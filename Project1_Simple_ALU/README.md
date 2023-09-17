# Project: Simple ALU Design

**NetID:** yz845   **Name:** Yunfan Zhang   **Course:** ECE550D   **Date:** 09/17/2023


## Content

1. ALU Structure Overview

2. Add Operation

3. Subtract Operation

4. Overflow Flag

5. isLessThan Flag

6. isNotEqual Flag

7. Decoder

8. Mux


## 1. ALU Structure Overview

**a) The overall files in this project checkpoint 1 include:**

- alu.v: This is the top-level design of the ALU

- add.v: This is the 32-bit adder with an overflow flag

- sub.v: This is the 32-bit subtractor with an overflow flag, isLessThan flag, isNotEqual flag

- decoder.v: This is a decoder that decodes the ALU operation code into hot-line format

- mux.v: This file includes multiplexer(s) that could use hot-line code to switch output result 

- cla_8.v: This is the Carry Lookahead 8-bit adder implementation

- cla_32.v: This is the Carry Lookahead 32-bit second hierarchy adder implementation

**b) The general structure of my top-level ALU includes 3 parts:** 

- A decoder to transfer the ALU operation code into the hot-line coding format. 

- Numerous operation blocks (ADD, SUBTRACT, etc.)

- Mux which uses hot-line command for output result data and overflow sign

**c) Input and Output**

|**Port Name**|**Input/output**|**Description**|
|-|-|-|
|data_operandA[31:0]|Input|First data operand Input|
|data_operandB[31:0]|Input|Second data operand Input|
|ctrl_ALUopcode[4:0]|Input|ALU command code |
|ctrl_shiftmat[4:0]|Input|Shift amount for SLL and SRA operations|
|data_result[31:0]|Output|Operation Result output|
|isNotEqual|Output|Flag - two data are not equal in subtraction|
|isLessThan|Output|Flag - dataA is less than dataB in subtraction|
|overflow|Output|Flag - overflow when add or subtract|

**d) Procedure and Description**

My ALU would run 2 operations (ADD & SUBTRACT) together. The operation result would be in the wire 'data_add_result' and 'data_sub_result' respectively. A decoder was used to transfer the command code into the hot-line coding format and then this would be used in mux to select which result needs to be output. Mux would also be used in overflow output.

**Note:** The reason why I have created these files is that it would be much easier to create a hierarchy for the project, making it more readable and easier for future development. I do not know if the future (for example, checkpoint 2) needs to implement more commands in the ALU, so I make sure it could be future updated. The design of this ALU may not be the best solution, as the subtraction and addition operation could be implemented using only 1 block. The isNotEqual and isLessThan is very easy to achieve, thus I have added these function into the project even if it is not required for checkpoint 1.

---

## 2. Add Operation

The adder I used is the hierarchical CLA. The first level is the 8-bit CLA adder. The second level is the 4 8-bit CLA adder block. The look-ahead ability for each bit carried out requires the previous bits 'propagation' and 'generation'. The propagate function (p) is the OR of two input bits and the generate function (G) is the AND of two input bits. For each carry-out in each bit, it is calculated as:

$$
c_1=g_0+p_0c_0\\c_2=g_1+p_1g_0+p_1p_0c_0\\c_3=g_2+p_2g_1+p_2p_1g_0+p_2p_1p_0c_0\\c_4=g_3+p_3g_2+p_3p_2g_1+p_3p_2p_1g_0+p_3p_2p_1p_0c_0\\...
$$
The SUM for each bit is still XOR for input 2 bit and the previous carry-out bit:
$$
s_i=A_i \oplus B_i \oplus c_{i-1}
$$
To build the second level CLA, it requires the final P and G for each 8-bit CLA, which are:
$$
P=p_7p_6p_5p_4p_3p_2p_1p_0\\G=g_7+p_7g_6+p_7p_6g_5+...+p_7p_6p_5p_4p_3p_2p_1c_0
$$
Then, each 8-bit CLA block would have a second-level carry-out as:
$$
c_8=G_0+P_0c_0\\c_{16}=G_1+P_1G_0+P_1P_0c_0\\c_{24}=G_2+P_2G_1+P_2P_1G_0+P_2P_1P_0c_0\\c_{32}=G_3+P_3G_2+P_3P_2G_1+P_3P_2P_1G_0+P_4P_3P_2P_1c_0
$$
The result is directly output from 4 8-bit CLA blocks. The overall gate-time delay would be approximately 8 gates delay, which is much faster than the 32 gates delay of an RCA design.

