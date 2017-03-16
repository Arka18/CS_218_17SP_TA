;  CS 218 - Assignment #10
;  Spirograph - Support Functions.
;  Provided Template
;	Richie Abenoja
; -----
;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;	MACROS (if any) GO HERE
; -----
; Converts tridecimal to decimal
; Arguments:
; %1 -> string address(reg)
; %2 -> integer number destination address
%macro tri2int 2

push rax
push rsi
push r10
push rcx

%%initialize:
		mov rax, 0
		mov rsi, 0
		mov r10d, 13
		mov rcx, 0

	%%convert:
		mov cl,	byte[%1 + rsi]
		cmp cl, NULL 							; if at end of String
		je %%convertEnd

	%%checkOne:
		; If "0" to "9"
		cmp cl, "0"
		jl %%notValid
		cmp cl, "9"
		jg %%checkTwo
		jmp %%convertDigit

	%%checkTwo:
		; If "A" - "C"
		cmp cl, "A"
		jl %%notValid
		cmp cl, "C"
		jg %%checkThree
		jmp %%convertUpper

	%%checkThree:
		; If "a" - "c"
		cmp cl, "a"
		jl %%notValid
		cmp cl, "c"
		jg %%notValid
		jmp %%convertLower

	%%notValid:
		; If input is invalid
		jmp %%end

	%%convertDigit:
		; Converts to decimal if "0" - "9"
		sub cl, "0"
		jmp %%xThirteen

	%%convertUpper:
		; Converts to decimal if "A" - "C"
		sub cl, "A"
		add cl, 10
		jmp %%xThirteen

	%%convertLower:
		; Converts to decimal if "a" - "c"
		sub cl, "a"
		add cl, 10
		jmp %%xThirteen

	%%xThirteen:
		; Calculates the base 13 conversion
		mul r10d
		add rax, rcx
		mov rcx, 0
		mov cl, byte[%1 + rsi]
		inc rsi
		jmp %%convert

	%%valueTooLarge:
		; When value is too large
		jmp %%end

	%%convertEnd:
		; End of Conversion
		mov %2, eax
		jmp %%end

	%%end:

pop rcx
pop r10
pop rsi
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
tmp			dd 	0.0

t		dd	0.0			; loop variable
s		dd	0.0			; phase variable
tStep	dd	0.01		; t step
sStep	dd	0.0			; s step
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
push r12
push r13
push r14
push r15
push rbx

mov r12, rdi 					; Copy of ARGC
mov r13, rsi					; Copy of ARGV
mov r14, rdx					; Copy of radius 1
mov r15, rcx 					; Copy of radius 2
mov rbx, r8 					; Copy of Offset position
mov r10, r9 					; Copy of Speed

;-----
; Check argument Count-----
cmp r12, 1
je errMsg1
cmp r12, 11
jne errMsg2

;-----
; Check argument vector

mov r11, qword[r13 + 8 * 1]		; Check if argv[1] == "-r1"
cmp dword[r11], 0x0031722D  	; 0x0031722D is HEX for "-r1"
jne errMsg3

mov r11, qword[r13 + 8 * 2]		; Check if -r1 value is between 0 - 163(13).
tri2int r11, edi  				; 0 - 250(10).
cmp edi, 0
jl errMsg4
cmp edi, 250
jg errMsg4
mov dword[r14], edi

mov r11, qword[r13 + 8 * 3] 	; Check if argv[3] == "-r2"
cmp dword[r11], 0x0032722D 		; 0x0032722D is HEX for "-r2"
jne errMsg5

mov r11, qword[r13 + 8 * 4]		; Check if -r2 value is between 0 - 163(13).
tri2int r11, edi 				; 0 - 250(10).
cmp edi, 0
jl errMsg6
cmp edi, 250
jg errMsg6
mov dword[r15], edi

mov r11, qword[r13 + 8 * 5] 	; Check if argv[5] == "-op"
cmp dword[r11], 0x00706F2D 		; 0x00706F2D is HEX for "-op"
jne errMsg7

mov r11, qword[r13 + 8 * 6]		; Check if -op value is between 1 - 163(13).
tri2int r11, edi				; 1 - 250(10).
cmp edi, 1
jl errMsg8
cmp edi, 250
jg errMsg8
mov dword[rbx], edi

mov r11, qword[r13 + 8 * 7]		; Check if argv[7] == "-sp"
cmp dword[r11], 0x0070732D 		; 0x0070732D is HEX for "-sp"
jne errMsg9

mov r11, qword[r13 + 8 * 8]		; Check if -sp value is between 1-79(13).
tri2int r11, edi 				; 1 - 100(10).
cmp edi, 1
jl errMsg10
cmp edi, 100
jg errMsg10
mov dword[r10], edi

mov r11, qword[r13 + 8 * 9]		; Check if argv[9] == "-cl"
cmp dword[r11], 0x006C632D 		; 0x006C632D is HEX for "-cl"
jne errMsg11

mov r11, qword[r13 + 8 * 10]

chkBlue:
cmp byte[r11], 0x62
jne chkGreen
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

chkGreen:
cmp byte[r11], 0x67
jne chkRed
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

chkRed:
cmp byte[r11], 0x72
jne chkPurple
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

chkPurple:
cmp byte[r11], 0x70
jne chkYellow
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

chkYellow:
cmp byte[r11], 0x79
jne chkWhite
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

chkWhite:
cmp byte[r11], 0x77
jne errMsg12
mov rcx, qword[rbp + 16]
mov r9b, byte[r11]
mov byte[rcx], r9b
jmp readComplete

readComplete:

mov rax, TRUE 					; If run is successful

pop rbx
pop r15
pop r14
pop r13
pop r12
mov rsp, rbp
pop rbp

ret



