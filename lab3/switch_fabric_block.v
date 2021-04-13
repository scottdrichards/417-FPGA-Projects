`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2021 12:07:57 PM
// Design Name: 
// Module Name: switch_fabric_block
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


module switch_fabric_block
#(
    parameter DATA_WIDTH = 16,
    parameter OUTPUT_QTY = 4,
    parameter INPUT_QTY = 4
)(
    input clk,
    input reset,
    
    input data_in_valid [INPUT_QTY-1:0],
    input [DATA_WIDTH-1:0] data_in [INPUT_QTY-1:0] ,
    input [$clog2(OUTPUT_QTY)-1:0] data_in_destination [INPUT_QTY-1:0],
    
    output data_out_valid [OUTPUT_QTY-1:0],
    output [DATA_WIDTH-1:0] data_out [OUTPUT_QTY-1:0] 
);
reg  [DATA_WIDTH-1:0] data_out_reg [OUTPUT_QTY-1:0];
assign data_out = data_out_reg;

reg data_out_valid_reg [OUTPUT_QTY-1:0];
assign data_out_valid = data_out_valid_reg;

localparam BUFFER_LEN = 5;
reg fifo_in_push [OUTPUT_QTY-1:0][INPUT_QTY-1:0];
wire fifo_out_full [OUTPUT_QTY-1:0][INPUT_QTY-1:0];
wire [DATA_WIDTH-1:0] fifo_out_data [OUTPUT_QTY-1:0][INPUT_QTY-1:0];
reg fifo_in_pop [OUTPUT_QTY-1:0][INPUT_QTY-1:0];
wire fifo_out_empty [OUTPUT_QTY-1:0][INPUT_QTY-1:0];

integer i;
integer j;
integer popped;
always@(posedge clk)begin
    for (j = 0; j<OUTPUT_QTY; j=j+1)begin
        // Initial conditions for output FIFOs
        for (i = 0; i<INPUT_QTY; i=i+1)begin
            fifo_in_push[j][i] = 0;
            fifo_in_pop[j][i] = 0;
        end
        // Other initial conditions
        popped = -1;
        data_out_valid_reg[j] <= 0;
        
        if (!reset)begin
            for (i = 0; i<INPUT_QTY; i=i+1)begin
                // Every input goes into the respective FIFO buffer
                if (data_in_valid[i] && (data_in_destination[i]==j))begin
                    fifo_in_push[j][i] = 1;
                end
                
                // POP the first non-empty FIFO buffer (starting at 0)
                if (popped==-1 && !fifo_out_empty[j][i])begin
                    fifo_in_pop[j][i] = 1;
                    popped = i;
                end
             end
             if (popped==-1)begin
                // No buffers had data to put out
             end else begin
                data_out_valid_reg[j] <= 1;
                data_out_reg[j] <= fifo_out_data[j][popped];
             end
         end
    end   
end


generate
    genvar outIndex;
    for (outIndex=0; outIndex<OUTPUT_QTY; outIndex=outIndex+1) begin:everyOut
        genvar inIndex;
        for (inIndex=0; inIndex<OUTPUT_QTY; inIndex=inIndex+1) begin:inBufferAtOut
            fifo #(DATA_WIDTH,BUFFER_LEN)outFifo(
                .din(data_in[inIndex]),
                .push(fifo_in_push[outIndex][inIndex]),
                .full(fifo_out_full[outIndex][inIndex]),
                .dout(fifo_out_data[outIndex][inIndex]),
                .pop(fifo_in_pop[outIndex][inIndex]),
                .empty(fifo_out_empty[outIndex][inIndex]),
                
                .clk(clk),
                .reset(reset)
                );
        end
    end
endgenerate
 
endmodule
