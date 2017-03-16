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
%macro 	tri2int	2
; 	%1 = string address
; 	%2 = return flag = r12
;		1 = errorR1value
;		2 = errorR2value
;		3 = errorOPvalue
; 		4 = errorSPvalue

%%tri2intStart:
	mov 	rbx, %1
	mov 	rax, 0
	mov 	r10, 0 			; i = 0
	mov 	r11, 0			; r11 = rSum

%%tri2intConvert:
	mov 	r15, 0
	mov 	r15b, byte [rbx + r10] 	; get str[i]
	cmp 	r15b, NULL 		; if(endOfString)
	je 	%%tri2intSuccess

	mov 	r14, 13
	mov 	rax, r11 		; rSum
	mul 	r14d			; rSum * 13
	mov 	r11, rax

	;convert digit
	cmp 	r15b, "c"
	ja 	%%tri2intError
	cmp 	r15b, "a"
	jae 	%%tri2intLower
	cmp 	r15b, "C"
	ja 	%%tri2intError
	cmp 	r15b, "A"
	jae 	%%tri2intUpper
	cmp 	r15b, "9"
	ja 	%%tri2intError
	cmp 	r15b, "0"
	jae 	%%tri2intNumber

%%tri2intLower:
	sub 	r15b, "a"
	add 	r15b, 10
	jmp 	%%charConvertDone

%%tri2intUpper:
	sub 	r15b, "A"
	add 	r15b, 10
	jmp 	%%charConvertDone

%%tri2intNumber:
	sub 	r15b, "0"
	jmp 	%%charConvertDone

%%charConvertDone:
	add 	r11, r15 		; rSum += digit
	inc 	r10			; i++
	jmp 	%%tri2intConvert

%%tri2intError:
	jmp 	%%tri2intConvertDone

%%tri2intSuccess:
	mov 	r12, 0
	jmp 	%%tri2intConvertDone

%%tri2intConvertDone:
	mov 	rax, r11

%endmacro


; ---------------------------------------------------------
int2tri
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
;	Gets radius 1, radius 2, offset positionm and rottaion
;	speedvalues and color code letter from the command line.

;	Performs error checking, converts ASCII/Tridecimal string
;	to integer.  Required ommand line format (fixed order):
;	  "-r1 <triDecimal> -r2 <triDecimal> -op <triDecimal>
;			-sp <triDecimal> -cl <color>"

; -----
;  Arguments:
;	- ARGC						- rdi
;	- ARGV						- rsi
;	- radius 1, double-word, address		- rdx
;	- radius 2, double-word, address 		- rcx
;	- offset Position, double-word, address		- r8
;	- speed value, double-word, address		- r9
;	- circle color, byte, address			- stack [rbp + 16]


;	YOUR CODE GOES HERE
global getRadii
getRadii:
	push	rbp
	mov 	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
	; SCC Prologue
	push 	r9
	push	r8
	push 	rcx
	push 	rdx
getRadiiStart:
	cmp 	rdi, 1			; if only one argument
	je 	errorUsage

	cmp 	rdi, 11			; if arg count incorrect
	jne 	errorBadCL

; "-r1" argument

	mov 	rbx, qword [rsi + 8] 	; arg 2
	cmp 	dword [rbx], 0x0031722d ; if arg 2 == "-r1"
	jne 	errorR1sp

	mov 	rbx, qword [rsi + 16] 	; arg 3
	mov 	r12, 1			; call code for errorR1value
	tri2int rbx, r12
	cmp 	r12, 1
	je 	errorR1value
	cmp 	rax, R1_MIN
	jl 	errorR1value
	cmp 	rax, R1_MAX
	jg 	errorR1value

	pop 	rdx
	mov 	dword [rdx], eax

; "-r2" argument

	mov 	rbx, qword [rsi + 24] 	; arg 4
	cmp 	dword [rbx], 0x0032722d	; if arg 4 == "-r2"
	jne 	errorR2sp

	mov 	rbx, qword [rsi + 32] 	; arg 5
	mov 	r12, 2 			; call code for errorR2value
	tri2int	rbx, r12
	cmp 	r12, 2
	je 	errorR2value
	cmp 	rax, R2_MIN
	jl 	errorR2value
	cmp 	rax, R2_MAX
	jg 	errorR2value

	pop 	rcx
	mov 	dword [rcx], eax

