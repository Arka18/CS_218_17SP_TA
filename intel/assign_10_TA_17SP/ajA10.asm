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

LF			equ	10
SPACE		equ	" "
NULL		equ	0
ESC			equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS			equ	0
GL_POLYGON			equ	9
GL_PROJECTION		equ	5889

GLUT_RGB			equ	0
GLUT_SINGLE			equ	0

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
;  You are NOT required to use these variables. If you want, feel free to use these variables or just define your own variables as desired.


fltOne		dd	1.0
fltZero		dd	0.0
fltTmp1		dd	0.0
fltTmp2		dd	0.0

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
;	- ARGC -- rdi
;	- ARGV -- rsi
;	- radius 1: int, double-word, address -- rdx
;	- radius 2: int, double-word, address -- rcx
;	- offset position: int double-word, address -- r8
;	- speed: int, double-word address -- r9
;	- circle color: char, byte, address -- [rbp+16]

global getRadii
getRadii:
;	YOUR CODE GOES HERE

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

; saves arguments
	push rsi
	push rdi
	push rdx

; pushing arguments for later
	mov rbx, qword[rbp+16]  		; color
	push rbx						; color
	push r9							; speed
	push r8							; operation
	push rcx						; R2
	push rdx						; R1


; Checks if you have enough arguments
	cmp rdi, 1  					; if line is empty,
	je PrintErrorUsage				; jump to PrintErrorUsage
	cmp rdi, 11						; if argc != 11
	jne EBadCommandLine				; print ErrorBadCl

CheckR1Command:
	mov rbx, qword[rsi+8] 			; gets address of -r1
	cmp dword[rbx], 0x0031722d		; checks to see if it actually is "-r1"
	jne R1Error

	mov rdi, qword[rsi+16]
	call tri2int
	cmp rax, -1						; if tri2int failed, call R1Error
	je R1ValueError
	cmp rax, R1_MAX					; Check if tri2int number is above R1_MAX
	jg R1ValueError					; If > give error
	cmp rax, R1_MIN 				; Check if tri2int number is below R1_MIN
	jl R1ValueError
	pop rbx
	mov dword[rbx], eax

CheckR2Command:
	mov rbx, qword[rsi+24] 			; gets address of -r2
	cmp dword[rbx], 0x0032722d		; checks to see if it actually is "-r2"
	jne R2Error

	mov rdi, qword[rsi+32]
	call tri2int
	cmp rax, -1						; if tri2int failed, call R2Error
	je R2ValueError
	cmp rax, R2_MAX					; Check if tri2int number is above R2_MAX
	jg R2ValueError					; If > give error
	cmp rax, R2_MIN
	jl R2ValueError					; If < give error
	pop rbx
	mov dword[rbx], eax

CheckOPCommand:
	mov rbx, qword[rsi+40] 			; gets address of -op
	cmp dword[rbx], 0x00706f2d		; checks to see if it actually is "-op"
	jne OPError

	mov rdi, qword[rsi+48]
	call tri2int
	cmp rax, -1						; if tri2int failed, call OPError
	je OPValueError
	cmp rax, OP_MAX					; Check if tri2int number is above OP_MAX
	jg OPValueError
	cmp rax, OP_MIN 				; If < give error
	jl OPValueError
	pop rbx
	mov dword[rbx], eax

CheckSPCommand:
	mov rbx, qword[rsi + 56] 		; gets address of -sp
	cmp dword[rbx], 0x0070732d		; checks to see if it actually is "-sp"
	jne SPError

	mov rdi, qword[rsi+64]
	call tri2int
	cmp rax, -1						; if tri2int failed, call SPError
	je SPValueError
	cmp rax, SP_MAX					; Check if tri2int number is above SP_MAX
	jg SPValueError
	cmp rax, SP_MIN 				; If < give error
	jl SPValueError
	pop rbx
	mov dword[rbx], eax

; ////////////////////////////////////////////////////////////////////////////////////////////////////////

CheckColorCommand:
	mov rbx, qword[rsi+72]
	cmp dword[rbx], 0x006c632d
	jne CLError

	mov rbx, qword[rsi+80]
	movzx rax, byte[rbx]
	movzx r10, byte[rbx+1]
	cmp r10b, NULL
	jne CLValueError

	;pop rbx
	;mov byte[rbx], al  THIS WAS STUPID! DON'T DO DIS.

	cmp al, 'b'
	je Set2Blue

	cmp al, 'g'
	je Set2Green

	cmp al, 'r'
	je Set2Red

	cmp al, 'p'
	je Set2Purple

	cmp al, 'y'
	je Set2Yellow

	cmp al, 'w'
	je Set2White

	jmp CLValueError

Set2Blue:
	 mov al, 0x00
	 mov byte[red], al
	 mov al, 0x00
	 mov byte[green], al
	 mov al, 0xFF
	 mov byte[blue], al
	 jmp ColorValueIsAGo

Set2Green:
	 mov al, 0x00
	 mov byte[red], al
	 mov al, 0xFF
	 mov byte[green], al
	 mov al, 0x00
	 mov byte[blue], al
	 jmp ColorValueIsAGo

Set2Red:
	 mov al, 0xFF
	 mov byte[red], al
	 mov al, 0x00
	 mov byte[green], al
	 mov al, 0x00
	 mov byte[blue], al
	 jmp ColorValueIsAGo

Set2Purple:
	 mov al, 0xFF
	 mov byte[red], al
	 mov al, 0x00
	 mov byte[green], al
	 mov al, 0xFF
	 mov byte[blue], al
	 jmp ColorValueIsAGo

Set2Yellow:
	 mov al, 0xFF
	 mov byte[red], al
	 mov al, 0xFF
	 mov byte[green], al
	 mov al, 0x00
	 mov byte[blue], al
	 jmp ColorValueIsAGo

