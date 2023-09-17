module mux_2_to_1_1bit(command, in1, in2, out);
    
	 input [5:0] command; // hot-line command
	 input in1, in2;       // input for mux
	 
	 output out;           // output select
	 
	 // Wire mux1, mux2... for future more operation
	 
	 // Cause now there is only 2 operation
	 assign out = command[1] ? in2 : in1;
	 
endmodule

module mux_2_to_1_32bit(command, in1, in2, out);
    
	 input [5:0] command;   // hot-line command
	 input [31:0] in1, in2; // input for mux
	 
	 output [31:0] out;     // output select
	 
	 // Wire mux1, mux2... for future more operation
	 // Cause now there is only 2 operation
	 assign out = command[1] ? in2 : in1;
	 
endmodule
