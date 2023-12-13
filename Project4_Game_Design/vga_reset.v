module vga_reset(iCLK, oRESET);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input iCLK;
	output reg oRESET;
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	// Internal Registers
	reg [19:0] Cont;

	////////////////////////////// Sequential logic /////////////////////////////
	always@(posedge iCLK)
	begin
		if (Cont != 20'hFFFFF)
		begin
			Cont	 <= Cont + 20'd1;
			oRESET <= 1'b0;
		end
		else
			oRESET <= 1'b1;
	end

endmodule
