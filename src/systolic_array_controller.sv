`include "include/define.v"
`include "systolic_array/systolic_array.sv"
`include "sync_fifo.sv"

module SystolicArrayController (
    input  logic                            clk,
    input  logic                            rstn,
    output logic                            finish,
    input  logic             [`STATE_W-1:0] curr_state,
           SinglePortRamIntf                param_intf,
           SinglePortRamIntf                weight_intf,
           SinglePortRamIntf                bias_intf,
           SinglePortRamIntf                input_intf,
           SinglePortRamIntf                output_intf
);
  localparam TILE_DIM = 64;

  logic                                               array_enb;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] row_i;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] col_i;
  logic [0:TILE_DIM * TILE_DIM * 2 * `DATA_WIDTH - 1] out_r;

  // TODO: Implement necessary buffer 

  // array_enb
  localparam FSM_IDLE = 0, FSM_REQ = 1, FSM_HALT = 2, FSM_END = 3;
  logic [0:FSM_END] sa_curr_state, sa_next_state;
  logic sa_step, fifo_load, fifo_ready;

  always_ff @(posedge clk) begin
    if (~rstn) sa_curr_state <= 0;
    else sa_curr_state <= sa_next_state;
  end

  always_comb begin
    sa_next_state <= 0;
    case (1'b1)
      sa_curr_state[FSM_IDLE]: begin
        sa_next_state[FSM_REQ] = (curr_state[`S_LOAD]) ? 1'b1 : 1'b0;
      end
      sa_curr_state[FSM_REQ]: begin
        if (~curr_state[`S_LOAD]) sa_next_state[FSM_IDLE] = 1'b1;
        else if (fifo_load) sa_next_state[FSM_HALT] = 1'b1;
        else sa_next_state[FSM_REQ] = 1'b1;
      end
      sa_curr_state[FSM_HALT]: begin
        if (fifo_ready) sa_next_state[FSM_REQ] = 1'b1;
        else sa_next_state[FSM_HALT] = 1'b1;
      end
      sa_curr_state[FSM_END]: begin
        sa_next_state[FSM_END] = 1'b1;
      end
      default: ;
    endcase
  end

  // Row-direction fifo 
  logic [TILE_DIM-1:0] row_fifo_wen, row_fifo_ren;
  logic [0:`DATA_WIDTH-1] row_fifo_from_mem[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] row_fifo_to_array[0:TILE_DIM-1];
  logic [0:TILE_DIM-1] row_fifio_full, row_fifo_empty;

  SyncFifo #(
      .DEPTH(8),
      .WIDTH(`DATA_WIDTH)
  ) i_RowSyncFifo[0:TILE_DIM-1] (
      .clk(clk),
      .rstn(rstn),
      .w_en(row_fifo_wen),
      .r_en(row_fifo_ren),
      .data_in(row_fifo_from_mem),
      .data_out(row_fifo_to_array),
      .full(row_fifio_full),
      .empty(row_fifo_empty)
  );

  // Column-direction fifo 
  logic [TILE_DIM-1:0] col_fifo_wen, col_fifo_ren;
  logic [0:`DATA_WIDTH-1] col_fifo_from_mem[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] col_fifo_to_array[0:TILE_DIM-1];
  logic [0:TILE_DIM-1] col_fifio_full, col_fifo_empty;

  SyncFifo #(
      .DEPTH(8),
      .WIDTH(`DATA_WIDTH)
  ) i_ColumnSyncFiFo[0:TILE_DIM-1] (
      .clk(clk),
      .rstn(rstn),
      .w_en(col_fifo_wen),
      .r_en(col_fifo_ren),
      .data_in(col_fifo_from_mem),
      .data_out(col_fifo_to_array),
      .full(col_fifio_full),
      .empty(col_fifo_empty)
  );

  // Connection between fifo and systolic array 
  genvar i;
  generate
    for (i = 0; i < TILE_DIM; i++) begin : CONNECT_FIFO_TO_ARRAY
      assign row_i[i*`DATA_WIDTH+:`DATA_WIDTH] = row_fifo_to_array[i];
      assign col_i[i*`DATA_WIDTH+:`DATA_WIDTH] = col_fifo_to_array[i];
    end
  endgenerate

  SystolicArray #(
      .TILE_DIM(TILE_DIM)
  ) i_SystolicArray (
      .clk(clk),
      .rstn(rstn),
      .enb(sa_step),
      .in_row(row_i),
      .in_col(col_i),
      .out(out_r)
  );


endmodule
