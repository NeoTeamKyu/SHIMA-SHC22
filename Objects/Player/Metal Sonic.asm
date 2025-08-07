MetalPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Metal_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Metal_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Metal_Index(pc,d0.w),d1
		jmp	Metal_Index(pc,d1.w)
; ===========================================================================
Metal_Index:	dc.w Metal_Main-Metal_Index
		dc.w Metal_Control-Metal_Index
		dc.w Player_Hurt-Metal_Index
		dc.w Player_Death-Metal_Index
		dc.w Player_ResetLevel-Metal_Index
		dc.w Player_Drowned-Metal_Index
; ===========================================================================

Metal_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		ResetHeight
		move.l	#Map_Metal,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_plrspeedmax).w ; Metal's top speed
		move.w	#$C,(v_plrspeedacc).w ; Metal's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Metal's deceleration

Metal_Control:	; Routine 2
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	locMS_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	locMS_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Metal into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

locMS_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	locMS_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

locMS_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	locMS_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Metal_Modes(pc,d0.w),d1
		jsr	Metal_Modes(pc,d1.w)

locMS_12C7E:
		jsr	Player_Display
		jsr	Player_RecordPosition
		jsr	Player_Water
	jsr		Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	locMS_12CA6
		tst.b	obAnim(a0)
		bne.s	locMS_12CA6
		move.b	obNextAni(a0),obAnim(a0)

locMS_12CA6:
		bsr.w	Metal_Animate
		tst.b	(f_lockmulti).w
		bmi.s	locMS_12CB6
		jsr	(ReactToItem).l

locMS_12CB6:
		bsr.w	Metal_LoadGfx
		rts
; ===========================================================================
Metal_Modes:	dc.w Metal_MdNormal-Metal_Modes
		dc.w Metal_MdAir-Metal_Modes
		dc.w Metal_MdRoll-Metal_Modes
		dc.w Metal_MdJump-Metal_Modes
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Metal
; ---------------------------------------------------------------------------

Metal_MdNormal:
		jsr Metal_Peelout
		jsr	Metal_Spindash
		bsr.w	Player_Jump
		jsr	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Player_Roll
		jsr     Player_LevelBound
		jsr	(SpeedToPos).l
		jsr	Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Metal_MdAir:	; Spring, walking off a platform...
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
		jsr	Player_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	locMS_12E5C
		subi.w	#$28,obVelY(a0)

locMS_12E5C:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Metal_MdRoll:
		tst.b	obPinball(a0)
		bne.s	@cont
		bsr.w	Player_Jump
	@cont:
		bsr.w	Player_RollRepel
		bsr.w	Player_RollSpeed
		jsr	Player_LevelBound
		jsr	(SpeedToPos).l
		jsr	Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Metal_MdJump:	; Actually jumping.
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
		jsr	Player_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	locMS_12EA6
		subi.w	#$28,obVelY(a0)

locMS_12EA6:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to	animate	Metal's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Metal_Animate:
		lea	(Ani_Metal).l,a1
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
		move.b	obAngle(a0),d0	; get Metal's angle
		bmi.s	@cont
		beq.s	@cont
		subq.b	#1,d0

	@cont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Metal mirrored horizontally?
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
		btst	#5,obStatus(a0)	; is Metal pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Metal's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		lea	(MetAni_MachSpeed).l,a1
		cmpi.w	#$A00,d2
		bcc.s	@running

		lea	(MetAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Metal at running speed?
		bcc.s	@running	; if yes, branch

		lea	(MetAni_Walk).l,a1 ; use walking animation
;		move.b	d0,d1
;		lsr.b	#1,d1
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
		move.w	obInertia(a0),d2 ; get Metal's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(MetAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Metal moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(MetAni_Roll).l,a1 ; use slower	animation

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
		move.w	obInertia(a0),d2 ; get Metal's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(MetAni_Push).l,a1
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
		addi.b	#$75,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; loc_1B54E:
@tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	locMS_1B566
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	locMS_1B572
; ===========================================================================

locMS_1B566:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

locMS_1B572:
		divu.w	#$16,d0
		addi.b	#$75,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; End of function Metal_Animate

; ---------------------------------------------------------------------------
; Metal	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Metal_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadMetalMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_Metal).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperMetal).l,a2
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
		move.l	#Art_Metal,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperMetal,d6

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
; End of function Metal_LoadGfx

LoadMetalMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_Metal,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Metal,(v_player+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperMetal,(v_player+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperMetal,(v_player+obMap).w
	@skip:
		rts

Metal_Peelout:  ; TODO: Clean this shit up. It's big spaghetti.
		moveq	#0,d0
		btst	#1,obSpindash(a0)
		bne.s	Metal_PeelLaunch
		cmpi.b	#id_LookUp,obAnim(a0) ;check to see if your looking up
		bne.s	@return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	@return
		move.b	#1,obAnim(a0)
		move.w	#0,obSpindashCounter(a0)
		sfx     sfx_Charge
		addq.l	#4,sp
		bset	#1,obSpindash(a0)

		bsr.w	Player_LevelBound
		jsr	Player_AnglePos

	@return:
		rts
; ---------------------------------------------------------------------------

Metal_PeelLaunch:
		move.b	#$C,obAnim(a0) ;charging peelout animation (walking to running to peelout sprites)
		move.b	(v_jpadhold2).w,d0
		btst	#0,d0
		bne.w	Metal_PeelCharge
		bclr	#1,obSpindash(a0)	; stop Dashing
		cmpi.b	#$1E,obSpindashCounter(a0)	; have we been charging long enough?
		bne.s	Metal_Peel_Stop_Sound
		move.b	#0,obAnim(a0)	; launches here (peelout sprites)
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	#$0C00,obInertia(a0)	;Set Player's speed
		move.w	obInertia(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		move.w	d0,(v_cameralag).w
		btst	#0,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)

@dontflip:
		;bset	#2,obStatus(a0)
		bclr	#7,obStatus(a0)
		sfx     sfx_ChargeRelease
		bra.w	Metal_PeelResetScr
; ---------------------------------------------------------------------------

Metal_PeelCharge:				; If still charging the dash...
		cmpi.b	#$1E,obSpindashCounter(a0)
		beq.s	Metal_PeelResetScr
		addi.b	#1,obSpindashCounter(a0)
		jmp 	Metal_PeelResetScr

Metal_Peel_Stop_Sound:
		sfx     sfx_ChargeStop

Metal_PeelResetScr:
		addq.l	#4,sp			; increase stack ptr ; was 4
		cmpi.w	#$60,(v_lookshift).w
		beq.s	@finish
		bcc.s	@skip
		addq.w	#4,(v_lookshift).w

	@skip:
		subq.w	#2,(v_lookshift).w

	@finish:
		bsr.w	Player_LevelBound
		jsr	Player_AnglePos
		rts

Metal_Spindash:
		btst	#0,obSpindash(a0)
		bne.s	SCDSpindash_Launch
		cmpi.b	#id_Duck,obAnim(a0) ;check to see if your ducking
		bne.s	@return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	@return
		sfx 	sfx_Charge		; These are if you use AMPS
		addq.l	#4,sp
		bset	#0,obSpindash(a0)
		move.w	#$16,obInertia(a0)

		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0)	; use "rolling"	animation
		addq.w	#5,obY(a0)
		clr.w	obInertia(a0)

		bsr.w	Player_LevelBound
		jsr	Player_AnglePos

	@return:
		rts
; ---------------------------------------------------------------------------

SCDSpindash_Launch:
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	SCDSpindash_Charge
		bclr	#0,obSpindash(a0)	; stop Dashing
		cmpi.b	#$2D,obSpindashCounter(a0)	; have we been charging long enough?
		bne.w	SCDSpindash_Stop_Sound	; if not, branch
		move.b	#$22,obAnim(a0) ;charging spindash animation (walking to running to spindash sprites)

SCDSpindash_Launch2:
		move.b	#id_Roll,obAnim(a0)	; launches here (spindash sprites)
		bset	#2,obStatus(a0)	; set rolling bit
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	obInertia(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		;move.w	d0,(v_cameralag).w
		btst	#0,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)

@dontflip:
		bclr	#7,obStatus(a0)
		sfx 	sfx_ChargeRelease
		bra.w	SCDSpindash_ResetScr
; ---------------------------------------------------------------------------

SCDSpindash_Charge:				; If still charging the dash...
		move.w	(v_plrspeedmax).w,d1	; get top spindash speed
		move.w	d1,d2
		add.w	d1,d1
		tst.b   (v_shoes).w 		; test for speed shoes
		beq.s	@noshoes
		asr.w	#1,d2
		sub.w	d2,d1

@noshoes:
		addi.w	#$64,obInertia(a0)		; increment speed
		cmp.w	obInertia(a0),d1
		bgt.s	@inctimer
		move.w	d1,obInertia(a0)

@inctimer:
		addq.b	#1,obSpindashCounter(a0)		; increment timer
		cmpi.b	#$2D,obSpindashCounter(a0)
		bcs.s	SCDSpindash_ResetScr
		move.b	#$2D,obSpindashCounter(a0)
		jmp 	SCDSpindash_ResetScr

SCDSpindash_Stop_Sound:
		sfx 	sfx_ChargeStop
		clr.w	obInertia(a0)
		jsr		ResetHeight
		move.b	#5,obAnim(a0)		; use "standing" animation
		subq.w	#5,obY(a0)

SCDSpindash_ResetScr:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	@finish
		bcc.s	@skip
		addq.w	#4,(v_lookshift).w

	@skip:
		subq.w	#2,(v_lookshift).w

	@finish:
		bsr.w	Player_LevelBound
		jsr	Player_AnglePos
		rts

Metal_DirectionalJump:
		cmpi.b  #2,obDoubleJump(a0) ; Is it 2 or more?
		bhs.w   @return
		move.b	(v_jpadpress2).w,d0		; Is a jump button pressed?
		andi.b	#btnABC,d0
		beq.w	@return			; if not, branch
;		bclr	#4,obStatus(a0) ; not necessary but keeping it here just in case
		tst.b	(v_super).w	; check Super-state
		beq.s	Metal_ChkTransform		; if not in a super-state, branch
		bra.w	Metal_JumpDash
	@return:
		rts
Metal_ChkTransform:
		tst.b	(f_timecount).w
		beq.w	Metal_JumpDash
		tst.b	(v_super).w
		bne.w	Metal_JumpDash
		cmpi.b	#6,(v_emeralds).w
		bne.w	Metal_JumpDash
		cmpi.w	#50,(v_rings).w
		blo.w	Metal_JumpDash
		bra.w	SuperPlayer_Cont

Metal_JumpDash:
		addq.b	#1,obDoubleJump(a0) ; Add 1 to the Double Jump Flag
		sfx	sfx_Dash
		move.b	(v_jpadhold2).w,d0
		andi.w	#btnUp|btnDn|btnL|btnR,d0	; Get D-pad input
		beq.s	@noInput
		; Any values totalling $B or above are produced by holding
		; both opposing directions on the D-pad, which is invalid
		cmpi.b	#$B,d0
		bhs.s	@noInput
		lsl.w	#2,d0	; This is important.
		lea	Metal_Dash_Velocities-4(pc,d0.w),a1
		move.w	(a1)+,d0
	@super_x:
		tst.b   (v_super).w ; do we have speed shoes?
		beq.s   @water_x
		asl		d0       ; multiply x_vel by 2

	@water_x:
		btst    #6,obStatus(a0) ; are we underwater?
		beq.s   @skipdivide_x
		asr		d0		; divide x_vel by 2
	@skipdivide_x:
		move.w	d0,x_vel(a0)
		move.w	d0,obInertia(a0)
		move.w	(a1)+,d0
	@super_y:
		tst.b   (v_super).w ; do we have speed shoes?
		beq.s   @water_y
		asl		d0       ; multiply y_vel by 2

	@water_y:
		btst    #6,obStatus(a0) ; are we underwater?
		beq.s   @skipdivide_y
		asr		d0		; divide y_vel by 2
	@skipdivide_y:
		move.w	d0,y_vel(a0)
		rts
; ---------------------------------------------------------------------------

	@noInput:
		; If there's no directional input, we just dash forward
		move.w	#$600,d0	; Go right...
	@super_noInput:
		tst.b   (v_super).w ; do we have speed shoes?
		beq.s   @water_noInput
		asl		d0       ; multiply by 2

	@water_noInput:
		btst    #6,obStatus(a0) ; are we underwater?
		beq.s   @skipdivide_NoInput
		asr		d0       ; divide by 2
	@skipdivide_NoInput:
		move.w	d0,y_vel(a0)
		btst	#0,obStatus(a0)	; ...unless Metal is facing left...
		beq.s	@applySpeeds
		neg.w	d0		; ...in which case, go left

	@applySpeeds:
		move.w	d0,x_vel(a0)
		move.w	d0,obInertia(a0)
		move.w	#0,y_vel(a0)
		rts

; ---------------------------------------------------------------------------
Metal_Dash_Velocities:
		dc.w      0, -$600	; up
		dc.w      0,  $600	; down
		dc.w      0,     0	; up + down (shouldn't happen)
		dc.w  -$600,     0	; left
		dc.w  -$600, -$600	; left + up
		dc.w  -$600,  $600	; left + down
		dc.w      0,     0	; left + up + down (shouldn't happen)
		dc.w   $600,     0	; right
		dc.w   $600, -$600	; right + up
		dc.w   $600,  $600	; right + down
		dc.w	  0,	 0	; right + up + down (shouldn't happen)
		; Everything after this would be bad button combinations