`include "include/pkg_include.sv"
`include "sync_fifo.sv"
`include "fifo_consumer.sv"
`include "fifo_producer.sv"
`include "common_modules/arbiter.sv"
`include "systolic_array/addr_bus_mux.sv"

module fifo_datapath
  import single_port_ram_pkg::*;
  import accelerator_pkg::*;
#(
    parameter TILE_DIM = 64
) (
    input  logic                                         clk,
    input  logic                                         rstn,
    input  logic                                         soft_rst,
    output logic                                         stall,
    output logic                                         done,
    input  logic                        [ADDR_WIDTH-1:0] base_addr,
    input  logic                        [          31:0] K,
    output logic                        [DATA_WIDTH-1:0] bus_to_compute[0:TILE_DIM-1],
           single_port_ram_intf.compute                  buffer_intf
);

  /* Notice that FIFO_DEPTH should be at least 2 times of BURST_SIZE  
  because a BURST_SIZE amount of data will be pushed into fifo once it 
  found the fifo is not full (no matter how many vacant slots available.) */
  localparam BURST_SIZE = 4;
  localparam FIFO_DEPTH = 8;  // Should be power of 2 

  // Bus: fifo consumer <-> systolic array 
  logic [0:TILE_DIM * DATA_WIDTH - 1] bus_to_array;
  logic [TILE_DIM-1:0] stall_vec, feed_vec, done_vec;

  // Bus: fifo <-> producer and consumer
  sync_fifo_producer_intf #(.DATA_WIDTH(DATA_WIDTH)) producer_intf[TILE_DIM] ();
  sync_fifo_consumer_intf #(.DATA_WIDTH(DATA_WIDTH)) consumer_intf[TILE_DIM] ();

  // Bus: producer <---arbiter---> buffer
  // single_port_ram_intf producer_to_buffer[TILE_DIM] ();
  logic                  to_buffer_cs    [TILE_DIM-1:0];
  logic                  to_buffer_oe    [TILE_DIM-1:0];
  logic [ADDR_WIDTH-1:0] to_buffer_addr  [TILE_DIM-1:0];
  logic [DATA_WIDTH-1:0] to_buffer_R_data[TILE_DIM-1:0];
  logic                  to_buffer_W_req [TILE_DIM-1:0];
  logic [DATA_WIDTH-1:0] to_buffer_W_data[TILE_DIM-1:0];

  // buffer bus arbiter 
  logic [TILE_DIM-1:0] grant, request;
  logic [((TILE_DIM > 1) ? $clog2(TILE_DIM) : 1)-1:0] select;
  arbiter #(
      .NUM_PORTS(TILE_DIM)
  ) mem_arbiter (
      .*,
      .request(request),
      .grant(grant),
      .select(select),
      .active()  // not connected
  );

  genvar fifo_idx;
  generate
    // fifo
    for (fifo_idx = 0; fifo_idx < TILE_DIM; fifo_idx++) begin : SYNC_FIFO
      sync_fifo #(
          .DEPTH(FIFO_DEPTH),
          .WIDTH(DATA_WIDTH)
      ) sync_fifo (
          .*,
          .producer(producer_intf[fifo_idx]),
          .consumer(consumer_intf[fifo_idx])
      );
    end
    // fifo consumer 
    for (fifo_idx = 0; fifo_idx < TILE_DIM; fifo_idx++) begin : FIFO_CONSUMER
      fifo_consumer #(
          .WIDTH(DATA_WIDTH)
      ) fifo_consumer (
          .*,
          .feed(feed_vec[fifo_idx]),
          .stall(stall_vec[fifo_idx]),
          .consumer(consumer_intf[fifo_idx]),
          .to_systolic_array(bus_to_compute[fifo_idx])
      );
    end
    // fifo producer    
    for (fifo_idx = 0; fifo_idx < TILE_DIM; fifo_idx++) begin : FIFO_PRODUCER
      // address 
      logic [ADDR_WIDTH-1:0] addr_begin, addr_nstep, addr_end;
      assign addr_begin = base_addr + K * (fifo_idx + 1) - 1;
      assign addr_nstep = 1;
      assign addr_end   = base_addr + K * fifo_idx;

      fifo_producer #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .BURST_SIZE(BURST_SIZE)
      ) fifo_producer (
          .*,
          .done(done_vec[fifo_idx]),
          .request(request[fifo_idx]),
          .grant(grant[fifo_idx]),
          .addr_begin(addr_begin),
          .addr_nstep(addr_nstep),
          .addr_end(addr_end),
          .producer(producer_intf[fifo_idx]),
          .to_buffer_cs(to_buffer_cs[fifo_idx]),
          .to_buffer_oe(to_buffer_oe[fifo_idx]),
          .to_buffer_addr(to_buffer_addr[fifo_idx]),
          .to_buffer_R_data(to_buffer_R_data[fifo_idx]),
          .to_buffer_W_req(to_buffer_W_req[fifo_idx]),
          .to_buffer_W_data(to_buffer_W_data[fifo_idx])
      );
    end
  endgenerate

  // connect buffer bus to producer bus (controller by memory arbiter)
  addr_bus_mux #(
      .MUX_NUM(TILE_DIM),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) addr_mux (
      .*,
      .sel(select),
      .buff_intf(buffer_intf)
  );

  always_ff @(posedge clk) begin
    if (~rstn) feed_vec <= {TILE_DIM{1'b0}};
    else begin
      feed_vec[0] <= ~stall;  // Not stall means active
      for (integer idx = 1; idx < TILE_DIM; idx++) begin
        feed_vec[idx] <= feed_vec[idx-1];
      end
    end
  end

  // stall caused by empty fifo
  assign stall = |stall_vec;
  assign done  = &done_vec;
endmodule
