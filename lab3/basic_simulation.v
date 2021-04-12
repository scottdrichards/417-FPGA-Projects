`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2021 09:25:21 PM
// Design Name: 
// Module Name: basic_simulation
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
module basic_simulation
#(
 INPUT_QTY=8,
 OUTPUT_QTY=8,
 DATA_WIDTH=64
)
(

);


reg clk;
reg reset;
reg [INPUT_QTY-1:0] data_in_valid;
reg [INPUT_QTY-1:0] [DATA_WIDTH-1:0] data_in;
reg [INPUT_QTY-1:0] [$clog2(OUTPUT_QTY)-1:0] data_in_destination;

wire [OUTPUT_QTY-1:0] data_out_valid;
wire [OUTPUT_QTY-1:0] [DATA_WIDTH-1:0] data_out; 

initial begin
    clk = 0;
    reset = 1;
    #9;
    reset = 0;
    #50;
end 

always
begin
    clk = ~clk;
    #2;
end
very_simple_switch

 vss(
 .clk(clk), .reset(reset), .data_in_valid(data_in_valid), .data_in(data_in), .data_in_destination(data_in_destination), .data_out_valid(data_out_valid), .data_out(data_out));

integer i;
always@(posedge clk)
    if(reset)
    begin
    for( i=0; i<INPUT_QTY; i=i+1)
    begin
        data_in[i] = 0;
        data_in_destination[i] = 0;
        data_in_valid[i] = 0;
    end
    end else begin
        if(data_in[1] == 1)
        begin
            data_in_valid = 0;
        end else begin
        for( i=0; i<INPUT_QTY; i=i+1)
        begin
            data_in[i] = i;//i % 2;
            data_in_destination[i] = 1;
            data_in_valid[i] = 1;
        end
        end
    end
 endmodule
    