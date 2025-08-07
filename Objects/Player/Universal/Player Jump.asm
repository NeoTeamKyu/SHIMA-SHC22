; ---------------------------------------------------------------------------
; Subroutine allowing Player to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	locret_1348E	; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		jsr		sub_14D48
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2
		tst.b	(v_super).w
		beq.s	@notsuper
		move.w	#$800,d2	; set higher jump speed if super
	@notsuper:
		btst	#6,obStatus(a0)	; Test if underwater
		beq.s	@notunderwater
		move.w	#$380,d2	; set lower jump speed if under
	@notunderwater:
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	loc_1341C
		sub.w	#$80,d2

loc_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)	; make Player jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)	; make Player jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		clr.w	$3E(a0)	;clear horiz control lock
		cmpi.b  #charID_Metal,(v_character).w
		bne.s   @normalsnd
		sfx	sfx_CDJump
		bra.s   @jscnt
    @normalsnd:
		sfx	sfx_Jump		; play jumping sound
    @jscnt:
		jsr	(ResetHeight).l
		btst	#2,obStatus(a0)
		bne.s	Player_RollJump
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		cmpi.b	#charID_Kyuko,(v_character).w
		bne.s	@rollAnim
		move.b	#id_Spring,obAnim(a0)
		bra.s	@animDone
	@rollAnim:
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
	@animDone:
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	locret_1348E
		subq.w	#4,obY(a0)	; Mimics Tails's thing because he's fucking short and dumb

locret_1348E:
		rts
; ===========================================================================

Player_RollJump:
		bset	#4,obStatus(a0)
		rts
; End of function Player_Jump
