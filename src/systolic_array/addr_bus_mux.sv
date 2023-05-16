`include "include/pkg_include.sv"

`ifndef ADDR_BUS_MUX
`define ADDR_BUS_MUX

module addr_bus_mux #(
    parameter MUX_NUM = 64,
    parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 16,
    parameter SELECT_W = $clog2(MUX_NUM)
) (
    input  logic                        [  SELECT_W-1:0] sel,
    input  logic                                         to_buffer_cs    [MUX_NUM-1:0],
    input  logic                                         to_buffer_oe    [MUX_NUM-1:0],
    input  logic                        [ADDR_WIDTH-1:0] to_buffer_addr  [MUX_NUM-1:0],
    output logic                        [DATA_WIDTH-1:0] to_buffer_R_data[MUX_NUM-1:0],
    input  logic                                         to_buffer_W_req [MUX_NUM-1:0],
    input  logic                        [DATA_WIDTH-1:0] to_buffer_W_data[MUX_NUM-1:0],
           single_port_ram_intf.compute                  buff_intf
);

  assign buff_intf.cs = to_buffer_cs[sel];
  assign buff_intf.oe = to_buffer_oe[sel];
  assign buff_intf.addr = to_buffer_addr[sel];
  assign buff_intf.W_req = to_buffer_W_req[sel];
  assign buff_intf.W_data = to_buffer_W_data[sel];

  logic [DATA_WIDTH-1:0] R_data;
  always_comb begin
    to_buffer_R_data[sel] = buff_intf.R_data;
  end

endmodule

`endif
