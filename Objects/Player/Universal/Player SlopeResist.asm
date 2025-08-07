; ---------------------------------------------------------------------------
; Subroutine to	slow Player walking up a	slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	@ret
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	@ret
		bmi.s	@cont
		tst.w	d0
		beq.s	@ret
	@cont:
		add.w	d0,obInertia(a0)
	@ret:
		rts
; End of function Player_SlopeResist