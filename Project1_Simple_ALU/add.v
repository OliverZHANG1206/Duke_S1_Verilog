module add(dataA, dataB, result, overflow);

	input [31:0] dataA, dataB; // input data
	output [31:0] result;      // ouput result
	output overflow;           // overflow sign for adding
	
	wire cout;                 // carry-out sign
	
	// **Implement adder**
	cla_32 adder(dataA, dataB, 1'b0, result, cout, overflow);

endmodule