errMsg1:
; When the user inputs 1 string of data
	mov rdi, errUsage
	call printString
	jmp done

errMsg2:
; When the user inputs an input of less than 11
	mov rdi, errBadCL
	call printString
	jmp done

errMsg3:
; When the user inputs incorrect string syntax for radius 1
; Correct Syntax: "-r1"
	mov rdi, errR1sp
	call printString
	jmp done

errMsg4:
; When the user inputs an invalid radius 1 value
; Must be between 0 and 163(13).
	mov rdi, errR1value
	call printString
	jmp done

errMsg5:
; When the user inputs incorrect string syntax for radius 2
; Correct Syntax: "-r2"
	mov rdi, errR2sp
	call printString
	jmp done

errMsg6:
; When the user inputs an invalid radius 2 value
; Must be between 0 and 163(13).
	mov rdi, errR2value
	call printString
	jmp done

errMsg7:
; When the user inputs incorrect string syntax for Offset position
; Correct Syntax: "-op"
	mov rdi, errOPsp
	call printString
	jmp done

errMsg8:
; When the user inputs an invalid offset position value
; Must be between 1 and 163(13).
	mov rdi, errOPvalue
	call printString
	jmp done

errMsg9:
; When the user inputs incorrect string syntax for Speed specifier
; Correct Syntax: "-sp"
	mov rdi, errSPsp
	call printString
	jmp done

errMsg10:
; When the user inputs an invalid Speed value
; Must be between 1 and 79(13).
	mov rdi, errSPvalue
	call printString
	jmp done

errMsg11:
; When the user inputs incorrect string syntax for the Color Specifier
; Correct Syntax: "-cl"
	mov rdi, errCLsp
	call printString
	jmp done

errMsg12:
; When the user inputs incorrect color value
; Valid Inputs: "b", "g", "r", "p", "w".
	mov rdi, errCLvalue
	call printString
	jmp done

done:
	mov rax, FALSE

pop rbx
pop r15
pop r14
pop r13
pop r12
mov rsp, rbp
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

push r12
push r13
push r14
push r15
push rbx

; -----
; Draw Speed
; sStep = speed / scale
	mov eax, dword[speed]
	cvtsi2ss xmm3, eax
	divss xmm3, dword[scale]
	movss dword[sStep], xmm3

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
; Convert values to floating point
	cvtsi2ss xmm0, dword[radius1]
	movss dword[r1], xmm0

	cvtsi2ss xmm0, dword[radius2]
	movss dword[r2], xmm0

	cvtsi2ss xmm0, dword[offPos]
	movss dword[ofp], xmm0

; -----
; radii = (r1 + r2)
	movss xmm7, dword[r1]
	addss xmm7, dword[r2]
	movss dword[radii], xmm7




; -----
; Set the Color to be drawn
; call glColor3ub(red, green, blue)
	
colorSet:
	mov rdi, 0			; Clear the registers to pass
	mov rsi, 0
	mov rdx, 0
	mov rax, 0
	mov al, byte[color]

setRed:
	cmp al, "r"
	jne setGreen
	mov rdi, 255
	mov rsi, 0
	mov rdx, 0
	call glColor3ub
	jmp colorDone

setGreen:
	cmp al, "g"
	jne setBlue
	mov rdi, 0
	mov rsi, 255
	mov rdx, 0
	call glColor3ub
	jmp colorDone

setBlue:
	cmp al, "b"
	jne setPurple
	mov rdi, 0
	mov rsi, 0
	mov rdx, 255
	call glColor3ub
	jmp colorDone

setPurple:
	cmp al, "p"
	jne setYellow
	mov rdi, 255
	mov rsi, 0
	mov rdx, 255
	call glColor3ub
	jmp colorDone

setYellow:
	cmp al, "y"
	jne setWhite
	mov rdi, 255
	mov rsi, 255
	mov rdx, 0
	call glColor3ub
	jmp colorDone

setWhite:
	cmp al, "w"
	jne colorDone
	mov rdi, 255
	mov rsi, 255
	mov rdx, 255
	call glColor3ub
	jmp colorDone

colorDone:


; -----
;  Main loop to calculate and then plot the series of (x,y)
;  points based on the spirograph equation.

; -----
; Clear t
	movss xmm6, dword[fltOne]
	movss dword[t], xmm6

drawImage:

; -----
; x = radii * cos(t) + [offPos * cos( (r1 + r2) * (t+s)/r2) ]

	; radii * cos(t)
	movss xmm0, dword[t]
	call cosf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1], xmm0

	; [offPos * cos( (r1 + r2) * (t+s)/r2) ]
	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0, dword[r2]
	mulss xmm0, dword[radii]
	call cosf
	mulss xmm0, dword[ofp]

	addss xmm0, dword[fltTmp1]
	movss dword[x], xmm0

; -----
; y = [ (r1 + r2) * sin(t)] + [offPos * sin( (r1+r2) * (t+s)/r2 ) ]

	; (r1 + r2) * sin(t)
	movss xmm0, dword[t]
	call sinf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1], xmm0

	; [offPos * sin( (r1+r2) * (t+s)/r2 ) ]
	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0, dword[r2]
	mulss xmm0, dword[radii]
	call sinf
	mulss xmm0, dword[ofp]

	addss xmm0, dword[fltTmp1]
	movss dword[y], xmm0

	movss xmm0, dword[x]
	movss xmm1, dword[y]
	call glVertex2f

; -----
; t = t + tstep
	movss xmm5, dword[t]
	addss xmm5, dword[tStep]
	movss dword[t], xmm5

; -----
; if t > 360.0
	movss xmm0, dword[t]
	ucomiss xmm0, dword[limit]
	jb drawImage

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

	pop	rbx
	pop r15
	pop r14
	pop r13
	pop r12
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
