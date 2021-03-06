����                                        ; Shape and drawing structures

	STRUCTURE Vertex3D,0	; what is the second parameter?
	UWORD	vertex_x	; x coordinate
	UWORD	vertex_y	; y coordinate
	UWORD	vertex_z	; z coordinate
	LABEL	Vertex3D_SIZEOF	; $6
;
	STRUCTURE Translation3D,0
	FLOAT	trans_x		; float
	FLOAT	trans_y		; float
	FLOAT	trans_z		; float
	LABEL	Translation3D_SIZEOF

	STRUCTURE Rotation3D,0
	FLOAT	rot_x		; float
	FLOAT	rot_y		; float
	FLOAT	rot_z		; float
	LABEL	Rotation3D_SIZEOF

	STRUCTURE Scale3D,0
	FLOAT	scale_x		; float
	FLOAT	scale_y		; float
	FLOAT	scale_z		; float
	LABEL	Scale3D_SIZEOF
;
	STRUCTURE Shape3D,0
	UWORD	shape_vertexCount	; number of vertexes in vertexList
	APTR	shape_vertexList	; ptr to an array of Vertex3D structs
	STRUCT	shape_translation,Translation3D_SIZEOF	
	STRUCT	shape_rotation,Rotation3D_SIZEOF
	STRUCT	shape_scale,Scale3D_SIZEOF
	LABEL	Shape3D_SIZEOF

Vertex3D_DEF	MACRO
	dc.w	\1,\2,\3
		ENDM	

;;;;;;;;
; Shape and drawing routines
;;;;;;;;
RotatePoint	MACRO
		move.l	\1,d0
		move.l	\2,d1
		move.l	\3,d2
		JSR	_RotatePoint
		ENDM

SetPixel	MACRO
		lea	\1,a0
		move.l	\2,d0
		move.l	\3,d1
		JSR	_SetPixel
		ENDM

DrawLine	MACRO
		lea	\1,a0
		move.l	\2,d0
		move.l	\3,d1
		move.l	\4,d2
		move.l	\5,d3
		JSR	_DrawLine
		ENDM

PlotVertex	MACRO
		lea	\1,a0
		lea	\2,a1
		move.l	\3,d0
		move.l	\4,d1
		JSR	_PlotVertex
		ENDM

DrawShape	MACRO
		lea	\1,a0
		lea	\2,a1
		move.l	\3,d0
		move.l	\4,d1
		JSR	_DrawShape
		ENDM

;;;;;;;;;;;;;;;;;;;;

_DrawShape:
	;a0 = bpl to write
	;a1 = ptr to start of shape data
	;d0 = offset x
	;d1 = offset y

	PRESERVE_D
	PRESERVE_A

	LINK	a6,#-16

	move.w	d0,-4(a6)
	move.w	d1,-8(a6)

	move.l	a1,a2		;preserve
	move.l	a1,a3		;preserve
	move.w	(a1),d7
	subi	#1,d7
	add.w	#2,a1

	lea	TransformedVertexBuffer,a4
.rotateLoop
	;Rotate the vertices.
	move.w	vertex_x(a1),d0
	move.w	vertex_y(a1),d1
	move.w	shape_rot_deg,d2
	JSR	_RotatePoint

	move.w	d0,(a4)+
	move.w	d1,(a4)+
	move.w	#0,(a4)+

	add.l	#Vertex3D_SIZEOF,a1	;advance to next X,Y,Z coordinate

	dbra	d7,.rotateLoop

.beforeDraw
	move.w	(a2),d7
	subi	#1,d7
	lea	TransformedVertexBuffer,a2
	lea	TransformedVertexBuffer,a3

.drawLoop:
	move.w	-4(a6),d0	;X
	move.w	-8(a6),d1	;Y
	move.l	a2,a1	;retrieve the shape ptr

.getV1:
	move.w	vertex_x(a1),d2
	move.w	vertex_y(a1),d3
	add.w	d0,d2	;d2 += d0
	add.w	d1,d3	;d3 += d1

	add.l	#Vertex3D_SIZEOF,a2	;a2 now = next vertex
	move.l	a2,a1			;a2 = current vertex ptr

	cmp	#0,d7	;are we on the last vertex?
	bne	.getV2	;no, continue.

	move.l	a3,a1	;yes, return to the first vertex

