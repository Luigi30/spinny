BltSize MACRO
	\1<<6|\2
	ENDM

WaitBlit:
	PUSHL	a5

	move.l	#CustomBase,a5
	tst	dmaconr(a5)
.loop
	btst	#6,dmaconr(a5)
	bne	.loop

	POPL	a5
	rts

WaitForVBL:
	PUSHL	d0

.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#262<<8,d0
	bne.b	.loop

.loop2	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#262<<8,d0
	bne.b	.loop2

	POPL	d0
	rts

ClearLoRes:
	;a0 = bpl to clear
	;Need to clear 4000 words of memory at a0.
	PUSHL	a5
	
	move.l	#CustomBase,a5
	bsr	WaitBlit

	move.w	#$0100,bltcon0(a5)	;BLTCON0 = ---D, null minterm
	move.w	#$0,bltcon1(a5)		;no BLTCON1 flags
	move.w	#0,bltdmod(a5)		;no D modulo
	move.l	a0,bltdpt(a5)		;D = a0
	move.w	#(1000<<6)|4,bltsize(a5);blitting 4000 words

	POPL	a5
	RTS		

