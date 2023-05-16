`include "sync_fifo_consumer_intf.sv"

module fifo_consumer
  import fifo_consumer_pkg::*;
#(
    parameter WIDTH = 16
) (
    input logic clk,
    rstn,
    // Consumer side
    sync_fifo_consumer_intf.to_consumer consumer,
    output logic [WIDTH-1:0] to_systolic_array
);

  // fifo_consumer_state_t curr_state, next_state;

  // always_ff @(posedge clk) begin
  //   if (~rstn) curr_state <= IDLE;
  //   else curr_state <= next_state;
  // end

  // always_comb begin
  //   unique case (1'b1)
  //     curr_state[IDLE_B]: next_state = ~empty ? FEED : IDLE;
  //     curr_state[FEED_B]: next_state = empty ? IDLE : FEED;
  //     default: next_state = IDLE;
  //   endcase
  // end

  assign consumer.r_en = ~consumer.empty;
  always_ff @(posedge clk) begin
    if (~rstn) to_systolic_array <= {WIDTH{1'b0}};
    else if (~consumer.empty) to_systolic_array <= consumer.data_out;
  end

endmodule
