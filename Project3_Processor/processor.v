/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
	// Control signals
	clock,                          // I: The master clock
	reset,                          // I: A reset signal

	// Imem
	address_imem,                   // O: The address of the data to get from imem
	q_imem,                         // I: The data from imem

	// Dmem
	address_dmem,                   // O: The address of the data to get or put from/to dmem
	data,                           // O: The data to write to dmem
	wren,                           // O: Write enable for dmem
	q_dmem,                         // I: The data from dmem

	// Regfile
	ctrl_writeEnable,               // O: Write enable for regfile
	ctrl_writeReg,                  // O: Register to write to in regfile
	ctrl_readRegA,                  // O: Register to read from port A of regfile
	ctrl_readRegB,                  // O: Register to read from port B of regfile
	data_writeReg,                  // O: Data to write to for regfile
	data_readRegA,                  // I: Data from port A of regfile
	data_readRegB                   // I: Data from port B of regfile
);
	
	// Control signals
	input clock, reset;

	// Imem
	output [11:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [11:0] address_dmem;
	output [31:0] data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */
	// Parameter define
	localparam Rstatus = 5'd30, Rreturn = 5'd31; // Register 30 & 31 address
	
	// Wire define
	wire [31:0] next_pc, curr_pc;                // Current PC and next PC
	wire [31:0] ins;                             // 32-bit instruction
	wire [31:0] reg_data;                        // data that need to write into the regfile
	wire [31:0] ALU_operandA, ALU_operandB;      // two data feed into ALU
	wire [31:0] ALU_result;                      // ALU calculation result
	wire [31:0] deme_data;                       // data read from the data memory
	wire [1:0] Ovfctrl;                          // Overflow mux control
	wire [4:0] opcode;                           // 5-bit operation code
	wire [4:0] Rs, Rt, Rd;                       // Rs, Rt, Rd address for regfile port
	wire [4:0] ALUopcode, ALUopctrl;             // ALU operation code (raw & control)
	wire [4:0] Shiftamt;                         // shift amount for SLL and SRA
	wire Rwe, Rtar, Rwd, ALUinB, ALUsht, DMwe;   // Control wires
	wire isNotEqual, isLessThan, overflow;       // ALU output flag ('<'|'!='|'ovf')
	
	/* PC CONTROL */
	pc_32bit pc (.curr_ins(curr_pc), .next_ins(next_pc), .clk(clock), .en(1'b1), .clr(reset));
	alu pc_alu  (.data_operandA(curr_pc), .data_operandB(32'd1), .ctrl_ALUopcode(5'd0), .data_result(next_pc));
	
	/* INSTRUCTION MEMORY */
	assign address_imem = curr_pc[11:0];
	assign ins = q_imem;
	
	/* CONTROL UNIT */
	assign opcode = ins[31:27];
	assign ALUopcode = ins[6:2];
	ctrl_unit control (.opcode(opcode), .Rwe(Rwe), .Rtar(Rtar), .Rwd(Rwd), 
	                   .ALUopcode(ALUopcode), .ALUinB(ALUinB), .ALUopctrl(ALUopctrl), .overflow(overflow), 
							 .Ovfctrl(Ovfctrl),
							 .DMwe(DMwe));
	
	/* REGISTER FILE */
	assign Rs = ins[21:17];
	assign Rt = Rtar ? ins[26:22] : ins[16:12];
	assign Rd = (|Ovfctrl) ? Rstatus : ins[26:22];
	assign reg_data = Rwd ? deme_data : (Ovfctrl[1] ? (Ovfctrl[0] ? 32'd3 : 32'd2) : (Ovfctrl[0] ? 32'd1 : ALU_result));
	
	assign ctrl_readRegA = Rs;
	assign ctrl_readRegB = Rt;
	assign ctrl_writeReg = Rd;
	assign ctrl_writeEnable = Rwe;
	assign data_writeReg = reg_data;
	
	/* ALU */
	assign Shiftamt = ins[11:7];
	assign ALU_operandA = data_readRegA;
	assign ALU_operandB = ALUinB ? {{15{ins[16]}}, ins[16:0]} : data_readRegB;
	alu main_alu (.data_operandA(ALU_operandA), .data_operandB(ALU_operandB), .ctrl_ALUopcode(ALUopctrl),
					  .ctrl_shiftamt(Shiftamt), .data_result(ALU_result), 
					  .isNotEqual(isNotEqual), .isLessThan(isLessThan), .overflow(overflow));
	
	/* DATA MEMORY */
	assign address_dmem = ALU_result[11:0];
	assign data = data_readRegB;
	assign wren = DMwe;
	assign deme_data = q_dmem;
	
endmodule
