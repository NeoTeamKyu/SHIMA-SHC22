; ---------------------------------------------------------------------------
; Mighty's Drop Dash (original by DeltaWooloo), Revised by AngelKOR64
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
Mighty_HammerDropAndSuper:
		cmpi.b	#4,obDoubleJump(a0)
		beq.s	@skip
		cmpi.b	#3,obDoubleJump(a0)
		beq.w	Mighty_DoWallJump
		tst.b	obDoubleJump(a0)		; is Mighty currently performing a double jump?
		bne.w	HammerDrop_return			; if yes, branch
	@skip:
		move.b	(v_jpadpress2).w,d0		; Is a jump button pressed?
		andi.b	#btnABC,d0
		beq.w	HammerDrop_return			; if not, branch
;		bclr	#4,obStatus(a0) ; not necessary but keeping it here just in case
		tst.b	(v_super).w	; check Super-state
		beq.s	Mighty_SuperChk		; if not in a super-state, branch
		bra.w	Mighty_HammerDrop

Mighty_SuperChk:
		tst.b	(f_timecount).w
		beq.w	Mighty_HammerDrop
		tst.b	(v_super).w
		bne.w	Mighty_HammerDrop
		cmpi.b	#6,(v_emeralds).w
		bne.w	Mighty_HammerDrop
		cmpi.w	#50,(v_rings).w
		blo.w	Mighty_HammerDrop
		bra.w	SuperPlayer_Cont

Mighty_HammerDrop:
		move.b	(v_jpadhold2).w,d0		; Is the down button held?
		andi.b	#btnDn,d0
		beq.w	HammerDrop_return	
Mighty_HammerDrop_continue:
		move.b	#1,obDoubleJump(a0)
		move.b	#$22,anim(a0) ; Hammer Drop's Animation (Note: Replace $22 with the id, since I can't seem to find it)
		move.w	#0,x_vel(a0)		; halt horizontal speed...
		move.w	#0,obinertia(a0)	; ...both ground and air		
		move.w	#$A00,y_vel(a0)			; force Mighty down (It's actually faster than a Bubble Bounce)
		move.b	#id_Trail,(v_trails).w ; load Obj7E (super Player stars object) at $FFFFD040
		move.w	a0,(v_trails+parent).w
		sfx	sfx_Dash					; Play Sound

HammerDrop_return:
		rts
		
		
; =============== S U B R O U T I N E =======================================

HammerDrop_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$280,d2
		btst	#6,obStatus(a0)
		beq.s	@notUnderwater
		subi.w	#$140,d2

	@notUnderwater:
		moveq	#0,d0
		move.b	$26(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,x_vel(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,y_vel(a0)
		tst.b	y_vel(a0)
		bmi.s	@noAdd
		move.w	#-$200,y_vel(a0)
	@noAdd:
		movem.l	(sp)+,d1-d2
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		clr.b	ob2ndRout(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_roll,obAnim(a0)
		bset	#2,obStatus(a0)
		move.b	obHeight(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		sub.w	d0,y_pos(a0)
;		lea	(DustVelocities).l,a2
;		move.b	#$15,(v_dust+mapping_frame).w
;		bsr.w	HammerDrop_Create_Dust
;		bsr.s	HammerDropTouchResponse
		move.w	#$10,(v_Ground_Y_screen_shake).w
		sfx	sfx_Dash ; play dash sound
		rts