//% @file Pixel_Config.v
//% @brief top module for MIC4 chip pixel config.
//% @author pyxiong
//%
//% This module collects data from memory port of control_interface,
//% then send data to MIC4 chip one by one.
 
`timescale 1ns / 1ps

module Pixel_Config #(parameter DIV_WIDTH=6,  //% @param width of division factor
                      parameter COUNT_WIDTH=64, //% @param Width of internal counter of Clock_Div module, it must be greater than 2**DIV_WIDTH.
                      parameter DATA_WIDTH=15, //% @param Width of data for each pixel configuration
                      parameter SHIFT_DIRECTION=1, //% @param 1: MSB out first, 0: LSB out first
                      parameter CNT_WIDTH=4 //% @param width of internal counter of statemachine
  ) (
  input SYS_CLK, //% system clock
  input RESET, //% system reset
  input [DIV_WIDTH-1:0] DIV, //% division factor 2**div
  input [31:0] SRAM_DATA,
  input SRAM_WE,
  input pulse_start,
  input BUSY,
  output S_CLK,
  output S_DATA
  );
wire [DATA_WIDTH:0] FIFO_DATA;
wire RD_FIFO;
wire RD_CLK;
wire EMPTY;
wire START;

Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH))
  clock_div_inst(
    .clk_in(SYS_CLK),
    .rst(RESET),
    .div(DIV),
    .clk_out(RD_CLK)
    );
    
fifo_32to16 fifo32to16_inst (
    .rst(RESET),
    .wr_clk(SYS_CLK),
    .rd_clk(RD_CLK),
    .din(SRAM_DATA),
    .wr_en(SRAM_WE),
    .rd_en(RD_FIFO),
    .dout(FIFO_DATA),
    .empty(EMPTY)
    );

pulse_synchronise pulse_sync_inst(
    .pulse_in(pulse_start),
    .clk_in(SYS_CLK),
    .clk_out(RD_CLK),
    .rst(RESET),
    .pulse_out(START)
    );
          
Pixel_Config_statemachine #(.DATA_WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .CNT_WIDTH(CNT_WIDTH))
     pixel_config_st_inst(
     .CLK_IN(RD_CLK),
     .RESET(RESET),
     .START(START),
     .DATA_IN(FIFO_DATA[DATA_WIDTH-1:0]),
     .BUSY(BUSY),
     .EMPTY(EMPTY),
     .S_CLK(S_CLK),
     .S_DATA(S_DATA),
     .RD_FIFO(RD_FIFO)
     );    
endmodule
