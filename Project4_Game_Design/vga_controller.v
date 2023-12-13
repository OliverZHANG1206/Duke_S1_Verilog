module vga_controller(
	clock,
	rstn,
	reset_ex,
	vga_clk, 
	status,
	bird_y,	
	oxbuf1, 
	oybuf1,
	pipe_refresh,	
	oBLANK_n, 
	oHS, 
	oVS, 
	b_data, 
	g_data, 
	r_data,
	vga_sync,
	score
);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input				clock;				// system clock (50MHz)
	input 			rstn, reset_ex;	// delay reset and external reset
	input 			vga_clk;				// vga clock (25MHz)
	input [2:0] 	status;				// game current status
	input [10:0]	bird_y;				// y position of the bird
	input [7:0]		score;				// game score
	
	output reg 		oBLANK_n;			// BLANK(negative) output signal
	output reg 		oHS;					// horizontal refresh
	output reg 		oVS;					// vitical refresh 
	output reg		vga_sync;			// vga refresh sign (interrupt)
	output [7:0] 	b_data;				// blue data
	output [7:0] 	g_data;  			// green data
	output [7:0] 	r_data;				// red data
	output [10:0]	oxbuf1;				// x position of the pipe 1
	output [10:0]	oybuf1;				// y position of the pipe 1
	output			pipe_refresh;		// pipe refresh sign (interrupt)
	
	///////////////// Internal Wires and Registers Declarations /////////////////                     
	// Internal registers
	reg  [23:0]		rgb_data;
	reg  [1:0]		frame_trig_buf;
	
	// Internal wires
	wire 				vga_clkn;
	wire [2:0]		mask;
	wire [7:0] 		index;
	wire [23:0] 	rgb_data_raw;
	wire [18:0] 	oaddress, address;  	// orignal address and changed address
	wire 				cBLANK_n, cHS, cVS;  // blank, horizontal, virtical sync signal
	wire [2:0]		pipe_cnt;
	wire [32:0] 	oxbuf;				   // 3 object pipe x coordinate
	wire [32:0] 	oybuf;				   // 3 object pipe y coordinate

	// sync signal generator
	vga_video_sync_generator LTM_ins (vga_clk, ~rstn, cBLANK_n, cHS, cVS);
	
	// address generator
	vga_address_generator ADR_ins  (.clock(vga_clk),
											  .reset(rstn),
											  .BLANK_n(cBLANK_n),
											  .HS(cHS),
											  .VS(cVS),
											  .game_status(status),
											  .bird_y(bird_y),
											  .pipe_cnt(pipe_cnt),
											  .x_buf(oxbuf),
											  .y_buf(oybuf),
											  .origin_address(oaddress),
											  .address(address),
											  .mask_num(mask),
											  .score(score));
	pipe_generator PIPE_ins (.clock(clock), 
									 .reset(reset_ex), 
									 .status(status), 
									 .vga_sync(vga_sync), 
									 .pipe_cnt(pipe_cnt), 
									 .oxbuf(oxbuf), 
									 .oybuf(oybuf),
									 .pipe_refresh(pipe_refresh));
	assign oxbuf1 = oxbuf[10:0];
	assign oybuf1 = oybuf[10:0];
	
	/* INDEX addr. */
	assign vga_clkn = ~vga_clk;
	vga_image_mask mask_ins(.clock(vga_clkn), .oaddress(oaddress), .address(address), .mask(mask), .index(index));
	
	// Color table output
	color_index index_inst (.address (index), .clock (vga_clk), .q (rgb_data_raw));	

	// latch valid data at falling edge
	always @(posedge vga_clkn) 
		rgb_data <= rgb_data_raw;
		
	assign r_data = rgb_data[23:16];
	assign g_data = rgb_data[15:8];
	assign b_data = rgb_data[7:0]; 

	// Delay the iHD, iVD,iDEN for one clock cycle;
	always @(negedge vga_clk)
	begin
		oHS <= cHS;
		oVS <= cVS;
		oBLANK_n <= cBLANK_n;
	end
	
	// Trigger a vag_sync signal - 60Hz
	always @(posedge clock)
	begin
		frame_trig_buf <= {frame_trig_buf[0], cVS};
		if (frame_trig_buf == 2'b10)
			vga_sync <= 1'b1;
		else
			vga_sync <= 1'b0;
	end

endmodule
 	