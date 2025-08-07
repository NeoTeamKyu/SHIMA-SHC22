; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

SpringShoes:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SprShoes_Index(pc,d0.w),d1
		jmp	SprShoes_Index(pc,d1.w)
; ===========================================================================
SprShoes_Index:	dc.w SprShoes_Main-SprShoes_Index
		dc.w SprShoes_Anim-SprShoes_Index
		dc.w SprShoes_Shield-SprShoes_Index
		dc.w SprShoes_Falling-SprShoes_Index
; ===========================================================================

SprShoes_Main:	; Routine 0
		addq.b	#4,obRoutine(a0)
		move.l	#Map_SpringShoes,obMap(a0)
		move.w	#vramSpringBGZ,obGfx(a0)	; shield specific code
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#4,obHeight(a0)
		lea		(v_player).w,a1
		move.b	#$20,obHeight(a1)
		move.b	#id_Wait,obAnim(a1) ; use "bouncing" animation
		bclr	#2,obStatus(a1)
		bclr	#3,obStatus(a1)
		bclr	#4,obStatus(a1)
		move.w	#$1C,$30(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		move.b	#$1C,obHeight(a1)
		move.w	#$18,$30(a0)
		bra.s	@notknuckles

	@nottails:
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notknuckles
		clr.b	KnucklesGlideState(a1)

	@notknuckles:
		btst	#1,obStatus(a1)
		bne.s	SprShoes_Shield
		moveq	#0,d2
		move.w	#-$500,d2 ; move Sonic upwards
        btst  #6,obStatus(a1)
        bne.s   @notInWater
		move.w	#-$800,d2 ; move Sonic upwards
    @notInWater:
		move.w	d2,obVelY(a1)
		bset	#1,obStatus(a1)
		subi.w	#$C,obX(a1)
		bra.s	SprShoes_Shield
; ===========================================================================

SprShoes_FramePos:
		dc.b	4, -4, 4, $C, $14, $14, $10, $C, 4, -4

SprShoes_Anim:	; Routine 2
		lea	(Ani_SpringShoes).l,a1
		jsr	(AnimateSprite).l
		lea		(v_player).w,a1
		cmpi.b	#5,obAniFrame(a0)
		bcc.s	SprShoes_Shield
		clr.w	obVelY(a0)
		move.w	$32(a0),obY(a1)
		moveq	#0,d0
		moveq	#0,d1
		move.b	obFrame(a0),d0
		move.b	SprShoes_FramePos(pc,d0),d1
		ext.w	d1
		sub.w	d1,obY(a1)
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),d0
		add.w	$30(a0),d0
		move.w	d0,obY(a0)
		jmp	(DisplaySprite).l

SprShoes_Shield:	; Routine 4
		lea		(v_player).w,a1
		tst.b	(v_springshoes).w	; does Sonic have shield?
		beq.w	@FallOff		; if not, branch
		btst	#bitUp,(v_jpadhold2).w
		beq.s	@nojump
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		bne.w	@jumpoff	; fuck, had to make this a .w... oh well.

	@nojump:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.w	obY(a0),$32(a0)
		move.w	$30(a0),d0
		add.w	d0,obY(a0)
		move.b	#0,obAniFrame(a1)
		lea		(v_player).w,a1
		cmpi.b	#2,(v_springshoes).w
		bne.s	@display
		move.b	#1,(v_springshoes).w
		move.b	#2,obRoutine(a0)
		move.w	#$800,d2
		btst	#6,obStatus(a1)	; Test if underwater
		beq.s	@notunderwater
		move.w	#$500,d2

	@notunderwater:
		moveq	#0,d0
		move.b	obAngle(a1),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a1)	; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a1)	; make Sonic jump

		bset	#1,obStatus(a1)
		bclr	#2,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#1,obJumping(a1)
		move.b	#id_Wait,obAnim(a1) ; use "bouncing" animation
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.s	@light		; if not, branch
		sfx	sfx_Spring		; play spring sound
		bra.s	@donesnd	
	@light:
		sfx	sfx_SpringShoes	; play spring shoes sound
	@donesnd:
		move.b	#0,obAniFrame(a0)
		bra.w	SprShoes_Anim

	@display:
		jmp	(DisplaySprite).l

	@jumpoff:
		moveq	#0,d2
		move.w	#-$380,d2
        btst  #6,obStatus(a1)
        bne.s   @notInWater2
		move.w	#-$680,d2
    @notInWater2:
		move.w	d2,obVelY(a1)
		bset	#2,obStatus(a1)
		move.b	#2,obAnim(a1)
		sfx		sfx_Jump

	@falloff:
		move.w	obVelX(a1),obVelX(a0)
		move.w	obVelY(a1),obVelY(a0)
		neg.w	obVelX(a0)
		jsr	ResetHeight
		clr.b	obFrame(a0)
		move.b	#6,obRoutine(a0)	
		tst.b	(v_springshoes).w
		beq.s	SprShoes_Falling
		clr.b	(v_springshoes).w	
		neg.w	obVelX(a0)
		neg.w	obVelY(a0)

SprShoes_Falling:
		jsr	ObjectFall
		move.w	obX(a0),d0	; get object position
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposx).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bhi.s	@delete
		move.w	obY(a0),d0	; get object position
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposy).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0		; approx distance between object and screen
		cmpi.w	#128+224+192,d0
		bhi.s	@delete
		jmp	(DisplaySprite).l

	@delete:
		jmp	(DeleteObject).l
; ===========================================================================