COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #6B
	March 19, 2017
&

;Program 6B     (Program6B_Townsend.asm)

; Author: Stephen Townsend
; CS271-400 / Program #6B                 Date: 3/19/17
; Description: Write a program.
;				A system is required for statistics students to use for drill and practice in combinatorics. 
;				In particular, the system will ask the student to calculate the number of combinations of r 
;				items taken from a set of n items (i.e., nCr ). The system generates random problems with n 
;				in [3 .. 12] and r in [1 .. n]. The student enters his/her answer, and the system reports 
;				the correct answer and an evaluation of the student’s answer. The system repeats until the 
;				student chooses to quit.
;
;				Extra Credit (Optional)
;				1. You may gain 1 additional point by numbering each problem and keeping score. When the 
;						student quits, report number right/wrong, etc.
;				2. You may gain 2 additional points by computing factorials in the floating point unit to 
;						expand the limits.


INCLUDE Irvine32.inc

	NMAX = 13			;Max user input
	NMIN = 3			;Min user input

.data

	intro			BYTE	"Programming Assignment #6B - Combinatorics by Stephen Townsend", 0
	
	extra1			BYTE	"**EC: None", 0

	problem			BYTE	"Problem: ", 0
	problem1		BYTE	"Number of elements in the set: ", 0
	problem2		BYTE	"Number of elements to choose from the set: ", 0
		
	instruct		BYTE	"How many ways can you choose? ", 0
	rangeError		BYTE	"Please enter a positive intiger", 0

	randN			DWORD	0
	randR			DWORD	0
	valNR			DWORD	0

	nFact			DWORD	0
	rFact			DWORD	0
	nrFact			DWORD	0

	userString		BYTE	10 DUP(0)
	userAnswer		DWORD	?

	actualAnswer	DWORD	0

	dispResult		BYTE	"There are ", 0
	dispResult1		BYTE	" combinations of ", 0
	dispResult2		BYTE	" items from a set of ", 0

	correct			BYTE	"You are correct!", 0
	wrong			BYTE	"You need more practice.", 0

	runAnother		BYTE	"Another problem? (y/n): ", 0
	userResponse	BYTE	15 DUP(0)
	responseError	BYTE	"Invalid response. ", 0
	yesResponse		BYTE	"y, Y", 0
	noResponse		BYTE	"n, N", 0

	userOutro		BYTE	"Thank you for using my combinations statistic generator.", 0

;NOTE:  call CrLf -- is used to display newlines for better output display

;String display macro to display strings ---------------------

WriteBuffer MACRO	buffer
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx
ENDM


.code
main PROC
	call	Randomize					;Random Seed
	mov		eax, green
	call	setTextColor

	call	introduction				;Intro Procedure Call

RunAgain:
	push	OFFSET valNR
	push	OFFSET randN
	push	OFFSET randR
	call	showProblem					;showProblemProcedure Call


	push	OFFSET userAnswer
	call	getData						;Get User Data Procedure Call

	mov		ecx, randN

	push	OFFSET nFact
	push	randN
	call	combinations				;Factorial N Procedure Call

	mov		ecx, randR

	push	OFFSET rFact
	push	randR
	call	combinations				;Factorial R Procedure Call

	mov		ecx, valNR

	push	OFFSET nrFact
	push	valNR
	call	combinations				;Factorial N-R Procedure Call

	push	OFFSET actualAnswer
	push	nrFact
	push	rFact
	push	nFact
	call	calculation					;Calculate formula Procedure Call

	push	actualAnswer
	push	userAnswer
	push	randR
	push	randN
	call	showResults					;showResults Procedure Call
	call	CrLf	

	call	anotherRun					
	cmp		ecx, 1
	je		RunAgain

	WriteBuffer userOutro
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
	WriteBuffer	intro			
	call	CrLf
	call	CrLf

;extra credit
	WriteBuffer	extra1			
	call	CrLf
	call	CrLf

	ret	 
introduction ENDP	


COMMENT *
							showProblem PROC 
This procedure is used to show the problem that the user will solve.

Inputs: None
Output: None
Post Condition:  A problem is generated with random integers
*

