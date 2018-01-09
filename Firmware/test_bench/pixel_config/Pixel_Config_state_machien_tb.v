//% @file pixel_config_state_machine_tb.v
//% @brief testbench file for Pixel_Config_statemachine.v module
//% @author pyxiong
`timescale 1ns / 1ps

module Pixel_Config_state_machien_tb #(parameter DATA_WIDTH=15,
                                       parameter SHIFT_DIRECTION=1,
                                       parameter CNT_WIDTH=4)();
reg CLK_IN;
reg RESET;
reg START;
reg [DATA_WIDTH-1:0] DATA_IN;
reg BUSY;
reg EMPTY;
wire S_CLK;
wire S_DATA;
wire RD_FIFO;

Pixel_Config_statemachine #(.DATA_WIDTH(DATA_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .CNT_WIDTH(CNT_WIDTH))
  DUT0(
  .CLK_IN(CLK_IN),
  .RESET(RESET),
  .START(START),
  .DATA_IN(DATA_IN),
  .BUSY(BUSY),
  .EMPTY(EMPTY),
  .S_CLK(S_CLK),
  .S_DATA(S_DATA),
  .RD_FIFO(RD_FIFO)
  );

initial begin
$dumpfile("pixel_config_st.dump");
$dumpvars(0, Pixel_Config_statemachine);
end

initial begin
CLK_IN=1;
forever #20 CLK_IN=~CLK_IN;
end

initial begin
RESET=1;
#100 RESET=0;
end

initial begin
START=0;
EMPTY=1;
BUSY=0;
DATA_IN=15'b110100101011001;
#500 EMPTY=0;
#100 START=1;
end

endmodule
