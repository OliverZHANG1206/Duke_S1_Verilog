module sra(data, shiftamt, result);
	
	input [31:0] data;    // data input
	input [4:0] shiftamt; // shift amount
	
	output [31:0] result; // output result
	
	wire [31:0] result1, result2, result4, result8; // shift 1/4/8 bit
	
	assign result1 = shiftamt[0] ? {data[31] ? 1'b1     : 1'b0,     data[31:1]}     : data;
	assign result2 = shiftamt[1] ? {data[31] ? 2'b11    : 2'b00,    result1[31:2]}  : result1;
	assign result4 = shiftamt[2] ? {data[31] ? 4'hf     : 4'h0,     result2[31:4]}  : result2;
	assign result8 = shiftamt[3] ? {data[31] ? 8'hff    : 4'h00,    result4[31:8]}  : result4;
	assign result  = shiftamt[4] ? {data[31] ? 16'hffff : 16'h0000, result8[31:16]} : result8;
	
endmodule
