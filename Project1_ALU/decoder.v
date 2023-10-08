module decoder(in, out);
	
	input [4:0] in;   // opcode input
	output [5:0] out; // hot-line output
	
	wire [4:0] nin;   // not wire for input
	
	// **Generate nagetive opcode**
	genvar i;
	generate
		for (i = 0; i<=4; i=i+1)
		begin: not_input
			not (nin[i], in[i]);
		end
	endgenerate
	
	// **Decode each hot-line**
	and (out[0], nin[4], nin[3], nin[2], nin[1], nin[0]); // ADD Command
	and (out[1], nin[4], nin[3], nin[2], nin[1],  in[0]); // SUB Command
	and (out[2], nin[4], nin[3], nin[2],  in[1], nin[0]); // Bitwise AND
	and (out[3], nin[4], nin[3], nin[2],  in[1],  in[0]); // Bitwise OR
	and (out[4], nin[4], nin[3],  in[2], nin[1], nin[0]); // SLL
	and (out[5], nin[4], nin[3],  in[2], nin[1],  in[0]); // SDA
	
endmodule
