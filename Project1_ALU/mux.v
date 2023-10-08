module mux_2_to_1_1bit(command, in1, in2, out);
    
	 input [5:0] command; // hot-line command
	 input in1, in2;       // input for mux
	 
	 output out;           // output select
	 
	 assign out = command[1] ? in2 : in1;
	 
endmodule

module mux_6_to_1_32bit(command, in1, in2, in3, in4, in5, in6, out);
    
	 input [5:0] command;                       // hot-line command
	 input [31:0] in1, in2, in3, in4, in5, in6; // input for mux
	 
	 output [31:0] out;                         // output select
	 
	 wire [31:0] mux1, mux2, mux3, mux4;
	 
	 assign mux1 = command[1] ? in2 : in1;
	 assign mux2 = command[2] ? in3 : mux1;
	 assign mux3 = command[3] ? in4 : mux2;
	 assign mux4 = command[4] ? in5 : mux3;
	 assign out  = command[5] ? in6 : mux4;
	 
endmodule
