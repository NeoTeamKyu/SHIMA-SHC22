KyukoPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Kyuko_Normal	; if not, branch
		jmp		(DebugMode).l
; ===========================================================================

Kyuko_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Kyuko_Index(pc,d0.w),d1
		jmp		Kyuko_Index(pc,d1.w)
; ===========================================================================
Kyuko_Index:
		dc.w	Kyuko_Main-Kyuko_Index
		dc.w	Kyuko_Control-Kyuko_Index
		dc.w	Player_Hurt-Kyuko_Index
		dc.w	Player_Death-Kyuko_Index
		dc.w	Player_ResetLevel-Kyuko_Index
		dc.w	Player_Drowned-Kyuko_Index
; ===========================================================================

Kyuko_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		ResetHeight
		move.l	#Map_Kyuko,obMap(a0)
		move.w	#$780,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$500,(v_plrspeedmax).w ; Kyuko's top speed
		move.w	#$C,(v_plrspeedacc).w ; Kyuko's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Kyuko's deceleration

Kyuko_Control:	; Routine 2
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	@noDebug	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	@noDebug	; if not, branch
		move.w	#1,(v_debuguse).w ; change Kyuko into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================
; This entire fucking chain is really really dumb. It might work, but *I hate it.*
    @noDebug:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	@controlLocked	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

    @controlLocked:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	@controlLocked2	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Kyuko_Modes(pc,d0.w),d1
		jsr		Kyuko_Modes(pc,d1.w)

    @controlLocked2:
		bsr.w	Player_Display
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	@dontAnimate
		tst.b	obAnim(a0)
		bne.s	@dontAnimate
		move.b	obNextAni(a0),obAnim(a0)

    @dontAnimate:
		bsr.w	Kyuko_Animate
		tst.b	(f_lockmulti).w
		bmi.s	@controlLocked3
		jsr		(ReactToItem).l

    @controlLocked3:
		bsr.w	Kyuko_LoadGfx
		rts
; ===========================================================================
Kyuko_Modes:
		dc.w	Kyuko_MdNormal-Kyuko_Modes
		dc.w	Kyuko_MdAir-Kyuko_Modes
		dc.w	Kyuko_MdRoll-Kyuko_Modes
		dc.w	Kyuko_MdJump-Kyuko_Modes
; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Kyuko
; ---------------------------------------------------------------------------

Kyuko_MdNormal:
		bsr.w	Player_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Player_Roll
		bsr.w	Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Kyuko_MdAir:	; Spring, walking off a platform...
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
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	@cont2
		subi.w	#$28,obVelY(a0)

    @cont2:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Kyuko_MdRoll:
		tst.b	obPinball(a0)
		bne.s	@cont
		bsr.w	Player_Jump
	@cont:
		bsr.w	Player_RollRepel
		bsr.w	Player_RollSpeed
		bsr.w	Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Kyuko_MdJump:	; Actually jumping.
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
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	@cont2
		subi.w	#$28,obVelY(a0)

    @cont2:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to	animate	Kyuko's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Kyuko_Animate:
		lea	(Ani_Kyuko).l,a1
    ; Kyuko won't have a Super form, so this snippet would've just been bloat.
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obNextAni(a0),d0 ; is animation set to restart?
		beq.s	@do		; if not, branch
		move.b	d0,obNextAni(a0) ; set to "no restart"
		move.b	#0,obAniFrame(a0) ; reset animation
		move.b	#0,obTimeFrame(a0) ; reset frame duration
		bclr	#5,obStatus(a0)

	@do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	@walkrunroll	; if animation is walk/run/roll/jump, branch
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@delay		; if time remains, branch
		move.b	d0,obTimeFrame(a0) ; load frame duration

@loadframe:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1 ; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		cmp.b	#$FD,d0		; MJ: is it a flag from FD to FF?
		bhs	@end_FF		; if animation is complete, branch

	@next:
		move.b	d0,obFrame(a0)	; load sprite number
		addq.b	#1,obAniFrame(a0) ; next frame number

	@delay:
		rts
; ===========================================================================

@end_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	@end_FE		; if not, branch
		move.b	#0,obAniFrame(a0) ; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	@end_FD		; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0) ; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	@next
; ===========================================================================

@end_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	@end		; if not, branch
		move.b	2(a1,d1.w),obAnim(a0) ; read next byte, run that animation

	@end:
		rts
; ===========================================================================

@walkrunroll:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@delay		; if time remains, branch

		addq.b	#1,d0		; is animation walking/running?
		bne.w	@rolljump	; if not, branch
		moveq	#0,d0		; is animation walking/running?
		move.b	(v_flipangle).w,d0	; if not, branch
		bne.w	@tumble
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Kyuko's angle
		bmi.s	@wrrcont
		beq.s	@wrrcont
		subq.b	#1,d0

	@wrrcont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Kyuko mirrored horizontally?
		bne.s	@flip		; if yes, branch
		not.b	d0		; reverse angle

	@flip:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	@noinvert	; if angle is $0-$7F, branch
		moveq	#3,d1

	@noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)	; is Kyuko pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Kyuko's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		lea	(KyuAni_MachSpeed).l,a1
		cmpi.w	#$A00,d2
		bcc.s	@running

		lea	(KyuAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Kyuko at running speed?
		bcc.s	@running	; if yes, branch

		lea	(KyuAni_Walk).l,a1 ; use walking animation
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
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		bsr.w	@loadframe
		add.b	d3,obFrame(a0)	; modify frame number
		rts

; ===========================================================================

@rolljump:
		addq.b	#1,d0		; is animation rolling/jumping?
		bne.s	@push		; if not, branch
		move.w	obInertia(a0),d2 ; get Kyuko's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(KyuAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Kyuko moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(KyuAni_Roll).l,a1 ; use slower	animation

	@rollfast:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	@belowmax2
		moveq	#0,d2

	@belowmax2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	@loadframe
; ===========================================================================

@push:
		move.w	obInertia(a0),d2 ; get Kyuko's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(KyuAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	@loadframe

; ===========================================================================
@tumble:
		move.b	(v_flipangle).w,d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	@tumble_Left

		andi.b	#$FC,obRender(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#frKyu_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; loc_1B54E:
@tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	@twentyNineIsZero
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	@tumbleCont
; ===========================================================================

    @twentyNineIsZero:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

    @tumbleCont:
		divu.w	#$16,d0
		addi.b	#frKyu_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; End of function Kyuko_Animate

; ---------------------------------------------------------------------------
; Kyuko	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Kyuko_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadKyukoMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
		lea	(DPLC_Kyuko).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		move.l	#Art_Kyuko,d6

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
; End of function Kyuko_LoadGfx

LoadKyukoMap:
		cmpi.l	#Map_Kyuko,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Kyuko,(v_player+obMap).w
	@skip:
		rts