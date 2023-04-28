`include "include/define.v"

module SystolicArrayController (
    input                                   clk,
    input                                   rstn,
    output logic                            finish,
    input                    [`STATE_W-1:0] curr_state,
           SinglePortRamIntf                param_intf,
           SinglePortRamIntf                weight_intf,
           SinglePortRamIntf                bias_intf,
           SinglePortRamIntf                input_intf,
           SinglePortRamIntf                output_intf
);

  // Write your code here 

endmodule
