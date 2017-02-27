;  CS 218 - Assignment 8
;  Provided Main.

;  DO NOT EDIT/ALTER THIS FILE

; **********************************************************************************
;  Main routine to call assembly language procedures/functions:

;  * Procedure selectionSort() sorts the numbers into descending
;    order (large to small).  Uses the radix sort algorithm (from asst #7).

;  * Procedure listStats() finds the minimum, median, and maximum, for a
;    list of numbers.  Note, for an odd number of items, the median value
;    is defined as the middle value.  For an even number of values, it is
;    the integer average of the two middle values.

;  * Function listAverage() computes and returns the average of a list of numbers.

;  * Function betaValue() finds and returns the B (beta) value of a list
;    of numbers.  The summation for the a (alpha) value must be performed
;    as a quad-word.

; **********************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	0			; unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; call code for read
SYS_write	equ	1			; call code for write
SYS_open	equ	2			; call code for file open
SYS_close	equ	3			; call code for file close
SYS_fork	equ	57			; call code for fork
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ	85			; call code for file open/create
SYS_time	equ	201			; call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

; -----
;  Data Sets for Assignment #8.

list1		dd	 121,  127,  110,  122,  161
		dd	 103,  112,  120,  119,  120
		dd	 120,  127,  112,  130,  133
		dd	 130,  133,  223,  141,  160
		dd	 190,  118,  150,  175,  123
		dd	 110,  137,  146,  199
len1		dd	29
estMed1		dd	0
min1		dd	0
med1		dd	0
max1		dd	0
ave1		dd	0
pctErr1	dd	0
beta1		dq	0


list2		dd	1123, 1122, 1549, 1236, 1163
		dd	1110, 1123, 1191, 1312, 1307
		dd	1111, 1124, 1384, 1159, 1548
		dd	1117, 1132, 1175, 1138, 1139
		dd	1121, 1232, 1261, 1126, 1104
		dd	1114, 1141, 1155, 1654, 1167
		dd	1113, 1141, 1144, 1236, 1126
		dd	1113, 1431, 1435, 1286, 1675
		dd	1113, 1342, 1422, 1146, 1154
		dd	1142, 1114, 1124, 1167, 1566
		dd	2612, 2651, 2131, 2211, 2132
		dd	2611, 2634, 2725, 2416, 2321
		dd	2611, 2621, 2733, 2747, 2821
		dd	2613, 2131, 2957, 2521, 2122
		dd	2621, 2623, 2311, 2155, 2311
		dd	2611, 2621, 2641, 2859, 2721
		dd	2113, 2141, 2144, 2236, 2126
		dd	2645, 2661, 2123, 2947, 2621
		dd	2631, 2621, 2547, 2431, 2251
		dd	2664, 2671, 2819, 2145, 2321
		dd	2661, 2621, 2219, 2467, 2221
		dd	2113, 2431, 1435, 1286, 1085
len2		dd	110
estMed2		dd	0
min2		dd	0
med2		dd	0
max2		dd	0
ave2		dd	0
pctErr2		dd	0
beta2		dq	0


list3		dd	2127, 6135, 2117, 1115, 1161
		dd	1110, 1120, 3122, 1124, 1226
		dd	6129, 9113, 1155, 1135, 1437
		dd	2119, 1141, 2143, 1145, 3149
		dd	9153, 9119, 1123, 2117, 1259
		dd	1116, 1115, 2151, 1167, 1169
		dd	1128, 9130, 3132, 1133, 1111
		dd	3138, 1140, 1142, 2144, 1146
		dd	2121, 1125, 5151, 2113, 1219
		dd	1257, 9199, 4153, 1165, 2179
		dd	1127, 1155, 4117, 5115, 1161
		dd	7183, 9114, 2121, 5128, 1212
		dd	1126, 1117, 1127, 1127, 3184
		dd	5174, 9112, 1125, 5126, 1129
		dd	1188, 1115, 1111, 2118, 1215
		dd	3126, 9117, 2115, 1110, 1114
		dd	1124, 1143, 3134, 2112, 2113
		dd	2172, 9176, 1156, 1165, 1256
		dd	1153, 1140, 2191, 1168, 1162
		dd	1146, 2147, 3167, 3177, 1144
len3		dd	100
estMed3		dd	0
min3		dd	0
med3		dd	0
max3		dd	0
ave3		dd	0
pctErr3		dd	0
beta3		dq	0


list4		dd	2244, 1234, 1313, 1221, 3216
		dd	1141, 4321, 2324, 2313, 5223
		dd	1318, 1333, 1112, 2410, 1110
		dd	2124, 3243, 3524, 1512, 2323
		dd	2153, 1440, 1111, 2618, 2212
		dd	4447, 3427, 4414, 3717, 2919
		dd	5183, 1450, 5651, 4828, 1515
		dd	3183, 2414, 4311, 2918, 1212
		dd	1426, 1917, 3217, 2717, 1414
		dd	2174, 2912, 2115, 1616, 2229
		dd	4318, 1335, 1351, 1818, 2515
		dd	1126, 3317, 2315, 1000, 1414
		dd	1124, 3113, 1514, 1212, 1313
		dd	4272, 3326, 2416, 2515, 1616
		dd	1153, 2910, 3451, 1818, 4212
		dd	2146, 2317, 1317, 2117, 1211
		dd	1255, 1452, 2615, 3219, 6111
		dd	1464, 1552, 1715, 4312, 1253
		dd	1483, 2515, 2911, 3418, 1137
		dd	2966, 3717, 1987, 2617, 2435
		dd	2610, 4320, 2332, 2524, 2659
		dd	1319, 1232, 1195, 1335, 1373
		dd	3339, 2341, 2343, 1345, 1494
		dd	1353, 1439, 1313, 1000, 1953
		dd	2416, 1415, 1551, 1667, 2912
		dd	1628, 2430, 1132, 2133, 1000
		dd	2938, 3240, 2342, 2444, 1461
		dd	1121, 4425, 1251, 1313, 1191
		dd	1257, 5999, 1153, 2665, 1791
		dd	1118, 2455, 2417, 3515, 2111
		dd	1283, 3234, 2611, 1828, 2221
		dd	2826, 4317, 3827, 2127, 2400
		dd	1168, 3115, 3611, 1218, 1550
		dd	2436, 2317, 1515, 2411, 1448
		dd	3314, 1243, 1334, 2312, 2381
		dd	1432, 8276, 2156, 1665, 1647
		dd	3353, 1140, 2231, 1868, 2265
		dd	2896, 6547, 1367, 1777, 2446
		dd	3455, 3332, 1385, 2449, 1146
		dd	1264, 3472, 2175, 3162, 1721
		dd	9999, 9999, 9999, 9999, 9999
		dd	9999, 9999, 9999, 9999, 9999
		dd	9999, 9999, 9999, 9999, 9999
		dd	9999, 9999, 9999, 9999, 9999
		dd	9999, 9999, 9999, 9999, 9999
		dd	9999, 9999, 9999, 9999, 9999
len4		dd	230
estMed4		dd	0
min4		dd	0
med4		dd	0
max4		dd	0
ave4		dd	0
pctErr4		dd	0
beta4		dq	0


; **********************************************************************************

extern	listEstMedian, selectionSort, listStats, betaValue

section	.text
global	main
main:

; **************************************************
;  Main routine calls functions for each data set.

;  Notes:
;	The high level language call is shown (in comments)
;	followed by the implementing assembly code for each

;	Assembly functions return results in eax
;	(for double-word values)

; **************************************************
;  Call functions for data set 1.

;  find estimated median
	mov	rdi, list1
	mov	esi, dword [len1]
	call	listEstMedian
	mov	dword [estMed1], eax

;  selectionSort(list, len)
	mov	rdi, list1
	mov	esi, dword [len1]
	call	selectionSort

;  listStats(list, len, estMed, &min, &med, &max, &ave, &pctErr)
	mov	rdi, list1
	mov	esi, dword [len1]
	mov	edx, dword [estMed1]
	mov	rcx, min1
	mov	r8, med1
	mov	r9, max1
	push	pctErr1
	push	ave1
	call	listStats

;  beta1 = betaValue(list, len)
	mov	rdi, list1
	mov	esi, dword [len1]
	call	betaValue
	mov	qword [beta1], rax

; **************************************************
;  Call functions for data set 2.

;  find estimated median
	mov	rdi, list2
	mov	esi, dword [len2]
	call	listEstMedian
	mov	dword [estMed2], eax

;  selectionSort(list, len)
	mov	rdi, list2
	mov	esi, dword [len2]
	call	selectionSort

;  listStats(list, len, estMed, &min, &med, &max, &ave, &pctErr)
	mov	rdi, list2
	mov	esi, dword [len2]
	mov	edx, dword [estMed2]
	mov	rcx, min2
	mov	r8, med2
	mov	r9, max2
	push	pctErr2
	push	ave2
	call	listStats
	add	rsp, 16

;  beta1 = betaValue(list, len)
	mov	rdi, list2
	mov	esi, dword [len2]
	call	betaValue
	mov	qword [beta2], rax

; **************************************************
;  Call functions for data set 3.

;  find estimated median
	mov	rdi, list3
	mov	esi, dword [len3]
	call	listEstMedian
	mov	dword [estMed3], eax

;  selectionSort(list, len)
	mov	rdi, list3
	mov	esi, dword [len3]
	call	selectionSort

;  listStats(list, len, estMed, &min, &med, &max, &ave, &pctErr)
	mov	rdi, list3
	mov	esi, dword [len3]
	mov	edx, dword [estMed3]
	mov	rcx, min3
	mov	r8, med3
	mov	r9, max3
	push	pctErr3
	push	ave3
	call	listStats
	add	rsp, 16

;  beta1 = betaValue(list, len)
	mov	rdi, list3
	mov	esi, dword [len3]
	call	betaValue
	mov	qword [beta3], rax

; **************************************************
;  Call functions for data set 4.

;  find estimated median
	mov	rdi, list4
	mov	esi, dword [len4]
	call	listEstMedian
	mov	dword [estMed4], eax

;  selectionSort(list, len)
	mov	rdi, list4
	mov	esi, dword [len4]
	call	selectionSort

;  listStats(list, len, estMed, &min, &med, &max, &ave, &pctErr)
	mov	rdi, list4
	mov	esi, dword [len4]
	mov	edx, dword [estMed4]
	mov	rcx, min4
	mov	r8, med4
	mov	r9, max4
	push	pctErr4
	push	ave4
	call	listStats
	add	rsp, 16

;  beta1 = betaValue(list, len)
	mov	rdi, list4
	mov	esi, dword [len4]
	call	betaValue
	mov	qword [beta4], rax

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rbx, SUCCESS
	syscall

