`include "systolic_array/tile.sv"
`include "include/define.v"

`ifndef SYSTOLIC_ARRAY_SV
`define SYSTOLIC_ARRAY_SV

module systolic_array #(
    parameter TILE_DIM = 64
) (
    input logic clk,
    rstn,
    enb,
    input logic [0:TILE_DIM * `DATA_WIDTH - 1] in_row,
    input logic [0:TILE_DIM * `DATA_WIDTH - 1] in_col,
    output logic [0:TILE_DIM * TILE_DIM * 2 * `DATA_WIDTH - 1] out
);

  tile #(
      .M(TILE_DIM),
      .N(TILE_DIM),
      .INPUT_WIDTH(`DATA_WIDTH)
  ) i_tile (
      .clk(clk),
      .rst(~rstn),
      .enb(enb),
      .in_row(in_row),
      .in_col(in_col),
      .out(out)
  );

endmodule

`endif
