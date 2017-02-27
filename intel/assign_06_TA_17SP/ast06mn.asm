;  CS 218, Assignment #6
;  Provided Main

;  Write a simple assembly language program to convert
;  integers to tridecimal/ASCII charatcers and output
;  the tridecimal/ASCII strings to the screen (using the
;  provided routine).


; **********************************************************************************
;  STEP #3
;  Macro, "tri2int", to convert a tridecimal/ASCII string
;  into an integer.  The macro reads the ASCII string (byte-size,
;  NULL terminated) and converts to a doubleword sized integer.
;	- Accepts both 'A' and 'a' (which are treated as the same thing).
;	- Accepts both 'B' and 'b' (which are treated as the same thing).
;	- Accepts both 'C' and 'c' (which are treated as the same thing).
;	- Assumes valid/correct data.  As such, no error checking is performed.
;  Skips leading blanks.

;  Example:  given the ASCII string: " 01aB", NULL
;  The is,  " " (blank) followed by "0" followeed by "1" followed
;  by "a" followed by "B" and NULL would be converted to integer 310.

; -----
;  Arguments
;	%1 -> string address (reg)
;	%2 -> integer number (destination address)

%macro	tri2int	2

;	YOUR CODE GOES HERE

%%tri2intStart:
	mov	rbx, %1
	mov	rax, 0
	mov 	rsi, 0		; i = 0
	mov 	r8, 0		; r8 = rSum

; check leading spaces
%%spaceLp:
	mov	al, byte [rbx + rsi]
	inc	rsi
	cmp 	al, " "
	je 	%%spaceLp
	dec 	rsi
	mov 	rax, 0

%%tri2intConvert:
	mov	r15, 0
	mov	r15b, byte [rbx + rsi]	; get str[i]
	cmp 	r15b, NULL		; if(end of string)
	je 	%%tri2intConvertDone

	mov 	r9d, dword [weight]	; r9d = 13
	mov	rax, r8
	mul 	r9d			; rSum * weight
	mov 	r8, rax

	; convert digit
	cmp	r15b, "a"			; if(char >= 'a')
	jae	%%lCase
	cmp	r15b, "A"			; if(char >= 'A')
	jae	%%uCase
	sub	r15b, "0"			; if('0' <= char <= '9')
	jmp 	%%charConvertDone

%%lCase:
	sub 	r15b, "a"
	add 	r15b, 10
	jmp 	%%charConvertDone

%%uCase:
	sub 	r15b, "A"
	add 	r15b, 10

%%charConvertDone:
	add 	r8, r15			; rSum += digit
	inc 	rsi 			; i++
	jmp 	%%tri2intConvert

%%tri2intConvertDone:
	mov 	dword [%2], r8d


%endmacro

; **********************************************************************************
;  STEP #4
;  Macro, "int2tri", to convert a unsigned base-10 integer into
;  an ASCII string representing the tridecimal value.  The macro stores
;  the result into an ASCII string (byte-size, right justified,
;  blank filled, NULL terminated).  Each integer is a doubleword value.
;  Assumes valid/correct data.  As such, no error checking is performed.
;  Note, places "A". "B", and/or "C" (always uppercase) in string.

; -----
;  Arguments
;	%1 -> integer number
;	%2 -> string address

%macro	int2tri	2

;	YOUR CODE GOES HERE

