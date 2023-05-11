`include "include/pkg_include.sv"

module accelerator_controller
  import accelerator_pkg::*;
  import single_port_ram_pkg::*;
(
    input  logic                       clk,
    input  logic                       rstn,
    input  logic                       start,
    output logic                       finish,
    input  logic                       sa_done,
    output logic                [31:0] M,
    N,
    K,
    output accelerator_state_t         curr_state,
           single_port_ram_intf        param_intf
);

  accelerator_state_t next_state;
  logic load_param_done;

  // State Register (S)
  always @(posedge clk) begin
    if (~rstn) curr_state <= S_IDLE;
    else curr_state <= next_state;
  end

  // Next State Logic (C)
  always_comb begin
    next_state = S_IDLE;
    unique case (1'b1)
      curr_state[IDLE_B]: begin
        next_state = (start) ? S_PARAM : S_IDLE;
      end
      curr_state[PARAM_B]: begin
        next_state = load_param_done ? S_STREAM : S_PARAM;
      end
      curr_state[STREAM_B]: begin
        next_state = sa_done ? S_FIN : S_STREAM;
      end
      curr_state[IMG2COL_B]: begin
        next_state = S_IDLE;
      end
      curr_state[FIN_B]: begin
        next_state = S_IDLE;
      end
      default: next_state = S_IDLE;
    endcase
  end

  assign load_param_done = (param_intf.addr == 3);

  always_ff @(posedge clk) begin
    if (~rstn) begin
      param_intf.addr <= EMPTY_ADDR;
    end else if (curr_state == S_PARAM) begin
      param_intf.addr <= param_intf.addr + 1'b1;
    end
  end

  assign param_intf.cs = (curr_state == S_PARAM) ? CS_ENB : CS_DIS;
  assign param_intf.oe = (curr_state == S_PARAM) ? OE_ENB : OE_DIS;
  assign param_intf.W_req = (curr_state == S_PARAM) ? WREQ_DIS : WREQ_ENB;
  assign param_intf.W_data = EMPTY_DATA;

  always_ff @(posedge clk) begin
    if (~rstn) begin
      {M, N, K} <= {32'h0, 32'h0, 32'h0};
    end else if (curr_state == S_PARAM) begin
      if (param_intf.addr == 1) M <= param_intf.R_data;
      else if (param_intf.addr == 2) K <= param_intf.R_data;
      else if (param_intf.addr == 3) N <= param_intf.R_data;
    end
  end

  assign finish = (curr_state == S_FIN);

endmodule
