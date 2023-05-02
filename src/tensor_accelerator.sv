`include "include/single_port_ram_intf.sv"
`include "include/define.v"
`include "accelerator_controller.sv"
`include "systolic_array_controller.sv"

module tensor_accelerator (
    input  logic       clk,
    input  logic       rstn,
    input  logic       start,
    input  logic [3:0] mode,
    output logic       finish,

    single_port_ram_intf.compute param_intf,
    single_port_ram_intf.compute weight_intf,
    single_port_ram_intf.compute bias_intf,
    single_port_ram_intf.compute input_intf,
    single_port_ram_intf.compute output_intf
);

  /* Write your code here */

  wire [`STATE_W-1:0] curr_state;

  accelerator_controller i_accelerator_controller (
      .clk(clk),
      .rstn(rstn),
      .curr_state(curr_state),
      .param_intf(param_intf)
  );

  systolic_array_controller i_systolic_array_controller (
      .clk(clk),
      .rstn(rstn),
      .finish(finish),
      .curr_state(curr_state),
      .param_intf(param_intf),
      .weight_intf(weight_intf),
      .bias_intf(bias_intf),
      .input_intf(input_intf),
      .output_intf(output_intf)
  );

endmodule
