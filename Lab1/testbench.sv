// Testbench
module test;
  reg clk;
  reg reset;
  reg [31:0] a,b;
  wire [63:0] result1;
  reg ae;

  wire overflow1;
  macc_417 macc_unit1(.clk(clk), .rst(reset), .a(a), .b(b), .accumulate_enable(ae), .result(result1),.overflow(overflow1));
  
  
  // A test of different-widths for the multiply
  parameter VAR_W_A = 4;
  parameter VAR_W_B = 4;
  wire [VAR_W_A+VAR_W_B-1:0] result2;
  wire overflow2;
  
  macc_417 #(VAR_W_A,VAR_W_B)macc_unit2(
    .clk(clk),
    .rst(reset),
    .a(a[VAR_W_A-1:0]),
    .b(b[VAR_W_B-1:0]),
    .accumulate_enable(ae),
    .result(result2),
    .overflow(overflow2)
  );

  initial begin
    // Dump waves
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(3, test);
    $display("Reset flop.");
    clk = 0;
    ae = 0;
    a = 0;
    b = 0;
    reset = 1;
    #3
    reset = 0;
    #20
    reset = 1;
    ae = 1;
    #3
    reset = 0;
  end
  
  always begin
    clk = ~clk;
    #2;
  end
  
  always@(posedge clk)
  begin
    a = a+1;
    b = b+3;
  end
  


endmodule