;%%int2triStart:
;;	mov	rax, 0
;	mov 	rsi, 0
;	mov 	rcx, 0
;	mov	eax, %1
;
;%%int2triConvert:
;	cmp 	eax, 0
;	je 	%%int2triConvertDone
;
;	mov 	rdx, 0
;	mov 	r9d, dword [weight]
;	div 	r9d			; rSum / 13
;
;	push 	rdx
;	inc 	rcx			; count++
;	jmp 	%%int2triConvert
;
;%%int2triConvertDone:
;	mov	rbx, %2
;	mov 	r10, MAX_STR_SIZE
;	sub 	r10, rcx		; rcx = MAX - ;count
;	dec	r10			; spaces
;
;%%insertSpaces:
;	cmp 	r10, 0
;	je 	%%insertSpacesDone
;	mov	byte [rbx + rsi], " "
;	inc 	rsi
;	dec	r10
;	jmp 	%%insertSpaces
;
;%%insertSpacesDone:
;	pop	rax
;	cmp	al, 10
;	jl	%%zeroNineConvert
;	sub 	al, 10
;	add 	al, "A"			; if(rem >= 10)
;	jmp 	%%insertChar
;
;%%zeroNineConvert:
;	add 	al, "0"			; if(rem < 10)
;
;%%insertChar:
;	mov 	byte [rbx + rsi], al 	; str[i] = char
;	inc 	rsi 			; i++
;	loop 	%%insertSpacesDone
;
;	mov	byte [rbx + rsi], NULL

; END MY CODE ===============================

;       cnt = MAX_STR_SIZE - 1
        mov     ecx, MAX_STR_SIZE
        dec     ecx
;       string(cnt) = NULL
	mov 	rbx, %2
        mov     byte[rbx + rcx], NULL
;       cnt--
        dec     ecx
;       grab the integer you want to convert
        mov     eax, %1
;       while(answer != 0)
%%convertInt:
;               divide by 13
        mov     edx, 0
        div     dword[weight]
;               if(rem <_ 9)
        cmp     edx, 9
        jbe     %%lessNine
        jmp     %%skpLN
%%lessNine:
;                       string(cnt) = rem + "0"
        add     edx, 0x30
        mov     byte[rbx + rcx], dl
        dec     ecx
        jmp     %%checkDone
;               if(rem >_ 12)
%%skpLN:
        cmp     edx, 12
        jbe     %%lessTwelve
        jmp     %%checkDone
%%lessTwelve:
;                       string(cnt) = rem - 10 + "A"
        sub     edx, dword[ddTen]
        add     edx, 0x41
        mov     byte[rbx + rcx], dl
        dec     ecx
;       end while
%%checkDone:
        cmp     eax, 0
        jne     %%convertInt
%%fillSpace:
;               string(cnt) = space
        mov     byte[rbx + rcx], SPACE
        dec     ecx
        cmp     ecx, 0
        jne     %%fillSpace
        mov 	byte[rbx + rcx], SPACE
;end

%endmacro

; **********************************************************************************
;  Simple macro to display a string to the console.
;	Call:	printString  <stringAddr>

;	Arguments:
;		%1 -> <stringAddr>, string address

;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

%macro	printString	1
	push	rax			; save altered registers
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	mov	rsi, %1			; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; **********************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

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
;  Variables and constants.

MAX_STR_SIZE	equ	10
NUMS_PER_LINE	equ	5
MAX_STR_LENGTH	equ	20

newline		db	LF, NULL

; -----
;  Misc. string definitions.

hdr1		db	"--------------------------------------------"
		db	LF, "CS 218 - Assignment #6", LF
		db	LF, NULL
hdr2		db	LF, LF, "----------------------"
		db	LF, "List Sums"
		db	LF, NULL

firstNum	db	"----------------------", LF
		db	"Test Number (base-13):     ", NULL
firstNumMul	db	"Test Number * 4 (base-13): ", NULL

lstSum1		db	LF, "List Sum (short list):"
		db	LF, NULL
lstSum2		db	LF, "List Sum (long list):"
		db	LF, NULL

; -----
;  Misc. data definitions (if any).

weight		dd	13
ddTen		dd 	10


; -----
;  Assignment #6 Provided Data:

dStr1		db	"    12a4B", NULL
iNum1		dd	0

dStrLst1	db	"     1a9C", NULL, "      3Ab", NULL, "    1cA92", NULL
		db	"    82bAc", NULL, "      bac", NULL
len1		dd	5
sum1		dd	0

