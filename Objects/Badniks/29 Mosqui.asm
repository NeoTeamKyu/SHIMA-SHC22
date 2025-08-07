; ---------------------------------------------------------------------------
; Object 29 - Mosqui enemy from Palmtree Panic Zone, now in Blossom Gardens
; ---------------------------------------------------------------------------

obStartX:	equ $2C
obEndX:		equ $2E
obAniFile:	equ	$30

Mosqui:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mosqui_Index(pc,d0.w),d1 ; used to be (pc,d0.w),d0
		jsr	Mosqui_Index(pc,d1.w) ; used to be (pc,d0.w)
		jsr	DisplaySprite
		jmp	RememberState
; ===========================================================================
Mosqui_Index:
		dc.w	Mosqui_Init-Mosqui_Index
		dc.w	Mosqui_Main-Mosqui_Index
		dc.w	Mosqui_Animate-Mosqui_Index
		dc.w	Mosqui_Dive-Mosqui_Index
		dc.w	Mosqui_Wait-Mosqui_Index
; ===========================================================================

Mosqui_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Mosqui,obMap(a0)
		move.l	#Ani_Mosqui,obAniFile(a0)
		move.w	#vramMosquiBGZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$10,obWidth(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$C,obColType(a0)
		move.w	obX(a0),obStartX(a0)
		moveq	#0,d0
		move.l	#-$10000,d0
		move.l	d0,obEndX(a0)

; End of function Mosqui_Init
; ===========================================================================

Mosqui_Main:
		tst.w	(v_debuguse).l
		bne.s	@SkipRange
		lea	(v_player).w,a1
		bsr.s	Mosqui_CheckInRange
		bcs.s	@StartDive

	@SkipRange:
		move.l	obEndX(a0),d0
		add.l	d0,obX(a0)
		move.w	obX(a0),d0
		sub.w	obStartX(a0),d0
		bpl.s	@ChkTurn
		neg.w	d0

	@ChkTurn:
		cmpi.w	#$80,d0
		blt.s	@Animate
		neg.l	obEndX(a0)
		bchg	#0,obRender(a0)
		bchg	#0,obStatus(a0)
		bra.s	@SkipRange

; -------------------------------------------------------------------------------

	@Animate:
		movea.l	obAniFile(a0),a1
		jmp	AnimateSprite

; -------------------------------------------------------------------------------

	@StartDive:
		addq.b	#2,obRoutine(a0)
		move.b	#1,obAnim(a0)
		rts
; End of function Mosqui_Main
; ===========================================================================

Mosqui_CheckInRange:
		move.w	obY(a1),d0
		sub.w	obY(a0),d0
		subi.w	#-$30,d0
		subi.w	#$70,d0
		bcc.s	@End
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		move.w	d0,d1
		subi.w	#-$30,d1
		subi.w	#$60,d1

	@End:
		rts
; End of function Mosqui_CheckInRange
; ===========================================================================

Mosqui_Animate:
		movea.l	obAniFile(a0),a1
		jmp	AnimateSprite
; End of function Mosqui_Animate
; ===========================================================================

Mosqui_Dive:
		addq.w	#6,obY(a0)
		bsr.w	Mosqui_Falling
		jsr	ObjFloorDist	; CheckFloorEdge in CD
		cmpi.w	#-8,d1
		bgt.s	Mosqui_DiveEnd
		subi.w	#-8,d1
Mosqui_Check_Top_Solids:
		add.w	d1,obY(a0)
		addq.b	#2,obRoutine(a0)
		tst.b	obRender(a0)
		bpl.s	Mosqui_DiveEnd
		sfx	sfx_ArrowStick	; was sound A7 in CD

Mosqui_DiveEnd:
		rts
; End of function Mosqui_Dive
; ===========================================================================

Mosqui_Wait:
		tst.b	obRender(a0)
		bmi.s	@End
		out_of_range_resp DeleteObject	; was CheckObjDespawnTime_Despawn in CD...
	@End:
		rts

Mosqui_Falling:
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	@End
		bra.w	Mosqui_Check_Top_Solids
	@End:
		rts

; End of function Mosqui_Wait