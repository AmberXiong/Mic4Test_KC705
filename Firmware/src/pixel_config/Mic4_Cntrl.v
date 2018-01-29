//% @file Mic4_Cntrl.v
//% @brief This module generates control signals for mic4 chip
//% @author pyxiong
//%
//% This module generates A_plse, D_plse, and other signals used for mic4 chip test.
`timescale 1ns / 1ps

module Mic4_Cntrl#(parameter DIV_WIDTH=6,  //% @param width of division factor.
                   parameter COUNT_WIDTH=64, //% @param Width of clock division counter, it must be greater than 2**DIV_WIDTH.
                   parameter APULSE_LENGTH = 100, //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
                   parameter DPULSE_LENGTH = 300, //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
                   parameter GRST_LENGTH = 5 //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
  ) (
input clk_in, //%250MHz
input clk_control, //%100MHz
input rst,
input [DIV_WIDTH-1:0] div0,
input [DIV_WIDTH-1:0] div1,
input pulse_grst,
input pulse_a,
input pulse_d,
output clk_out, //% CLK_IN of mic4
output lt_out, //%LT_IN of mic4
output a_pulse_out,
output d_pulse_out,
output grst_n_out
    );

wire [COUNT_WIDTH-1:0] counter0, counter1;
wire grst_temp;

Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH))
        clock_div_1(
            .clk_in(clk_in),
            .rst(rst),
            .div(div0),
            .counter(counter0),
            .clk_out(clk_out)
            );

Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH))
        clock_div_2(
            .clk_in(clk_in),
            .rst(rst),
            .div(div1),
            .counter(counter1),
            .clk_out(lt_out)
            );

Pulse_Strecher #(.PULSE_LENGTH(APULSE_LENGTH))
  ps_inst0(
   .clk_in(clk_control),
   .rst(rst),
   .pulse_in(pulse_a),
   .pulse_out(a_pulse_out)
    );

Pulse_Strecher #(.PULSE_LENGTH(DPULSE_LENGTH))
  ps_inst1(
   .clk_in(clk_control),
   .rst(rst),
   .pulse_in(pulse_d),
   .pulse_out(d_pulse_out)
    );

assign grst_n_out=~grst_temp;
Pulse_Strecher #(.PULSE_LENGTH(GRST_LENGTH))
  ps_inst(
   .clk_in(clk_control),
   .rst(rst),
   .pulse_in(pulse_grst),
   .pulse_out(grst_temp)
    );
endmodule
