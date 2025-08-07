TailsPlayer:
		tst.w	(v_debuguse).w
		beq.s	TailsPlayer_Normal
		jmp	DebugMode
; ---------------------------------------------------------------------------

TailsPlayer_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TailsPlayer_Index(pc,d0.w),d1
		jmp	TailsPlayer_Index(pc,d1.w)
; ===========================================================================
; off_1B8CC: TailsPlayer_States:
TailsPlayer_Index:
		dc.w TailsPlayer_Init-TailsPlayer_Index		;  0
		dc.w TailsPlayer_Control-TailsPlayer_Index	;  2
		dc.w Player_Hurt-TailsPlayer_Index		;  4
		dc.w Player_Death-TailsPlayer_Index		;  6
		dc.w Player_ResetLevel-TailsPlayer_Index
		dc.w Player_Drowned-TailsPlayer_Index
; ===========================================================================
; loc_1B8D8: TailsPlayer_Main:
TailsPlayer_Init:
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w
		addq.b	#2,obRoutine(a0)	; => TailsPlayer_Normal
		jsr		ResetHeight
		move.l	#Map_Tails,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$84,obRender(a0) ; obRender(Tails) = $80 | initial obRender(Sonic)
		move.w	#$600,(v_plrspeedmax).w	; set Tails' top speed
		move.w	#$C,(v_plrspeedacc).w	; set Tails' acceleration
		move.w	#$80,(v_plrspeeddec).w	; set Tails' deceleration
		move.b	#id_TailsTails,(v_followobject).w ; load TailsTails (Tails' Tails) at $FFFFD000
		move.w	a0,(v_followobject+parent).w ; set its parent object to this

; ---------------------------------------------------------------------------
; Normal state for Tails
; ---------------------------------------------------------------------------
; loc_1B9B4:
TailsPlayer_Control:
		tst.w	(f_debugmode).w
		beq.s	TailsPlayer_Control_Part2
		btst	#bitB,(v_jpadpress1).w
		beq.s	TailsPlayer_Control_Part2
		move.w	#1,(v_debuguse).w
		clr.b	(f_lockctrl).w
		rts

TailsPlayer_Control_Part2:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	TailsPlayer_Control_Part3	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
; loc_1B9EA:
TailsPlayer_Control_Part3:
		btst	#0,(f_lockmulti).w	; is Tails flying, or interacting with another object that holds him in place or controls his movement somehow?
		bne.s	@belowmin			; if yes, branch to skip Tails' control
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0	; %0000 %0110
		move.w	TailsPlayer_Modes(pc,d0.w),d1
		jsr	TailsPlayer_Modes(pc,d1.w)	; run Tails' movement control code

	@belowmin:
		jsr		Player_Display
		jsr		Player_RecordPosition
		jsr		Player_Water
		jsr		Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	@cont
		tst.b	obAnim(a0)
		bne.s	@cont
		move.b	obNextAni(a0),obAnim(a0)
	@cont:
		bsr.w	Tails_Animate
		tst.b	(f_lockmulti).w
		bmi.s	@nocontrol2
		jsr		(ReactToItem).l
	@nocontrol2:
		bra.w	Tails_LoadGfx

; ===========================================================================
; secondary states under state TailsPlayer_Normal
; off_1BA4E:
TailsPlayer_Modes:
		dc.w TailsPlayer_MdNormal-TailsPlayer_Modes	; 0 - not airborne or rolling
		dc.w TailsPlayer_MdAir-TailsPlayer_Modes		; 2 - airborne
		dc.w TailsPlayer_MdRoll-TailsPlayer_Modes		; 4 - rolling
		dc.w TailsPlayer_MdJump-TailsPlayer_Modes		; 6 - jumping
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Start of subroutine TailsPlayer_MdNormal
; Called if Tails is neither airborne nor rolling this frame
; ---------------------------------------------------------------------------
; loc_1C00A:
TailsPlayer_MdNormal:
		jsr		Player_CheckSpindash
		jsr		Player_Jump
		jsr		Player_SlopeResist
		jsr		Player_Move
		jsr		Player_Roll
		jsr		Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		jsr		Player_SlopeRepel
		rts
