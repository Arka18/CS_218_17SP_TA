;  CS 218 - Assignment #10
;  Spirograph - Support Functions.
;  Provided Template
; Amit Etiel
; CS218
; 1002
; -----
;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;	MACROS (if any) GO HERE
%macro	int2tri  1

	mov 	r8, 0        ; zero out r8 r8 sum
				 		 ; zero out r13
	mov 	rax, 0 		 ; zero out rax
	mov 	r11, 0       ; zero out r11
	mov 	r15, 0
 	mov 	rbx, %1      ; move 1st argument (address) into rbx
 	mov		r15b, byte[rbx] ; move number into r15
    ;cmp		r8b, ' '
    ;je		%%spaceloop
    ;jmp 	%%done1
    ;spaceloop:
    ;
    ;inc		rbx
    ;mov 	r8b, byte[rbx]
    ;cmp		r8b, ' '
    ;je		%%spaceloop
    ;
    ;
	%%cvtloop:

	cmp		 r15b, NULL			 ; if (char==Null)
	je		%%cvtloopdone			 ; go to cvtloopdone
	%%Lowercase1:
	cmp 	 r15b, 'c'
	ja  	%%Invalid
	cmp		 r15b, 'a' 			 ; if (char == lowercase )
	jae		%%lowercase          ; go to lowercase
	%%Upper:
	cmp 	r15b, 'C'
	ja		%%Invalid
	cmp		r15b, 'A'             ; if (char == uppercase)
	jae		%%uppercase          ; go to uppercase
	%%Number:
	cmp 	r15b, '9'
	ja  	%%Invalid
	cmp		r15b, '0'             ; if (char == number)
	jae		%%number             ; go to number

	cmp 	r15b, '0'
	jb  	%%Invalid
	%%Cont:
	mov 	rax, r8
	mov		r11, 13
	mul		r11          ; rsum *13
	mov 	r8, rax    ; mov rsum back to r8
	add		r8, r15    ; add number to rsum

	inc		r13

	%%Next12:
	inc		rbx
	mov 	r15b, byte[rbx]
	cmp 	r15b, NULL
	je 		%%cvtloopdone
	jmp 	%%cvtloop

	%%lowercase:
	mov		r14b, 0
	mov		r14b, 10
	sub		r15b, 'a'
	add		r15b, r14b
	jmp		%%Cont

	%%uppercase:
	mov		r14b, 0
	mov		r14b, 10
	sub		r15b, 'A'
	add		r15b, r14b
	jmp		%%Cont

	%%number:
	sub		r15b, '0'
	jmp		%%Cont

	%%cvtloopdone:
	mov 	r12, 0
	mov 	rax, r8
	jmp 	%%nextone
	%%Invalid:
	mov  	r12, 2
	%%nextone:


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

fltRadius1	dd 	0.0
fltRadius2	dd 	0.0
fltRadii 	dd 	0.0
fltOffPos	dd 	0.0

fltPart1	dd 	0.0

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
;	Gets radius 1, radius 2, offset positionm and rottaion
;	speedvalues and color code letter from the command line.

;	Performs error checking, converts ASCII/Tridecimal string
;	to integer.  Required ommand line format (fixed order):
;	  "-r1 <triDecimal> -r2 <triDecimal> -op <triDecimal>
;			-sp <triDecimal> -cl <color>"

; -----
;  Arguments:
;	- ARGC        -- rdi
;	- ARGV		  -- rsi
;	- radius 1: int, double-word, address -- rdx
;	- radius 2: int, double-word, address -- rcx
;	- offset position: int double-word, address -- r8
;	- speed: int, double-word address  -- r9
;	- circle color: char, byte, address -- stack


;	YOUR CODE GOES HERE
global getRadii

getRadii:
	push 	rbp
	mov 	rbp, rsp
	push 	rbx
	push 	r12
	push 	r13
	push 	r14
	push 	r15
	push 	rdi
	mov 	r15, qword[rbp+16]
	push 	r15
	push 	r9
	push 	r8
	push 	rcx
	push 	rdx

	cmp 	rdi, 1 		; if there is only one argument
	je 		incomplete1  ; go to incomplete1

	cmp 	rdi, 11  ; if there are not 11 arguments
	jne     Nope     ; jump to nope


