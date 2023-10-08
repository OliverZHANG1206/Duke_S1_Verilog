module sll(data, shiftamt, result);
	
	input [31:0] data;    // data input
	input [4:0] shiftamt; // shift amount
	
	output [31:0] result; // output result
	
	wire [31:0] result1, result2, result4, result8; // shift 1/4/8 bit
	
	assign result1 = shiftamt[0] ? {data[30:0]   , 1'b0}     : data;
	assign result2 = shiftamt[1] ? {result1[29:0], 2'b00}    : result1;
	assign result4 = shiftamt[2] ? {result2[27:0], 4'h0}     : result2;
	assign result8 = shiftamt[3] ? {result4[23:0], 8'h00}    : result4;
	assign result  = shiftamt[4] ? {result8[15:0], 16'h0000} : result8;
	
endmodule
