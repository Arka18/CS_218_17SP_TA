;Blossom Hamika
;Section 1002

; CS 218 - Assignment #10
;  Spirograph - Support Functions.
;  Provided Template

; -----
;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


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
;	- ARGC 	-number of arguments					;rdi
;	- ARGV 											;rsi
;	- radius 1: int, double-word, address 			;rdx
;	- radius 2: int, double-word, address			;rcx
;	- offset position: int double-word, address 	;r8
;	- speed: int, double-word address 				;r9
;	- circle color: char, byte, address 			;rbp + 16

;Check ARGC
;if (argc == 1)
	;use msg
	;exit (f)
;if (argc != 11)
	;err msg
	;exit (f)
;if (argv[1] != "-r1")
	;err msg
	;exit (f)
;get argv[2] /call tri2int
	;if invalid
	;err msg
	;exit (f)
	;if valid
		;check range (max/min)
			;if out of range
				;err msg
				;exit (f)


;	YOUR CODE GOES HERE

;function convert
global tri2int
tri2int:
	push 	rbx
	push 	r12
	push 	r13
	push 	r14
	push 	r15

tri2intStart:
	mov 	r10, 0 						;rSum
	mov 	r11, 0 						;i
	mov 	r13, 13 					;13 to multiply

cvtLp:
	movzx 	r15, byte [rbx + r11] 		;read in chr
	cmp 	r15b, NULL 					;check if input is done
	je 		cvtLpDone
	mov 	rax, r10 					;mov rSum into rax
	mul 	r13 						;multiply rax * 13
	mov 	r10, rax 					;mov the total back to rSum

	cmp 	r15b, "0"
	jb 		tri2intError 				;if below 0 error
	cmp 	r15b, "9"
	jbe 	cvtNum 						;if between 0-9 convert
	cmp 	r15b, "A"
	jb 		tri2intError 				;if between 9-A error
	cmp 	r15b, "C"
	jbe 	cvtUpper 					;if between A-C convert
	cmp 	r15b, "a"
	jb 		tri2intError 				;if between C-a error
	cmp 	r15b, "c"
	jbe 	cvtLower 					;if between a-c convert
	jmp 	tri2intError 				;if anything else error

cvtNum:
	sub 	r15, "0" 					;int = chr - "0"
	jmp 	cvtCharDone

cvtUpper:
	sub 	r15, "A" 					;int = chr - "A"
	add 	r15, 10 					;int = int + 10
	jmp 	cvtCharDone

cvtLower:
	sub 	r15, "a" 					;int = chr - "a"
	add 	r15, 10						; int = int + 10
	jmp 	cvtCharDone

cvtCharDone:
	add 	r10, r15  					;rsum = rsum + int
	inc 	r11
	jmp  	cvtLp

tri2intError:
	mov 	rax, -1  					;if failed it errors out
	jmp 	tri2intDone

cvtLpDone:
	mov 	rax, r10 					;mov int into rax
	jmp 	tri2intDone

tri2intDone:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	ret


;new code
global getRadii
getRadii:
	push 	rbp
	mov 	rbp, rsp
	push 	rbx
	push 	r12
	push 	r13
	push 	r14
	mov 	r15d, dword [rbp + 16]
	push 	r15


argFuncStart:
	cmp 	rdi, 1						;if (argc == 1)
	je 		argUse 						;use msg
	cmp 	rdi, 11 					;if (argc != 11)
	jne 	argBad 						;err msg, errBadCL


;argument r1, range: 0-163 base 13
argR1:
	mov 	r10, 0
	mov 	r10, qword[rsi + 8]	 		;argv[1], -r1
	cmp 	dword[r10], 0x0031722D		;cmp argv[1] to -r1NULL
	je 		checkR1range				;if argv[1] = -r1NULL check range
	mov 	rax, errR1sp 				;if argv[1] != -r1NULL give err
	jmp 	getRadiiDone

checkR1range:
	mov 	rbx, qword[rsi + 16]
	push 	rdx
	call 	tri2int						;check/cvt trinum, int in rax
	pop 	rdx
	mov 	dword [rdx], eax 			;mov converted int into r1
	cmp 	dword [rdx], R1_MAX 		;if int > max
	ja 		argR1false					;return false
	cmp 	dword [rdx], R1_MIN 		;else if int >= min
	jae 	argR1true					;continue

argUse:
	mov 	rax, errUsage 				;only given -r1 give error
	jmp 	getRadiiDone

