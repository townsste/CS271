COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #1
	January 22, 2017
&

TITLE Program 1     (Program1.asm)

; Author: Stephen Townsend
; Course / Project ID                 Date: 1/22/17
; Description: 1.Display your name and program title on the output screen.
;			   2. Display instructions for the user.
;			   3. Prompt the user to enter two numbers.
;			   4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
;			   5. Display a terminating message.
;
;			   Extra Credit (Optional)
;			   1. Repeat until the user chooses to quit.
;			   2. Validate the second number to be less than the first.
;			   3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001.

INCLUDE Irvine32.inc

.data
	intro		BYTE	"Programming Assignment #1 by Stephen Townsend", 0

	extra1		BYTE	"**EC: Repeat until the user chooses to quit. ", 0
	extra2		BYTE	"**EC: Validate the second number to be less than the first ", 0
	
	
	inst1		BYTE	"In this program you will be asked to enter two numbers. ", 0
	inst2		BYTE	"Those numbers will go through the steps of being ", 0
	inst3		BYTE	"added, subtracted, multiplied, divided with a remainder ", 0
	

	prompt1		BYTE	"Please enter two numbers", 0
	prompt2		BYTE	"First number: ", 0
	prompt3		BYTE	"Second number: ", 0
	promptError BYTE	"Please enter a number that is less than first number: ", 0
	promptAgain BYTE	"If you would like to run again please press 1 or press any key to continue: ", 0	


	goodbye		BYTE	"Thank you for running the program.  Goodbye!", 0


	numberOne 	DWORD 	?				;get first number
	numberTwo 	DWORD 	?				;get second number


	sum 		DWORD 	0				;hold addition total
	diff 		DWORD 	0				;hold subtraction total
	prod 		DWORD 	0				;hold multiplication total
	quoti 		DWORD 	0				;hold division total
	remain 		DWORD 	0				;hold remainder


	sumOut		BYTE	"The sum is: ", 0
	diffOut		BYTE	"The difference is: ", 0
	prodOut		BYTE	"The product is: ", 0
	quotiOut	BYTE	"The quotient is: ", 0
	remainOut	BYTE	"The remainder is: ", 0


.code
main PROC
	
;NOTE:  call CrLf -- is used to display newlines for better output display

;INTRODUCTION
		mov		edx, OFFSET intro		;move intro to edx register
		call	WriteString	
		call	CrLf				
		call	CrLf					
		

;EXTRA CREDIT
		mov		edx, OFFSET extra1		;move extra1 to edx register
		call	WriteString
		call	CrLf					
		
		mov		edx, OFFSET extra2		;move extra2 to edx register
		call	WriteString
		call	CrLf					
		call	CrLf					


;INSTRUCTIONS
		mov		edx, OFFSET inst1		;move inst1 to edx register
		call	WriteString
		call	CrLf
		mov		edx, OFFSET inst2		;move inst2 to edx register
		call	WriteString
		call	CrLf
		mov		edx, OFFSET inst3		;move inst3 to edx register
		call	WriteString
		call	CrLf
		call	CrLf


;PROMPTS
	runAgain:							;label to jump back to.  Run the program again
		mov		edx, OFFSET prompt1		;move prompt1 to edx register
		call	WriteString
		call	CrLf
		call	CrLf
		
		mov		edx, OFFSET prompt2		;move prompt2 to edx register
		call	WriteString
		mov		edx, OFFSET numberOne
		call	ReadDec					;get input
		mov		numberOne, eax			;put eax register into numberOne
		call	CrLf

		mov		edx, OFFSET prompt3		;move prompt3 to edx register
		call	WriteString
		mov		edx, OFFSET numberTwo
		call	ReadDec					;get input
		cmp		eax, numberOne			;compare number two to number one
		jl		goodInput				;number two is less than one
		jge		inputVal				;number two is greater than one
		

;Validation
	inputVal:
		mov		edx, OFFSET promptError	
		call	WriteString				;Display error message for EC 2
		mov		edx, OFFSET numberTwo
		call	ReadDec					;get input
		cmp		eax, numberOne			;compare number two to number one
		jl		goodInput				;input is valid	numberTwo < numberOne
		jge		inputVal				;jump if numberTwo > numberOne

	goodInput:
		mov		numberTwo, eax			;put eax register into numberTwo
		call	CrLf


;Arithmetic
	;addition							
		mov		eax, numberOne			;move numberOne to the eax register
		add		eax, numberTwo			;add numberTwo to numberOne
		mov		sum, eax				;move the result in eax to sum
	
	;subtraction
		mov		eax, numberOne			;move numberOne to the eax register
		sub		eax, numberTwo
		mov		diff, eax				;move the result in eax to diff
					
	;multiplication
		mov		eax, numberOne			;move numberOne to the eax register
		mov		ebx, numberTwo			;move numberTwo to the ebx register
		mul		ebx						;multiply eax and ebx registers
		mov		prod, eax				;move the result in eax to prod

	;division & remainder
		mov		edx, 0					;initialize edx for division
		mov		eax, numberOne			;move numberOne to the eax register
		mov		ebx, numberTwo			;move numberTwo to the ebx register
		div		ebx						;divide eax and ebx registers
		mov		quoti, eax				;move the result in eax to quoti
		mov		remain, edx				;move the remainder of division from edx to remain
	

;Output Results
	;Addition
		mov		edx, OFFSET sumOut
		call	WriteString				;display "The sum is: "
		mov		eax, sum				;move sum to the eax
		call	WriteDec				;display sum in the eax register
		call	CrLf		
	
	;Subtraction
		mov		edx, OFFSET diffOut
		call	WriteString				;display "The difference is: "
		mov		eax, diff				;move diff to the eax
		call	WriteDec				;display diff in the eax register
		call	CrLf	
			
	;Multiplication
		mov		edx, OFFSET prodOut
		call	WriteString				;display "The product is: "
		mov		eax, prod				;move prod to the eax
		call	WriteDec				;display prod in the eax register
		call	CrLf		
		
	;Division
		mov		edx, OFFSET quotiOut
		call	WriteString				;display "The quotient is: "
		mov		eax, quoti				;move quoti to the eax
		call	WriteDec				;display quoti in the eax register
		call	CrLf			
				
	;Remainder
		mov		edx, OFFSET remainOut
		call	WriteString				;display "The remainder is: "
		mov		eax, remain				;move remain to the eax
		call	WriteDec				;display remain in the eax register
		call	CrLf					
		call	CrLf					


;Prompt to continue
		mov		edx, OFFSET promptAgain
		call	WriteString				;display for EC 1
		call	ReadDec					;get input
		call	CrLf					
		cmp		eax, 1					;compare eax input to 1
		je		runAgain				;eax == 1
	

;Exit Statement
		mov		edx, OFFSET goodbye
		call	WriteString
		call	CrLf

	exit	; exit to operating system
main ENDP

END main