; "-op" argument

	mov 	rbx, qword [rsi + 40] 	; arg 6
	cmp 	dword [rbx], 0x00706f2d ; if arg 6 == "-op"
	jne 	errorOPsp

	mov 	rbx, qword [rsi + 48] 	; arg 7
	mov 	r12, 3
	tri2int	rbx, r12
	cmp 	r12, 3
	je 	errorOPvalue
	cmp 	rax, OP_MIN
	jl 	errorOPvalue
	cmp 	rax, OP_MAX
	jg 	errorOPvalue

	pop 	r8
	mov 	dword [r8], eax

; "-sp" argument

	mov 	rbx, qword [rsi + 56]	; arg 8
	cmp 	dword [rbx], 0x0070732d ; if arg 8 == "-sp"
	jne 	errorSPsp

	mov 	rbx, qword [rsi + 64] 	; arg 9
	mov 	r12, 4
	tri2int	rbx, r12
	cmp 	r12, 4
	je 	errorSPvalue
	cmp 	rax, SP_MIN
	jl 	errorSPvalue
	cmp 	rax, SP_MAX
	jg 	errorSPvalue

	pop 	r9
	mov 	dword [r9], eax

; "-cl" argument

	mov 	rbx, qword [rsi + 72]	; arg 10
	cmp 	dword [rbx], 0x006c632d ; if arg 10 == "-cl"
	jne 	errorCLsp

	mov 	rbx, qword [rsi + 80] 	; arg 11
	movzx 	ra,x byte [rbx]
	cmp 	al, "b"		; "b"
	je 	clValueDone
	cmp 	al, "g"		; "g"
	je 	clValueDone
	cmp 	al, "r"		; "r"
	je 	clValueDone
	cmp 	al, "p"		; "p"
	je 	clValueDone
	cmp 	al, "w"		; "w"
	je 	clValueDone
	jmp 	errorCLvalue

clValueDone:
	mov 	al, byte [rbx]
	movzx 	rax, al
	mov 	rbx, qword [rbp + 16]
	mov 	byte [rbx], al

; DONE JUMP TO SUCCESS
	jmp 	getRadiiSuccess

; -------------------------------------------------
; ERRORS START

errorUsage:
	mov 	rax, errUsage
	jmp 	printError

errorBadCL:
	mov 	rax, errBadCL
	jmp 	printError

errorR1sp:
	mov 	rax, errR1sp
	jmp 	printError

errorR1value:
	mov 	rax, errR1value
	jmp 	printError

errorR2sp:
	mov 	rax, errR2sp
	jmp 	printError

errorR2value:
	mov 	rax, errR2value
	jmp 	printError

errorOPsp:
	mov 	rax, errOPsp
	jmp 	printError

errorOPvalue:
	mov 	rax, errOPvalue
	jmp 	printError

errorSPsp:
	mov 	rax, errSPsp
	jmp 	printError

errorSPvalue:
	mov 	rax, errSPvalue
	jmp 	printError

errorCLsp:
	mov 	rax, errCLsp
	jmp 	printError

errorCLvalue:
	mov 	rax, errCLvalue
	jmp 	printError

printError:
	mov 	rdi, rax
	call 	printString
	mov 	rax, FALSE
	jmp 	getRadiiEnd

; END ERRORS
; ----------------------------------------------------------


getRadiiSuccess:
	mov 	rax, SUCCESS

getRadiiEnd:
	; SCC Epilogue
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	mov 	rsp, rbp
	pop 	rbp
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
;  Global variables accessed
;	There are defined and set in the main, accessed herein by
;	name as per the below declarations.

common	radius1		1:4		; radius 1, dword, integer value
common	radius2		1:4		; radius 2, dword, integer value
common	offPos		1:4		; offset position, dword, integer value
common	speed		1:4		; rortation speed, dword, integer value
common	color		1:1		; color code letter, byte, ASCII value

global drawSpiro
drawSpiro:

; -----

; SCC SAVE RGISTERS
	push 	rbp
	mov 	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15


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

;	YOUR CODE GOES HERE





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




drawSpiroEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	mov 	rsp, rbp
	pop 	rbp
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

