//% @file Pixel_Config_statemachine.v
//% @brief MIC4 pixel config module.
//% @author pyxiong
//%
//% This module generates signals for MIC4 pixel config.
//% This module is controlled by clock CLK_IN,
//% it sends parallized data(DATA_IN) to MIC4 chip.
//% When FIFO is not empty, and MIC4 chip is not BUSY,
//% S_CLK will start running, data stored in FIFO will be sent to MIC4 one by one.

`timescale 1ns / 1ps


module Pixel_Config_statemachine #(parameter DATA_WIDTH=15, //% @param Width of data for each pixel configuration
                                   parameter SHIFT_DIRECTION=1, //% @param 1: MSB out first, 0: LSB out first
                                   parameter CNT_WIDTH=4 //% @param width of internal counter
  ) (
  input CLK_IN, //% input clock
  input RESET, //% system reset
  input START, //% start signal from control_interface pulse_reg
  input [DATA_WIDTH-1:0] DATA_IN, //% data from FIFO
  input BUSY, //% MIC4 chip's busy signal
  input EMPTY, //% FIFO's empty flag
  output S_CLK, //% clock signal send to MIC4 chip
  output reg S_DATA, //% serial data send to MIC4 chip
  output reg RD_FIFO //% read request send to FIFO
    );
    
reg [5:0] c_state, n_state;
reg [CNT_WIDTH-1:0] count;
reg [DATA_WIDTH-1:0] data_reg;
reg clk_trig;
parameter s0=6'b000001;
parameter s1=6'b000010;
parameter s2=6'b000100;
parameter s3=6'b001000;
parameter s4=6'b010000;
parameter s5=6'b100000;

always@(posedge CLK_IN or posedge RESET)
 begin
  if(RESET) begin c_state<=s0; end
  else begin c_state<=n_state; end
 end
 
always@(c_state or RESET or START or BUSY or count or EMPTY)
 begin
  if(RESET) begin n_state=s0; end
  else
   begin
    case(c_state)
     s0:
       begin
         if(START) begin n_state=s1; end
         else begin n_state=s0; end
       end
     s1:
       begin
         if(EMPTY) begin n_state=s0; end
         else if(!BUSY) begin n_state=s2; end
         else begin n_state=s1; end
       end
     s2: begin n_state=s3; end
     s3: begin n_state=s4; end
     s4: begin n_state=s5; end
     s5:
       begin
         if(count==DATA_WIDTH) begin n_state=s1; end
         else begin n_state=s5; end
       end
     default: begin n_state=s0; end
    endcase
   end
 end

always@(posedge CLK_IN or posedge RESET)
 begin
  if(RESET)
   begin
   clk_trig<=0;
   S_DATA<=0;
   RD_FIFO<=0;
   count<=4'b0000;
   data_reg<=15'b0;
   end
  else
   begin
    case(n_state)
     s0:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=0;
        count<=4'b0000;
        data_reg<=15'b0;
        end
     s1:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=0;
        count<=4'b0000;
        data_reg<=15'b0;
        end
     s2:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=1;
        count<=4'b0000;
        data_reg<=15'b0;
        end
     s3:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=0;
        count<=4'b0000;
        data_reg<=15'b0;
        end
     s4:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=0;
        count<=4'b0000;
        data_reg<=DATA_IN;
        end              
     s5:
        begin
        clk_trig<=1;
        RD_FIFO<=0;
        count<=count+1'b1;
        if(SHIFT_DIRECTION)
         begin
         S_DATA<=data_reg[DATA_WIDTH-1];
         data_reg<={data_reg[DATA_WIDTH-2:0],1'b0};
         end
        else
         begin
         S_DATA<=data_reg[0];
         data_reg<={1'b0,data_reg[DATA_WIDTH-1:1]};         
         end
        end
     default:
        begin
        clk_trig<=0;
        S_DATA<=0;
        RD_FIFO<=0;
        count<=4'b0000;
        end
    endcase
   end
 end

assign S_CLK=(clk_trig==1)?(~CLK_IN):1'b1;

endmodule
