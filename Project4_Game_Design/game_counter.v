// Count for how many times the keyboard pressed
module pressed_times_cnt(clock, reset, ps2_key_pressed, counter);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input 				clock, reset;
	input 				ps2_key_pressed;
	output reg [7:0]  counter;
	
	////////////////////////////// Sequential logic /////////////////////////////
	always @(posedge clock or negedge reset)  
	begin
		if (~reset) 
			counter <= 8'h00;
		else if (ps2_key_pressed)
			counter <= counter + 1'b1;
	end
	
endmodule

// Count for total playing time
module paly_time_cnt(clock, reset, game_status, second_cnt);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input 					clock, reset;
	input 		[2:0] 	game_status;
	output reg  [11:0] 	second_cnt;
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	reg [32:0] clock_cnt;
	
	////////////////////////////// Sequential logic /////////////////////////////
	always @(posedge clock or negedge reset)  
	begin
		if (~reset) 
		begin
			clock_cnt <= 8'h00;
			second_cnt <= 8'h00;
		end
		else if (game_status == 2'd2) 
		begin
			if (clock_cnt == 32'd50000000 - 32'd1)
			begin
				clock_cnt <= 8'h00;
				second_cnt <= second_cnt + 1'b1;
			end
			else
				clock_cnt <= clock_cnt + 1'b1;
		end
		else if (game_status == 2'd3)
		begin
			clock_cnt <= 8'h00;
			second_cnt <= second_cnt;
		end
		else
		begin
			clock_cnt <= 8'h00;
			second_cnt <= 8'h00;
		end
	end

endmodule
