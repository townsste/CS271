COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #3
	February 12, 2017
&

;Program 3     (Program3_Townsend.asm)

; Author: Stephen Townsend
; CS271-400 / Program #3                 Date: 2/12/17
; Description: Write a program to calculate Fibonacci numbers.
;				• Display the program title and programmer’s name.
;				• Get the user’s name, and greet the user.
;				• Display instructions for the user.
;				• Repeatedly prompt the user to enter a number. Validate the user input to be in [-100, -1] (inclusive). 
;					Count and accumulate the valid user numbers until a non-negative number is entered. (The non-negative number is discarded.)
;				• Calculate the (rounded integer) average of the negative numbers.
;				• Display:
;					i. the number of negative numbers entered (Note: if no negative numbers were entered, display a special message and skip to iv.)
;					ii. the sum of negative numbers entered
;					iii. the average, rounded to the nearest integer (e.g. -20.5 rounds to -20)
;					iv. a parting message (with the user’s name)
;
;				Extra Credit (Optional)
;				1. Number the lines during user input.
;				2. Calculate and display the average as a floating-point number, rounded to the nearest .001.
;				3. Do something astoundingly creative.



INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

	intro		BYTE	"Programming Assignment #3 - Integer Accumulator by Stephen Townsend", 0
	
	extra1		BYTE	"**EC: Number the lines during user input", 0
	extra2		BYTE	"**EC: Do something astoundingly creative - Results Displayed in Calculator", 0
		

	askName		BYTE	"Please enter your name: "
	userName	BYTE 21 DUP(0)
	byteCount	DWORD	?

	userIntro1	BYTE	"Hello ", 0
	userIntro2	BYTE	", it is a pleasure to meet you.", 0

	instruct	BYTE	"Please enter integers from -100 to -1", 0
	instruct2	BYTE	"Once finished, enter a non-negative number to see the sum and average of your valid inputs.", 0
	range		BYTE	"Range [-100 , -1]", 0
	rangeError	BYTE	"Out of Range", 0
	calcResult	BYTE	"I will now calculate with your valid inputs.", 0

	sum			SDWORD	0
	average		SDWORD	0
	remainder	SDWORD	0
	inputCount	DWORD	0
	rowNumber	DWORD	1

	fiveSpace	BYTE	"     ", 0
	rowSpace	BYTE	". ", 0

	dispValidInput	BYTE	"Valid input ", 0
	dispSum			BYTE	"Sum is  ", 0
	dispAvg			BYTE	"Avg is  ", 0

	noValidInput	BYTE	"There were no valid inputs to calculate.", 0

	userOutro	BYTE	"Thank you for using my calculator, ", 0

	UPPERLIMIT	= -1
	LOWERLIMIT	= -100


	calculatorUpper		BYTE	"    ____________________ ", 0
	calculatorUp1		BYTE	"   |  ________________  |", 0
	
	calculatorMiddleIn	BYTE	"   | | ", 0
	calculatorMiddleOut BYTE	" | | ", 0						
	
	calculatorLower 	BYTE	"   | |				| |", 0
	calculatorLo1		BYTE	"   | |________________| |", 0
	calculatorLo2		BYTE	"   |  ___ ___ ___  ___  |", 0
	calculatorLo3		BYTE	"   | | 7 | 8 | 9 || / | |", 0
	calculatorLo4		BYTE	"   | | 4 | 5 | 6 || x | |", 0
	calculatorLo5		BYTE	"   | | 1 | 2 | 3 || - | |", 0
	calculatorLo6		BYTE	"   | | . | 0 | = || + | |", 0
	calculatorLo7		BYTE	"   |____________________|", 0

	spacerFour			BYTE	"    ", 0
	spacerThree			BYTE	"   ", 0
	spacerTwo			BYTE	"  ", 0
	spacerOne			BYTE	" ", 0

	posCounter			DWORD	0


; (insert variable definitions here)

.code
main PROC

		mov		eax, green
		call	setTextColor

;NOTE:  call CrLf -- is used to display newlines for better output display


;INTRODUCTION
		mov		edx, OFFSET intro		;move intro to edx register
		call	WriteString	
		call	CrLf				
		call	CrLf			


	;extra credit
		mov		edx, OFFSET extra1		;move extra1 to edx register
		call	WriteString
		call	CrLf
		mov		edx, OFFSET extra2		;move extra2 to edx register
		call	WriteString
		call	CrLf				
		call	CrLf	
	


