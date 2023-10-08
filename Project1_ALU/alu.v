module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;

   // YOUR CODE HERE //
	wire [5:0]  command;                           // hot-line command from ALUopcode [total 6 command]
	wire [31:0] data_add_result, data_sub_result;  // add/sub module output result
	wire [31:0] data_and_result, data_or_result;   // AND/OR  module output result
	wire [31:0] data_sll_result, data_sra_result;  // SLL/SRA module output result
	wire add_overflow, sub_overflow;               // overflow bit
	wire sub_isNotEqual, sub_isLessThan;           // not equal and less than sign
	
	// **Decoder for hot-line command**
	decoder cmd_hot_line(ctrl_ALUopcode, command);
	
	// **Implement operation unit**
	add         adder       (data_operandA, data_operandB, data_add_result, add_overflow);
	subtract    subtractor  (data_operandA, data_operandB, data_sub_result, sub_overflow, sub_isNotEqual, sub_isLessThan);
	Bitwise_AND bitwise_and (data_operandA, data_operandB, data_and_result);
	Bitwise_OR  bitwise_or  (data_operandA, data_operandB, data_or_result);
	sll         Shift_left  (data_operandA, ctrl_shiftamt, data_sll_result);
	sra         Shift_right (data_operandA, ctrl_shiftamt, data_sra_result);
	
	// **result mux**
	mux_6_to_1_32bit mux_result(command, data_add_result, data_sub_result, 
										          data_and_result, data_or_result, 
										          data_sll_result, data_sra_result, data_result);
	
	// **overflow mux**
	mux_2_to_1_1bit  mux_overflow(command, add_overflow, sub_overflow, overflow);
	
	// **isLessThan output**
	and buf_isLessThan(isLessThan, sub_isLessThan, command[1]);
	
	// **isNotEqual output**
	and buf_isNotEqual(isNotEqual, sub_isNotEqual, command[1]);
	
endmodule
