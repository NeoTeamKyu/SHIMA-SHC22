; ------------------------------------------------------------
; Obj24: Fire Shield Dissipate Object - Ported from S3K by DeltaWooloo
; ------------------------------------------------------------

FireShield_Dissipate:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	FireShield_Dissipate_Index(pc,d0.w),d1
		jmp		FireShield_Dissipate_Index(pc,d1.w)

; ===========================================================================
FireShield_Dissipate_Index:
		dc.w	FireShield_Dissipate_Init-FireShield_Dissipate_Index
		dc.w	FireShield_Dissipate_Main-FireShield_Dissipate_Index
; ===========================================================================
FireShield_Dissipate_Init:
		move.l	#Map_ExplodeItem,obMap(a0)
		move.w	#vramExplode,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$280,obPriority(a0)
		move.b	#$C,obActWid(a0)
		move.b	#3,obTimeFrame(a0)
		move.b	#1,obFrame(a0)
		addq.b	#2,obRoutine(a0)

FireShield_Dissipate_Main:
		jsr		(SpeedToPos).l
		subq.b	#1,obTimeFrame(a0)
		bpl.s	@display
		move.b	#3,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#5,obFrame(a0)
		beq.w	FS_JumpTo_DeleteObject

@display:
		jmp		(DisplaySprite).l

FS_JumpTo_DeleteObject:
		jmp		(DeleteObject).l
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Object 27 - explosion	from a destroyed enemy or monitor
; ---------------------------------------------------------------------------

ExplosionItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ExItem_Index(pc,d0.w),d1
		jmp	ExItem_Index(pc,d1.w)
; ===========================================================================
ExItem_Index:	dc.w ExItem_Animal-ExItem_Index
		dc.w ExItem_Main-ExItem_Index
		dc.w ExItem_Animate-ExItem_Index
; ===========================================================================

ExItem_Animal:	; Routine 0
		addq.b	#2,obRoutine(a0)
		bsr.w	FindFreeObj
		bne.s	ExItem_Main
		move.b	#id_Animals,0(a1) ; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	$3E(a0),$3E(a1)

ExItem_Main:	; Routine 2
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeItem,obMap(a0)
		move.w	#vramExplode,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0) ; set frame duration to 7 frames
		move.b	#0,obFrame(a0)
		sfx	sfx_Break	; play breaking enemy sound

ExItem_Animate:	; Routine 4 (2 for ExplosionBomb)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@display
		move.b	#7,obTimeFrame(a0) ; set frame duration to 7 frames
		addq.b	#1,obFrame(a0)	; next frame
		cmpi.b	#5,obFrame(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

	@display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3F - explosion	from a destroyed boss, bomb or cannonball
; ---------------------------------------------------------------------------

ExplosionBomb:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ExBom_Index(pc,d0.w),d1
		jmp	ExBom_Index(pc,d1.w)
; ===========================================================================
ExBom_Index:	dc.w ExBom_Main-ExBom_Index
				dc.w ExItem_Animate-ExBom_Index
				dc.w ExLant_Main-ExBom_Index
; ===========================================================================

ExBom_Main:	; Routine 0
		bset	#0,$2B(a0)
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeBomb,obMap(a0)
		move.w	#vramExplode,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		sfx	sfx_Explode	; play exploding bomb sound
		rts

ExLant_Main:	; Routine 4, jumps back to 2
		bset	#0,$2B(a0)
		move.b	#2,obRoutine(a0)
		move.l	#Map_ExplodeLant,obMap(a0)
		move.w	#vramExpLanBGZ,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#0,obColType(a0)
		move.b	#$C,obActWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#0,obFrame(a0)
		sfx	sfx_Explode	; play exploding bomb sound
		rts
