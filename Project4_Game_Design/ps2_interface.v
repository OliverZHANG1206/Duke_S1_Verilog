module ps2_interface(clk, reset, ps2_clock, ps2_data, ps2_key_pressed, ps2_key_data);

	///////////////////////////// Port Declarations ///////////////////////////// 
	input 		 		clk, reset;             // clock and reset
	input 		 		ps2_clock, ps2_data;    // ps2_clock line and data line
	output reg 		 	ps2_key_pressed;		   // ps2 pressed sign
	output reg [7:0]	ps2_key_data;			   // ps2 data output
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	wire 					ps2_key_data_en;        // ps2 complete data transfer sign
	wire [7:0] 			ps2_key_data_received;  // ps2 original data received
	reg  [2:0]			ns_ps2_input; 				// Next state PS2 input
	reg  [2:0]			s_ps2_input;  				// Current state PS2 input
	
	////////////////////////// Parameter Declarations /////////////////////////// 
	localparam A = 8'h1C, B = 8'h32, C = 8'h21, D = 8'h23, E = 8'h24, F = 8'h2B, G = 8'h34,
				  H = 8'h33, I = 8'h43, J = 8'h3B, K = 8'h42, L = 8'h4B, M = 8'h3A, N = 8'h31,
				  O = 8'h44, P = 8'h4D, Q = 8'h15, R = 8'h2D, S = 8'h1B, T = 8'h2C, U = 8'h3C,
				  V = 8'h2A, W = 8'h1D, X = 8'h22, Y = 8'h35, Z = 8'h1A;
				  
	localparam N0 = 8'h45, N1 = 8'h16, N2 = 8'h1E, N3 = 8'h26, N4 = 8'h25, 
	           N5 = 8'h2E, N6 = 8'h36, N7 = 8'h3D, N8 = 8'h3E, N9 = 8'h46;
				  
	localparam up = 8'h75, left = 8'h6b, down = 8'h72, right = 8'h74;
	
	localparam space = 8'h29, enter = 8'h5A, esc = 8'h76;
	
	// states
	localparam  PS2_STATE_0_IDLE				= 3'h0, // No value to transfer
					PS2_STATE_1_VALUE				= 3'h1, // Direct type keyboard input
					PS2_STATE_2_EXTEND   		= 3'h2, // Extend sign state
					PS2_STATE_3_EXTEND_VALUE   = 3'h3, // Extend type keyboard input
					PS2_STATE_4_RELEASE			= 3'h4; // Release type

	////////////////////////// Finite State Machine(s) //////////////////////////
	// Key board input 1: "A F0 A" the keyboard would print F0 when user release the button
	// Key board input 2: "E0 up E0 F0 up" the keyboard would print E0 for extend key
	// state: type 1: 0->1->4->0, type 2: 0->2->3->2->4->0
	always @(posedge ps2_key_data_en or negedge reset)
	begin
		if (~reset)
			s_ps2_input <= PS2_STATE_0_IDLE;
		else
			s_ps2_input <= ns_ps2_input;
	end
	
	always @(*)
	begin
		if (~reset) 
			ns_ps2_input <= PS2_STATE_0_IDLE;
		else
		begin
			case (s_ps2_input)
			// Currently no data input
			PS2_STATE_0_IDLE:
			begin
				if (ps2_key_data_received == 8'hE0)
					ns_ps2_input = PS2_STATE_2_EXTEND;
				else
					ns_ps2_input = PS2_STATE_1_VALUE;
			end
			
			// The data is not extended state -> transfer to ASCII
			PS2_STATE_1_VALUE:
			begin
				if (ps2_key_data_received == 8'hF0)
					ns_ps2_input = PS2_STATE_4_RELEASE;
				else
					ns_ps2_input = PS2_STATE_1_VALUE;
			end
			
			// The first is a extend sign, wait for next true data
			PS2_STATE_2_EXTEND:
			begin
				if (ps2_key_data_received == 8'hF0)
					ns_ps2_input = PS2_STATE_4_RELEASE;
				else
					ns_ps2_input = PS2_STATE_3_EXTEND_VALUE;
			end
				
			// Extended data state -> trasnfer to ASCII 
			PS2_STATE_3_EXTEND_VALUE:
			begin
				if (ps2_key_data_received == 8'hE0)
					ns_ps2_input = PS2_STATE_2_EXTEND;
				else
					ns_ps2_input = PS2_STATE_3_EXTEND_VALUE;
			end
			
			// Release sign state -> jump back to idle state
			PS2_STATE_4_RELEASE:
				ns_ps2_input = PS2_STATE_0_IDLE;
			
			default: ns_ps2_input = PS2_STATE_0_IDLE;
			endcase
		end
	end
	
	////////////////////////////// Sequential logic /////////////////////////////
	always @(posedge clk or negedge reset)
	begin
		if (~reset)
			ps2_key_data <= 8'h00;			
		else if (ps2_key_data_en)
		begin
			
			case (s_ps2_input)
			// Transfer the signle key to ASCII
			PS2_STATE_1_VALUE:
			begin
				// Set pressed
				ps2_key_pressed <= 1'b1;
				
				case (ps2_key_data_received)
				A: ps2_key_data <= 8'h41;
				B: ps2_key_data <= 8'h42;
				C: ps2_key_data <= 8'h43;
				D: ps2_key_data <= 8'h44;
				E: ps2_key_data <= 8'h45;
				F: ps2_key_data <= 8'h46; 
				G: ps2_key_data <= 8'h47;
				H: ps2_key_data <= 8'h48;
				I: ps2_key_data <= 8'h49;
				J: ps2_key_data <= 8'h4A;
				K: ps2_key_data <= 8'h4B;
				L: ps2_key_data <= 8'h4C;
				M: ps2_key_data <= 8'h4D;
				N: ps2_key_data <= 8'h4E;
				O: ps2_key_data <= 8'h4F;
				P: ps2_key_data <= 8'h50;
				Q: ps2_key_data <= 8'h51;
				R: ps2_key_data <= 8'h52;
				S: ps2_key_data <= 8'h53;
				T: ps2_key_data <= 8'h54;
				U: ps2_key_data <= 8'h55;
				V: ps2_key_data <= 8'h56;
				W: ps2_key_data <= 8'h57;
				X: ps2_key_data <= 8'h58;
				Y: ps2_key_data <= 8'h59;
				Z: ps2_key_data <= 8'h5A;
				
				N0: ps2_key_data <= 8'h30;
				N1: ps2_key_data <= 8'h31;
				N2: ps2_key_data <= 8'h32;
				N3: ps2_key_data <= 8'h33;
				N4: ps2_key_data <= 8'h34;
				N5: ps2_key_data <= 8'h35;
				N6: ps2_key_data <= 8'h36;
				N7: ps2_key_data <= 8'h37;
				N8: ps2_key_data <= 8'h38;
				N9: ps2_key_data <= 8'h39;
				
				esc: ps2_key_data <= 8'h01;
				enter: ps2_key_data <= 8'hFF;
				space: ps2_key_data <= 8'h20;
				
				default: ps2_key_pressed <= 1'b0;
				endcase
			end
			
			// Transfer extend key
			PS2_STATE_3_EXTEND_VALUE:
			begin
				// Set pressed
				ps2_key_pressed <= 1'b1;
				
				case (ps2_key_data_received)
				up:    ps2_key_data <= 8'h57;
				left:  ps2_key_data <= 8'h41;
				down:  ps2_key_data <= 8'h53;
				right: ps2_key_data <= 8'h44;
				
				default: ps2_key_pressed <= 1'b0;
				endcase
			end
			
			default:
			begin
				ps2_key_pressed <= 1'b0;
				ps2_key_data <= ps2_key_data;
			end
			endcase
		end
		else
		begin
			ps2_key_pressed <= 1'b0;
			ps2_key_data <= ps2_key_data;
		end
	end
	
	////////////////////////////// Internal Modules /////////////////////////////
	ps2_controller PS2 (.clk 					(clk),
							  .reset 				(reset),
							  .ps2_clk	      	(ps2_clock),
						     .ps2_data	      	(ps2_data),		
						     .received_data		(ps2_key_data_received),
						     .received_data_en	(ps2_key_data_en));

endmodule
