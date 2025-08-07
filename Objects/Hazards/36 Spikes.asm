; ---------------------------------------------------------------------------
; Object 36 - spikes
; ---------------------------------------------------------------------------

Spikes:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spik_Index(pc,d0.w),d1
		jmp	Spik_Index(pc,d1.w)
; ===========================================================================
Spik_Index:	dc.w Spik_Main-Spik_Index
		dc.w Spik_Solid-Spik_Index

spik_origX:	equ $30		; start X position
spik_origY:	equ $32		; start Y position

Spik_Var:	dc.b 0,	$14		; frame	number,	object width
		dc.b 1,	$10
		dc.b 2,	4
		dc.b 3,	$1C
		dc.b 4,	$40
		dc.b 5,	$10
; Wait, does this really not have any sort of error checking for the two invalid types...?
; From what I've measured, Invalid 1 is ~80px wide, and is as tall as a regular spike is when facing upwards.
; Invalid 2 is... well, I didn't measure it in pixels, but if fixed, it could be used as a 5-spike vertical subtype.
; To make the width, turn the width (in pixels) into a hexadecimal number, then divide by 2.
		dc.b 6, $28
		dc.b 7, $24
; ===========================================================================

Spik_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spike,obMap(a0)
		cmpi.b	#id_MHZ,(v_zone).w
		bne.s	@notIce
		move.w	#$4000+vramSpikesBGZ,obGfx(a0)	; Make them blue!
		bra.s	@cont
	@notIce:
		cmpi.b	#id_BGZ,(v_zone).w	; BGZ?
		bne.s	@notBamboo
		cmpi.b	#3,(v_act).w	; Act 4 (Legacy BGZ)?
		beq.s	@notBamboo
		move.w	#$6000+vramSpikesBGZ,obGfx(a0)	; Make them green.
		bra.s	@cont
	@notBamboo:
		move.w	#vramSpikesBGZ,obGfx(a0)
	@cont:
		ori.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	obSubtype(a0),d0
		andi.b	#$F,obSubtype(a0)
		andi.w	#$F0,d0
		lea	(Spik_Var).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.w	obX(a0),spik_origX(a0)
		move.w	obY(a0),spik_origY(a0)

Spik_Solid:	; Routine 2
		bsr.w	Spik_Type0x	; make the object move
		move.w	#4,d2
		cmpi.b	#5,obFrame(a0)	; is object type $5x ?
		beq.s	Spik_SideWays	; if yes, branch
		cmpi.b	#1,obFrame(a0)	; is object type $1x ?
		bne.s	Spik_Upright	; if not, branch
		move.w	#$14,d2

; Spikes types $1x and $5x face	sideways

Spik_SideWays:
		move.w	#$1B,d1
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)
		bne.s	Spik_Display
		cmpi.w	#1,d4
		beq.s	Spik_Hurt
		bra.s	Spik_Display
; ===========================================================================

; Spikes types $0x, $2x, $3x and $4x face up or	down

Spik_Upright:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)
		bne.s	Spik_Hurt
		tst.w	d4
		bpl.s	Spik_Display

Spik_Hurt:
		cmpi.b	#charID_Mighity,(v_character).w
		beq.w	Spik_Hurt_Mighty
Spik_Hurt_2:
		tst.b	(v_invinc).w	; is Sonic invincible?
		bne.s	Spik_Display	; if yes, branch
		tst.w	(v_player+$30).w ; +++ is Sonic invulnerable?
		bne.s	Spik_Display	; +++ if yes, branch
		move.l	a0,-(sp)
		movea.l	a0,a2
		lea	(v_player).w,a0
		cmpi.b	#4,obRoutine(a0)
		bcc.s	loc_CF20
		; This fixes the infamous "spike bug"
		tst.b	flashtime(a0)	; Is Sonic flashing after being hurt?
		bne.s	loc_CF20	; If so, skip getting hurt
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
loc_D5A2:
		sub.l	d0,d3
		move.l	d3,obY(a0)
		jsr	(HurtSonic).l