; End of subroutine TailsPlayer_MdNormal
; ===========================================================================
; Start of subroutine TailsPlayer_MdAir
; Called if Tails is airborne, but not in a ball (thus, probably not jumping)
; loc_1C032: TailsPlayer_MdJump
TailsPlayer_MdAir:
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		tst.b	(v_SpringShoes).w
		bne.s	@noflying
		tst.b	obDoubleJump(a0)	 ; please tell me this won't break it
		bne.s	Tails_FlyingSwimming
	@noflying:
		jsr		Player_JumpHeight
		jsr		Player_JumpDirection
		jsr		Player_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)	; is Tails underwater?
		beq.s	@cont2		; if not, branch
		subi.w	#$28,obVelY(a0)	; reduce gravity by $28 ($38-$28=$10)
	@cont2:
		jsr		Player_JumpAngle
		jsr		Player_Floor
		rts
; End of subroutine TailsPlayer_MdAir
; ===========================================================================
Tails_FlyingSwimming:	; code from S3K
		bsr.w	Tails_Move_FlySwim
		jsr		Player_JumpDirection
		jsr		Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_JumpAngle
		movem.l	a4-a6,-(sp)
		bsr.w	Player_Floor
		movem.l	(sp)+,a4-a6
		lea		(v_character).w,a1
		move.w	(v_jpadhold1).w,d0

	@ret:
		rts

; =============== S U B R O U T I N E =======================================


Tails_Move_FlySwim:
		move.b	(v_framebyte).w,d0
		andi.b	#1,d0
		beq.s	loc_14836
		tst.b	ob2ndRout(a0)
		beq.s	loc_14836
		subq.b	#1,ob2ndRout(a0)

loc_14836:
		cmpi.b	#1,obDoubleJump(a0)
		beq.s	loc_14860
		cmpi.w	#-$100,obVelY(a0)
		blt.s	loc_14858
		subi.w	#$20,obVelY(a0)
		addq.b	#1,obDoubleJump(a0)
		cmpi.b	#$20,obDoubleJump(a0)
		bne.s	loc_1485E

loc_14858:
		move.b	#1,obDoubleJump(a0)

loc_1485E:
		bra.s	loc_14892
; ---------------------------------------------------------------------------

loc_14860:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0		; Is a jump button pressed?
		beq.s	loc_1488C
		move.b	(v_jpadhold2).w,d0		; Is the down button held?
		andi.b	#btnDn,d0
		beq.s	@cont
		move.b	#id_Roll,obAnim(a0)
		bset	#2,obStatus(a0)   ; force Tails to roll
		rts
	@cont:
		cmpi.w	#-$100,obVelY(a0)
		blt.s	loc_1488C
		tst.b	ob2ndRout(a0)
		beq.s	loc_1488C
		btst	#6,obStatus(a0)
		beq.w	loc_14886

loc_14886:
		move.b	#2,obDoubleJump(a0)

loc_1488C:
		addi.w	#8,obVelY(a0)

loc_14892:
		move.w	(v_limittop2).w,d0
		addi.w	#$10,d0
		cmp.w	obY(a0),d0
		blt.s	Tails_Set_Flying_Animation
		tst.w	obVelY(a0)
		bpl.s	Tails_Set_Flying_Animation
		move.w	#0,obVelY(a0)
; End of function Tails_Move_FlySwim


; =============== S U B R O U T I N E =======================================


Tails_Set_Flying_Animation:
		btst	#6,obStatus(a0)
		bne.w	loc_14914
		moveq	#$21,d0	   ; slow animation
		tst.w	obVelY(a0)
		bpl.s	loc_148CC
		moveq	#$20,d0	   ; fast animation

loc_148CC:
		tst.b	ob2ndRout(a0)	 ; some sort of timer, methinks
		bne.s	loc_148F4
		moveq	#$22,d0	 ; tired flight animation to d0.
		move.b	d0,obAnim(a0)	   ; run whatever animation ID is on d0.
		tst.b	obRender(a0)
		bpl.s	locret_148F2
		move.b	(v_framebyte).w,d0
		addq.b	#8,d0
		andi.b	#$F,d0
		bne.w	locret_148F2
		sfx		sfx_FlyTired

locret_148F2:
		rts
; ---------------------------------------------------------------------------

loc_148F4:
		move.b	d0,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	locret_14912
		move.b	(v_framebyte).w,d0
		addq.b	#8,d0
		andi.b	#$F,d0
		bne.w	locret_14912
		sfx		sfx_Fly

locret_14912:
		rts
; ---------------------------------------------------------------------------

