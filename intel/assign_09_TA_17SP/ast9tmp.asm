;  CS 218 - Assignment 9
;  Functions Template.

; ============================================================================
;  Write assembly language functions.

;  * Function rdTriNum() to read an unsigned tridecimal number
;    from the user (STDIN), perform error checking and ASCII to
;    integer conversion.

;  * Function selectionSort() sorts the numbers into descending
;    order (large to small).  Uses the selection sort algorithm
;    (from asst #7).

;  * Function listStats() finds the minimum, median, and maximum, for a
;    list of numbers.  Note, for an odd number of items, the median value
;    is defined as the middle value.  For an even number of values, it is
;    the integer average of the two middle values.

;  * Function estListMedian() computes and returns the estimated median
;    of a list of unsorted numbers.

;  * Function listAverage() computes and returns the average of
;    a list of numbers.

;  * Function betaValue() finds and returns the B (beta) value of a list
;    of numbers.  The summation for the a (alpha) value must be performed
;    as a quad-word.

; ============================================================================

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

SUCCESS		equ	0
NOSUCCESS	equ	1
OVERMAX		equ	2
INPUTOVERFLOW	equ	3
ENDOFINPUT	equ	4

MAXNUM		equ	100000
BUFFSIZE	equ	51			; 50 chars plus NULL

; -----
;  NO static local variables allowed...


; ============================================================================

section	.text

; ********************************************************************
;  Read an unsigned ASCII tridecimal number from the user.
;  Perform appropriate error checking and, if OK,
;  convert to integer.

; -----
;  HLL Call:
;	bool = rdTriNum(&numberRead, promptStr);

;  Arguments Passed:
;	numberRead, addr - rdi
;	promptStr, addr - rsi

;  Returns:
;	status code
;	number read (via reference)
;
;	SCC Prologue
; 		buffer = 51 bytes;	rbp - 51
;		char = 1 bytes; 	rbp - 52
;		rSum = 4 bytes		rbp - 56
;	Start function:
;	rSum = 0
;	i = 0
; 	bufferLp:
;		char = SYS_read()
;		if(char == LF); jump inputDone
;		else{
;			// if still in buffer, i=50 should be last char i.e. NULL
;			if(i <= 50){
;				// if a leading space, restart loop
;				if(char == " " && i == 0)
;					jmp bufferLp
;				else{
;					buffer[i] = char
;					string[i++]
;					i++
;				}
;			}
;			jump bufferLp
;		}

;	inputDone:
;		if(i == 0)
;			return ENDOFINPUT
;		else{
;			if(i <= 50)
;				buffer[i] = NULL
;		}

; BEGIN ERROR HANDLING
;	errorInputOverflow:
;		if(i == 51)
;			return INPUTOVERFLOW

;	errorNoSuccess:
;		for(i=0; i<buffer.length(); i++){
;			char = buffer[i]
;			if(char == NULL)
;				break;
;			else{
;				if(char >= 'a' && char <= 'c')
;					goto errorNoSuccessLp
;				if(char >= 'A' && char <= 'C')
;					goto errorNoSuccessLp
;				if(char >= '0' && char <= '9')
;					goto errorNoSuccessLp
;				else
;					return NOSUCCESS
;			}
;		}

; 	CONVERT TRI TO INTEGER

;	YOUR CODE GOES HERE
global rdTriNum
rdTriNum:
	push	rbp
	mov	rbp, rsp
	sub 	rsp, BUFFSIZE + 1					; buffer - rbp-51
	push	rbx							; char = rbp-52
	push	r12
	push	r13
	push	r14
	push	r15
	; ----------------- SCC Prologue
	; save passed args for later use when needed
	push 	rdi
	push 	rsi
rdTriNumStart:
; INITIALIZATION
	lea 	rbx, byte [rbp - BUFFSIZE]
	mov 	r15, 0			; index i = 0;

	pop 	rsi
	mov	rdi, rsi
	call 	printString 		; Prompt user to input
; READING IN CHARACTERS START
bufferLp:
	mov	rax, SYS_read
	mov	rdi, STDIN
	lea 	rsi, byte [rbp - BUFFSIZE - 1]
	mov 	rdx, 1
	syscall				; char = SYS_read()

	mov 	al, byte [rbp - BUFFSIZE - 1]
	cmp 	al, LF
	je 	inputDone		; if(char == LF); jump inputDone

	cmp 	r15, 50			; if(i <= 50){
	ja	lengthCheck
	cmp 	al, " "			;	if(char == " ")
	je 	leadingSpaces
	jmp 	storeChar

leadingSpaces:
	cmp 	r15, 0			; 	if(i == 0)
	je 	bufferLp		; 		jmp bufferLp

storeChar:
	mov 	byte [rbx], al 		; 	buffer[i] = char
	inc 	rbx 			; 	string[i + 1]
	inc 	r15 			; 	i++

lengthCheck:
	jmp 	bufferLp		; jmp bufferLp

inputDone:
	cmp 	r15, 0
	je 	noInputTRUE		; if(i == 0); return ENDOFINPUT
	cmp 	r15, 50
	ja 	nullDone		; if(i <= 50)
	mov 	byte [rbx], NULL 	;	buffer [i] = NULL
nullDone:
; READING IN CHARACTERS END

; ******** BEGIN ERROR HANDLING *********

; INPUT OVERFLOW START
errorInputOverflow:
	cmp 	r15, BUFFSIZE
	je 	errorInputOverflowTRUE
	jmp 	errorInputOverflowDone

errorInputOverflowDone:
; INPUT OVERFLOW END

; INPUT VALIDITY START
errorNoSuccess:
	mov 	r15, 0			; i = 0
	lea 	rbx, byte [rbp - BUFFSIZE]	; rbx = buffer

errorNoSuccessLp:
	mov 	al, byte [rbx]
	cmp 	al, NULL 		; if(end of string)
	je 	errorNoSuccessDone 	;	break

	cmp 	al, "c"
	ja 	errorNoSuccessTRUE
	cmp 	al, "a"			; if(char >= 'a' && char <= 'c')
	jae 	errorNoSuccessLpInc	; 	goto errorNoSuccessLp

	cmp 	al, "C"
	ja 	errorNoSuccessTRUE
	cmp 	al, "A"			; if(char >= 'A' && char <= 'C')
	jae 	errorNoSuccessLpInc	;	goto errorNoSuccessLp

	cmp 	al, "9"
	ja 	errorNoSuccessTRUE
	cmp 	al, "0"			; if(char >= '0' && char <= '9')
	jae 	errorNoSuccessLpInc	;	goto errorNoSuccessLp

	jmp 	errorNoSuccessTRUE 	; else NOSUCCESS
errorNoSuccessLpInc:
	inc 	rbx
	inc 	r15
	jmp 	errorNoSuccessLp

errorNoSuccessDone:
; INPUT VALIDITY END

; CONVERSION LOOP START
	mov 	r10, 0			; i = 0
	mov 	r11, 0 			; r11 = rSum
	mov 	r13, 13			; r13 = weight = 13
	lea 	rbx, byte [rbp - BUFFSIZE]	; rbx = buffer
tri2IntLp:
	mov 	r15, 0
	mov 	r15b, byte [rbx]		; buffer[i]
	cmp 	r15b, NULL 		; if(endOfString); break;
	je 	tri2IntDone

	mov 	rax, r11
	mul 	r13d
	mov	r11, rax		; rSum * weight

	cmp 	r15b, "a"
	jae	cvtLowerCase
	cmp 	r15b, "A"
	jae 	cvtUpperCase
	sub 	r15b, "0"
	jmp 	cvtCharDone

cvtLowerCase:
	sub 	r15b, "a"
	add 	r15b, 10
	jmp 	cvtCharDone

cvtUpperCase: 
	sub 	r15b, "A"
	add 	r15b, 10

cvtCharDone:
	add 	r11, r15		; rSum += digit
	inc 	rbx
	jmp 	tri2IntLp

tri2IntDone:
; CONVERSION LOOP END

; ERROR OVERMAX START
errorOverMaxStart:
	cmp 	r11, MAXNUM
	ja 	errorOverMaxTRUE
errorOverMaxEnd:
; ERROR OVERMAX END

; STORE VALID VALUE
	pop 	rdi 			; numberRead - addr
	mov 	dword [rdi], r11d	; numberRead = rSum

	mov	rax, SUCCESS
	jmp 	rdTriNumEnd
; END STORE VALID VALUE

; START ERRORS
noInputTRUE:
	mov 	rax, ENDOFINPUT
	jmp 	rdTriNumEnd

errorInputOverflowTRUE:
	mov 	rax, INPUTOVERFLOW
	jmp 	rdTriNumEnd

errorNoSuccessTRUE:
	mov 	rax, NOSUCCESS
	jmp 	rdTriNumEnd

errorOverMaxTRUE:
	mov	rax, OVERMAX
	mov 	r11, 0
	jmp 	rdTriNumEnd
	
; END ERRORS

	; ------------------ SCC Epilogue
rdTriNumEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	mov 	rsp, rbp
	pop 	rbp
	ret

; ********************************************************************
;  Selection sort function.
;	Note, must update the selection sort algorithm to sort
;	in asending order.

; -----
;  HLL Call:
;	selectionSort(list, len)

;  Arguments Passed:
;	- list, addr
;	- length, value

;  Returns:
;	sorted list (list passed by reference)


;	YOUR CODE GOES HERE

; algorithm for selection sort

; begin
; 	for  i = 0 to len­1 {
; 		big = arr[i]
; 		index = i
; 		for  j = i to len­1 {
;			if (arr[j] > big) {
; 				big = arr[j]
;				index = j
; 			}
; 		}
; 		arr[index] = arr[i]
; 		arr[i] = big
; 	}
; end_begin
global selectionSort
selectionSort:
	push 	rbp
	push 	rbx
	push 	r12
	push	r13
	push 	r14
	push 	r15
startSelectionSort:
	mov 	r15, 0		; r15 = j
	mov 	r14, 0	 	; r14 = i
	mov 	r13, 0 		; r13 = index
	mov 	r12, 0 		; r12 = big

outerLp:
	cmp 	r14, rsi			; for i=0 to len-1
	jae	outerLpDone
	mov 	r12d, dword [rdi + r14 * 4]	; big = arr[i]
	mov	r13, r14			; index = i
	mov	r15, r14			; j = i
innerLp:
	cmp 	r15, rsi				; for j=i to len-1
	jae	innerLpDone
	mov	ebx, dword [rdi + r15 * 4]	; arr[j]
	cmp 	ebx, r12d			; arr[j] > big
	jae  	bigDone
	mov 	r12, rbx				; big = arr[j]
	mov	r13, r15				; index = j
bigDone:
	inc	r15				; j++
	jmp 	innerLp
innerLpDone:
	mov 	eax, dword [rdi + r14 * 4] 	; arr[i]
	mov 	dword [rdi + r13 * 4], eax	; arr[index] = arr[i]
	mov 	dword [rdi + r14 * 4], r12d	; arr[i] = big
	inc 	r14				; i++
	jmp 	outerLp
outerLpDone:

endSelectionSort:
	pop	r15
	pop 	r14
	pop 	r13
	pop	r12
	pop 	rbx
	pop	rbp
	ret

; ********************************************************************
;  Find the minimum, median, and maximum for a list of integers

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	listStats(list, len, estMed, &min, &med,
;					&max, &ave, &pctErr)

;  Arguments Passed:
;	- list, addr
;	- length, value
;	- est median, value
;	- minimum, addr
;	- median, addr
;	- maximum, addr
;	- average, addr
;	- percent err, addr

;  Returns:
;	minimum, median, maximum, average, and percent error
;	via pass-by-reference


;	YOUR CODE GOES HERE
global listStats
listStats:
	push	rbp
	mov	rbp, rsp
	push 	rbx
	push	r12
	push	r13
	push	r14
	push	r15
startListStats:
	push	rdx		; save Estmedian
	; Maximum start
	mov 	eax, dword [rdi + rsi * 4 - 4]		; list[0], i.e. maximum
	mov 	dword [r9], eax
	; Maximum done
	; Minimum start
	mov 	eax, dword [rdi]	; list[length-1] i.e. minimum
	mov 	dword [rcx], eax
	; Minimum done
	; Median start
	mov 	eax, esi 			; eax = length
	mov 	r10, 2				; divisor
	mov 	rdx, 0
	div 	r10
	mov 	ebx, dword [rdi + rax * 4]	; middle value

	cmp 	rdx, 0
	jne 	medianDone
	add 	ebx, dword [rdi + rax * 4 - 4] 	; middle-1 value
	mov 	rax, rbx
	mov 	rdx, 0
	div 	r10
	mov 	rbx, rax
medianDone:
	mov 	dword [r8], ebx
	; Median done
	; Average start
	push 	rdi	; list
	push 	rsi 	; length
	push	r8 	; median address
	call 	lstAverage
	pop 	r8
	pop 	rsi
	pop 	rdi
	mov 	rbx, qword [rbp + 16]
	mov 	dword [rbx], eax
	; Average done
	; Percent error start
	pop 	rdx
	mov 	rax, rdx		; estMed
	mov 	ebx, dword [r8] 	; med
	sub 	rax, rbx		; estMed - med
	cmp 	rax, 0
	jge 	negPctDone
	neg 	rax			; abs(estMed - med)
negPctDone:
	mov 	rbx, 100
	mul 	rbx 			; abs(estMed - med) * 100

	mov 	ebx, dword [r8]		; median
	mov 	rdx, 0
	div 	ebx			; (abs(estMed - med) * 100)/median

	mov 	rbx, qword [rbp + 24]
	mov 	dword [rbx], eax
	; Percent error done
endListStats:
	pop	r15
	pop 	r14
	pop	r13
	pop	r12
	pop	rbx
	pop 	rbp
	ret



; ********************************************************************
;  Function to calculate the estimated median of an unsorted list.

; -----
;  Call:
;	ans = listEstMedian(lst, len)

;  Arguments Passed:
;	- list, address
;	- length, value

;  Returns:
;	est median (in eax)


;	YOUR CODE GOES HERE
global listEstMedian
listEstMedian:
	push 	rbp
	push	rbx
	push 	r12
	push	r13
	push	r14
	push	r15
startListEstMedian:
	mov 	r8, 0			; r8 = sum
	mov 	r8d, dword [rdi]	; list[0]

	mov 	r10, rsi
	dec 	r10
	add 	r8d, dword [rdi + r10 * 4]	; list[last]

	mov	rax, rsi
	mov 	r10, 2
	mov 	rdx, 0
	div 	r10				; length/2 i.e. middle

	add 	r8d, dword [rdi + rax * 4]	; list[middle]
	cmp 	rdx, 1
	je	isOdd
	; odd case
	dec 	rax
	add 	r8d, dword [rdi + rax * 4] 	; lenght/2 - 1
	mov 	rax, r8
	mov 	r10, 4				; sumEst/4 even
	mov	rdx, 0
	div 	r10
	jmp 	endListEstMedian
isOdd:
	mov 	r10, 3
	mov	rax, r8
	mov 	rdx, 0
	div	r10
endListEstMedian:
	pop	r15
	pop 	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret


; ********************************************************************
;  Function to calculate the average of a list.

; -----
;  Call:
;	ans = lstAverage(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)


;	YOUR CODE GOES HERE
global lstAverage
lstAverage:
	push 	rbp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
startLstAverage:
	mov	r10, 0		; i=0
	mov 	rax, 0		; sum = 0
sumLp:
	add 	eax, dword [rdi + r10 * 4]
	inc	r10
	cmp 	r10, rsi
	jb 	sumLp

	mov 	rdx, 0
	div 	rsi		; sum/length
endLstAverage:
	pop	r15
	pop 	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret


; ********************************************************************
;  Function to calculate the beta value for a list of numbers.

; -----
;  HLL Call:
;	b = betaValue(list, len)

;  Arguments Passed:
;	- list, addr
;	- length, value

;  Returns:
;	beta value (in eax)


;	YOUR CODE GOES HERE
global betaValue
betaValue:
	push	rbp
	push 	rbx
	push	r12
	push	r13
	push	r14
	push	r15
startBetaValue:
	mov 	rax, 0		; rax = cubing register
	mov 	r15, 0		; r15 = alpha
	mov 	r12, 0 		; r12 = i

alphaLp:
	cmp 	r12, rsi
	jae 	alphaLpDone
	mov 	eax, dword [rdi + r12 * 4]	; list[i]
	mov 	r10, rax				; list[i]
	mul 	r10					; list[i]^2
	mul 	r10					; list[i]^3
	add 	r15, rax			; alpha += list[i]^3
	inc 	r12
	jmp 	alphaLp
alphaLpDone:
	; get beta value
	mov 	rax, rsi 			; rax = length
	mov 	r10, 2
	mov 	rdx, 0
	div 	r10				; length/2
	add 	rax, rsi 			; length/2 + length
	mov 	r10, rax			; r10 = (length + length/2)
	mov 	rax, r15			; rax = r15 = alpha
	mov 	rdx, 0
	div 	r10				; alpha/(length+length/2)
	; beta value in rax

endBetaValue:
	pop 	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret



; ********************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************