loc_CF20:
		movea.l	(sp)+,a0

Spik_Display:
		bsr.w	DisplaySprite
		move.w	spik_origX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bls.s	Obj36_NoDel
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.w	DeleteObject		; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject	; and delete object

Obj36_NoDel:
		rts	
		
Spik_Hurt_Mighty:
		tst.b	(v_invinc).w	; is Sonic invincible?
		bne.s	Spik_Display	; if yes, branch
		tst.w	(v_player+$30).w ; +++ is Sonic invulnerable?
		bne.s	Spik_Display	; +++ if yes, branch
		lea	(v_player).w,a1
		cmpi.b	#4,obRoutine(a1)
		bcc.s	loc_CF20
		tst.b	flashtime(a1)	; Is Sonic flashing after being hurt?
		bne.s	loc_CF20	; If so, skip getting hurt
		cmpi.b	#id_roll,obAnim(a1)
		bne.s	Check_SpindashSpikes
		bra.s	SpikeImmunity

Check_SpindashSpikes:
		cmpi.b	#id_spindash,obAnim(a1)
		bne.s	Check_DJFM_Spikes
		bra.s	SpikeImmunity

Check_DJFM_Spikes:
		cmpi.b	#1,obDoubleJump(a1)
		bne.w	Spik_Hurt_2

SpikeImmunity:
		cmpi.b	#1,obFrame(a0)	; => Obj36_Sideways
		beq.w	UncurlM
		cmpi.b	#5,obFrame(a0)	; => Obj36_Sideways
		beq.w	UncurlM

Bounce_Check:
		cmpi.w	#$A00,obVelY(a1)
		bge.w	HurtAniNL
		cmpi.w	#-$A00,obVelY(a1)
		ble.w	HurtAniNL
		cmpi.w	#$300,obVelX(a1)
		bge.s	SmallJumpS
		cmpi.w	#-$300,obVelX(a1)
		bgt.s	UncurlM

SmallJumpS:
		move.w	#-$200,obVelY(a1)
		btst	#6,status(a1)
		beq.s	ContSmallJump
		move.w	#-$100,obVelY(a1)

ContSmallJump:
		bclr	#3,obStatus(a1)
		bset	#1,obStatus(a1)
		bset	#2,obStatus(a1)
		move.b	#id_roll,obAnim(a1)
		sfx		sfx_BallDeflect
		cmpi.b	#1,obFrame(a0)
		beq.w	@NegXVelSp
		cmpi.b	#5,obFrame(a0)
		bne.s	@check_Vertical

	@NegXVelSp:
		neg.w	x_vel(a1)
		cmpi.w	#$300,x_vel(a1)
		blt.s	@check_negative
		move.w	#$300,x_vel(a1)

	@check_negative:
		cmpi.w	#-$300,x_vel(a1)
		bgt.s	@check_Vertical
		move.w	#-$300,x_vel(a1)

	@check_Vertical:
		btst	#1,obStatus(a0)	; => Obj36_Upsidedown
		beq.w	locretM_242B4
		neg.w	obVelY(a1)
		bra.w	locretM_242B4

UncurlM:
		move.w	#-$400,obVelY(a1)
		move.w	#-$300,obVelX(a1)
		btst	#6,status(a1)
		beq.s	ContUncurl
		move.w	#-$200,obVelY(a1)
		move.w	#-$150,obVelX(a1)

ContUncurl:
		btst	#1,obStatus(a0)	; => Obj36_Upsidedown
		beq.w	@notVertical
		neg.w	obVelY(a1)
		move.w	obVelX(a1),d0
		asr.w	#1,d0
		move.w	d0,obVelX(a1)

	@notVertical:
		cmpi.b	#1,obFrame(a0)	; => Obj36_Sideways
		beq.s	@HorizontalSpikes
		cmpi.b	#5,obFrame(a0)	; => Obj36_Sideways
		beq.s	@HorizontalSpikes
		btst	#0,obStatus(a1)
		bne.s	loc_10320M
		neg.w	obVelX(a1)
		bra.s	loc_10320M

	@HorizontalSpikes:
		move.w	x_pos(a1),d0
		cmp.w	x_pos(a0),d0
		blo.s	loc_10320M
		neg.w	x_vel(a1)
		bra.w	locretM_242B4

