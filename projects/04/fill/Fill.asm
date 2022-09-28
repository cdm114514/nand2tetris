// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

	// while(true)	
(INF_LOOP)

	// tmp = st
	@SCREEN
	D=A
	@tmp
	M=D

	// if([kbd]==0) fill white
	// else         fill black
	@KBD
	D=M
	@PRESSED
	D;JNE

(NOT_PRESSED)
	// if(tmp==ed) goto INF_LOOP
	@tmp
	D=M
	@24576
	D=D-A
	@INF_LOOP
	D;JEQ

	// *tmp = 0
	@tmp
	A=M
	M=0
	// tmp = tmp + 1
	@tmp
	M=M+1

	@NOT_PRESSED
	0;JMP

(PRESSED)
	// if(tmp==ed) goto INF_LOOP
	@tmp
	D=M
	@24576
	D=D-A
	@INF_LOOP
	D;JEQ

	// *tmp = -1
	@tmp
	A=M
	M=-1
	// tmp = tmp + 1
	@tmp
	M=M+1

	@PRESSED
	0;JMP