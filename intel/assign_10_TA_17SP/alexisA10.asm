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

; %macro 	tri2int	2
; ; 	%1 = string address
; ; 	%2 = return flag = r12
; ;		1 = errorR1value
; ;		2 = errorR2value
; ;		3 = errorOPvalue
; ; 		4 = errorSPvalue

; %%tri2intStart:
; 	mov 	rbx, %1
; 	mov 	rax, 0
; 	mov 	r10, 0 			; i = 0
; 	mov 	r11, 0			; r11 = rSum

; %%tri2intConvert:
; 	mov 	r15, 0
; 	mov 	r15b, byte [rbx + r10] 	; get str[i]
; 	cmp 	r15b, NULL 		; if(endOfString)
; 	je 	%%tri2intSuccess

; 	mov 	r14, 13
; 	mov 	rax, r11 		; rSum
; 	mul 	r14d			; rSum * 13
; 	mov 	r11, rax

; 	;convert digit
; 	cmp 	r15b, "c"
; 	ja 	%%tri2intError
; 	cmp 	r15b, "a"
; 	jae 	%%tri2intLower
; 	cmp 	r15b, "C"
; 	ja 	%%tri2intError
; 	cmp 	r15b, "A"
; 	jae 	%%tri2intUpper
; 	cmp 	r15b, "9"
; 	ja 	%%tri2intError
; 	cmp 	r15b, "0"
; 	jae 	%%tri2intNumber

; %%tri2intLower:
; 	sub 	r15b, "a"
; 	add 	r15b, 10
; 	jmp 	%%charConvertDone

; %%tri2intUpper:
; 	sub 	r15b, "A"
; 	add 	r15b, 10
; 	jmp 	%%charConvertDone

; %%tri2intNumber:
; 	sub 	r15b, "0"
; 	jmp 	%%charConvertDone

; %%charConvertDone:
; 	add 	r11, r15 		; rSum += digit
; 	inc 	r10			; i++
; 	jmp 	%%tri2intConvert

; %%tri2intError:
; 	jmp 	%%tri2intConvertDone

; %%tri2intSuccess:
; 	mov 	r12, 0
; 	jmp 	%%tri2intConvertDone

; %%tri2intConvertDone:
; 	mov 	rax, r11

; %endmacro




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

red		    db	0			; 0-255
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


;******************************************************************
;TRITOINT FUNCTION
global converttri
converttri:

	push rbp     ;standard things
	mov rbp,rsp

	push rbx
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rdi

	mov rbx, 0

tri2intstart:

    mov rbx, rdi
    mov r11,0     ; rsum
    mov r10, 0     ; i
    mov r13, 13   ;base 13

convertloop:
	movzx r15, byte [rbx+ r10]  ;string[i]
	cmp r15b, NULL
	je convertloopsuccess

	mov rax, r11  ; rsum
	mul r13       ; rsum * base
	mov r11, rax

	cmp r15b, "0"
	jl convertlooperror

	cmp r15b, "9"
	jle convertnumber

	cmp r15b, "A"
	jl convertlooperror

	cmp r15b, "C"
	jle convertupper

	cmp r15b, "a"
	jl convertlooperror

	cmp r15b, "c"
	jle convertlower

	jmp convertlooperror   ;if no its a error

;*********************************************************

convertnumber:
	sub r15b, "0"
	jmp charconvertdone

convertupper:
	sub r15b, "A"
	add r15b, 10
	jmp charconvertdone

convertlower:
	sub r15b, "a"
	add r15b, 10
	jmp charconvertdone

;******************
charconvertdone:
	add r11, r15  ; rsum + digit
	inc r10
	jmp convertloop

convertlooperror:       ;go here if it is not a valid base 13 digit
	mov rax, -1
	jmp tri2intdone


convertloopsuccess:
	mov rax, r11            ;store converted tri base into rax
	jmp tri2intdone         ;tri to int complete

;*********************************************************
tri2intdone:

	pop rdi
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rbx

	mov rsp,rbp
	pop rbp

	ret

; ******************************************************************
;  Function getRadii()
; 	Gets radius 1, radius 2, offset positionm and rottaion
; 	speedvalues and color code letter from the command line.

; 	Performs error checking, converts ASCII/Tridecimal string
; 	to integer.  Required ommand line format (fixed order):
; 	  "-r1 <triDecimal> -r2 <triDecimal> -op <triDecimal>
; 			-sp <triDecimal> -cl <color>"

