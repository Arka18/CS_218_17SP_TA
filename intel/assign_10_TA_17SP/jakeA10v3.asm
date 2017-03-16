;  CS 218 - Assignment #10
;  Spirograph - Support Functions.
;  Provided Template

;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;  Macro, "tri2int", to convert a tridecimal/ASCII string
;  into an integer.  The macro reads the ASCII string (byte-size,
;  NULL terminated) and converts to a doubleword sized integer.
;	- Accepts both 'A' and 'a' (which are treated as the same thing).
;	- Accepts both 'B' and 'b' (which are treated as the same thing).
;	- Accepts both 'C' and 'c' (which are treated as the same thing).
;  	- Skips leading blanks.

; -----
;  Arguments
;	%1 -> string address (reg)
;	%2 -> integer number (dest address)
;	%3 -> success or nosuccess (address)

%macro	tri2int	3
	push rax		; save altered registers
	push rbx
	push rcx
	push rsi
	push r8
	push r9
	push rdx

	mov r9, 13
	mov dword [%3], SUCCESS
	mov rsi, 0		; number of total chars in string
	mov r8 , 0		; number of non-whitespace chars
	mov rax, 0
%%pushCh:
	mov al, byte [%1+rsi]
	inc rsi
	cmp al, NULL		; if null, stop pushing chars
	je  %%endPush
	cmp al, SPACE		; if space, check if valid or next char
	je  %%isSpace
	push rax		; if not a space or null, push char
	inc r8			; and count it by incrementing r8
	jmp %%pushCh

%%isSpace:
	cmp r8, 0
	je  %%pushCh
	jmp %%notValidTri

%%endPush:
	mov rsi, 0		; number of digits from the right
	mov ebx, 0		; sum to be stored

%%popCh:
	pop rax
	cmp al, "0"
	jb %%notValidTri
	cmp al, "9"
	ja %%not0to9
	sub al, "0"		; subtracting "0" gives 0 to 9
	jmp %%addDigits
%%not0to9:
	cmp al, "A"
	jb %%notValidTri
	cmp al, "C"
	ja %%notAtoC
	sub al, 55
	jmp %%addDigits
%%notAtoC:
	cmp al, "a"
	jb %%notValidTri
	cmp al, "c"
	ja %%notValidTri
	sub al, 87
%%addDigits:
	cmp rsi, 0		; if last digit, then no need to multiply
	je  %%skipExp
	mov rcx, rsi		; else, multiply by weight^n where n =
%%expon:			; number of places from the right
	mul r9d
	loop %%expon
%%skipExp:
	add ebx, eax		; add result to destination
	inc rsi
	cmp rsi, r8
	jb  %%popCh
	mov dword [%2], ebx
	jmp %%Tri2end

%%popLeftover:
	pop rax
%%notValidTri:
	inc rsi
	cmp rsi, r8
	jb %%popLeftover
	mov dword[%3], NOSUCCESS

%%Tri2end:
	pop rdx
	pop r9
	pop r8			; restore registers
	pop rsi
	pop rcx
	pop rbx
	pop rax

%endmacro

; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

R1_MIN		equ	0
R1_MAX		equ	250			; 250(10) = 163(13)

R2_MIN		equ	1			; 1(10) = 1(13)
R2_MAX		equ	250			; 250(10) = 163(13)

OP_MIN		equ	1			; 1(10) = 1(13)
OP_MAX		equ	250			; 250(10) = 163(13)

SP_MIN		equ	1			; 1(10) = 1(13)
SP_MAX		equ	100			; 12(10) = 79(13)

X_OFFSET	equ	320
Y_OFFSET	equ	240

; -----
;  Variables for getRadii function.
;  	These are the provided strings for messages.
;  	Please do not change (as these are the expected messages).

errUsage	db	"Usage: ./spiro -r1 <triDecimal> -r2 <triDecimal> "
		db	"-op <triDecimal> -sp <1-9> -cl <b/g/r/y/p/w>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errR1sp		db	"Error, radius 1 specifier incorrect."
		db	LF, NULL
errR1value	db	"Error, radius 1 value must be between 0 and 163(13)."
		db	LF, NULL

errR2sp		db	"Error, radius 2 specifier incorrect."
		db	LF, NULL
errR2value	db	"Error, radius 2 value must be between 1 and 163(13)."
		db	LF, NULL

errOPsp		db	"Error, offset position specifier incorrect."
		db	LF, NULL