Set2White:
	 mov al, 0xFF
	 mov byte[red], al
	 mov al, 0xFF
	 mov byte[green], al
	 mov al, 0xFF
	 mov byte[blue], al
	 jmp ColorValueIsAGo

ColorValueIsAGo:
	;movzx rax, byte[rbx]
	;mov rbx, qword[rbp+16]
	;mov byte[rbx], al
	jmp EndOfFunctionIsAGo


; Errors are below /////////////////////////////////////////////////////////////////////////////////////////////

EBadCommandLine:
	mov rax, errBadCL
	jmp PrintErrors 			; Quits program and pops everything on the stack

R1Error:
	mov rax, errR1sp
	jmp PrintErrors

R1ValueError:
	mov rax, errR1value
	jmp PrintErrors

R2Error:
	mov rax, errR2sp
	jmp PrintErrors

R2ValueError:
	mov rax, errR2value
	jmp PrintErrors

OPError:
	mov rax, errOPsp
	jmp PrintErrors

OPValueError:
	mov rax, errOPvalue
	jmp PrintErrors

SPError:
	mov rax, errSPsp
	jmp PrintErrors

SPValueError:
	mov rax, errSPvalue
	jmp PrintErrors

CLError:
	mov rax, errCLsp
	jmp PrintErrors

CLValueError:
	mov rax, errCLvalue
	jmp PrintErrors


PrintErrorUsage:
	mov rax, errUsage
	jmp PrintErrors

PrintErrors:
	mov rdi, rax
	call printString
	mov rax, FALSE
	jmp EndOfFunction


; ////////////////////////////////////////////////////////////////////

EndOfFunctionIsAGo:
	pop rbx
	mov byte[rbx], al
	mov rax, TRUE



EndOfFunction: 				; This line is called when an error occurs
	pop rdx
	pop rdi
	pop rsi
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
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
common	speed		1:4		; rortation speed: int, dword, integer value
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

; YOUR CODE GOES HERE
; STANDARD CALLING CONVENTION
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
;
	mov dil, byte[red]
	mov sil, byte[green]
	mov dl, byte[blue]

	call glColor3ub

	; sStep = speed * scale

	cvtsi2ss xmm0, rbx
	divss xmm0, dword[scale]
	movss dword[sStep], xmm0

	cvtsi2ss xmm0, dword[radius1]
	movss dword[r1], xmm0

	cvtsi2ss xmm0, dword[radius2]
	movss dword[r2], xmm0

	cvtsi2ss xmm0, dword[offPos]
	movss dword[ofp], xmm0

	movss xmm0, dword[r1]
	addss xmm0, dword[r2]
	movss dword[radii], xmm0

	; float compare

	movss	xmm0, dword [fltZero]
	movss 	dword [t], xmm0

DrawMyTeaLoop:
	movss xmm1, dword[t]
	movss xmm2, dword[limit]
	ucomiss xmm1, xmm2
	jae TeaIsReady

;	x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
	movss xmm0, dword[t]
	call cosf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1], xmm0

	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0, dword[r2]
	mulss xmm0, dword[radii]
	call cosf
	mulss xmm0, dword[ofp]
	addss xmm0, dword[fltTmp1]
	movss dword[x], xmm0

;	y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))

	movss xmm1, dword[t]
	movss xmm2, dword[limit]
	ucomiss xmm1, xmm2
	jae TeaIsReady

	movss xmm0, dword[t]
	call sinf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1], xmm0

	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0, dword[r2]
	mulss xmm0, dword[radii]
	call sinf
	mulss xmm0, dword[ofp]
	addss xmm0, dword[fltTmp1]
	movss dword[y], xmm0

	movss xmm0, dword[t]
	addss xmm0, dword[tStep] 		;increment
	movss dword[t], xmm0

	movss xmm0, dword[x]
	movss xmm1, dword[y]

	call glVertex2f

	jmp DrawMyTeaLoop

TeaIsReady:


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
; TRI2INT Function

; rdi - string address
; rax - return register

global tri2int
tri2int:
	push rbp
	mov rbp, rsp
	push rbx
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rdi

	mov rbx, 0
	mov r15, 0


Start:
	mov rbx, rdi 						; moves string address into rbx
	mov r11, 0 							; rSum
	mov r10, 0							; increment
	mov r13, 13 						; this is what to multiply by (base/weight)
	mov rax, 0

ConvertLoop:
	movzx r15, byte[rbx + r10] 			; string = i
	cmp r15b, NULL
	je ConvertLoopIsAGo

	mov rax, r11						; rSum
	mul r13								; rSum * 13
	mov r11, rax 						; mov back into rSum

	cmp r15b, '0'
	jl ConvertLoopError

	cmp r15b, '9'
	jle ConvertNumber

	cmp r15b, 'A'
	jl ConvertLoopError

	cmp r15b, 'C'
	jle ConvertUpper

	cmp r15b, 'a'
	jl ConvertLoopError

	cmp r15b, 'c'
	jle ConvertLower

	jmp ConvertLoopError


	; //////////////////////////////////////////////////////

ConvertNumber:
	sub r15b, '0'
	jmp CharConvertDone

ConvertUpper:
	sub r15b, 'A'
	add r15b, 10
	jmp CharConvertDone

ConvertLower:
	sub r15b, 'a'
	add r15b, 10
	jmp CharConvertDone

CharConvertDone:
	add r11, r15 			; rSum += digit
	inc r10 				; i++
	jmp ConvertLoop

ConvertLoopError:
	mov rax, -1
	jmp tri2intDONE

ConvertLoopIsAGo:
	mov rax, r11
	jmp tri2intDONE

tri2intDONE:
	pop rdi
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
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

