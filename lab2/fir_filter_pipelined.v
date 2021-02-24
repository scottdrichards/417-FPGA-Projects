`timescale 1ns / 1ps


module fir_filter_pipelined
#(
    parameter NUM_ELEMENTS = 7
)
(
    input clk,
    input rst,
    input [ 7 : 0 ] weight_data,
    input [ 2 : 0 ] weight_idx,
    input weight_valid,
    output weight_ready,
    input [ 7 : 0 ] input_data,
    input input_valid,
    output input_ready,
    output [ 15 : 0 ] output_data,
    input output_ready,
    output output_valid
);
    assign weight_ready = 1;
    assign input_ready = 1;
    assign output_valid = 1;
    
    // weight (and value) index 0 is beginning, NUM_ELEMENTS-1 is end
    reg [6:0] weights [NUM_ELEMENTS-1:0];
        
    // Shift register to hold values
    reg [6:0] values [NUM_ELEMENTS-1:0];
    
    // Pipeline stages
    reg [15:0] pipeStage1 [3:0];
    reg [15:0] pipeStage2 [1:0];
    reg [15:0] pipeStage3;
    assign output_data = pipeStage3;
    
    integer i;
    always@(posedge clk)begin
        // Reset
        if (rst)begin
            for (i = 0; i< NUM_ELEMENTS; i = i+1)begin
                weights[i] = 0;
                values[i] =0;            
            end
            
            // Clear pipe stages. I tried to do this parametrically but Vivado was being silly
            pipeStage1[0] = 0;
            pipeStage1[1] = 0;
            pipeStage1[2] = 0;
            pipeStage1[3] = 0;
            pipeStage2[0] = 0;
            pipeStage2[1] = 0;
            pipeStage3 = 0;
        end else begin
            if (weight_valid) // Update weights
                weights[weight_idx] <= weight_data;
     
            // Shift the values down the line
            for (i = NUM_ELEMENTS-1; i> 0; i=i-1)begin
                values[i] <= values[i-1];
            end
            // Bring in the new value
            values[0] <= input_data;
            
            // Again, vivado was being silly so I can't do this parametrically/algorithmically
            pipeStage3 <= pipeStage2[0]+pipeStage2[1];
            
            pipeStage2[0] <= pipeStage1[0]+pipeStage1[1];
            pipeStage2[1] <= pipeStage1[2]+pipeStage1[3];
            
            pipeStage1[0] <= weights[0]*values[0]+weights[1]*values[1];
            pipeStage1[1] <= weights[2]*values[2]+weights[3]*values[3];
            pipeStage1[2] <= weights[4]*values[4]+weights[5]*values[5];
            pipeStage1[3] <= weights[6]*values[6];
         end 
    end
endmodule