errOPvalue	db	"Error, offset position value must be between 1 and 163(13)."
		db	LF, NULL

errSPsp		db	"Error, speed specifier incorrect."
		db	LF, NULL
errSPvalue	db	"Error, speed value must be between 1 and 79(13)."
		db	LF, NULL

errCLsp		db	"Error, color specifier incorrect."
		db	LF, NULL
errCLvalue	db	"Error, color value must be b, g, r, p, or w. "
		db	LF, NULL

;  Argument specifiers for getRadii

spRadius1	db	"-r1", NULL
spRadius2	db	"-r2", NULL
spOffset	db	"-op", NULL
spSpeed		db	"-sp", NULL
spColor		db	"-cl", NULL

; -----
;  Variables for spirograph routine.
;	You are NOT required to use these variables.
;	If you want, feel free to use these variables or just
;	define your own variables as desired.


fltOne		dd	1.0
fltZero		dd	0.0
fltTmp1		dd	0.0
fltTmp2		dd	0.0

t		dd	0.0			; loop variable
s		dd	0.0			; phase variable
tStep		dd	0.01			; t step
sStep		dd	0.0			; s step
x		dd	0			; current x
y		dd	0			; current y

r1		dd	0.0			; radius 1 (float)
r2		dd	0.0			; radius 2 (float)
ofp		dd	0.0			; offset position (float)
radii		dd	0.0			; tmp location for (radius1+radius2)

scale		dd	5000.0			; speed scale
limit		dd	360.0			; for loop limit
iterations	dd	0			; set to 360.0/tStep

red		db	0			; 0-255
green		db	0			; 0-255
blue		db	0			; 0-255

; ------------------------------------------------------------

section  .text

; -----
;  External references for openGL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cosf, sinf

; ******************************************************************
;  Function getRadii()
;	Gets radius 1, radius 2, offset position and rotation
;	speedvalues and color code letter from the command line.

;	Performs error checking, converts ASCII/Tridecimal string
;	to integer.  Required ommand line format (fixed order):
;	  "-r1 <triDecimal> -r2 <triDecimal> -op <triDecimal>
;			-sp <triDecimal> -cl <color>"

; -----
;  Arguments:
;	- ARGC
;	- ARGV
;	- radius 1: int, double-word, address
;	- radius 2: int, double-word, address
;	- offset position: int double-word, address
;	- speed: int, double-word address
;	- circle color: char, byte, address

global getRadii
getRadii:

	push	rbp
	mov	rbp, rsp
	sub	rsp, 8
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	; preserve contents of rdi
	mov	r12, rdi

	; check if number of arguments is incorrect
	cmp	r12, 11
	jne	errorArgc

	; check that each specifier is correct and that each
	; value is within a valid range
	mov	rbx, 1
	mov	r14, qword[rsi+rbx*8]
	mov	r13, 0
checkR1sp:
	mov	r15b, byte[r14+r13]
	cmp	r15b, byte[spRadius1+r13]
	jne	errorR1sp
	inc	r13
	cmp	r13, 4
	jb	checkR1sp

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	tri2int	r14, rbp-4, rbp-8
	cmp	dword[rbp-8], SUCCESS
	jne	errorR1val
	cmp	dword[rbp-4], R1_MAX
	ja	errorR1val
	cmp	dword[rbp-4], R1_MIN
	jb	errorR1val
	mov	r10d, dword[rbp-4]
	mov	qword[rdx], r10

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	mov	r13, 0
checkR2sp:
	mov	r15b, byte[r14+r13]
	cmp	r15b, byte[spRadius2+r13]
	jne	errorR2sp
	inc	r13
	cmp	r13, 4
	jb	checkR2sp

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	tri2int	r14, rbp-4, rbp-8
	cmp	dword[rbp-8], SUCCESS
	jne	errorR2val
	cmp	dword[rbp-4], R2_MAX
	ja	errorR2val
	cmp	dword[rbp-4], R2_MIN
	jb	errorR2val
	mov	r10d, dword[rbp-4]
	mov	qword[rcx], r10

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	mov	r13, 0
checkOPsp:
	mov	r15b, byte[r14+r13]
	cmp	r15b, byte[spOffset+r13]
	jne	errorOPsp
	inc	r13
	cmp	r13, 4
	jb	checkOPsp

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	tri2int	r14, rbp-4, rbp-8
	cmp	dword[rbp-8], SUCCESS
	jne	errorOPval
	cmp	dword[rbp-4], OP_MAX
	ja	errorOPval
	cmp	dword[rbp-4], OP_MIN
	jb	errorOPval
	mov	r10d, dword[rbp-4]
	mov	qword[r8], r10

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	mov	r13, 0
checkSPsp:
	mov	r15b, byte[r14+r13]
	cmp	r15b, byte[spSpeed+r13]
	jne	errorSPsp
	inc	r13
	cmp	r13, 4
	jb	checkSPsp

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	tri2int	r14, rbp-4, rbp-8
	cmp	dword[rbp-8], SUCCESS
	jne	errorSPval
	cmp	dword[rbp-4], SP_MAX
	ja	errorSPval
	cmp	dword[rbp-4], SP_MIN
	jb	errorSPval
	mov	r10d, dword[rbp-4]
	mov	qword[r9], r10

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	mov	r13, 0
checkCLsp:
	mov	r15b, byte[r14+r13]
	cmp	r15b, byte[spColor+r13]
	jne	errorCLsp
	inc	r13
	cmp	r13, 4
	jb	checkCLsp

	inc	rbx
	mov	r14, qword[rsi+rbx*8]
	cmp	byte[r14], "r"
	je	validColor
	cmp	byte[r14], "g"
	je	validColor
	cmp	byte[r14], "b"
	je	validColor
	cmp	byte[r14], "p"
	je	validColor
	cmp	byte[r14], "y"
	je	validColor
	cmp	byte[r14], "w"
	je	validColor

	jmp	errorCLval

