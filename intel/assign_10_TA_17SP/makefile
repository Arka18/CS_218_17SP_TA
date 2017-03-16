# Makefile for assign_09
# 17SP

runme:	spiro
	./spiro -r1 10 -r2 10 -op 10 -sp 79 -cl b

test1:	spiro
	./spiro -r1 c0 -r2 31 -op c0 -sp 2 -cl y

test2:	spiro
	./spiro -r1 80 -r2 10 -op 90 -sp 79 -cl p

spiro:	a10tmpV2.asm spiro.cpp
	./asm10 spiro a10tmpV2

dddRun:	spiro
	ddd --args spiro -r1 10 -r2 10 -op 10 -sp 2 -cl b

dddErr: spiro
	ddd --args spiro -r1 fh -r2 23 -op 3a -sp 1 -cl r

progTest:	a10tst spiro
	./a10tst spiro

alexisProg:	spiro.cpp alexisA10.asm
	./asm10 spiro alexisA10

alexis:	alexisProg
	./a10tst spiro

amitProg:	spiro.cpp amitA10.asm
	./asm10 spiro amitA10

amit:	amitProg
	./a10tst spiro