; -----
;  Arguments:
; 	- ARGC - rdi
; 	- ARGV - rsi
; 	- radius 1: int, double-word, address - rdx
; 	- radius 2: int, double-word, address - rcx
; 	- offset position: int double-word, address - r8
; 	- speed: int, double-word address - r9
; 	- circle color: char, byte, address - stack i.e. [rbp + 16]
; 	YOUR CODE GOES HERE

global getRadii
getRadii:

	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov rbx, qword[rbp+16]
	push rbx
	push r9;
	push r8;
	push rcx;
	push rdx;


	cmp rdi, 1
	je errorUsage          ; check if arguement is just one

	cmp rdi, 11            ; check if arguement is total of 11
	jne errorBadCL         ; continue belif there

	mov rbx, qword[rsi+8]      ;check for arguement 1: "-r1"
	cmp dword[rbx], 0x0031722D
	jne errorR1sp
	mov rdi, qword[rsi + 16]   ; check arguement 2: "c0"
	call converttri            ; call function to convert
	cmp rax, -1                ; if -1 was returned from the convert tri function
	je errorR1value
	cmp rax, R1_MAX            ; check if between max and min
	jg errorR1value
	cmp rax, R1_MIN
	jl errorR1value

	pop rdx				;r1
	mov dword [rdx], eax

	mov rbx, qword[rsi + 24]   ; check arguement 3: "-r2"
	cmp dword[rbx], 0x0032722D
	jne errorR2sp
	mov rdi, qword[rsi + 32]   ; check arguement 4: "31"
	call converttri            ; call funciton to convert tri to int function
	cmp rax, -1                ; if -1 was returned from the convert tri function
	je errorR2value
	cmp rax, R2_MAX            ; check if between max and min
	jg errorR2value
	cmp rax, R2_MIN
	jl errorR2value

	pop rcx
	mov dword[rcx],eax  ; r2

	mov rbx, qword[rsi + 40]   ; check arguement 5: "-op"
	cmp dword[rbx], 0x00706F2D
 	jne errorOPsp
	mov rdi, qword[rsi + 48]   ; check arguement 6: "c0"
	call converttri
	cmp rax, -1                ; if -1 was returned from the convert tri function
	je errorOPvalue
	cmp rax, OP_MAX            ; check if between max and min
	jg errorOPvalue
	cmp rax, OP_MIN
	jl errorOPvalue

	pop r8             ;offset
	mov dword[r8], eax

	mov rbx, qword[rsi + 56]   ; check arguement 7: "-sp"
	cmp dword[rbx], 0x0070732D
    jne errorSPsp
	mov rdi, qword[rsi + 64]   ; check arguement 8: "2"
	call converttri
	cmp rax, -1
	je errorSPvalue
	cmp rax, SP_MAX
	jg errorSPvalue
	cmp rax, SP_MIN
	jl errorSPvalue

	pop r9           ;speed
	mov dword[r9], eax

	mov rbx, qword[rsi + 72]   ; check arguemnet 9: "-cl"
	cmp dword[rbx], 0x006C632D
	jne errorCLsp

	mov rbx, qword[rsi + 80]   ; check arguement 10: "y"

	mov al, byte[rbx]

	cmp byte[rbx+1], NULL      ;if second " b " is not null then its not correct
	jne errorCLvalue

	pop rbx
	mov byte[rbx], al

	cmp al, "r"
	je setred

	cmp al, "g"
	je setgreen

	cmp al, "b"
	je setblue

	cmp al, "p"
	je setpurple

	cmp al, "y"
	je setyellow

	cmp al, "w"
	je setwhite

	jmp errorCLvalue

setred:
	mov byte[red], 255
	jmp completetrue     ;will go to very end of the program

setgreen:
	mov byte[green], 255
	jmp completetrue     ;will go to very end of the program

setblue:
	mov byte[blue], 255
	jmp completetrue     ;will go to very end of the program

setwhite:
	mov byte[red], 255
	mov byte[green], 255
	mov byte[blue], 255
	jmp completetrue
setpurple:
	mov byte [red],255
	mov byte [green], 0
	mov byte [blue], 255
	jmp completetrue

setyellow:
	mov byte[red], 255
	mov byte[green], 255
	mov byte[blue], 0
	jmp completetrue

;Errors*****************************************************************

errorUsage:
	mov rax, errUsage
	jmp printerror

errorBadCL:
	mov rax, errBadCL
	jmp printerror

errorR1sp:
	mov rax, errR1sp
	jmp printerror

errorR1value:
	mov rax, errR1value
	jmp printerror

