����                                        PUSHL	MACRO
	MOVE.L	\1,-(SP)
	ENDM

POPL	MACRO
	MOVE.L	(SP)+,\1
	ENDM

PRESERVE_A 	MACRO
 	MOVEM.L	a2-a6,-(sp)
		ENDM

RESTORE_A	MACRO
	MOVEM.L	(sp)+,a2-a6
		ENDM

PRESERVE_D	MACRO
	MOVEM.L	d2-d7,-(sp)
		ENDM

RESTORE_D	MACRO
	MOVEM.L	(sp)+,d2-d7
		ENDM

FUNCDEF	MACRO
_LVO\1		EQU	FUNC_CNT
FUNC_CNT	SET	FUNC_CNT-6
	ENDM
FUNC_CNT	SET	5*-6

