`ifndef GENERIC_MUX
`define GENERIC_MUX

module generic_mux #(
    parameter DATA_WIDTH = 16,
    parameter MUX_NUM = 64,
    localparam SELECT_W = $clog2(MUX_NUM)
) (
    input  logic [  SELECT_W-1:0] sel,
    input  logic [DATA_WIDTH-1:0] mux_in[MUX_NUM-1:0],
    output logic [DATA_WIDTH-1:0] out
);

  assign out = mux_in[sel];

endmodule

`endif
