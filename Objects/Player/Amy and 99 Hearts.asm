AmyPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Amy_Normal	; if not, branch
		jmp	DebugMode
; ===========================================================================

Amy_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Amy_Index(pc,d0.w),d1
		jmp	Amy_Index(pc,d1.w)
; ===========================================================================
Amy_Index:	dc.w Amy_Main-Amy_Index
		dc.w Amy_Control-Amy_Index
		dc.w Player_Hurt-Amy_Index
		dc.w Player_Death-Amy_Index
		dc.w Player_ResetLevel-Amy_Index
		dc.w Player_Drowned-Amy_Index
; ===========================================================================

Amy_Main:
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		ResetHeight
		move.l	#Map_Amy,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_plrspeedmax).w ; Amy's top speed
		move.w	#$C,(v_plrspeedacc).w ; Amy's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Amy's deceleration

Amy_Control:
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	locA_12C58	; if not, branch
		btst	#4,(v_jpadpress1).w ; is button C pressed?
		beq.s	locA_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Amy	into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

locA_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	locA_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

locA_12C64:
		btst	#0,(f_lockmulti).w ; are controls	locked?
		bne.s	locA_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Amy_Modes(pc,d0.w),d1
		jsr	Amy_Modes(pc,d1.w)

locA_12C7E:
		bsr.w	Player_Display
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water
		bsr.w	Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	locA_12CA6
		tst.b	obAnim(a0)
		bne.s	locA_12CA6
		move.b	obNextAni(a0),obAnim(a0)

locA_12CA6:
		bsr.w	Amy_Animate
		tst.b	(f_lockmulti).w
		bmi.s	locA_12CB6
		jsr		ReactToItem

locA_12CB6:
		bsr.w	Amy_LoadGfx
		rts
; ===========================================================================
Amy_Modes:	dc.w Amy_MdNormal-Amy_Modes
		dc.w Amy_MdAir-Amy_Modes
		dc.w Amy_MdRoll-Amy_Modes
		dc.w Amy_MdJump-Amy_Modes
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Amy
; ---------------------------------------------------------------------------

Amy_MdNormal:				; XREF: Amy_Modes
		bsr.w	Amy_CheckDash
		bsr.w	Amy_Leaping
		bsr.w	Amy_HighJump
		bsr.w	Amy_PratfallEnd
		bsr.w	Amy_Hammer
		bsr.w	Amy_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Player_Roll
		bsr.w	Player_LevelBound
		jsr		SpeedToPos
		bsr.w	Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Amy_MdAir:				; XREF: Amy_Modes
		cmpi.b	#id_Spring,obAnim(a0) ; Is Player in his spring animation
		bne.s	@cont ; if not branch
		tst.b	obVelY(a0) ; has Player reached peak height from a spring
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0) ; use falling animation
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Amy_JumpAttack
		bsr.w	Amy_HammerSpin
;		bsr.w	HammerSpin_Hearts
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		bclr	#1,(f_lockctrl).w	; unlock controls
		btst	#6,obStatus(a0)
		beq.s	locA_12E5C
		subi.w	#$28,obVelY(a0)

locA_12E5C:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Amy_MdRoll:				; XREF: Amy_Modes
		bsr.w	Amy_Jump
		bsr.w	Player_RollRepel
		bsr.w	Player_RollSpeed
		bsr.w	Player_LevelBound
		jsr	SpeedToPos
		bsr.w	Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Amy_MdJump:				; XREF: Amy_Modes
		cmpi.b	#id_Spring,obAnim(a0) ; Is Player in his spring animation
		bne.s	@cont ; if not branch
		tst.b	obVelY(a0) ; has Player reached peak height from a spring
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0) ; use falling animation
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Amy_JumpAttack
		bsr.w	Amy_Pratfall
		bsr.w	Amy_HammerSpin
		;bsr.w	HammerSpin_Hearts
		bsr.w	Player_JumpHeight
		bsr.w	Amy_JumpLand
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		tst.b	obDoubleJump_property(a0)		; was jumpdash flag set?
		bne.s	MdAir_NoPratfall2
		bclr	#1,(f_lockctrl).w	; unlock controls
MdAir_NoPratfall2:
		btst	#6,obStatus(a0)
		beq.s	locA_12EA6
		subi.w	#$28,obVelY(a0)

locA_12EA6:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ---------------------------------------------------------------------------
; balancing checks for Amy
Amy_Balance:
		jsr	ObjFloorDist
		cmpi.w	#$C,d1
		blt.w	Player_LookUp
		cmpi.b	#3,obNextTilt(a0)
		bne.s	Amy_BalanceLeft

Amy_BalanceOnObjRight:
		bclr	#0,obStatus(a0)
		bra.s	Amy_ResetScr
; ===========================================================================

Amy_BalanceLeft:
		cmpi.b	#3,obTilt(a0)
		beq.s	Amy_BalanceOnObjLeft
		jmp		Player_LookUp

Amy_BalanceOnObjLeft:
		bset	#0,obStatus(a0)