;showProblem: generates the random numbers and displays the problem
;• showProblem accepts addresses of n and r.

showProblem PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]
	mov		ebx, 0
	mov		ecx, 0

	;Stack Frame
	;0	;ebp
	;4	;@return
	;8	;randR
	;12	;randN

;RANDOM NUMBER GENERATOR-------------------
RandomN:		
	mov		eax, NMAX
	call	RandomRange
	call	validateRandom		
	cmp		ebx, 0				;Check if valid input 0 = FALSE
	je		RandomN

	mov		[edi], eax
	mov		edi, [ebp+8]
	add		eax, 1				;add one for random (Random is n-1)
	mov		ebx, 0
	jmp		RandomR

Reset:
	pop		ebx
	pop		eax
	
RandomR:						
	push	eax
	push	ebx
	call	RandomRange
	call	validateRandom
	cmp		ebx, 0				;Check if valid input 0 = FALSE
	je		Reset

	mov		[edi], eax
	pop		ebx
	mov		ebx, eax

;DISPLAYING PROBLEM-----------------------
	
	WriteBuffer	problem
	call	CrLf
	
	pop		eax
	sub		eax, 1
	
	WriteBuffer	problem1
	call	WriteDec
	call	CrLf
	
	mov		eax, ebx
	WriteBuffer	problem2
	call	WriteDec
	call	CrLf
	call	CrLf

	mov		edi, [ebp+16]
	mov		eax, ecx
	sub		eax, ebx
	mov		[edi], eax

;EXITING PROCEDURE------------------------
	pop		ebp
	ret		9
showProblem ENDP


COMMENT *
							validateRandom PROC 
This procedure is used to validate the random integers.  The range is compared
	against the MAX and MIN limits.  1 = TRUE (Valid) and 0 = FALSE (Invalid).  
	Invalid options will not be put into array.

Inputs: None
Output: None
Post Condition:  Valid or Invalid option
*
validateRandom PROC
	cmp		ecx, 2						;R
	jg		JumpR

	cmp     eax, NMAX					;Compare With 12
	ja      Invalid						;Not In Range
	cmp     eax, NMIN					;Compare With 3
	jb      Invalid						;Not In Range
	mov		ebx, 1						;Set valid input 1 = TRUE
	mov		ecx, eax					;Put N into ecx to move on to R
	ret

	JumpR:
	cmp     eax, 1						;Compare With 1
	jb      Invalid						;Not In Range
	mov		ebx, 1						;Set valid input 1 = TRUE
	ret

Invalid:								;Out of range
	ret
validateRandom ENDP


COMMENT *
							getData PROC 
This procedure is used to determine how much of the array will be used.

Inputs: User defined integer
Output: Direstions on the required input
Pre Condition:  None
Post Condition:  Displayed instructions to user and read their input
*
getData PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+8]		;@UserR in edi
	mov		eax, 0
	mov		[edi], eax

Loop1:
	WriteBuffer	instruct
	mov		edx, OFFSET userString
	mov		ecx, 9
	call	ReadString
	mov		ecx, eax
	mov		esi, OFFSET userString

Loop2:
	mov		ebx, [ebp+8]
	mov		eax, [ebx]
	mov		ebx, 10
	mul		ebx
	
	mov		ebx, [ebp+8]
	mov		[ebx], eax
	mov		al, [esi]
	cmp		al, 48
	jl		invalid

	cmp		al, 57
	jg		invalid

	inc		esi
	sub		al, 48
		
	mov		ebx, [ebp+8]
	add		[ebx], al

	loop	Loop2
	jmp		Exiting

invalid:
	WriteBuffer	rangeError
	call	CrLf
	call	CrLf
	jmp		Loop1

Exiting:
	call	CrLf
	pop		ebp
	ret		8
getData ENDP


COMMENT *
							combinations PROC 
This procedure is used to recursively factoral the value passed in.

Inputs: None
Output: None
Pre Condition:  Value to be factorialed is passed in
Post Condition:  Recursively factoraled
*
;Calculator to check value
;https://www.mathsisfun.com/combinatorics/combinations-permutations-calculator.html

;Referenced: Assembly Language for x86 Processors Seventh Edition (Pg 304)

