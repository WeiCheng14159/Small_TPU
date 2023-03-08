`include "sp_ram_intf.sv"
`include "InOut_SRAM_384k.sv"  // Input SRAM or Output SRAM (384 KB)
`include "Weight_SRAM_180k.sv"  // Weight SRAM (180 KB)
`include "Param_SRAM_16B.sv"  // Param SRAM (16B)
`include "ConvAcc.sv"

module top (
    input  logic       clk,
    input  logic       rstn,
    input  logic       start_i,
    input  logic [3:0] mode_i,
    output logic       finish_o
);

  // Interface
  sp_ram_intf param_intf ();
  sp_ram_intf input_intf ();
  sp_ram_intf base_kernel_intf ();
  sp_ram_intf filter_kernel_intf ();
  sp_ram_intf output_intf ();

  Param_SRAM_16B i_param_mem (
      .clk(clk),
      .mem(param_intf)
  );

  InOut_SRAM_384k i_Input_SRAM_384k (
      .clk(clk),
      .mem(input_intf)
  );

  InOut_SRAM_384k i_Output_SRAM_384k (
      .clk(clk),
      .mem(output_intf)
  );

  Weight_SRAM_180k i_Base_kernel_SRAM_180k (
      .clk(clk),
      .mem(base_kernel_intf)
  );

  Weight_SRAM_180k i_Filter_kernel_SRAM_180k (
      .clk(clk),
      .mem(filter_kernel_intf)
  );

  ConvAcc i_ConvAcc (
      .rstn(rstn),
      .clk(clk),
      .start(start_i),
      .finish(finish_o),
      .mode(mode_i),
      .param_intf(param_intf),
      .base_kernel_intf(base_kernel_intf),
      .filter_kernel_intf(filter_kernel_intf),
      .input_intf(input_intf),
      .output_intf(output_intf)
  );

endmodule
