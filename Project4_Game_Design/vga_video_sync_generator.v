//////////////////////VGA TIMING AND PRINCIPLE//////////////////////
//																						//
// VGA Timing																		//
// Horizontal:																		//
//                 ___________              _____________________ //
//                |           |            |								//
// _______________|   VIDEO   |____________|  VIDEO (next line)	//
// 		    <-C-> <----D----> <-E->										//
// _______   _______________________   __________________________ //
//        |_|                       |_|									//
//         B <----------A----------> B										//	
//            																		//
// The Unit used below are pixels;  										//
//   B->Sync_cycle                   :H_sync_cycle						//
//   C->Back_porch                   :hori_back							//
//   D->Visable Area																//
//   E->Front porch                  :hori_front						//
//   A->horizontal line total length :hori_line							//
//																						//
// Vertical:																		//
//                 ___________              _____________________ //
//                |           |            |          				//
// _______________|   VIDEO   |____________|  VIDEO (next frame)	//
// 			 <-Q-> <----R----> <-S->										//
// _______   _______________________	__________________________ //
//        |_|                       |_|									//
//         P <----------O----------> P										//
//           																		//
// The Unit used below are horizontal lines;  							//
//   P->Sync_cycle                   :V_sync_cycle						//
//   Q->Back_porch                   :vert_back							//
//   R->Visable Area																//
//   S->Front porch                  :vert_front						//
//   O->vertical line total length   :vert_line							//
//																						//
////////////////////////////////////////////////////////////////////

module vga_video_sync_generator(vga_clk, reset, blank_n, HS, VS);

   ///////////////////////////// Port Declarations /////////////////////////////                       
	input reset;
	input vga_clk;
	output reg blank_n; 				// Indicate the current is a blank to fill
	output reg HS;		  				// Indicate the Horizontal line is syncing
	output reg VS;						// Indicate the Virtical line is syncing
                         
	////////////////////////// Parameter Declarations ///////////////////////////
	parameter hori_line    = 800; // Total horizontal pixel   
	parameter hori_back    = 144; // back porch - the pixel exceed left side of the screen
	parameter hori_front   = 16;  // front porch - the pixel exceed right side of the screen 
	parameter vert_line    = 525;	// Total vertical pixel
	parameter vert_back    = 34;	// back porch - the pixel exceed top side of the screen
	parameter vert_front   = 11;  // front porch - the pixel exceed bottom side of the screen 
	parameter H_sync_cycle = 96;	// sync cycle time for cursor back to left
	parameter V_sync_cycle = 2;   // sync cycle time for cursor back to top
	
	///////////////// Internal Wires and Registers Declarations /////////////////               *
	reg [9:0]  v_cnt;  // virtical position of the cursor
	reg [10:0] h_cnt;	 // horizontal position of the cursor
	wire cHD, cVD, cDEN, hori_valid, vert_valid;
	
	// Update the cursor position each vga clock cycle 
	always @(negedge vga_clk or posedge reset)
	begin
		if (reset)
		begin
			h_cnt <= 11'd0;
			v_cnt <= 10'd0;
		end
		else
		begin
			if (h_cnt == hori_line - 1)
			begin 
				h_cnt <= 11'd0;
				if (v_cnt == vert_line - 1)
					v_cnt <= 10'd0;
				else
					v_cnt <= v_cnt + 10'd1;
			end
			else
				h_cnt <= h_cnt + 11'd1;
		end
	end

	// The waiting sign / time cycle for VGA to sync back (horizontal->cursor back to left side, virtical->back to top)
	assign cHD = (h_cnt < H_sync_cycle) ? 1'b0 : 1'b1;
	assign cVD = (v_cnt < V_sync_cycle) ? 1'b0 : 1'b1;

	// Visible horizontal / verital pixel line / frame 
	assign hori_valid = (h_cnt < (hori_line - hori_front) && h_cnt >= hori_back) ? 1'b1 : 1'b0;
	assign vert_valid = (v_cnt < (vert_line - vert_front) && v_cnt >= vert_back) ? 1'b1 : 1'b0;

	// Visible area sign
	assign cDEN = hori_valid && vert_valid;

	always@ (negedge vga_clk)
	begin
		HS <= cHD;
		VS <= cVD;
		blank_n <= cDEN;
	end

endmodule