loc_14914:
		moveq	#$23,d0		   ; slow swim
		tst.w	obVelY(a0)
		bpl.w	loc_1491E
		moveq	#$25,d0		   ; fast swim

loc_1491E:
		tst.b	ob2ndRout(a0)
		bne.s	loc_1492E
		moveq	#$24,d0		; just tired swim

loc_1492E:
		move.b	d0,obAnim(a0)
		rts	; end of S3K code
; ===========================================================================
; Start of subroutine TailsPlayer_MdRoll
; Called if Tails is in a ball, but not airborne (thus, probably rolling)
; loc_1C05C:
TailsPlayer_MdRoll:
		tst.b	obPinball(a0)
		bne.s	@cont
		jsr		Player_Jump
	@cont:
		jsr		Player_RollRepel
		jsr		Player_RollSpeed
		jsr		Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		jsr		Player_SlopeRepel
		rts
; End of subroutine TailsPlayer_MdRoll
; ===========================================================================
; Start of subroutine TailsPlayer_MdJump
; Called if Tails is in a ball and airborne (he could be jumping but not necessarily)
; Notes: This is identical to TailsPlayer_MdAir, at least at this outer level.
;	Why they gave it a separate copy of the code, I don't know.
; loc_1C082: TailsPlayer_MdJump2:
TailsPlayer_MdJump:
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		jsr		Player_JumpHeight
		jsr		Player_JumpDirection
		jsr		Player_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)	; is Tails underwater?
		beq.s	@cont2		; if not, branch
		subi.w	#$28,obVelY(a0)	; reduce gravity by $28 ($38-$28=$10)
	@cont2:
		jsr		Player_JumpAngle
		jsr		Player_Floor
		rts
; End of subroutine TailsPlayer_MdJump

Test_For_Flight:
		tst.b	obDoubleJump(a0)
		bne.w	locret_151A2
		move.b	(v_jpadpress2).w,d0		; Is a jump button pressed?
		andi.b	#btnABC,d0
		beq.w	locret_151A2

loc_1515C:	; Disabled Super Tails, as we planned.
;		tst.b	(f_timecount).w
;		beq.w	@flight
;		tst.b	(v_super).w
;		bne.w	@flight
;		cmpi.b	#6,(v_emeralds).w
;		bne.w	@flight
;		cmpi.w	#50,(v_rings).w
;		blo.w	@flight
;		jmp		SuperPlayer_Cont

	@flight:
		btst	#2,obStatus(a0)
		beq.s	loc_1518C
		bclr	#2,obStatus(a0)

		move.b	obHeight(a0),d1
		jsr		ResetHeight
		sub.b	#$F,d1
		ext.w	d1
		tst.b	(f_wtunnelmode-1).w
		beq.s	loc_15188
		neg.w	d0

loc_15188:
		add.w	d1,obY(a0)

loc_1518C:
		bclr	#4,obStatus(a0)
		move.b	#1,obDoubleJump(a0)
		move.b	#-$10,ob2ndRout(a0)
		bsr.w	Tails_Set_Flying_Animation

locret_151A2:
		rts

; ---------------------------------------------------------------------------
; Subroutine to reset Tails' mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CB50:
Tails_ResetOnFloor:
		tst.b	obPinball(a0)
		bne.s	Tails_ResetOnFloor_Part3
		tst.b   (v_victory).w ; Has the victory animation flag been set?
		beq.s   @normalJump ; If not, branch
		move.b  #id_Victory+1,obAnim(a0) ; Play the victory animation
		bra.s   Tails_ResetOnFloor_Part2 ; Continue
	@normalJump:
		move.b	#id_Walk,obAnim(a0)	; use running/walking/standing animation

Tails_ResetOnFloor_Part2:
		btst	#2,obStatus(a0)
		beq.s	Tails_ResetOnFloor_Part3
		bclr	#2,obStatus(a0)
		jsr		ResetHeight
		move.b	#id_Walk,obAnim(a0)	; use running/walking/standing animation
		subq.w	#1,obY(a0)	; move Tails up 1 pixel so the increased height doesn't push him slightly into the ground
