`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ccnu
// Engineer: Poyi Xiong
// 
// Create Date: 01/13/2017 04:41:05 PM
// Design Name: 
// Module Name: top_sr_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_sr_tb #(parameter WIDTH=50,
                   parameter CNT_WIDTH=8,
                   parameter DIV_WIDTH=6,
                   parameter COUNT_WIDTH=64,
                   parameter VALID_WIDTH=32,
                   parameter NUM_WIDTH=4,
                   parameter FIFO_WIDTH=36,
                   parameter SHIFT_DIRECTION=1,
                   parameter READ_TRIG_SRC=0,
                   parameter READ_DELAY=0)();
reg clk_in;
reg rst;
reg start;
reg [15:0] din;
reg wr_en;
reg data_in;
reg [DIV_WIDTH-1:0] div;
reg fifo_rd_en;
wire clk_sr;
wire data_out;
wire load_sr;
wire fifo_empty;
wire [FIFO_WIDTH-1:0] fifo_q;
wire clk;

Top_SR #(.WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .VALID_WIDTH(VALID_WIDTH), .NUM_WIDTH(NUM_WIDTH), .FIFO_WIDTH(FIFO_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION),.READ_TRIG_SRC(READ_TRIG_SRC),.READ_DELAY(READ_DELAY))
  DUT4(
    .clk_in(clk_in),
    .rst(rst),
    .start(start),
    .wr_en(wr_en),
    .din(din),
    .data_in(data_in),
    .div(div),
    .fifo_rd_en(fifo_rd_en),
    .clk_sr(clk_sr),
    .data_out(data_out),
    .load_sr(load_sr),
    .clk(clk),
    .fifo_empty(fifo_empty),
    .fifo_q(fifo_q)
    );
    
initial begin
$dumpfile("top_sr.dump");
$dumpvars(0, Top_SR);
end

initial begin
clk_in=1;
forever #5 clk_in=~clk_in;
end
 
initial begin
rst=0;
#100 rst=1;
#100 rst=0;
end

initial begin
div=6'b10;
start=0;
din=16'b1000_0100_0010_0011;
wr_en=0;
#300 wr_en=1;
#10 wr_en=0;
repeat(3)
  begin
  #20 din=din+2'b10;
  #10 wr_en=1;
  #10 wr_en=0;
  end
#100 start=1;
#40 start=0;
repeat(4)
  begin
  #20 din=din+2'b10;
  #10 wr_en=1;
  #10 wr_en=0;
  end
#3205 start=1;
#40 start=0;
end

initial begin
fifo_rd_en=0;
data_in=0;
//data_in_n=1;
//#775
//data_in_p=1;
//data_in_n=0;  
//#200 
//data_in_p=0;
//data_in_n=1;
//#200 
//data_in_p=1;
//data_in_n=0;
end

endmodule