validColor:
	cmp	byte[r14+1], NULL
	jne	errorCLval
	mov	r11, qword[rbp+16]
	mov	r10b, byte[r14]
	mov	byte[r11], r10b
	jmp	success

errorR1sp:
	mov	rdi, errR1sp
	call	printString
	jmp	nosuccess
errorR1val:
	mov	rdi, errR1value
	call	printString
	jmp	nosuccess
errorR2sp:
	mov	rdi, errR2sp
	call	printString
	jmp	nosuccess
errorR2val:
	mov	rdi, errR2value
	call	printString
	jmp	nosuccess
errorOPsp:
	mov	rdi, errOPsp
	call	printString
	jmp	nosuccess
errorOPval:
	mov	rdi, errOPvalue
	call	printString
	jmp	nosuccess
errorSPsp:
	mov	rdi, errSPsp
	call	printString
	jmp	nosuccess
errorSPval:
	mov	rdi, errSPvalue
	call	printString
	jmp	nosuccess
errorCLsp:
	mov	rdi, errCLsp
	call	printString
	jmp	nosuccess
errorCLval:
	mov	rdi, errCLvalue
	call	printString
	jmp	nosuccess

errorArgc:
	; if exactly one argument, only print usage details
	cmp	r12, 1
	je	printUsage
	; else, print error invalid arguments
	mov	rdi, errBadCL
	call	printString
	jmp	nosuccess

printUsage:
	mov	rdi, errUsage
	call	printString

nosuccess:
	mov	rax, FALSE
	jmp	endGetRadii

success:
	mov	rax, TRUE

endGetRadii:
	; end of getRadii
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	mov	rsp, rbp
	pop	rbp
	ret


; ******************************************************************
;  Spirograph Plotting Function.
;  Plot provided spirograph equations.

; -----
;  Color Code Conversion:
;	'r' -> red=255, green=0, blue=0
;	'g' -> red=0, green=255, blue=0
;	'b' -> red=0, green=0, blue=255
;	'p' -> red=255, green=0, blue=255
;	'y' -> red=255 green=255, blue=0
;	'w' -> red=255, green=255, blue=255
;  Note, set color before plot loop.

; -----
;  Since the loop is from 0.0 to 360.0 by tStep, you can calculate
;  the number of iterations via:  iterations = 360.0 / tStep
;  This eliminates needing a float compare (a hassle).

; -----
;  Basic flow:
;	Set openGL drawing initializations
;	Loop initializations
;		Set draw color (i.e., glColor3ub)
;		Convert integer values to float for calculations
;		set 'sStep' variable
;		set 'iterations' variable
;	Plot the following spirograph equations:
;	     for (t=0.0; t<360.0; t+=step) {
;	         radii = (r1+r2)
;	         x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
;	         y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))
;	         t += tStep
;	         plot point (x, y)
;	     }
;	Close openGL plotting (i.e., glEnd and glFlush)
;	Update s for next call (s += sStep)
;	Ensure openGL knows to call again (i.e., glutPostRedisplay)

