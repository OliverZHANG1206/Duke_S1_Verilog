/*****************************************************************************
 *                                                                           *
 * Module: PS2_Controller                                       		  		  *
 * Description: This module accepts incoming data from a PS2 core.           *
 *                                                                           *
 *****************************************************************************/

module ps2_controller (
	// Inputs
	clk,							// System/chip clock
	reset,						// chip reset
	
	ps2_clk,						// ps2_clk line
	ps2_data,					// ps2_data line

	// Outputs
	received_data,				// Received data (8 bit)
	received_data_en			// If 1 - new data has been received (it is a small pulse)
);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	input			clk;
	input			reset;
	
	input 		ps2_clk;
	input			ps2_data;

	output reg	[7:0]	received_data;
	output reg		 	received_data_en;

	////////////////////////// Parameter Declarations ///////////////////////////
	// states
	localparam	PS2_STATE_0_IDLE			   = 3'h0,
					PS2_STATE_1_DATA_IN			= 3'h1,
					PS2_STATE_2_PARITY_IN		= 3'h2,
					PS2_STATE_3_STOP_IN			= 3'h3;

	///////////////// Internal Wires and Registers Declarations /////////////////
	// Internal Wires
	reg			[3:0]	data_count;                    // count for how many data bit has input
	reg			[7:0]	data_shift_reg;					 // a buffer for storing the 8-bit data
	reg 					last_ps2_clk_reg, ps2_clk_reg; // a clock for storing the data
	wire 					ps2_clk_posedge;

	// State Machine Registers
	reg			[1:0]	ns_ps2_receiver; // Next state PS2 receiver
	reg			[1:0]	s_ps2_receiver;  // Current state PS2 receiver

	////////////////////////// Finite State Machine(s) //////////////////////////
	always @(posedge clk)
	begin
		if (~reset)
			s_ps2_receiver <= PS2_STATE_0_IDLE;
		else
			s_ps2_receiver <= ns_ps2_receiver;
	end

	always @(*)
	begin
		// Defaults state - IDLE
		ns_ps2_receiver = PS2_STATE_0_IDLE;

		case (s_ps2_receiver)
		// State 0: IDLE - The FSM is in IDLE with no data need to process
		PS2_STATE_0_IDLE:
		begin
			if ((ps2_data == 1'b0) && (ps2_clk_posedge == 1'b1) && (received_data_en == 1'b0))
				ns_ps2_receiver = PS2_STATE_1_DATA_IN;
			else
				ns_ps2_receiver = PS2_STATE_0_IDLE;
		end
		
		// State 1: DATA_IN - The FSM successfully received start bit and start to intake data (8 bit)
		PS2_STATE_1_DATA_IN:
		begin
			// Recieve 8 bit -> next stage
			if ((data_count == 3'h7) && (ps2_clk_posedge == 1'b1))
				ns_ps2_receiver = PS2_STATE_2_PARITY_IN;
			else
				ns_ps2_receiver = PS2_STATE_1_DATA_IN;
		end
		
		// State 2: PARITY_CHECK - The FSM successfully recieved 8 bit and do the parity check for input data
		// Note: This program do not have parity check, so just bypass 1 bit
		PS2_STATE_2_PARITY_IN:
		begin
			// Receive 1 parity bit -> next stage
			if (ps2_clk_posedge == 1'b1)
				ns_ps2_receiver = PS2_STATE_3_STOP_IN;
			else
				ns_ps2_receiver = PS2_STATE_2_PARITY_IN;
		end
		
		// State 4: STOP - The FSM completed all the data recieve and return to idle stage
		PS2_STATE_3_STOP_IN:
		begin
			// Receive 1 stop bit -> next stage
			if (ps2_clk_posedge == 1'b1)
				ns_ps2_receiver = PS2_STATE_0_IDLE;
			else
				ns_ps2_receiver = PS2_STATE_3_STOP_IN;
		end
	
		default:
		begin
			ns_ps2_receiver = PS2_STATE_0_IDLE;
		end
		endcase
	end

	////////////////////////////// Sequential logic /////////////////////////////
	// Counter behavior for counting how many bit that have received
	always @(posedge clk)
	begin
		if (~reset) 
			data_count	<= 3'h0;
		else if ((s_ps2_receiver == PS2_STATE_1_DATA_IN) && (ps2_clk_posedge == 1'b1))
			data_count	<= data_count + 3'h1;
		else if (s_ps2_receiver != PS2_STATE_1_DATA_IN)
			data_count	<= 3'h0;
	end

	// Shift register for storing the input data (8 bit)
	always @(posedge clk)
	begin
		if (~reset)
			data_shift_reg	<= 8'h00;
		else if ((s_ps2_receiver == PS2_STATE_1_DATA_IN) && (ps2_clk_posedge == 1'b1))
			data_shift_reg	<= {ps2_data, data_shift_reg[7:1]};
	end

	// Update the output from the recieved data buffer
	always @(posedge clk)
	begin
		if (~reset)
			received_data <= 8'h00;
		else if (s_ps2_receiver == PS2_STATE_3_STOP_IN)
			received_data	<= data_shift_reg;
	end

	// Stop behavior for set enable line to 1 to indicate the data have been successfully received
	always @(posedge clk)
	begin
		if (~reset)
			received_data_en <= 1'b0;
		else if ((s_ps2_receiver == PS2_STATE_3_STOP_IN) && (ps2_clk_posedge == 1'b1))
			received_data_en <= 1'b1;
		else
			received_data_en <= 1'b0;
	end
	
	// Because the clock in the PS2 keyboard is much lower than the 50MHz, thus this is a register to record
	// the clock in PS2 keyboard
	always @(posedge clk)
	begin
		if (~reset)
		begin
			last_ps2_clk_reg <= 1'b1;
			ps2_clk_reg		  <= 1'b1;
		end
		else
		begin
			last_ps2_clk_reg <= ps2_clk_reg; // Every clock cycle update clock edge and data
			ps2_clk_reg		  <= ps2_clk;
		end
	end

	//////////////////////////// Combinational Logic ////////////////////////////
	// Detect the posegde of the PS2 clock have posedge when the last time clock is 0 and now is 1
	assign ps2_clk_posedge = ((ps2_clk_reg == 1'b1) && (last_ps2_clk_reg == 1'b0)) ? 1'b1 : 1'b0;
	
endmodule

