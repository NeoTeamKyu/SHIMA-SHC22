; ---------------------------------------------------------------------------
; Subroutine to	change Player's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_JumpDirection:
		btst	#7,obStatus(a0)
		bne.w	locret_132D2
		move.w	(v_plrspeedmax).w,d6
		move.w	(v_plrspeedacc).w,d5
		asl.w	#1,d5
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	@cont	; if not, branch
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	@cont
		add.w	d5,d0		; Speed Cap
		cmp.w	d1,d0		; Speed Cap
		ble.s	@cont	; Speed Cap
		move.w	d1,d0

	@cont:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	Player_JumpMove	; if not, branch
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	Player_JumpMove
		sub.w	d5,d0		; Speed Cap
		cmp.w	d6,d0		; Speed Cap
		bge.s	Player_JumpMove	; Speed Cap
		move.w	d6,d0

Player_JumpMove:
		move.w	d0,obVelX(a0)	; change Player's horizontal speed

Player_Jump_ResetScreen:
		cmpi.w	#$60,(v_lookshift).w ; is the screen in its default position?
		beq.s	Player_JumpPeakDecelerate	; if yes, branch
		bcc.s	@cont
		addq.w	#4,(v_lookshift).w
	@cont:
		subq.w	#2,(v_lookshift).w

Player_JumpPeakDecelerate:
		cmpi.w	#-$400,obVelY(a0) ; is Player moving faster than -$400 upwards?
		bcs.s	locret_132D2	; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2
		bmi.s	Player_JumpPeakDecelerateLeft
		sub.w	d1,d0
		bcc.s	@cont
		move.w	#0,d0

	@cont:
		move.w	d0,obVelX(a0)
		rts	
; ===========================================================================

Player_JumpPeakDecelerateLeft:
		sub.w	d1,d0
		bcs.s	@cont
		move.w	#0,d0

	@cont:
		move.w	d0,obVelX(a0)

locret_132D2:
		rts	
; End of function Player_JumpDirection