Amy_ResetScr:
		cmp.b	#$25,obAnim(a0) 	; Amy Hammering
		beq.s	@hammer
		cmp.b	#$1F,obAnim(a0) 	; Amy Hammering
		bne.s	@nohammer
	@hammer:
		bra.w	Player_ResetScr
	@nohammer:
		move.b	#6,obAnim(a0)	; use "balancing" animation
		bra.w	Player_ResetScr
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to make Amy perform a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Amy_CheckDash:
		tst.b	obSpindash(a0)			; already Spin Dashing?
		bne.s	Amy_UpdateDash		; if set, branch
		cmpi.b	#id_LookUp,obAnim(a0)		; is anim looking up
		bne.s	@ret		; if not, return
		move.b	(v_jpadpress2).w,d0	; read controller
		andi.b	#btnBC,d0			; pressing B/C ?
		beq.w	@ret		; if not, return
		move.b	#$26,obAnim(a0)		; set Spin Dash anim (9 in s2)
		sfx		sfx_Spindash
		addq.l	#4,sp			; increment stack ptr
		move.b	#1,obSpindash(a0)		; set Spin Dash flag
		move.w	#0,obSpindashCounter(a0)		; set charge count to 0
		move.b	#2,(v_dust+obAnim).w
		move.b	#0,(v_dust+obTimeFrame).w
		move.w	#$80,obSpindashCounter(a0)

	@done:
		bsr.w	Player_LevelBound
		bsr.w	Player_AnglePos

	@ret:
		rts
; ---------------------------------------------------------------------------

Amy_UpdateDash:
		move.b	#$26,obAnim(a0)		; set Spin Dash anim (9 in s2)
		move.b	(v_jpadhold2).w,d0	; read controller
		btst	#bitUp,d0			; check up button
		bne.w	Amy_ChargingDash		; if set, branch

		; unleash the charged dash and start running quickly:
		move.b	#id_Run,obAnim(a0)		; set animation to run
		move.b	#0,obSpindash(a0)		; clear Spin Dash flag
		moveq	#0,d0
		move.b	obSpindashCounter(a0),d0		; copy charge count
		add.w	d0,d0			; double it
		move.w	Dash_Speeds(pc,d0.w),obInertia(a0) ; get normal speed
		tst.b	(v_super).w
		beq.s	@done
		move.w	Dash_Speeds_Super(pc,d0.w),obInertia(a0)
	@done:
		move.b	obInertia(a0),d0		; get inertia
		subi.b	#$8,d0		; subtract $8
		add.b	d0,d0			; double it
		andi.b	#$1F,d0		; mask it against $1F
		neg.b	d0			; negate it
		addi.b	#$20,d0		; add $2
		move.b	d0,(v_cameralag).w
		btst	#0,status(a0)
		beq.s	@done2
		neg.w	obInertia(a0)
	@done2:
		tst.b	(v_super).w
		beq.s	@notsuper
		move.b	#6,(v_dust+obAnim).w
		bra.s	@cont
	@notsuper:
		move.b	#5,(v_dust+obAnim).w
	@cont:
		sfx	sfx_Dash ; play dash sound

		bra.w	Player_Spindash_ResetScr
; ===========================================================================
Dash_Speeds:
		dc.w  $800	; 0
		dc.w  $880	; 1
		dc.w  $900	; 2
		dc.w  $980	; 3
		dc.w  $A00	; 4
		dc.w  $A80	; 5
		dc.w  $B00	; 6
		dc.w  $B80	; 7
		dc.w  $C00	; 8
Dash_Speeds_Super:
		dc.w  $B00	; 0
		dc.w  $B80	; 1
		dc.w  $C00	; 2
		dc.w  $C80	; 3
		dc.w  $D00	; 4
		dc.w  $D80	; 5
		dc.w  $E00	; 6
		dc.w  $E80	; 7
		dc.w  $F00	; 8
; ===========================================================================

Amy_ChargingDash:				; If still charging the dash...
		tst.w	obSpindashCounter(a0)		; check charge count
		beq.s	@done	; if zero, branch

		move.b	(v_jpadhold2).w,d0	; Mercury's "don't rev the spindash down..."
		andi.b	#btnBC,d0 ; "...but only if you're holding the button."
		bne.s	@done

		move.w	obSpindashCounter(a0),d0	; otherwise put it in d0
		lsr.w	#5,d0		; shift right 5 (divide it by 32)
		sub.w	d0,obSpindashCounter(a0)	; subtract from charge count

		cmpi.w	#$1F,obSpindashCounter(a0)
		bne.s	@skip
		move.w	#0,obSpindashCounter(a0)
		move.b	#0,obSpindash(a0)
		bra.s	@done

	@skip:
		bcc.s	@done	; ??? branch if carry clear
		move.w	#0,obSpindashCounter(a0)	; set charge count to 0

	@done:
		move.b	(v_jpadpress2).w,d0	; read controller
		andi.b	#btnBC,d0			; pressing A/B/C?
		beq.w	Player_Spindash_ResetScr		; if not, branch
		move.w	#$2600,obAnim(a0)		; reset spdsh animation
		move.b	#2,(v_dust+obAnim).w	; Set the Spin Dash dust animation to $2.
		sfx		sfx_Spindash
		addi.w	#$200,obSpindashCounter(a0)		; increase charge count
		cmpi.w	#$800,obSpindashCounter(a0)		; check if it's maxed
		bcs.w	Player_Spindash_ResetScr		; if not, then branch
		move.w	#$800,obSpindashCounter(a0)		; reset it to max
		jmp		Player_Spindash_ResetScr
