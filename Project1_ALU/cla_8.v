module cla_8(in1, in2, cin, sum, pout, gout, ovf);

	input [7:0] in1, in2; // 8-bit data
	input cin;            // carry-in
	
	output [7:0] sum;     // output sum
	output pout, gout;    // p and g for second-level CLA (32-bit)
	output ovf;           // overflow check
	
	wire [7:0] g, p;      // p0-6 and g0-6
	wire [7:0] c;         // carry-out for each bit
	wire [6:0] p1g;       // p(i+1)*g(i)
	wire [5:0] p2g;       // p(i+2)*..*g(i)
	wire [4:0] p3g;       // p(i+3)*..*g(i)
	wire [3:0] p4g;       // p(i+4)*..*g(i)
	wire [2:0] p5g;       // p(i+5)*..*g(i)
	wire [1:0] p6g;       // p(i+6)*..*g(i)
	wire p7g;             // p(i+7)*..*g(i)
	wire p1c, p2c, p3c, p4c, p5c, p6c, p7c, p8c; // p0c0 p1p0c0 p2p1p0c0 .. p7p6p5p4p3p2p1p0c0
	
	// Generate block
	genvar i;
	generate
		// Generate propagate and generate function for each bit
		for (i=0; i<=7; i=i+1) 
		begin: p_and_g
			and ag(g[i], in1[i], in2[i]);
			or  op(p[i], in1[i], in2[i]);
		end
		
		// Generate output sum for each bit
		for (i=1; i<=7; i=i+1)
		begin: g_sum
			xor gsum(sum[i], in1[i], in2[i], c[i-1]);
		end
		
		// Generate p(i+1)*g(i) .. p(i+6)*..*g(i)
		for (i=0; i<=6; i=i+1)
		begin: g_p1g
			and ap1g(p1g[i], p[i+1], g[i]);
		end
		
		for (i=0; i<=5; i=i+1)
		begin: g_p2g
			and ap2g(p2g[i], p[i+2], p[i+1], g[i]);
		end
		
		for (i=0; i<=4; i=i+1)
		begin: g_p3g
			and ap3g(p3g[i], p[i+3], p[i+2], p[i+1], g[i]);
		end
		
		for (i=0; i<=3; i=i+1)
		begin: g_p4g
			and ap4g(p4g[i], p[i+4], p[i+3], p[i+2], p[i+1], g[i]);
		end
		
		for (i=0; i<=2; i=i+1)
		begin: g_p5g
			and ap5g(p5g[i], p[i+5], p[i+4], p[i+3], p[i+2], p[i+1], g[i]);
		end
		
		for (i=0; i<=1; i=i+1)
		begin: g_p6g
			and ap6g(p6g[i], p[i+6], p[i+5], p[i+4], p[i+3], p[i+2], p[i+1], g[i]);
		end
	endgenerate
	
	xor gsum(sum[0], in1[0], in2[0], cin);
	and ap7g(p7g, p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
	
	// Generate p0c0 p1p0c0 p2p1p0c0 .. p7p6p5p4p3p2p1p0c0
	and ap1c(p1c, p[0], cin);
	and ap2c(p2c, p[1], p[0], cin);
	and ap3c(p3c, p[2], p[1], p[0], cin);
	and ap4c(p4c, p[3], p[2], p[1], p[0], cin);
	and ap5c(p5c, p[4], p[3], p[2], p[1], p[0], cin);
	and ap6c(p6c, p[5], p[4], p[3], p[2], p[1], p[0], cin);
	and ap7c(p7c, p[6], p[5], p[4], p[3], p[2], p[1], p[0], cin);
	and ap8c(p8c, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], cin);
	
	// Generate look ahead carry bit
	or c1(c[0], g[0], p1c);
	or c2(c[1], g[1], p1g[0], p2c);
	or c3(c[2], g[2], p1g[1], p2g[0], p3c);
	or c4(c[3], g[3], p1g[2], p2g[1], p3g[0], p4c);
	or c5(c[4], g[4], p1g[3], p2g[2], p3g[1], p4g[0], p5c);
	or c6(c[5], g[5], p1g[4], p2g[3], p3g[2], p4g[1], p5g[0], p6c);
	or c7(c[6], g[6], p1g[5], p2g[4], p3g[3], p4g[2], p5g[1], p6g[0], p7c);
	or co(c[7], g[7], p1g[6], p2g[5], p3g[4], p4g[3], p5g[2], p6g[1], p7g, p8c);
	
	// Assign output cout, pout, gout, overflow
	xor ov(ovf, c[6], c[7]);
	and po(pout, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0]);
	or  go(gout, g[7], p1g[6], p2g[5], p3g[4], p4g[3], p5g[2], p6g[1], p7g);
	
endmodule
