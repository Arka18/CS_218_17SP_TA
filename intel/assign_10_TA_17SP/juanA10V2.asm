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
s2		dd 	0.0
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




;***FOR THE TRI TO INT MACRO
intDigit	dd 0
rSum		dd 0
weight		dd 13

rad1			dd 0 
rad2			dd 0
ofsp			dd	0
spd 			dd 0

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
;	- ARGC											-rdi 
;	- ARGV											-rsi 
;	- radius 1: int, double-word, address			-rdx &
;	- radius 2: int, double-word, address			-rcx &
;	- offset position: int double-word, address		-r8  &
;	- speed: int, double-word address				-r9  &
;	- circle color: char, byte, address				-[rbp + 16] &


;	YOUR CODE GOES HERE

global getRadii
getRadii:

	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14
	mov r15d, dword[rbp + 16]
	push r15
	


funcStart:
	
	;errUsage
	;compare rdi which contains the value of arguements.
	;if there is 0 arguments then errorUsage 
	cmp rdi, 1
	je errorUsage

	;errBadCL
	cmp rdi, 11
	jne errorBadCL

	;errR1sp
	mov rbx, qword[rsi + 8]
	cmp dword[rbx], 0x0031722d
	jne errorR1sp

	;errR1value 
	push rdi
	push r9
	push r8
	push rcx
	push rdx
	mov rbx, qword[rsi + 16]
	lea edi, dword[rad1]
	call tri2int
	cmp dword[rad1], R1_MIN 
	jb errorR1value
	cmp dword[rad1], R1_MAX
	ja errorR1value

	;store
	pop rdx
	mov eax, dword[rad1]
	mov dword[rdx], eax

	;errR2sp
	pop rdi
	mov rbx, qword[rsi + 24]
	cmp dword[rbx], 0x0032722d
	jne errorR2sp

	;errR2value
	push rdi  
	mov rbx, qword[rsi + 32]
	lea edi, dword[rad2]
	call tri2int
	cmp dword[rad2], R2_MIN
	jb errorR2value
	cmp dword[rad2], R2_MAX
	ja errorR2value

	;store
	pop rcx
	mov eax, dword[rad2]
	mov dword[rcx], eax


	;errOPsp
	pop rdi
	mov rbx, qword[rsi + 40]
	cmp dword[rbx], 0x00706f2d
	jne errorOPsp

	;errOPvalue
	push rdi
	mov rbx, qword[rsi + 48]
	lea edi, dword[ofsp]
	call tri2int
	cmp dword[ofsp], OP_MIN
	jb errorOPvalue
	cmp dword[ofsp], OP_MAX
	ja errorOPvalue

	;store
	pop r8
	mov eax, dword[ofsp]
	mov dword[r8], eax
	
	;errSPsp
	pop rdi
	mov rbx, qword[rsi + 56]
	cmp dword[rbx], 0x0070732d
	jne errorSPsp

	;errSPvalue
	push rdi 
	mov rbx, qword[rsi + 64]
	lea edi, dword[spd]
	call tri2int 
	cmp dword[spd], SP_MIN
	jb errorSPvalue 
	cmp dword[spd], SP_MAX
	ja errorSPvalue

	;store
	pop r9
	mov eax, dword[spd]
	mov dword[r9], eax

	;errCLsp
	pop rdi 
	mov rbx, qword[rsi + 72]
	cmp dword[rbx], 0x006c632d
	jne errorCLsp 

	;errCLvalue
	mov rbx, qword[rsi + 80]

	;can only be one byte
	cmp byte[rbx + 1], NULL
	jne errorCLvalue

	;red
	mov byte[red], 255
	mov byte[green], 0
	mov byte[blue], 0

	cmp byte[rbx], 0x0072 ;'r'
	je successfulEnd 

	;green
	mov byte[red], 0
	mov byte[green], 255
	mov byte[blue],0

	cmp byte[rbx], 0x0067
	je successfulEnd

	;blue
	mov byte[red], 0
	mov byte[green], 0
	mov byte[blue], 255

	cmp byte[rbx], 0x0062
	je successfulEnd

	;purple
	mov byte[red], 255
	mov byte[green], 0
	mov byte[blue], 255

	cmp byte[rbx], 0x0070
	je successfulEnd

	;yellow
	mov byte[red], 255
	mov byte[green], 255
	mov byte[blue], 0

	cmp byte[rbx], 0x0079
	je successfulEnd

	;white
	mov byte[red], 255
	mov byte[green], 255
	mov byte[blue], 255

	cmp byte[rbx], 0x0077
	je successfulEnd

	jmp errorCLvalue




