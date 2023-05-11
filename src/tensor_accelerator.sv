`include "include/single_port_ram_intf.sv"
`include "include/pkg_include.sv"
`include "accelerator_controller.sv"
`include "systolic_array_controller.sv"

module tensor_accelerator
  import accelerator_pkg::*;
(
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

  accelerator_state_t curr_state;
  logic sa_done;
  logic [31:0] M, N, K;

  accelerator_controller i_accelerator_controller (.*);

  systolic_array_controller i_systolic_array_controller (.*);

endmodule
