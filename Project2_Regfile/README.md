# Project: Regfile Design

**NetID:** yz845   **Name:** Yunfan Zhang   **Course:** ECE550D   **Date:** 04/10/2023

---

## Content

1. Regfile Structure Overview

2. Write

3. Read

4. Decoder

5. D-FF

---

## 1. Regfile Structure Overview

**a) The overall files in this project checkpoint 3 include:**

- regfile.v: This is the top-level design of the regfile

- decoder.v: This is the decoder for 5-bit command extend 32-bit one-hot command

- dffe.v: This is a 32-bit register array

**b) The general structure of my top-level Regfile includes 3 parts:** 

- A register array that connnect with write port and read ports

- Three decoders that are for decoding the write address and read address

- Tristate buffer for controlling output 

**c) Input and Output**

|**Port Name**|**Input/output**|**Description**|
|-|-|-|
|clock|Input|Clock signal|
|ctrl_writeEnable|Input|Enable wire for controlling write reg|
|ctrl_reset|Input|Signal for reseting all registers  |
|ctrl_writeReg[4:0]|Input|Address for writing reg|
|ctrl_readRegA[4:0]|Input|Address for reading regA|
|ctrl_readRegB[4:0]|Input|Address for reading regB|
|data_writeReg[31:0]|Input|Data need to be write into the regfile|
|data_readRegA[31:0]|Output|Data need to be read from the regfile|
|data_readRegB[31:0]|Output|Data need to be read from the regfile|

**d) Procedure and Description**

My Regfile would consist of 3 parts, including the decoder, the tri-state buffer, and the register arrays. For writing operations, the ctrl_writeReg would use a decoder to transfer to one-hot command and then AND with the ctrl_writeEnable to select which 32-bit register to write, then update them using data_writeReg for the next clock cycle. For reading operation, the decoder would use ctrl_readRegA/B to get a one-hot command and then use it as the control signal for the tristate buffer to select which data should be output to data_readRedA/B.

**Note:** The \$0 should be always 0. There are many ways to achieve this. It could be either do not enable 'en' for DFF; directly assign 32-bit zero for input of tristate or only have 32-bit input zero for DFF.  In this case, to keep the same Filpflop characters and still keep the \$0 zero, I have chosen the input of \$0 to be 32-bit zero. Even if there is write command, the \$0 would only update 0.

---

## 2. Write

The write operation requires the address of the register and the 32-bit value that needs to be stored in the register. The decoder would first decode the address into a one-hot command. Then, the command would have an AND operation with the ctrl_writeEnable to ensure the write command is activated. Then the data would be write into the register in the next clock cycle.

```Verilog
decoder dw (ctrl_writeReg, addressW);
assign writeEnable = addressW & {32{ctrl_writeEnable}};
```

## 3. Read

The read operation requires the same items as write for each 32-bit data. The decoder would first decode the address into a one-hot command. Then, it would be used for the tri-state buffer to select the output. The A and B are in the same structure.

```Verilog
decoder drA(ctrl_readRegA, readEnableA);
decoder drB(ctrl_readRegB, readEnableB);
generate
  for (i=0; i<32; i=i+1)
  begin: Each_register
    assign data_readRegA = readEnableA[i] ? register[i] : 32'hzzzzzzzz;
    assign data_readRegB = readEnableB[i] ? register[i] : 32'hzzzzzzzz;
  end
endgenerate
```

## 4. Decode

The decoder could be considered as a shift-left logic starting from 0x00000001. For example, if the address of the register is 00111, it is a similar operation as the 0x00000001 shift left 7 bits. Thus, the decoder would be very easy to achieve as:

```Verilog
assign shift0 = 32'h00000001;
assign shift1 = ctrl_bit[0] ? {shift0[30:0], 1'b0}     : shift0;
assign shift2 = ctrl_bit[1] ? {shift1[29:0], 2'b00}    : shift1;
assign shift4 = ctrl_bit[2] ? {shift2[27:0], 4'h0}     : shift2;
assign shift8 = ctrl_bit[3] ? {shift4[23:0], 8'h00}    : shift4;
assign line   = ctrl_bit[4] ? {shift8[15:0], 16'h0000} : shift8;
```

## 5. DFF

D-flipflop in this project has the 'clr' and 'en' for controlling it. The clr is an active High trigger, thus all the dff would become zero if the 'clr' signal trigger to high. The 'en' is the write enable signal as the DFF could only update the new value only if the en is high, otherwise, the data stored in the DFF would always remain the same without any modification.

```Verilog
// Set value of q on positive edge of the clock or clear
always @(posedge clk or posedge clr) 
begin
  // If clear is high, set q to 0
  if (clr) 
    q <= 32'h00000000;
  // If enable is high, set q to the value of d 
  else if (en) 
    q <= d;
  // If enable is low, the q remain the same
  else
	q <= q;
end
```