; End of subroutine Amy_CheckDash

Duck_Movement:
		cmpi.b	#$29,obAnim(a0)	; are we still in the hammer animation?
		beq.w	@ret		; if yes, branch
		moveq	#0,d1		; make sure d1 is empty
		move.b	obAngle(a0),d1	; move angle to d1
		bpl.s	@positiveAngle	; is angle positive? if yes, branch
		neg.b	d1		; otherwise negate it (e.g. change it from -$10 to $10)

	@positiveAngle:
		cmpi.b	#$10,d1		; is angle within -$10 and $10?
		bgt.s	@ret	; if not, branch
		tst.w	obInertia(a0)		; is Amy moving?
		beq.s	@ret				; if not, branch

		;move.w	#0,obInertia(a0)	; stop Amy moving (interia)
		;move.w	#$20,obVelX(a0)	; stop Amy moving (X-speed)
		cmp.b	#8,obAnim(a0)
		bne.s	@duck1
		move.w	obInertia(a0),d0
		move.w	d0,d1
		asr.w	#3,d1
		sub.w	d1,d0
		move.w	d0,obInertia(a0)
		rts
	@duck1:
		move.w	obInertia(a0),d0
		move.b	#8,obAnim(a0)	; use "ducking"	animation
		btst	#0,obStatus(a0)
		beq	@duck2
		neg.w	d0
	@duck2:
		cmp.w	#$10,d0
		bgt	@duck4
		move.w	#$10,d0
		btst	#0,obStatus(a0)
		beq	@duck3
		neg.w	d0
	@duck3:
		move.w	d0,obInertia(a0)
	@duck4:
		move.w	obVelX(a0),d0
		tst.w	d0
		bpl	@ret
		neg.w	d0

	@ret:
		rts			; return

; ---------------------------------------------------------------------------
; Subroutine to	activate Amy's Jump Attack
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_PratfallEnd:
		tst.b	obDoubleJump_property(a0)		; was jumpdash flag set?
		beq.w	@end3			; if not, branch
		cmpi.b	#$2A,obAnim(a0)	; are we still in the hammer animation?
		beq.s	@end3		; if yes, branch
		cmpi.b	#$29,obAnim(a0)	; are we still in the hammer animation?
		beq.s	@end		; if yes, branch
		cmpi.b	#$28,obAnim(a0)	; are we still in the hammer animation?
		beq.s	@end		; if yes, branch
		clr.b	(f_lockctrl).w	; unlock controls
		clr.b	obDoubleJump_property(a0)		; if not, set jumpdash flag
		rts
	@end:
		tst.w	obInertia(a0)		; is Amy moving?
		bne.s	@end2; if yes, branch
		move.b  #$2A,obAnim(a0)   	; use recover animation
		rts
	@end2:
		move.b  #$29,obAnim(a0)   	; use skid animation
		cmpi.b	#6,obAniFrame(a0)	; are we still in the hammer animation?
		beq.s	@end3		; if yes, branch
		;cmpi.b	#5,anim_frame(a0)	; are we still in the hammer animation?
		;beq.s	@end3		; if yes, branch
		sfx		sfx_GroundSlide

	@end3:
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Amy to high jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_HighJump:
		cmp.b	#6,obAnim(a0)
		beq.w	HJ_Button
		cmp.b	#8,obAnim(a0)
		bne.w	HJ_End
HJ_Button:
		move.b	(v_jpadpress2).w,d0	; move the current button press to d0
		btst	#1,(v_jpadhold2).w	; is Down button pressed?
		beq.b	HJ_End			; if not, return
		and.b	#$40,d0			; get only button A
		cmp.b	#$40,d0			; were A pressed?
		bne.s	HJ_End			; if not, branch
		move.b	(v_ssangle).w,d0
		andi.b	#$FC,d0
		neg.b	d0
		subi.b	#$40,d0
		bset	#1,obStatus(a0)
		tst.b	(v_highJump).w		; was jumpdash flag set?
		bne.w	HJ_End			; if yes, branch
		move.b	#1,(v_highJump).w	; if not, set jumpdash flag
		move.b	#$23,obAnim(a0)		; show hammer animation
		bclr	#4,obStatus(a0)		; clear double jump flag
		move.w	#-$250,obVelY(a0)		; set normal jumpdash speed
