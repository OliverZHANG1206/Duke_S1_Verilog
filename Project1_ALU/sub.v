module subtract(dataA, dataB, result, overflow, isNotEqual, isLessThan);
	
	input [31:0] dataA, dataB;     // input data
	
	output [31:0] result;          // output result
	output overflow;               // output for overflow
	output isNotEqual, isLessThan; // output for 'is not equal' sign and 'is less than' sign
	
	wire [31:0] n_dataB;           // 'not' for each dataB bit
	wire [7:0] or_4bit;            // 'or' 8 bits for result (bitwise or for 32bit but considering the fan-in and fan-out)
	wire bitwise_nor;              // 'nor' 32 bits for result
	wire cout;                     // carry-out for 32bit adder
	
	// **Deal with substraction (B->-B without +1 compliment)**
	genvar i;
	generate
		for (i=0; i<=31; i=i+1)
		begin: get_inverse
			not (n_dataB[i], dataB[i]);
		end
	endgenerate
	
	// **Create substractor**
	cla_32 subtractor(dataA, n_dataB, 1'b1, result, cout, overflow);
	
	// **Deal with isLessThan**
	xor (isLessThan, overflow, result[31]);
	
	// **Deal with isNotEqual**
	// 1. OR each 4 bits in result
	generate
		for (i=0; i<=7; i=i+1)
		begin: bitwise_or_4bits
			or (or_4bit[i], result[i*4], result[i*4+1], result[i*4+2], result[i*4+3]);
		end
	endgenerate
	
	// 2. OR all the bit in the reuslt and negate them
	nor  (bitwise_nor, or_4bit[0], or_4bit[1], or_4bit[2], or_4bit[3], or_4bit[4], or_4bit[5], or_4bit[6], or_4bit[7]);
	
	// 3. if is equal, cout must be 1 and not(bitwise OR) must be 1, from truth table 
	nand (isNotEqual, bitwise_nor, cout);

endmodule
