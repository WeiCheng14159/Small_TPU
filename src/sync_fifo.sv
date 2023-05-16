`include "sync_fifo_consumer_intf.sv"
`include "sync_fifo_producer_intf.sv"

module sync_fifo #(
    parameter DEPTH = 8,
    parameter WIDTH = 16
) (
    input logic                           clk,
    input logic                           rstn,
    // Producer side 
          sync_fifo_producer_intf.to_fifo producer,
    // Consumer side
          sync_fifo_consumer_intf.to_fifo consumer
);

  logic [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  logic [WIDTH-1:0] fifo[DEPTH];

  // Set Default values on reset.
  always @(posedge clk) begin
    if (!rstn) begin
      w_ptr <= 0;
      r_ptr <= 0;
      consumer.data_out <= 0;
    end
  end

  // To write data to FIFO
  always @(posedge clk) begin
    if (producer.w_en & !producer.full) begin
      fifo[w_ptr] <= producer.data_in;
      w_ptr <= w_ptr + 1;
    end
  end

  // To read data from FIFO
  always @(posedge clk) begin
    if (consumer.r_en & !consumer.empty) begin
      consumer.data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end

  assign producer.full  = ((w_ptr + 1'b1) == r_ptr);
  assign consumer.empty = (w_ptr == r_ptr);
endmodule
