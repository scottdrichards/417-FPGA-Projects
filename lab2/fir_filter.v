`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2021 12:13:38 PM
// Design Name: 
// Module Name: fir_filter
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


module fir_filter
#(
    parameter NUM_ELEMENTS = 7
)
(
    input clk,
    input rst,
    input [ 7 : 0 ] weight_data,
    input [ 2 : 0 ] weight_idx,
    input weight_valid,
    output reg weight_ready,
    input [ 7 : 0 ] input_data,
    input input_valid,
    output input_ready,
    output [ 15 : 0 ] output_data,
    input output_ready,
    output output_valid
);
    // weight (and value) index 0 is beginning, NUM_ELEMENTS-1 is end
    reg [7:0] weights [NUM_ELEMENTS-1:0];
        
    // Shift register to hold values
    reg [7:0] values [NUM_ELEMENTS-1:0];
    
    
    integer i;
    always@(posedge clk)begin
        // Reset
        if (rst)begin
            for (i = 0; i< NUM_ELEMENTS; i = i+1)begin
                values[i] <= 0;
                weights[i] <= 0;
            end
        end else begin
            if (weight_valid)
                weights[weight_idx] <= weight_data;
            if (input_valid)begin
                // Shift the values down the line, have to start at the end
                // so you don't overwrite stuff
                for (i = NUM_ELEMENTS-1; i> 0; i=i-1)begin
                    values[i] <= values[i-1];
                end
                // Bring in the new value
                values[0] <= input_data;
            end    
         end
    end
    
    // This section combines the weights and values to generate a total sum
    wire [15:0] intermediate_sums [NUM_ELEMENTS-1:0];
    assign output_data = intermediate_sums[NUM_ELEMENTS-1]; // result
    generate
        genvar j;
        for (j = 1; j<NUM_ELEMENTS; j=j+1)begin:summation
            assign intermediate_sums[j] = i?intermediate_sums[j-1]:0 + values[j]*weights[j];
        end
    endgenerate    
    

endmodule