dStrLst2	db	"      3A8", NULL, "    A6791", NULL, "    193b0", NULL
		db	"    250b0", NULL, "   a13081", NULL, "    14b21", NULL
		db	"    224A2", NULL, "    11010", NULL, "    11201", NULL
		db	"     10C0", NULL, "        B", NULL, "       c6", NULL
		db	"      7b1", NULL, "     C009", NULL, "    19a45", NULL
		db	"    15557", NULL, "     23a9", NULL, "    189c0", NULL
		db	"    A12a4", NULL, "    11c11", NULL, "    12a2c", NULL
		db	"    11B92", NULL, "    15a10", NULL, "    1b667", NULL
		db	"     B726", NULL, "     B312", NULL, "      420", NULL
		db	"     55C2", NULL, "    26516", NULL, "     5182", NULL
		db	"      192", NULL, "    21a44", NULL, "     18c4", NULL
		db	"     79a6", NULL, "    24c12", NULL, "     a231", NULL
		db	"     97B5", NULL, "    17312", NULL, "      812", NULL
		db	"      7c4", NULL, "    123A4", NULL, "    278b1", NULL
		db	"        7", NULL, "        c", NULL, "    B1512", NULL
		db	"     7c52", NULL, "    11b44", NULL, "    10134", NULL
		db	"     7a64", NULL, "     4b71", NULL, "     2c44", NULL
		db	"      2b4", NULL, "    112c2", NULL, "    11aa5", NULL
		db	"     2012", NULL, "    22a30", NULL, "     7164", NULL
		db	"     1067", NULL, "    117b1", NULL, "    21000", NULL
		db	"     2b74", NULL, "     2127", NULL, "    23212", NULL
		db	"      117", NULL, "    20c63", NULL, "    b2112", NULL
		db	"    11C45", NULL, "    11064", NULL, "    11B21", NULL
		db	"    260a0", NULL, "    23A75", NULL, "    c3725", NULL
		db	"     3A10", NULL, "      120", NULL, "    13332", NULL
		db	"    10C22", NULL, "     7B60", NULL, "    a2313", NULL
		db	"    11c60", NULL, "     4312", NULL, "    17b65", NULL
		db	"    23241", NULL, "    27C31", NULL, "      730", NULL
		db	"     4313", NULL, "    30233", NULL, "    13657", NULL
		db	"    31113", NULL, "     1661", NULL, "    11312", NULL
		db	"    17A55", NULL, "    12241", NULL, "    13C31", NULL
		db	"     3270", NULL, "     7a53", NULL, "    15127", NULL
		db	"       A5", NULL, "    7a3b1", NULL, "   AbCaBc", NULL
		db	"     1b9c", NULL
len2		dd	100
sum2		dd	0


; **********************************************************************************

section	.bss

num1String	resb	MAX_STR_SIZE
tempString	resb	MAX_STR_SIZE
tempNum		resd	1


; **********************************************************************************

section	.text
global	_start
_start:

