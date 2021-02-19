/*
psu_ids: szr322 (Scott Richards), ama54@psu.edu (Ashfaq, Asad), arp5767@psu.edu (Palasamudrum, Ankush)


NOTES:          
    Structure
    	This is a variable-width multiplier that can be re-used
        for any bit-widths. It also includes a carry bit.
    
    	The multiplier comprises a chain of adders
        which bitshift a running total then add b
        if the corresponding index of a is '1'.
        It begins by analzying the MSB of a and works
        down to 0.
        
        Each addition is done by a variable-bit-width 
        ripple adder comprising full- and half- adders
        as appropriate.
        
        To save space, the adders in the chain (for mult)
        start at, e.g., 32bit+32bit=33bit then gradually increase until
        they are 64bit+32bit=65bit though the final bit (carry)
        is discarded in the multiply result.
        
    Parameters:
       	- A_WIDTH: The bit width of input A
       	- B_WIDTH: The bit width of input B
        
	Triggers:
    	- Reset-high: accumulator is set to 0
      - Clock-high: current result is saved to accumulator
      - a or b change: result = a*b+accumulator
        
          accumulator_enable is not a trigger, it merely
          replaces 'a' and 'b' with 0 when disabled
          
    State:
    	- Only state maintained is the accumulator, all 
          else is combinational.
*/
module macc_417
  #(parameter A_WIDTH = 32,
    parameter B_WIDTH = 32
  )
  (
    input clk,
    input rst,
    input [A_WIDTH-1:0] a,
    input [B_WIDTH-1:0] b,
    input accumulate_enable,
    output [A_WIDTH+B_WIDTH-1:0] result,
    output overflow
  );
  parameter R_WIDTH = A_WIDTH+B_WIDTH;
  
  // Make the inputs meaningless if ae is disabled. Saves energy
  // because no internal state change
  wire [A_WIDTH-1:0]a_input = accumulate_enable?a:{A_WIDTH{1'b0}};
  wire [B_WIDTH-1:0]b_input = accumulate_enable?b:{B_WIDTH{1'b0}};  
  
  // State reg, everything else is combinational
  reg [R_WIDTH-1:0] accumulator;
  
  // Reset the total to zero on rst
  always@(posedge rst)begin
    accumulator <= {R_WIDTH{1'b0}};
  end
  
  // Capture input state on accumulate enable
  always@(posedge clk)begin
    if (accumulate_enable && !rst) accumulator <= result;
  end
  
  // Interconnects are the wires connecting
  // each successive adder, there are 31 adders
  // so we have 32 connections, each being 64 bits wide
  wire [A_WIDTH:1][R_WIDTH:0] interconnects;
        
  // This is designed as a chain of adders. It takes the prior
  // result and bit-shifts left by 1 and adds it to 'b' if the
  // corresponding bit in 'a' is a 1;
  
  // Because it is a chain, there are propogation delays as the value
  // gets passed down the chain. I'm sure there is a faster way.
  generate
    genvar i;
    for (i = 1; i< A_WIDTH; i++) begin:mult
      // When i == 0 we don't do addition, it's just b
      // so we skip that iteration of the loop and assign it here
      wire [B_WIDTH-1+i:0] adder_a;
      if (i==1) assign adder_a =  a_input[A_WIDTH-1]?b:{B_WIDTH{1'b0}};
      else assign adder_a =  interconnects[i];
        
      ripple_adder #(B_WIDTH+i,B_WIDTH)ra1(
        // Left shift and 0 pad
        {adder_a[B_WIDTH-2+i:0],1'b0},
        // Starting from LSB, if 1 then add, otherwise carry through
        a_input[A_WIDTH-1-i]? b_input :{B_WIDTH{1'b0}},
        // Store the result in the next interconnect
        interconnects[i+1][B_WIDTH+i:0]);
    end
  endgenerate
  
  // Add the mult with the accumulator and attach to result
  wire [R_WIDTH-1:0]multiply_result = interconnects[A_WIDTH][R_WIDTH-1:0];
  ripple_adder #(R_WIDTH,R_WIDTH) ra_final(multiply_result, accumulator, {overflow,result});
endmodule

                                                                        
                                                                        
// Variable width - A_WIDTH must be >= B_WIDTH
// Return width is A_WIDTH+1 unless RESULT_INCL_CARRY is set to 0, then is A_WIDTH
module ripple_adder
  #(parameter A_WIDTH = 64,
    parameter B_WIDTH = 64,
    parameter RESULT_INCL_CARRY = 1
  )
  (
    input [A_WIDTH-1:0] a,
    input [B_WIDTH-1:0] b,
    output [A_WIDTH-1+RESULT_INCL_CARRY:0] result
  );
  
  wire [A_WIDTH:1] carry; 
  
  generate 
    genvar i;
    for (i = 0; i<A_WIDTH; i=i+1) begin:adder
      // There's no carry-in for the first add so we can use a half-adder
      if (i == 0) begin
        half_adder ha0(
          a[i],
          b[i],
          result[i],
          carry[i+1]
        );
      end
      else if (i<B_WIDTH)begin
        // Full adder for the range of b (32-bit)        
        full_adder fa1(
          a[i],
          b[i],
          carry[i],
          result[i],
          carry[i+1]
        );
      end else begin
        // Only use a half-adder because we are past the range of b (32-bit)
        half_adder ha1(
          a[i],
          carry[i],
          result[i],
          carry[i+1]
        );
      end      
    end
  endgenerate
  
  // Map the final carry bit to the result if we are interested in retreiving
  // that from the output
  if (RESULT_INCL_CARRY) assign result[A_WIDTH] = carry[A_WIDTH];
endmodule

module full_adder
(
  input a,
  input b,
  input carry_in,
  output sum,
  output carry
);
  wire partial_sum, carry_1, carry_2;
  half_adder ha1(a, b, partial_sum, carry_1);
  half_adder ha2(partial_sum, carry_in, sum, carry_2);
  assign carry = carry_1 | carry_2;
endmodule

module half_adder
(
  input a,
  input b,
  output sum,
  output carry
);
  assign sum = a ^ b;
  assign carry = a & b;
endmodule
