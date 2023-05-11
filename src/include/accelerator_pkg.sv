`ifndef ACCELERATOR_PKG_SV
`define ACCELERATOR_PKG_SV

package accelerator_pkg;
  // FSM
  localparam IDLE_B = 0;
  localparam PARAM_B = 1;
  localparam STREAM_B = 2;
  localparam IMG2COL_B = 3;
  localparam FIN_B = 4;

  typedef enum logic [FIN_B:0] {
    S_IDLE = 1 << IDLE_B,
    S_PARAM = 1 << PARAM_B,
    S_STREAM = 1 << STREAM_B,
    S_IMG2COL = 1 << IMG2COL_B,
    S_FIN = 1 << FIN_B
  } accelerator_state_t;

  // Data size
  localparam DATA_WIDTH = 16;
  localparam ADDR_WIDTH = 20;
  localparam EMPTY_ADDR = {ADDR_WIDTH{1'b0}};
  localparam EMPTY_DATA = {DATA_WIDTH{1'b0}};
  // Mode
  localparam MODE_WIDTH = 4;
endpackage

`endif
