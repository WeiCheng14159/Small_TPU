`ifndef ARBITER_V1
`define ARBITER_V1

module arbiter_v1 #(
    parameter NUM_PORTS = 64,
    SEL_WIDTH = ((NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1)
) (
    input  logic                 clk,
    input  logic                 rstn,
    input  logic [NUM_PORTS-1:0] request,
    output logic [NUM_PORTS-1:0] grant,
    output logic [SEL_WIDTH-1:0] select,
    output logic                 active
);
  logic [NUM_PORTS-1:0] request_q;
  logic [NUM_PORTS-1:0] grant_q;
  logic [SEL_WIDTH-1:0] rr_counter;

  assign grant  = grant_q;
  assign select = rr_counter;
  assign active = |grant_q;

  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      request_q <= '0;
      grant_q <= '0;
      rr_counter <= 0;
    end else begin
      request_q <= request;
      if (request_q != 0) begin
        for (int i = 0; i < NUM_PORTS; i++) begin
          grant_q[i] <= (request_q[i] && (rr_counter == i)) ? 1'b1 : 1'b0;
        end
        rr_counter <= (rr_counter == NUM_PORTS - 1) ? 0 : (rr_counter + 1);
      end
    end
  end
endmodule

`endif
