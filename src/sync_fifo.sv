
`ifndef SYNC_FIFO_SV
`define SYNC_FIFO_SV

module sync_fifo #(
    parameter DEPTH = 8,
    parameter WIDTH = 16
) (
    input logic clk,
    rstn,
    input logic w_en,
    r_en,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic full,
    empty
);

  logic [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  logic [WIDTH-1:0] fifo[DEPTH];

  // Set Default values on reset.
  always @(posedge clk) begin
    if (!rstn) begin
      w_ptr <= 0;
      r_ptr <= 0;
      data_out <= 0;
    end
  end

  // To write data to FIFO
  always @(posedge clk) begin
    if (w_en & !full) begin
      fifo[w_ptr] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end

  // To read data from FIFO
  always @(posedge clk) begin
    if (r_en & !empty) begin
      data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end

  assign full  = ((w_ptr + 1'b1) == r_ptr);
  assign empty = (w_ptr == r_ptr);
endmodule

`endif
