; Thien Truong
; Section 1001
;  CS 218 - Assignment #11
;  Functions Template

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

LF			equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20		; space

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

; -----
;  Define program specific constants.

MIN_FILE_LEN	equ	5
BUFF_SIZE		equ	1000000			; buffer size

; -----
;  Variables for getOptions() function.

eof				db	FALSE

usageMsg		db	"Usage: ./thumb <inputFile.bmp> "
				db	"<outputFile.bmp>", LF, NULL
errIncomplete	db	"Error, incomplete command line arguments.", LF, NULL
errExtra		db	"Error, too many command line arguments.", LF, NULL
;errReadSpec		db	"Error, invalid read specifier.", LF, NULL
;errWriteSpec	db	"Error, invalid write specifier.", LF, NULL
errReadName		db	"Error, invalid source file name.  Must be '.bmp' file.", LF, NULL
errWriteName	db	"Error, invalid output file name.  Must be '.bmp' file.", LF, NULL
errReadFile		db	"Error, unable to open input file.", LF, NULL
errWriteFile	db	"Error, unable to open output file.", LF, NULL
fDes 			dq	0
wrDes 			dq 	0
bmp 			dw	0
; -----
;  Variables for readHeader() function.

HEADER_SIZE		equ	138

errReadHdr		db	"Error, unable to read header from source image file."
				db	LF, NULL
errFileType		db	"Error, invalid file signature.", LF, NULL
errDepth		db	"Error, unsupported color depth.  Must be 24-bit color."
				db	LF, NULL
errCompType		db	"Error, only non-compressed images are supported."
				db	LF, NULL
errSize			db	"Error, bitmap block size inconsistant.", LF, NULL
errWriteHdr		db	"Error, unable to write header to output image file.", LF,
				db	"Program terminated.", LF, NULL

; -----
;  Variables for getRow() function.

buffMax			dq	BUFF_SIZE - 1
curr			dq	BUFF_SIZE
wasEOF			db	FALSE
pixelCount		dq	0

errRead			db	"Error, reading from source image file.", LF,
				db	"Program terminated.", LF, NULL

; -----
;  Variables for writeRow() function.

errWrite		db	"Error, writting to output image file.", LF,
				db	"Program terminated.", LF, NULL


; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer			resb	BUFF_SIZE
header			resb	HEADER_SIZE


; ############################################################################

section	.text

; ***************************************************************
;  Routine to get image file names (from command line)
;	Verify files by atemptting to open the files (to make
;	sure they are valid and available).

;  Command Line format:
;	./makeThumb <inputFileName> <outputFileName>

; -----
;  Arguments:
;	- argc (value)
;	- argv table (address)
;	- read file descriptor (address)
;	- write file descriptor (address)
;  Returns:
;	read file descriptor (via reference)
;	write file descriptor (via reference)
;	TRUE or FALSE


;	YOUR CODE GOES HERE
global getImageFileNames
getImageFileNames:
	push r11
	push r12
	push r13
	push r14
	push rbp
	mov rbp, rsp
	mov r8, 0
	mov r9, 0
	mov r10, 0
	mov r11, 0
	mov r12, 0
	mov r13, 0
	mov r14, 0

	mov r9, rsi
	mov r8, rcx
; if(argc ==1)
	cmp rdi, 1
	jne CheckArgc1
	mov rdi, usageMsg
	call printString
	mov rax, FALSE
	jmp goBack
; The block of code above checks to see if rdi has at least 1 agrument
CheckArgc1:
; if(argc != 3)
	cmp rdi, 3
	je Checkbmp
	jg Extraloop
	jl Lessloop
; The block of code above checks to see if rdi has exactly 3 agrument
; if(argv[1] != valid file name)

Checkbmp:
	mov r10, qword[r9 + 8]			; Moves the first argument into r10
	cmp byte[r10], '.'
	je Error1

Checkbmp2:
	inc r10
	cmp byte[r10], NULL
	je Error1
	cmp byte[r10], '.'
	jne Checkbmp2
	cmp byte[r10 + 1], 'b'
	jne Error1
	cmp byte[r10 + 2], 'm'
	jne Error1
	cmp byte[r10 + 3], 'p'
	jne Error1
	cmp byte[r10 + 4], NULL
	jne Error1

Checkbmp3:
	mov r10, qword[r9 + 16]			; Moves the second argument into r10
	cmp byte[r10], '.'
	je Error5

Checkbmp4:
	inc r10
	cmp byte[r10], NULL
	je Error5
	cmp byte[r10], '.'
	jne Checkbmp4
	cmp byte[r10 + 1], 'b'
	jne Error5
	cmp byte[r10 + 2], 'm'
	jne Error5
	cmp byte[r10 + 3], 'p'
	jne Error5
	cmp byte[r10 + 4], NULL
	jne Error5

CheckArgv:
	mov rax, SYS_open
	mov rdi, qword[r9 + 8]			; This is getting the first argument and putting it into rdi
	mov rsi, O_RDONLY
	syscall
	cmp rax, 0
	jl Error4						; If rax returns a negative value then we will jump to Error1
	mov qword[fDes], rax			; If successful, then we put the value of rax into qword[fDes]

	mov rax, SYS_creat
	mov rdi, qword[r9 + 16]			; This is getting the second argument and putting it into rdi
	mov rsi, S_IRUSR | S_IWUSR		; allows read and write access
	syscall
	cmp rax, 0
	jl Error2						; If rax returns a negative value then we will jump to Error2
	mov qword[wrDes], rax 			; If successful, then we put the value of rax into qword[rwDes]

	mov rax, TRUE 					; If we get to this point, then we will put TRUE into rax because the file was open and access and read correctly
	mov r11, qword[fDes]
	mov qword[rdx], r11				; Returning the value into the 3rd agrument
	mov r11, qword[wrDes]
	mov rcx, r8
	mov qword[rcx], r11 			; Returning the value into the 4th agrument
	jmp goBack

Extraloop:
	mov rdi, errExtra
	call printString
	mov rax, FALSE
	jmp goBack

Lessloop:
	mov rdi,errIncomplete
	call printString
	mov rax, FALSE
	jmp goBack
Error1:
	mov rdi, errReadName
	call printString
	mov rax, FALSE
	jmp goBack

Error2:
	mov rdi, errWriteFile
	call printString
	mov rax, FALSE
	jmp goBack

Error4:
	mov rdi, errReadFile
	call printString
	mov rax, FALSE
	jmp goBack
Error5:
	mov rdi, errWriteName
	call printString
	mov rax, FALSE
	jmp goBack

; All these error checks will put the error that it appropriate with the error that the user made into rdi
goBack:
	mov rsp, rbp
	pop rbp
	pop r14
	pop r13
	pop r12
	pop r11
	ret
; ***************************************************************
;  Read and verify header information
;	bool = setImageInfo(readFileDesc, writeFileDesc,
;				fileSize, picWidth, picHeight)
;  Also modified header information and writes modified
;  header information to output file (i.e., thumbnail file).

; -----
;  2 -> BM						(+0)
;  4 file size					(+2)
;  4 skip						(+6)
;  4 header size				(+10)
;  4 skip						(+14)
;  4 width						(+18)
;  4 height						(+22)
;  2 skip						(+26)
;  2 depth (16/24/32)			(+28)
;  4 compression method code	(+30)
;  4 bytes of pixel data		(+34)
;  skip remaing header entries

; -----
;   Arguments:
;	- read file descriptor (value)
;	- write file descriptor (value)
;	- old image width (address)
;	- old image height (address)
;	- new image width (value)
;	- new image height (value)

;  Returns:
;	file size (via reference)
;	image width (via reference)
;	image height (via reference)
;	TRUE or FALSE


;	YOUR CODE GOES HERE
global setImageInfo
setImageInfo:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15


	mov rbp, rdi 					; read file descriptor value
	mov rbx, rsi 					; write file descriptor value
	mov r12, rdx 					; old image width (address)
	mov r13, rcx					; old image height (address)
	mov r14, r8 					; new image width value
	mov r15, r9 					; new image hegiht value


	mov rax, SYS_read
	mov rdi, rbp 					; If we get to here, we will move the first agrument address into rdi
	mov rsi, header 				; Moves what we're reading into rsi
	mov rdx, HEADER_SIZE			; HEADER_SIZE will be how many characters rdx reads every syscall
	syscall
	cmp rax, 0
	jl Error3

; Check if Signature is BM
	cmp word[header], 0x4d42 		; Check if signutre is "BM"
	jne Errorfiletype
; Check the color depth
	cmp word[header + 28], 24 		; Check color depth
	jne Errordepth
; Check compType
	cmp dword[header + 30], 0 		; Check if compression type = 0
	jne ErrorCompType
; Check Size
	mov eax, dword[header + 10]		; Size of header
	mov r10d, dword[header + 34]	; Size of image in bytes
	add eax, r10d					; file size (to check)
	mov r10d, dword[header + 2]		; file size (read)
	cmp eax, r10d
	jne ErrorSize 					; fileSize != header size + size of image

; Return old width & height
	mov eax, dword[header + 18]		; old image width into eax
	mov dword[r12], eax 			; return old image
	mov eax, dword[header + 22]		; old image height into eax
	mov dword[r13], eax 			; return old height

; Update to new width & height
	mov dword[header + 18], r8d 	; new image width into header
	mov dword[header + 22], r9d 	; new image height into header
; Write to new header to new file
	mov rax, SYS_write
	mov rdi, rbx
	mov rsi, header
	mov rdx, HEADER_SIZE
	syscall
	jmp Sucessdude

Errorfiletype:
	mov rdi, errFileType
	call printString
	mov rax, FALSE
	jmp goBack1

Errordepth:
	mov rdi, errDepth
	call printString
	mov rax, FALSE
	jmp goBack1

ErrorCompType:
	mov rdi, errCompType
	call printString
	mov rax, FALSE
	jmp goBack1

ErrorSize:
	mov rdi, errSize
	call printString
	mov rax, FALSE
	jmp goBack1

Error3:
	mov rdi, errReadHdr
	call printString
	mov rax, FALSE
	jmp goBack1

; All of these code blocks will check for errors.
Sucessdude:
	mov rax, TRUE
goBack1:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp

ret



; ***************************************************************
;  Return a row from read buffer
;	This routine performs all buffer management

; ----
;  HLL Call:
;	bool = readRow(readFileDesc, picWidth, rowBuffer[]);

;   Arguments:
;	- read file descriptor (value)
;	- image width (value)
;	- row buffer (address)
;  Returns:
;	TRUE or FALSE

; -----
;  This routine returns TRUE when row has been returned
;	and returns FALSE if there is no more data to
;	return (i.e., all data has been read) or if there
;	is an error on read (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.


;	YOUR CODE GOES HERE
global readRow
readRow:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi 			; moving the read file descriptor
	mov r14, rdx 			; Puts the row buffer into r14
	mov rax, rsi
	mov r13, 3
	mul r13
	mov r13, rax 			; limit = maxwidth * 3
	mov r15, 0

getNextChar:
	mov r10, qword[curr]			; Move the value of curr into r10
	mov r11, qword[buffMax]			; Move the value of buffMax into r11
	cmp r10, r11
	jb Next

	mov r10b, byte[wasEOF]			; checks for EOF of file
	cmp r10b, FALSE
	jne QuitFunction

	mov rax, SYS_read				; Will read the file
	mov rdi, r12
	mov rsi, buffer
	mov rdx, BUFF_SIZE
	syscall

	cmp rax, 0 						; If rax is a negavtive value then that's an error message
	jl errOnRead

	cmp rax, 0 						; actual read = 0, returns false
	je QuitFunction

	mov qword[curr], 0

	cmp rax, BUFF_SIZE
	jl notEOF
	jmp Next

notEOF:
	mov byte[wasEOF], TRUE
	mov qword[buffMax], rax

Next:
;	mov r11, 0 								; Resize buffMax to 0
;	mov r10, qword[curr]
	mov r11b, byte[buffer + r10]			; chr = buffer[curr]
	inc qword[curr]							; curr++
	mov byte[r14 + r15], r11b 				; oldBuffer[i] = chr
	inc r15 								; i++
	cmp r15, r13 							; if (i < (width * 3))
	jl getNextChar

	mov rax, TRUE
	jmp Done

errOnRead:
	mov rdi, errRead
	call printString
	jmp QuitFunction

QuitFunction:
	mov rax, FALSE

Done:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

; ***************************************************************
;  Write image row to output file.
;	Writes exactly (width*3) bytes to file.
;	No requirement to buffer here.

; -----
;  HLL Call:
;	writeRow(writeFileDesc, picWidth, rowBuffer);

;  Arguments are:
;	- write file descriptor (value)
;	- image width (value)
;	- row buffer (address)

;  Returns:
;	N/A

; -----
;  This routine returns SUCCESS when row has been written
;	and returns NOSUCCESS only if there is an
;	error on write (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.


;	YOUR CODE GOES HERE
global writeRow
writeRow:
	push rbp
	mov rbp, rsp
	push r11
	push r12
	push r13
	push r14
	push r15

	mov rax, rsi
	mov r14, rdx
	mov r12, 3
	mul r12
	mov r12, rax 				; maxwidth * 3
	mov r13, rdi

	mov rax, 0
	mov rax, SYS_write			; write file
	mov rdi, r13
	mov rsi, r14
	mov rdx, r12
	syscall

	cmp rax, 0
	jl errOnWrite

	mov rax, TRUE
	jmp Done1

errOnWrite:
	mov rdi, errWrite
	call printString

	mov rax, FALSE

Done1:
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	mov rsp, rbp
	pop rbp

	ret



; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.

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
	mov		rbp, rsp
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

