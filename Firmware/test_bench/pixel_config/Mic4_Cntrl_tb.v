//% @flie Mic4_Cntrl_tb.v
//% @brief testbench file
//% @author pyxiong
`timescale 1ns / 1ps

module Mic4_Cntrl_tb#(parameter DIV_WIDTH=6,  //% @param width of division factor.
                      parameter COUNT_WIDTH=64, //% @param Width of clock division counter, it must be greater than 2**DIV_WIDTH.
                      parameter APULSE_LENGTH = 100, //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
                      parameter DPULSE_LENGTH = 300, //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
                      parameter GRST_LENGTH = 5 //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
                      )();
reg clk_in, clk_control, rst, pulse_grst, pulse_a, pulse_d;
reg [DIV_WIDTH-1:0] div0, div1;
wire clk_out, lt_out, a_pulse_out, d_pulse_out, grst_n_out;

Mic4_Cntrl #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .APULSE_LENGTH(APULSE_LENGTH), .DPULSE_LENGTH(DPULSE_LENGTH), .GRST_LENGTH(GRST_LENGTH))
 dut_mc0 (
   .clk_in(clk_in), //%250MHz
   .clk_control(clk_control), //%100MHz
   .rst(rst),
   .div0(div0),
   .div1(div1),
   .pulse_grst(pulse_grst),
   .pulse_a(pulse_a),
   .pulse_d(pulse_d),
   .clk_out(clk_out), //% CLK_IN of mic4
   .lt_out(lt_out), //%LT_IN of mic4
   .a_pulse_out(a_pulse_out),
   .d_pulse_out(d_pulse_out),
   .grst_n_out(grst_n_out)
    );


initial begin
clk_in=1;
forever #2 clk_in=~clk_in;
end

initial begin
clk_control=1;
forever #5 clk_control=~clk_control;
end

initial begin
rst=0;
#1000 rst=1;
#100 rst=0;
end

initial begin
div0=6'b0;
div1=6'b0;
#100
div0=6'b000010;
div1=6'b000100;
end

initial begin
pulse_a=0;
#55 pulse_a=1;
#10 pulse_a=0;
#1050 pulse_a=1;
#10 pulse_a=0;
end

initial begin
pulse_d=0;
#50 pulse_d=1;
#10 pulse_d=0;
#1050 pulse_d=1;
#10 pulse_d=0;
end

initial begin
pulse_grst=0;
#50 pulse_grst=1;
#10 pulse_grst=0;
#1050 pulse_grst=1;
#10 pulse_grst=0;
end
endmodule
