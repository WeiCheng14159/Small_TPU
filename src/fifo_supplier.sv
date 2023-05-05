`include "define.v"

`ifndef FIFO_SUPPLIER
`define FIFO_SUPPLIER

module fifo_supplier #(
    parameter WIDTH = 16
) (
    input logic clk,
    rstn,
    input logic    full,
    input logic [WIDTH-1:0] from_mem,

    input logic [`ADDR_WIDTH-1:0] base_addr,
    input logic [`ADDR_WIDTH-1:0] addr_step,
    input logic [`ADDR_WIDTH-1:0] end_addr,

    output logic                            w_en,
    output logic                [WIDTH-1:0] to_fifo,
           single_port_ram_intf             buffer_intf
);

  localparam IDLE = 0, LOAD = 1, FINISH = 2;

  typedef enum logic [FINISH:0] {
    S_IDLE   = 1 << IDLE,
    S_LOAD   = 1 << LOAD,
    S_FINISH = 1 << FINISH
  } state_t;

  state_t curr_state, next_state;
  logic [WIDTH-1:0] addr;

  assign addr_in_range = (addr >= base_addr && addr <= end_addr) ? 1'b1 : 1'b0;

  // State Register (S)
  always_ff @(posedge clk) begin
    if (~rstn) curr_state <= S_IDLE;
    else curr_state <= next_state;
  end

  // Next State Logic (C)
  always_comb begin
    next_state = S_IDLE;
    if (~rstn) begin
      next_state[IDLE] = 1'b1;
    end else begin
      unique case (1'b1)
        curr_state[IDLE]:   next_state = (addr_in_range) ? S_LOAD : S_IDLE;
        curr_state[LOAD]:   next_state = S_IDLE;
        curr_state[FINISH]: next_state = S_IDLE;
      endcase
    end
  end

endmodule

`endif