; loc_1CB80:
Tails_ResetOnFloor_Part3:
		bclr	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		bclr	#4,obStatus(a0)
		moveq	#0,d0
		move.b	d0,(v_flipangle).w
		move.b	d0,(v_flipsremaining).w
		move.b	d0,(v_flipspeed).w
		move.b	d0,obJumping(a0)
		move.w	d0,(v_itembonus).w
	;	move.w	d0,(v_scrolldelay).w
		move.w	d0,obDoubleJump(a0)

		cmpi.b	#$21,obAnim(a0)
		bcc.s	@fug
		cmpi.b	#$14,obAnim(a0)
		bne.s	@ret
	@fug:
		move.b	d0,obAnim(a0)

	@ret:
		rts
; End of subroutine Tails_ResetOnFloor

; ---------------------------------------------------------------------------
; Subroutine to animate Tails' sprites
; See also: AnimateSprite and Player_Animate
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1CDC4:
Tails_Animate:
		lea	(TailsAniData).l,a1
; loc_1CDCA:
Tails_Animate_Part2:
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obNextAni(a0),d0	; has animation changed?
		beq.s	TAnim_Do		; if not, branch
		move.b	d0,obNextAni(a0)	; set previous animation
		move.b	#0,anim_frame(a0)	; reset animation frame
		move.b	#0,obTimeFrame(a0)	; reset frame duration
		bclr	#5,obStatus(a0)
; loc_1CDEC:
TAnim_Do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; calculate address of appropriate animation script
		move.b	(a1),d0
		bmi.s	TAnim_WalkRunZoom	; if animation is walk/run/roll/jump, branch
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from frame duration
		bpl.s	TAnim_Delay			; if time remains, branch
		move.b	d0,obTimeFrame(a0)	; load frame duration
; loc_1CE12:
TAnim_Do2:
		moveq	#0,d1
		move.b	anim_frame(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0		; read sprite number from script
		cmpi.b	#$F0,d0
		bhs.s	TAnim_End_FF		; if animation is complete, branch
; loc_1CE22:
TAnim_Next:
		move.b	d0,obFrame(a0)	; load sprite number
		addq.b	#1,anim_frame(a0)	; go to next frame
; return_1CE2A:
TAnim_Delay:
		rts
; ===========================================================================
; loc_1CE2C:
TAnim_End_FF:
		addq.b	#1,d0		; is the end flag = $FF ?
		bne.s	TAnim_End_FE	; if not, branch
		move.b	#0,anim_frame(a0)	; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	TAnim_Next
; ===========================================================================
; loc_1CE3C:
TAnim_End_FE:
		addq.b	#1,d0		; is the end flag = $FE ?
		bne.s	TAnim_End_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next byte in the script
		sub.b	d0,anim_frame(a0)	; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	TAnim_Next
; ===========================================================================
; loc_1CE50:
TAnim_End_FD:
		addq.b	#1,d0			; is the end flag = $FD ?
		bne.s	TAnim_End		; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)	; read next byte, run that animation
; return_1CE5A:
TAnim_End:
		rts
; ===========================================================================
; loc_1CE5C:
TAnim_WalkRunZoom: ; a0=character
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from Tails' frame duration
		bpl.s	TAnim_Delay			; if time remains, branch

		addq.b	#1,d0		; is the end flag = $FF ?
		bne.w	TAnim_Roll	; if not, branch
		moveq	#0,d0		; is animation walking/running?
		move.b	(v_flipangle).w,d0	; if not, branch
		bne.w	TAnim_Tumble
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Tails' angle
		bmi.s	@cont
		beq.s	@cont
		subq.b	#1,d0

	@cont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Tails mirrored horizontally?
		bne.s	@flip		; if yes, branch
		not.b	d0		; reverse angle

	@flip:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	@noinvert		; if angle is $0-$7F, branch
		moveq	#3,d1

	@noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)
		bne.w	TAnim_Push

		lsr.b	#4,d0		; divide angle by 16
		andi.b	#6,d0		; angle must be 0, 2, 4 or 6
		move.w	obInertia(a0),d2
		bpl.s	@nomodspeed
		neg.w	d2

	@nomodspeed:
		lea	(TailsAni_HaulAss).l,a1
		cmpi.w	#$700,d2	; May change this later, but this makes it work at the original speed.
		bcc.s	@running

		lea	(TailsAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Tails at running speed?
		bcc.s	@running	; if yes, branch

		lea	(TailsAni_Walk).l,a1 ; use walking animation
		add.b	d0,d0

	@running:
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	@belowmax
		moveq	#0,d2		; max animation speed

	@belowmax:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)	; modify frame duration
		bsr.w	TAnim_Do2
		add.b	d3,obFrame(a0)
		rts