;		btst	#6,obStatus(a0)		; is Amy underwater?
;		beq.s	HJ_End		; if not, branch
;		move.w	#-$250,obVelY(a0)		; set underwater jumpdash speed
HJ_End:
		rts				; return
; End of function Amy_HighJump

; ---------------------------------------------------------------------------
; Subroutine allowing Amy to leap
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_Leaping:
		cmp.b	#6,obAnim(a0)
		beq.w	SL_Button
		cmp.b	#8,obAnim(a0)
		bne.w	SL_End
SL_Button:
		move.b	(v_jpadpress2).w,d0	; move the current button press to d0
		btst	#1,(v_jpadhold2).w	; is Down button pressed?
		beq.b	JumpToSL_End		; if not, return
		andi.b	#btnBC,d0			; were B pressed?
		cmp.b	#$10,d0			; were B pressed?
		beq.s	Cont_Leap		; if yes, branch
Leaping_C:
		andi.b	#$20,d0			; were C pressed?
		cmp.b	#$20,d0			; were C pressed?
		beq.s	Cont_Leap		; if yes, branch
JumpToSL_End:
		jmp	SL_End
Cont_Leap:
		tst.b	(v_leap).w		; was jumpdash flag set?
		bne.w	SL_End			; if yes, branch
		move.b	#1,(v_leap).w	; if not, set jumpdash flag
		move.b	#$24,obAnim(a0)		; show leap animation
		bclr	#4,obStatus(a0)		; clear double jump flag
		move.w	#$800,d0		; set normal jumpdash speed
		move.w	#$400,obVelY(a0)		; set normal jumpdash speed
		tst.b	(v_shoes).w		; do you have speed shoes?
		beq.s	SL_ChkUW		; if not, branch
		move.w	#$C00,d0		; set speed shoes jumpdash speed
		move.w	#$350,obVelY(a0)		; set normal jumpdash speed

SL_ChkUW:
		btst	#6,obStatus(a0)		; is Amy underwater?
		beq.s	SL_ChkDirection		; if not, branch
		move.w	#$400,d0		; set underwater jumpdash speed
		move.w	#$200,obVelY(a0)		; set normal jumpdash speed

SL_ChkDirection:
		btst	#0,obStatus(a0)		; is Amy facing left?
		beq.s	SL_Move			; if yes, branch
		neg.w	d0			; if not, negate d0 (for jumping to the right)

SL_Move:
		btst	#6,obStatus(a0)		; is player underwater?
		beq.s	IfNotUnderwater		; if not, branch
		move.w	d0,obVelX(a0)		; move Amy forward (x-velocity)
		move.w	#$200,obVelY(a0)		; move Amy forward (y-velocity)
 		jmp	SL_Animate
IfNotUnderwater:
		move.w	d0,obVelX(a0)		; move Amy forward (x-velocity)
		move.w	#$400,obVelY(a0)		; move Amy forward (y-velocity)

SL_Animate:
		move.b	#$24,obAnim(a0)		; show leap animation


SL_End:
		rts				; return
; End of function Amy_Leap

;; ---------------------------------------------------------------------------
; Subroutine allowing Amy to attack
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Amy_Hammer:
		tst.b	(v_hammer).w		; was jumpdash flag set?
		beq.w	NotActive		; if not, branch
		cmpi.b	#$25,obAnim(a0)		; are we still in the hammer animation?
		beq.s	Hammer_Hearts		; if yes, branch
		cmpi.b	#$1F,obAnim(a0)		; are we still in the hammer animation?
		beq.s	Hammer_Hearts		; if not, branch
Undoflag:
		bclr	#1,(f_lockctrl).w		; unlock controls
		clr.b	(v_hammer).w		; clear flag
		rts

NotActive:
		btst	#1,(v_jpadhold2).w		; is Down button pressed?
		bne.w	Hammer_End		; if not, return
		btst	#6,(v_jpadpress2).w		; is A button pressed?
		beq.w	Hammer_End		; if not branch
		move.b	#1,(v_hammer).w		; if not, set jumpdash flag
		move.b	#$25,obAnim(a0)		; show hammer animation
		sfx		sfx_Piko
		clr.w	(v_jpadhold2).w		; reset control input
Hammer_Hearts:
		bset	#1,(f_lockctrl).w		; lock controls
		move.w	obInertia(a0),d0		; get inertia
		beq.s	@NoSpeed; don't change speed when it's already at zero
		move.w	d0,d1	; copy it to d1
		asr.w	#3,d1	; arithmetically bit-shift to the right by 3
		sub.w	d1,d0	; sub result from original

		move.w	d0,d1	; copy result to d1
		btst	#0,obStatus(a0)		; is Amy facing right?
		beq.s	@FacingRight		; if yes, branch
		neg.w	d1	; otherwise, make result positive
@FacingRight:
		cmpi.w	#$20,d1 ; is speed above $20?
		bgt.s	@SetSpeed		 ; if yes, branch
		move.w	#$20,d0 ; otherwise reset it to $20
