//% @file Temp_Sensor_tb.v
//% @brief tenstbench file for Temp_Sensor.v module
//% @author pyxiong
`timescale 1ns / 1ps

module Temp_Sensor_tb #(parameter TS_COUNT_WIDTH=32)();
reg clk_100MHz;
reg RESET;
reg pulse_in;
reg en_in;
reg ts_out;
wire ts_data;
wire [TS_COUNT_WIDTH-1:0] pulse_length;
wire valid;

assign ts_data=(en_in==1)?ts_out:1'bz;

Temp_Sensor #(.TS_COUNT_WIDTH(TS_COUNT_WIDTH))
  DUT2 (
   .clk_100MHz(clk_100MHz),
   .RESET(RESET),
   .pulse_in(pulse_in),
   .ts_data(ts_data),
   .pulse_length(pulse_length),
   .valid(valid)
   );

initial begin
$dumpfile("temp_sensor.dump");
$dumpvars(0, Temp_Sensor);
end

initial begin
clk_100MHz=1;
forever #5 clk_100MHz=~clk_100MHz;
end

initial begin
RESET=1;
pulse_in=0;
#100 RESET=0;
#20 pulse_in=1;
#10 pulse_in=0;
end

initial begin
en_in=1;
ts_out=0;
#120 en_in=0;
#500
en_in=1;
#10  ts_out=1;
#160 ts_out=0;
end
endmodule
