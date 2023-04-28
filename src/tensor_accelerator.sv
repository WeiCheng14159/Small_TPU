`include "include/single_port_ram_intf.sv"
`include "include/define.v"
`include "accelerator_controller.sv"
`include "systolic_array_controller.sv"

module TensorAccelerator (
    input  logic       clk,
    input  logic       rstn,
    input  logic       start,
    input  logic [3:0] mode,
    output logic       finish,

    SinglePortRamIntf.compute param_intf,
    SinglePortRamIntf.compute weight_intf,
    SinglePortRamIntf.compute bias_intf,
    SinglePortRamIntf.compute input_intf,
    SinglePortRamIntf.compute output_intf
);

  /* Write your code here */

  wire [`STATE_W-1:0] curr_state;

  AcceleratorController i_AcceleratorController (
      .clk(clk),
      .rstn(rstn),
      .curr_state(curr_state),
      .param_intf(param_intf)
  );

  SystolicArrayController i_SystolicArrayController (
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
