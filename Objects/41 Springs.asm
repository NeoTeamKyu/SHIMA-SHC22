; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------
Springs:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Springs_Index(pc,d0.w),d1
		jsr	Springs_Index(pc,d1.w)
		bsr.w	DisplaySprite
		out_of_range_resp	DeleteObject
		rts
; ===========================================================================
Springs_Index:
		dc.w Springs_Init-Springs_Index
		dc.w Springs_Up-Springs_Index
		dc.w Springs_Horizontal-Springs_Index
		dc.w Springs_Down-Springs_Index
		dc.w Springs_DiagonallyUp-Springs_Index
		dc.w Springs_DiagonallyDown-Springs_Index
; ===========================================================================

Springs_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spring,obMap(a0)

loc_E22A:
		move.w	#vramSpringBGZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$200,obPriority(a0)
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		move.w	Springs_Init_Subtypes(pc,d0.w),d0
		jmp	Springs_Init_Subtypes(pc,d0.w)
; ===========================================================================
Springs_Init_Subtypes:
		dc.w Springs_Init_Up-Springs_Init_Subtypes
		dc.w Springs_Init_Horizontal-Springs_Init_Subtypes
		dc.w Springs_Init_Down-Springs_Init_Subtypes
		dc.w Springs_Init_DiagonallyUp-Springs_Init_Subtypes
		dc.w Springs_Init_DiagonallyDown-Springs_Init_Subtypes
; ===========================================================================

Springs_Init_Horizontal:
		move.b	#4,obRoutine(a0)
		move.b	#2,obAnim(a0)
		move.b	#3,obFrame(a0)
		move.b	#8,obActWid(a0)
		bra.s	Springs_Init_Common
; ===========================================================================

Springs_Init_Down:
		move.b	#6,obRoutine(a0)
		move.b	#6,obFrame(a0)
		bset	#1,obStatus(a0)
		bra.s	Springs_Init_Common
; ===========================================================================

Springs_Init_DiagonallyUp:
		move.l	#Map_DiagSprings,obMap(a0)
		move.b	#8,obRoutine(a0)
		move.b	#0,obAnim(a0)
		move.b	#7,obFrame(a0)
		move.w	#vramDSpringBGZ,obGfx(a0)
		bra.s	Springs_Init_Common
; ===========================================================================

Springs_Init_DiagonallyDown:
		move.l	#Map_DiagSprings,obMap(a0)
		move.b	#$A,obRoutine(a0)
		move.b	#0,obAnim(a0)
		move.b	#$A,obFrame(a0)
		move.w	#vramDSpringBGZ,obGfx(a0)
		bset	#1,obStatus(a0)

Springs_Init_Up:
Springs_Init_Common:
;	Checks color of spring.
		move.b	obSubtype(a0),d0
		andi.w	#2,d0
		move.w	Springs_Strengths(pc,d0.w),$30(a0)
		move.w	Springs_AmyStrengths(pc,d0.w),$32(a0)
		btst	#1,d0
		beq.s	@return
		bset	#5,obGfx(a0)	; make dat shit yellow, plz.
	@return:
		rts
; ===========================================================================
Springs_Strengths:
	; Speed applied on player
	dc.w -$1000		; power	of red spring
	dc.w  -$A00		; power	of yellow spring	

Springs_AmyStrengths: 
	; Speed applied when Amy interacts with springs with her Paper Mario-like hammer
	dc.w -$1300		; power	of red spring
	dc.w -$D00		; power	of yellow spring	
; ===========================================================================

Springs_Up:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w   SolidObject ;	loc_F4A8
		btst	#3,obStatus(a0)
		beq.s	loc_E32A
		bsr.s	sub_E34E

loc_E32A:
		movem.l	(sp)+,d1-d4
		lea	(v_ball).w,a1
		moveq	#4,d6
		bsr.w	SolidObject ;loc_F4A8
		cmpi.b  #charID_Amy,(v_character).w
		bne.s	Springs_NoHammerAttack
		lea	(v_player).w,a1
		cmpi.b	#$22,obAnim(a1)
		beq.s	Springs_Hammer
		cmpi.b	#$20,obAnim(a1)
		beq.s	Springs_Hammer
		cmpi.b	#$1F,obAnim(a1)
		bne.s	Springs_NoHammerAttack	; if not, branch
		
Springs_Hammer:
		moveq	#0,d0			; clear d0
		move.w	obX(a0),d0		; load springs's X-pos to d0
		sub.w	(v_player+obX).w,d0	; substract Amy's X-pos from it
		bpl.s	Springs_XPositive		; if answer is positive, branch
		neg.w	d0			; otherwise negate d0 