;USER INSTRUCTIONS
	;TALK TO USER
		mov		edx, OFFSET askName	
		call	WriteString
		mov		edx, OFFSET userName
		mov		ecx, SIZEOF	userName		;specify max characters
		call	ReadString
		mov		ecx, SIZEOF	userName		;specify max characters


	;GETUSERDATA
		call	CrLf
		mov		edx, OFFSET userIntro1
		call	WriteString
		mov		edx, OFFSET userName
		call	WriteString
		mov		edx, OFFSET userIntro2
		call	WriteString
		call	CrLf
		call	CrLf


		mov		edx, OFFSET instruct
		call	WriteString
		call	CrLf

		mov		edx, OFFSET instruct2
		call	WriteString
		call	CrLf

	;CHECK RANGE
	Validate:
		mov		edx, OFFSET fiveSpace
		call	WriteString
		mov		eax, rowNumber
		call	WriteDec
		mov		edx, OFFSET rowSpace
		call	WriteString
		inc		rowNumber
		call	ReadInt						;Read User Integer
        cmp     eax, UPPERLIMIT				;Compare With -1
        jg      FinishedInput				;Pos Number
        cmp     eax, LOWERLIMIT				;Compare With -100
        jb      Invalid						;Not In Range
        jmp		Valid						;In Range

	;NOT IN RANGE
	Invalid:		
		call	CrLf
        mov     edx, OFFSET rangeError
        call    WriteString
		call	CrLf
		dec		rowNumber
		mov		edx, OFFSET range
		call	WriteString
		call	CrLf
        jmp     Validate

	;IN RANGE
	Valid:
		;ARITHMETIC - ADDITION		
		add		eax, sum
		mov		sum, eax
		inc		inputCount
		jmp		Validate					;Check Range

	
	;USER ENTERED POSITIVE NUMBER
	FinishedInput:
		cmp		inputCount, 0
		je		NoValues					;No Valid Inputs
	

	;ARITHMETIC - DIVISION	
		mov		eax, sum
		CDQ
		mov		ebx, inputCount
		idiv	ebx
		mov		average, eax
		mov		remainder, edx
		neg		remainder
		mov		eax, remainder
		mov		eax,		inputCount
		shr		eax,		1                   ;halves the total
		cmp		eax,		remainder              ;checks to see if the remainder in over half the halved total
		jge		Display
		mov		eax, average
		add		eax, -1                         ;adds negative 1 to round up
		mov		average, eax


	;DISPLAY RESULTS
	Display:
		call	CrLf
		mov		edx, OFFSET calcResult
		call	WriteString
		call	CrLf
		call	CrLf
		

	;DISPLAY TOP OF CALCULATOR
		mov		edx, OFFSET	calculatorUpper
		call	WriteString
		call	CrLf
		mov		edx, OFFSET	calculatorUp1
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	calculatorMiddleIn
		call	WriteString


		;Section - VALID INPUTS
		mov		edx, OFFSET dispValidInput
		call	WriteString
		mov		eax, inputCount
		call	WriteDec

		cmp		inputCount, 10
		jge		SumOutsideDispJump
		mov		edx, OFFSET spacerOne
		call	WriteString

		
		;Section - SUM
;-----------------------------------------------------
	SumOutsideDispJump:	;Continue to SUM
		mov		edx, OFFSET	calculatorMiddleOut
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	calculatorMiddleIn
		call	WriteString

		;DISPLAY SUM
		mov		edx, OFFSET dispSum
		call	WriteString
		mov		eax, sum
		call	WriteInt

		inc		posCounter		;Add one to position in sequence counter

		;CHECK NUMBER OF DIGITS
		cmp		sum, -9
		jge		addFour			;Jump to add four spaces

		cmp		sum, -99
		jge		addThree		;Jump to add three spaces

		cmp		sum, -999
		jge		addTwo			;Jump to add two spaces

		cmp		sum, -9999
		jge		addOne			;Jump to add one spaces

		
		;Section - AVERAGE
;-----------------------------------------------------
	AvgOutsideDispJump:	;Continue to AVERAGE
		mov		edx, OFFSET	calculatorMiddleOut
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	calculatorMiddleIn
		call	WriteString

		;DISPLAY AVERAGE
		mov		edx, OFFSET dispAvg
		call	WriteString
		mov		eax, average
		call	WriteInt
		
		inc		posCounter		;Add one to position in sequence counter

		;CHECK NUMBER OF DIGITS
		cmp		average, -9
		jge		addFour			;Jump to add four spaces
		
		cmp		average, -99
		jge		addThree		;Jump to add three spaces

		cmp		average, -999
		jge		addTwo			;Jump to add two spaces

		cmp		average, -9999
		jge		addOne			;Jump to add one spaces
		


		;SPACERS TO ADD TO END POSIITON IN DISPLAY
;-----------------------------------------------------
		addFour:
			mov		edx, OFFSET spacerFour
			call	WriteString
			cmp		posCounter, 1
			je		AvgOutsideDispJump
			jmp		FinishOutsideDispJump
			
		addThree:
			mov		edx, OFFSET spacerThree
			call	WriteString
			cmp		posCounter, 1
			je		AvgOutsideDispJump
			jmp		FinishOutsideDispJump

		addTwo:
			mov		edx, OFFSET spacerTwo
			call	WriteString
			cmp		posCounter, 1
			je		AvgOutsideDispJump
			jmp		FinishOutsideDispJump

		addOne:
			mov		edx, OFFSET spacerOne
			call	WriteString
			cmp		posCounter, 1
			je		AvgOutsideDispJump
			jmp		FinishOutsideDispJump
;-----------------------------------------------------

	FinishOutsideDispJump:
			mov		edx, OFFSET	calculatorMiddleOut
			call	WriteString
			call	CrLf

;DISPLAY LOWER CALC
;-----------------------------------------------------
		mov		edx, OFFSET calculatorLo1
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo2
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo3
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo4
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo5
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo6
		call	WriteString
		call	CrLf

		mov		edx, OFFSET calculatorLo7
		call	WriteString
		call	CrLf
		call	CrLf
;-----------------------------------------------------

		jmp		Terminate					;Exit Program With Outro


	;NO VALID INPUTS
	NoValues:								
		call	CrLf
		mov		edx, OFFSET noValidInput
		call	WriteString
		call	CrLf
		call	CrLf


	;EXIT PROGRAM WITH OUTRO
	Terminate:									
		mov		edx, OFFSET userOutro
		call	WriteString
		mov		edx, OFFSET userName
		call WriteString
		call	CrLf
		call	CrLf

; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
