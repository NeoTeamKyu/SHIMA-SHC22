; ---------------------------------------------------------------------------
; Subroutine to	change Player's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_RollSpeed:
		move.w	(v_plrspeedmax).w,d6
		asl.w	#1,d6
		moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
		move.w	(v_plrspeeddec).w,d4	; It was either this or outright
		asr.w	#2,d4	; moving $20 to d4. This seems more versatile.
		tst.b	(f_jumponly).w
		bne.w	Player_Roll_ResetScreen
		tst.w	move_lock(a0)
		bne.s	@notright
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	@notleft	; if not, branch
		bsr.w	Player_RollLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	@notright	; if not, branch
		bsr.w	Player_RollRight

	@notright:
		move.w	obInertia(a0),d0
		beq.s	Player_CheckRollStop
		bmi.s	Player_ApplyRollSpeedLeft
		sub.w	d5,d0
		bcc.s	@cont
		move.w	#0,d0
	@cont:
		move.w	d0,obInertia(a0)
		bra.s	Player_CheckRollStop
; ===========================================================================

Player_ApplyRollSpeedLeft:
		add.w	d5,d0
		bcc.s	@cont
		move.w	#0,d0
	@cont:
		move.w	d0,obInertia(a0)

Player_CheckRollStop:
		tst.w	obInertia(a0)	; is Player moving?
		bne.s	Player_Roll_ResetScreen	; if yes, branch
		tst.b	obPinball(a0)
		bne.s	Player_KeepRolling
		bclr	#2,obStatus(a0)
		jsr		ResetHeight
		subq.w	#5,obY(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@tallbois
		addq.w	#4,obY(a0)
	@tallbois:
		bra.s	Player_Roll_ResetScreen
; ---------------------------------------------------------------------------
; magically gives Player an extra push if he's going to stop rolling where it's not allowed
; (such	as in an S-curve in BGZ or a stopper chamber in ??? if we even have them)

Player_KeepRolling:
		move.w	#$400,obInertia(a0)
		btst	#0,obStatus(a0)
		beq.s	Player_Roll_ResetScreen
		neg.w	obInertia(a0)

Player_Roll_ResetScreen:
		cmp.w	#$60,(v_lookshift).w
		beq.s	@setrollspeed
		bcc.s	@cont
		addq.w	#4,(v_lookshift).w
	@cont:
		subq.w	#2,(v_lookshift).w

	@setrollspeed:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	@cont2
		move.w	#$1000,d1
	@cont2:
		cmpi.w	#-$1000,d1
		bge.s	@cont3
		move.w	#-$1000,d1
	@cont3:
		move.w	d1,obVelX(a0)
		jmp		Player_CheckWallsOnGround
; End of function Player_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	@cont
		bpl.s	Player_BrakeRollingRight
	@cont:
		bset	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

Player_BrakeRollingRight:
		sub.w	d4,d0
		bcc.s	@cont
		move.w	#0,d0
	@cont:
		move.w	d0,obInertia(a0)
		rts
; End of function Player_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	Player_BrakeRollingLeft
		bclr	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

Player_BrakeRollingLeft:
		add.w	d4,d0
		bcc.s	@cont
		move.w	#0,d0
	@cont:
		move.w	d0,obInertia(a0)
		rts
; End of function Player_RollRight