errorR2sp:
	mov rax, errR2sp
	jmp printerror

errorR2value:
	mov rax, errR2value
	jmp printerror

errorOPsp:
	mov rax, errOPsp
	jmp printerror

errorOPvalue:
	mov rax, errOPvalue
	jmp printerror

errorSPsp:
	mov rax, errSPsp
	jmp printerror

errorSPvalue:
	mov rax, errSPvalue
	jmp printerror

errorCLsp:
	mov rax, errCLsp
	jmp printerror

errorCLvalue:
	mov rax, errCLvalue
	jmp printerror

;***********************************************************************

printerror:
	mov rdi, rax
	call printString
	mov rax, FALSE
	jmp getparametersdone

completetrue:
	mov rax,TRUE
	jmp getparametersdone

getparametersdone:

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret


; 	global getRadii
; getRadii:
; 	push	rbp
; 	mov 	rbp, rsp
; 	push	rbx
; 	push	r12
; 	push	r13
; 	push	r14
; 	push	r15
; 	; SCC Prologue
; 	mov 	rbx, qword [rbp + 16]
; 	push 	rbx
; 	push 	r9
; 	push	r8
; 	push 	rcx
; 	push 	rdx
; xgetRadiiStart:
; 	cmp 	rdi, 1			; if only one argument
; 	je 	errorUsage

; 	cmp 	rdi, 11			; if arg count incorrect
; 	jne 	errorBadCL

; ; "-r1" argument

; 	mov 	rbx, qword [rsi + 8] 	; arg 2
; 	cmp 	dword [rbx], 0x0031722d ; if arg 2 == "-r1"
; 	jne 	errorR1sp

; 	mov 	rbx, qword [rsi + 16] 	; arg 3
; 	mov 	r12, 1			; call code for errorR1value
; 	tri2int rbx, r12
; 	cmp 	r12, 1
; 	je 	errorR1value
; 	cmp 	rax, R1_MIN
; 	jl 	errorR1value
; 	cmp 	rax, R1_MAX
; 	jg 	errorR1value

; 	pop 	rdx
; 	mov 	dword [rdx], eax

; ; "-r2" argument

; 	mov 	rbx, qword [rsi + 24] 	; arg 4
; 	cmp 	dword [rbx], 0x0032722d	; if arg 4 == "-r2"
; 	jne 	errorR2sp

; 	mov 	rbx, qword [rsi + 32] 	; arg 5
; 	mov 	r12, 2 			; call code for errorR2value
; 	tri2int	rbx, r12
; 	cmp 	r12, 2
; 	je 	errorR2value
; 	cmp 	rax, R2_MIN
; 	jl 	errorR2value
; 	cmp 	rax, R2_MAX
; 	jg 	errorR2value

; 	pop 	rcx
; 	mov 	dword [rcx], eax

; ; "-op" argument

; 	mov 	rbx, qword [rsi + 40] 	; arg 6
; 	cmp 	dword [rbx], 0x00706f2d ; if arg 6 == "-op"
; 	jne 	errorOPsp

; 	mov 	rbx, qword [rsi + 48] 	; arg 7
; 	mov 	r12, 3
; 	tri2int	rbx, r12
; 	cmp 	r12, 3
; 	je 	errorOPvalue
; 	cmp 	rax, OP_MIN
; 	jl 	errorOPvalue
; 	cmp 	rax, OP_MAX
; 	jg 	errorOPvalue

; 	pop 	r8
; 	mov 	dword [r8], eax

; ; "-sp" argument

; 	mov 	rbx, qword [rsi + 56]	; arg 8
; 	cmp 	dword [rbx], 0x0070732d ; if arg 8 == "-sp"
; 	jne 	errorSPsp

; 	mov 	rbx, qword [rsi + 64] 	; arg 9
; 	mov 	r12, 4
; 	tri2int	rbx , r12
; 	cmp 	r12, 4
; 	je 	errorSPvalue
; 	cmp 	rax, SP_MIN
; 	jl 	errorSPvalue
; 	cmp 	rax, SP_MAX
; 	jg 	errorSPvalue

; 	pop 	r9
; 	mov 	dword [r9], eax

; ; "-cl" argument

; 	mov 	rbx, qword [rsi + 72]	; arg 10
; 	cmp 	dword [rbx], 0x006c632d ; if arg 10 == "-cl"
; 	jne 	errorCLsp

; 	mov 	rbx, qword [rsi + 80] 	; arg 11
; 	movzx 	rax, byte [rbx]
; 	movzx 	r10, byte[rbx + 1]
; 	cmp 	r10b, NULL		; Only one character
; 	jne 	errorCLvalue

