WallJump:
		cmpi.b	#charID_Mighty,(v_character).w
		bne.w	@return
		cmpi.b	#$22,anim(a0) ; Check for Hammer Drop since it doesn't make sense for him to be able to grab a wall whilst slamming at a high speed (Note: change $22 with an actual id)
		beq.w	@return
		cmpi.b	#2,obDoubleJump(a0)	; Mercury Constants
		beq.w	@return
		cmpi.b	#3,obDoubleJump(a0)	; Mercury Constants
		beq.w	@return
		cmpi.b	#4,obDoubleJump(a0)
		beq.s	@Skip_JumpCheckWJ
		tst.b	jumping(a0)	; Mercury Constants
		beq.s	@return
	@Skip_JumpCheckWJ:
		tst.b	obVelY(a0)
		bmi.s	@return
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0
		beq.s	@return			; fail if A, B or C aren't pressed
		move.w	#0,obVelY(a0)
		move.b	#3,obDoubleJump(a0)
		move.b	#$30,obDoubleJump_property(a0)	; Mercury Constants
		move.b	#id_MariJump1,obAnim(a0)	; Wall Jump animation
		sfx	sfx_Grab

	@return:
		rts

Mighty_DoWallJump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.s	@skip
		move.b	#4,obDoubleJump(a0)	; Mercury Constants
		move.b	#1,jumping(a0)
		move.b	#id_Roll,obAnim(a0)
		move.w	#-$600,d0
		btst	#bitUp,(v_jpadhold2).w
		bne.s	@uponly
		btst	#bitDn,(v_jpadhold2).w
		bne.w	Mighty_HammerDrop_continue
		move.w	#-$580,d0
		move.w	#-$400,obVelX(a0)
		btst	#0,obStatus(a0)
		beq.s	@uponly
		neg.w	obVelX(a0)

	@uponly:
		btst	#6,obStatus(a0)
		beq.s	@nowtr
		addi.w	#$280,d0

	@nowtr:
		move.w	d0,obVelY(a0)
		sfx	sfx_Jump

	@skip:
		rts