argBad:
	mov 	rax, errBadCL 				;not 11 arguments give error
	jmp 	getRadiiDone

argR1false:
	mov 	rax, errR1value 			;not in range give error
	jmp 	getRadiiDone

argR1true:
	;continue

;argument r2,range: 1-163 base 13
argR2:
	mov 	r10, 0
	mov 	r10, qword[rsi + 24]		;read "-r2"
	cmp 	dword[r10], 0x0032722D 		;check if == 0x0032722D
	je 		checkR2range 				;equals continue
	mov 	rax, errR2sp 				;does not equal ret errR2sp
	jmp 	getRadiiDone

checkR2range:
	mov 	rbx, qword[rsi + 32]
	call 	tri2int
	mov 	dword [rcx], eax 			;mov converted int into r2
	cmp 	dword [rcx], R2_MAX 		;if int > max
	ja 		argR2false					;return false
	cmp 	dword [rcx], R2_MIN 		;else if int >= min
	jae 	argR2true					;continue

argR2false:
	mov 	rax, errR2value
	jmp 	getRadiiDone

argR2true:
	;continue


;argument op, range: 1-163 base 13
argOP:
	mov 	r10, 0
	mov 	r10, qword[rsi + 40] 		;read "-op"
	cmp 	dword[r10], 0x00706F2D 		;check if == 0x00706F2D
	je 		checkOPrange 				;equals continue
	mov 	rax, errOPsp 				;does not equal ret errOPsp
	jmp 	getRadiiDone

checkOPrange:
	mov 	rbx, qword[rsi + 48]
	call 	tri2int
	mov 	dword [r8], eax
	cmp 	dword [r8], OP_MAX 			;if int > max
	ja 		argOPfalse					;return false
	cmp 	dword [r8], OP_MIN 			;else if int >= min
	jae 	argOPtrue					;continue

argOPfalse:
	mov 	rax, errOPvalue
	jmp 	getRadiiDone

argOPtrue:
	;continue



;argument sp, range 1-79 base 13
argSP:
	mov 	r10, 0
	mov 	r10, qword[rsi + 56] 		;read "-sp"
	cmp 	dword[r10], 0x0070732D 		;check if == 0x0070732D
	je 		checkSPrange 				;equals continue
	mov 	rax, errSPsp  				;does not equal ret errSPsp
	jmp 	getRadiiDone

checkSPrange:
	mov 	rbx, qword[rsi + 64]
	call 	tri2int
	mov 	dword [r9], eax
	cmp 	dword [r9], SP_MAX 			;if int > max
	ja 		argSPfalse					;return false
	cmp 	dword [r9], SP_MIN 			;else if int >= min
	jae 	argSPtrue					;continue

argSPfalse:
	mov 	rax, errSPvalue
	jmp 	getRadiiDone

argSPtrue:
	;continue



;argument cl, options: r/g/b/p/y/w
argCL:
	mov 	r10, 0
	mov 	r10, qword[rsi + 72] 		;read "-cl"
	cmp 	dword[r10], 0x006C632D 		;check if == 0x006C632D
	je 		clRead 						;equals continue
	mov 	rax, errCLsp 				;does not equal ret errCLsp
	jmp 	getRadiiDone

clRead:									;check if chr is r/g/b/p/y/w
	mov 	r10, 0
	mov 	rax, 0
	mov 	rax, qword [rsi + 80]		;address in rax

	cmp 	byte [rax + 1], NULL 		;check if following chr is Null
	je 		compareCl 					;if so check char
	mov 	rax, errCLvalue				;if not give error
	jmp 	getRadiiDone

compareCl: 								;checking char
	cmp 	byte [rax], "r"
	je 		storeRed
	cmp 	byte [rax], "g"
	je 		storeGreen
	cmp 	byte [rax], "b"
	je 		storeBlue
	cmp 	byte [rax], "p"
	je 		storePurple
	cmp 	byte [rax], "y"
	je 		storeYellow
	cmp 	byte [rax], "w"
	je 		storeWhite
	mov 	rax, errCLvalue
	jmp 	getRadiiDone

;store in colors
storeRed:
	mov 	byte [red], 255
	mov 	byte [green], 0
	mov 	byte [blue], 0
	jmp 	incCLRead

storeGreen:
	mov 	byte [red], 0
	mov 	byte [green], 255
	mov 	byte [blue], 0
	jmp 	incCLRead

