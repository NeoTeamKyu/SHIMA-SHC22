; ---------------------------------------------------------------------------
; Subroutine to	push Player down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_SlopeRepel:
		nop	
		tst.b	stick_to_convex(a0)
		bne.s	@ret
		tst.w	move_lock(a0)
		bne.s	loc_13582
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	@ret
		move.w	obInertia(a0),d0
		bpl.s	@ispositive
		neg.w	d0
	@ispositive:
		cmpi.w	#$280,d0
		bcc.s	@ret
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#$1E,move_lock(a0)

	@ret:
		rts	
; ===========================================================================

loc_13582:
		subq.w	#1,move_lock(a0)
		rts	
; End of function Player_SlopeRepel