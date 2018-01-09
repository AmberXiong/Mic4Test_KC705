//% @file Pixel_Config_tb.v
//% @brief testbench file for Pixel_Config module
//% @author pyxiong
`timescale 1ns / 1ps

module Pixel_Config_tb#(parameter DIV_WIDTH=6,  //% @param width of division factor
                        parameter COUNT_WIDTH=64, //% @param Width of internal counter of Clock_Div module, it must be greater than 2**DIV_WIDTH.
                        parameter DATA_WIDTH=15, //% @param Width of data for each pixel configuration
                        parameter SHIFT_DIRECTION=1, //% @param 1: MSB out first, 0: LSB out first
                        parameter CNT_WIDTH=4 //% @param width of internal counter of statemachine
                        )();
reg SYS_CLK;
reg RESET;
reg [DIV_WIDTH-1:0] DIV;
reg [31:0] SRAM_DATA;
reg SRAM_WE;
reg pulse_start;
reg BUSY;
wire S_CLK;
wire S_DATA;

Pixle_Config #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .DATA_WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .CNT_WIDTH(CNT_WIDTH))
  DUT1(
      .SYS_CLK(SYS_CLK),
      .RESET(RESET),
      .DIV(DIV),
      .SRAM_DATA(SRAM_DATA),
      .SRAM_WE(SRAM_WE),
      .pulse_start(pulse_start),
      .BUSY(BUSY),
      .S_CLK(S_CLK),
      .S_DATA(S_DATA)
      );

initial begin
$dumpfile("pixel_config.dump");
$dumpvars(0, Pixle_Config);
end

initial begin
SYS_CLK=1;
forever #5 SYS_CLK=~SYS_CLK;
end

initial begin
RESET=1;
DIV=6'b000010;
pulse_start=0;
#100 RESET=0;
#505 pulse_start=1;
#10 pulse_start=0;
end
      
initial begin
BUSY=0;
#1500 BUSY=1;
#2500 BUSY=0;
end

initial begin
SRAM_WE=0;
SRAM_DATA=32'b0;
#205 
SRAM_WE=1;
SRAM_DATA=32'b1100_0000_0000__0010_1110_0000_0000_0001;
repeat(20) #10 SRAM_DATA=SRAM_DATA+32'b0000_0000_0000__0001_0000_0000_0000_0001;
#10 SRAM_WE=0;
end 
        
endmodule
