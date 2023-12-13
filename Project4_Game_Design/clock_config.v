module clk_div2(clk, reset, clk_out);

	input clk;
	input reset;
	output reg clk_out;

	always @(posedge clk or posedge reset)
	begin
		if (reset)
			clk_out <= 1'b0;
		else
			clk_out <= ~clk_out;	
	end
	
endmodule 

module clk_div4(clk, reset, clk_out);
	
	input clk;
	input reset;
	output clk_out;
	
	wire clk_2;
	
	clk_div2 div2 (clk,   reset, clk_2);
	clk_div2 div4 (clk_2, reset, clk_out);

endmodule

module clk_config(clock, reset, imem_clock, dmem_clock, processor_clock, regfile_clock);
	
	input clock, reset;
	output imem_clock, dmem_clock, processor_clock, regfile_clock;
	
	clk_div4 pc_clk  (clock, reset, processor_clock);
	assign regfile_clock = processor_clock;
	assign imem_clock = ~clock;
	assign dmem_clock = clock;

endmodule
