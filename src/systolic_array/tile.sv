`include "systolic_array/mac.sv"

`ifndef TILE_SV
`define TILE_SV

module tile #(
    parameter M = 64,  // M rows
    parameter N = 64,  // N columns
    parameter INPUT_WIDTH = 16
) (
    input logic clk,
    rst,
    enb,
    input logic [0:M * INPUT_WIDTH - 1] in_row,
    input logic [0:N * INPUT_WIDTH - 1] in_col,
    output logic [0:M * N * 2 * INPUT_WIDTH - 1] out
);

  // wires used to connect macs
  wire [0:N * INPUT_WIDTH - 1] col_wire[0:M];
  wire [0:M * INPUT_WIDTH - 1] row_wire[0:N];

  assign col_wire[0] = in_col;
  assign row_wire[0] = in_row;

  // generates 2-dimension mac array in loop
  genvar i, j;
  generate
    begin
      for (i = 0; i < M; i = i + 1) begin : for_row
        for (j = 0; j < N; j = j + 1) begin : for_col

          mac #(
              .INPUT_WIDTH(INPUT_WIDTH)
          ) i_mac (
              .clk  (clk),
              .rst  (rst),
              .enb  (enb),
              .in_a (row_wire[j][(i*INPUT_WIDTH)+:INPUT_WIDTH]),
              .in_b (col_wire[i][(j*INPUT_WIDTH)+:INPUT_WIDTH]),
              .out_a(row_wire[j+1][(i*INPUT_WIDTH)+:INPUT_WIDTH]),
              .out_b(col_wire[i+1][(j*INPUT_WIDTH)+:INPUT_WIDTH]),
              .out_c(out[((i*N+j)*2*INPUT_WIDTH)+:2*INPUT_WIDTH])
          );

        end
      end
    end
  endgenerate

endmodule

`endif