; 	pop 	rbx
; 	mov 	byte [rbx], al

; 	cmp 	al, "b"		; "b"
; 	je 	clValueBlue
; 	cmp 	al, "g"		; "g"
; 	je 	clValueGreen
; 	cmp 	al, "r"		; "r"
; 	je 	clValueRed
; 	cmp 	al, "p"		; "p"
; 	je 	clValuePurple
; 	cmp 	al, "y"		; "y"
; 	je 	clValueYellow
; 	cmp 	al, "w"		; "w"
; 	je 	clValueWhite
; 	jmp 	errorCLvalue

; clValueBlue:
; 	mov 	al, 0x00
; 	mov 	byte [red], al
; 	mov 	al, 0x00
; 	mov 	byte [green], al
; 	mov 	al, 0xFF
; 	mov 	byte [blue], al
; 	jmp 	clValueDone
; clValueGreen:
; 	mov 	al, 0x00
; 	mov 	byte [red], al
; 	mov 	al, 0xFF
; 	mov 	byte [green], al
; 	mov 	al, 0x00
; 	mov 	byte [blue], al
; 	jmp 	clValueDone
; clValueRed:
; 	mov 	al, 0xFF
; 	mov 	byte [red], al
; 	mov 	al, 0x00
; 	mov 	byte [green], al
; 	mov 	al, 0x00
; 	mov 	byte [blue], al
; 	jmp 	clValueDone
; clValuePurple:
; 	mov 	al, 0xFF
; 	mov 	byte [red], al
; 	mov 	al, 0x00
; 	mov 	byte [green], al
; 	mov 	al, 0xFF
; 	mov 	byte [blue], al
; 	jmp 	clValueDone
; clValueYellow:
; 	mov 	al, 0xFF
; 	mov 	byte [red], al
; 	mov 	al, 0xFF
; 	mov 	byte [green], al
; 	mov 	al, 0x00
; 	mov 	byte [blue], al
; 	jmp 	clValueDone
; clValueWhite:
; 	mov 	al, 0xFF
; 	mov 	byte [red], al
; 	mov 	al, 0xFF
; 	mov 	byte [green], al
; 	mov 	al, 0xFF
; 	mov 	byte [blue], al
; 	jmp 	clValueDone

; clValueDone:
; 	movzx 	rax, byte [rbx]
; 	mov 	rbx, qword [rbp + 16]
; 	mov 	byte [rbx], al

; ; DONE JUMP TO SUCCESS
; 	jmp 	getRadiiSuccess

; ; -------------------------------------------------
; ; ERRORS START

; errorUsage:
; 	mov 	rax, errUsage
; 	jmp 	printError

; errorBadCL:
; 	mov 	rax, errBadCL
; 	jmp 	printError

; errorR1sp:
; 	mov 	rax, errR1sp
; 	jmp 	printError

; errorR1value:
; 	mov 	rax, errR1value
; 	jmp 	printError

; errorR2sp:
; 	mov 	rax, errR2sp
; 	jmp 	printError

; errorR2value:
; 	mov 	rax, errR2value
; 	jmp 	printError

; errorOPsp:
; 	mov 	rax, errOPsp
; 	jmp 	printError

; errorOPvalue:
; 	mov 	rax, errOPvalue
; 	jmp 	printError

; errorSPsp:
; 	mov 	rax, errSPsp
; 	jmp 	printError

; errorSPvalue:
; 	mov 	rax, errSPvalue
; 	jmp 	printError

; errorCLsp:
; 	mov 	rax, errCLsp
; 	jmp 	printError

; errorCLvalue:
; 	mov 	rax, errCLvalue
; 	jmp 	printError

; printError:
; 	mov 	rdi, rax
; 	call 	printString
; 	mov 	rax, FALSE
; 	jmp 	getRadiiEnd

; ; END ERRORS
; ; ----------------------------------------------------------


; getRadiiSuccess:
; 	mov 	rax, TRUE

; getRadiiEnd:
; 	; SCC Epilogue
; 	pop 	r15
; 	pop 	r14
; 	pop 	r13
; 	pop 	r12
; 	pop 	rbx
; 	mov 	rsp, rbp
; 	pop 	rbp
; 	ret


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
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15

