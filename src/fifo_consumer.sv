`include "sync_fifo_consumer_intf.sv"

module fifo_consumer
  import fifo_consumer_pkg::*;
#(
    parameter WIDTH = 16
) (
    input logic clk,
    input logic rstn,
    input logic feed,
    output logic stall,
    // Consumer side
    sync_fifo_consumer_intf.to_consumer consumer,
    output logic [WIDTH-1:0] to_systolic_array
);

  logic r_valid;

  assign consumer.r_en = (feed && ~consumer.empty);
  assign stall = consumer.empty;

  always_ff @(posedge clk) begin
    if (~rstn) r_valid <= 1'b0;
    else r_valid <= consumer.r_en;
  end

  assign to_systolic_array = (r_valid) ? consumer.data_out : {WIDTH{1'b0}};

endmodule
