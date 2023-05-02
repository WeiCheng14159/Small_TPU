`ifndef MAC_SV
`define MAC_SV

//            |
//           in_b  
//            |  
// -- in_a --xxxx -- out_a
//           xxxx \ 
//            |    \
//           out_b  \
//            |     out_c

module mac #(
    parameter INPUT_WIDTH = 8
) (
    input logic clk,
    rst,
    enb,
    input logic signed [0:INPUT_WIDTH - 1] in_a,
    in_b,
    output logic signed [0:INPUT_WIDTH - 1] out_a,
    out_b,
    output logic signed [0:2 * INPUT_WIDTH - 1] out_c
);


  logic signed [0:INPUT_WIDTH - 1] a_reg, b_reg;
  logic signed [0:2 * INPUT_WIDTH - 1] c_reg;

  always @(posedge clk) begin
    if (rst) {a_reg, b_reg, c_reg} <= 0;
    else if (enb) begin
      a_reg <= in_a;
      b_reg <= in_b;
      c_reg <= in_a * in_b + c_reg;
    end
  end

  assign out_a = a_reg;
  assign out_b = b_reg;
  assign out_c = c_reg;

endmodule

`endif
