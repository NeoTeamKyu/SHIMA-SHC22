; ---------------------------------------------------------------------------
; Object 02 - Floating Lantern
; ---------------------------------------------------------------------------

FloatingLantern:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Lantern_Index(pc,d0.w),d1
		jsr		Lantern_Index(pc,d1.w)
		jmp		RememberState

; ===========================================================================
Lantern_Index:
		dc.w	Lantern_Init-Lantern_Index
		dc.w	Lantern_Main-Lantern_Index
		dc.w	Lantern_Shard-Lantern_Index

; ===========================================================================
Lantern_Init:
		move.l	#Map_BGZLantern,obMap(a0)
		move.w	#vramLantenBGZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#$280,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#-$29,obColType(a0)
		addq.b  #2,obRoutine(a0)

Lantern_Main:
		lea	(v_player).w,a2
		bclr	#0,obColProp(a0)
		bne.s	Lantern_Destroy
		rts

; ===========================================================================

Lantern_Destroy:
		jsr	FindFreeObj
		bne.s	@fail
		move.b	#id_ExplosionBomb,obID(a1) ; load explosion object
		move.b	#4,obRoutine(a1)	; Lantern explosion
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	@fail:
		move.w	#-$700,obVelY(a2)
		bset	#1,obStatus(a2)
		bclr	#4,obStatus(a2)
		bclr	#5,obStatus(a2)
		clr.b	obJumping(a2)
		move.b	#1,obFrame(a0)
		lea	(Lantern_FragSpd).l,a4
		moveq	#8,d1		; load 9 fragments
		move.b	#sfx_Balloon,d6
		jsr		SmashObject

Lantern_Shard:
		addq.l	#4,sp			  
		jsr		SpeedToPos
		move.w	#8,d0
		tst.w	obVelX(a0)
		bpl.s	@posvelx
		neg.w	d0
	@posvelx:
		sub.w	d0,obVelX(a0)
		move.w	obsmashGrav(a0),d0
		add.w	d0,obVelY(a0)
		tst.b	obRender(a0)
		bpl.s	Lantern_Delete
		jmp		DisplaySprite	

Lantern_Delete:
		jmp		DeleteObject

; ===========================================================================


Lantern_FragSpd:
		; x velocity, y velocity, gravity
		dc.w	-$200, -$200, $70	; top left
		dc.w	$200, -$200, $70	; top right
		dc.w	-$200, -$100, $38	; middle top left
		dc.w	$200, -$100, $38	; middle top right
		dc.w	-$200, $100, $38	; middle bottom left
		dc.w	$200, $100, $38		; middle bottom right
		dc.w	-$200, $200, $70	; bottom left
		dc.w	$200, $200, $70		; bottom right
		dc.w	0, $200, $20		; strings