; -----
	; Step = Speed/scale
	mov eax, dword[speed]
	cvtsi2ss xmm0, rax        ;speed is now a float
	divss xmm0, dword[scale]
	movss dword[sStep], xmm0

	; iterations = limit/tStep
	movss xmm0, dword[limit]
	divss xmm0, dword[tStep]
	movss [iterations], xmm0

	;convert ints to floats
	mov eax, dword[radius1]
	cvtsi2ss xmm0, rax
	movss dword[r1], xmm0

	mov eax, dword[radius2]
	cvtsi2ss xmm0, rax
	movss dword[r2], xmm0

	mov eax, dword[offPos]
	cvtsi2ss xmm0, rax
	movss dword[ofp], xmm0

	movss xmm0, dword[r1]    ;r= r1+r2
	addss xmm0 , dword[r2]
	movss dword[radii], xmm0


;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin


; ; -----
; ;  Main loop to calculate and then plot the series of (x,y)
; ;  points based on the spirograph equation.

; ;	YOUR CODE GOES HERE

;  	mov dil , byte[red]
;  	mov sil , byte[green]
;  	mov dl  , byte[blue]
;  	call glColor3ub



;  ;	SCC PROLOGUE START
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








	movss xmm0, dword[fltZero]
	movss dword[t], xmm0

Drawtloop:
	movss xmm1, dword [t]
	movss xmm2, dword [limit]
	ucomiss xmm1, xmm2
	jae tloopdone

; ; x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))

	movss xmm0, dword [t]
	call cosf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1] , xmm0

 	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0 ,dword[r2]
	mulss xmm0, dword[radii]
	call cosf
	mulss xmm0, dword[ofp]

    	addss xmm0, dword[fltTmp1]
	movss dword[x], xmm0


; ; y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))

	movss xmm0, dword [t]
	call sinf
	mulss xmm0, dword[radii]
	movss dword[fltTmp1] , xmm0

 	movss xmm0, dword[t]
	addss xmm0, dword[s]
	divss xmm0 ,dword[r2]
	mulss xmm0, dword[radii]
	call sinf
	mulss xmm0, dword[ofp]

    	addss xmm0, dword[fltTmp2]
	movss dword[y], xmm0


 	movss xmm0, dword [x]
 	movss xmm1, dword [y]
 	call glVertex2f


  	movss xmm0, dword[t]      ;increment t step
 	addss xmm0, dword[tStep]
 	movss dword[t], xmm0
 	jmp Drawtloop

    tloopdone:

    	movss 	xmm0, dword [fltZero]
	movss	dword [t], xmm0		; t = 0.0

drawSpiroTLoop:
	movss 	xmm0, dword [t]
	movss 	xmm1, dword [limit]
	ucomiss xmm0, xmm1
	jae 	drawSpiroTLoopDone

; x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))

	movss 	xmm0, dword [t]		; cos(t)
	call 	cosf
	mulss 	xmm0, dword [fltRadii] 	; (radii * cos(t))
	movss 	dword [fltPart1], xmm0	; (above)

	movss 	xmm0, dword [t]			; t
	addss 	xmm0, dword [s]			; (t+s)
	divss 	xmm0, dword [fltRadius2]	; (t+s)/r2
	mulss	xmm0, dword [fltRadii]		; radii * ((t+s)/r2)
	call 	cosf				; cos(above)
	mulss 	xmm0, dword [fltOffPos] 	; offPos * cos(above)

	addss 	xmm0, dword [fltPart1]		; x
	movss 	dword [x], xmm0			; store x
;	movss	dword[love], dword[me]

; y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))

	movss 	xmm0, dword [t]		; cos(t)
	call 	sinf
	mulss 	xmm0, dword [fltRadii] 	; (radii * cos(t))
	movss 	dword [fltPart1], xmm0	; (above)

	movss 	xmm0, dword [t]			; t
	addss 	xmm0, dword [s]			; (t+s)
	divss 	xmm0, dword [fltRadius2]	; (t+s)/r2
	mulss	xmm0, dword [fltRadii]		; radii * ((t+s)/r2)
	call 	sinf				; cos(above)
	mulss 	xmm0, dword [fltOffPos] 	; offPos * cos(above)

	addss 	xmm0, dword [fltPart1]		; y
	movss 	dword [y], xmm0			; store x

; plot (x,y)
	movss	xmm0, dword [x]
	movss 	xmm1, dword [y]
	call 	glVertex2f

; Increment t   ----   t += tStep
	movss 	xmm0, dword [t]
	addss 	xmm0, dword [tStep]
	movss	dword [t], xmm0
	jmp 	drawSpiroTLoop

drawSpiroTLoopDone:




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



; AUSTIN'S PROGRAM