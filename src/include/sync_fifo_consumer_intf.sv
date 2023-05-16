`ifndef SYNC_FIFO_CONSUMER_INTF_SV
`define SYNC_FIFO_CONSUMER_INTF_SV

// synchronize fifo interface with parameterized data width
interface sync_fifo_consumer_intf #(
    parameter DATA_WIDTH = 16
);
  // Read enable signals
  logic r_en;
  // Data input and output with parameterized width
  logic [DATA_WIDTH-1:0] data_out;
  // FIFO status signals
  logic empty;
  // Modports for easy signal access
  modport to_consumer(output r_en, input data_out, empty);
  modport to_fifo(input r_en, output data_out, empty);

endinterface


`endif
