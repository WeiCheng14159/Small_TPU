module fifo_consumer
  import accelerator_pkg::*;
#(
    parameter WIDTH = 16
) (
    input logic clk,
    rstn,
    input logic    empty,
    input logic [WIDTH-1:0] from_fifo,
    output logic r_en,
    output logic [WIDTH-1:0] to_array
);

  logic [ADDR_WIDTH-1:0] addr;

  assign r_en = 1'b1;

  always_ff @(posedge clk) begin
    if (~rstn) to_array <= {WIDTH{1'b0}};
    else to_array <= (empty) ? {WIDTH{1'b0}} : from_fifo;
  end

endmodule