## 3. Subtract Operation

The subtract operation would also use the 32-bit CLA adder. The basic idea is that A - B = A - (-B) = A - (~B) + 1. Thus, for subtraction, the NOT gate would used to reverse each bit in B and then set carry-in to 1 in the adder.

## 4. Overflow Flag

Overflow is determined after subtraction and addition operations. It has accomplished the checking when in 32-bit CLA (first level) design. If the carry_in of the last bit is not equal to the carry_out of the last bit, there is an overflow happened. Simply achieved by:

```Verilog
xor (overflow, CO, CI); // CO and CI is the carry-out and carry-in for the MSB/Sign bit
```

## 5. IsLessThan Flag

isLessThan flag is also determined after the subtraction. It could be achieved by checking the overflow bit and the sign bit. Basically, if A < B, then A - B < 0, which indicates that A is less than B if the sign bit is '1'. However, if the subtraction encounters an overflow problem, it turns to the opposite situation. This is because A - B is still less than 0 but due to the overflow problem the output result became 'positive'. Thus, the sign bit should be '0' to prove A is less than B when having overflow. 

```Verilog
xor (isLessThan, overflow, result[31]); // result[31] is the sign bit
```

## 6. isNotEqual Flag

isNotEqual flag is also not difficult to achieve. Considering if A = B, then A - B = 0. Thus, the not equal flag could check whether the result is 0 and then reverse it. However, to achieve the sign bit equal to 0, there are only two situations: There is a carry-out '1' for the sign bit addition or the subtrahend and minuend(after 1's complement) are both positive. The second situation is not possible, cause it will never let other bits result in 0, even have overflow. Thus, the equal flag should have the result = 0 and the carry-out should be 0. The 'Not Equal' is the opposite of the 'Equal' It could be achieved by:

```Verilog
nor (result_nor, result[0], result[1] ... result[31]); 
nand (isNotEqual, result_nor, cout); // 'result' is the sustration result
```

**Note:** The code is slightly different from the above code, as bitwise OR 32-bit written in Verilog is either too long or has fan-in problems. Thus I have bitwise OR each 8-bit and then OR the combined 4-bit.  

## 7. Decoder

The decoder for operation code to hot-line command is in a simple structure and only requires brute force. As there is a 5-bit opcode, there are 32 commands maximum in total. The ADD command would let 'command[0]' become 1 and the others become '0'. Use the NOT gate to get the opposite logic for each opcode digit, and combine them directly according to the opcode format.

```Verilog
// Example SUBTRACT Operation '00001' -> command[1]
and (command[1], n_opcode[4], n_opcode[3], n_opcode[2], n_opcode[1], opcode[0]);
// n_opcode is the reverse of opcode
```

## 8. Mux

N-to-1 Mux is easy to implement when having a hot-line command and simple 2-to-1 mux. The selector for each mux is the hot-line command and every 2-to-1 mux can manage one input. For example, if we have a total of 4 commands with hot-line 'command[3:0]' and to build a 4-to-1 mux with input 'in[3:0]', it could be implemented by:

```Verilog
assign mux1 = command[1] ? in[1] : in[0];
assign mux2 = command[2] ? in[2] : mux1;
assign out  = command[3] ? in[3] : mux2;
```

**Note:** In this checkpoint, as there are only two commands, the mux block, and decoder block is very simple. It should be noted that upgrading the mux and decoder would be much easier if we tried to have more commands.

