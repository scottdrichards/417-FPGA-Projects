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


module testbench;

reg clk, rst;

reg [7:0] input_data;
reg [7:0] weight_data;
reg [2:0] weight_idx;

initial begin
    clk = 0;
    rst = 1;
    weight_idx = 0;
    weight_data = 0;
    input_data = 0;
    output_ready = 0;
    input_valid = 0;
    #14
    weight_valid = 1;
    #6;
    rst = 0;
    #4;
    output_ready = 1;
    weight_idx = 0;
    weight_data = 1;
    #4;
    weight_idx = 1;
    weight_data = 1;
    #4;
    weight_idx = 2;
    weight_data = 1;
    #4;
    weight_idx = 3;
    weight_data = 1;
    #4;
    weight_idx = 4;
    weight_data = 1;
    #4;
    weight_idx = 5;
    weight_data = 1;
    #4;
    weight_idx = 6;
    weight_data = 1;
    #4;
    weight_valid = 0;
    #8
    input_valid = 1;
end 

wire weight_ready;
reg input_valid;
reg weight_valid;
reg output_ready;


wire input_ready1;
wire output_valid1;
wire [15:0] fir_out;
fir_filter fir_simple(
    clk,
    rst,
    weight_data,
    weight_idx,
    weight_valid,
    input_ready1,
    input_data,
    input_valid,
    input_ready,
    fir_out,
    output_ready,
    output_valid1);


wire input_ready2;
wire output_valid2;
wire [15:0] fir_pipe_out;
fir_filter_pipelined fir_pipe(
    clk,
    rst,
    weight_data,
    weight_idx,
    weight_valid,
    input_ready2,
    input_data,
    input_valid,
    input_ready,
    fir_pipe_out,
    output_ready,
    output_valid2);

wire input_ready3;
wire output_valid3;
wire [15:0] fir_max_pipe_out;
fir_filter_max_pipelined fir_max_pipe(
    clk,
    rst,
    weight_data,
    weight_idx,
    weight_valid,
    input_ready3,
    input_data,
    input_valid,
    input_ready,
    fir_max_pipe_out,
    output_ready,
    output_valid3);



always 
begin
    clk = ~clk;
    #2;
end 

always@(posedge clk)
begin
    if(input_valid & input_ready1 & input_ready2 & input_ready3)
        input_data <= 1;
end
    
endmodule
