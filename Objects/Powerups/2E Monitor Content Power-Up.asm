; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jsr		Pow_Index(pc,d1.w)
		addq.b	#1,(RandomRingsID).w ; set to the next  value
		jsr		DisplaySprite
		bra.w	GetRingValue
; ===========================================================================
Pow_Index:
		dc.w	Pow_Main-Pow_Index
		dc.w	Pow_Move-Pow_Index
		dc.w	Pow_Delete-Pow_Index
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_MonitorIcon,obMap(a0)
		move.w	#vramMonitors,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0	; get subtype
		addq.b	#2,d0
		move.b	d0,obFrame(a0)	; use correct frame

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)		; is object moving?
		bpl.w	Pow_Checks		; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce object	speed
		rts
; ===========================================================================

Pow_Checks:
		addq.b	#2,obRoutine(a0)
		move.w	#29,obTimeFrame(a0)	; display icon for half a second
; ===========================================================================

Pow_Chk1Up:
		move.b	obAnim(a0),d0
		cmpi.b	#1,d0						; does monitor contain a 1-up?
		bne.s	Pow_ChkSuper

	ExtraLife:
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.s	@cont						; They won't be losing any anyway, so go away.
		addq.b	#1,(v_lives).w				; add 1 to the number of lives you have
		addq.b	#1,(f_lifecount).w			; update the lives counter
		music	mus_ExtraLife				; play extra life music
		rts
	@cont:
		addi.w	#100,(v_rings).w			; add 100 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w			; update the ring counter
		bra.s	Pow_SilverRingSound

; ===========================================================================

Pow_ChkSuper:
	; By far, the simplest monitor to make.
		cmpi.b	#2,d0	; does monitor contain 'S'?
		bne.s	Pow_ChkSilverRing
		addi.w	#50,(v_rings).w
		jmp		SuperPlayer_Cont
; ===========================================================================

Pow_ChkSilverRing:
		cmpi.b	#3,d0
		bne.s	Pow_ChkRings

		addi.w	#25,(v_rings).w				; add 25 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w			; update the ring counter
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.s	Pow_SilverRingSound			; They won't be losing any anyway, so go away.
		cmpi.w	#100,(v_rings).w			; check if you have 100 rings
		bcs.s	Pow_SilverRingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w			; check if you have 200 rings
		bcs.s	Pow_SilverRingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

	Pow_SilverRingSound:
		sfx		sfx_25Rings					; play ring sound
		rts
; ===========================================================================

Pow_ChkRings:
		cmpi.b	#4,d0						; does monitor contain 10 rings?
		bne.s	Pow_ChkRandomRings
Pow_Give10Rings:
		addi.w	#10,(v_rings).w				; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w			; update the ring counter
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.s	Pow_RingSound				; They won't be losing any anyway, so go away.
		cmpi.w	#100,(v_rings).w			; check if you have 100 rings
		bcs.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w			; check if you have 200 rings
		bcs.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

	Pow_RingSound:
		sfx	sfx_10Rings						; play ring sound
		rts
; ===========================================================================

Pow_ChkRandomRings:
		cmpi.b	#5,d0						; does monitor contain 10 rings?
		bne.s	Pow_ChkInvinc
		move.w	(RandomRingAmount).w,d0
		add.w	d0,(v_rings).w				; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w			; update the ring counter
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.w	Pow_RingSound				; They won't be losing any anyway, so go away.
		cmpi.w	#100,(v_rings).w			; check if you have 100 rings
		bcs.w	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w			; check if you have 200 rings
		bcs.w	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife
		bra.s	Pow_RingSound
; ===========================================================================

Pow_ChkInvinc:
		cmpi.b	#6,d0						; does monitor contain invincibility?
		bne.s	Pow_ChkShoes
		tst.b	(v_super).w					; Prevent Player from getting (invincibility, shoes) if Super
		bne.w	Pow_Give10Rings
		move.b	#1,(v_invinc).w				; make Player invincible
		move.b	#$96,(v_player+invtime).w	; time limit for the power-up (20 seconds)
		tst.b	(f_lockscreen).w			; is boss mode on?
		bne.s	@cont						; if yes, branch
		cmpi.w	#$C,(v_air).w
		bls.s	@cont
		music	mus_Invincibility
	@cont:
		move.b	#id_InvStars,(v_stars).w	; load stars object
		move.b	#1,(v_stars+obAnim).w
		clr.b	(v_oshield+obRoutine).w		; reset routine counter
	@ret:
		rts
; ===========================================================================

