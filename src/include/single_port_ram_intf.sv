`ifndef SINGLE_PORT_RAM_INTF
`define SINGLE_PORT_RAM_INTF

`include "define.v"

interface single_port_ram_intf;

  logic                   cs;
  logic                   oe;
  logic [`ADDR_WIDTH-1:0] addr;
  logic [`DATA_WIDTH-1:0] R_data;
  logic                   W_req;
  logic [`DATA_WIDTH-1:0] W_data;

  // To memory
  modport memory(output R_data, input cs, oe, addr, W_req, W_data);
  // To compute unit
  modport compute(input R_data, output cs, oe, addr, W_req, W_data);

endinterface
`endif
