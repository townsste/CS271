COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #4
	February 19, 2017
&

;Program 4     (Program4_Townsend.asm)

; Author: Stephen Townsend
; CS271-400 / Program #4                 Date: 2/19/17
; Description: Write a program to display composite numbers.
;				• Write a program to calculate composite numbers. 
;				• First, the user is instructed to enter the number of composites to be displayed, 
;					and is prompted to enter an integer in the range [1 .. 400]. 
;				• The user enters a number, n, and the program verifies that 1 ? n ? 400. 
;				• If n is out of range, the user is re-prompted until s/he enters a value in the specified range. 
;				• The program then calculates and displays all of the composite numbers up to and including the nth composite. 
;				• The results should be displayed 10 composites per line with at least 3 spaces between the numbers.
;
;				Extra Credit (Optional)
;				1) Align the output columns.
;				2) Display more composites, but show them one page at a time. The user can “Press any key to continue …” to view the next page. 
;					Since length of the numbers will increase, it’s OK to display fewer numbers per line.
;				3) One way to make the program more efficient is to check against only prime divisors, which requires saving all of the primes 
;					found so far (numbers that fail the composite test). It’s easy in a high-level language, but you will have to look ahead in 
;					the textbook to figure out how to do it in assembly language.


INCLUDE Irvine32.inc

	UPPERLIMIT	= 400
	LOWERLIMIT	= 1

.data

	intro			BYTE	"Programming Assignment #4 - Composite Numbers by Stephen Townsend", 0
	
	extra1			BYTE	"**EC: Align the output columns", 0
		
	instruct		BYTE	"Enter the number of composites to display from 1 to 400: ", 0
	range			BYTE	"Range [1 , 400]", 0
	rangeError		BYTE	"Out of Range", 0
	
	userInput		DWORD	?
	curCompos		DWORD	4			;Smallest Composite Number
	divider			DWORD	2			;Smallest diviser that is useful.
	status			DWORD	0			;TRUE(1) or FALSE(0) Based on if a number was found

	oneSpace		BYTE	" ", 0
	twoSpace		BYTE	"  ", 0
	threeSpace		BYTE	"   ", 0
	fourSpace		BYTE	"    ", 0
	fiveSpace		BYTE	"     ", 0
	lineCount		DWORD	0	
	precedSpace		DWORD	0

	userOutro		BYTE	"Thank you for looking for composite numbers.", 0

;NOTE:  call CrLf -- is used to display newlines for better output display

.code
main PROC

		mov		eax, green
		call	setTextColor

		call	introduction			;Procedure Call
		call	getUserData				;Procedure Call
		call	showComposites			;Procedure Call
		call	CrLf
		call	CrLf
		call	farewell				;Procedure Call
		call	CrLf
		call	CrLf
	exit	; exit to operating system
main ENDP


COMMENT *
							introduction PROC 
This procedure is used to display the programs intro to the user.

Inputs: None
Output: Program Title and Extra Credit used
Pre Condition:  None
Post Condition:  Displayed intro message to user
*
introduction PROC
		mov		edx, OFFSET intro		;move intro to edx register
		call	WriteString	
		call	CrLf				
		call	CrLf			


	;extra credit
		mov		edx, OFFSET extra1		;move extra1 to edx register
		call	WriteString
		call	CrLf				
		call	CrLf
		ret
introduction ENDP	
	

COMMENT *
							getUserData PROC 
This procedure is used to get the number of composite numbers to show to the user.

Inputs: DWORD (Int)
Output: Direstions on the required input
Pre Condition:  None
Post Condition:  Displayed instructions to user and read their input
*
getUserData PROC
	Loop1:
		mov		edx, OFFSET instruct
		call	WriteString
		call	ReadInt						;Read User Integer
		call	CrLf

		call	validate
		cmp		ebx, 0						;Check if valid input 0 = FALSE
		je		Loop1

		ret
getUserData ENDP

	
COMMENT *
							validate PROC 
This procedure is used to validate the users input.  The input is compared
	against the UPPER and LOWER limits.  1 = TRUE (Valid) and 0 = FALSE (Invalid)

