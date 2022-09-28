// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

// Put your code here.
// use binary lifting, 32 add operation in total

    // bit = 1, bit becomes 0 when overflow
	@bit
	M=1     
    // ans = 0
	@R2
	M=0     
(LOOP)
    // if(bit==0) goto END
	@bit
	D=M
	@STOP
	D;JEQ

	// if((R0&bit)!=0) ans = ans + R1
    @R0
    D=M
    @bit
    D=D&M

    @IS_ZERO
    D;JEQ
    @R1
    D=M
    @R2
    M=D+M
(IS_ZERO)
	// bit <<= 1, R1 <<= 1
    @bit
    D=M
    M=D+M

    @R1
    D=M
    M=D+M

	@LOOP
	0;JMP
(END)
	@END
	0;JMP

