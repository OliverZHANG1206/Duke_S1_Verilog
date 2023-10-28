module clk_neg (clk, reset, clk_out);

	input clk;
	input reset;
	output reg clk_out;
	
	reg clk_pos, clk_neg;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset)
			clk_pos <= 1'b0;
		else
			clk_pos <= ~clk_pos;
	end
	
	always @(negedge clk or posedge reset)
	begin
		if (reset)
			clk_neg <= 1'b0;
		else
			clk_neg <= ~clk_neg;
	end
	
	always @(*)
	begin
		clk_out = clk_pos ^ clk_neg;
	end
	
endmodule

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
