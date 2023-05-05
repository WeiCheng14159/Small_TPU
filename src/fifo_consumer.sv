`include "define.v"

`ifndef FIFO_CONSUMER
`define FIFO_CONSUMER

module fifo_consumer #(
    parameter WIDTH = 16
) (
    input logic clk,
    rstn,
    input logic    empty,
    input logic [WIDTH-1:0] from_fifo,
    // input logic [`ADDR_WIDTH-1:0] base_addr,
    // input logic [`ADDR_WIDTH-1:0] addr_step,
    // input logic [`ADDR_WIDTH-1:0] end_addr,

    output logic r_en,
    output logic [WIDTH-1:0] to_array
);

  logic [`ADDR_WIDTH-1:0] addr;

  assign r_en = 1'b1;

  // always_ff @(posedge clk) begin
  //   if (~rstn) addr <= base_addr;
  //   else addr <= (empty & r_en) ? addr + addr_step : addr;
  // end

  always_ff @(posedge clk) begin
    if (~rstn) to_array <= `EMPTY_DATA;
    else to_array <= (empty) ? `EMPTY_DATA : from_fifo;
  end

endmodule
`endif