r1checker:
	mov 	r10, qword[rsi+8]   ;move 2nd argument to r10
	cmp 	dword[r10], 0x0031722d  ; compare 2nd argument to '-r1' in hex (0x0031722d) backwards because of stack
	jne 	Errorr1                 ; if not equal then jump to error1

r1radius:
	mov 	r13, qword[rsi+16]      ; move radius range into r13
	int2tri  r13                    ; convert radius range
	cmp 	r12, 2                  ; if 2 then input had an error
	je 		overr1

	cmp 	rax, R1_MAX
	ja 	 	overr1
	pop 	rdx
	mov 	dword[rdx], eax

r2checker:
	mov 	r10, qword[rsi+24]   ;move 2nd argument to r10
	cmp 	dword[r10], 0x0032722d  ; compare 2nd argument to '-r1' in hex (0x0031722d) backwards because of stack
	jne 	Errorr1                 ; if not equal then jump to error1

r2radius:
	mov 	r14, qword[rsi+32]
	int2tri r14
	cmp 	r12, 2
	je 		overr2

	cmp 	rax, R2_MAX
	ja  	overr2
	cmp 	rax, R2_MIN
	jb   	overr2
	pop 	rcx
	mov 	dword[rcx], eax
OFFset:
	mov 	r10, qword[rsi+40]
	cmp     dword[r10], 0x00706f2d
	jne 	Migos

Quavo:                              ; op convert
	mov 	r13, qword[rsi+48]
	int2tri r13
	cmp 	r12, 2
	je 		Takeoff

	cmp 	rax, OP_MAX
	ja 		Takeoff
	cmp 	rax, OP_MIN
	jb 		Takeoff
	pop 	r8
	mov 	dword[r8], eax
Speed:
	mov 	r10, qword[rsi+56]
	cmp     dword[r10], 0x0070732d
	jne     notcool

Speedy21:                              ; op convert
	mov 	r13, qword[rsi+64]
	int2tri r13
	cmp 	r12, 2
	je 		Slow
	cmp 	rax, SP_MAX
	ja 		Slow
	cmp 	rax, SP_MIN
	jb 		Slow
	pop 	r9
	mov 	dword[r9], eax
Color:
	mov 	r14, qword[rsi+72]
	cmp 	dword[r14], 0x006c632d
	jne 	soundofcolor
actualColor:
	mov 	r14, qword[rsi+80]
	movzx   rax, byte[r14]
	movzx 	r10, byte[r14+1]
	cmp 	r10b, NULL
	jne 	wrongletterc
	pop 	r15
	mov 	byte[r15], al
	cmp 	al, 'b'
	je 		Blue

	cmp 	al, 'r'
	je 		Red

	cmp 	al, 'g'
	je 		Green

	cmp     al, 'p'
	je 		Purple

	cmp 	al, 'y'
	je 		Yellow

	cmp 	al, 'w'
	je 		White

	jmp  	wrongletterc
	Blue:
	mov 	byte[blue], 0xff
	jmp Successinput
	Red:
	mov 	byte[red], 0xff
	jmp Successinput
	Green:
	mov 	byte[green], 0xff
	jmp Successinput
	Purple:
	mov 	byte[blue], 0xff
	mov 	byte[red], 0xff
	jmp Successinput
	Yellow:
	mov 	byte[red], 0xff
	mov 	byte[green], 0xff
	jmp Successinput
	White:
	mov 	byte[red], 0xff
	mov 	byte[green], 0xff
	mov 	byte[blue], 0xff
	jmp Successinput
;  Color Code Conversion:
;	'r' -> red=255, green=0, blue=0
;	'g' -> red=0, green=255, blue=0
;	'b' -> red=0, green=0, blue=255
;	'p' -> red=255, green=0, blue=255
;	'y' -> red=255 green=255, blue=0
;	'w' -> red=255, green=255, blue=255
Successinput:
	mov 	rax, TRUE
	pop 	rdi
	pop 	r15
    pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	mov 	rsp, rbp
	pop 	rbp
	ret

soundofcolor:
	mov 	rdi, errCLsp
	jmp 	ReturnF
wrongletterc:
	mov 	rdi, errCLvalue
	jmp 	ReturnF
overr1:
	mov 	rdi, errR1value
	jmp 	ReturnF
overr2:
	mov 	rdi, errR2value
	jmp 	ReturnF
Takeoff:
	mov 	rdi, errOPvalue
	jmp 	ReturnF
incomplete1:
	mov 	rdi, errUsage
	jmp 	ReturnF

