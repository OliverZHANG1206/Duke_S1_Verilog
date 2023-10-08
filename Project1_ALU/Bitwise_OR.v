module Bitwise_OR(dataA, dataB, result);

	input [31:0] dataA, dataB; // data input
	
	output [31:0] result;      // result output

	genvar i;
	generate
		for (i = 0; i < 32; i = i+1)
		begin : bitwise_or
			or (result[i], dataA[i], dataB[i]);
		end
	endgenerate

endmodule