Springs_XPositive:
		cmpi.w	#35,d0			; is Amy within 35 pixels of the spring (X-axis)?
		bge.s	Springs_NoHammerAttack	; if not, branch 	
		moveq	#0,d0			; clear d0
		move.w	obY(a0),d0		; load springs's Y-pos to d0
		sub.w	(v_player+obY).w,d0	; substract Amy's Y-pos from it	
		bpl.s	Springs_YPositive		; if answer is positive, branch	
		neg.w	d0			; otherwise negate d0 

Springs_YPositive:
		cmpi.w	#35,d0			; is Amy within 35 pixels of the spring (Y-axis)?
		bge.s	Springs_NoHammerAttack	; if not, branch
		bra.s	sub_E34E		; otherwise make spring bouncing 

Springs_NoHammerAttack:			
		btst	#4,obStatus(a0)
		beq.s	loc_E342
		bsr.s	sub_E34E

loc_E342:
		lea	(Ani_Spring).l,a1
		jmp	AnimateSprite
; ===========================================================================

sub_E34E:
		move.w	#$100,obAnim(a0)
		addq.w	#8,obY(a1)
		move.w	$30(a0),obVelY(a1)
		cmpi.b  #charID_Amy,(v_character).w
		bne.s	@skip		
		tst.b	(v_hammerspin).w
		bne.s	@Hammer
		tst.b	obDoubleJump(a0)
		bne.s	@Hammer
		tst.b	(v_hammer).w
		beq.s	@skip
@Hammer:
		move.w	$32(a0),obVelY(a1)	; move Sonic upwards
@skip:		
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		bpl.s	loc_E382
		move.w	#0,obVelX(a1)

loc_E382:
		btst	#0,d0
		beq.s	loc_E3C2
		move.w	#1,obInertia(a1)
		move.b	#1,(v_flipangle).w
		move.b	#id_Walk,obAnim(a1)
		move.b	#0,(v_flipsremaining).w
		move.b	#4,(v_flipspeed).w
		btst	#1,d0
		bne.s	loc_E3B2
		move.b	#1,(v_flipsremaining).w

loc_E3B2:
		btst	#0,obStatus(a1)
		beq.s	loc_E3C2
		neg.b	(v_flipangle).w
		neg.w	obInertia(a1)

loc_E3C2:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E3D8
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w

loc_E3D8:
		cmpi.b	#8,d0
		bne.s	loc_E3EA
		move.b	#$E,(v_top_solid_bit).w
		move.b	#$F,(v_lrb_solid_bit).w

loc_E3EA:
		sfx		sfx_Spring
		rts
; End of function sub_E34E

; ===========================================================================

Springs_Horizontal:
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	obX(a0),d4
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SolidObject;loc_F4A8
		btst	#5,obStatus(a0)
		beq.s	loc_E434
		move.b	obStatus(a0),d1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcs.s	loc_E42C
		eori.b	#1,d1

loc_E42C:
		andi.b	#1,d1
		bne.s	loc_E434
		bsr.s	sub_E474

loc_E434:
		movem.l	(sp)+,d1-d4
		lea	(v_ball).w,a1
		moveq	#4,d6
		bsr.w	SolidObject;loc_F4A8
		btst	#6,obStatus(a0)
		beq.s	loc_E464
		move.b	obStatus(a0),d1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bcs.s	loc_E45C
		eori.b	#1,d1

loc_E45C:
		andi.b	#1,d1
		bne.s	loc_E464
		bsr.s	sub_E474

loc_E464:
		bsr.w	sub_E54C
		lea	(Ani_Spring).l,a1
		jmp	AnimateSprite
; ===========================================================================

sub_E474:
		move.w	#$300,obAnim(a0)
		move.w	$30(a0),obVelX(a1)
		addq.w	#8,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E4A2
		bclr	#0,obStatus(a1)
		subi.w	#$10,obX(a1)
		neg.w	obVelX(a1)

loc_E4A2:
		move.w	#$F,$2E(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#2,obStatus(a1)
		bne.s	loc_E4BC
		move.b	#id_Walk,obAnim(a1)

loc_E4BC:
		move.b	obSubtype(a0),d0
		bpl.s	loc_E4C8
		move.w	#0,obVelY(a1)

loc_E4C8:
		btst	#0,d0
		beq.s	loc_E508
		move.w	#1,obInertia(a1)
		move.b	#1,(v_flipangle).w
		move.b	#id_Walk,obAnim(a1)
		move.b	#1,(v_flipsremaining).w
		move.b	#8,(v_flipspeed).w
		btst	#1,d0
		bne.s	loc_E4F8
		move.b	#3,(v_flipsremaining).w

