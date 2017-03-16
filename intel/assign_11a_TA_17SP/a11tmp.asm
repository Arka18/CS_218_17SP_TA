;  CS 218 - Assignment #11
;  Functions Template

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20			; space

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
BUFF_SIZE	equ	1000000			; buffer size

; -----
;  Variables for getOptions() / getImageFileNames() function.

eof		db	FALSE

usageMsg	db	"Usage: ./thumb <inputFile.bmp> "
		db	"<outputFile.bmp>", LF, NULL
errIncomplete	db	"Error, incomplete command line arguments.", LF, NULL
errExtra	db	"Error, too many command line arguments.", LF, NULL
errReadSpec	db	"Error, invalid read specifier.", LF, NULL
errWriteSpec	db	"Error, invalid write specifier.", LF, NULL
errReadName	db	"Error, invalid source file name.  Must be '.bmp' file.", LF, NULL
errWriteName	db	"Error, invalid output file name.  Must be '.bmp' file.", LF, NULL
errReadFile	db	"Error, unable to open input file.", LF, NULL
errWriteFile	db	"Error, unable to open output file.", LF, NULL

; -----
;  Variables for readHeader() / setImageInfo() function.

HEADER_SIZE	equ	138

errReadHdr	db	"Error, unable to read header from source image file."
		db	LF, NULL
errFileType	db	"Error, invalid file signature.", LF, NULL
errDepth	db	"Error, unsupported color depth.  Must be 24-bit color."
		db	LF, NULL
errCompType	db	"Error, only non-compressed images are supported."
		db	LF, NULL
errSize		db	"Error, bitmap block size inconsistant.", LF, NULL
errWriteHdr	db	"Error, unable to write header to output image file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for getRow() function.

buffMax		dq	BUFF_SIZE
curr		dq	BUFF_SIZE
wasEOF		db	FALSE
pixelCount	dq	0

errRead		db	"Error, reading from source image file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for writeRow() function.

errWrite	db	"Error, writting to output image file.", LF,
		db	"Program terminated.", LF, NULL


; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer		resb	BUFF_SIZE
header		resb	HEADER_SIZE


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
;	- argc (value)	- rdi
;	- argv table (address) - rsi
;	- read file descriptor (address) - rdx
;	- write file descriptor (address) - rcx
;  Returns:
;	read file descriptor (via reference)
;	write file descriptor (via reference)
;	TRUE or FALSE


;	YOUR CODE GOES HERE

global getImageFileNames
getImageFileNames:
	push	rbp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

getImageFileNamesStart:
	cmp 	rdi, 1
	je	errorUsage		; if argc == 1, print usage message

	cmp 	rdi, 3
	jl 	errorIncomplete		; if argc < 3, print incomplete args

	cmp 	rdi, 3
	jg 	errorExtra		; if argc > 3, print extra args

	mov	rbx, qword [rsi + 8] 	; input file name addr
	cmp 	byte [rbx], "." 	; string starts with "." / incomplete name
	je 	errorReadName

; 2nd arg - inputFileName
readNameLp:
	inc 	rbx
	cmp 	byte [rbx], NULL	; string with no "."
	je 	errorReadName
	cmp 	byte [rbx], "."
	jne 	readNameLp
 	inc 	rbx			; hit file extension
	cmp 	dword [rbx], 0x00706d62	; if (fileExtension != .bmp) goto errorReadName
	jne 	errorReadName
; 2nd arg - end

; 3rd arg - outputFileName
	mov 	rbx, qword [rsi + 16] 	; output file name addr
	cmp 	byte [rbx], "."		; ...
	je 	errorWriteName

writeNameLp:
	inc 	rbx
	cmp 	byte [rbx], NULL
	je 	errorWriteName
	cmp 	byte [rbx], "."
	jne 	writeNameLp
	inc 	rbx
	cmp 	dword [rbx], 0x00706d62 ; hit file ext
	jne 	errorWriteName
