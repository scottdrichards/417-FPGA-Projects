`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2021 03:52:37 PM
// Design Name: 
// Module Name: testbench
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

`define NUM_INPUTS 4
`define NUM_OUTPUTS 4
`define DATA_WIDTH 16 // Decreased because of board limitations 

module testbench;
reg clk, rst;

reg data_in_valid [`NUM_INPUTS-1:0];
reg [`DATA_WIDTH-1:0] data_in [`NUM_INPUTS-1:0];
reg [1:0] destinations [`NUM_INPUTS-1:0];

wire data_out_valid [`NUM_OUTPUTS-1:0];
wire [`DATA_WIDTH-1:0] data_out [`NUM_OUTPUTS-1:0]; 

switch_fabric_block #(
        .DATA_WIDTH(`DATA_WIDTH),
        .OUTPUT_QTY(`NUM_OUTPUTS),
        .INPUT_QTY(`NUM_INPUTS)
        )
    switch(clk,rst,data_in_valid,data_in,destinations,data_out_valid,data_out);


initial begin
    clk = 0;
    rst = 1;
    #4;
    rst = 0;
    #4;
    data_in_valid = {1,1,1,1};
    destinations = {3,2,1,0};
    data_in = {10,9,8,7};
    
    #4;
    destinations = {0,0,0,0};
    data_in = {15,15,15,15};
    
    #4
    destinations = {1,1,1,1};
    data_in = {0,0,0,0};
    
    #4
    destinations = {2,2,2,2};
    data_in = {1,1,1,1};
    #4
    destinations = {3,4,3,4};
    data_in = {2,2,2,2};
    #4
    destinations = {4,3,4,3};
    data_in = {3,3,3,3};
    #4
    data_in_valid = {0,0,0,0};
end 


always 
begin
    clk = ~clk;
    #2;
end 
    
endmodule
