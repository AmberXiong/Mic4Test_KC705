//% @flie pulse_strecher_tb.v
//% @brief testbench file
//% @author pyxiong
`timescale 1ns / 1ps

module Pulse_Strecher_tb#(parameter PULSE_LENGTH = 3)();
reg clk_in;
reg rst;
reg pulse_in;
wire pulse_out;

Pulse_Strecher #(.PULSE_LENGTH(PULSE_LENGTH))
  dut_ps(
   .clk_in(clk_in),
   .rst(rst),
   .pulse_in(pulse_in),
   .pulse_out(pulse_out)
    );

initial begin
clk_in=1;
forever #5 clk_in=~clk_in;
end

initial begin
rst=0;
#1000 rst=1;
#100 rst=0;
end

initial begin
pulse_in=0;
#50 pulse_in=1;
#10 pulse_in=0;
#1050 pulse_in=1;
#10 pulse_in=0;
end

endmodule
