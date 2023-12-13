module pipe_generator (
	// Input
	clock,
	reset,
	status,
	vga_sync,
	
	// Output
	pipe_cnt,
	oxbuf,
	oybuf,
	pipe_refresh
);

	///////////////////////////// Port Declarations ///////////////////////////// 
	input						clock, reset;
	input 					vga_sync;
	input 		[2:0]		status;
	output 		[32:0]	oxbuf, oybuf;
	output reg 	[2:0] 	pipe_cnt;
	output reg				pipe_refresh;
	
	////////////////////////// Parameter Declarations ///////////////////////////
	localparam signed pos1 = 11'd180, pos2 = 11'd200, pos3 = 11'd160, pos4 = 11'd220, pos5 = 11'd140;
	localparam signed pos6 = 11'd240, pos7 = 11'd120, pos8 = 11'd260, pos9 = 11'd100;
	localparam shift = 11'd4;
	localparam distance = 11'd250;
	
	///////////////// Internal Wires and Registers Declarations /////////////////  
	reg 						clock_div;
	reg			[7:0]		counter;
	reg			[7:0]		random;
	reg			[10:0]	rand_pos;
	reg			[10:0]	pipex1_last;
	reg signed 	[10:0]	pipex1, pipex2, pipex3;
	reg signed 	[10:0]	pipey1, pipey2, pipey3;
	
	////////////////////////////// Sequential logic /////////////////////////////
	// A devider to reduce the refresh rate
	always @(posedge vga_sync or negedge reset)
	begin
		if (~reset)
		begin
			counter <= 8'b0;
			clock_div <= 1'b0;
		end
		else if (counter == 8'd1)
		begin
			counter <= 8'b0;
			clock_div <= 1'b1;
		end
		else
		begin
			clock_div <= 1'b0;
			counter <= counter + 1'b1;
		end
	end
	
	// Every update frame do a random number generation
	always @(posedge clock_div or negedge reset)
	begin
		if (~reset)
			random <= 8'b10110101;
		else
		begin
			random <= {random[3] ^ random[5], random[7:1]}; // persudo-random generation
			case (random % 9)
			0: rand_pos <= pos1;
			1: rand_pos <= pos2;
			2: rand_pos <= pos3;
			3: rand_pos <= pos4;
			4: rand_pos <= pos5;
			5: rand_pos <= pos6;
			6: rand_pos <= pos7;
			7: rand_pos <= pos8;
			8: rand_pos <= pos9;
			endcase
		end
	end
	
	// place the pipe
	always @(posedge clock_div or negedge reset)
	begin
		// reset: set the pipe position to all zero
		if (~reset)
		begin
			pipe_cnt <= 3'd0;
			pipex1 <= 11'd0;
			pipex2 <= 11'd0;
			pipex3 <= 11'd0;
			pipey1 <= 11'd0;
			pipey2 <= 11'd0;
			pipey3 <= 11'd0;
		end
		// if the game is playing 
		else if (status == 3'd2)
		begin
			case (pipe_cnt)
			// if the pipe number is zero, add pipe
			3'd0:
			begin
				pipex1 <= 11'd640;
				pipey1 <= rand_pos;
				pipe_cnt <= pipe_cnt + 1'b1;
			end
			// if the pipe number is one, add pipe
			3'd1:
			begin
				pipex1 <= pipex1 - shift;
				if (pipex1 < 11'd640 - distance) 
				begin
					pipex2 <= 11'd640;
					pipey2 <= rand_pos;
					pipe_cnt <= pipe_cnt + 1'b1;
				end
			end 
			// if the pipe number is two, add pipe
			3'd2:
			begin
				pipex1 <= pipex1 - shift;
				pipex2 <= pipex2 - shift;
				if (pipex2 < 11'd390) 
				begin
					pipex3 <= 11'd640;
					pipey3 <= rand_pos;
					pipe_cnt <= pipe_cnt + 1'b1;
				end
			end
			// if the pipe number is three, reduce pipe
			3'd3:
			begin
				if (pipex1 + 70 <= 0) 
				begin
					pipex1 <= pipex2 - shift;
					pipey1 <= pipey2;
					pipex2 <= pipex3 - shift;
					pipey2 <= pipey3;
					pipex3 <= 11'd640;
					pipey3 <= 11'd480;
					pipe_cnt <= pipe_cnt - 1'b1;
				end
				else
				begin
					pipex1 <= pipex1 - shift;
					pipex2 <= pipex2 - shift;
					pipex3 <= pipex3 - shift;
				end
			end
			default: pipe_cnt <= 3'd0;
			endcase
		end
		else // Clear all if not gaming
		begin
			pipe_cnt <= 3'd0;
			pipex1 <= 11'd0;
			pipex2 <= 11'd0;
			pipex3 <= 11'd0;
			pipey1 <= 11'd0;
			pipey2 <= 11'd0;
			pipey3 <= 11'd0;
		end
	end
	
	// make a pipe refresh interrupt
	always @(posedge clock or negedge reset)
	begin
		if (~reset)
			pipex1_last <= 2'b00;
		else
		begin
			pipex1_last <= pipex1;
			
			if (pipex1_last >= 11'd90 && pipex1 < 11'd90)
				pipe_refresh <= 1'b1;
			else
				pipe_refresh <= 1'b0;
		end
	end

	// output buffer
	assign oxbuf = {pipex3, pipex2, pipex1};
	assign oybuf = {pipey3, pipey2, pipey1};
	
endmodule
