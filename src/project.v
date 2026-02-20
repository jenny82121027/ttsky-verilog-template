/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Internal signals for RangeFinder
  wire [7:0] range_out;
  wire       error_out;

  // Instantiate RangeFinder module (WIDTH=8)
  RangeFinder #(.WIDTH(8)) range_finder_inst (
    .data_in (ui_in),           // 8-bit data input from dedicated inputs
    .clock   (clk),             // clock
    .reset   (~rst_n),          // reset (active high, so invert rst_n)
    .go      (uio_in[0]),       // go signal from bidirectional pin 0
    .finish  (uio_in[1]),       // finish signal from bidirectional pin 1
    .range   (range_out),       // 8-bit range output
    .error   (error_out)        // error output
  );

  // Assign outputs
  assign uo_out  = range_out;           // range goes to dedicated outputs
  assign uio_out = {5'b0, error_out, 2'b0};   // error on uio_out[2], rest are 0
  assign uio_oe  = 8'b00000100;         // uio[2] is output (error), uio[0:1] are inputs (go, finish)

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:3], 1'b0};

endmodule
