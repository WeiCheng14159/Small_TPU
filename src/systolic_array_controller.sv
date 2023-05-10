`include "include/define.v"
`include "systolic_array/systolic_array.sv"
`include "sync_fifo.sv"
`include "fifo_consumer.sv"


module systolic_array_controller (
    input  logic                               clk,
    input  logic                               rstn,
    output logic                               finish,
    input  logic                [`STATE_W-1:0] curr_state,
           single_port_ram_intf                param_intf,
           single_port_ram_intf                weight_intf,
           single_port_ram_intf                bias_intf,
           single_port_ram_intf                input_intf,
           single_port_ram_intf                output_intf
);
  localparam TILE_DIM = 64;

  logic                                               array_enb;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] row_i;
  logic [               0:TILE_DIM * `DATA_WIDTH - 1] col_i;
  logic [0:TILE_DIM * TILE_DIM * 2 * `DATA_WIDTH - 1] out_r;

  // TODO: Implement necessary buffer 

  // array_enb
  localparam IDLE = 0, REQ = 1, HALT = 2, FIN = 3;
  typedef enum logic [FIN:0] {
    S_IDLE = 1 << IDLE,
    S_REQ  = 1 << REQ,
    S_HALT = 1 << HALT,
    S_FIN  = 1 << FIN
  } state_t;

  state_t sa_curr_state, sa_next_state;
  logic sa_step, fifo_load, fifo_ready;

  always_ff @(posedge clk) begin
    if (~rstn) sa_curr_state <= S_IDLE;
    else sa_curr_state <= sa_next_state;
  end

  always_comb begin
    unique case (1'b1)
      sa_curr_state[IDLE]: sa_next_state = S_REQ;
      sa_curr_state[REQ]:  sa_next_state = S_REQ;
      sa_curr_state[HALT]: sa_next_state = S_FIN;
      sa_curr_state[FIN]:  sa_next_state = S_FIN;
    endcase
  end

  // Connection between fifo and systolic array 

  // Row-direction fifo 
  logic [TILE_DIM-1:0] row_fifo_wen, row_fifo_ren;
  logic [0:`DATA_WIDTH-1] row_fifo_from_supplier[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] row_fifo_from_mem[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] row_fifo_to_consumer[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] row_fifo_to_array[0:TILE_DIM-1];
  logic [0:TILE_DIM-1] row_fifio_full, row_fifo_empty;

  sync_fifo #(
      .DEPTH(8),
      .WIDTH(`DATA_WIDTH)
  ) row_sync_fifo[0:TILE_DIM-1] (
      .clk(clk),
      .rstn(rstn),
      .w_en(row_fifo_wen),
      .r_en(row_fifo_ren),
      .data_in(row_fifo_from_mem),
      .data_out(row_fifo_to_consumer),
      .full(row_fifio_full),
      .empty(row_fifo_empty)
  );

  // Row-direction fifo consumer
  genvar row_cons_i;
  generate
    for (row_cons_i = 0; row_cons_i < TILE_DIM; row_cons_i++) begin : ROW_FIFO_CONSUMER
      fifo_consumer #(
          .WIDTH(`DATA_WIDTH)
      ) row_fifo_consumer (
          .clk(clk),
          .rstn(rstn),
          .empty(row_fifo_empty[row_cons_i]),
          .from_fifo(row_fifo_to_consumer[row_cons_i]),
          // .base_addr(0),
          // .addr_step(4),
          // .end_addr(400),
          .r_en(row_fifo_ren[row_cons_i]),
          .to_array(row_fifo_to_array[row_cons_i])
      );
    end
  endgenerate

  // Column-direction fifo 
  logic [TILE_DIM-1:0] col_fifo_wen, col_fifo_ren;
  logic [0:`DATA_WIDTH-1] col_fifo_from_mem[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] col_fifo_from_supplier[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] col_fifo_to_array[0:TILE_DIM-1];
  logic [0:`DATA_WIDTH-1] col_fifo_to_consumer[0:TILE_DIM-1];
  logic [0:TILE_DIM-1] col_fifio_full, col_fifo_empty;

  sync_fifo #(
      .DEPTH(8),
      .WIDTH(`DATA_WIDTH)
  ) col_sync_fifo[0:TILE_DIM-1] (
      .clk(clk),
      .rstn(rstn),
      .w_en(col_fifo_wen),
      .r_en(col_fifo_ren),
      .data_in(col_fifo_from_mem),
      .data_out(col_fifo_to_array),
      .full(col_fifio_full),
      .empty(col_fifo_empty)
  );

  // Column-direction fifo consumer
  genvar col_cons_i;
  generate
    for (col_cons_i = 0; col_cons_i < TILE_DIM; col_cons_i++) begin : COL_FIFO_CONSUMER
      fifo_consumer #(
          .WIDTH(`DATA_WIDTH)
      ) col_fifo_consumer (
          .clk(clk),
          .rstn(rstn),
          .empty(col_fifo_empty[col_cons_i]),
          .from_fifo(col_fifo_to_consumer[col_cons_i]),
          // .base_addr(0),
          // .addr_step(4),
          // .end_addr(400),
          .r_en(col_fifo_ren[col_cons_i]),
          .to_array(col_fifo_to_array[col_cons_i])
      );
    end
  endgenerate

  // Connection between fifo and systolic array 
  genvar i;
  generate
    for (i = 0; i < TILE_DIM; i++) begin : CONNECT_FIFO_TO_ARRAY
      assign row_i[i*`DATA_WIDTH+:`DATA_WIDTH] = row_fifo_to_array[i];
      assign col_i[i*`DATA_WIDTH+:`DATA_WIDTH] = col_fifo_to_array[i];
    end
  endgenerate

  systolic_array #(
      .TILE_DIM(TILE_DIM)
  ) i_systolic_array (
      .clk(clk),
      .rstn(rstn),
      .enb(sa_step),
      .in_row(row_i),
      .in_col(col_i),
      .out(out_r)
  );


endmodule