.getV2:
	move.w	vertex_x(a1),d4
	move.w	vertex_y(a1),d5
	add.w	d0,d4
	add.w	d1,d5

	DrawLine Bitplane1,d2,d3,d4,d5

	dbra	d7,.drawLoop

	UNLK	a6

	RESTORE_A
	RESTORE_D

	RTS

;;;

_PlotVertex:
	;a0 = bpl to write
	;a1 = pointer to vertex
	;d0 = origin X
	;d1 = origin Y

	add.w	(a1),d0
	add.w	2(a1),d1
	JSR	_SetPixel
	
	RTS

;;;

_SetPixel:
	;a0 = bpl to write
	;d0 = x
	;d1 = y
	mulu.w	#PX_WIDE_BYTES,d1	;d1   = y*pixelwidth
	divu	#8,d0			;d0.h = shift factor
					;d0.l = pixel offset in bytes
	add.w	d0,d1			;d1   = y*pixelwidth + offset
	swap	d0
	add.l	d1,a0			;a0   = bpl + (y*pixelwidth+offset)

	move.b	#%10000000,d1
	lsr.b	d0,d1			;d1   = shifted pixel to set at a0

	or.b	d1,(a0)			;(a0) = old | new
	RTS

;;;

_DrawLine:
	;Adapted (okay, stolen) from the HW examples book
	;a0.l = bpl to write
	;d0.w = x1
	;d1.w = y1
	;d2.w = x2
	;d3.w = y2
	;d4.w = width

	PRESERVE_A
	PRESERVE_D

	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	ext.l	d4

	move.l	#PX_WIDE_BYTES,d4

	lea	CustomBase,a1	; custom address
	sub.w	d0,d2		;calculate dX
	bmi	xneg		;if neg,      octant is in [3,4,5,6]
	sub.w	d1,d3		;calculate dY octant is in [1,2,7,8]
	bmi	yneg		;if neg,      octant is in [7,8]
	cmp.w	d3,d2		;	      octant is in [1,2]
	bmi	ygtx			;if y>x, octant is 2
	moveq.l	#OCTANT1+LINEMODE,d5	;else octant is 1
	bra	lineagain

ygtx:
	exg	d2,d3		;X > Y for proper operation
	moveq.l	#OCTANT2+LINEMODE,d5	;octant is 2
	bra	lineagain

yneg:
	neg.w	d3		;abs(dY)
	cmp.w	d3,d2		;octant is in [7,8]
	bmi	ynygtx			;if y>x, octant is 7
	moveq.l	#OCTANT8+LINEMODE,d5	;else octant is 8
	bra	lineagain

ynygtx:
	exg	d2,d3		;X > Y for proper operation
	moveq.l	#OCTANT7+LINEMODE,d5	;octant is 7
	bra	lineagain

xneg:
	neg.w	d2		;octant is in [3,4,5,6]
	sub.w	d1,d3		;calculate dY
	bmi	xyneg		;if neg, octant is in [5,6]
	cmp.w	d3,d2		;else octant is in [3,4]
	bmi	xnygtx			;if y>x, octant is 3
	moveq.l	#OCTANT4+LINEMODE,d5	;else octant is 4
	bra	lineagain

xnygtx:
	exg	d2,d3		;ensure X > Y
	moveq.l	#OCTANT3+LINEMODE,d5	;octant is 3
	bra	lineagain

xyneg:
	neg.w	d3		;octant is in [5,6]
	cmp.w	d3,d2		;y > x?
	bmi	xynygtx			;octant is 6
	moveq.l	#OCTANT5+LINEMODE,d5	;else octant is 5
	bra	lineagain		

xynygtx:
	exg	d2,d3		;ensure X > Y
	moveq.l	#OCTANT6+LINEMODE,d5	;octant is 6

