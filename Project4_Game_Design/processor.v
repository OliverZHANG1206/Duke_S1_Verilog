module processor(
	// Control signals
	system_clock,			// I: system clock
	reset,					// I: A reset signal
	
	// Virtual memory
	wren_virtual,			// O: 
	address_virtual,
	data_virtual,
	q_virtual
);
	
	///////////////////////////// Port Declarations ///////////////////////////// 
	// Control signals
	input system_clock;
	input reset;
	
	// virtual memory -> hardware interface
	output				wren_virtual;
	output 	[16:0] 	address_virtual;
	output 	[31:0]	data_virtual;
	input		[31:0]	q_virtual;
	
	/////////////////////////// Parameter Declarations ///////////////////////////
	localparam Rzero = 5'd0, Rstatus = 5'd30, Rreturn = 5'd31; // Register 30 & 31 address
	
	///////////////// Internal Wires and Registers Declarations /////////////////
	// Wire define
	wire 				imem_clock, dmem_clock, processor_clock, regfile_clock;
	wire [31:0] 	next_pc, curr_pc, pc_p1, pc_p1n, pc_pp; 	// Current PC and next PC, PC plus one and PC plus n + 1
	wire [31:0] 	ins;                             			// 32-bit instruction
	wire [31:0] 	reg_data;                        			// data that need to write into the regfile
	wire [31:0] 	ALU_operandA, ALU_operandB;      			// two data feed into ALU
	wire [31:0] 	ALU_result;                      			// ALU calculation result
	wire [31:0] 	deme_data;                       			// data read from the data memory
	wire [31:0] 	ExN27, ExN17;                    			// Sign extension wire
	wire [1:0] 		Ovfctrl;                          			// Overflow mux control
	wire [4:0] 		opcode;                           			// 5-bit operation code
	wire [4:0] 		Rs, Rt, Rd;                       			// Rs, Rt, Rd address for regfile port
	wire [4:0] 		ALUopcode, ALUopctrl;             			// ALU operation code (raw & control)
	wire [4:0] 		Shiftamt;                         			// shift amount for SLL and SRA
	wire 				Rwe, Rtar, Rwd, ALUinB, ALUsht, DMwe;   	// Control wires (R & I)
	wire 				Bex, Setx, Jal, Jr, J, Bne, Blt;        	// Control wires (B & J)
	wire 				isNE, isLT, overflow;                   	// ALU output flag ('<'|'!='|'ovf')
	wire [31:0] 	data_readRegA, data_readRegB;
	wire [31:0]		virtual_data, data;
	
	/* Clock configuration */
	clk_config	myconfig (system_clock, reset, imem_clock, dmem_clock, processor_clock, regfile_clock); 	// clock config
	
	/* SIGN EXTENSION */
	assign ExN27 = {{5{ins[26]}},  ins[26:0]};
	assign ExN17 = {{15{ins[16]}}, ins[16:0]};
	
	/* PC CONTROL */
	dffe_32bit pc1 (curr_pc, next_pc, processor_clock, 1'b1, reset);
	alu pc_alu   (.data_operandA(curr_pc), .data_operandB(32'd1), .ctrl_ALUopcode(5'd0), .data_result(pc_p1));
	alu pc_n_alu (.data_operandA(pc_p1),   .data_operandB(ExN17), .ctrl_ALUopcode(5'd0), .data_result(pc_p1n));
	assign next_pc = Jr ? data_readRegB : ((Bex & isNE) | J | Jal) ? ExN27 : ((Blt & isNE & (~isLT)) | (Bne & isNE)) ? pc_p1n : pc_p1;
	
	/* CONTROL UNIT */
	assign opcode = ins[31:27];
	assign ALUopcode = ins[6:2];
	ctrl_unit control (.opcode(opcode), .Rwe(Rwe), .Rtar(Rtar), .Rwd(Rwd), .Ovfctrl(Ovfctrl),
	                   .ALUopcode(ALUopcode), .ALUinB(ALUinB), .ALUopctrl(ALUopctrl), .overflow(overflow), 
							 .BltOP(Blt), .BneOP(Bne), .BexOP(Bex), .JOP(J), .JrOP(Jr), .JalOP(Jal), .SetxOP(Setx),
							 .DMwe(DMwe));
	
	/* REGISTER FILE */
	assign Rs = Bex  ? Rzero   : ins[21:17];
	assign Rt = Bex  ? Rstatus : Rtar ? ins[26:22] : ins[16:12];
	assign Rd = Setx ? Rstatus : Jal  ? Rreturn    : (|Ovfctrl) ? Rstatus : ins[26:22];
	assign reg_data = Setx ? ExN27 : Jal ? pc_p1 : Rwd ? data : (Ovfctrl[1] ? (Ovfctrl[0] ? 32'd3 : 32'd2) : (Ovfctrl[0] ? 32'd1 : ALU_result));
	assign data = (ALU_result >= 5000) ? virtual_data : deme_data;
	
	/* ALU */
	assign Shiftamt = ins[11:7];
	assign ALU_operandA = data_readRegA;
	assign ALU_operandB = ALUinB ? ExN17 : data_readRegB;
	alu main_alu (.data_operandA(ALU_operandA), .data_operandB(ALU_operandB), .ctrl_ALUopcode(ALUopctrl),
					  .ctrl_shiftamt(Shiftamt), .data_result(ALU_result), 
					  .isNotEqual(isNE), .isLessThan(isLT), .overflow(overflow));
	
	/* Virtual Memory */
	assign address_virtual = ALU_result[16:0];
	assign wren_virtual = DMwe;
	assign data_virtual = data_readRegB;
	assign virtual_data = q_virtual;
	
	////////////////////////////// Internal Modules /////////////////////////////
	/* INSTRUCTION MEMORY && DATA MEMORY && REGFILE */
	imem 		my_imem 		(curr_pc[9:0], imem_clock, ins);
	dmem 		my_dmem 		(ALU_result[7:0], dmem_clock, data_readRegB, DMwe, deme_data);
	regfile	my_regfile	(regfile_clock, Rwe, reset, Rd, Rs, Rt, reg_data, data_readRegA, data_readRegB);
	
endmodule
