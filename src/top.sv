`include "include/single_port_ram_intf.sv"
`include "sram_buffer/InOut_SRAM_384k.sv"  // Input SRAM or Output SRAM (384 KB)
`include "sram_buffer/Weight_SRAM_384k.sv"  // Weight SRAM (384 KB)
`include "sram_buffer/Bias_SRAM_384k.sv"  // Bias SRAM (384 KB)
`include "sram_buffer/Param_SRAM_16B.sv"  // Param SRAM (16B)
`include "tensor_accelerator.sv"

module top (
    input  logic       clk,
    input  logic       rstn,
    input  logic       start_i,
    input  logic [3:0] mode_i,
    output logic       finish_o
);

  // Interface
  SinglePortRamIntf param_intf ();
  SinglePortRamIntf input_intf ();
  SinglePortRamIntf bias_intf ();
  SinglePortRamIntf weight_intf ();
  SinglePortRamIntf output_intf ();

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

  Weight_SRAM_384k i_Weight_SRAM_384k (
      .clk(clk),
      .mem(weight_intf)
  );

  Bias_SRAM_384k i_Bias_SRAM_384k (
      .clk(clk),
      .mem(bias_intf)
  );

  TensorAccelerator i_TensorAccelerator (
      .rstn(rstn),
      .clk(clk),
      .start(start_i),
      .mode(mode_i),
      .finish(finish_o),

      .param_intf (param_intf),
      .weight_intf(weight_intf),
      .bias_intf  (bias_intf),
      .input_intf (input_intf),
      .output_intf(output_intf)
  );

endmodule