@SetSpeed:
		move.w	d0,obInertia(a0)		; copy result to new inertia
@NoSpeed:

		;cmpi.b	#$25,obAnim(a0)		; are we still in the hammer animation?
		;beq.s	@StillActive		; if yes, branch
		cmpi.b	#$1F,obAnim(a0)		; are we still in the hammer animation?
		bne.w	Hammer_End		; if not, branch
@StillActive:
		tst.b	obTimeFrame(a0) ; is frame duration at 0? (is a new frame about to be shown?)
		bne.w	Hammer_End		; if not, branch

		jsr	FindFreeObj		; find free object location
		bne.w	Hammer_End		; skip if none was found
		move.b	#id_AmyHearts,(a1)		 ; set it to hearts object

		move.w	obX(a0),obX(a1)		 ; copy Amy's x-pos
		move.w	obY(a0),obY(a1)		; copy Amy's y-pos

		lea	(H_Deviation).l,a2	; load position deviation data into a2
		moveq	#0,d0	; clear d0	
		move.b	obFrame(a0),d0		; load current frame into d0
		subi.b	#$60,d0 ; substract $59 from it so the first frame of the animation is at 0 now
		lsl.b	#2,d0	; bit-shift by two to the left (four bytes per entry in H_Deviation)
		adda.w	d0,a2	; get correct offset for current frame

		move.w	(a2)+,d1; get x-deviation (and increase pointer to y-deviation)
		btst	#0,obStatus(a0)		; is Amy facing leftwards?
		beq.s	@SetXPos; if not, branch
		neg.w	d1	; if yes, negate x-deviation
@SetXPos:
		add.w	d1,obX(a1); add deviation to x-po

		move.w	(a2),d1 ; get y-deviation
		add.w	d1,obY(a1)		 ; add deviation to y-pos
Hammer_End:
	rts
; End of function Amy_Hammer
; ---------------------------------------------------------------------------
H_Deviation:	;	   x       y
		dc.w	-$0004,  -$001A	; frame 1
		dc.w	$000A,   -$0016	; frame 2
		dc.w	$0014,   -$000A	; frame 3
		dc.w	$0018,   $0002	; frame 4
		even
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine allowing Amy to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Amy_Jump:				; XREF: Amy_MdNormal; Amy_MdRoll
		cmp.b 	#1,(v_highJump).w	; check if bit 2 of the Air Attack flag is set
		beq.s 	HighJump_Ani		; branch if it is
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnBC,d0		; is B or C pressed?
		beq.w	locreta_1348E	; if not, branch
HighJump_Ani:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	locreta_1348E
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	locA_1341C
		move.w	#$380,d2

locA_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)	; make Amy jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)	; make Amy jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	$38(a0)
		jsr		ResetHeight
		btst	#2,obStatus(a0)
		bne.s	locA_13490
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		cmp.b 	#1,(v_highJump).w	; check if bit 2 of the Air Attack flag is set
		bne.s 	LeapJump_Ani		; branch if it isn't
		move.b	#$23,obAnim(a0)	; use "jumping"	animation
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)
		sfx		sfx_DoubleJump		; Heyy! Finally getting a use~
		jmp	locreta_1348E
LeapJump_Ani:
		cmp.b 	#1,(v_leap).w	; check if bit 2 of the Air Attack flag is set
		bne.s 	NormalJump_Ani		; branch if it isn't
		move.b	#$24,obAnim(a0)	; use "jumping"	animation
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)
		sfx		sfx_DoubleJump		; Heyy! Finally getting a use~
		jmp	locreta_1348E
NormalJump_Ani:
		move.b	#id_Spring,obAnim(a0)	; use "jumping"	animation
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)
		sfx		sfx_Jump

locreta_1348E:
		rts
; ===========================================================================

locA_13490:
		bset	#4,obStatus(a0)
		rts
; End of function Amy_Jump

; ---------------------------------------------------------------------------
; Subroutine for Amy's hammer spin animation
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Amy_HammerSpin:
		cmpi.b #$20,obAnim(a0)		; is hammer spin flag already set?
		beq.s	HammerSpin_Cont		; if yes, branch
		tst.b	(v_springshoes).w	; is Amy wearing spring shoes?
		bne.w	HS_End			; if so, return
		btst	#1,(v_jpadhold2).w	; is Down button held?
		beq.s	HS_End			; if not, return
		btst	#6,(v_jpadpress2).w	; is A pressed?
		beq.s	HS_End			; if not, branch

		move.b	#1,(v_hammerspin).w	; set hammer spin flag
		move.b	#$20,obAnim(a0)		; show hammer spin animation
		sfx		sfx_InstaAttack

		clr.w	obVelX(a0)			; clear X-velocity
		tst.w	obVelY(a0)			; is Amy moving upwards?
		bpl.s	HammerSpin_Cont		; if not, branch
		clr.w	obVelY(a0)			; clear y-velocity to move Amy directly down

