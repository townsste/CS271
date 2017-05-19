COMMENT &
	Stephen Townsend
	townsste@oregonstate.edu
	CS271-400
	Program #5
	March 5, 2017
&

;Program 5     (Program5_Townsend.asm)

; Author: Stephen Townsend
; CS271-400 / Program #5                 Date: 3/5/17
; Description: Write a program.
;				• Introduce the program.
;				• Get a user request in the range [min = 10 .. max = 200].
;				• Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.
;				• Display the list of integers before sorting, 10 numbers per line.
;				• Sort the list in descending order (i.e., largest first).
;				• Calculate and display the median value, rounded to the nearest integer.
;				• Display the sorted list, 10 numbers per line.
;
;				Extra Credit (Optional)
;				1. Display the numbers ordered by column instead of by row.
;				2. Use a recursive sorting algorithm (e.g., Merge Sort, Quick Sort, Heap Sort, etc.).
;				3. Implement the program using floating-point numbers and the floating-point processor.
;				4. Generate the numbers into a file; then read the file into the array.
;				5. Others?


INCLUDE Irvine32.inc

	MAX = 200			;Max user input
	MIN	= 10			;Min user input

	HI = 1000			;Random will be HI-1 (1000 - 1 = 999)
	LO = 100			;Lowest random number

.data

	intro			BYTE	"Programming Assignment #5 - Random Sorted Numbers by Stephen Townsend", 0
	
	extra1			BYTE	"**EC: None", 0
		
	instruct		BYTE	"Enter the amount of random numbers to display from 10 to 200: ", 0
	range			BYTE	"Range [10 , 200]", 0
	rangeError		BYTE	"Out of Range", 0

	nonSorted		BYTE	"Non Sorted Array", 0
	sorted			BYTE	"Sorted Array", 0
	
	arrList			DWORD	MAX		DUP(?)	;Array Initialization
	arrUsed			DWORD	?				;Amount of array to use
	
	status			DWORD	0				;TRUE(1) or FALSE(0) Based on if a number was found

	dispMedian		BYTE	"The Median is: ", 0
	
	twoSpace		BYTE	"  ", 0

	lineCount		DWORD	0	
	precedSpace		DWORD	0

	userOutro		BYTE	"Thank you for looking for random numbers.", 0

;NOTE:  call CrLf -- is used to display newlines for better output display

.code
main PROC
		call	Randomize				;Random Seed
		mov		eax, green
		call	setTextColor

		push	OFFSET intro
		push	OFFSET extra1
		call	introduction			;Intro Procedure Call
		
		push	OFFSET rangeError
		push	OFFSET instruct
		push	OFFSET arrUsed
		call	getData					;Get User Data Procedure Call

		;call	CreateOutputFile
		

		push	OFFSET arrList
		push	arrUsed
		call	fillArray				;Fill Array Procedure Call


		mov		edx, OFFSET nonSorted
		call	WriteString
		call	CrLf


		push	OFFSET twoSpace
		push	OFFSET arrList
		push	arrUsed
		call	displayList				;Display Array Procedure Call


		push	OFFSET arrList
		push	arrUsed
		call	sortList				;Sort Array Procedure Call
		call	CrLf

		push	OFFSET	dispMedian
		push	OFFSET arrList
		push	arrUsed
		call	displayMedian			;Display Array Median Procedure Call
		
		
		call	CrLf
		call	CrLf
		mov		edx, OFFSET sorted
		call	WriteString	
		call	CrLf


		push	OFFSET twoSpace
		push	OFFSET arrList
		push	arrUsed
		call	displayList				;Display Array Procedure Call
		call	CrLf
		call	CrLf

		push	OFFSET userOutro
		call	farewell				;Farewell Procedure Call
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
		push	ebp
		mov		ebp, esp

		mov		edx, [ebp+12]		;move intro to edx register
		call	WriteString	
		call	CrLf				
		call	CrLf			


	;extra credit
		mov		edx, [ebp+8]		;move extra1 to edx register
		call	WriteString
		call	CrLf				
		call	CrLf
		
		pop		ebp
		ret		2 