;***errUsage
;Usage: ./spiro -r1 <triDecimal> -r2 <triDecimal> 
;        -op <triDecimal> -sp <1-9> -cl <b/g/r/y/p/w>
errorUsage:
mov rax, errUsage
jmp printError


;***errBadCL
;Error, invalid or incomplete command line argument
errorBadCL:
mov rax, errBadCL
jmp printError 


;***errR1sp
;Error, radius 1 specifier incorrect
errorR1sp:
mov rax, errR1sp
jmp printError


;***errR1value
;Error, radius 1 value must be between 0 and 163(13)
errorR1value:
mov rax, errR1value
jmp printError


;***errR2sp
;Error, radius 2 specifier incorrect
errorR2sp:
mov rax, errR2sp
jmp printError


;***errR2value
;Error, radius 2 value must be between 1 and 163(13).
errorR2value:
mov rax, errR2value
jmp printError


;***err0Psp
;Error, offset position specifier incorrect.
errorOPsp:
mov rax, errOPsp
jmp printError


;***err0value
;Error, offset position value must be between 1 and 163(13).
errorOPvalue:
mov rax, errOPvalue
jmp printError


;***errSPsp
;Error, speed specifier incorrect.
errorSPsp:
mov rax, errSPsp
jmp printError


;***errSPvalue
;Error, speed value must be between 1 and 79(13).
errorSPvalue:
mov rax, errSPvalue
jmp printError


;***errCLsp
;Error, color specifier incorrect.
errorCLsp:
mov rax, errCLsp
jmp printError


;***errCLvalue
;Error, color value must be b, g, r, p, or w.
errorCLvalue:
mov rax, errCLvalue 
jmp printError


printError:
	mov rdi, rax 
	call printString
	mov rax, 0
	jmp funcEnd

successfulEnd
	pop r15
	mov al, byte[rbx]
	mov byte[r15], al 
	mov rax, TRUE	

funcEnd:

	;pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

;*******************************************************************

;rdi address of number
;rsi address of stored number

global tri2int 
tri2int:
	; mov rax, 0
	; mov rcx, 0 

	;mov rbx, rsi 

	mov r12, 0	;weight
	mov r13, 0	;counter
	mov r14, 0  ;intDigit
	mov r15, 0 	;rSum

	nxtSpc:
		mov al, byte[rbx] ;CL = READ IN CHAR

		cmp al, ' ' ;COMPARE CHAR IS ' ' (SPACE)
		jne skpDone ;IF CHAR != ' ' THEN JUMP TO skpDone
		;inc r13	
		inc rbx	;rsi++
		jmp nxtSpc ;IF THE CHAR IS A SPACE GO BACK TO nxtSpc

		;SKIP DONE LOOP
		skpDone:
		mov r15, 0 ;r15 = rSUM
		jmp cntLp2
		;CONVERT LOOP
		cntLp:
		mov al, byte[rbx] ;MOVE THE CHAR READ IN INTO CL REGISTER

		cntLp2:
		cmp al, NULL ;COMPARING CL(THE CHAR READ IN) WITH NULL 
		je cntDone 	;IF THE CL IS NULL, GO TO cntDone


		;****ERROR CHECKING ******
		cmp al, '0'
		jb invalidInput

		cmp al,'9'
		jbe validInput

		cmp al, 'A'
		jb invalidInput

		cmp al, 'C'
		jbe validInput

		cmp al, 'a'
		jb invalidInput

		cmp al, 'c'
		jbe validInput

		jmp invalidInput


		validInput:
		;***LOWER CASE***
		cmp al, 'a'
		jb next 	;IF CHAR IS < 'a' THEN JUMP TO next ELSE...
			sub al, 'a' ;SUBTRACT CHAR - 'a'
			add al, 10	;ADD 10
			movzx eax, al ;CONVERT FROM SMALL REGISTER TO BIG
			mov r14d, eax ;MOVE ANSWER INTO intDigit ;R14 == intDigit
			jmp nextDone ;jump to nextDone


		;***UPPER CASE***
		next:		
		cmp al, 'A' 
		jb next2  ;IF CHAR IS < 'A' THEN JUMP TO next2 ELSE...
			sub al, 'A' ;SUBTRACT CHAR - 'A'
			add al, 10  ;ADD 10
			movzx eax, al ;CONVERT FROM SMALL REGISTER TO BIG
			mov r14d, eax ;MOVE ANSWER INTO intDigit
			jmp nextDone ;jump to nextDone

		;***NUMBERS CASE***
		next2: ;THIS IS DEFAULT CASE SO IT HAS TO BE A NUM FROM 0 TO 9
		sub al, '0' ;SUBTRACT CHAR - '0'
		movzx eax, al ;CONVERT FROM SMALL REGISTER TO BIG
		mov r14d, eax ;MOVE ANSWER INTO intDigit

		nextDone:
		mov eax, r15d ;eax = rSum
		mov r12d, 13
		mul r12d ;eax * 13
		add eax, r14d ;intDigit + eax
		
		mov r15d, eax  ;rSum = eax
		;mov dword[rSum+4], edx ;rSum = eax
		inc rbx
		;inc r13 ;rsi
		jmp cntLp
		cntDone:

		mov ecx, r15d ; r15d = rSum
		mov dword[rdi], ecx
		jmp validInput2