loc_E4F8:
		btst	#0,obStatus(a1)
		beq.s	loc_E508
		neg.b	(v_flipangle).w
		neg.w	obInertia(a1)

loc_E508:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E51E
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w

loc_E51E:
		cmpi.b	#8,d0
		bne.s	loc_E530
		move.b	#$E,(v_top_solid_bit).w
		move.b	#$F,(v_lrb_solid_bit).w

loc_E530:
		bclr	#5,obStatus(a0)
		bclr	#6,obStatus(a0)
		bclr	#5,obStatus(a1)
		sfx		sfx_Spring
		rts
; End of function sub_E474


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E54C:
		cmpi.b	#3,obAnim(a0)
		beq.w	locret_E604
		move.w	obX(a0),d0
		move.w	d0,d1
		addi.w	#$28,d1	; '('
		btst	#0,obStatus(a0)
		beq.s	loc_E56E
		move.w	d0,d1
		subi.w	#$28,d0	; '('

loc_E56E:
		move.w	obY(a0),d2
		move.w	d2,d3
		subi.w	#$18,d2
		addi.w	#$18,d3
		lea	(v_player).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_E5C2
		move.w	obInertia(a1),d4
		btst	#0,obStatus(a0)
		beq.s	loc_E596
		neg.w	d4

loc_E596:
		tst.w	d4
		bmi.s	loc_E5C2
		move.w	obX(a1),d4
		cmp.w	d0,d4
		blo.w	loc_E5C2
		cmp.w	d1,d4
		bhs.w	loc_E5C2
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blo.w	loc_E5C2
		cmp.w	d3,d4
		bhs.w	loc_E5C2
		move.w	d0,-(sp)
		bsr.w	sub_E474
		move.w	(sp)+,d0

loc_E5C2:
		lea	(v_ball).w,a1
		btst	#1,obStatus(a1)
		bne.s	locret_E604
		move.w	obInertia(a1),d4
		btst	#0,obStatus(a0)
		beq.s	loc_E5DC
		neg.w	d4

loc_E5DC:
		tst.w	d4
		bmi.s	locret_E604
		move.w	obX(a1),d4
		cmp.w	d0,d4
		blo.w	locret_E604
		cmp.w	d1,d4
		bhs.w	locret_E604
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blo.w	locret_E604
		cmp.w	d3,d4
		bhs.w	locret_E604
		bsr.w	sub_E474

locret_E604:
		rts
; End of function sub_E54C

; ===========================================================================

Springs_Down:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SolidObject
		cmpi.w	#-2,d4
		bne.s	loc_E62C
		bsr.s	sub_E64E

loc_E62C:
		movem.l	(sp)+,d1-d4
		lea	(v_ball).w,a1
		moveq	#4,d6
		bsr.w	SolidObject
		cmpi.w	#-2,d4
		bne.s	loc_E642
		bsr.s	sub_E64E

loc_E642:
		lea	(Ani_Spring).l,a1
		jmp	AnimateSprite
; ===========================================================================
  rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E64E:
		move.w	#$100,obAnim(a0)
		subq.w	#8,obY(a1)
		move.w	$30(a0),obVelY(a1)
		neg.w	obVelY(a1)
		move.b	obSubtype(a0),d0
		bpl.s	loc_E66E
		move.w	#0,obVelX(a1)

loc_E66E:
		btst	#0,d0
		beq.s	loc_E6AE
		move.w	#1,obInertia(a1)
		move.b	#1,(v_flipangle).w
		move.b	#id_Walk,obAnim(a1)
		move.b	#0,(v_flipsremaining).w
		move.b	#4,(v_flipspeed).w
		btst	#1,d0
		bne.s	loc_E69E
		move.b	#1,(v_flipsremaining).w

loc_E69E:
		btst	#0,obStatus(a1)
		beq.s	loc_E6AE
		neg.b	(v_flipangle).w
		neg.w	obInertia(a1)

loc_E6AE:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E6C4
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w

loc_E6C4:
		cmpi.b	#8,d0
		bne.s	loc_E6D6
		move.b	#$E,(v_top_solid_bit).w
		move.b	#$F,(v_lrb_solid_bit).w

loc_E6D6:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		sfx		sfx_Spring
		rts
; End of function sub_E64E

; ===========================================================================

Springs_DiagonallyUp:
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	obX(a0),d4
		lea	Spring_SlopeData_DiagUp(pc),a2
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SlopedSolid ;loc_F4FA
		btst	#3,obStatus(a0)
		beq.s	loc_E71A
		bsr.s	sub_E73E

