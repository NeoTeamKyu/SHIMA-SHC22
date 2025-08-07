; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateSprite:
		moveq	#0,d0
		move.b	obAnim(a0),d0	; move animation number	to d0
		cmp.b	obNextAni(a0),d0 ; is animation set to restart?
		beq.s	@run	; if not, branch
		move.b	d0,obNextAni(a0) ; set to "no restart"
		move.b	#0,obAniFrame(a0) ; reset animation
		move.b	#0,obTimeFrame(a0) ; reset frame duration

@run:	; @do
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration	; these are in a different
		bpl.s	@wait	; if time remains, branch ; spot in Sonic_Animate
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),obTimeFrame(a0) ; load frame duration
		moveq	#0,d1
		move.b	obAniFrame(a0),d1 ; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		cmp.b	#$FA,d0
		bhs.s	@end_FF	; if animation is complete, branch

@next:
		cmpi.b	#id_SpindashDust,(a0)
		beq.s	@fuckyourflipping
		move.b	d0,d1
		andi.b	#$1F,d0
	@fuckyourflipping:
		move.b	d0,obFrame(a0)	; load sprite number
		move.b	obStatus(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		addq.b	#1,obAniFrame(a0) ; next frame number

@wait:	; @delay
		rts	
; ===========================================================================

@end_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	@end_FE	; if not, branch
		move.b	#0,obAniFrame(a0) ; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	@end_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0) ; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	@end_FC	; if not, branch
		move.b	2(a1,d1.w),obAnim(a0) ; read next byte, run that animation

@end_FC:
		addq.b	#1,d0		; is the end flag = $FC	?
		bne.s	@end_FB	; if not, branch
		addq.b	#2,obRoutine(a0) ; jump to next routine

@end_FB:
		addq.b	#1,d0		; is the end flag = $FB	?
		bne.s	@end_FA	; if not, branch
		move.b	#0,obAniFrame(a0) ; reset animation
		clr.b	ob2ndRout(a0)	; reset	2nd routine counter

@end_FA:
		addq.b	#1,d0		; is the end flag = $FA	?
		bne.s	@end	; if not, branch
		addq.b	#2,ob2ndRout(a0) ; jump to next routine

@end:
		rts	
; End of function AnimateSprite
