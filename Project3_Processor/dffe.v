module dffe_32bit(q, d, clk, en, clr);
   // Inputs for clock, enable, clear
   input clk, en, clr;
	input [31:0] d;

   // Output for register output
   output reg [31:0] q;

   // Intialize q to 0
   initial
   begin
       q = 32'h00000000;
   end

   // Set value of q on positive edge of the clock or clear
   always @(posedge clk or posedge clr) 
	begin
		// If clear is high, set q to 0
      if (clr) 
			q <= 32'h00000000;
      // If enable is high, set q to the value of d 
		else if (en) 
			q <= d;
		// If enable is low, the q remain the same
		else
			q <= q;
   end
endmodule
