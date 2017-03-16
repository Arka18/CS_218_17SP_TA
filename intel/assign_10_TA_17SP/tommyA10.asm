;  CS 218 - Assignment #10
;  Spirograph - Support Functions.
;  Provided Template

; -----
;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;	MACROS (if any) GO HERE
%macro tri2int 2
	push r12
	push r13
	push rsi
	mov r11, 0
	mov r12, 0
	mov r13, 0
	mov rsi, 0

%%Nextlp:
	movsx rax, byte[%1 + r12]
	inc r12
	cmp rax, NULL
	jne %%Nextlp
	dec r12
	mov r13, r12
%%Cvtlp:
	movsx rax, byte[%1 + rsi]
	cmp rax, 'a'
	jae %%intDigits
	cmp rax, '0'
	jae %%intDigits2
	cmp rax, NULL
	je %%Quit

%%intDigits:
	sub rax, 'a'
	add rax, 10
	jmp %%Converter
%%intDigits2:
	sub rax, '0'
	jmp %%Converter
%%Converter:
	mov r14, 13
	imul r14
	mov qword[Multiplersum], rax
	dec r12
	cmp r12, 0
	je %%Zero
	cmp r12, 1
	jne %%Converter
	jmp %%Done1
%%Zero:
	idiv byte[Multipler]
%%Done1:
	add %2, rax
	inc rsi
	dec r13
	mov r12, r13
	mov rax, 0

	jmp %%Cvtlp

%%Quit:
	pop rsi
	pop r13
	pop r12
	pop r14
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

LF			equ	10
SPACE		equ	" "
NULL		equ	0
ESC			equ	27

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
;  These are the provided strings for messages.
;  Please do not change (as these are the expected messages).

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

; -----
;  Variables for spirograph routine.
;	You are NOT required to use these variables.
;	If you want, feel free to use these variables or just
;	define your own variables as desired.


fltOne		dd	1.0
fltZero		dd	0.0
fltTmp1		dd	0.0
fltTmp2		dd	0.0

fltRadius1	dd 	0.0
fltRadius2	dd 	0.0
fltRadii 	dd 	0.0
fltOffPos	dd 	0.0

fltPart1	dd 	0.0

t			dd	0.0			; loop variable
s			dd	0.0			; phase variable
tStep		dd	0.01		; t step
sStep		dd	0.0			; s step
x			dd	0			; current x
y			dd	0			; current y

r1			dd	0.0			; radius 1 (float)
r2			dd	0.0			; radius 2 (float)
ofp			dd	0.0			; offset position (float)
radii		dd	0.0			; tmp location for (radius1+radius2)

scale		dd	5000.0		; speed scale
limit		dd	360.0		; for loop limit
iterations	dd	0			; set to 360.0/tStep

red			db	0			; 0-255
green		db	0			; 0-255
blue		db	0			; 0-255
Multipler	db 	13
Multiplersum  dq 	0
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


;	YOUR CODE GOES HERE
global getRadii
getRadii:
	push rbp
	mov rbp, rsp

; if(argc == 1 )
	cmp rdi, 1
	jne CheckArgc1
	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp goBack
CheckArgc1:
; if(argc != 11)
	cmp rdi, 11
	je CheckArgc2
	mov rdi, errBadCL
	call printString
	mov rax, FALSE
	jmp goBack
CheckArgc2:
; if(argv[1] != "-r1")
	mov r10, qword[rsi + 8]
	cmp dword[r10], 0x0031722d			; this is backwards because the computer reads it oppositely
	je CheckR1next
	mov rdi, errR1sp
	call printString
	mov rax, FALSE
	jne goBack
; get argv[2]
CheckR1next:
	mov r10, qword[rsi + 16]
	mov r15, rdx
	tri2int r10, r11
	mov rdx, r15
	cmp r11, R1_MIN
	jl Error0
	cmp r11, R2_MAX
	jg Error0
