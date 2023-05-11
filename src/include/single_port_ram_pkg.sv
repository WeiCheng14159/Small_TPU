`ifndef SINGLE_PORT_RAM_PKG_SV
`define SINGLE_PORT_RAM_PKG_SV

package single_port_ram_pkg;
  localparam CS_ENB = 1'b1;
  localparam CS_DIS = 1'b0;
  localparam OE_ENB = 1'b1;
  localparam OE_DIS = 1'b0;
  localparam WREQ_ENB = 1'b0;
  localparam WREQ_DIS = 1'b1;
endpackage

`endif