; 3rd arg - end

; Check if input file opens
	push 	rsi
	push 	rdx
	push 	rcx			; save args

	; input file open
	mov 	rax, SYS_open
	mov 	rdi, qword [rsi + 8] 	; 2nd arg = fileName
	mov 	rsi, O_RDONLY		; RO perms
	syscall

	pop 	rcx			; restore args
	pop 	rdx
	pop 	rsi

	cmp 	rax, 0			; if rax < 0; error
	jl 	errorReadFile

	mov	qword [rdx], rax	; store input file descriptor
; end input file open

; Check if output file opens
	push 	rsi
	push	rcx			; save args

	; output file creation
	mov 	rax, SYS_creat
	mov 	rdi, qword [rsi + 16]	; 3rd arg = filename
	mov 	rsi, S_IRUSR | S_IWUSR 	; R/W perms
	syscall

	pop	rcx			; restore args
	pop 	rsi

	cmp 	rax, 0			; if rax < 0; error
	jl 	errorWriteFile

	mov 	qword [rcx], rax	; store output file descriptor
	jmp 	getImageFileNamesSuccess

; ERROR START
errorUsage:
	mov 	rax, usageMsg
	jmp 	getImageFileNamesPrint

errorIncomplete:
	mov	rax, errIncomplete
	jmp 	getImageFileNamesPrint

errorExtra:
	mov 	rax, errExtra
	jmp 	getImageFileNamesPrint

errorReadSpec:
	mov 	rax, errReadSpec
	jmp 	getImageFileNamesPrint

errorWriteSpec:
	mov 	rax, errWriteSpec
	jmp 	getImageFileNamesPrint

errorReadName:
	mov 	rax, errReadName
	jmp 	getImageFileNamesPrint

errorWriteName:
	mov 	rax, errWriteName
	jmp 	getImageFileNamesPrint

errorReadFile:
	mov 	rax, errReadFile
	jmp 	getImageFileNamesPrint

errorWriteFile:
	mov	rax, errWriteFile
	jmp 	getImageFileNamesPrint

getImageFileNamesPrint:
	mov 	rdi, rax
	call 	printString
	mov 	rax, FALSE
	jmp 	getImageFilesNamesEnd
; ERROR END

getImageFileNamesSuccess:
	mov 	rax, TRUE

getImageFilesNamesEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop	rbx
	pop	rbp
	ret


; ***************************************************************
;  Read and verify header information

;  HLL Call:
;	bool = setImageInfo(readFileDesc, writeFileDesc,
;		&picWidth, &picHeight, thumbWidth, thumbHeight)

;  If correct, also modifies header information and writes modified
;  header information to output file (i.e., thumbnail file).

; -----
;  2 -> BM				(+0)
;  4 file size				(+2)
;  4 skip				(+6)
;  4 header size			(+10)
;  4 skip				(+14)
;  4 width				(+18)
;  4 height				(+22)
;  2 skip				(+26)
;  2 depth (16/24/32)			(+28)
;  4 compression method code		(+30)
;  4 bytes of pixel data		(+34)
;  skip remaing header entries

; -----
;   Arguments:
;	- read file descriptor (value) - rdi
;	- write file descriptor (value) - rsi
;	- old image width (address) - rdx
;	- old image height (address) - rcx
;	- new image width (value) - r8
;	- new image height (value) - r9

;  Returns:
;	file size (via reference)
;	old image width (via reference)
;	old image height (via reference)
;	TRUE or FALSE


;	YOUR CODE GOES HERE

global setImageInfo
setImageInfo:
	push 	rbp
	push 	rbx
	push 	r12
	push 	r13
	push 	r14
	push 	r15