; ===========================================================================
; loc_1CF6E:
TAnim_Roll:
		addq.b	#1,d0		; is the end flag = $FE ?
		bne.w	TAnim_GetTailFrame	; if not, branch
		move.w	obInertia(a0),d2
		bpl.s	@ispositive
		neg.w	d2
	@ispositive:
		lea	(TailsAni_Roll2).l,a1
		cmpi.w	#$600,d2
		bhs.s	@cont
		lea	(TailsAni_Roll).l,a1
	@cont:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	@cont2
		moveq	#0,d2
	@cont2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	TAnim_Do2
; ===========================================================================
; loc_1CFB2
TAnim_Push:
		move.w	obInertia(a0),d2
		bmi.s	@cont
		neg.w	d2
	@cont:
		addi.w	#$800,d2
		bpl.s	@cont2
		moveq	#0,d2
	@cont2:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)
		lea	(TailsAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	TAnim_Do2

; ===========================================================================
TAnim_Tumble:
		move.b	(v_flipangle).w,d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	TAnim_Tumble_Left

		andi.b	#$FC,obRender(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#frT_Corkscrew1,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; loc_1B54E:
TAnim_Tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	loc2_1B566
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	loc2_1B572
; ===========================================================================

loc2_1B566:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

loc2_1B572:
		divu.w	#$16,d0
		addi.b	#frT_Corkscrew1,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; ===========================================================================
; loc_1CFE4:
TAnim_GetTailFrame:
		move.w	obVelX(a2),d1
		move.w	obVelY(a2),d2
		jsr	(CalcAngle).l
		cmpi.b	#$10,(v_gamemode).w
		bne.s	@notSS
		add.b	(v_ssangle).w,d0
	@notSS:
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	loc_1D002
		not.b	d0
		bra.s	loc_1D006
; ===========================================================================

loc_1D002:
		addi.b	#$80,d0

loc_1D006:
		addi.b	#$10,d0
		bpl.s	@cont
		moveq	#3,d1
	@cont:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		lsr.b	#3,d0
		andi.b	#$C,d0
		move.b	d0,d3
		lea	(TailsTailsAni_Directional).l,a1
		move.b	#3,obTimeFrame(a0)
		bsr.w	TAnim_Do2
		add.b	d3,obFrame(a0)
		rts

; ---------------------------------------------------------------------------
; Tails' Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1D184:
TailsTails_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadTailsTailsMap
		cmp.b	(v_tailframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_tailframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_TailsTails).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperTailsTails).l,a2
	@cont:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
;		tst.b	(v_super).w
;		bne.s	@superart
		move.l	#Art_TailsTails,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperTailsTails,d6

	@readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries

	@nochange:
		rts

LoadTailsTailsMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_TailsTails,(v_followobject+obMap).w
		beq.s	@skip
		move.l	#Map_TailsTails,(v_followobject+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperTailsTails,(v_followobject+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperTailsTails,(v_followobject+obMap).w
	@skip:
		rts

; ---------------------------------------------------------------------------
; Tails	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadTailsMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_Tails).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperTails).l,a2
	@cont:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
;		tst.b	(v_super).w
;		bne.s	@superart
		move.l	#Art_Tails,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperTails,d6

	@readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries

	@nochange:
		rts
; End of function Tails_LoadGfx

LoadTailsMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_Tails,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Tails,(v_player+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperTails,(v_player+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperTails,(v_player+obMap).w
	@skip:
		rts
; ----------------------------------------------------------------------------
; Object 9C - Tails' tails
; ----------------------------------------------------------------------------
; Sprite_1D200:
TailsTails:
		cmpi.b	#id_SonicPlayer,(v_player).w
		beq.s	@cont
		cmpi.b	#id_ContSonic,(v_player).w
		beq.s	@cont
		jmp		DeleteObject
@cont:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TailsTails_Index(pc,d0.w),d1
		jmp	TailsTails_Index(pc,d1.w)
; ===========================================================================
; off_1D20E: TailsTails_States:
TailsTails_Index:
		dc.w TailsTails_Init-TailsTails_Index	; 0
		dc.w TailsTails_Main-TailsTails_Index	; 2
; ===========================================================================

; loc_1D212
TailsTails_Init:
		addq.b	#2,obRoutine(a0) ; => TailsTails_Main
		move.l	#Map_TailsTails,obMap(a0)
		move.w	#vramAbbey,obGfx(a0) ;	god i hope this doesnt override anything...
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)

; loc_1D23A:
TailsTails_Main:
		movea.w	parent(a0),a2 ; a2=character
		move.w	obPriority(a2),obPriority(a0)
		move.b	obAngle(a2),obAngle(a0)
		move.b	obStatus(a2),obStatus(a0)
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		andi.w	#$7FFF,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	@cont
		ori.w	#(1<<15),art_tile(a0)
	@cont:
		moveq	#0,d0
		move.b	obAnim(a2),d0
		btst	#5,obStatus(a2)		; is Tails about to push against something?
		beq.s	@cont2			; if not, branch
		cmpi.b	#frT_Push1,obFrame(a2)	; Is Tails in his pushing animation yet?
		blo.s	@cont2			; If not yet, branch, and do not set tails' tail pushing animation
		cmpi.b	#frT_Push4,obFrame(a2)	; ''
		bhi.s	@cont2			; ''
		moveq	#4,d0
	@cont2:
	; This is here so TailsTailsAni_Flick works
	; It changes obAnim(a0) itself, so we don't want the below code changing it as well
		cmp.b	obParentNextAni(a0),d0	; Did Tails' animation change?
		beq.s	@display
		move.b	d0,obParentNextAni(a0)
		move.b	TailsTailsAniSelection(pc,d0.w),obAnim(a0)	; If so, update Tails' tails' animation
; loc_1D288:
	@display:
		cmpi.b	#id_Special,(v_gamemode).w ; is game on special stage?
		beq.s	@loadtailsspecial
		lea	(TailsTailsAniData).l,a1
		bsr.w	Tails_Animate_Part2
		bsr.w	TailsTails_LoadGfx
		lea	(v_player).w,a1
		move.b	flashtime(a1),d0
		beq.s	@displayalways
		addq.w	#1,d0
		lsr.w	#3,d0
		bcs.s	@displayalways
		rts
	@displayalways:
		jmp	(DisplaySprite).l
	
	@loadtailsspecial:	
		lea	(TailsTailsAniData).l,a1
		bsr.w   Tails_Animate_Part2
		bsr.w   TailsTails_LoadGfx
		jsr (DisplaySprite).l
		rts
; ===========================================================================
; animation master script table for the tails
; chooses which animation script to run depending on what Tails is doing
; byte_1D29E:
TailsTailsAniSelection:
		dc.b	0,0	; TailsAni_Walk,Run	-> None
		dc.b	3,3	; TailsAni_Roll,Roll2	-> Directional
		dc.b	9	; TailsAni_Push		-> Pushing
		dc.b	1	; TailsAni_Wait		-> Swish
		dc.b	0	; TailsAni_Balance	-> None
		dc.b	1,1	; TailsAni_LookUp,Duck	-> Flick
		dc.b	7	; TailsAni_Spindash	-> Spindash
		dc.b	0	; TailsAni_Fall		-> Falling
		dc.b	0	; TailsAni_Balance2 -> None
		dc.b	0	; TailsAni_Blank	-> None
		dc.b	8	; TailsAni_Stop		-> Skidding
		dc.b	0,0	; TailsAni_Float,2	-> None
		dc.b	0	; TailsAni_Spring	-> None
		dc.b	0	; TailsAni_Hang		-> None
		dc.b	0,0	; TailsAni_Blink,2	-> None
		dc.b	0	; TailsAni_Hang2	-> None
		dc.b	0	; TailsAni_Bubble	-> None
		dc.b	0,0,0,0	; TailsAni_Death,2,3,4	-> None
		dc.b	0,0	; TailsAni_Hurt,Slide	-> None
		dc.b	0	; TailsAni_Blank	-> None
		dc.b	0,0	; TailsAni_Float3,4	-> None
		dc.b	0	; TailsAni_HaulAss	-> None
		dc.b	$A	; TailsAni_FlyFast	-> Flying fast
		dc.b	$B	; TailsAni_Fly		-> Flying (woah holy shit im smart!!!)
		dc.b	$C	; TailsAni_FlyTired	-> Tired boi.
		dc.b	0,0,0,0,0	; TailsAni_Swim,SwimTired,Swim2,Victory,Transform	-> None
		even