; -----
;  The animation is accomplished by plotting a static
;	image, exiting the routine, and replotting a new
;	slightly different image.  The 's' variable controls
;	the phase or animation.

; -----
;  Arguments
;	N/A -> no arguments passed
;	Some arguments are accessed via gloabl variables

; -----
;  Global variables accessed
;	There are defined and set in the main, accessed herein by
;	name as per the below declarations.

common	radius1		1:4		; radius 1: int, dword, integer value
common	radius2		1:4		; radius 2: int, dword, integer value
common	offPos		1:4		; offset position: int, dword, integer value
common	speed		1:4		; rotation speed: int, dword, integer value
common	color		1:1		; color code letter: char, byte, ASCII value

global drawSpiro
drawSpiro:

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Main loop to calculate and then plot the series of (x,y)
;  points based on the spirograph equation.

	; set draw color
	cmp	byte[color], "r"
	je	setcRed
	cmp	byte[color], "g"
	je	setcGreen
	cmp	byte[color], "b"
	je	setcBlue
	cmp	byte[color], "p"
	je	setcPurple
	cmp	byte[color], "y"
	je	setcYellow
	cmp	byte[color], "w"
	je	setcWhite

setcRed:
	mov	dword[red], 255
	jmp	colorSet
setcGreen:
	mov	dword[green], 255
	jmp	colorSet
setcBlue:
	mov	dword[blue], 255
	jmp	colorSet
setcPurple:
	mov	dword[red], 255
	mov	dword[blue], 255
	jmp	colorSet
setcYellow:
	mov	dword[red], 255
	mov	dword[green], 255
	jmp	colorSet
setcWhite:
	mov	dword[red], 255
	mov	dword[green], 255
	mov	dword[blue], 255
colorSet:
	mov	edi, dword[red]
	mov	esi, dword[green]
	mov	edx, dword[blue]
	call	glColor3ub

	; convert integer values to float
	cvtsi2ss xmm0, dword[offPos]
	movss	dword[ofp], xmm0
	; sStep = speed/scale
	cvtsi2ss xmm0, dword[speed]
	divss	xmm0, dword[scale]
	movss	dword[sStep], xmm0
	; t = 0 before loop
	movss	xmm0, dword[fltZero]
	movss	dword[t], xmm0
	; set radii = (r1 + r2)
	cvtsi2ss xmm0, dword[radius1]
	movss	dword[r1], xmm0
	cvtsi2ss xmm1, dword[radius2]
	movss	dword[r2], xmm1
	addss	xmm0, xmm1
	movss	dword[radii], xmm0
plotLoop:
	; find x
	movss	xmm0, dword[t]
	call	cosf
	mulss	xmm0, dword[radii]
	movss	dword[fltTmp1], xmm0
	movss	xmm0, dword[t]
	addss	xmm0, dword[s]
	divss	xmm0, dword[r2]
	mulss	xmm0, dword[radii]
	call	cosf
	mulss	xmm0, dword[ofp]
	addss	xmm0, dword[fltTmp1]
	movss	dword[fltTmp1], xmm0

	; find y
	movss	xmm0, dword[t]
	call	sinf
	mulss	xmm0, dword[radii]
	movss	dword[fltTmp2], xmm0
	movss	xmm0, dword[t]
	addss	xmm0, dword[s]
	divss	xmm0, dword[r2]
	mulss	xmm0, dword[radii]
	call	sinf
	mulss	xmm0, dword[ofp]
	addss	xmm0, dword[fltTmp2]
	movss	dword[fltTmp2], xmm0


	; plot point (x, y)
	movss	xmm0, dword[fltTmp1]
	movss	xmm1, dword[fltTmp2]
	call	glVertex2f
	; t += tStep
	movss	xmm0, dword[t]
	addss	xmm0, dword[tStep]
	movss	dword[t], xmm0
	ucomiss	xmm0, dword[limit]
	jb	plotLoop


; -----
;  Main plotting loop done.

	call	glEnd
	call	glFlush

; -----
;  Update s for next call.

	movss	xmm0, dword [s]
	addss	xmm0, dword [sStep]
	movss	dword [s], xmm0

; -----
;  Ensure openGL knows to call again

	call	glutPostRedisplay

;	pop	r12
	ret

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  No error checking is done here...

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	- address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret

; ******************************************************************

