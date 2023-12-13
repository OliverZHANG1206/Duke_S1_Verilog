module vga_image_mask(
	clock,
	oaddress, 
	address, 
	mask, 
	index
);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input 			clock;						// clock input
	input  [18:0] 	oaddress, address;		// original and modified address
	input  [2:0]  	mask;							// which picture should use
	
	output [7:0]	index;						// The index in the color board
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	wire [7:0] 		bird_index, pipe_index, number_index, background_index, gg_index, title_index; // The index from the mask or the background
	
	//////////////////////////// Combinational Logic ////////////////////////////
	assign index = (mask == 3'd0) ? background_index :
						(mask == 3'd1) ? (bird_index == 8'd0)   ? background_index : bird_index :
						(mask == 3'd2) ? (pipe_index == 8'd0)   ? background_index : pipe_index :
						(mask == 3'd3) ? (number_index == 8'd0) ? background_index : number_index :
						(mask == 3'd4) ? (gg_index == 8'd0)     ? background_index : gg_index : 
						(mask == 3'd5) ? (title_index == 8'd0)  ? background_index : title_index : 
						background_index;
	
	////////////////////////////// Internal Modules /////////////////////////////
	background 	background_inst  (.address(oaddress),      .clock (clock), .q (background_index));
	flappy_bird flappy_bird_inst (.address(address[10:0]), .clock (clock), .q (bird_index));
	pipe			pipe_inst		  (.address(address[15:0]), .clock (clock), .q (pipe_index));
	number		number_inst		  (.address(address[14:0]), .clock (clock), .q (number_index));
	gameover		gg_inst			  (.address(address[14:0]), .clock (clock), .q (gg_index));
	title			title_inst		  (.address(address[14:0]), .clock (clock), .q (title_index));

endmodule
