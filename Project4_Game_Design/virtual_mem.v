module virtual_mem(
	clock,
	reset,
	wren, 
	address, 
	data,
	q_data,
	key_int,
	vga_int,
	key_data,
	pipe_refresh,
	oxbuf, 
	oybuf, 
	game_status,
	bird_y,
	score
);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input 						clock, reset; 	// clock and reset
	input 						wren;				// write enable
	input 			[16:0] 	address;			// address
	input 			[31:0] 	data;				// data input to save
	input 			[10:0] 	oxbuf;			// x position of the pipe 1
	input 			[10:0] 	oybuf;			// y position of the pipe 1
	
	input 						key_int;			// keyboard interrupt input
	input 						vga_int;			// vga new freame refresh interrupt
	input 						pipe_refresh;	// pipe refresh interrupt
	input				[7:0]		key_data;		// keyboard input data
	
	output reg  	[31:0]   q_data;			// data port for processor to fetch
	output reg  	[2:0]		game_status;	// current game status
	output reg  	[7:0]		score;			// final score of the game
	output reg		[10:0]	bird_y;			// y position of the bird
	
	///////////////// Internal Wires and Registers Declarations /////////////////  
	reg 							key_int_handler, vga_int_handler, pipe_int_handler; // Interrupt handler
	reg 				[7:0] 	key_int_buf;	// input buffer for keyboard data input
	
	////////////////////////////// Sequential logic /////////////////////////////
	always @(posedge clock or negedge reset)
	begin
		if (~reset)
		begin
			key_int_handler <= 1'b0;
			vga_int_handler <= 1'b0;
			pipe_int_handler <= 1'b0;
			key_int_buf <= 8'd0;
			game_status <= 2'b0;
		end
		else
		begin
			// Setting all the interrupt line to the memory
			if (key_int)
			begin
				key_int_handler <= 1'b1;
				key_int_buf <= key_data;
			end
			else
				key_int_handler <= key_int_handler;
			
			if (vga_int)
				vga_int_handler <= 1'b1;
			else
				vga_int_handler <= vga_int_handler;
			
			if (pipe_refresh)
				pipe_int_handler <= 1'b1;
			else if (game_status != 2'd2)
				pipe_int_handler <= 1'b0;
			else
				pipe_int_handler <= pipe_int_handler;
			
			// Write operation
			if (wren)
			begin
				case (address) // virtual memory write
				17'd5000:
					game_status <= data[1:0];
				17'd5001:
					bird_y <= 11'd480 - data[10:0];
				17'd5002:
					score <= data[7:0];
				17'd6000:
					if (pipe_refresh)
						pipe_int_handler <= 1'b1;
					else
						pipe_int_handler <= data[0];
				17'd6001:
					if (key_int)
						key_int_handler <= 1'b1;
					else
						key_int_handler <= data[0];
				17'd6002:
					if (vga_int)
						vga_int_handler <= 1'b1;
					else
						vga_int_handler <= data[0];
				endcase
			end
			// Read operation
			else
			begin
				case (address)	 // virtual memory read
				17'd5000:
					q_data <= game_status;
				17'd5001:
					q_data <= bird_y;
				17'd5002:
					q_data <= score;
				17'd5003:
					q_data <= {{22{oxbuf[10]}},  oxbuf[9:0]};
				17'd5004:
					q_data <= {{22{oybuf[10]}},  oybuf[9:0]};
				17'd6000:
					q_data <= pipe_int_handler;
				17'd6001:
					q_data <= key_int_handler;
				17'd6002:
					q_data <= vga_int_handler;
				17'd6003:
					q_data <= key_int_buf;
				endcase
			end
		end
	end

endmodule
