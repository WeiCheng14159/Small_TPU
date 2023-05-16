`include "sync_fifo_producer_intf.sv"

module fifo_producer
  import fifo_producer_pkg::*;
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 20,
    parameter BURST_SIZE = 4
) (
    input logic clk,
    rstn,
    // module control signal 
    output logic request,
    input logic grant,
    // address start, end address
    input logic [ADDR_WIDTH-1:0] addr_begin,
    input logic [ADDR_WIDTH-1:0] addr_nstep,  // negative step size
    input logic [ADDR_WIDTH-1:0] addr_end,
    // datapath
    sync_fifo_producer_intf.to_producer producer,
    output logic to_buffer_cs,
    output logic to_buffer_oe,
    output logic [ADDR_WIDTH-1:0] to_buffer_addr,
    input logic [DATA_WIDTH-1:0] to_buffer_R_data,
    output logic to_buffer_W_req,
    output logic [DATA_WIDTH-1:0] to_buffer_W_data
);

  fifo_producer_state_t curr_state, next_state;
  logic transfer_done;
  logic [31:0] burst_cnt;
  logic fifo_ready;

  always_ff @(posedge clk) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end

  assign transfer_done = (to_buffer_addr > addr_end);
  assign request = !transfer_done;
  always_ff @(posedge clk) begin
    if (~rstn) to_buffer_addr <= addr_begin;
    else if (grant) to_buffer_addr <= to_buffer_addr - addr_nstep;
  end

  assign fifo_ready = (grant && ~transfer_done && ~producer.full);
  always_comb begin
    unique case (1'b1)
      curr_state[IDLE_B]: next_state = fifo_ready ? BURST : IDLE;
      curr_state[BURST_B]: next_state = (burst_cnt == BURST_SIZE) ? IDLE : BURST;
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rstn) burst_cnt <= 0;
    else if (curr_state == IDLE) burst_cnt <= 0;
    else if (grant) burst_cnt <= burst_cnt + 1;
  end

  assign producer.w_en = (curr_state == BURST) && ~producer.full;
  always_ff @(posedge clk) begin
    if (~rstn) producer.data_in <= {DATA_WIDTH{1'b0}};
    else if (grant) producer.data_in <= to_buffer_R_data;
    else producer.data_in <= {DATA_WIDTH{1'b0}};
  end

  assign to_buffer_W_data = accelerator_pkg::EMPTY_DATA;
  assign to_buffer_W_req = single_port_ram_pkg::WREQ_DIS;
  assign to_buffer_cs = ((curr_state == IDLE) && fifo_ready) || (curr_state == BURST) ? single_port_ram_pkg::CS_ENB: single_port_ram_pkg::CS_DIS;
  assign to_buffer_oe = ((curr_state == IDLE) && fifo_ready) || (curr_state == BURST) ? single_port_ram_pkg::OE_ENB: single_port_ram_pkg::OE_DIS;

endmodule
