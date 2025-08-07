; ---------------------------------------------------------------------------
; Sonic	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadSonicMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
		tst.b	(v_super).w
		bne.s	@superplc
		lea	(DPLC_Sonic).l,a2
		bra.s	@cont
	@superplc:
		lea	(DPLC_SuperSonic).l,a2
	@cont:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		tst.b	(v_super).w
		bne.s	@superart
		move.l	#Art_Sonic,d6
		bra.s	@readentry
	@superart:
		move.l	#Art_SuperSonic,d6

    @readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries

    @nochange:
		rts	
; End of function Sonic_LoadGfx

LoadSonicMap:
		tst.b	(v_super).w
		bne.s	@super
	@normal:
		cmpi.l	#Map_Sonic,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Sonic,(v_player+obMap).w
		bra.s	@skip
	@super:
		cmpi.l	#Map_SuperSonic,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_SuperSonic,(v_player+obMap).w
	@skip:
		rts