setImageInfoStart:
	mov 	rbp, rdi 	; read file desc (val)
	mov 	rbx, rsi 	; write file desc (val)
	mov	r12, rdx	; old image width (addr)
	mov 	r13, rcx 	; old image heeight (addr)
	mov 	r14, r8		; new image width (val)
	mov 	r15, r9		; new image height (val)

	; read header portion of read file
	mov 	rax, SYS_read
	mov 	rdi, rbp		; rbp = file desc for read file
	mov 	rsi, header
	mov 	rdx, HEADER_SIZE
	syscall

	mov 	rax, 0			; unsuccessful read
	jl	errorReadHdr

; Check file type / signature
	cmp 	word [header], 0x4d42	; checks if signature = "BM"
	jne 	errorFileType

; Check depth
	cmp 	word [header + 28], 24	; checks if color depth = 24
	jne 	errorDepth

; Check compType
	cmp 	dword [header + 30], 0	; checks if compression type = 0
	jne 	errorCompType

; Check size
	mov 	eax, dword [header + 10] 	; size of header
	mov 	r10d, dword [header + 34] 	; size of image in bytes
	add 	eax, r10d			; file size (to check)
	mov 	r10d, dword [header + 2] 	; file size (read)
	cmp 	eax, r10d
	jne 	errorSize			; fileSize != header size + size of image

; Return old width & height
	mov 	eax, dword [header + 18]	; old image width
	mov 	dword [r12], eax 		; return old image width
	mov 	eax, dword [header + 22] 	; old image height
	mov 	dword [r13], eax 		; return old image width

; Update to new width and height
	mov 	eax, r8d
	mul 	r9d
	add 	eax, HEADER_SIZE
	mov 	dword [header + 2], eax 	; set new file size

	mov 	dword [header + 18], r8d	; new image width
	mov 	dword [header + 22], r9d	; new image height
;	mov	qword [header + 136], 0x0000000000001234

; Write to new header to new file
	mov 	rax, SYS_write
	mov 	rdi, rbx
	mov 	rsi, header
	mov 	rdx, HEADER_SIZE
	syscall

	mov 	rax, 0			; unsucessful write
	jl 	errorWriteHdr

	jmp 	setImageInfoSuccess

; -------- Start errors
errorReadHdr:
	mov 	rax, errReadHdr
	jmp 	setImageInforPrint

errorFileType:
	mov 	rax, errFileType
	jmp 	setImageInforPrint

errorDepth:
	mov 	rax, errDepth
	jmp 	setImageInforPrint

errorCompType:
	mov	rax, errCompType
	jmp 	setImageInforPrint

errorSize:
	mov 	rax, errSize
	jmp 	setImageInforPrint

errorWriteHdr:
	mov 	rax, errWriteHdr
	jmp 	setImageInforPrint

setImageInforPrint:
	mov 	rdi, rax
	call 	printString
	mov 	rax, FALSE
	jmp 	setImageInfoEnd
; --------- End errors

setImageInfoSuccess:
	mov 	rax, TRUE

setImageInfoEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rbx
	pop 	rbp
	ret






; ***************************************************************
;  Return a row from read buffer
;	This routine performs all buffer management

; ----
;  HLL Call:
;	bool = readRow(readFileDesc, picWidth, rowBuffer[]);

;   Arguments:
;	- read file descriptor (value) 	- rdi
;	- image width (value)	- rsi
;	- row buffer (address)	- rdx
;  Returns:
;	TRUE or FALSE

; -----
;  This routine returns TRUE when row has been returned
;	and returns FALSE if there is no more data to
;	return (i.e., all data has been read) or if there
;	is an error on read (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.

; -----------------------
; Algorithm to manage buffer
	; i = 0
	; wasEOF = FALSE
	; bufferLp:
	; loop for (i < (width * 3)){
	; 	if(curr >= buffMax){
	; 		if(wasEOF)	exit with FALSE
	; 		read file
	; 		if(rax < 0)
	; 			display error
	; 			exit with FALSE
	; 		}
	; 		if(actualRead == 0) 	exit with FALSE
	; 		if(actualRead < BUFF_SIZE){
	; 			buffMax = rax
	; 			eof = TRUE
	; 		}
	; 		curr = 0
	; 	}
	; 	char = buffer[curr]
	; 	oldRow[i] = char
	; 	i++
	; 	curr++
	; 	goto bufferLp
	; }
	; return TRUE