Pow_ChkShoes:
		cmpi.b	#7,d0		; does monitor contain speed shoes?
		bne.s	Pow_ChkShield
		tst.b	(v_super).w ; Prevent Player from getting (invincibility, shoes) if Super
		bne.w	Pow_Give10Rings
		move.b	#1,(v_shoes).w	; speed up the BG music
		move.b	#$96,(v_player+shoetime).w	; time limit for the power-up
		move.b	#id_Trail,(v_trails).w
		move.w	#v_player,(v_trails+parent).w
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		tst.b	(v_trails2).w
		bne.s	@nottails
		move.b	#id_Trail,(v_trails2).w ; load Obj7E (super Player stars object) at $FFFFD040
		move.w	#v_followobject,(v_trails2+parent).w

	@nottails:
		move.w	#$C00,(v_plrspeedmax).w ; change Player's top speed
		move.w	#$18,(v_plrspeedacc).w	; change Player's acceleration
		move.w	#$100,(v_plrspeeddec).w	; change Player's deceleration
		btst	#6,(v_player+obStatus).w	; is Player underwater?
		beq.s	@isdry		; if not, branch
		move.w	#$600,(v_plrspeedmax).w ; change Player's top speed
		move.w	#$C,(v_plrspeedacc).w	; change Player's acceleration
		move.w	#$80,(v_plrspeeddec).w	; change Player's deceleration
	@isdry:
		command	mus_ShoesOn	; Speed	up the music
	@ret:
		rts
; ===========================================================================

Pow_ChkShield:
		cmpi.b	#8,d0		; does monitor contain a shield?
		bne.s	Pow_ChkBubbleShield
		cmpi.b	#shID_Norm,(v_shield).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#shID_Norm,(v_shield).w	; give Player a shield
		move.b	#id_ShieldItem,(v_oshield).w ; load shield object ($38)
		clr.b	(v_oshield+obRoutine).w	; Reset routine counter
		sfx	sfx_Shield	; play shield sound
		rts
; ===========================================================================

Pow_ChkBubbleShield:
		cmpi.b	#9,d0		; does monitor contain bubble shield?
		bne.s	Pow_ChkFireShield
		cmpi.b	#shID_Bubb,(v_shield).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#shID_Bubb,(v_shield).w   ;give Player a shield with bubble attribute
		move.b	#id_ShieldItem,(v_oshield).w ; load bubble shield object
		clr.b	(v_oshield+obRoutine).w	; Reset routine counter
		sfx	sfx_BubbleShield
		command	mus_OutWater	; get out of water(tm)
		rts
; ===========================================================================

Pow_ChkFireShield:
		cmpi.b	#10,d0		; does monitor contain fire shield?
		bne.s	Pow_ChkLightningShield
		cmpi.b	#shID_Fire,(v_shield).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#shID_Fire,(v_shield).w   ;give Player a shield with fire attribute
		move.b	#id_ShieldItem,(v_oshield).w ; load fire shield object
		clr.b	(v_oshield+obRoutine).w	; Reset routine counter
		sfx	sfx_FireShield
		rts
; ===========================================================================

Pow_ChkLightningShield:
		cmpi.b	#11,d0		; does monitor contain lightning shield?
		bne.s	Pow_ChkHomingShield
		cmpi.b	#shID_Elec,(v_shield).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#shID_Elec,(v_shield).w   ;give Player a shield with lightning attribute
		move.b	#id_ShieldItem,(v_oshield).w ; load lightning shield object
		move.b	#id_LightningShieldSpark,(v_oshield+$1F).w ; load lightning shield spark object
		clr.b	(v_oshield+obRoutine).w	; Reset routine counter
		sfx	sfx_ElectricShield
		rts
; ===========================================================================

Pow_ChkHomingShield:
		cmpi.b	#12,d0		; does monitor contain homing shield?
		bne.s	Pow_ChkSpring
		cmpi.b	#shID_Gold,(v_shield).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#shID_Gold,(v_shield).w   ;give Player a shield with homing attribute
		move.b	#id_ShieldItem,(v_oshield).w ; load homing shield object
		clr.b	(v_oshield+obRoutine).w	; Reset routine counter
		sfx	sfx_GoldShield
		rts
; ===========================================================================

Pow_ChkSpring:
		cmpi.b	#13,d0						; does monitor contain a pogo spring powerup?
		bne.s	Pow_ChkEnd
		cmpi.b	#id_SpringShoes,(v_oshoes).w
		bne.s	@cont
		bra.w	Pow_Give10Rings
	@cont:
		clr.b	obDoubleJump(a0)	
		move.b	#1,(v_springshoes).w
		move.b	#id_SpringShoes,(v_oshoes).w
		clr.b	(v_oshoes+obRoutine).w
		sfx	sfx_PogoSpring					; play pogo spring sound
		rts
; ===========================================================================

Pow_ChkEnd:
		rts
; ===========================================================================

Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject	; delete after half a second
		rts

	; This is kind of horrendous. Maybe it'll be replaced with something that uses actual RNG soon...?
GetRingValue:
		moveq	#0,d0
		move.b	(RandomRingsID).w,d0
		cmp.b	#6,d0
		bne.s	@getRingValue
		clr.b	d0
		move.b	d0,(RandomRingsID).w
	@getRingValue:
		add.w	d0,d0
		move.w	MonitorValues(pc,d0.w),d0	; get values
		move.w	d0,(RandomRingAmount).w
		rts
MonitorValues:
		dc.w	1
		dc.w	5
		dc.w	10
		dc.w	20
		dc.w	30
		dc.w	40
		dc.w	50
		even