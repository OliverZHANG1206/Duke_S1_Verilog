module ctrl_unit(opcode, ALUopcode, overflow, Rwe, Rtar, Rwd, ALUinB, ALUopctrl, Ovfctrl,  
	              DMwe, BltOP, BneOP, BexOP, JOP, JrOP, JalOP, SetxOP);
	
	input overflow;                                       // Overflow for the ALU
	input [4:0] opcode, ALUopcode;                        // Operation code & ALU Operation code
	
	output Rwe, Rtar, Rwd;                                // Register control flag
	output ALUinB;                                        // ALU unit control flag  
	output DMwe;                                          // Data Memory write control
	output BltOP, BneOP, BexOP, JOP, JrOP, JalOP, SetxOP; // Branch & Jump instruction flag
	output [1:0] Ovfctrl;                                 // Overflow control flag      
	output [4:0] ALUopctrl;                               // ALU operation code 
	
	// Different Operations
	wire arithOP, arithiOP, swOP, lwOP;                   // Arthematric and load type instruction flag
	wire addOP, subOP, addiOP;                            // ALU operation
	
	// Arithmatric function
	assign arithOP  = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & (~opcode[1]) & (~opcode[0]); // All arithmatric R OP 00000
	assign arithiOP = (~opcode[4]) & (~opcode[3]) & ( opcode[2]) & (~opcode[1]) & ( opcode[0]); // ADDI & SUBI 00101
	
	// Load and Save
	assign swOP     = (~opcode[4]) & (~opcode[3]) & ( opcode[2]) & ( opcode[1]) & ( opcode[0]); // SW  00111
	assign lwOP     = (~opcode[4]) & ( opcode[3]) & (~opcode[2]) & (~opcode[1]) & (~opcode[0]); // lw  01000
	
	// Jump function
	assign JOP      = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & (~opcode[1]) & ( opcode[0]); // j   00001
	assign JrOP     = (~opcode[4]) & (~opcode[3]) & ( opcode[2]) & (~opcode[1]) & (~opcode[0]); // jr  00100
	assign JalOP    = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & ( opcode[1]) & ( opcode[0]); // jal 00011
	
	// Binary function
	assign BneOP    = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & ( opcode[1]) & (~opcode[0]); // bne 00010
	assign BltOP    = (~opcode[4]) & (~opcode[3]) & ( opcode[2]) & ( opcode[1]) & (~opcode[0]); // blt 00110
	assign BexOP    = ( opcode[4]) & (~opcode[3]) & ( opcode[2]) & ( opcode[1]) & (~opcode[0]); // bex (not in MIPS) 10110
	assign SetxOP   = ( opcode[4]) & (~opcode[3]) & ( opcode[2]) & (~opcode[1]) & ( opcode[0]); // setx(not in MIPS) 10101
	
	// Output control line
	assign Rwe    = arithOP | arithiOP | lwOP | JalOP | SetxOP;  // write enable
	assign Rtar   = swOP | JrOP | BltOP | BneOP;                 // destination
	assign Rwd    = lwOP;                                        // write data (ALU or Dmem)
	assign DMwe   = swOP;                                        // Dmemory write enable
	assign ALUinB = arithiOP | lwOP | swOP;                      // ALU B port input
	
	// ALU operation code control
	assign addOP  = arithOP  & (~ALUopcode[4]) & (~ALUopcode[3]) & (~ALUopcode[2]) & (~ALUopcode[1]) & (~ALUopcode[0]);
	assign subOP  = arithOP  & (~ALUopcode[4]) & (~ALUopcode[3]) & (~ALUopcode[2]) & (~ALUopcode[1]) & ( ALUopcode[0]); 
	assign addiOP = arithiOP;
	assign ALUopctrl = (addiOP | addOP | swOP | lwOP) ? 5'd0 : (subOP ? 5'd1 : ALUopcode);
	
	// Overflow control
	assign Ovfctrl = {overflow & (addiOP | subOP), overflow & (addOP | subOP)};
	
endmodule
