// This is generated automatically on 2021/10/05-14:08:00
// Check the # of bits for state registers !!!
// Check the # of bits for flag registers !!!

`ifndef __FLAG_DEFINE__
`define __FLAG_DEFINE__

// There're 6 states in this design
`define S_INIT                 	 0  
`define S_READ_I              1
`define S_GEN_BASE              2
`define S_READ_K                  3
`define S_ADD                   4
`define S_COMPOSE               5
`define S_OUT                   6
`define S_WAIT                   7
`define S_END                  	8
`define S_ZVEC                 	 9'b0  

`define STATE_W                  9         

// done state
`define DONE_INIT                  0
`define DONE_READ_I               1
`define DONE_GEN_BASE            2
`define DONE_READ_K                3
`define DONE_ADD               4
`define DONE_COMPOSE              5
`define DONE_OUT           6
`define DONE_WAIT           7
`define DONE_FINISH              8
`define DONE_ZVEC                9'b0

`define STATE_DONE_W             9

// Macro from template
`define BUF_SIZE               	 8'd66
`define READ_MEM_DELAY         	 2'd2
`define LOCAL_IDX_W            	 16 

`define DATA_W                 	 10
`define ADDR_W                   18

// Self-defined macro
`define CNT_W                  	 10
`define INCNT_W                  10

`endif
