`ifndef FIFO_PRODUCER_PKG_SV
`define FIFO_PRODUCER_PKG_SV

package fifo_producer_pkg;
  // FSM
  localparam IDLE_B = 0;
  localparam WAIT_B = 1;
  localparam BURST_B = 2;
  localparam DONE_B = 3;

  typedef enum logic [DONE_B:0] {
    IDLE  = 1 << IDLE_B,
    WAIT  = 1 << WAIT_B,
    BURST = 1 << BURST_B,
    DONE  = 1 << DONE_B
  } fifo_producer_state_t;

endpackage

`endif
