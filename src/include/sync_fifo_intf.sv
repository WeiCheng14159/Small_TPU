`ifndef FIFO_INTF
`define FIFO_INTF

// SyncFIFO Interface with Parameterized Data Width
interface sync_fifo_intf #(
    parameter DATA_WIDTH = 16
) (
    input logic clk,
    input logic rstn
);

  // Write and Read enable signals
  logic w_en;
  logic r_en;

  // Data input and output with parameterized width
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;

  // FIFO status signals
  logic full;
  logic empty;

  // Modports for easy signal access
  modport fifo_feed(input clk, rstn, output w_en, r_en, data_in, input data_out, full, empty);

  modport fifo_serve(input clk, rstn, input w_en, r_en, data_in, output data_out, full, empty);

endinterface


`endif
