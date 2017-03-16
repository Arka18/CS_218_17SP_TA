;  Cheyenne D'cruz
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

%macro	tri2int	2

mov r8, 0
mov r11, 0
mov r12, 0
mov r13, 0
mov r14, 0
mov rsi, 0

%%readChr:
mov al, byte [%1+rsi]

cmp al, NULL
je %%sort

cmp al, '0'
jl %%NO
cmp al, '9'
jle %%OK

cmp al, 'A'
jl %%NO
cmp al, 'C'
jle %%OK

cmp al, 'a'
jl %%NO
cmp al, 'c'
jle %%OK

jmp %%NO

%%OK:
inc r12
inc rsi
jmp %%readChr

%%sort:
mov rax, 0
mov al, byte [%1+r13]
cmp al, 'a'
jae %%intDigit1
cmp al, 'A'
jae %%intDigit2
cmp al, '9'
jbe %%intDigit3

%%intDigit1:
sub rax, 'a'
add rax, 10
mov r11, r12
jmp %%convert

%%intDigit2:
sub rax, 'A'
add rax, 10
mov r11, r12
jmp %%convert

%%intDigit3:
sub rax, '0'
mov r11, r12
jmp %%convert

%%convert:
cmp r12, 1
je %%Done
mov r8, 13
mul r8
dec r11
cmp r11, 1
jg %%convert
jmp %%Done

%%Done:
add r14, rax
dec r12
cmp r12, 0
je %%YAY
inc r13
jmp %%sort

%%NO:
mov %2, -1
jmp %%Final

%%YAY:
mov %2, r14

%%Final:

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
xtmp            dd      0                       ; temp variable for x
ytmp            dd      0                       ; temp variable for y

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
;	- ARGC -rdi
;	- ARGV - rsi
;	- radius 1: int, double-word, address - rdx
;	- radius 2: int, double-word, address - rcx
;	- offset position: int double-word, address - r8
;	- speed: int, double-word address  - r9
;	- circle color: char, byte, address - stack (rbp+16)


;	YOUR CODE GOES HERE
global getRadii
getRadii:
push rbp
mov rbp, rsp
push rbx

;if ARGC == 1
cmp rdi, 1
je doUseMsg

;if ARGC != 11
cmp rdi, 11
jne doCLerrMsg

;check ARGV[1] for "-r1"
mov r10, qword [rsi+8]
cmp dword [r10], 0x0031722d        ;NULL'1''r''-'
jne doR1err

;get ARGV[2]
mov r10, qword [rsi+16]

push rsi
push rdx
push rcx
push r8
push r9
tri2int r10, r11
pop r9
pop r8
pop rcx
pop rdx
pop rsi

cmp r11, R1_MIN
jl doR1valueErr
cmp r11, R1_MAX
jg doR1valueErr
mov dword [rdx], r11d

;check ARGV[3] for "-r2"
mov r10, qword [rsi+24]
cmp dword [r10], 0x0032722d        ;NULL'2''r''-'
jne doR2err

;get ARGV[4]
mov r10, qword [rsi+32]

push rsi
push rdx
push rcx
push r8
push r9
tri2int r10, r11
pop r9
pop r8
pop rcx
pop rdx
pop rsi

cmp r11, R2_MIN
jl doR2valueErr
cmp r11, R2_MAX
jg doR2valueErr
mov dword [rcx], r11d

;check ARGV[5] for "-op"
mov r10, qword [rsi+40]
cmp dword [r10], 0x00706F2d        ;NULL'p''o''-'
jne doOPerr

;get ARGV[6]
mov r10, qword [rsi+48]

push rsi
push rdx
push rcx
push r8
push r9
tri2int r10, r11
pop r9
pop r8
pop rcx
pop rdx
pop rsi

cmp r11, OP_MIN
jl doOPvalueErr
cmp r11, OP_MAX
jg doOPvalueErr
mov dword [r8], r11d

;check ARGV[7] for "-sp"
mov r10, qword [rsi+56]
cmp dword [r10], 0x0070732d        ;NULL'p''s''-'
jne doSPerr

;get ARGV[8]
mov r10, qword [rsi+64]

push rsi
push rdx
push rcx
push r8
push r9
tri2int r10, r11
pop r9
pop r8
pop rcx
pop rdx
pop rsi

cmp r11, SP_MIN
jl doSPvalueErr
cmp r11, SP_MAX
jg doSPvalueErr
mov dword [r9], r11d

;check ARGV[9] for "-cl"
mov r10, qword [rsi+72]
cmp dword [r10], 0x006C632d        ;NULL'l''c''-'
jne doCLerr

;get ARGV[10]
mov r10, qword [rsi+80]
mov bl, byte [r10]

cmp byte [r10+1], NULL             ;checking if there is a second char
jne doCLvalueErr

cmp bl, "r"
je setCL
cmp bl, "g"
je setCL
cmp bl, "b"
je setCL
cmp bl, "p"
je setCL
cmp bl, "y"
je setCL
cmp bl, "w"
je setCL
jmp doCLvalueErr

;set color
setCL:
mov r11, qword [rbp+16]
mov dword [r11], ebx
jmp noErr

;ERRORS

;usage error
doUseMsg:
mov rdi, errUsage
jmp printMsg