Inputs: None
Output: No output if valid and Invalid Output if invalid
Pre Condition:  User inputed something
Post Condition:  Valid or Invalid option
*
validate PROC
        cmp     eax, UPPERLIMIT				;Compare With 400
		ja      Invalid						;Not In Range
        cmp     eax, LOWERLIMIT				;Compare With 1
        jb      Invalid						;Not In Range
		mov		userInput, eax
		mov		ebx, 1						;Set valid input 1 = TRUE
		ret

	Invalid:
        mov     edx, OFFSET rangeError
        call    WriteString
		call	CrLf
		call	CrLf
		mov		ebx, 0						;Set invalid input 0 = FALSE
		ret
validate ENDP


COMMENT *
							showComposites PROC 
This procedure is used to direct the output of the 
	against the UPPER and LOWER limits.  1 = TRUE (Valid) and 0 = FALSE (Invalid)

Inputs: None
Output: None
Pre Condition:  User Entered a valid input
Post Condition:  Procedure moves variables into registers and calls isComposite
*
showComposites PROC
		
		mov		eax, CurCompos				;Move 4 into eax,  4 is smallest composite
		mov		ecx, userInput				;Move user input into ecx to determine loop executions

		mov		edx, OFFSET twoSpace		;Call proceeding two spaces for the first time
		call	WriteString

	Continue:
		mov		ebx, divider				;Move 2 into ebx to start the lowest usable division number
		call	isComposite					;Procedure call
		cmp		status, 0					;Check if composite was found
		je		Continue					;No number was found.  Loop back to Continue
		
		mov		eax, CurCompos				;Move current comp number into eax.
		call	WriteDec
		call	spaces
		inc		CurCompos					;Increment eax to a new number
		mov		status, 0					;Reset status to false
		inc		lineCount	 
		cmp		lineCount, 10				;Check if need a new line
		je		NewLine						;Need a newline
		loop	Continue					;Continue the loop
		ret

		NewLine:
		call	CrLf
		mov		lineCount, 0				;Reset newline count
		inc		precedSpace					;Need to add space to begining of line
		call	spaces						;Procedure call
		loop	Continue					;Continue the loop
showComposites ENDP


COMMENT *
							spaces PROC 
This procedure is used to add spaaces based on specific conditions.  This will allow
	for the program to display the results in a column format. 

Inputs: None
Output: Spaces
Pre Condition:  Composite Number was found
Post Condition:  Spaces added after the composite number
*
spaces PROC
		cmp		ecx, 1						;Check if last loop
		je		None						;No spaces needed
		cmp		precedSpace, 1				;Check if there is a new line
		je		One							;Add a space for new lines with numbers > 9
		cmp		eax, 9						;Check if < 9
		jl		Four						;Add four spaces
		cmp		eax, 99						;Check if < 99
		jl		Three						;Add three spaces
		jmp		Two							;Add two spaces
		
	Four:
		mov		edx, OFFSET fourSpace
		call	WriteString
		ret

	Three:
		mov		edx, OFFSET threeSpace
		call	WriteString
		ret

	Two:
		mov		edx, OFFSET twoSpace
		call	WriteString
		ret

	One:
		cmp		eax, 100
		jg		None
		mov		edx, OFFSET oneSpace
		call	WriteString
		dec		precedSpace					;Added space to new line decrement precedSpace
		ret
	
	None:
		dec		precedSpace					;Decrement precedSpace
		ret
spaces ENDP


COMMENT *
							isComposite PROC 
This procedure is used to check if a number is a composite number.  The first 
	composite is 4 and uses 2 to divide by.  The divisor will be increased each
	loop until the number is determined to be a composite.

Inputs: None
Output: None
Pre Condition:  Valid input
Post Condition:  Determined if a composite number or not.
*
isComposite PROC	
	Check:
		mov		eax, CurCompos				;Move Current number into eax
		cmp		eax, ebx					;If == to divisor then it is not a composite
		je		NotComposite

		cdq
		div		ebx
		cmp		edx, 0
		je		CompositeFound				;No Remainder. Composite number
		jne		MoreTesting					;Remainder, but may be a composite number

	MoreTesting:
		inc		ebx							;Increment divisor
		jmp		Check

	CompositeFound:
		mov		status, 1					;Change status to true
		ret

	NotComposite:
		inc		CurCompos					;Increment CurCompos to check new number
		mov		status, 0
		ret
isComposite ENDP


COMMENT *
							isComposite PROC 
This procedure is used to display a farewell message to the user.

Inputs: None
Output: Farewell
Pre Condition:  Displayed the designated number of composites to the user.
Post Condition:  Finish the program
*
farewell PROC
		mov		edx, OFFSET userOutro
		call	WriteString
		ret
farewell ENDP

END main