introduction ENDP	


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
		mov		edi, [ebp+8]		;@ArrSize in edi

	Loop1:
		mov		edx, [ebp+12]
		call	WriteString
		call	ReadInt				;Read User Integer
		call	CrLf

		call	validateInput
		cmp		ebx, 0				;Check if valid input 0 = FALSE
		je		Loop1

		mov		[edi], eax			;Move eax into arrSize address

		pop		ebp
		ret		9
getData ENDP

	
COMMENT *
							validate PROC 
This procedure is used to validate the users input.  The input is compared
	against the UPPER and LOWER limits.  1 = TRUE (Valid) and 0 = FALSE (Invalid)

Inputs: None
Output: No output if valid and Invalid Output if invalid
Pre Condition:  User inputed something
Post Condition:  Valid or Invalid option
*
validateInput PROC
		push	ebp
		mov		ebp, esp

        cmp     eax, MAX					;Compare With 200
		ja      Invalid						;Not In Range
        cmp     eax, MIN					;Compare With 10
        jb      Invalid						;Not In Range
		mov		ebx, 1						;Set valid input 1 = TRUE
		jmp		ExitValidation

	Invalid:
        mov		edx, [ebp+24]				;RangeError
        call    WriteString
		call	CrLf
		call	CrLf
		mov		ebx, 0						;Set invalid input 0 = FALSE
		
	ExitValidation:
		pop ebp
		ret
validateInput ENDP


COMMENT *
							fillArray PROC 
This procedure is used to fill the array, to a certain point designated
	by the user, with random integers.

Inputs: None
Output: None
Pre Condition:  User inputed the amount of the array to use
Post Condition:  The array is filled with random integers
*
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]			;@list in edi
	mov		ecx, [ebp+8]			;value of count into ecx  
	mov		eax, 1

	Fill:							;LOOP To fill array by calling random number
	mov		eax, HI
	call	RandomRange
	call	validateRandom
	cmp		ebx, 0					;Check if valid input 0 = FALSE
	je		Fill

	mov		[edi], eax
	add		edi, 4					;next array element
	loop	fill

	pop		ebp
	ret		8
fillArray ENDP


COMMENT *
							displayList PROC 
This procedure is used to display the arrays contents to the user.

Inputs: None
Output: Contents of array
Pre Condition:  Array is randomly filled
Post Condition:  The contents are displayed to the console
*
displayList PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]				;@list in edi
	mov		ecx, [ebp+8]				;value for counter into ecx  
	mov		ebx, 0
	
	More:
		mov		eax, [edi]				;Move array element into eax
		call	WriteDec
		mov		edx, [ebp+16]			;Add two spaces between elements
		call	WriteString
		add		edi, 4					;Next array element
		inc		ebx						;Inc newline counter
		cmp		ebx, 10					;Check for newline
		je		NewLine
		loop	More

	NewLine:
		call	CrLf
		mov		ebx, 0					;Reset counter
		cmp		ecx, 0					;Check if finished
		je		Finish
		loop	More

	Finish:
	pop		ebp
	ret		9
displayList ENDP


COMMENT *
							validateRandom PROC 
This procedure is used to validate the random integers.  The range is compared
	against the Hi and LO limits.  1 = TRUE (Valid) and 0 = FALSE (Invalid).  
	Invalid options will not be put into array.

Inputs: None
Output: None
Pre Condition:  User inputed a valid integers for array size
Post Condition:  Valid or Invalid option
*
validateRandom PROC
		cmp     eax, HI						;Compare With 999
		ja      Invalid						;Not In Range
        cmp     eax, LO						;Compare With 100
        jb      Invalid						;Not In Range
		mov		ebx, 1						;Set valid input 1 = TRUE
		ret

	Invalid:
		mov		ebx, 0						;Set invalid input 0 = FALSE
		ret
validateRandom ENDP


COMMENT *
							sortList PROC 
This procedure is used to sort the array.  This will check for the highest
	integer and swap the current element with the highest in its loop.

