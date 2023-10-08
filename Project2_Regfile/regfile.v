module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);

   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;

   output [31:0] data_readRegA, data_readRegB;

   /* YOUR CODE HERE */
	genvar i;                    // variable for generate block
	wire [31:0] register [31:0]; // register array 32 32-bit register output
	wire [31:0] writeEnable;     // write command after ctrl_writeEnable
	wire [31:0] readEnableA, readEnableB, addressW; // ont-hot address for the regfile
	
	// **REGISTERS**
	generate
		for (i=1; i<32; i=i+1) 
		begin: register_group
			dff_32bit registers(register[i], data_writeReg, clock, writeEnable[i], ctrl_reset);
		end
   endgenerate
	// $0 is always zero: the D input is always 32-bit zeros
	dff_32bit register0(register[0], 32'h00000000, clock, writeEnable[0], ctrl_reset);
	
	// **READ**
	decoder drA(ctrl_readRegA, readEnableA);
	decoder drB(ctrl_readRegB, readEnableB);
	generate
		for (i=0; i<32; i=i+1)
		begin: Each_Register
			assign data_readRegA = readEnableA[i] ? register[i] : 32'hzzzzzzzz;
			assign data_readRegB = readEnableB[i] ? register[i] : 32'hzzzzzzzz;
		end
	endgenerate
	
	// **WRITE**
	decoder dw (ctrl_writeReg, addressW);
	assign writeEnable = addressW & {32{ctrl_writeEnable}};
	
endmodule
