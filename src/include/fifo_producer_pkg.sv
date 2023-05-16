`ifndef FIFO_PRODUCER_PKG_SV
`define FIFO_PRODUCER_PKG_SV

package fifo_producer_pkg;
  // FSM
  localparam IDLE_B = 0;
  localparam BURST_B = 1;

  typedef enum logic [BURST_B:0] {
    IDLE  = 1 << IDLE_B,
    BURST = 1 << BURST_B
  } fifo_producer_state_t;

endpackage

`endif