Nope:
	mov 	rdi, errBadCL
	jmp 	ReturnF
Errorr1:
	mov 	rdi, errR1sp
	jmp 	ReturnF

Errorr2:
	mov 	rdi, errR2sp
	jmp 	ReturnF
Migos:
	mov 	rdi, errOPsp
	jmp 	ReturnF
notcool:                 ; not good speed input
	mov 	rdi, errSPsp
	jmp 	ReturnF
Slow:
	mov 	rdi, errSPvalue
	jmp 	ReturnF
ReturnF:
	call 	printString
	mov 	rax, FALSE
    pop 	rdi
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
;	YOUR CODE GOES HERE
push rbp
mov  rbp, rsp
push rbx
push r12
push r13
push r14
push r15

;S STEP CALCULATION

mov 		eax, dword[speed]
cvtsi2ss 	xmm3, rax
divss 		xmm3, dword[scale]
movss 		dword[sStep], xmm3

; convert to float
cvtsi2ss 	xmm2, dword[radius1]
movss		dword[r1], xmm2

cvtsi2ss 	xmm2, dword[radius2]
movss 	dword[r2], xmm2

cvtsi2ss 	xmm2, dword[offPos]
movss 	dword[ofp], xmm2


;setcolor
mov 	dil, byte[red]
mov 	sil, byte[green]
mov 	dl, byte[blue]
call 	glColor3ub
; Radii = (r1+r2)
movss 	xmm7, dword[r1]
addss 	xmm7, dword[r2]
movss 	dword[radii], xmm7

; iterations



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

movss	xmm0, dword [fltZero]
movss	dword [t], xmm0

Drawingtloop:
movss xmm6, dword[t]
movss xmm7, dword[limit]
ucomiss xmm6, xmm7
jae 	drawingloopdone

  ; x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
movss 	xmm0, dword[t]
call    cosf
mulss 	xmm0, dword[radii]
movss   dword[fltTmp1], xmm0
; t+s
movss 	xmm2, dword[t]
addss 	xmm2, dword[s]
divss 	xmm2, dword[r2]
mulss 	xmm2, dword[radii]
movss 	xmm0, xmm2
call 	cosf
mulss 	xmm0, dword[ofp]
addss 	xmm0, dword[fltTmp1]
movss 	dword[x], xmm0
;y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))
movss	xmm0, dword[t]
call    sinf
mulss 	xmm0, dword[radii]
movss   dword[fltTmp2], xmm0
; t+s
movss 	xmm2, dword[t]
addss 	xmm2, dword[s]
divss 	xmm2, dword[r2]
mulss 	xmm2, dword[radii]
movss 	xmm0, xmm2
call 	sinf
mulss 	xmm0, dword[ofp]
addss 	xmm0, dword[fltTmp2]
movss 	dword[y], xmm0
; increment t step
movss 	xmm5, dword[t]
addss   xmm5, dword[tStep]
movss 	dword[t], xmm5
; plot
movss 	xmm0, dword[x]
movss 	xmm1, dword[y]
call 	glVertex2f
jmp  	Drawingtloop
drawingloopdone:













; global drawSpiro
; drawSpiro:

; ;	SCC PROLOGUE START
; 	push	rbp
; 	push	rbx
; 	push 	r12
; 	push	r13
; 	push	r14
; 	push	r15
; ; 	SCC PROLOGUE END

; ; ***** SSTEP CALCULATION START ******

; ; 	sStep = speed/scale

; 	mov 		r12d, dword [speed]
; 	cvtsi2ss	xmm0, r12
; 	divss		xmm0, dword [scale]
; 	movss		dword [sStep], xmm0

; ; ***** SSTEP CALCULATION END ********

; ; ***** ITERATIONS CALCULATION START ******

; ; 	iterations = 360.0/tStep

; 	movss 	xmm0, dword [limit]
; 	divss	xmm0, dword [tStep]
; 	movss 	dword [iterations], xmm0

; ; ***** ITERATIONS CALCULATION END ********

; ; ***** CONVERSION OF INTS TO FLOATS START *****

; 	mov 		eax, dword [radius1]
; 	cvtsi2ss	xmm0, rax
; 	movss 		dword [fltRadius1], xmm0

; 	mov 		eax, dword [radius2]
; 	cvtsi2ss	xmm0, rax
; 	movss 		dword [fltRadius2], xmm0

