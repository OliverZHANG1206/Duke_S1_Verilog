module vga_address_generator (
	// Input
	clock, reset,    		// clock and reset 
	HS, VS, BLANK_n, 		// vga sync control line
	game_status,	  		// current game status
	bird_y,
	pipe_cnt,			  	// number of object on the canvas (maximum 5 obj)
	x_buf,				  	// x axis buffer for pipe objects
	y_buf,				  	// y axis buffer for pipe objects
	score,
	
	// Output
	origin_address,
	address,
	mask_num
);

	///////////////////////////// Port Declarations ///////////////////////////// 
	input 					clock, reset;   	// clock and reset  
	input 					HS, VS, BLANK_n;	// VGA control signal
	input [2:0] 			game_status;		// game current status
	input [10:0]			bird_y;
	input [2:0] 			pipe_cnt;			// number of object on the canvas (maximum 5 obj)
	input [32:0] 			x_buf;				// 4 object y coordinate
	input [32:0]			y_buf;
	input [7:0]				score;
	
	output reg [18:0] 	origin_address;	// orignal address
	output reg [18:0] 	address;				// generated output
	output reg [2:0] 		mask_num;			// which picture/mask
	
	////////////////////////// Parameter Declarations ///////////////////////////
	localparam signed w_bird = 11'd40, 			h_bird = 11'd30;		// bird size
	localparam signed w_pipe = 11'd70, 			h_pipe = 11'd840;		// pipe size
	localparam signed w_start = 11'd258, 		h_start = 11'd67;	// start menu size
	localparam signed w_restart = 11'd339, 	h_restart = 11'd75;	// restart menu size
	localparam signed w_number = 11'd400, 		h_number = 11'd50;   // each number size
	
	localparam signed s_pos_x = 11'd191,		s_pos_y = 11'd100;
	localparam signed s_bird_x = 11'd300,		s_bird_y = 11'd225;
	localparam signed gg_pos_x = 11'd146, 		gg_pos_y = 11'd100;
	localparam signed num1_pos_x = 11'd280,	num1_pos_y = 11'd50;
	localparam signed num2_pos_x = 11'd320, 	num2_pos_y = 11'd50;
	localparam signed w_number_single = 11'd40;
	localparam signed gg_num_pos_y = 11'd240;
	localparam signed bird_x = 11'd140;
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	reg  signed [18:0] 	x;							// orignal address x coor
	reg  signed	[18:0] 	y;							// orignal address y coor
	wire 			[2:0] 	pipe;						// pipe indicator 
	wire signed [10:0] 	ox [2:0];				// address x coor
	wire signed [10:0] 	oy [2:0];				// address y coor 
	wire 			[3:0]		num1, num2;

	////////////////////////////// Sequential logic /////////////////////////////
	always @(posedge clock or negedge reset)
	begin
		if (~reset)
			origin_address <= 19'd0;
		else if (HS == 1'b0 && VS == 1'b0) // the line and frame are sync
			origin_address <= 19'd0;
		else if (BLANK_n == 1'b1)			  // 600*480 address start here
		begin
			// update original address
			origin_address <= origin_address + 1'b1;
			address <= 18'd0;
			mask_num <= 3'd0;
			
			case (game_status)
			// Game initializing
			2'd0:
				mask_num <= 3'd0;
					
			// Game is first started
			2'd1:
			begin
				// only one object - start menu - mask 5
				if (x >= s_pos_x && y >= s_pos_y && x < s_pos_x + w_start && y < s_pos_y + h_start)
				begin
					mask_num <= 3'd5;
					address <= (y - s_pos_y) * w_start + (x - s_pos_x);
				end
				else if (x >= s_bird_x && y >= s_bird_y && x < s_bird_x + w_bird && y < s_bird_y + h_bird)
				begin
					mask_num <= 3'd1;
					address <= (y - s_bird_y) * w_bird + (x - s_bird_x);
				end
				else
					mask_num <= 3'd0;
			end
				
			// Game is running
			2'd2:
			begin
				// First object must be the bird when game is running - mask 1
				if (x >= bird_x && y >= bird_y && x < bird_x + w_bird && y < bird_y + h_bird)
				begin
					mask_num <= 3'd1;
					address <= (y - bird_y) * w_bird + (x - bird_x);
				end
				// object are numbers 1 and 2 - mask 3
				else if (x >= num1_pos_x && y >= num1_pos_y && x < num1_pos_x + w_number_single && y < num1_pos_y + h_number)
				begin
					mask_num <= 3'd3;
					address <= (y - num1_pos_y) * w_number + num1 * w_number_single + (x - num1_pos_x);
				end
				else if (x >= num2_pos_x && y >= num2_pos_y && x < num2_pos_x + w_number_single && y < num2_pos_y + h_number)
				begin
					mask_num <= 3'd3;
					address <= (y - num2_pos_y) * w_number + num2 * w_number_single + (x - num2_pos_x);
				end
				else
				begin
					// object are numbers pipes - mask 2
					mask_num <= 3'd2;
					case (pipe)
					3'b001:
						address <= (y + oy[0]) * w_pipe + (x - ox[0]);
					3'b010:
						address <= (y + oy[1]) * w_pipe + (x - ox[1]);
					3'b100:
						address <= (y + oy[2]) * w_pipe + (x - ox[2]);
					default: 
						mask_num <= 3'd0;
					endcase
				end
			end
				
			// Game is over
			2'd3:
			begin
				// objects - restart menu and score - mask 3 and 4
				if (x >= num1_pos_x && y >= gg_num_pos_y && x < num1_pos_x + w_number_single && y < gg_num_pos_y + h_number)
				begin
					mask_num <= 3'd3;
					address <= (y - gg_num_pos_y) * w_number + num1 * w_number_single + (x - num1_pos_x);
				end
				else if (x >= num2_pos_x && y >= gg_num_pos_y && x < num2_pos_x + w_number_single && y < gg_num_pos_y + h_number)
				begin
					mask_num <= 3'd3;
					address <= (y - gg_num_pos_y) * w_number + num2 * w_number_single + (x - num2_pos_x);
				end
				else if (x >= gg_pos_x && y >= gg_pos_y && x < gg_pos_x + w_restart && y < gg_pos_y + h_restart)
				begin
					mask_num <= 3'd4;
					address <= (y - gg_pos_y) * w_restart + (x - gg_pos_x);
				end
				else
					mask_num <= 3'd0;
			end
				
			default:
				mask_num <= 3'd0;
			endcase
		end
	end
	
	// Calculate the x and y coordinate for current address
	always @(posedge clock or negedge reset)
	begin
		if (~reset) 
		begin
			x <= 18'd0;
			y <= 18'd0;
		end
		else
		begin
			x <= origin_address % 18'd640;
			y <= origin_address / 18'd640;
		end
	end 
	
	//////////////////////////// Combinational Logic ////////////////////////////
	genvar i;
	generate
		for (i = 0; i < 3; i = i + 1)
		begin : signed_extract
			assign ox[i] = x_buf[(i+1)*11-1:i*11];
			assign oy[i] = y_buf[(i+1)*11-1:i*11];
		end
		
		for (i = 0; i < 3; i = i + 1)
		begin : pipe_indicator
			assign pipe[i] = ((x >= ox[i]) && (x < ox[i] + w_pipe) && (pipe_cnt > i)) ? 1'b1 : 1'b0;
		end
	endgenerate
	
	assign num1 = (score > 8'd99) ? 4'd9 : score / 4'd10;
	assign num2 = (score > 8'd99) ? 4'd9 : score % 4'd10;
	
endmodule
