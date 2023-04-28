`include "include/define.v"

module AcceleratorController (
    input                                   clk,
    input                                   rstn,
    output logic             [`STATE_W-1:0] curr_state,
           SinglePortRamIntf                param_intf
);

  reg [`STATE_W-1:0] next_state;

  // State Register (S)
  always @(posedge clk) begin
    if (~rstn) curr_state <= (1 << `S_IDLE);
    else curr_state <= next_state;
  end

  // Next State Logic (C)
  always @(*) begin
    next_state = 0;
    if (~rstn) begin
      next_state[`S_IDLE] = 1'b1;
    end else begin
      case (1'b1)
        curr_state[`S_IDLE]: begin
          next_state[`S_IDLE] = 1'b1;
        end

        curr_state[`S_LOAD]: begin
          next_state[`S_IDLE] = 1'b1;
        end

        curr_state[`S_STREAM]: begin
          next_state[`S_IDLE] = 1'b1;
        end

        curr_state[`S_TAIL]: begin
          next_state[`S_IDLE] = 1'b1;
        end

        curr_state[`S_IMG2COL]: begin
          next_state[`S_IDLE] = 1'b1;
        end

        curr_state[`S_END]: begin
          next_state[`S_IDLE] = 1'b1;
        end
      endcase
    end
  end
endmodule