lineagain:
	mulu.w	d4,d1		;calculate y1*width
	ror.l	#4,d0		;move upper 4 bits into hi word
	add.w	d0,d0		;multiply by 2
	add.l	d1,a0		;ptr += (x1 >> 3)
	add.w	d0,a0		;ptr += y1*width
	swap	d0		;get the 4 bits of x1
	or.w	#$0BFA,d0	;OR with USEA|USEC|USED. F=A+C
	lsl.w	#2,d3		;Y = 4*Y
	add.w	d2,d2		;X = 2*X
	move.w	d2,d1		;set up the size word
	lsl.w	#5,d1		;shift five left
	add.w	#$42,d1		;add 1 to height, 2 to width

	jsr	WaitBlit

setBLT:
	move.w	d3,bltbmod(a1)	;B mod = 4*Y
	sub.w	d2,d3
	ext.l	d3
	move.l	d3,bltapt(a1)	;A ptr = 4*Y - 2*X
	bpl	lineover
	or.w	#SIGNFLAG,d5	;set sign bit if negative

lineover:
	move.w	d0,bltcon0(a1)	;write the control registers
	move.w	d5,bltcon1(a1)
	move.w	d4,bltcmod(a1)
	move.w	d4,bltdmod(a1)
	sub.w	d2,d3
	move.w	d3,bltamod(a1)	;A mod = 4*Y - 4*X
	move.w	#$8000,bltadat(a1)
	moveq.l	#-1,d5
	move.l	d5,bltafwm(a1)	;hit both masks at once
	move.l	a0,bltcpt(a1)
	move.l	a0,bltdpt(a1)
	move.w	d1,bltsize(a1)

	RESTORE_D
	RESTORE_A
	
	RTS


;;;

_RotatePoint:
	;Rotate a point (d0.w,d1.w) around (0,0) by d2.w degrees.
	;Returns new coordinates in (d0,d1).
	PRESERVE_A
	PRESERVE_D

	ext.l	d0
	ext.l	d1
	ext.l	d2

	LINK	a6,#-24

	move.l	mathieeesingbas_base,a4
	move.l	mathieeesingtrans_base,a5
	move.l	d0,-4(a6)
	move.l	d1,-8(a6)

	jsr	IEEESPFlt(a4)
	move.l	d0,-4(a6)

	move.l	-8(a6),d0
	jsr	IEEESPFlt(a4)
	move.l	d0,-8(a6)

	;formula: x' =  x*cos(theta) - y*sin(theta)
	;	  y' =  y*cos(theta) + x*sin(theta)

.calcSinCos
	move.w	d2,d0
	JSR	DegreesToRadians

	move.l	d0,-12(a6)	;12(a6) = theta
	JSR	IEEESPSin(a5)
	move.l	d0,-16(a6)	;16(a6) = sin(theta)

	move.l	-12(a6),d0
	JSR	IEEESPCos(a5)
	move.l	d0,-20(a6)	;20(a6) = cos(theta)

.calcXPrime
	move.l	-20(a6),d1
	move.l	-4(a6),d0
	jsr	IEEESPMul(a4)
	move.l	d0,d6		;d6 = x*cos(theta)

	move.l	-16(a6),d1
	move.l	-8(a6),d0
	jsr	IEEESPMul(a4)	;d0 = y*sin(theta)
	move.l	d6,d1
	jsr	IEEESPSub(a4)	;d0 = x*cos(theta) - y*sin(theta)
	move.l	d0,d5
	
.calcYPrime
	move.l	-8(a6),d0	;d0 = y
	move.l	-20(a6),d1	;d1 = cos(theta)
	jsr	IEEESPMul(a4)	;d0 = y*cos(theta)
	move.l	d0,d6

	move.l	-4(a6),d0	;d0 = x
	move.l	-16(a6),d1	;d1 = sin(theta)
	jsr	IEEESPMul(a4)	;d0 = x*sin(theta)
	move.l	d6,d1
	jsr	IEEESPAdd(a4)	;d0 = y*cos(theta) + x*sin(theta)

.backToInteger
	jsr	IEEESPFix(a4)	;d0 = INT(y)
	move.l	d0,d1

	move.l	d5,d0
	jsr	IEEESPFix(a4)	;d0 = INT(x)

	UNLK	a6

	RESTORE_D
	RESTORE_A
	
	RTS

;;;;;;;

