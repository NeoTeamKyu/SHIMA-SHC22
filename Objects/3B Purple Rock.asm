; ---------------------------------------------------------------------------
; Object 3B - statues in BGZ and rock in LBGZ
; ---------------------------------------------------------------------------

PurpleRock:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Rock_Index(pc,d0.w),d1
		jmp	Rock_Index(pc,d1.w)
; ===========================================================================
Rock_Index:	dc.w Rock_Main-Rock_Index
		dc.w Rock_Solid-Rock_Index
; ===========================================================================

Rock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_BGZStatues,obMap(a0)
		move.w	#vramStatueBGZ,obGfx(a0)
		cmpi.b	#3,(v_act).w
		bne.s	@notlegacy
		move.l	#Map_LRock,obMap(a0)
		move.w	#$4000+vramRockLBGZ,obGfx(a0)
		move.b	#27,obWidth(a0)
		move.b	#16,obHeight(a0)
		bra.s	@cont
		
	@notlegacy:
		move.b	obSubtype(a0),d0 ; copy object subtype to d0
		move.b	d0,obFrame(a0)
		mulu.w	#2,d0		; multiply by 2... wait, can I change this into an asr?
		lea	Statue_Values(pc,d0.w),a2
		move.b	(a2)+,obWidth(a0)
		move.b	(a2)+,obHeight(a0)
	@cont:
		move.b	#%00010100,obRender(a0)
		move.b	#19,obActWid(a0)
		move.w	#$200,obPriority(a0)

Rock_Solid:	; Routine 2
	; This is so stupid. Clearing these as words then moving the bytes to them *works*. God dammit.
		clr.w	d1
		clr.w	d2
		clr.w	d3
		move.b	obWidth(a0),d1	; Width
		move.b	obHeight(a0),d2	; Height / 2 (jumping)
		move.b	obHeight(a0),d3 ; Height / 2 (walking)
		move.w	obX(a0),d4
		bsr.w	SolidObject
		bsr.w	DisplaySprite
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bls.s	Obj3B_NoDel
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.w	DeleteObject		; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject	; and delete object

Obj3B_NoDel:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Variables for	the statues are stored in an array
; ---------------------------------------------------------------------------
Statue_Values:
	;			W,	H	; Both are /2.
		dc.b	27, 16	; No character. I refuse to make this the proper height, because then it'll be a bitch to place in SonLVL.
		dc.b	27, 32	; Ristar
		dc.b	27, 26	; Komainu