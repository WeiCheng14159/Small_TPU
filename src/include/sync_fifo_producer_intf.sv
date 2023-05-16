`ifndef SYNC_FIFO_PRODUCER_INTF_SV
`define SYNC_FIFO_PRODUCER_INTF_SV

// synchronize fifo interface with parameterized data width
interface sync_fifo_producer_intf #(
    parameter DATA_WIDTH = 16
);
  // Write enable signals
  logic w_en;
  // Data input with parameterized width
  logic [DATA_WIDTH-1:0] data_in;
  // FIFO status signals
  logic full;
  // Modports for easy signal access
  modport to_producer(output w_en, data_in, input full);
  modport to_fifo(input w_en, data_in, output full);

endinterface


`endif
