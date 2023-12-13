module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	leds, 															// LED
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	clock);  													   // 50 MHz clock
	
	///////////////////////////// General ////////////////////////////////
	input					clock;    				// main clock
	input 				resetn;					// reset
		
	/////////////////////////////// VGA //////////////////////////////////
	output				VGA_CLK;   				//	VGA Clock
	output				VGA_HS;					//	VGA H_SYNC
	output				VGA_VS;					//	VGA V_SYNC
	output				VGA_BLANK;				//	VGA BLANK
	output				VGA_SYNC;				//	VGA SYNC
	output	[7:0]		VGA_R;   				//	VGA Red[9:0]
	output	[7:0]		VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]		VGA_B;   				//	VGA Blue[9:0]

	/////////////////////////////// PS2 ///////////////////////////////////
	input 				ps2_data;				// ps2 data line
	input					ps2_clock;				// ps2 clock line
	
	////////////////////// LCD and Seven Segment //////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	
	////////////// Internal Wires and Registers Declarations //////////////
	wire			 	delay_rst;                    // Delay rest line
	wire 			 	VGA_CTRL_CLK, AUD_CTRL_CLK;
	
	wire			 	lcd_write_en;
	wire [31:0] 	lcd_write_data;
	
	wire [7:0]	 	ps2_key_data;						// ps2 input data 
	wire				ps2_key_pressed;					// ps2 keyboard interrupt
	
	wire				vga_sync;							// vag frame sync interrupt signal
	wire				pipe_refresh;						// pipe refreshed interrupt
	
	wire [2:0] 		game_status;						// game current status
	wire [10:0]		bird_y;								// bird y axis
	wire [10:0] 	oxbuf;								// 3 object x coordinate
	wire [10:0] 	oybuf;								// 3 object y coordinate
	wire [7:0] 		score;								// game score
	
	wire [7:0]		pressed_times;						// A counter for counting how many times keyboard pressed
	wire [11:0]		play_time;							// A counter for time duration for each game round
	
	wire				wren_virtual;						// virtual memory write enable
	wire [16:0] 	address_virtual;					// virtual memory address
	wire [31:0]		data_virtual;						// virtual memory data
	wire [31:0]		q_virtual;							// virtual memory read data
	
	// Processor
	processor	myprocessor (.system_clock(clock), 
									 .reset(~resetn),									
									 .wren_virtual(wren_virtual), 
									 .address_virtual(address_virtual),
									 .data_virtual(data_virtual),		
									 .q_virtual(q_virtual));
	virtual_mem my_vmem		(.clock(clock), 
									 .reset(resetn), 
									 .wren(wren_virtual), 
									 .address(address_virtual), 
									 .data(data_virtual), 
									 .q_data(q_virtual), 
									 .key_int(ps2_key_pressed), 
									 .key_data(ps2_key_data),
									 .vga_int(vga_sync), 
									 .oxbuf(oxbuf), 
									 .oybuf(oybuf), 
									 .game_status(game_status), 
									 .bird_y(bird_y), 
									 .score(score),
									 .pipe_refresh(pipe_refresh));
	
	// PS2 keyboard controller
	ps2_interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_pressed, ps2_key_data);
	
	// LCD controller
	lcd mylcd(clock, ~resetn, ps2_key_pressed, ps2_key_data, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// Seven segment display
	Hexadecimal_To_Seven_Segment hex1(play_time[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(play_time[7:4], seg2);
	Hexadecimal_To_Seven_Segment hex3(play_time[11:8], seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(score[3:0], seg5);
	Hexadecimal_To_Seven_Segment hex6(score[7:4], seg6);
	Hexadecimal_To_Seven_Segment hex7(ps2_key_data[3:0], seg7);
	Hexadecimal_To_Seven_Segment hex8(ps2_key_data[7:4], seg8);
	
	// LED
	assign leds = pressed_times;
	
	// Counters
	pressed_times_cnt pcnt_inst (clock, resetn, ps2_key_pressed, pressed_times);
	paly_time_cnt		gcnt_inst (clock, resetn, game_status, play_time);
		
	// VGA
	vga_reset		r0  	  (.iCLK(clock), .oRESET(delay_rst));  // a small counter that delay reset signal
	vga_aduio_pll 	p1  	  (.areset(~delay_rst),.inclk0(clock),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK));
	vga_controller vga_ins (.clock(clock),
									.rstn(delay_rst),
									.reset_ex(resetn),
								   .vga_clk(VGA_CLK),
								   .oBLANK_n(VGA_BLANK),
								   .oHS(VGA_HS),
								   .oVS(VGA_VS),
								   .b_data(VGA_B),
								   .g_data(VGA_G),
								   .r_data(VGA_R),
									.status(game_status), 
									.bird_y(bird_y),
									.oxbuf1(oxbuf), 
									.oybuf1(oybuf),
									.vga_sync(vga_sync),
									.score(score),
									.pipe_refresh(pipe_refresh));
	
endmodule