loc_E71A:
		movem.l	(sp)+,d1-d4
		lea	(v_ball).w,a1
		moveq	#4,d6
		bsr.w	SlopedSolid
		btst	#4,obStatus(a0)
		beq.s	loc_E732
		bsr.s	sub_E73E

loc_E732:
		lea	(Ani_Spring).l,a1
		jmp	AnimateSprite
; ===========================================================================
  rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E73E:
		btst	#0,obStatus(a0)
		bne.s	loc_E754
		move.w	obX(a0),d0
		subq.w	#4,d0
		cmp.w	obX(a1),d0
		blo.s	loc_E762
		rts
; ===========================================================================

loc_E754:
		move.w	obX(a0),d0
		addq.w	#4,d0
		cmp.w	obX(a1),d0
		bhs.s	loc_E762
		rts
; ===========================================================================

loc_E762:
		move.w	#$100,obAnim(a0)
		move.w	$30(a0),obVelY(a1)
		move.w	$30(a0),obVelX(a1)
		addq.w	#6,obY(a1)
		addq.w	#6,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E79A
		bclr	#0,obStatus(a1)
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)

loc_E79A:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#id_Spring,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		btst	#0,d0
		beq.s	loc_E7F6
		move.w	#1,obInertia(a1)
		move.b	#1,(v_flipangle).w
		move.b	#id_Walk,obAnim(a1)
		move.b	#1,(v_flipsremaining).w
		move.b	#8,(v_flipspeed).w
		btst	#1,d0
		bne.s	loc_E7E6
		move.b	#3,(v_flipsremaining).w

loc_E7E6:
		btst	#0,obStatus(a1)
		beq.s	loc_E7F6
		neg.b	(v_flipangle).w
		neg.w	obInertia(a1)

loc_E7F6:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E80C
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w

loc_E80C:
		cmpi.b	#8,d0
		bne.s	loc_E81E
		move.b	#$E,(v_top_solid_bit).w
		move.b	#$F,(v_lrb_solid_bit).w

loc_E81E:
		sfx		sfx_Spring
		rts
; End of function sub_E73E

; ===========================================================================

Springs_DiagonallyDown:
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	obX(a0),d4
		lea	Spring_SlopeData_DiagDown(pc),a2
		lea	(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.w	SlopedSolid ;loc_F4FA
		cmpi.w	#-2,d4
		bne.s	loc_E84E
		bsr.s	sub_E870

loc_E84E:
		movem.l	(sp)+,d1-d4
		lea	(v_ball).w,a1
		moveq	#4,d6
		bsr.w	SlopedSolid ;loc_F4FA
		cmpi.w	#-2,d4
		bne.s	loc_E864
		bsr.s	sub_E870

loc_E864:
		lea	(Ani_Spring).l,a1
		jmp	AnimateSprite
; ===========================================================================
  rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_E870:
		move.w	#$100,obAnim(a0)
		move.w	$30(a0),obVelY(a1)
		neg.w	obVelY(a1)
		move.w	$30(a0),obVelX(a1)
		subq.w	#6,obY(a1)
		addq.w	#6,obX(a1)
		bset	#0,obStatus(a1)
		btst	#0,obStatus(a0)
		bne.s	loc_E8AC
		bclr	#0,obStatus(a1)
		subi.w	#$C,obX(a1)
		neg.w	obVelX(a1)

loc_E8AC:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		move.b	obSubtype(a0),d0
		btst	#0,d0
		beq.s	loc_E902
		move.w	#1,obInertia(a1)
		move.b	#1,(v_flipangle).w
		move.b	#id_Walk,obAnim(a1)
		move.b	#1,(v_flipsremaining).w
		move.b	#8,(v_flipspeed).w
		btst	#1,d0
		bne.s	loc_E8F2
		move.b	#3,(v_flipsremaining).w

loc_E8F2:
		btst	#0,obStatus(a1)
		beq.s	loc_E902
		neg.b	(v_flipangle).w
		neg.w	obInertia(a1)

loc_E902:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_E918
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w

loc_E918:
		cmpi.b	#8,d0
		bne.s	loc_E92A
		move.b	#$E,(v_top_solid_bit).w
		move.b	#$F,(v_lrb_solid_bit).w


loc_E92A:
		sfx		sfx_Spring
		rts
; End of function sub_E870

; ===========================================================================
Spring_SlopeData_DiagUp:
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10, $E, $C, $A,  8
	dc.b   6,  4,  2,  0,$FE,$FC,$FC,$FC,$FC,$FC,$FC,$FC; 16
Spring_SlopeData_DiagDown:
	dc.b $F4,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F2,$F4,$F6,$F8
	dc.b $FA,$FC,$FE,  0,  2,  4,  4,  4,  4,  4,  4,  4; 16
; ===========================================================================