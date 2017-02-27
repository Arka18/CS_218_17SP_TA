;  CS 218 - Assignment 8
;  Functions Template.

; ============================================================================
;  Write assembly language functions.

;  * Function selectionSort() sorts the numbers into descending
;    order (large to small).  Uses the selection sort algorithm
;    (from asst #7), modified.

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

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	0			; unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; call code for read
SYS_write	equ	1			; call code for write
SYS_open	equ	2			; call code for file open
SYS_close	equ	3			; call code for file close
SYS_fork	equ	57			; call code for fork
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ	85			; call code for file open/create
SYS_time	equ	201			; call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

; -----
;  Variables for selectionSort() function (if any)



; -----
;  Variables for listStats() function (if any)



; -----
;  Variables for listAverage() function (if any)



; -----
;  Variables for betaValue() function (if any)



; ---------------------------------------------

section .bss

; ============================================================================

section	.text

; ********************************************************************
;  Selection sort function.
;	Note, must update the selection sort algorithm to sort
;	in desending order.

; -----
;  HLL Call:
;	selectionSort(list, len)

;  Arguments Passed:
;	- list, addr 	- rdi
;	- length, value - rsi

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
	jbe  	bigDone
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
;  Find the minimum, median, maximum, and average for a list
;  of integers.  Also finds percent error between the estimated
;  median and the actual median (per formula).

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	listStats(list, len, estMed, &min, &med,
;					&max, &ave, &pctErr)

;  Arguments Passed:
;	- list, addr 		-rdi
;	- length, value  	-rsi
;	- est median, value 	-rdx
;	- minimum, addr 	-rcx
;	- median, addr 		-r8
;	- maximum, addr 	-r9
;	- average, addr 	-rbp+16
;	- percent err, addr 	-rbp+24

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
	mov 	eax, dword [rdi]		; list[0], i.e. maximum
	mov 	dword [r9], eax
	; Maximum done
	; Minimum start
	mov 	eax, dword [rdi + rsi * 4 - 4]	; list[length-1] i.e. minimum
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
;	- list, address	- rdi
;	- length, value - rsi

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
	pop 	r1401565960155
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
;	- list, addr - rdi
;	- length, value - rsi

;  Returns:
;	beta value (in rax)

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