; if(argv[3] != "-r2")
	mov dword[rdx], r11d
	mov r10, qword[rsi + 24]
	cmp dword[r10], 0x0032722d
	je CheckR2next
	mov rdi, errR2sp
	call printString
	mov rax, FALSE
	jmp goBack
; get arg[4]
CheckR2next:
	mov r10, qword[rsi + 32]
	tri2int r10, r11
	cmp r11, R2_MIN
	jl Error1
	cmp r11, R2_MAX
	jg Error1
; if(argv[5] != "-op")
	mov dword[rcx], r11d
	mov r10, qword[rsi + 40]
	cmp dword[r10], 0x00706f2d
	je Checkopnext
	mov rdi, errOPsp
	call printString
	mov rax, FALSE
	jmp goBack
; get arg[6]
Checkopnext:
	mov r10, qword[rsi + 48]
	tri2int r10, r11
	cmp r11, OP_MIN
	jl Error2
	cmp r11, OP_MAX
	jg Error2
; if(argv[7] != "-sp")
	mov dword[r8], r11d
	mov r10, qword[rsi + 56]
	cmp dword[r10], 0x0070732d
	je CheckSPnext
	mov rdi, errSPsp
	call printString
	mov rax, FALSE
	jmp goBack
CheckSPnext:
; get arg[8]
	mov r10, qword[rsi + 64]
	tri2int r10, r11
	cmp r11, SP_MIN
	jl Error3
	cmp r11, SP_MAX
	jg Error3
; if(argv[9] != "-cl")
	mov dword[r9], r11d
	mov r10, qword[rsi + 72]
	cmp dword[r10], 0x006c632d
	je CheckCLnext
	mov rdi, errCLsp
	call printString
	mov rax, FALSE
	jmp goBack
CheckCLnext:
; get arg[10]
	mov r10, 0
	mov r10, qword[rsi + 80]
	movzx rax, byte[r10]


	cmp al, 'b'
	je c1ValueBlue
	cmp al, 'g'
	je c1Valuegreen
	cmp al, 'r'
	je c1Valuered
	cmp al, 'p'
	je c1Valuepurple
	cmp al, 'y'
	je c1Valueyellow
	cmp al, 'w'
	je c1Valuewhite
	jmp errCLvalue1

c1ValueBlue:
	mov r10, 255
	mov byte[blue], r10b
	jmp c1Valuefin
c1Valuegreen:
	mov r10, 255
	mov byte[green], r10b
	jmp c1Valuefin

c1Valuered:
	mov r10, 255
	mov byte[red], r10b
	jmp c1Valuefin

c1Valuepurple:
	mov r10, 255
	mov byte[red], r10b
	mov byte[blue], r10b
	jmp c1Valuefin

c1Valueyellow:
	mov r10, 255
	mov byte[red], r10b
	mov byte[green], r10b
	jmp c1Valuefin

c1Valuewhite:
	mov r10, 255
	mov byte[red], r10b
	mov byte[green], r10b
	mov byte[blue], r10b
	jmp c1Valuefin

c1Valuefin:
	mov rax, TRUE
	jmp goBack

Error0:
	mov rdi, errR1value
	call printString
	mov rax, FALSE
	jmp goBack

Error1:
	mov rdi, errR2value
	call printString
	mov rax, FALSE
	jmp goBack

Error2:
	mov rdi, errR2value
	call printString
	mov rax, FALSE
	jmp goBack

Error3:
	mov rdi, errOPvalue
	call printString
	mov rax, FALSE
	jmp goBack

errCLvalue1:
	mov rdi, errCLvalue
	call printString
	mov rax, FALSE
	jmp goBack


goBack:
	pop rbp
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
;	    	 radii = (r1+r2)
;			for (t=0.0; t<360.0; t+=step) {
;	         x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
;	         y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))
;	         plot point (x, y)
;	     }
; 			t += tStep
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
common	speed		1:4		; rortation speed: int, dword, integer value
common	color		1:1		; color code letter: char, byte, ASCII value

global drawSpiro
drawSpiro:

;	SCC PROLOGUE START
	push	rbp
	push	rbx
	push 	r12
	push	r13
	push	r14
	push	r15
