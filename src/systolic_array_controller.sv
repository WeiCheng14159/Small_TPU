`include "include/define.v"
`include "systolic_array/systolic_array.sv"

module SystolicArrayController (
    input  logic                            clk,
    input  logic                            rstn,
    output logic                            finish,
    input  logic             [`STATE_W-1:0] curr_state,
           SinglePortRamIntf                param_intf,
           SinglePortRamIntf                weight_intf,
           SinglePortRamIntf                bias_intf,
           SinglePortRamIntf                input_intf,
           SinglePortRamIntf                output_intf
);
  localparam TILE_DIM = 64;

  logic                                               array_enb;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] row_i;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] col_i;
  logic [0:TILE_DIM * TILE_DIM * 2 * `DATA_WIDTH - 1] out_r;

  // TODO: Implement necessary buffer 

  SystolicArray #(
      .TILE_DIM(TILE_DIM)
  ) i_SystolicArray (
      .clk(clk),
      .rstn(rstn),
      .enb(array_enb),
      .in_row(row_i),
      .in_col(col_i),
      .out(out_r)
  );

endmodule