invalidInput:
	mov dword[rdi], 1000



validInput2:

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
;	         //t += tStep
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

	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14
	push r15
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



	;***SET THE COLORS

	mov rdi, 0
	mov rsi, 0
	mov rdx, 0

	mov dil, byte[red]
	mov sil, byte[green]
	mov dl, byte[blue]

	call glColor3ub


	;****CONVERT THE VARIABLES
	cvtsi2ss xmm0, dword[radius1]
	movss dword[r1], xmm0

	cvtsi2ss xmm1, dword[radius2]
	movss dword[r2], xmm1

	cvtsi2ss xmm2, dword[speed]
	movss dword[s2], xmm2 

	cvtsi2ss xmm3, dword[offPos]
	movss dword[ofp], xmm3
	
	
	;****SET sStep
	movss xmm2, dword[s2]
	divss xmm2, dword[scale]
	movss dword[sStep], xmm2


	;***set radii 
	addss xmm0, xmm1
	movss dword[radii], xmm0


	;***set t
	movss xmm0, dword[fltZero]
	movss dword[t], xmm0


drawloop:
;*COS********************************	
	;t+s
	movss xmm0, dword[t]
	addss xmm0, dword[s]
	;divide by radius 2
	divss xmm0, dword[r2]
	;multiply by radii
	mulss xmm0, dword[radii]
	;cosine of all this
	call cosf

	;multiply offPos
	mulss xmm0, dword[ofp] 

	movss dword[fltTmp1], xmm0

	;cos t
	movss xmm0, dword[t]
	call cosf
	;multiply radii
	mulss xmm0, dword[radii]

	;add two parts together
	addss xmm0, dword[fltTmp1]


	movss dword[x], xmm0

;*SIN***********************************
	;t+s
	movss xmm0, dword[t]
	addss xmm0, dword[s]
	;divide by radius 2
	divss xmm0, dword[r2]
	;multiply by radii
	mulss xmm0, dword[radii]
	;cosine of all this
	call sinf

	;multiply offPos
	mulss xmm0, dword[ofp] 

	movss dword[fltTmp2], xmm0

	;cos t
	movss xmm0, dword[t]
	call sinf
	;multiply radii
	mulss xmm0, dword[radii]

	;add two parts together
	addss xmm0, dword[fltTmp2]


	movss dword[y], xmm0
;****************************************************

	movss xmm0, dword[x]
	movss xmm1, dword[y]
	call glVertex2f

	movss xmm1, dword[tStep]
	movss xmm0, dword[t]
	addss xmm0, xmm1
	movss dword[t], xmm0


	ucomiss xmm0, dword[limit]
	jb drawloop



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

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp
	
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