; 	SCC PROLOGUE END

; ***** SSTEP CALCULATION START ******

; 	sStep = speed/scale

	mov 		r12d, dword [speed]
	cvtsi2ss	xmm0, r12
	divss		xmm0, dword [scale]
	movss		dword [sStep], xmm0

; ***** SSTEP CALCULATION END ********

; ***** ITERATIONS CALCULATION START ******

; 	iterations = 360.0/tStep

	movss 	xmm0, dword [limit]
	divss	xmm0, dword [tStep]
	movss 	dword [iterations], xmm0

; ***** ITERATIONS CALCULATION END ********

; ***** CONVERSION OF INTS TO FLOATS START *****

	mov 		eax, dword [radius1]
	cvtsi2ss	xmm0, rax
	movss 		dword [fltRadius1], xmm0
	movss 		dword [r1], xmm0

	mov 		eax, dword [radius2]
	cvtsi2ss	xmm0, rax
	movss 		dword [fltRadius2], xmm0
	movss 		dword [r2], xmm0

	mov 		eax, dword [offPos]
	cvtsi2ss 	xmm0, rax
	movss 		dword [fltOffPos], xmm0
	movss 		dword [ofp], xmm0


; 	Both radii added together
	movss	xmm0, dword [fltRadius1]
	addss 	xmm0, dword [fltRadius2]
	movss 	dword [fltRadii], xmm0
	movss 	dword [radii], xmm0

; ***** CONVERSION OF INTS TO FLOATS END *******

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----

; ***** COLOR SET START **************

; 	uses glColor3ub(r, g, b)
	mov 	dil, byte [red]
	mov 	sil, byte [green]
	mov 	dl, byte [blue]
	call 	glColor3ub

; ***** COlOR SET END ****************

; -----
;  Main loop to calculate and then plot the series of (x,y)
;  points based on the spirograph equation.

;	YOUR CODE GOES HERE
	movss xmm0, dword[fltZero]
	movss dword[t], xmm0

drawSpiroTloop:
	movss xmm0, dword[t]
	movss xmm1, dword[limit]
	ucomiss xmm0, xmm1
	jae drawSpiroDone

; Below will be the equation for x
	movss xmm0, dword[t]
	call cosf
	mulss xmm0, dword[radii]			; radii * cos(t)
	movss dword[fltTmp1], xmm0

	movss xmm0, dword[t]
	addss xmm0, dword[s]				; t+s
	divss xmm0, dword[r2]				; (t+s)/r2
	mulss xmm0, dword[radii]			; (r1 + r2) * (t+s)/r2
	call cosf
	mulss xmm0, dword[ofp]				; offPos * (r1 + r2) * (t+s)/r2

	addss xmm0, dword[fltTmp1]			; This is the complete equation for x
	movss dword[x], xmm0 				; Sorting the value into variable x

; Below will be the equation for y
	movss xmm0, dword[t]
	call sinf
	mulss xmm0, dword[radii]			; radii * sin(t)
	movss dword[fltTmp2], xmm0

	movss xmm0, dword[t]
	addss xmm0, dword[s]				; t+s
	divss xmm0, dword[r2]				; (t+s)/r2
	mulss xmm0, dword[radii]			; (r1 + r2) * (t+s)/r2
	call sinf
	mulss xmm0, dword[ofp]				; offPos * (r1 + r2) * (t+s)/r2

	addss xmm0, dword[fltTmp2]			; This is the complete equation for y
	movss dword[y], xmm0 				; Sorting the value into variable y

	movss xmm0, dword[x]
	movss xmm1, dword[y]
	call glVertex2f

	movss xmm0, dword[t]
	addss xmm0, dword[tStep]
	movss dword[t], xmm0
	jmp drawSpiroTloop

drawSpiroDone:


; ********************************
; START MY PROG



; END MY PROG
; ********************************





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

; 	SCC EPILOGUE START
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	pop 	rbp
; 	SCC EPILOGUE END
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

