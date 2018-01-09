//% @file Temp_Sensor.v
//% @brief Mic4 temperature sensor control and test module.
//% @author pyxiong
//%
//% This module contains an inout port,
//% after it sends a 300ns pulse to chip, it will act as an input port,
//% and recieve the data from chip. 
`timescale 1ns / 1ps

module Temp_Sensor #(parameter TS_COUNT_WIDTH=32 //% Width of internal counter
  ) (
  input clk_100MHz, //% control clock
  input RESET, //% system reset
  input pulse_in, //% pulse for output
  inout ts_data, //% inout port connects to chip emperature sensor
  output reg [TS_COUNT_WIDTH-1:0] pulse_length, //% the length of pulse equals to Tclk*pulse_length
  output reg valid //% a flag signal indicates the counter is stopped
  );
reg [TS_COUNT_WIDTH-1:0] t_counter;
reg [4:0] cnt_20;
reg [4:0] cnt_30;
reg pulse_out;
reg en_out;

reg [5:0] c_state, n_state;
parameter s0=6'b000001;
parameter s1=6'b000010;
parameter s2=6'b000100;
parameter s3=6'b001000;
parameter s4=6'b010000;
parameter s5=6'b100000;

assign ts_data=(en_out==1)?pulse_out:1'bz;

always@(posedge clk_100MHz or posedge RESET)
 begin
  if(RESET) begin c_state<=s0; end
  else begin c_state<=n_state; end
 end
 
always@(c_state or RESET or pulse_in or ts_data or t_counter or cnt_20 or cnt_30)
 begin
  if(RESET) begin n_state=s0; end
  else
   begin
    case(c_state)
      s0: begin n_state=(pulse_in==1)?s1:s0; end
      s1: begin n_state=(cnt_20==5'b10100)?s2:s1; end
      s2: begin n_state=(cnt_30==5'b11110)?s3:s2; end
      s3: begin n_state=(ts_data==1)?s4:s3; end
      s4: begin n_state=(ts_data==0)?s5:s4; end
      s5: begin n_state=s0; end
      default: begin n_state=s0; end
    endcase
   end
 end

always@(posedge clk_100MHz or posedge RESET)
 begin
  if(RESET)
   begin
    en_out<=0;
    pulse_out<=0;
    cnt_20<=5'b0;
    cnt_30<=5'b0;
    t_counter<=32'b0;
    pulse_length<=32'b0;
    valid<=0;
   end
  else
   begin
    case(n_state)
      s0:
       begin
        en_out<=0;
        pulse_out<=0;
        cnt_20<=5'b0;
        cnt_30<=5'b0;
        t_counter<=32'b0;
        pulse_length<=32'b0;
        valid<=0;
       end
      s1:
       begin
        en_out<=1;
        pulse_out<=0;
        cnt_20<=cnt_20+5'b1;
        cnt_30<=5'b0;
        t_counter<=32'b0;
        pulse_length<=32'b0;
        valid<=0;
       end
      s2:
       begin
        en_out<=1;
        pulse_out<=1;
        cnt_20<=5'b0;
        cnt_30<=cnt_30+5'b1;
        t_counter<=32'b0;
        pulse_length<=32'b0;
        valid<=0;
       end
      s3:
       begin
        en_out<=0;
        pulse_out<=0;
        cnt_20<=5'b0;
        cnt_30<=5'b0;
        t_counter<=32'b0;
        pulse_length<=32'b0;
        valid<=0;
       end
      s4:
       begin
        en_out<=0;
        pulse_out<=0;
        cnt_20<=5'b0;
        cnt_30<=5'b0;
        t_counter<=t_counter+32'b1;
        pulse_length<=32'b0;
        valid<=0;
       end
      s5:
       begin
        en_out<=0;
        pulse_out<=0;
        cnt_20<=5'b0;
        cnt_30<=5'b0;
        t_counter<=t_counter;
        pulse_length<=t_counter;
        valid<=1;
       end
      default:
       begin
        en_out<=0;
        pulse_out<=0;
        cnt_20<=5'b0;
        cnt_30<=5'b0;
        t_counter<=32'b0;
        pulse_length<=32'b0;
        valid<=0;
       end
    endcase
   end
 end
endmodule