HammerSpin_Cont:
		cmpi.b	#$20,obAnim(a0)		; are we still in the hammer spin animation?
		bne.s	HS_End			; if not, branch
		tst.b	obTimeFrame(a0)			; is frame duration at 0? (is a new frame about to be shown?)
		bne.s	HS_End			; if not, branch

		jsr	(FindFreeObj).l		; find free object location
		bne.w	HS_End			; skip if none was found
		move.b  #id_AmyHearts,(a1)		; set it to hearts object

		move.w	obX(a0),obX(a1)		; copy Amy's x-pos
		move.w	obY(a0),obY(a1)		; copy Amy's y-pos

		lea	(HS_Deviation).l,a2	; load position deviation data into a2
		moveq	#0,d0			; clear d0
		move.b	obFrame(a0),d0		; load current frame into d0
		subi.b	#$68,d0			; substract $50 (???) from it so the first frame of the animation is at 0 now
		lsl.b	#2,d0			; bit-shift by two to the left (four bytes per entry in HS_Deviation)
		adda.w	d0,a2			; get correct offset for current frame

		move.w	(a2)+,d1		; get x-deviation (and increase pointer to y-deviation)
		btst	#0,obStatus(a0)		; is Amy facing leftwards?
		beq.s	@SetXPos		; if not, branch
		neg.w	d1			; if yes, negate x-deviation
	@SetXPos:
		add.w	d1,obX(a1)		; add deviation to x-pos

		move.w	(a2),d1			; get y-deviation
		add.w	d1,obY(a1)		; add deviation to y-pos

HS_End:
		rts

; ---------------------------------------------------------------------------
HS_Deviation:	;	   x       y
		dc.w	 $0010,  $0000	; frame 1
		dc.w	$0000,   $0000	; frame 2
		dc.w	-$0010,   $0000	; frame 3
		dc.w	-$001A,  $0000	; frame 4
		dc.w	$0000,  $0000	; frame 5
		dc.w	$001A,   $0000	; frame 6
		even
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine for Amy's landing animation
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_JumpLand:
		btst	#6,obStatus(a0)		; is Amy underwater?
		beq.s	Normal_JumpLand		; if not, branch
		cmpi.b	#$23,obAnim(a0)		; is Amy in the jumping animation?
		beq.s	UD_Land		; if not, return
		cmpi.b	#id_Spring,obAnim(a0)		; is Amy in the jumping animation?
		bne.b	Normal_JumpLand		; if not, return
UD_Land:
		cmpi.w	#-$120,obVelY(a0)		; has Amy reached the peak of his jump?
		blt.b	Normal_JumpLand		; if not, return
		move.b	#id_Fall,obAnim(a0)		; use falling animation

Amy_JumpLand_Return:
		rts

Normal_JumpLand:
		cmpi.b	#$23,obAnim(a0)		; is Amy in the jumping animation?
		beq.s	Normal_Land		; if not, return
		cmpi.b	#id_Spring,obAnim(a0)		; is Amy in the jumping animation?
		bne.b	Amy_JumpLand_Return2	; if not, return
Normal_Land:
		cmpi.w	#-$100,obVelY(a0)		; has Amy reached the peak of his jump?
		blt.b	Amy_JumpLand_Return2	; if not, return
		move.b	#id_Fall,obAnim(a0)		; use falling animation

Amy_JumpLand_Return2:
		rts
; End of function Amy_JumpLand

; ---------------------------------------------------------------------------
; Subroutine to	activate Amy's Pratfall
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_Pratfall:
		tst.b	obDoubleJump_property(a0)		; was jumpdash flag set?
		beq.w	Amy_Pratfall_Activate			; if not, branch
		;cmpi.b	#$2A,anim(a0)	; are we still in the hammer animation?
		;beq.s	Amy_NoPratfall		; if yes, branch
		cmpi.b	#$29,obAnim(a0)	; are we still in the hammer animation?
		beq.s	Amy_NoPratfall		; if yes, branch
		cmpi.b	#$28,obAnim(a0)	; are we still in the hammer animation?
		beq.s	Amy_NoPratfall		; if yes, branch
		bclr	#1,(f_lockctrl).w	; unlock controls
		clr.b	obDoubleJump_property(a0)		; if not, set jumpdash flag
Amy_NoPratfall:
		rts

Amy_Pratfall_Activate:
		cmpi.b	#$24,obAnim(a0)		; is Amy in the jumping animation?
		bne.s	Amy_Pratfall_End		; if not, return

		btst	#6,(v_jpadpress2).w	;is A being pressed?
		beq.b	Amy_Pratfall_End	; if not, return
		move.b	#$28,obAnim(a0)		; change animation to X
		move.b	#1,obDoubleJump_property(a0)		; if not, set jumpdash flag
		move.b	#6,(v_dust+obRoutine).w
		move.b	#$15,(v_dust+obFrame).w
		bset	#1,(f_lockctrl).w	; lock controls
		clr.b	(v_jpadpress2).w
		clr.b	(v_jpadhold2).w
Amy_Pratfall_End:
		rts


