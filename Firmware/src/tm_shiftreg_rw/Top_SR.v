//% @file Top_SR.v
//% @brief TMIIa shift register control module.
//% @author pyxiong
//% 
//% This module generates shift register control signals,
//% and receives the output data of TMIIa shift register .
//% This module is controlled by a high frequency clock clk_in,
//% it sends parallized data(din) to shift register chip,
//% and receives data(data_in_p,data_in_n) from shift register chip,
//% then output parallized data(dout) from shift register.  
//% Clock_Div.v: generates a divided clock which acts as the control
//% clock of some submodules(SR_Control.v, Receive_Data.v), the divided clock
//% frequency is clk_in/2**div.
//% SR_Control.v: generates signals sent to shift
//% register. When start is asserted, data(data_out_p,data_out_n) will sent to
//% shift register one by one, after finishing sending data, the load_sr is
//% asserted.
//% Clock_SR.v: generates shift register's control
//% clock(clk_sr), clk_sr starts running after start signal is asserted, 
//% and after the last bit is written into shift register, clk_sr
//% must stop until next assertion of start signal.
//% Receive_Data.v: When start is asserted, the data(data_in_p,data_in_n) 
//% stored in shift register will be sent to this module, when 170-bit
//% data are received, a 170-bit width data(dout) will come to the output
//% port of this module.
//% 
`timescale 1ns / 1ps

module Top_SR #(parameter WIDTH=170, //% @param Width of data input and output
                parameter CNT_WIDTH=8, //% @param WIDTH must be no greater than 2**CNT_WIDTH 
                parameter DIV_WIDTH=6,  //% @param width of division factor.
                parameter COUNT_WIDTH=64, //% @param Width of clock division counter, it must be greater than 2**DIV_WIDTH.
                parameter VALID_WIDTH=32, //% Width of data_out's valid bits.
                parameter NUM_WIDTH=4, //% 2**NUM_WIDTH must be greater than DATA_WIDTH/VALID_WIDTH.
                parameter FIFO_WIDTH=36, //% Width of fifo that data_out sent to
                parameter SHIFT_DIRECTION=1, //% @param 1: MSB out first, 0: LSB out first  
                parameter READ_TRIG_SRC=0, //% @param 0:start act as trig, 1: load_sr act as trig   
                parameter READ_DELAY=1 //% @param state machine delay period             
   ) (
    input clk_in, //% clock input is synchronised with input signals' control clock.
    input rst, //% module reset 
    input start, //% start signal, it should be asserted after the last assertion of wr_en. 
    input wr_en, //% enable signal for writing 16-bit din to data_to_send. 
    input [15:0] din, //% 16-bit data input, to be sent to shift register.
    input data_in, //% data from shift register
    input [DIV_WIDTH-1:0] div, //% clock frequency division factor 2**div
    input fifo_rd_en, //% control_interface FIFO full signal.
    output clk, //% sub modules' control clock
    output clk_sr, //% control clock send to shift register
    output data_out, //% data send to shift register
    output load_sr, //% load signal send to shift register
    output fifo_empty, //% FIFO empty signal sent to control_interface.
    output [FIFO_WIDTH-1:0] fifo_q //% data send to internal FIFO of control interface.
    );

wire trig;
wire fifo_full;
wire fifo_wr_en;
wire valid;
wire [FIFO_WIDTH-1:0] data_to_fifo;
wire [CNT_WIDTH-1:0] count_delay;
wire [COUNT_WIDTH-1:0] counter;
wire [WIDTH-1:0] data_to_send;
wire [WIDTH-1:0] data_receive;


Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH))
    clock_div_0(
        .clk_in(clk_in),
        .rst(rst),
        .div(div),
        .counter(counter),
        .clk_out(clk)
        );
Config_data_Combination #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH))
    config_data_combination_inst(
        .clk_in(clk_in), 
        .rst(rst), 
        .data_in(din), 
        .pulse(wr_en),
        .data_out(data_to_send)
        );            
SR_Control #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION))
     sr_control_0(
        .din(data_to_send),
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_out(data_out),
        .load_sr(load_sr),
        .count_delay(count_delay),
        .clk_sr(clk_sr)
        );
        
//reg start_reg;
//wire start_tmp;

//assign start_tmp=start_reg;
//always@(posedge clk or posedge rst)
// begin
//  if(rst)
//  begin
//  start_reg<=0;
//  end
// else
//  begin
//  start_reg<=start;
//  end
// end
 
//Clock_SR #(.WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .DIV_WIDTH(DIV_WIDTH))        
//   clock_sr_0(
//        .clk_in(clk_in),
//        .rst(rst),
//        .count(count_delay),
//        .counter(counter),
//        .start(start),
//        .start_tmp(start_tmp),
//        .div(div),
//        .clk_sr(clk_sr)
//   );
assign trig= (READ_TRIG_SRC==1)? load_sr: start;
        
Receive_Data #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .READ_DELAY(READ_DELAY))
     receive_data_0(
        .data_in(data_in),
        .clk(clk),
        .rst(rst),
        .start(trig),
        .valid(valid),
        .dout(data_receive)
        ); 
        
Format_Data #(.DATA_WIDTH(WIDTH), .VALID_WIDTH(VALID_WIDTH), .NUM_WIDTH(NUM_WIDTH), .FIFO_WIDTH(FIFO_WIDTH))
     format_data_inst (
        .clk(clk_in),
        .rst(rst),
        .start(start),
        .data_in(data_receive),
        .fifo_full(fifo_full),
        .valid(valid),
        .fifo_wr_en(fifo_wr_en),
        .data_out(data_to_fifo)
        );

fifo36x512 fifo_sr_inst(
        .rst(rst),
        .wr_clk(clk_in),
        .rd_clk(clk_in),
        .din(data_to_fifo),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .dout(fifo_q),
        .full(fifo_full),
        .empty(fifo_empty)
        );        
endmodule
