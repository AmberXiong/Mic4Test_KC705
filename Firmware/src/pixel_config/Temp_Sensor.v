//% @file Temp_Sensor.v
//% @brief Mic4 temperature sensor control and test module.
//% @author pyxiong
//%
//% This module contains an inout port,
//% after it sends a 300ns pulse to chip, it will act as an input port,
//% and recieve the data from chip. 
`timescale 1ns / 1ps

module Temp_Sensor #(parameter TS_COUNT_WIDTH=32, //% Width of internal counter
                     parameter PLS_LOW=20,
                     parameter PLS_HIGH=30
  ) (
  input clk_100MHz, //% control clock
  input RESET, //% system reset
  input pulse_in, //% pulse for output
  inout ts_data, //% inout port connects to chip emperature sensor
  output reg [TS_COUNT_WIDTH-1:0] MEM_OUT //% data sent to memory, the length of pulse equals to Tclk*MEM_OUT
  );
reg [TS_COUNT_WIDTH-1:0] t_counter;
reg [4:0] cnt_20;
reg [4:0] cnt_30;
reg pulse_out;
reg en_out;
reg [TS_COUNT_WIDTH-1:0] pulse_length;
reg valid;

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
  if(RESET) begin MEM_OUT<= 32'b0; end
  else
   begin
    if(valid) begin MEM_OUT<=pulse_length; end
    else begin MEM_OUT<=MEM_OUT; end
   end
 end

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
      s0:
        begin
          if(pulse_in) begin n_state=s1; end
          else begin n_state=s0; end
        end
      s1:
        begin
          if(cnt_20==PLS_LOW) begin n_state=s2; end
          else begin n_state=s1; end
        end
      s2:
        begin
          if(cnt_30==PLS_HIGH) begin n_state=s3; end
          else begin n_state=s2; end
        end
      s3:
        begin
        if(ts_data) begin n_state=s4; end
        else begin n_state=s3; end
        end
      s4:
        begin
          if(!ts_data) begin n_state=s5; end
          else begin n_state=s4; end
        end
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
