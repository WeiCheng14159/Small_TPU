`include "sync_fifo_producer_intf.sv"

module fifo_producer
  import fifo_producer_pkg::*;
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 20,
    parameter BURST_SIZE = 4
) (
    input logic clk,
    input logic rstn,
    input logic soft_rst,
    output logic done,
    // module control signal 
    output logic request,
    input logic grant,
    // address start, end address
    input logic [ADDR_WIDTH-1:0] addr_begin,
    input logic [ADDR_WIDTH-1:0] addr_nstep,  // negative step size
    input logic [ADDR_WIDTH-1:0] addr_end,
    // datapath
    sync_fifo_producer_intf.to_producer producer,
    output logic to_buffer_cs,
    output logic to_buffer_oe,
    output logic [ADDR_WIDTH-1:0] to_buffer_addr,
    input logic [DATA_WIDTH-1:0] to_buffer_R_data,
    output logic to_buffer_W_req,
    output logic [DATA_WIDTH-1:0] to_buffer_W_data
);

  fifo_producer_state_t curr_state, next_state;
  logic [31:0] burst_cnt;
  logic fifo_ready;

  always_ff @(posedge clk) begin
    if (~rstn) curr_state <= IDLE;
    else curr_state <= next_state;
  end

  assign done = (curr_state == DONE);
  assign request = (curr_state == WAIT || curr_state == BURST) && ~producer.full;
  always_ff @(posedge clk) begin
    if (~rstn) to_buffer_addr <= {ADDR_WIDTH{1'b0}};
    else if (curr_state == IDLE && soft_rst) to_buffer_addr <= addr_begin;
    else if (curr_state == BURST) to_buffer_addr <= to_buffer_addr - addr_nstep;
  end

  assign fifo_ready = (grant && ~producer.full);
  always_comb begin
    unique case (1'b1)
      curr_state[IDLE_B]: next_state = (soft_rst) ? WAIT : IDLE;
      curr_state[WAIT_B]: next_state = fifo_ready ? BURST : WAIT;
      curr_state[BURST_B]: begin
        if (to_buffer_addr == addr_end) next_state = BURST_DONE;
        else if (burst_cnt == (BURST_SIZE - 1)) next_state = BURST_NDONE;
        else next_state = BURST;
      end
      curr_state[BURST_DONE_B]: next_state = DONE;
      curr_state[BURST_NDONE_B]: next_state = WAIT;
      curr_state[DONE_B]: next_state = (soft_rst) ? WAIT : DONE;
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk) begin
    if (~rstn) burst_cnt <= 0;
    else if (curr_state == WAIT || curr_state == BURST_DONE || curr_state == BURST_NDONE)
      burst_cnt <= 0;
    else if (curr_state == BURST) burst_cnt <= burst_cnt + 1;
  end

  always_ff @(posedge clk) begin
    if (~rstn) producer.w_en <= 1'b0;
    else producer.w_en <= (~producer.full && |burst_cnt) ? 1'b1 : 1'b0;
  end

  always_ff @(posedge clk) begin
    if (~rstn) producer.data_in <= {DATA_WIDTH{1'b0}};
    else producer.data_in <= to_buffer_R_data;
  end

  assign to_buffer_W_data = accelerator_pkg::EMPTY_DATA;
  assign to_buffer_W_req = single_port_ram_pkg::WREQ_DIS;
  assign mem_enb = (curr_state == BURST || curr_state == BURST_DONE || curr_state == BURST_NDONE);
  assign to_buffer_cs = mem_enb ? single_port_ram_pkg::CS_ENB : single_port_ram_pkg::CS_DIS;
  assign to_buffer_oe = mem_enb ? single_port_ram_pkg::OE_ENB : single_port_ram_pkg::OE_DIS;

endmodule
