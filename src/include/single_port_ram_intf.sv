`ifndef SINGLE_PORT_RAM_INTF_SV
`define SINGLE_PORT_RAM_INTF_SV

interface single_port_ram_intf #(
    parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 16
);

  logic                  cs;  // chip select signal for both RW
  logic                  oe;  // output enable signal for R 
  logic [ADDR_WIDTH-1:0] addr;  // address signal for both RW 
  logic [DATA_WIDTH-1:0] R_data;  // read data
  logic                  W_req;  // write request
  logic [DATA_WIDTH-1:0] W_data;  // write data

  // To memory
  modport memory(output R_data, input cs, oe, addr, W_req, W_data);
  // To compute unit
  modport compute(input R_data, output cs, oe, addr, W_req, W_data);

endinterface
`endif