; ---------------------------------------------------------------------------
; Subroutine to	activate Amy's Jump Attack
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Amy_JumpAttack:
		cmpi.b	#$22,obAnim(a0)		; is Amy in the jumping animation?
		beq.s	JumpAttack_Hearts		; if yes, return
		tst.b	(v_springshoes).w	; is Amy wearing spring shoes?
		bne.w	Amy_JumpAttack_Return			; if so, return
		cmpi.b	#$24,obAnim(a0)		; is Amy in the jumping animation?
		beq.w	Amy_JumpAttack_return		; if not, return
		btst	#1,(v_jpadhold2).w	; is Down button pressed?
		bne.w	Amy_JumpAttack_return	; if yes, return
		btst	#6,(v_jpadpress2).w	; is A button pressed?
		beq.w	Amy_JumpAttack_return	; if not, return
		tst.b	obDoubleJump(a0)		; was jumpdash flag set?
		bne.w	Amy_JumpAttack_Return		; if yes, branch
		move.b 	#1,obDoubleJump(a0)	; set jumpattack flag
		move.b	#$22,obAnim(a0)		; change animation to X
		sfx		sfx_InstaAttack

JumpAttack_Hearts:
		cmpi.b	#$22,obAnim(a0)		; are we still in the hammer spin animation?
		bne.s	Amy_JumpAttack_Return			; if not, branch
		;cmpi.b	#$73,obFrame(a0)		; are we still in the hammer spin animation?
		;bne.s	HS_End			; if not, branch
		tst.b	obTimeFrame(a0)			; is frame duration at 0? (is a new frame about to be shown?)
		bne.w	Amy_JumpAttack_Return			; if not, branch

		jsr	(FindFreeObj).l		; find free object location
		bne.w	Amy_JumpAttack_Return			; skip if none was found
		move.b  #id_AmyHearts,(a1)		; set it to hearts object

		move.w	obX(a0),obX(a1)		; copy Amy's x-pos
		move.w	obY(a0),obY(a1)		; copy Amy's y-pos

		lea	(JA_Deviation).l,a2	; load position deviation data into a2
		moveq	#0,d0			; clear d0
		move.b	obFrame(a0),d0		; load current frame into d0
		subi.b	#$73,d0			; substract $50 (???) from it so the first frame of the animation is at 0 now
		lsl.b	#2,d0			; bit-shift by two to the left (four bytes per entry in JA_Deviation)
		adda.w	d0,a2			; get correct offset for current frame

		move.w	(a2)+,d1		; get x-deviation (and increase pointer to y-deviation)
		btst	#0,obStatus(a0)		; is Amy facing leftwards?
		beq.s	@SetXPos		; if not, branch
		neg.w	d1			; if yes, negate x-deviation
	@SetXPos:
		add.w	d1,obX(a1)		; add deviation to x-pos

		move.w	(a2),d1			; get y-deviation
		add.w	d1,obY(a1)		; add deviation to y-pos



Amy_JumpAttack_Return:
		rts
; End of function Amy_JumpAttack
; ---------------------------------------------------
JA_Deviation:	;	   x       y
		dc.w	-$0002,  -$001C	; frame 1
		dc.w	$000C,   -$0018	; frame 2
		dc.w	$0018,   -$000C	; frame 3
		dc.w	$001C,  $0000	; frame 4
		dc.w	$0018,  $000C	; frame 5
		dc.w	$000C,   $0018	; frame 6

		dc.w	 -$0002,  $001C	; frame 7
		even
; ---------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine to	reset Amy's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Amy_ResetOnFloor:			; XREF: PlatformObject; et al
		clr.b	(v_hammerspin).w	; clear jumpdash flag
		clr.b	(v_highJump).w	; clear jumpdash flag
		clr.b	obDoubleJump(a0)
		clr.b	(v_leap).w	; clear leap flag
		btst	#4,obStatus(a0)
		beq.s	locA_137AE
		nop
		nop
		nop

locA_137AE:
		bclr	#5,obStatus(a0)
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
Amy_ResetOnFloor_Part2:
		btst	#2,obStatus(a0)
		beq.s	locA_137E4
		bclr	#2,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		tst.b	obDoubleJump_property(a0)		; was jumpdash flag set?
		beq.w	Amy_ResetOnFloor_Part2_5		; if not, branch
		move.b	#$29,obAnim(a0)	; use pratfall animation
		subq.w	#5,obY(a0)	; move Amy up 5 pixels so the increased height doesn't push him into the ground
		jmp	locA_137E4
Amy_ResetOnFloor_Part2_5:
		move.b	#0,obAnim(a0)	; use running/walking animation
		subq.w	#5,obY(a0)

locA_137E4:
		move.b	#0,obJumping(a0)
		move.w	#0,(v_itembonus).w
		rts
; End of function Amy_ResetOnFloor

; -------------------------------------------------------------------------
; Subroutine to stop Player, bounce him up and to give him the ability to; Jumpdash again when ;he has performed a Jumpdash;
;-------------------------------------------------------------------------

