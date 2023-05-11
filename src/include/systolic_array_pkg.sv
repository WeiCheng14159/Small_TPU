`ifndef SYSTOLIC_ARRAY_PKG_SV
`define SYSTOLIC_ARRAY_PKG_SV

package systolic_array_pkg;
  // FSM
  localparam SA_IDLE_B = 0;
  localparam SA_COMP_B = 1;
  localparam SA_HALT_B = 2;
  localparam SA_FINI_B = 3;

  typedef enum logic [SA_FINI_B:0] {
    SA_IDLE = 1 << SA_IDLE_B,
    SA_COMP = 1 << SA_COMP_B,
    SA_HALT = 1 << SA_HALT_B,
    SA_FINI = 1 << SA_FINI_B
  } systolic_array_state_t;

endpackage

`endif
