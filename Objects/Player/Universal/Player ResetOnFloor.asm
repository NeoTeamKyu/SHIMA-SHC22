; ---------------------------------------------------------------------------
; Subroutine to	reset Player's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_ResetOnFloor:
		tst.b	(v_SpringShoes).w
		bne.w	Player_ROSShoes
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		move.w	@playerLUT(pc,d0.w),d1
		jmp	@playerLUT(pc,d1.w)

	@playerLUT:
		dc.w @cont-@playerLUT
		dc.w Tails_ResetOnFloor-@playerLUT
		dc.w Knuckles_ResetOnFloor-@playerLUT
		dc.w @cont-@playerLUT
		dc.w @cont-@playerLUT
		dc.w @cont-@playerLUT
		dc.w Amy_ResetOnFloor-@playerLUT
		dc.w @cont-@playerLUT

	@cont:
	       
		move.b	obHeight(a0),d0
		jsr		ResetHeight
		btst	#2,obStatus(a0)
		beq.s	Player_ResetOnFloor_Part2
		bclr	#2,obStatus(a0)

		move.b	#id_Walk,obAnim(a0) ; use running/walking animation
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,obY(a0)

Player_ResetOnFloor_Part2:
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		bclr	#5,obStatus(a0)
		bclr	#7,obStatus(a0)
		move.b	#0,jumping(a0)
		move.w	#0,(v_itembonus).w
		move.b	#id_Walk,obAnim(a0)
		move.b	#0,(v_flipangle).w
		move.b	#0,(v_flipsremaining).w
		move.b	#0,(v_flipspeed).w
		tst.b	obDoubleJump(a0)
		beq.s	@ret
		cmpi.b	#charID_Mighity,(v_character).w ; Are we Mighty?
		bne.s	@notmighty ; If not, ignore the following code
		cmpi.b	#1,obDoubleJump(a0)
		bne.s	@notsonic
		bsr.w	HammerDrop_Bounce

	@notmighty:
		cmpi.b	#charID_Sonic,(v_character).w
		bne.s	@notsonic
		cmpi.b	#4,obDoubleJump(a0) ; Really only matters for Sonic
		beq.s	@ret
		tst.b	(v_super).w
		bne.s	@notsonic
		cmpi.b	#shID_Bubb,(v_shield).w		; Does Sonic have the bubble Shield?
		bne.s	@notsonic			; if not, branch
		bsr.s	BubbleShield_Bounce
	@notsonic:
		move.b	#0,obDoubleJump(a0)
		move.b	#0,obDoubleJump_property(a0)

	@ret:
		rts

Player_ROSShoes:
		move.b	#2,(v_SpringShoes).w
	;	move.b	#id_Wait,obAnim(a0) ; use "bouncing" animation
		rts

; =============== S U B R O U T I N E =======================================


BubbleShield_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$780,d2
		btst	#6,obStatus(a0)
		beq.s	@cont1
		move.w	#$400,d2

	@cont1:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		movem.l	(sp)+,d1-d2
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,jumping(a0)
		clr.b	stick_to_convex(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_roll,anim(a0)
		bset	#2,status(a0)
		move.b	obHeight(a0),d0
		subi.b	#$13,d0
		ext.w	d0

	@cont2:
		sub.w	d0,obY(a0)
		move.b	#2,(v_oshield+obAnim).w
		sfx		sfx_bubbleattack
		rts
; End of function BubbleShield_Bounce

; End of function Player_ResetOnFloor