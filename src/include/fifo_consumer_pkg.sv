`ifndef FIFO_CONSUMER_PKG_SV
`define FIFO_CONSUMER_PKG_SV

package fifo_consumer_pkg;
  // FSM
  localparam IDLE_B = 0;
  localparam FEED_B = 1;

  typedef enum logic [FEED_B:0] {
    IDLE = 1 << IDLE_B,
    FEED = 1 << FEED_B
  } fifo_consumer_state_t;

endpackage

`endif