storeBlue:
	mov 	byte [red], 0
	mov 	byte [green], 0
	mov 	byte [blue], 255
	jmp 	incCLRead

storePurple:
	mov 	byte [red], 255
	mov 	byte [green], 0
	mov 	byte [blue], 255
	jmp 	incCLRead

storeYellow:
	mov 	byte [red], 255
	mov 	byte [green], 255
	mov 	byte [blue], 0
	jmp 	incCLRead

storeWhite:
	mov 	byte [red], 255
	mov 	byte [green], 255
	mov 	byte [blue], 255
	jmp 	incCLRead


;when finished checking everything or there is an error return here
getRadiiDone:
	mov 	rdi, rax
	call 	printString
	mov 	rax, 0
	jmp 	funcDone

incCLRead:
	pop 	r15
	mov 	al, byte [rax]
	mov 	byte [r15], al
	mov 	rax, TRUE

funcDone:
	;pop 	r15
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

	push 	rbp
	mov 	rbp, rsp
	push 	rbx
	push 	r12
	push 	r13
	push 	r14
	push 	r15
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

;	YOUR CODE GOES HERE

startmain:

;set draw color

	movzx 	rdi, byte [red]
	movzx 	rsi, byte [green]
	movzx 	rdx, byte [blue]
	call 	glColor3ub


;convert integer values to float for calculations
	mov 		eax, dword [radius1]
	cvtsi2ss 	xmm1, eax
	movss 		dword [r1], xmm1

	mov 		eax, dword [radius2]
	cvtsi2ss 	xmm2, eax
	movss 		dword [r2], xmm2

	mov 		eax, dword [offPos]
	cvtsi2ss 	xmm3, eax
	movss 		dword [ofp], xmm3

	mov 		eax, dword [speed]
	cvtsi2ss 	xmm4, eax
	movss 		dword [s], xmm4  ;speed


;sStep = speed/scale
	divss 		xmm4, dword [scale]
	movss		dword [sStep], xmm4


;radii = r1 + r2
	movss		xmm5, dword [r1]
	addss 		xmm5, dword [r2]
	movss 		dword [radii], xmm5

;set t to 0.0
	movss 		xmm6, dword[fltZero]
	movss 		dword[t], xmm6

;start loop
startDrawLp:

;fltTmp2 = radii * ((t + s)/ r2)
	movss 	xmm0, dword [t]
	addss 	xmm0, dword [s] 					;xmm0 = t + s
	divss 	xmm0, dword [r2] 					;xmm0/r2
	mulss 	xmm0, dword [radii] 				;xmm0*radii
	movss 	dword [fltTmp2], xmm0 				;fltTmp2 = xmm0

;fltTmp1 = offpos * cos (fltTmp2)
	movss 	xmm0, dword [fltTmp2]				;xmm0 = fltTmp2
	call 	cosf 								;cos (fltTmp2)
	mulss 	xmm0, dword [ofp] 					;xmm0 * offpos
	movss 	dword [fltTmp1], xmm0 				;fltTmp1 = xmm0

; xmm0 = radii * cos(t) + fltTmp1
	movss 	xmm0, dword [t]
	call 	cosf								;cos(t)
	mulss 	xmm0, dword [radii] 				;radii * cos(t)
	addss 	xmm0, dword [fltTmp1]				;+ fltTmp1
	movss 	dword [x], xmm0

;fltTmp1 = offpos * sin (fltTmp2)
	movss 	xmm0, dword [fltTmp2]				;xmm0 = fltTmp2
	call 	sinf 								;sin (fltTmp2)
	mulss 	xmm0, dword [ofp] 					;xmm0 * offpos
	movss 	dword [fltTmp1], xmm0 				;fltTmp1 = xmm0

; xmm0 = radii * sin(t) + fltTmp1
	movss 	xmm0, dword [t]
	call 	sinf								;sin(t)
	mulss 	xmm0, dword [radii] 				;radii * sin(t)
	addss 	xmm0, dword [fltTmp1]				;+ fltTmp1
	movss 	dword [y], xmm0

;plot point (x, y)
	movss 	xmm0, dword [x]
	movss 	xmm1, dword [y]
 	call 	glVertex2f

;t = t + tstep
	movss 		xmm6, dword [t]
	addss 		xmm6, dword [tStep]
	movss 		dword [t], xmm6
	ucomiss 	xmm6, dword [limit]
	jb 		startDrawLp




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
endmain:
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

