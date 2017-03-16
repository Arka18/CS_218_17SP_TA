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

;  Main loop to calculate and then plot the series of (x,y)
;  points based on the spirograph equation.

;	YOUR CODE GOES HERE

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
	mulss 	xmm0, dword [radii] 	; (radii * cos(t))
	movss 	dword [fltTmp1], xmm0	; (above)

	movss 	xmm0, dword [t]			; t
	addss 	xmm0, dword [s]			; (t+s)
	divss 	xmm0, dword [r2]	; (t+s)/r2
	mulss	xmm0, dword [radii]		; radii * ((t+s)/r2)
	call 	cosf				; cos(above)
	mulss 	xmm0, dword [ofp] 	; offPos * cos(above)

	addss 	xmm0, dword [fltTmp1]		; x
	movss 	dword [x], xmm0			; store x
;	movss	dword[love], dword[me]

; y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))

	movss 	xmm0, dword [t]		; cos(t)
	call 	sinf
	mulss 	xmm0, dword [radii] 	; (radii * cos(t))
	movss 	dword [fltTmp1], xmm0	; (above)

	movss 	xmm0, dword [t]			; t
	addss 	xmm0, dword [s]			; (t+s)
	divss 	xmm0, dword [r2]	; (t+s)/r2
	mulss	xmm0, dword [radii]		; radii * ((t+s)/r2)
	call 	sinf				; cos(above)
	mulss 	xmm0, dword [ofp] 	; offPos * cos(above)

	addss 	xmm0, dword [fltTmp1]		; y
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

; 	SCC EPILOGUE START
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	pop 	rbp
; 	SCC EPILOGUE END
	ret