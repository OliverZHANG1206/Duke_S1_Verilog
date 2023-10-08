module decoder(ctrl_bit, line);
	// input address
	input [4:0] ctrl_bit;
	
	// ouput parallel wire
	output [31:0] line;
	
	// shift left wire
	wire [31:0] shift0, shift1, shift2, shift4, shift8;
	
	// The decoder is like a shift left logic start with 0x00000001
	assign shift0 = 32'h00000001;
	assign shift1 = ctrl_bit[0] ? {shift0[30:0], 1'b0}     : shift0;
	assign shift2 = ctrl_bit[1] ? {shift1[29:0], 2'b00}    : shift1;
	assign shift4 = ctrl_bit[2] ? {shift2[27:0], 4'h0}     : shift2;
	assign shift8 = ctrl_bit[3] ? {shift4[23:0], 8'h00}    : shift4;
	assign line   = ctrl_bit[4] ? {shift8[15:0], 16'h0000} : shift8;
	
endmodule
