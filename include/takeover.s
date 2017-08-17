	SECTION OldView,DATA

;Data junk goes here
olddmareq	dc.w	0
oldintena	dc.w	0
oldintreq	dc.w	0
oldadkcon	dc.w	0

oldview:	dc.l	0
oldcopper:	dc.l	0

	SECTION Takeover,CODE

SystemTakeover:
	move.l	#CustomBase,a5

;Save the old registers.
	move.w	dmaconr(a5),d0
	or.w	#$8000,d0
	move.w	d0,olddmareq

	move.w	intenar(a5),d0
	or.w	#$8000,d0
	move.w	d0,oldintena

	move.w	intreqr(a5),d0
	or.w	#$8000,d0
	move.w	d0,oldintreq

	move.w	adkconr(a5),d0
	or.w	#$8000,d0
	move.w	d0,oldadkcon

	move.l	gfx_base,a6
	move.l	34(a6),oldview
	move.l	38(a6),oldcopper

	move.l	#0,a1
	
	jsr	-222(a6)	;LoadView
	jsr	-270(a6)	;WaitTOF
	jsr	-270(a6)	

	move.l	SysBase,a6
	jsr	_LVOForbid(a6)

	RTS

SystemRelease:
	move.l	#CustomBase,a5

;Restore the old registers.
	move.w	#$7fff,dmacon(a5)
	move.w	olddmareq,dmacon(a5)

	move.w	#$7fff,intena(a5)
	move.w	oldintena,intena(a5)

	move.w	#$7fff,intreq(a5)
	move.w	oldintreq,intreq(a5)

	move.w	#$7fff,adkcon(a5)
	move.w	oldadkcon,adkcon(a5)

	move.l	oldcopper,cop1lc(a5)
	move.l	gfx_base,a6
	move.l	oldview,a1

	jsr	-222(a6)	;LoadView
	jsr	-270(a6)	;WaitTOF
	jsr	-270(a6)

	move.l	SysBase,a6
	jsr	_LVOPermit(a6)

	RTS