combinations PROC
	push	ebp
	mov		ebp, esp
	
	;Stack Frame
	;0	;ebp
	;4	;@return
	;8	;rand
	;12	;@actualAnswer

	mov		eax,[ebp+8]		
	cmp		eax,0				;compare to 0 to see if at end of factoral
	ja		Loop1				;keep running factoral
	mov		eax,1				;finished factoral
	jmp		Loop2				;return to prev call

Loop1: 
	dec		eax
	push	eax					;Factorial(passed in reference)
	call	combinations

;recursive return
	mov		ebx,[ebp+8]				
	mul		ebx	
	cmp		ebx, ecx
	je		PutInAddress

Loop2: 
	pop ebp						
	ret 4					

PutInAddress:
	mov		edi, [ebp+12]
	mov		[edi], eax
	pop		ebp						; return EAX
	ret		5						; clean up stack

combinations ENDP


COMMENT *
							combinations PROC 
This procedure is used to calculate the combinations formula with the values
		that have been factoraled.  Formula: n!/r!(n-r)!

Inputs: None
Output: None
Pre Condition:  Factoral values are passed in
Post Condition:  Calculate the problems solution
*
calculation PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+20]

;Check if answer is one -----------------
	mov		eax, [ebp+8]
	mov		ebx, [ebp+12]
	cmp		eax, ebx				;check to see if values are the same.  Answer will be one
	je		AnsIsOne

;Lower formula --------------------------
	mov		eax, [ebp+12]
	mov		ebx, [ebp+16]
	mul		ebx

;Upper formula divied by lower ----------
	mov		ebx, eax
	mov		eax, [ebp+8]
	div		ebx

	mov		[edi], eax
	jmp		Exiting

AnsIsOne:							;Calculation had issues with n and r being the same number
	mov		eax, 1					;The result will be one.
	mov		[edi], eax

Exiting:
	pop		ebp	
	ret		13
calculation ENDP


COMMENT *
							showResults PROC 
This procedure is used to show the results of the problem to the user.

Inputs: None
Output: None
Pre Condition:  User inputed something
Post Condition:  Valid or Invalid option
*
showResults PROC
	push	ebp
	mov		ebp, esp
	
	WriteBuffer	dispResult
	mov		eax, [ebp+20]			;The calculated solution
	call	WriteDec

	WriteBuffer	dispResult1
	mov		eax, [ebp+8]			;N
	call	WriteDec

	WriteBuffer	dispResult2
	mov		eax, [ebp+12]			;R
	call	WriteDec
	call	CrLf

	mov		eax, [ebp+16]			;Users Guess
	mov		ebx, [ebp+20]			;The calculated solution
	cmp		eax, ebx
	je		CorrectAns
	jmp		WrongAns

CorrectAns:
	WriteBuffer	correct				;Correct Answer
	call	CrLf
	jmp		Exiting

WrongAns:
	WriteBuffer	wrong				;Wrong Answer
	call	CrLf
	jmp		Exiting

Exiting:
	pop		ebp
	ret		15
showResults ENDP


COMMENT *
							showResults PROC 
This procedure is used check if the user wants to run the program again.

Inputs: Y or N
Output: Question to run again
Pre Condition:  None
Post Condition:  Valid or Invalid option
*
anotherRun PROC
Asking:
	WriteBuffer	runAnother
	mov		edx, OFFSET userResponse			;user response
	mov		ecx, 14								;max characters
	call	ReadString							;get user response

	mov		esi, OFFSET userResponse			;The user string into esi
	mov		edi, OFFSET yesResponse				;Yes string to coninue in edi
	cmpsb										;Compare strings
	mov		ecx, 1								;yes to continue
	je		Exiting								;if yes, Exit procedure			
	
	mov		esi, OFFSET userResponse			;The user string into esi
	mov		edi, OFFSET noResponse				;No string to coninue in edi
	cmpsb										;Compare strings
	mov		ecx, 0								;no to continue
	je		Exiting								;if no, Exit procedure	

	WriteBuffer	responseError					;Invalid string
	call CrLf
	jmp		Asking	

Exiting:
	call	CrLf
	ret
anotherRun ENDP

END main