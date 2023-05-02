// Check the # of bits for state registers !!!
// Check the # of bits for flag registers !!!

`ifndef __FLAG_DEF__
`define __FLAG_DEF__

// There're 6 states in this design
`define S_IDLE 0  
`define S_LOAD 1  
`define S_STREAM 2  
`define S_TAIL 3  
`define S_IMG2COL 4  
`define S_END 5  
`define S_ZVEC 6'b0
`define STATE_W 6  

// Macro from template
`define BUF_SIZE 8'd66
`define DATA_WIDTH 16 
`define ADDR_WIDTH 20 
`define EMPTY_ADDR {`ADDR_WIDTH{1'b0}}
`define EMPTY_DATA {`DATA_WIDTH{1'b0}}

// Self-defined macro
`define CNT_WIDTH 15 

// Memory control signal 
`define WRITE_ENB (1'b0)
`define WRITE_DIS (1'b1)
`define READ_ENB (1'b1)
`define READ_DIS (1'b0)

`endif