Inputs: None
Output: None
Pre Condition:  Filled array is passed in by reference
Post Condition:  The array is sorted from highest to lowest
*
sortList PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]			;Loop Counter
	mov		edi, [ebp+12]
	mov		esi, ecx				;Array starting position
	add		esi, 1					;Incriment Loop by one to keep current array position
	dec 	ecx 					;Decrease Counter by 1
	mov		ebx, 0					;Clear ebx
	mov		edx, 0					;Clear edx

	OuterLoop:
		dec		esi					;Decrement for next array position
		push	ecx					;Push outerloop counter into stack
		push	edi					;Push current edi position into stack
		mov		eax, [edi]			;Move array element into eax to compare
		cmp		ecx, 0				;Check if end of loop
		je		EndSort				;Jump to end if ewual to 0

	InnerLoop:
		mov		ebx, [edi + 4]		;Move next element to comapre into ebx
		cmp		ebx, eax			;Compare ebx and eax
		jg		Greater				;Jump to Greater if ebx is higher
		add		edi, 4				;Add 4 to edi to move to next element in array
		loop	innerLoop			;Loop back to InnerLoop
		jmp		swap				;End of loop jump to swap

	Greater:
		mov		eax, ebx			;Move the higher element into eax to compare
		push	ebx					;Push ebx into stack so that the ebx's location in array can be calulated
		mov		ebx, esi			;Move the size of current array used into ebx
		sub		ebx, ecx			;Subtract the current counter ecx with ebx to get the high element location
		mov		edx, ebx			;Move location to edx
		pop		ebx					;Restore ebx back to array element
		add		edi, 4				;Add 4 to edi to move to next element in array
		loop	InnerLoop

	Swap:
		pop		edi					;Restore edi to remove the added bytes from InnerLoop and Greater
		cmp		edx, 0				;Check if there are elements to swap (edx > 0)
		je		reset				;If no element then jump to reset
		call	exchange			;Call Exchange to swap elements in array
		
	Reset:
		pop		ecx					;Restore the OuterLoop counter
		mov		edx, 0				;Reset edx to 0 to determine swap element
		add		edi, 4				;Move edi to next element in array
		loop	OuterLoop			;Loop back to OuterLoop

	EndSort:
		pop		ebp					;Restore ebp
		ret		4					;Return

sortList ENDP


COMMENT *
							exchange PROC 
This procedure is used in conjunction with sortList.  Exchange is only
	used to swap two elements in the array.

Inputs: None
Output: None
Pre Condition:  User inputed something
Post Condition:  Valid or Invalid option
Registers: eax (hold array element 1), 
		   ebx(hold array element 2), 
		   edi(holds array element location)
*
exchange PROC

		mov		ebx, [edi]			;Move current start element into ebx,  eax holds current highest element
		mov		[edi], eax			;Swap the higher element into the old location of the lower one
		mov		[edi+edx*4], ebx	;Swap the lower element into the old location of the higher one

		ret
exchange ENDP


COMMENT *
							validate PROC 
This procedure is used to calculate and display the mean value
	in the randomly filled array

Inputs: None
Output: Mean
Pre Condition:  Passed in the array
Post Condition:  Calculate and display the mean
Registers: eax (hold array elements, location and median), 
		   ebx(hold array element 2 location), 
		   ecx(divider by 2), 
		   edx(dispMedian address)
		   edi(holds array element location)
*
displayMedian PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]			;@list in edi
	mov		eax, [ebp+8]			;value of count into ecx  
	mov		ecx, 2

	test	eax, 1					;Test most significant bit
	jz		EvenSize
	
	OddSize:
		div		ecx					;Divide eax by 2 to get middle
		mov		eax, [edi+eax*4]	;Move middle element into eax
		jmp		Display				;Jump to display

	EvenSize:
		div		ecx					;Divide eax by 2 to get middle
		mov		ebx, eax			;Move a copy of middle to eax
		sub		ebx, 1				;Subtract to ebx to get element to add to eax
		mov		eax, [edi+eax*4]	;Move element 1 into eax
		add		eax, [edi+ebx*4]	;Add element 2 to eax
		div		ecx					;Divide result of eax by 2 to get median
		jmp		Display

	Display:
		mov		edx, [ebp+16]		;Move dispMedian into edx
		call	WriteString
		call	WriteDec
		
		pop		ebp
		ret		5
displayMedian ENDP


COMMENT *
							farewell PROC 
This procedure is used to display a farewell message to the user.

Inputs: None
Output: Farewell
Pre Condition:  Displayed the designated number of composites to the user.
Post Condition:  Finish the program
Registers: edx (hold Outro address), 
*
farewell PROC
	push	ebp
	mov		ebp, esp
	
	mov		edx, [ebp+8]
	call	WriteString
	
	pop ebp
	ret 1
farewell ENDP

END main