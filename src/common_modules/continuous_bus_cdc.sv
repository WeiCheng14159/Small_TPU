`ifndef _continuous_bus_cdc_
`define _continuous_bus_cdc_

/**
 * Module:
 *  continuous_bus_cdc
 *
 * Description:
 *  Continuous transfer of bus data using a variation of the 1-deep, 2-register
 *  fifo. Operates in both slow2fast or fast2slow directions but has no
 *  guaranties that all data will be passed. Can guaranty that the data that is
 *  passed over is correct and in order.
 *
 *  http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 55)
 *  http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf (p. 49)
 *
 * Authors:
 *  Berin Martini (berin.martini@gmail.com)
 */

module continuous_bus_cdc #(
    parameter BUS_WIDTH = 32
) (
    input wire                 up_clk,
    input wire                 up_rst,
    input wire [BUS_WIDTH-1:0] up_bus,

    input  wire                  dn_clk,
    input  wire                  dn_rst,
    output logic [BUS_WIDTH-1:0] dn_bus
);

  logic [BUS_WIDTH-1:0] a_mem      [0:1];
  logic [          1:0] a_u2d;
  logic [          1:0] a_d2u;

  logic [BUS_WIDTH-1:0] dn_bus_r;
  logic                 dn_ptr;
  logic                 dn_u2d_ptr;
  logic                 dn_en;

  logic [BUS_WIDTH-1:0] up_bus_r;
  logic                 up_ptr;
  logic                 up_d2u_ptr;
  logic                 up_en;


  // sync signal from up clk to down clk
  always_ff @(posedge dn_clk)
    if (dn_rst) {dn_u2d_ptr, a_u2d} <= 'b0;
    else {dn_u2d_ptr, a_u2d} <= {a_u2d, up_ptr};


  // sync signal from down clk to up clk
  always_ff @(posedge up_clk)
    if (up_rst) {up_d2u_ptr, a_d2u} <= 'b0;
    else {up_d2u_ptr, a_d2u} <= {a_d2u, dn_ptr};



  // When the up and down pointers are the same value we know that down
  // stream is ready to receive a new bus value from the up clock domain.
  // This will trigger an enable pulse which not only writes the new value
  // into the 'memory' but also toggles the up pointer to its new value.
  assign up_en = ~(up_d2u_ptr ^ up_ptr);

  always_ff @(posedge up_clk)
    if (up_rst) up_ptr <= 1'b0;
    else up_ptr <= up_ptr ^ up_en;


  always_ff @(posedge up_clk) if (up_en) a_mem[up_ptr] <= up_bus_r;


  // Register bus on up_clk
  always_ff @(posedge up_clk)
    if (up_rst) up_bus_r <= 'b0;
    else up_bus_r <= up_bus;


  // When the down and up pointers are different values we know that there is
  // a new bus value from the up clock domain ready to be passed to the down
  // clock domain. This will trigger an enable pulse which not only reads the
  // new value from the 'memory' but also toggles the down pointer to its new
  // value.
  assign dn_en = (dn_u2d_ptr ^ dn_ptr);

  always_ff @(posedge dn_clk)
    if (dn_rst) dn_ptr <= 1'b0;
    else dn_ptr <= dn_ptr ^ dn_en;


  always_ff @(posedge dn_clk)
    if (dn_rst) dn_bus_r <= 'b0;
    else if (dn_en) dn_bus_r <= a_mem[dn_ptr];


  // Register bus on the dn_clk
  always_ff @(posedge dn_clk)
    if (dn_rst) dn_bus <= 'b0;
    else dn_bus <= dn_bus_r;


endmodule

`default_nettype wire

`endif  // _continuous_bus_cdc_