; 	mov 		eax, dword [offPos]
; 	cvtsi2ss 	xmm0, rax
; 	movss 		dword [fltOffPos], xmm0


; ; 	Both radii added together
; 	movss	xmm0, dword [fltRadius1]
; 	addss 	xmm0, dword [fltRadius2]
; 	movss 	dword [fltRadii], xmm0

; ; ***** CONVERSION OF INTS TO FLOATS END *******

; ; -----
; ;  Prepare for drawing
; 	; glClear(GL_COLOR_BUFFER_BIT);
; 	mov	rdi, GL_COLOR_BUFFER_BIT
; 	call	glClear

; 	; glBegin();
; 	mov	rdi, GL_POINTS
; 	call	glBegin

; ; -----

; ; ***** COLOR SET START **************

; ; 	uses glColor3ub(r, g, b)
; 	mov 	dil, byte [red]
; 	mov 	sil, byte [green]
; 	mov 	dl, byte [blue]
; 	call 	glColor3ub

; ; ***** COlOR SET END ****************

; ;  Main loop to calculate and then plot the series of (x,y)
; ;  points based on the spirograph equation.

; ;	YOUR CODE GOES HERE

; 	movss 	xmm0, dword [fltZero]
; 	movss	dword [t], xmm0		; t = 0.0

; drawSpiroTLoop:
; 	movss 	xmm0, dword [t]
; 	movss 	xmm1, dword [limit]
; 	ucomiss xmm0, xmm1
; 	jae 	drawSpiroTLoopDone

; ; x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))

; 	movss 	xmm0, dword [t]		; cos(t)
; 	call 	cosf
; 	mulss 	xmm0, dword [fltRadii] 	; (radii * cos(t))
; 	movss 	dword [fltPart1], xmm0	; (above)

; 	movss 	xmm0, dword [t]			; t
; 	addss 	xmm0, dword [s]			; (t+s)
; 	divss 	xmm0, dword [fltRadius2]	; (t+s)/r2
; 	mulss	xmm0, dword [fltRadii]		; radii * ((t+s)/r2)
; 	call 	cosf				; cos(above)
; 	mulss 	xmm0, dword [fltOffPos] 	; offPos * cos(above)

; 	addss 	xmm0, dword [fltPart1]		; x
; 	movss 	dword [x], xmm0			; store x
; ;	movss	dword[love], dword[me]

; ; y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))

; 	movss 	xmm0, dword [t]		; cos(t)
; 	call 	sinf
; 	mulss 	xmm0, dword [fltRadii] 	; (radii * cos(t))
; 	movss 	dword [fltPart1], xmm0	; (above)

; 	movss 	xmm0, dword [t]			; t
; 	addss 	xmm0, dword [s]			; (t+s)
; 	divss 	xmm0, dword [fltRadius2]	; (t+s)/r2
; 	mulss	xmm0, dword [fltRadii]		; radii * ((t+s)/r2)
; 	call 	sinf				; cos(above)
; 	mulss 	xmm0, dword [fltOffPos] 	; offPos * cos(above)

; 	addss 	xmm0, dword [fltPart1]		; y
; 	movss 	dword [y], xmm0			; store x

; ; plot (x,y)
; 	movss	xmm0, dword [x]
; 	movss 	xmm1, dword [y]
; 	call 	glVertex2f

; ; Increment t   ----   t += tStep
; 	movss 	xmm0, dword [t]
; 	addss 	xmm0, dword [tStep]
; 	movss	dword [t], xmm0
; 	jmp 	drawSpiroTLoop

; drawSpiroTLoopDone:

; ; -----
; ;  Main plotting loop done.

; 	call	glEnd
; 	call	glFlush

; ; -----
; ;  Update s for next call.

; 	movss	xmm0, dword [s]
; 	addss	xmm0, dword [sStep]
; 	movss	dword [s], xmm0

; ; -----
; ;  Ensure openGL knows to call again

; 	call	glutPostRedisplay

; ;	pop	r12

; ; 	SCC EPILOGUE START
; 	pop 	r15
; 	pop 	r14
; 	pop 	r13
; 	pop 	r12
; 	pop 	rbx
; 	pop 	rbp
; ; 	SCC EPILOGUE END
; 	ret


















; X function

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
	pop r15
	pop r14
	pop r13
    pop	r12
	pop rbx
	mov 	rsp, rbp
	pop rbp
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
	mov rsp, rbp
	pop	rbp
	ret

; ******************************************************************

