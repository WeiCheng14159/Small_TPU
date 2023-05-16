`include "include/pkg_include.sv"
`include "systolic_array/systolic_array.sv"
`include "systolic_array/fifo_datapath.sv"

module systolic_array_controller
  import single_port_ram_pkg::*;
  import systolic_array_pkg::*;
  import accelerator_pkg::*;
(
    input  logic                               clk,
    input  logic                               rstn,
    input  accelerator_state_t                 curr_state,
    input  logic                        [31:0] M,
    N,
    K,
    output logic                               sa_done,
           single_port_ram_intf.compute        param_intf,
           single_port_ram_intf.compute        weight_intf,
           single_port_ram_intf.compute        bias_intf,
           single_port_ram_intf.compute        input_intf,
           single_port_ram_intf.compute        output_intf
);
  localparam TILE_DIM = 2;

  logic                                              array_enb;
  logic [               0:TILE_DIM * DATA_WIDTH - 1] row_i;
  logic [               0:TILE_DIM * DATA_WIDTH - 1] col_i;
  logic [0:TILE_DIM * TILE_DIM * 2 * DATA_WIDTH - 1] out_r;

  systolic_array_state_t sa_curr_state, sa_next_state;
  logic sa_step;
  logic [ADDR_WIDTH-1:0] row_base_addr, col_base_addr;
  assign row_base_addr = {ADDR_WIDTH{1'b0}};
  assign col_base_addr = {ADDR_WIDTH{1'b0}};

  always_ff @(posedge clk) begin
    if (~rstn) sa_curr_state <= SA_IDLE;
    else sa_curr_state <= sa_next_state;
  end

  always_comb begin
    unique case (1'b1)
      sa_curr_state[SA_IDLE_B]: sa_next_state = (curr_state == S_STREAM) ? SA_COMP : SA_IDLE;
      sa_curr_state[SA_COMP_B]: sa_next_state = SA_COMP;
      sa_curr_state[SA_HALT_B]: sa_next_state = SA_FINI;
      sa_curr_state[SA_FINI_B]: sa_next_state = SA_FINI;
      default: sa_next_state = SA_IDLE;
    endcase
  end

  // Row-direction datapath (Input matrix)
  logic [0:DATA_WIDTH-1] row_buff_to_array[0:TILE_DIM-1];
  fifo_datapath #(
      .TILE_DIM(TILE_DIM)
  ) row_fifo_datapath (
      .*,
      .base_addr(row_base_addr),
      .K(K),
      .bus_to_compute(row_buff_to_array),
      .buffer_intf(input_intf)
  );

  // Column-direction datapath (Weight matrix)
  logic [0:DATA_WIDTH-1] col_buff_to_array[0:TILE_DIM-1];
  fifo_datapath #(
      .TILE_DIM(TILE_DIM)
  ) col_fifo_datapath (
      .*,
      .base_addr(col_base_addr),
      .K(K),
      .bus_to_compute(col_buff_to_array),
      .buffer_intf(weight_intf)
  );

  // Connection between fifo_datapath and systolic array 
  genvar i;
  generate
    for (i = 0; i < TILE_DIM; i++) begin : CONNECT_FIFO_TO_ARRAY
      assign row_i[i*DATA_WIDTH+:DATA_WIDTH] = row_buff_to_array[i];
      assign col_i[i*DATA_WIDTH+:DATA_WIDTH] = col_buff_to_array[i];
    end
  endgenerate

  systolic_array #(
      .TILE_DIM  (TILE_DIM),
      .DATA_WIDTH(DATA_WIDTH)
  ) i_systolic_array (
      .*,
      .enb(sa_step),
      .in_row(row_i),
      .in_col(col_i),
      .out(out_r)
  );


endmodule
