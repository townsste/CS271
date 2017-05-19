COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #2
	January 29, 2017
&

;Program 2     (Program2_Townsend.asm)

; Author: Stephen Townsend
; CS271-400 / Program #2                 Date: 1/29/17
; Description: Write a program to calculate Fibonacci numbers.
;				• Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;				• Prompt the user to enter the number of Fibonacci terms to be displayed. Advise the user to enter 
;						an integer in the range [1 .. 46].
;				• Get and validate the user input (n).
;				• Calculate and display all of the Fibonacci numbers up to and including the nth term. 
;						The results should be displayed 5 terms per line with at least 5 spaces between terms.
;				• Display a parting message that includes the user’s name, and terminate the program.
;
;				Extra Credit (Optional)
;				1. Display the numbers in aligned columns.
;				2. Do something incredible.
;						source: http://programming.msjc.edu/asm/help/source/irvinelib/settextcolor.htm


INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
	
	intro		BYTE	"Programming Assignment #2 - Fibonacci by Stephen Townsend", 0
	
	extra1		BYTE	"**EC: Do something incredible - Green Text", 0
		

	askName		BYTE	"Please enter your name: "
	userName	BYTE 21 DUP(0)
	byteCount	DWORD	?

	userIntro1	BYTE	"Hello ", 0
	userIntro2	BYTE	", it is a pleasure to meet you.", 0

	
	instruct	BYTE	"Please enter an integer from 1 - 46: ", 0
	rangeError	BYTE	"I am sorry, I cannot use that", 0

	userInput	DWORD	?
	
	n			DWORD	0
	nPlus1		DWORD	1

	spacer		BYTE	"     ", 0
	lineCounter	DWORD	0

	userOutro	BYTE	"Thank you for calculating Fibonacci's Sequence, ", 0

	UPPERLIMIT	= 46
	LOWERLIMIT	= 1

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
		call	CrLf	
	


;USER INSTRUCTIONS
;Talk to user
		mov		edx, OFFSET askName	
		call	WriteString
		mov		edx, OFFSET userName
		mov		ecx, SIZEOF	userName	;specify max characters
		call	ReadString
		mov		ecx, SIZEOF	userName	;specify max characters



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

	Validate:
		mov		edx, OFFSET instruct
		call	WriteString
		call	ReadDec
        cmp     eax, UPPERLIMIT
        ja      Invalid
        cmp     eax, LOWERLIMIT
        jb      Invalid
		call	CrLf
		mov		ecx, eax				;loop counter based on user input
        jmp		Fibonacci				;Continue

	Invalid:
		call	CrLf
        mov     edx, OFFSET rangeError
        call    WriteString
        call    CrLf
        jmp     Validate



;DISPLAYFIBS

;Arithmetic - F (sub) n = F (sub) n-1 + F (sub) n-2
Fibonacci:
		mov		eax, n					;move n to eax register
		mov		ebx, nPlus1				;move nPlus1 to ebx register
		add		eax, ebx				;add the eax and ebx registers
		mov		n, ebx					;move ebx (nPlus1) to n
		mov		nPlus1, eax				;move eax (addition) to nPlus1
		jmp		Output

Output:
		mov		eax, n					;move n to eax register for resulting
		call	WriteDec				;output eax register
		mov		edx, OFFSET spacer		;call output spacer
		call	WriteString				;output to console
		inc		lineCounter
		cmp		lineCounter, 5
		je		Nextline
		loop	Fibonacci				;loop based on user limit in ecx register

		Nextline:
		call	CrLf
		mov		lineCounter, 0
		dec		ecx
		cmp		ecx, 0
		jg		Fibonacci				;loop based on user limit in ecx register



;FAREWELL
		call	CrLf
		mov		edx, OFFSET userOutro
		call	WriteString
		mov		edx, OFFSET userName
		call	WriteString
		call	CrLf
	
	exit	; exit to operating system
main ENDP

END main
