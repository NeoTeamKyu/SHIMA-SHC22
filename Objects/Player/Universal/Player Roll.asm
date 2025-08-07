; ---------------------------------------------------------------------------
; Subroutine allowing Player to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


; TODO: Make NoSpin characters less hacky and weird. See also: Player Move.asm, Player Jump.asm
Player_Roll:
		tst.b		(f_jumponly).w	; This check doesn't work on its own for some reason,
		bne.s		@noroll			; so I'm just going to throw another after it.
		cmpi.b		#id_WaterSlide,obAnim(a0)
		beq.s		@noroll
		cmpi.b		#charID_Kyuko,(v_character).w
		beq.s		@noSpin
		cmpi.b		#charID_Amy,(v_character).w
		beq.s		@noSpin
		bra.s		@charCanSpin
	@noSpin:
		btst		#bitDn,(v_jpadhold2).w	; is down being pressed?
		bne.w		Duck_Movement			; if not, branch
		bra.s		@noroll
	@charCanSpin:
		btst		#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s		@noroll			; if not, branch
		move.b		(v_jpadhold2).w,d0
		andi.b		#btnL+btnR,d0	; is left/right being pressed?
		bne.s		@noroll		; if yes, branch
	@cont:
		move.w		obInertia(a0),d0
		bpl.s		@ispositive
		neg.w		d0
@ispositive:
		cmpi.w		#$100,d0	; is Player moving at $100 speed or faster?
		bhi.s		Player_ChkRoll	; if yes, branch
		move.b		#id_Duck,obAnim(a0)	; use "ducking" animation

	@noroll:
		rts
; ===========================================================================

Player_ChkRoll:
		btst	#2,obStatus(a0)	; is Player already rolling?
		beq.s	@roll		; if not, branch
		rts
; ===========================================================================

@roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		addq.w	#5,obY(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@tallboi
		subq.w	#4,obY(a0)
	@tallboi:
		sfx	sfx_Roll	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	@ismoving
		move.w	#$200,obInertia(a0) ; set inertia if 0

	@ismoving:
		rts
; End of function Player_Roll