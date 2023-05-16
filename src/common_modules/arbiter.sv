`ifndef ARBITER
`define ARBITER

module arbiter #(
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

  localparam WRAP_LENGTH = 2 * NUM_PORTS;

  // Find First 1 - Start from MSB and count downwards, returns 0 when no bit set
  function [SEL_WIDTH-1:0] ff1(input logic [NUM_PORTS-1:0] in);
    logic   set;
    integer i;

    begin
      set = 1'b0;
      ff1 = 'b0;

      for (i = 0; i < NUM_PORTS; i = i + 1) begin
        if (in[i] & ~set) begin
          set = 1'b1;
          ff1 = i[0+:SEL_WIDTH];
        end
      end
    end
  endfunction


  logic                   next;
  logic [  NUM_PORTS-1:0] order;

  logic [  NUM_PORTS-1:0] token;
  logic [  NUM_PORTS-1:0] token_lookahead[NUM_PORTS-1:0];
  logic [WRAP_LENGTH-1:0] token_wrap;

  assign token_wrap = {token, token};
  assign next       = ~|(token & request);

  always @(posedge clk) begin
    if (~rstn) grant <= {NUM_PORTS{1'b0}};
    else grant <= token & request;

  end
  always @(posedge clk) begin
    if (~rstn) select <= {SEL_WIDTH{1'b0}};
    else select <= ff1(token & request);
  end

  always @(posedge clk) begin
    if (~rstn) active <= 1'b0;
    else active <= |(token & request);
  end

  integer yy;
  always @(posedge clk)
    if (~rstn) token <= 'b1;
    else if (next) begin
      for (yy = 0; yy < NUM_PORTS; yy = yy + 1) begin : TOKEN_
        if (order[yy]) begin
          token <= token_lookahead[yy];
        end
      end
    end

  genvar xx;
  generate
    for (xx = 0; xx < NUM_PORTS; xx = xx + 1) begin : ORDER_
      assign token_lookahead[xx] = token_wrap[xx+:NUM_PORTS];
      assign order[xx]           = |(token_lookahead[xx] & request);
    end
  endgenerate

endmodule

`endif

/**
Main Functionality:

The ff1 function: This function finds the first set bit (1) in the input. It starts from the most significant bit and counts downwards.

The token register and token_lookahead wires: These are used to implement a round-robin policy for granting access to the memory. When a port is granted access, the token is shifted to indicate that the next port in line should be granted access next time.

The next wire: This is used to determine when the token should be shifted. It is set when none of the ports currently requesting access are allowed to access the memory.

The grant, select, and active assignments: These are updated on each rising edge of the clock signal. grant is the bitwise AND of token and request, indicating which of the requesting ports are granted access. select uses the ff1 function to find the first port that is granted access. active is the bitwise OR of token and request, indicating whether any port is granted access.

The rst condition in the token assignment: If the reset signal is active, the token is set to 1, resetting the round-robin policy.

The generate loop: This generates the token_lookahead and order wires for each port. The token_lookahead wire is a shifted version of the token, and the order wire indicates whether the corresponding token_lookahead and request have any set bits in common.

This arbiter provides a fair access policy by ensuring that each port gets access to the memory in turn. It also provides priority to lower indexed ports in case of simultaneous requests.
**/