;command line argument error
doCLerrMsg:
mov rdi, errBadCL
jmp printMsg

;incorrect radius 1 specifier
doR1err:
mov rdi, errR1sp
jmp printMsg

;incorrect range for radius 1
doR1valueErr:
mov rdi, errR1value
jmp printMsg

;incorrect radius 2 specifier
doR2err:
mov rdi, errR2sp
jmp printMsg

;incorrect range for radius 2
doR2valueErr:
mov rdi, errR2value
jmp printMsg

;incorrect op specifier
doOPerr:
mov rdi, errOPsp
jmp printMsg

;incorrect range for op
doOPvalueErr:
mov rdi, errOPvalue
jmp printMsg

;incorrect sp specifier
doSPerr:
mov rdi, errSPsp
jmp printMsg

;incorrect range for sp
doSPvalueErr:
mov rdi, errSPvalue
jmp printMsg

;incorrect cl specifier
doCLerr:
mov rdi, errCLsp
jmp printMsg

;incorrect value for cl
doCLvalueErr:
mov rdi, errCLvalue
jmp printMsg

;prints error message
printMsg:
call printString
mov rax, FALSE
jmp exitLoop


;no errors
noErr:
mov rax, TRUE

;done
exitLoop:

pop rbx
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

;color RED
mov al, byte [color]
cmp al, "r"
jne nxtCheck
mov rdi, 255
mov rsi, 0
mov rdx, 0
jmp colorSet

;color GREEN
nxtCheck:
mov al, byte [color]
cmp al, "g"
jne nxtCheck2
mov rdi, 0
mov rsi, 255
mov rdx, 0
jmp colorSet

;color BLUE
nxtCheck2:
mov al, byte [color]
cmp al, "b"
jne nxtCheck3
mov rdi, 0
mov rsi, 0
mov rdx, 255
jmp colorSet

;color PURPLE
nxtCheck3:
mov al, byte [color]
cmp al, "p"
jne nxtCheck4
mov rdi, 255
mov rsi, 0
mov rdx, 255
jmp colorSet

;color YELLOW
nxtCheck4:
mov al, byte [color]
cmp al, "y"
jne nxtCheck5
mov rdi, 255
mov rsi, 255
mov rdx, 0
jmp colorSet

;color WHITE
nxtCheck5:
mov al, byte [color]
cmp al, "w"
jne nxtCheck6
mov rdi, 255
mov rsi, 255
mov rdx, 255
jmp colorSet

colorSet:
call glColor3ub

mov rdi, GL_COLOR_BUFFER_BIT
call glClear

mov rdi, GL_POINTS
call glBegin

nxtCheck6:

;convert integer values to float
cvtsi2ss xmm1, dword [radius1]
movss dword [r1], xmm1
cvtsi2ss xmm2, dword [radius2]
movss dword [r2], xmm2
cvtsi2ss xmm3, dword [offPos]
movss dword [ofp], xmm3

;step = speed/scale
mov eax, dword [speed]
cvtsi2ss xmm3, eax
divss xmm3, dword [scale]
movss dword [sStep], xmm3

;interations
movss xmm0, dword [limit]
divss xmm0, dword [tStep]
movss dword [iterations], xmm0

movss	xmm0, dword [fltZero]
movss 	dword [t], xmm0

drawSpiroLp:
; (r1+r2)
movss xmm7, dword [r1]
addss xmm7, dword [r2]
movss dword [radii], xmm7

;(r1+r2)*cos(t)
movss xmm0, dword [t]
call cosf
mulss xmm0, dword [radii]
movss dword [xtmp], xmm0

;(t+s)/r2
movss xmm5, dword [t]
addss xmm5, dword [s]
divss xmm5, dword [r2]

;offPos * [cos[(r1+r2) * [(t+s)/(r2)]]]
mulss xmm5, dword [radii]
movss xmm0, xmm5
call cosf
mulss xmm0, dword [ofp]

;[(r1+r2)*cos(t)] + [offPos * [cos[(r1+r2) * [(t+s)/(r2)]]]]
addss xmm0, dword [xtmp]
movss dword [x], xmm0

; (r1+r2)
movss xmm7, dword [r1]
addss xmm7, dword [r2]
movss dword [radii], xmm7

;(r1+r2)*sin(t)
movss xmm0, dword [t]
call sinf
mulss xmm0, dword [radii]
movss dword [ytmp], xmm0

;(t+s)/r2
movss xmm5, dword [t]
addss xmm5, dword [s]
divss xmm5, dword [r2]

;offPos * [sin[(r1+r2) * [(t+s)/(r2)]]]
mulss xmm5, dword [radii]
movss xmm0, xmm5
call sinf
mulss xmm0, dword [ofp]

;[(r1+r2)*sin(t)] + [offPos * [sin[(r1+r2) * [(t+s)/(r2)]]]]
addss xmm0, dword [ytmp]
movss dword [y], xmm0

movss xmm0, dword [x]
movss xmm1, dword [y]
call glVertex2f

;t = t + tStep
movss xmm5, dword [t]
addss xmm5, dword [tStep]
movss dword [t], xmm5
ucomiss xmm5, dword [limit]
jl drawSpiroLp

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

