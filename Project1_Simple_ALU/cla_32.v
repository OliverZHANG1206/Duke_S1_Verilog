module cla_32(in1, in2, cin, sum, cout, overflow);

	input [31:0] in1, in2;   // 8-bit data
	input cin;               // carry-in
	
	output [31:0] sum;       // output sum
	output overflow;         // overflow check
	output cout;             // carry out
	
	wire [3:0] p, g, ovf;    // generation, propagation, carry-out, overflow in first level
	wire [2:0] p1g;          // p(i+1)*g(i)
	wire [1:0] p2g;          // p(i+2)*p(i+2)*g(i)
	wire p3g;                // p(i+3)*p(i+2)*p(i+1)*g(i)
	wire c08, c16, c24;      // carry-out for byte on second level
	wire p1c, p2c, p3c, p4c; // p0c0 p1p0c0 p2p1p0c0 .. p4p3p2p1p0c0
	
	cla_8 byte1(in1[07:00], in2[07:00], cin, sum[07:00], p[0], g[0], ovf[0]);
	cla_8 byte2(in1[15:08], in2[15:08], c08, sum[15:08], p[1], g[1], ovf[1]);
	cla_8 byte3(in1[23:16], in2[23:16], c16, sum[23:16], p[2], g[2], ovf[2]);
	cla_8 byte4(in1[31:24], in2[31:24], c24, sum[31:24], p[3], g[3], ovf[3]);
	
	// Generate p(i+1)*g(i) .. p(i+2)*..*g(i)
	genvar i;
	generate
		for (i=0; i<=2; i=i+1)
		begin: g_p1g
			and ap1g(p1g[i], p[i+1], g[i]);
		end
		
		for (i=0; i<=1; i=i+1)
		begin: g_p2g
			and ap2g(p2g[i], p[i+2], p[i+1], g[i]);
		end
	endgenerate
	
	and ap3g(p3g, p[3], p[2], p[1], g[0]);
	
	// Generate p0c0 p1p0c0 p2p1p0c0 .. p7p6p5p4p3p2p1p0c0
	and ap1c(p1c, p[0], cin);
	and ap2c(p2c, p[1], p[0], cin);
	and ap3c(p3c, p[2], p[1], p[0], cin);
	and ap4c(p4c, p[3], p[2], p[1], p[0], cin);
	
	// Generate look ahead carry bit
	or c1(c08, g[0], p1c);
	or c2(c16, g[1], p1g[0], p2c);
	or c3(c24, g[2], p1g[1], p2g[0], p3c);
	
	// Generate final output (for isNotEqual use)
	or co(cout, g[3], p1g[2], p2g[1], p3g, p4c);
	
	// Check 32bit overflow
	assign overflow = ovf[3];

endmodule