loc_10320M:
		bclr	#3,obStatus(a1)
		bset	#1,obStatus(a1)
		clr.b	obSpindash(a1)
		clr.b	jumping(a1)
		move.b	#2,obDoubleJump(a1)
		move.b	#$12,obAnim(a1) ; Falling
		bra.w	locretM_242B4

HurtAniNL:
		movea.l	a0,a2
		movea.l	a1,a0
		move.b	#4,obRoutine(a0)
		jsr	Player_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#-$400,obVelY(a0) ; make Sonic bounce away from the object
		move.w	#-$200,obVelX(a0)
		btst	#6,obStatus(a0)	; is Sonic underwater?
		beq.s	@isdry		; if not, branch

		move.w	#-$200,obVelY(a0) ; slower bounce
		move.w	#-$100,obVelX(a0)

	@isdry:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		bcs.s	@isleft		; if Sonic is left of the object, branch
		neg.w	obVelX(a0)	; if Sonic is right of the object, reverse

	@isleft:
		move.b #0,spindash_flag(a0) ; clear Spin Dash flag 
		move.w	#0,obInertia(a0)
		move.b	#id_Hurt,obAnim(a0)
		move.b	#$78,flashtime(a0)	; set temp invincible time to 2 seconds
		move.w	#sfx_Death,d0	; load normal damage sound
		cmpi.b	#id_Spikes,(a2)	; was damage caused by spikes?
		beq.s	@setspikesound	; if so, branch
		cmpi.b	#id_Harpoon,(a2) ; was damage caused by LZ harpoon?
		bne.s	@sound		; if not, branch

	@setspikesound:	; if not, branch
		moveq	#sfx_SpikeHit,d0 ; load spikes damage sound

	@sound:
		move.b	d0,mQueue+2.w
		moveq	#-1,d0
		movea.l	a2,a0

locretM_242B4:
		bra.w	Spik_Display
; End of function Touch_ChkHurt2

; ===========================================================================

Spik_Type0x:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	Spik_TypeIndex(pc,d0.w),d1
		jmp	Spik_TypeIndex(pc,d1.w)
; ===========================================================================
Spik_TypeIndex:	dc.w Spik_Type00-Spik_TypeIndex
		dc.w Spik_Type01-Spik_TypeIndex
		dc.w Spik_Type02-Spik_TypeIndex
; ===========================================================================

Spik_Type00:
		rts			; don't move the object
; ===========================================================================

Spik_Type01:
		bsr.w	Spik_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	spik_origY(a0),d0
		move.w	d0,obY(a0)	; move the object vertically
		rts	
; ===========================================================================

Spik_Type02:
		bsr.w	Spik_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	spik_origX(a0),d0
		move.w	d0,obX(a0)	; move the object horizontally
		rts	
; ===========================================================================

Spik_Wait:
		tst.w	$38(a0)		; is time delay	= zero?
		beq.s	loc_CFA4	; if yes, branch
		subq.w	#1,$38(a0)	; subtract 1 from time delay
		bne.s	locret_CFE6
		tst.b	obRender(a0)
		bpl.s	locret_CFE6
		sfx	sfx_SpikeMove	; play "spikes moving" sound
		bra.s	locret_CFE6
; ===========================================================================

loc_CFA4:
		tst.w	$36(a0)
		beq.s	loc_CFC6
		subi.w	#$800,$34(a0)
		bcc.s	locret_CFE6
		move.w	#0,$34(a0)
		move.w	#0,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second
		bra.s	locret_CFE6
; ===========================================================================

loc_CFC6:
		addi.w	#$800,$34(a0)
		cmpi.w	#$2000,$34(a0)
		bcs.s	locret_CFE6
		move.w	#$2000,$34(a0)
		move.w	#1,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second

locret_CFE6:
		rts	