BounceJH:
		tst.b	obDoubleJump(a0)	; was jumpdash flag set?
		beq.s	BounceJH_End	; if not, branch
		clr.b	obDoubleJump(a0)	; if yes, clear jumpdash flag (allow Player to jumpdash again)
		clr.w	obVelX(a0)		; clear X-velocity (stop Player)
		move.w	#-$5F0,obVelY(a0)	; use -$5F0 for Y-velocity (move Player upwards)
		btst	#6,obStatus(a0)	; is Player underwater?
		beq.s	BounceJH_Shoes	; if not, branch
		move.w	#-$320,obVelY(a0)	; use only -$320 for Y-velocity (move Player upwards)

BounceJH_Shoes:
		tst.b	(v_shoes).w	; does Player has speed shoes?
		beq.s	BounceJH_End	; if not, branch
		move.w	#-$620,obVelY(a0)	; use -$620 for Y-velocity (move Player upwards)
BounceJH_End:
		rts			; return;

BounceJD:
		tst.b	(v_hammerspin).w	; was jumpdash flag set?
		beq.s	BounceJD_End	; if not, branch
		clr.b	(v_hammerspin).w	; if yes, clear jumpdash flag (allow Player to jumpdash again)
		clr.w	obVelX(a0)		; clear X-velocity (stop Player)
		move.w	#-$5F0,obVelY(a0)	; use -$5F0 for Y-velocity (move Player upwards)
		btst	#6,obStatus(a0)	; is Player underwater?
		beq.s	BounceJD_Shoes	; if not, branch
		move.w	#-$320,obVelY(a0)	; use only -$320 for Y-velocity (move Player upwards)

BounceJD_Shoes:
		tst.b	(v_shoes).w	; does Player has speed shoes?
		beq.s	BounceJD_End	; if not, branch
		move.w	#-$620,obVelY(a0)	; use -$620 for Y-velocity (move Player upwards)

BounceJD_End:
		rts			; return;
;End of function BounceJD

; ---------------------------------------------------------------------------
; Subroutine to	animate	Amy's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Amy_Animate:
		lea	(Ani_Amy).l,a1
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
		move.b	obAngle(a0),d0	; get Amy's angle
		bmi.s	@cont
		beq.s	@cont
		subq.b	#1,d0

	@cont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Amy mirrored horizontally?
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
		btst	#5,obStatus(a0)	; is Amy pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Amy's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
;		lea	(AmyAni_MachSpeed).l,a1
;		cmpi.w	#$A00,d2
;		bcc.s	@running
;
		lea	(AmyAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Amy at running speed?
		bcc.s	@running	; if yes, branch

		lea	(AmyAni_Walk).l,a1 ; use walking animation
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0

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
		move.w	obInertia(a0),d2 ; get Amy's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(AmyAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Amy moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(AmyAni_Roll).l,a1 ; use slower	animation

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
		move.w	obInertia(a0),d2 ; get Amy's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(AmyAni_Push).l,a1
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
		addi.b	#frS_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; locA_1B54E:
@tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	locA_1B566
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	locA_1B572
; ===========================================================================

locA_1B566:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

locA_1B572:
		divu.w	#$16,d0
		addi.b	#frS_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; End of function Amy_Animate

; ---------------------------------------------------------------------------
; Amy	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Amy_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadAmyMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_Amy).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperAmy).l,a2
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
		move.l	#Art_Amy,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperAmy,d6

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
; End of function Amy_LoadGfx

LoadAmyMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_Amy,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Amy,(v_player+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperAmy,(v_player+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperAmy,(v_player+obMap).w
	@skip:
		rts

; ---------------------------------------------------------------------------
; Object 99 - Amy's hearts
; ---------------------------------------------------------------------------
AmyHearts:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	AmyHearts_Index(pc,d0),d0
		jmp	AmyHearts_Index(pc,d0.w)
; ===========================================================================
AmyHearts_Index:
		dc.w	AmyHearts_Init-AmyHearts_Index
		dc.w	AmyHearts_Animate-AmyHearts_Index
; ===========================================================================

AmyHearts_Init:
		addq.b	#2,obRoutine(a0)		; set routine to AmyHearts_Animate
		move.l	#Map_Hearts,obMap(a0)	; set mappings
		move.b	#4,obRender(a0)		; set render flags
		move.w  #vramHearts,obGfx(a0)	; set tile offset	; fixed my math lol
		move.w	#$100,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.b	#4,obHeight(a0)

AmyHearts_Animate:
		cmpi.b	#$4,obAniFrame(a0)
		beq.w	AmyHearts_Delete
		move.w	#-$100,obVelY(a0)

		jsr	SpeedToPos
		lea	(Ani_Heart).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite


AmyHearts_Delete:
		jmp	DeleteObject
; ===========================================================================


Ani_Heart:
	dc.w @heart-Ani_Heart

@heart:	dc.b 3, 1, 2, 3, 0, $FD, 0
	even