; **********************************************************************************
;  Main program
;	display headers
;	calls the macro on various data items
;	display results to screen (via provided macro's)

;  Note, since the print macros do NOT perform an error checking,
;  	if the conversion macros do not work correctly,
;	the print string will not work!

; **********************************************************************************
;  Prints some cute headers...

	printString	hdr1
	printString	firstNum
	printString	dStr1
	printString	newline

; -----
;  STEP #1
;	Convert tridecimal/ASCII NULL terminated string at 'dNum1'
;	into an integer which should be placed into 'iNum1'
;	Note, 12a4B (base-13) = 34,877 (base-10)

;	DO NOT USE MACRO HERE!!
;	YOUR CODE GOES HERE

tri2intStart:
	mov	rbx, dStr1
	mov	rax, 0
	mov 	rsi, 0		; i = 0
	mov 	r8, 0		; r8 = rSum

; check leading spaces
spaceLp:
	mov	al, byte [rbx + rsi]
	inc	rsi
	cmp 	al, " "
	je 	spaceLp
	dec 	rsi
	mov 	rax, 0

tri2intConvert:
	mov	r15, 0
	mov	r15b, byte [rbx + rsi]	; get str[i]
	cmp 	r15b, NULL		; if(end of string)
	je 	tri2intConvertDone

	mov 	r9d, dword [weight]	; r9d = 13
	mov	rax, r8
	mul 	r9d			; rSum * weight
	mov 	r8, rax

	; convert digit
	cmp	r15b, "a"			; if(char >= 'a')
	jae	lCase
	cmp	r15b, "A"			; if(char >= 'A')
	jae	uCase
	sub	r15b, "0"			; if('0' <= char <= '9')
	jmp 	charConvertDone

lCase:
	sub 	r15b, "a"
	add 	r15b, 10
	jmp 	charConvertDone

uCase:
	sub 	r15b, "A"
	add 	r15b, 10

charConvertDone:
	add 	r8, r15			; rSum += digit
	inc 	rsi 			; i++
	jmp 	tri2intConvert

tri2intConvertDone:
	mov 	dword [iNum1], r8d



; -----
;  Perform (iNum1 * -2) operation.
;	Note, 34,708 (base-10) * 4 (base-10) = 138,832 (base-10)

	mov	eax, dword [iNum1]
	mov	ebx, 4
	mul	ebx
	mov	dword [iNum1], eax

; -----
;  STEP #2
;	Convert the integer (in dNum1) into a tridecimal/ASCII string
;	which should be stored into the 'num1String'
;	Note, 138,832 (base-10) = 4B265 (base-13)

;	DO NOT USE MACRO HERE!!
;	YOUR CODE GOES HERE

int2triStart:
	mov	rax, 0
	mov 	rsi, 0
	mov 	rcx, 0

	mov	eax, dword [iNum1]

int2triConvert:
	cmp 	eax, 0
	je 	int2triConvertDone

	mov 	rdx, 0
	mov 	r9d, dword [weight]
	div 	r9d			; rSum / 13

	push 	rdx
	inc 	rcx			; count++
	jmp 	int2triConvert

int2triConvertDone:
	mov	rbx, num1String
	mov 	r10, MAX_STR_SIZE
	sub 	r10, rcx		; rcx = MAX - count
	dec	r10			; spaces

insertSpaces:
	cmp 	r10, 0
	je 	insertSpacesDone
	mov	byte [rbx + rsi], " "
	inc 	rsi
	dec	r10
	jmp 	insertSpaces

insertSpacesDone:
	pop	rax
	cmp	al, 10
	jl	zeroNineConvert
	sub 	al, 10
	add 	al, "A"			; if(rem >= 10)
	jmp 	insertChar

zeroNineConvert:
	add 	al, "0"			; if(rem < 10)

insertChar:
	mov 	byte [rbx + rsi], al 	; str[i] = char
	inc 	rsi 			; i++
	loop 	insertSpacesDone

	mov	byte [rbx + rsi], NULL

; -----
;  Display a simple header and then the ASCII/tridecimal string.

	printString	firstNumMul
	printString	num1String

; **********************************************************************************
;  Next, repeatedly call the macro on each value in an array.

	printString	hdr2

; ==================================================
;  Data Set #1 (short list)

	mov	ecx, dword [len1]		; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, dStrLst1			; address of string

cvtLoop1:
	push	rcx
	push	rdi

	tri2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum1], eax

	add	rdi, MAX_STR_SIZE
	pop	rdi

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop1

	mov	eax, dword [sum1]
	int2tri	eax, tempString			; convert integer (eax) into octal string

	printString	lstSum1			; display header string
	printString	tempString		; print string
	printString	newline

; ==================================================
;  Data Set #2 (long list)

	mov	rcx, [len2]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, dStrLst2			; address of string

cvtLoop2:
	push	rcx
	push	rdi

	tri2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum2], eax

	pop	rdi
	add	rdi, MAX_STR_SIZE

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop2

	mov	eax, [sum2]
	int2tri	eax, tempString			; convert integer (eax) into octal string

	printString	lstSum2			; display header string
	printString	tempString		; print string
	printString	newline


; **********************************************************************************
; Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rbx, SUCCESS
	syscall

