module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);

	///////////////////////////// Port Declarations ///////////////////////////// 
   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;

   output [31:0] data_readRegA, data_readRegB;

   ///////////////// Internal Wires and Registers Declarations /////////////////
	genvar i;                    // variable for generate block
	wire [31:0] register [31:0]; // register array 32 32-bit register output
	wire [31:0] writeEnable;     // write command after ctrl_writeEnable
	wire [31:0] readEnableA, readEnableB, addressW; // ont-hot address for the regfile
	
	// **REGISTERS**
	generate
		for (i=1; i<32; i=i+1) 
		begin: register_group
			dffe_32bit registers(register[i], data_writeReg, clock, writeEnable[i], ctrl_reset);
		end
   endgenerate
	// $0 is always zero: the D input is always 32-bit zeros
	dffe_32bit register0(register[0], 32'h00000000, clock, writeEnable[0], ctrl_reset);
	
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

module decoder(ctrl_bit, line);
	// input address
	input [4:0] ctrl_bit;
	
	// ouput parallel wire
	output [31:0] line;
	
	// shift left wire
	wire [31:0] shift0, shift1, shift2, shift4, shift8;
	
	// The decoder is like a shift left logic start with 0x00000001
	assign shift0 = 32'h00000001;
	assign shift1 = ctrl_bit[0] ? {shift0[30:0], 1'b0}     : shift0;
	assign shift2 = ctrl_bit[1] ? {shift1[29:0], 2'b00}    : shift1;
	assign shift4 = ctrl_bit[2] ? {shift2[27:0], 4'h0}     : shift2;
	assign shift8 = ctrl_bit[3] ? {shift4[23:0], 8'h00}    : shift4;
	assign line   = ctrl_bit[4] ? {shift8[15:0], 16'h0000} : shift8;
	
endmodule
