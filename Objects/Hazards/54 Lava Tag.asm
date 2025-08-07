; ---------------------------------------------------------------------------
; Object 54 - invisible	lava tag (MZ)
; ---------------------------------------------------------------------------

LavaTag:
		cmpi.b	#2,obSubtype(a0)	;TIS
		bgt	WaterTag	;TIS
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LTag_Index(pc,d0.w),d1
		jmp	LTag_Index(pc,d1.w)
; ===========================================================================
LTag_Index:	dc.w LTag_Main-LTag_Index
		dc.w LTag_ChkDel-LTag_Index

LTag_ColTypes:	dc.b $96, $94, $95
		even
; ===========================================================================

LTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)
		;bset	#1,obShieldDeflect(a0)
		move.l	#Map_LTag,obMap(a0)
		move.b	#$84,obRender(a0)

LTag_ChkDel:	; Routine 2
		out_of_range_resp	DeleteObject
		rts

; ---------------------------------------------------------------------------
; Object 54a - invisible	water tag (MZ) - TIS
; ---------------------------------------------------------------------------

WaterTag:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	WTag_Index(pc,d0.w),d1
		jmp	WTag_Index(pc,d1.w)
; ===========================================================================
WTag_Index:	dc.w WTag_Main-WTag_Index
		dc.w WTag_ChkDel-WTag_Index

WTag_ColTypes:	dc.b $96, $94, $95
		even
; ===========================================================================


WTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		;move.b	obSubtype(a0),d0
		;sub.b	#$F0,d0
		move.b	$96,obColType(a0)
		move.l	#Map_LTag,obMap(a0)
		;move.b	#$84,obRender(a0)

WTag_ChkDel:	; Routine 2
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	DeleteObject
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts