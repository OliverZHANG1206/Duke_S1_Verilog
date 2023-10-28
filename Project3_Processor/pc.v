module pc_32bit (curr_ins, next_ins, clk, en, clr);

	input clk, en, clr;     // PC clock, enable, clear signal
	input [31:0] next_ins;  // PC next instruction address
	output [31:0] curr_ins; // PC current instruction address
	
	// Update next instruction to current instruction
	dffe_32bit pc1 (curr_ins, next_ins, clk, en, clr);

endmodule
