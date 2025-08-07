; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge
; ---------------------------------------------------------------------------
BridgeChildPointers = $36
Bridge:
		btst	#6,render_flags(a0)	; is this a child sprite object?
		bne.w	@child			; if yes, branch
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bri_Index(pc,d0.w),d1
		jmp	Bri_Index(pc,d1.w)
; ===========================================================================
	@child:	; child sprite objects only need to be drawn
		move.w	#$180,d0
		jmp	(DisplaySprite2).l
; ===========================================================================
Bri_Index:	dc.w Bri_Main-Bri_Index, Bri_Action-Bri_Index
		dc.w Bri_Display-Bri_Index
; ===========================================================================

Bri_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bri,obMap(a0)
		move.w	#$4000+vramDecorMHZ,obGfx(a0)
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@notMHZ
		move.w	#$4000+vramBridgeLBGZ,obGfx(a0)

	@notMHZ:
		move.w	#$180,obPriority(a0)
		move.b	#4,obRender(a0)
		move.b	#$80,obActWid(a0)
		move.w	obY(a0),d2
		move.w	d2,$3C(a0)
		move.w	obX(a0),d3
		lea	obSubtype(a0),a2
		moveq	#0,d1
		move.b	(a2),d1		; copy bridge length to d1
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3	; x position of left half
		swap	d1	; store subtype in high word for later
		move.w	#8,d1
		bsr.s	Obj11_MakeBdgSegment
		move.w	sub6_x_pos(a1),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)		; center of first subsprite object
		move.l	a1,$30(a0)	; pointer to first subsprite object
		swap	d1	; retrieve subtype
		subq.w	#8,d1
		bls.s	@nomore	; branch, if subtype <= 8 (bridge has no more than 8 logs)
		; else, create a second subsprite object for the rest of the bridge
		move.w	d1,d4
		bsr.s	Obj11_MakeBdgSegment
		move.w	a1,BridgeChildPointers(a0)	; pointer to second subsprite object
		move.w	d4,d0
		add.w	d0,d0
		add.w	d4,d0	; d0*3
		move.w	sub2_x_pos(a1,d0.w),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)		; center of second subsprite object
	@nomore:
		bra.s	Bri_Action

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; sub_F728:
Obj11_MakeBdgSegment:
		jsr	(FindNextFreeObj).l
		bne.s	@return	; rts
		move.b	(a0),(a1) ; load obj11
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#6,obRender(a1)
		move.b	#$40,mainspr_width(a1)
		move.b	d1,mainspr_childsprites(a1)
		subq.b	#1,d1
		lea	sub2_x_pos(a1),a2 ; starting address for subsprite data
	@loop:
		move.w	d3,(a2)+	; sub?_x_pos
		move.w	d2,(a2)+	; sub?_y_pos
		move.w	#0,(a2)+	; sub?_mapframe
		addi.w	#$10,d3		; width of a log, x_pos for next log
		dbf	d1,@loop	; repeat for d1 logs
	@return:
		rts
; End of function Obj11_MakeBdgSegment

; ===========================================================================
Bri_Action:	; Routine 2
		move.b	obStatus(a0),d0
		andi.b	#$18,d0
		bne.s	@standing
		tst.b	$3E(a0)
		beq.s	@F7BC
		subq.b	#4,$3E(a0)
		bra.s	@F7B8

	@standing:
		cmpi.b	#$40,$3E(a0)
		beq.s	@F7B8
		addq.b	#4,$3E(a0)

	@F7B8:
		bsr.w	Bri_Bend

	@F7BC:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		moveq	#8,d3
		move.w	obX(a0),d4
		bsr.w	sub_F872

	@display:
		bra.w	Bri_ChkDel


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_F872:
		lea	(v_player).w,a1 ; a1=character
		moveq	#3,d6
		bsr.s	@doplayerstuff
		lea	(v_ball).w,a1 ; a1=character
		moveq	#4,d6

	@doplayerstuff:
		moveq	#$3F,d5
		btst	d6,obStatus(a0)
		beq.s	loc_F8F0
		btst	#1,obStatus(a1)
		bne.s	@flip
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	@flip
		cmp.w	d2,d0
		blo.s	@inX
	@flip:
		bclr	d6,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ===========================================================================
	@inX:
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)
		movea.l	$30(a0),a2
		cmpi.w	#8,d0
		blo.s	@firstsubsprite
		movea.w	BridgeChildPointers(a0),a2 ; a2=object
		subi.w	#8,d0
	@firstsubsprite:
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	sub2_y_pos(a2,d0.w),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		moveq	#0,d4
		rts
; ===========================================================================

loc_F8F0:
		move.w	d1,-(sp)
		bsr.s	PlatformObject11_cont
		move.w	(sp)+,d1
		btst	d6,obStatus(a0)
		beq.s	@return	; rts
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)
	@return:
		rts
; End of function sub_F872
; ===========================================================================
; Used only by EHZ/HPZ log bridges. Very similar to PlatformObject_cont, but
; d2 already has the full width of the log.
;loc_19D9C:
PlatformObject11_cont:
		tst.w	obVelY(a1)
		bmi.w	return_19E8E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	return_19E8E
		cmp.w	d2,d0
		bhs.w	return_19E8E
		bra.w	loc_19DD8
; ===========================================================================

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Bri_Bend:
		move.b	$3E(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea	(Obj11_BendData2).l,a4
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea	(Obj11_BendData).l,a5
		move.b	(a5,d3.w),d5
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		movea.l	$30(a0),a1
		lea	sub9_y_pos+next_subspr(a1),a2
		lea	sub2_y_pos(a1),a1

	@loopafter:
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	@skiploopafter
		movea.w	BridgeChildPointers(a0),a1 ; a1=object
		lea	sub2_y_pos(a1),a1
	@skiploopafter:
		dbf	d2,@loopafter

		moveq	#0,d0
		move.b	obSubtype(a0),d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	@return	; rts
		move.w	d3,d2
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		bcs.s	@return	; rts
	@loopbefore:
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a0),d0
		move.w	d0,(a1)
		addq.w	#6,a1
		cmpa.w	a2,a1
		bne.s	@skiploopbefore
		movea.w	BridgeChildPointers(a0),a1 ; a1=object
		lea	sub2_y_pos(a1),a1
	@skiploopbefore:
		dbf	d2,@loopbefore
	@return:
		rts
; End of function Bri_Bend

; ===========================================================================
; ---------------------------------------------------------------------------
; GHZ bridge-bending data
; (Defines how the bridge bends	when Sonic walks across	it)
; ---------------------------------------------------------------------------
Obj11_BendData:	incbin	"Miscellaneous\bridgebend1.bin"
		even
Obj11_BendData2:incbin	"Miscellaneous\bridgebend2.bin"
		even

; ===========================================================================

Bri_ChkDel:
		out_of_range_resp	@delete1st
		rts
; ---------------------------------------------------------------------------
	@delete1st:		; delete first subsprite object
		movea.l	$30(a0),a1 ; a1=object
		jsr		DeleteChild
		cmpi.b	#8,obSubtype(a0)
		bls.s	@delete2nd	; if bridge has more than 8 logs, delete second subsprite object
		movea.w	BridgeChildPointers(a0),a1 ; a1=object
		jsr		DeleteChild
	@delete2nd:
		jmp		DeleteObject
; ===========================================================================

Bri_Display:	; Routine $A
		jmp		DisplaySprite