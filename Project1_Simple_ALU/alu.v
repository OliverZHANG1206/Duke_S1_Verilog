module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;

   // YOUR CODE HERE //
	wire [31:0] data_add_result;         // add module output result
	wire [31:0] data_sub_result;         // sub module output result
	wire [5:0]  command;                 // hot-line command from ALUopcode [total 6 command] [command[0]->ADD, command[1]->SUB]
	wire add_overflow, sub_overflow;     // overflow bit
	wire sub_isNotEqual, sub_isLessThan; // not equal and less than sign
	
	
	// **Decoder for hot-line command**
	decoder cmd_hot_line(ctrl_ALUopcode, command);
	
	// **Implement operation unit**
	add      adder(data_operandA, data_operandB, data_add_result, add_overflow);
	subtract subtractor(data_operandA, data_operandB, data_sub_result, sub_overflow, sub_isNotEqual, sub_isLessThan);
	
	// **result mux**
	mux_2_to_1_32bit mux_result(command, data_add_result, data_sub_result, data_result);
	
	// **overflow mux**
	mux_2_to_1_1bit  mux_overflow(command, add_overflow, sub_overflow, overflow);
	
	// **isLessThan output**
	and buf_isLessThan(isLessThan, sub_isLessThan, command[1]);
	
	// **isNotEqual output**
	and buf_isNotEqual(isNotEqual, sub_isNotEqual, command[1]);
	
endmodule