; -----------------------


;	YOUR CODE GOES HERE

global readRow
readRow:
	push	rbp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

readRowStart:
 	mov 	r12, rdi 	; value of read file descriptor
 	mov 	r14, rdx 	; addres of row buffer
 	mov 	r15, 0 		; i = 0 - rbx

 	mov 	rax, rsi
 	mov 	r13, 3
 	mul 	r13 		; width * 3 = r10
 	mov 	r13, rax

bufferLp:
	cmp 	r15, r13 	; while(i < width*3)
	jae 	bufferLpDone
	mov 	rbx, qword [curr]
	cmp 	rbx, qword [buffMax] 	; if(curr >= buffMax)
	jb	insertChar

	cmp 	byte [wasEOF], TRUE 	; 	if(wasEOF)
	je 	readRowFalse 		;		return FALSE

	; read file
	mov 	rax, SYS_read
	mov 	rdi, r12
	mov 	rsi, buffer
	mov 	rdx, qword [buffMax]
	syscall

	cmp 	rax, 0			; if(rax < 0)
	jl 	errorRead 		; 	display error and return FALSE

	cmp 	rax, 0			; if(rax == 0)
	je 	readRowFalse 		; 	return FALSE

	cmp 	rax, BUFF_SIZE 		; if(rax < BUFF_SIZE)
	jae 	eofDone
	mov 	qword [buffMax], rax 	; 	buffMax = rax
	mov 	byte [wasEOF], TRUE 	; 	eof = TRUE

eofDone:
	mov 	qword [curr], 0 	; curr = 0

insertChar:
	; curr in r10
	mov 	r11, 0
	mov 	rbx, qword [curr]
	mov 	r11b, byte [buffer + rbx]	; r11b = buffer[curr]
	mov 	byte [r14 + r15], r11b 		; oldRow[i] = char
	inc 	qword [curr] 			; curr++
	inc 	r15 				; i++
	jmp 	bufferLp
	;cmp 	r15, r13
	;jb 	bufferLp

bufferLpDone:
	jmp 	readRowTrue

errorRead:
	mov 	rax, errRead
	jmp 	readRowPrint

readRowPrint:
	mov 	rdi, rax
	call 	printString

readRowFalse:
	mov 	rax, FALSE
	jmp 	readRowEnd

readRowTrue:
	mov 	rax, TRUE

readRowEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop	rbx
	pop	rbp
	ret





; ***************************************************************
;  Write image row to output file.
;	Writes exactly (width*3) bytes to file.
;	No requirement to buffer here.

; -----
;  HLL Call:
;	writeRow(writeFileDesc, picWidth, rowBuffer);

;  Arguments are:
;	- write file descriptor (value) - rdi - r12
;	- image width (value) - rsi - r13
;	- row buffer (address) - rdx - r14

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
	push	rbp
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

writeRowStart:
	mov 	r12, rdi 	; write file descriptor
	mov 	r13, rsi	; value of image width
	mov 	r14, rdx	; addres of row buffer

	mov 	rax, r13	; width
	mov 	rcx, 3
	mul 	rcx 		; width * 3
	mov 	r13, rax	; r15 = width * 3

	mov 	rax, SYS_write
	mov 	rdi, r12
	mov	rsi, r14
	mov 	rdx, r13
	syscall

	cmp 	rax, 0
	jl	errorWrite

	jmp 	writeRowSuccess

errorWrite:
	mov 	rax, errWrite
	jmp 	writeRowPrint

writeRowPrint:
	mov 	rdi, rax
	call 	printString
	mov 	rax, FALSE
	jmp 	writeRowEnd

writeRowSuccess:
	mov 	rax, TRUE

writeRowEnd:
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop	rbx
	pop	rbp
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

