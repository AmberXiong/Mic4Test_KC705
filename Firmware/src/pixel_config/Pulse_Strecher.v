//% @file Pulse_Strecher.v
//% @brief This module generates a long pulse.
//% @author pyxiong
`timescale 1ns / 1ps

module Pulse_Strecher#(parameter PULSE_LENGTH = 300 //% output pulse have a length of PULSE_LENGTH*CLOCK_PERIOD
  ) (
input clk_in,
input rst,
input pulse_in,
output reg pulse_out
    );
reg [31:0] counter;

reg [1:0] c_state, n_state;
parameter s0=2'b01;
parameter s1=2'b10;

always@(posedge clk_in or posedge rst)
 begin
  if(rst) begin c_state<=s0; end
  else begin c_state<=n_state; end
 end

always@(c_state or pulse_in or rst or counter)
 begin
 if(rst) begin n_state=s0; end
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
        if(counter==PULSE_LENGTH) begin n_state=s0; end
        else begin n_state=s1; end
      end
    default: begin n_state=s0; end
   endcase
  end
 end

always@(posedge clk_in or posedge rst)
 begin
  if(rst)
   begin
   counter<=32'b0;
   pulse_out<=0;
   end
  else
   begin
    case(n_state)
     s0:
        begin
        counter<=32'b0;
        pulse_out<=1'b0;
        end
     s1:
        begin
        counter<=counter+1'b1;
        pulse_out<=1'b1;
        end
     default:
        begin
        counter<=32'b0;
        pulse_out<=1'b0;
        end
    endcase
   end
 end
endmodule
