KnucklesGlideState: equ $3D

KnucklesPlayer:
		tst.w	(v_debuguse).w
		beq.s	Knuckles_Normal
		jmp	DebugMode
; ---------------------------------------------------------------------------

Knuckles_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Knuckles_Index(pc,d0.w),d1
		jmp	Knuckles_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Knuckles_Index:
		dc.w Knuckles_Init-Knuckles_Index		; 0
		dc.w Knuckles_Control-Knuckles_Index	; 2
		dc.w Player_Hurt-Knuckles_Index		; 4
		dc.w Player_Death-Knuckles_Index		; 6
		dc.w Player_ResetLevel-Knuckles_Index	; 8
		dc.w Player_Drowned-Knuckles_Index	; A
; ---------------------------------------------------------------------------

Knuckles_Init:
		move.b	#$C,(v_top_solid_bit).w
		move.b	#$D,(v_lrb_solid_bit).w
		addq.b	#2,obRoutine(a0)
		jsr     ResetHeight
		move.l	#Map_Knuckles,mappings(a0)	  ; Map_Knuckles
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#4,render_flags(a0)
		move.w	#$600,(v_plrspeedmax).w
		move.w	#$C,(v_plrspeedacc).w
		move.w	#$80,(v_plrspeeddec).w

Knuckles_Control:
		tst.w	(f_debugmode).w
		beq.s	Knuckles_Control_Part2
		btst	#bitB,(v_jpadpress1).w
		beq.s	Knuckles_Control_Part2
		move.w	#1,(v_debuguse).w
		clr.b	(f_lockctrl).w
		rts
; ---------------------------------------------------------------------------

Knuckles_Control_Part2:
		tst.b	(f_lockctrl).w
		bne.s	Knuckles_Control_Part3
		move.w	(v_jpadhold1).w,(v_jpadhold2).w

Knuckles_Control_Part3:
		btst	#0,(f_lockmulti).w
		beq.s	loc_31543E
		move.b	#0,KnucklesGlideState(a0)
		bra.s	loc_315450
; ---------------------------------------------------------------------------

loc_31543E:
		moveq	#0,d0
		move.b	status(a0),d0
		and.w	#6,d0
		move.w	Knuckles_Modes(pc,d0.w),d1
		jsr	Knuckles_Modes(pc,d1.w)

loc_315450:
		jsr     Player_Display
		jsr     Player_RecordPosition
		jsr     Player_Water
		jsr		Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	@cont
		tst.b	obAnim(a0)
		bne.s	@cont
		move.b	obNextAni(a0),obAnim(a0)

	@cont:
		bsr.w	Knuckles_Animate
		tst.b	(f_lockmulti).w
		bmi.s	@nocontrol2
		jsr	ReactToItem

	@nocontrol2:
		bra.w	Knuckles_LoadGfx
; ---------------------------------------------------------------------------
Knuckles_Modes:
		dc.w Knuckles_MdNormal-Knuckles_Modes	; 0 - Not airborne or rolling
		dc.w Knuckles_MdAir-Knuckles_Modes		; 2 - Airborne, but NOT rolling
		dc.w Knuckles_MdRoll-Knuckles_Modes		; 4 - Rolling, but NOT airborne
		dc.w Knuckles_MdJump-Knuckles_Modes		; 6 - Airborne AND rolling, thus probably jumping
; ---------------------------------------------------------------------------

; =============== S U B	R O U T	I N E =======================================

Knuckles_MdNormal:
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
; End of function Knuckles_MdNormal


; =============== S U B	R O U T	I N E =======================================


Knuckles_MdAir:
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
		tst.b	KnucklesGlideState(a0)
		bne.s	Knuckles_MdAir_Gliding
		jsr		Player_JumpHeight
		jsr		Player_JumpDirection
		jsr		Player_LevelBound
		jsr		ObjectFall
		btst	#6,obStatus(a0)
		beq.s	@done
		sub.w	#$28,obVelY(a0)

	@done:
		jsr		Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ---------------------------------------------------------------------------

Knuckles_MdAir_Gliding:
		bsr.w	Knuckles_GlideSpeedControl
		jsr		Player_LevelBound
		jsr		SpeedToPos		  ; AKA	SpeedToPos in Sonic 1
		bsr.w	Knuckles_GlideControl

return_3156B8:
		rts
; End of function Knuckles_MdAir


; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideControl:

; FUNCTION CHUNK AT 00315C40 SIZE 0000003C BYTES

		move.b	KnucklesGlideState(a0),d0
		beq.s	return_3156B8
		cmp.b	#2,d0
		beq.w	Knuckles_FallingFromGlide
		cmp.b	#3,d0
		beq.w	Knuckles_Sliding
		cmp.b	#4,d0
		beq.w	Knuckles_Climbing_Wall
		cmp.b	#5,d0
		beq.w	Knuckles_Climbing_Up

Knuckles_NormalGlide:
		move.b	#$A,obHeight(a0)
		move.b	#$A,obWidth(a0)
		bsr.w	Knuckles_DoLevelCollision2
		btst	#5,obDoubleJump(a0)
		bne.w	Knuckles_BeginClimb
		jsr		ResetHeight
		btst	#1,obDoubleJump(a0)
		beq.s	Knuckles_BeginSlide
		move.b	(v_jpadhold2).w,d0
		and.b	#btnABC,d0
		bne.s	loc_31574C
		move.b	#2,KnucklesGlideState(a0)
		move.b	#idK_FallFromGlide,obAnim(a0)
		bclr	#0,obStatus(a0)
		tst.w	obVelX(a0)
		bpl.s	loc_315736
		bset	#0,obStatus(a0)

loc_315736:
		asr	obVelX(a0)
		asr	obVelX(a0)
		jsr		(ResetHeight).l
		rts
; ---------------------------------------------------------------------------

loc_31574C:
		bra.w	sub_315C7C
; ---------------------------------------------------------------------------

Knuckles_BeginSlide:
		bclr	#0,obStatus(a0)
		tst.w	obVelX(a0)
		bpl.s	loc_315762
		bset	#0,obStatus(a0)

loc_315762:
		move.b	obAngle(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_315780
		move.w	obInertia(a0),obVelX(a0)
		move.w	#0,obVelY(a0)
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:
		move.b	#3,KnucklesGlideState(a0)
		move.b	#frK_GlideS1,obFrame(a0)
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#6,(v_dust+obRoutine).w
		move.b	#$15,(v_dust+obFrame).w

return_3157AC:
		rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:
		tst.b	obDoubleJump_property(a0)
		bmi.w	loc_31587A
		move.b	(v_lrb_solid_bit).w,d5
		move.b	obDelayAni(a0),d0
		add.b	#$40,d0
		bpl.s	loc_3157D8
		bset	#0,obStatus(a0)
		jsr	loc_14FD6
		or.w	d0,d1
		bne.s	Knuckles_FallFromGlide
		addq.w	#1,obX(a0)
		bra.s	loc_3157E8
; ---------------------------------------------------------------------------

loc_3157D8:
		bclr	#0,obStatus(a0)
		jsr		sub_14E50
		or.w	d0,d1
		bne.w	loc_31586A

loc_3157E8:
		jsr		ResetHeight
		tst.b	(v_super).w
		beq.s	loc_315804
		cmp.w	#$480,obInertia(a0)
		bcs.s	loc_315804
		nop

loc_315804:
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.b	#4,KnucklesGlideState(a0)
		move.b	#frK_Climb1,obFrame(a0)
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#3,obDelayAni(a0)
		move.w	obX(a0),obChild_dx(a0)
		sfx		sfx_Grab
		rts
; ---------------------------------------------------------------------------

Knuckles_FallFromGlide:
		move.w	obX(a0),d3
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		subq.w	#1,d3

loc_31584A:
		move.w	obY(a0),d2
		sub.w	#$B,d2
		jsr     ObjFloorDist2
		tst.w	d1
		bmi.s	loc_31587A
		cmp.w	#$C,d1
		bcc.s	loc_31587A
		add.w	d1,obY(a0)
		bra.w	loc_3157E8
; ---------------------------------------------------------------------------

loc_31586A:
		move.w	obX(a0),d3
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		addq.w	#1,d3
		bra.s	loc_31584A
; ---------------------------------------------------------------------------

loc_31587A:
		move.b	#2,KnucklesGlideState(a0)
		move.b	#idK_FallFromGlide,obAnim(a0)
		jsr		ResetHeight
		bset	#1,obDoubleJump(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:
		jsr		Player_JumpDirection
		add.w	#$38,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	loc_3158B2
		sub.w	#$28,obVelY(a0)

loc_3158B2:
		bsr.w	Knuckles_DoLevelCollision2
		btst	#1,obDoubleJump(a0)
		bne.s	return_315900
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.b	obHeight(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,obY(a0)
		move.b	obAngle(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_3158F0
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_3158F0:
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,move_lock(a0)
		move.b	#idK_HardFall,obAnim(a0)
		sfx		sfx_GlideLand

return_315900:
		rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:
		move.b	(v_jpadhold2).w,d0
		and.b	#btnABC,d0
		beq.s	loc_315926
		tst.w	obVelX(a0)
		bpl.s	loc_31591E
		add.w	#$20,obVelX(a0)
		bmi.s	loc_31591C
		bra.s	loc_315926
; ---------------------------------------------------------------------------

loc_31591C:
		bra.s	loc_315958
; ---------------------------------------------------------------------------

loc_31591E:
		sub.w	#$20,obVelX(a0)
		bpl.s	loc_315958

loc_315926:
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.b	obHeight(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,obY(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,move_lock(a0)
		move.b	#idK_GetUp,obAnim(a0)
		rts
; ---------------------------------------------------------------------------

loc_315958:
		move.b	#$A,obHeight(a0)
		move.b	#$A,obWidth(a0)
		bsr.w	Knuckles_DoLevelCollision2
		jsr	(Player_HitFloor).l
		cmp.w	#$E,d1
		bge.s	loc_315988
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		jsr		ResetHeight
		; play slide sfx
		move.b	(v_framecount+1).w,d0
		andi.b	#7,d0
		bne.s	@done
		sfx		sfx_GroundSlide
	@done:
		rts
; ---------------------------------------------------------------------------

loc_315988:
		move.b	#2,KnucklesGlideState(a0)
		move.b	#idK_FallFromGlide,obAnim(a0)
		jsr		ResetHeight
		bset	#1,obDoubleJump(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:
		tst.b	obDoubleJump_property(a0)
		bmi.w	loc_315BAE
		move.w	obX(a0),d0
		cmp.w	obChild_dx(a0),d0
		bne.w	loc_315BAE
		btst	#3,obStatus(a0)
		bne.w	loc_315BAE
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		move.l	(v_colladdr1).w,(v_collindex).w
		cmp.b	#$D,(v_lrb_solid_bit).w
		beq.s	loc_3159F0
		move.l	(v_colladdr2).w,(v_collindex).w

loc_3159F0:
		move.b	(v_lrb_solid_bit).w,d5
		move.b	#$A,obHeight(a0)
		move.b	#$A,obWidth(a0)
		moveq	#0,d1
		btst	#0,(v_jpadhold2).w
		beq.w	loc_315A76
		move.w	obY(a0),d2
		sub.w	#$B,d2
		bsr.w	sub_315C22
		cmp.w	#4,d1
		bge.w	Knuckles_ClimbUp	  ; Climb onto the floor above you
		tst.w	d1
		bne.w	loc_315B30
		move.b	(v_lrb_solid_bit).w,d5
		move.w	obY(a0),d2
		subq.w	#8,d2
		move.w	obX(a0),d3
		bsr.w	sub_3192E6		  ; Doesn't exist in S2
		tst.w	d1
		bpl.s	loc_315A46
		sub.w	d1,obY(a0)
		moveq	#1,d1
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A46:
		subq.w	#1,obY(a0)
		tst.b	(v_super).w
		beq.s	loc_315A54
		subq.w	#1,obY(a0)

loc_315A54:
		moveq	#1,d1
		move.w	(v_limittop2).w,d0	; literally don't even know anymore.
		cmp.w	#-$100,d0
		beq.w	loc_315B04
		add.w	#$10,d0
		cmp.w	obY(a0),d0
		ble.w	loc_315B04
		move.w	d0,obY(a0)
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A76:
		btst	#1,(v_jpadhold2).w
		beq.w	loc_315B04
		cmp.b	#frK_Climb7,obFrame(a0)
		bne.s	loc_315AA2
		move.b	#frK_Climb1,obFrame(a0)
		addq.w	#3,obY(a0)
		subq.w	#3,obX(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_315AA2
		addq.w	#6,obX(a0)

loc_315AA2:
		move.w	obY(a0),d2
		add.w	#$B,d2
		bsr.w	sub_315C22
		tst.w	d1
		bne.w	loc_315BAE
		move.b	(v_top_solid_bit).w,d5
		move.w	obY(a0),d2
		add.w	#9,d2
		move.w	obX(a0),d3
		bsr.w	sub_318FF6
		tst.w	d1
		bpl.s	loc_315AF4

loc_16D6E:			
		add.w	d1,obY(a0)
		move.b	(v_anglebuffer).w,obAngle(a0)
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		tst.b   (v_victory).w ; Has the victory animation flag been set?
		beq.s   @normalJump ; If not, branch
		move.b  #id_Victory,obAnim(a0) ; Play the victory animation
		bra.s   @cont ; Continue
@normalJump:
		move.b    #id_Wait,obAnim(a0)    ; use "standing" animation
@cont:
		rts
; ---------------------------------------------------------------------------

loc_315AF4:
		addq.w	#1,obY(a0)
		tst.b	(v_super).w
		beq.s	loc_315B02
		addq.w	#1,obY(a0)

loc_315B02:
		moveq	#-1,d1

loc_315B04:
	    move.b  (v_jpadhold2).w,d0
        andi.b  #3,d0
        bne.s   loc_16E34
        move.b  (v_top_solid_bit).w,d5
        move.w  obY(a0),d2
        addi.w  #9,d2
        move.w  obX(a0),d3
        bsr.w   sub_318FF6
        tst.w   d1
        bmi.w   loc_16D6E

loc_16E34:	
		tst.w	d1
		beq.s	loc_315B30
		subq.b	#1,obDelayAni(a0)
		bpl.s	loc_315B30
		move.b	#3,obDelayAni(a0)
		add.b	obFrame(a0),d1
		btst    #0,(v_jpadhold2).w
        bne.s    ClimbUpAni
        btst    #1,(v_jpadhold2).w
        bne.s    ClimbDownAni
        bra.s    ResetAniClimb
		
ClimbUpAni:
        cmpi.b    #frK_Climb1,d1
        bcc.s    loc_16E52
        move.b    #frK_Climb6,d1
        bra.s    loc_16E5C
		
loc_16E52:
        cmpi.b    #frK_Climb6,d1
        bls.s    loc_16E5C
        move.b    #frK_Climb1,d1
        bra.s    loc_16E5C
		
ClimbDownAni:
        cmpi.b    #frK_ClimbD1,d1
        bcs.s    loc_16E52_D
        move.b    #frK_ClimbD1,d1
        bra.s    loc_16E5C
		
loc_16E52_D:
        move.b    #frK_ClimbD2,d1
        bra.s    loc_16E5C
		
ResetAniClimb:
        move.b    #frK_ClimbI,d1

loc_16E5C:
        move.b    d1,obFrame(a0)

loc_315B30:
		move.b	#$20,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)
		jsr		ResetHeight
		move.w	(v_jpadhold2).w,d0
		and.w	#btnABC,d0
		beq.s	return_315B94
		move.w	#$FC80,obVelY(a0)
		move.w	#$400,obVelX(a0)
		bchg	#0,obStatus(a0)
		bne.s	loc_315B6A
		neg.w	obVelX(a0)

loc_315B6A:
		bset	#1,obStatus(a0)
		move.b	#1,obJumping(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#2,obAnim(a0)
		bset	#2,obStatus(a0)
		move.b	#0,KnucklesGlideState(a0)

return_315B94:
		rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:
		move.b	#5,KnucklesGlideState(a0)		  ; Climb up to	the floor above	you
		cmp.b	#frK_Climb7,obFrame(a0)
		beq.s	return_315BAC
		move.b	#0,obDelayAni(a0)
		bsr.s	sub_315BDA

return_315BAC:
		rts
; ---------------------------------------------------------------------------

loc_315BAE:
		move.b	#2,KnucklesGlideState(a0)
		move.b	#$21,obAnim(a0)
		move.b	#frK_GlideF2,obFrame(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#1,obAniFrame(a0)
		jsr		ResetHeight
		rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================


sub_315BDA:
		moveq	#0,d0
		move.b	obDelayAni(a0),d0
		lea	Knuckles_ClimbUp_Frames(pc,d0.w),a1
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,d0
		ext.w	d0
		btst	#0,obStatus(a0)
		beq.s	loc_315BF6
		neg.w	d0

loc_315BF6:
		add.w	d0,obX(a0)
		move.b	(a1)+,d1
		ext.w	d1
		add.w	d1,obY(a0)
		move.b	(a1)+,obTimeFrame(a0)
		addq.b	#4,obDelayAni(a0)
		move.b	#0,obAniFrame(a0)
		rts
; End of function sub_315BDA

; ---------------------------------------------------------------------------
Knuckles_ClimbUp_Frames:
	dc.b frK_Climb7, $03
	dc.b $FD, $06
	dc.b frK_Climb8, $08
	dc.b $F6, $06
	dc.b frK_Climb9, $F8
	dc.b $F4, $06
	dc.b frK_Walk12, $08	; what?
	dc.b $FB, $06

; =============== S U B	R O U T	I N E =======================================


sub_315C22:

; FUNCTION CHUNK AT 00319208 SIZE 00000020 BYTES
; FUNCTION CHUNK AT 003193D2 SIZE 00000024 BYTES

		move.b	(v_lrb_solid_bit).w,d5
		btst	#0,obStatus(a0)
		bne.s	loc_315C36
		move.w	obX(a0),d3
		bra.w	loc_319208
; ---------------------------------------------------------------------------

loc_315C36:
		move.w	obX(a0),d3
		subq.w	#1,d3
		bra.w	loc_3193D2
; End of function sub_315C22

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl

Knuckles_Climbing_Up:
		tst.b	obTimeFrame(a0)
		bne.s	return_315C7A
		bsr.w	sub_315BDA
		cmp.b	#$10,obDelayAni(a0)
		bne.s	return_315C7A
		move.w	#0,obInertia(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		btst	#0,obStatus(a0)
		beq.s	loc_315C70
		subq.w	#1,obX(a0)

loc_315C70:
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.b	#5,obAnim(a0)

return_315C7A:
		rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================


sub_315C7C:
		cmpi.b	#$26,obAnim(a0)
		bne.s	@checkSetGlideAni
		bra.s	return_315CC0
	@checkSetGlideAni:
		move.b	#$20,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)
		cmpi.b	#$20,obAnim(a0)
		beq.s	@ChangeGlideFrames
		move.b	#$26,obAnim(a0)
		bra.s	return_315CC0

@ChangeGlideFrames:
		bclr	#5,obStatus(a0)
		bclr	#0,obStatus(a0)
		moveq	#0,d0
		move.b	obDelayAni(a0),d0
		add.b	#$10,d0
		lsr.w	#5,d0
		move.b	Knuckles_GlideFrames(pc,d0.w),d1
		move.b	d1,obFrame(a0)
		cmp.b	#frK_Mach11,d1
		bne.s	return_315CC0
		bset	#0,obStatus(a0)
		move.b	#frK_Glide1,obFrame(a0)

return_315CC0:
		rts
; End of function sub_315C7C

; ---------------------------------------------------------------------------
Knuckles_GlideFrames:	dc.b frK_Glide1,frK_Glide2,frK_Glide3,frK_Glide4,frK_Glide5,frK_Glide4,frK_Glide3,frK_Glide2; 0	; ...

; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideSpeedControl:
		cmp.b	#1,KnucklesGlideState(a0)
		bne.w	loc_315D88
		move.w	obInertia(a0),d0
		cmp.w	#$400,d0
		bcc.s	loc_315CE2
		addq.w	#8,d0
		bra.s	loc_315CFC
; ---------------------------------------------------------------------------

loc_315CE2:
		cmp.w	#$1800,d0
		bcc.s	loc_315CFC
		move.b	obDelayAni(a0),d1
		and.b	#$7F,d1
		bne.s	loc_315CFC
		addq.w	#4,d0
		tst.b	(v_super).w
		beq.s	loc_315CFC
		addq.w	#8,d0

loc_315CFC:
		move.w	d0,obInertia(a0)
		move.b	obDelayAni(a0),d0
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	loc_315D1C
		cmp.b	#$80,d0
		beq.s	loc_315D1C
		tst.b	d0
		bpl.s	loc_315D18
		neg.b	d0

loc_315D18:
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D1C:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	loc_315D30
		tst.b	d0
		beq.s	loc_315D30
		bmi.s	loc_315D2C
		neg.b	d0

loc_315D2C:
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D30:
		move.b	d0,d1
		and.b	#$7F,d1
		beq.s	loc_315D3A
		addq.b	#2,d0

loc_315D3A:
		move.b	d0,obDelayAni(a0)
		move.b	obDelayAni(a0),d0
		jsr	CalcSine
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		cmp.w	#$80,obVelY(a0)
		blt.s	loc_315D62
		sub.w	#$20,obVelY(a0)
		bra.s	loc_315D68
; ---------------------------------------------------------------------------

loc_315D62:
		add.w	#$20,obVelY(a0)

loc_315D68:

		add.w	#$10,d0
		cmp.w	obY(a0),d0
		ble.w	loc_315D88
		asr	obVelX(a0)
		asr	obInertia(a0)

loc_315D88:
		cmp.w	#$60,(v_lookshift).w
		beq.s	return_315D9A
		bcc.s	loc_315D96
		addq.w	#4,(v_lookshift).w

loc_315D96:
		subq.w	#2,(v_lookshift).w

return_315D9A:
		rts
; End of function Knuckles_GlideSpeedControl

; ---------------------------------------------------------------------------

Knuckles_MdRoll:
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
; ---------------------------------------------------------------------------

Knuckles_MdJump:
		cmpi.b	#id_Spring,obAnim(a0) ; Spring animation?
		bne.s	@cont	; if not, don't do this
		tst.b	obVelY(a0) ; is your Y velocity...
		blt.s	@cont ; less than 0? if so, don't do it
		move.b	#id_Fall,obAnim(a0) ; change animation to falling
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		jsr		Player_JumpHeight
		jsr		Player_JumpDirection
		jsr		Player_LevelBound
		jsr		ObjectFall
		btst	#6,obStatus(a0)
		beq.s	loc_315DE2
		sub.w	#$28,obVelY(a0)

loc_315DE2:
		jsr		Player_JumpAngle
		bsr.w	Player_Floor
		rts

; Knuckles_Move used to be here, but I kinda nuked it because it was near-identical to Player_Move. All balancing routines will jump back here, though!

; =============== S U B	R O U T	I N E =======================================

Knuckles_CheckGlide:
		tst.w	(f_demo).w		  ; Don't glide on demos
		bne.w	return_3165D2
		tst.b	(v_SpringShoes).w		  ; Don't glide on spring shoes, either.
		bne.w	return_3165D2
		tst.b	KnucklesGlideState(a0)
		bne.w	return_3165D2
		move.b	(v_jpadpress2).w,d0
		and.b	#btnABC,d0
		beq.w	return_3165D2
	@ChkGoSuper:
		tst.b	(f_timecount).w
		beq.s	Knuckles_BeginGlide
		tst.b	(v_super).w
		bne.s	Knuckles_BeginGlide
		cmpi.b	#6,(v_emeralds).w
		bne.s	Knuckles_BeginGlide
		cmpi.w	#50,(v_rings).w
		blo.s	Knuckles_BeginGlide
		jmp		SuperPlayer_Cont

Knuckles_BeginGlide:
		bclr	#2,obStatus(a0)
		move.b	#$A,obHeight(a0)
		move.b	#$A,obWidth(a0)
		bclr	#4,obStatus(a0)
		move.b	#1,KnucklesGlideState(a0)
		add.w	#$200,obVelY(a0)
		bpl.s	loc_31659E
		move.w	#0,obVelY(a0)

loc_31659E:
		moveq	#0,d1
		move.w	obVelX(a0),d0
		move.w	d0,d2
		add.w	#$100,d2
		cmpi.w	#$200,d2
		bls.s	@nomomentum
		move.w	d0,d2
		tst.w	d0
		bpl.s	loc_3165B4
		moveq	#-$80,d1
		neg.w	d0
		bra.s	loc_3165B4

	@nomomentum:
		move.w	#$100,d0
		move.w	d0,d2
		btst	#0,obStatus(a0)
		beq.s	loc_3165B4
		moveq	#-$80,d1
		neg.w	d2


loc_3165B4:
		move.w	d0,obInertia(a0)
		move.w	d2,obVelX(a0)
		move.b	d1,obDelayAni(a0)
		move.w	#0,obAngle(a0)
		move.b	#0,obDoubleJump(a0)
		bset	#1,obDoubleJump(a0)
		bsr.w	sub_315C7C

return_3165D2:
		rts

; =============== S U B	R O U T	I N E =======================================


Knuckles_DoLevelCollision2:
		move.l	(v_colladdr1).w,(v_collindex).w
		cmp.b	#$C,(v_top_solid_bit).w
		beq.s	loc_31694E
		move.l	(v_colladdr2).w,(v_collindex).w

loc_31694E:
		move.b	(v_lrb_solid_bit).w,d5
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	CalcAngle
		sub.b	#$20,d0
		and.b	#$C0,d0
		cmp.b	#$40,d0
		beq.w	Knuckles_HitLeftWall2
		cmp.b	#$80,d0
		beq.w	Knuckles_HitCeilingAndWalls2
		cmp.b	#$C0,d0
		beq.w	Knuckles_HitRightWall2
		jsr	Player_HitWall
		tst.w	d1
		bpl.s	loc_316998
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

loc_316998:
		jsr	(sub_14EB4).l
		tst.w	d1
		bpl.s	loc_3169B0
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

loc_3169B0:
		jsr	(Player_HitFloor).l
		tst.w	d1
		bpl.s	return_3169CC
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		bclr	#1,obDoubleJump(a0)

return_3169CC:
		rts
; ---------------------------------------------------------------------------

Knuckles_HitLeftWall2:
		jsr	Player_HitWall
		tst.w	d1
		bpl.s	Knuckles_HitCeilingAlt
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

Knuckles_HitCeilingAlt:
		jsr	(Player_DontRunOnWalls).l
		tst.w	d1
		bpl.s	Knuckles_HitFloor
		neg.w	d1
		cmp.w	#$14,d1
		bcc.s	loc_316A08
		add.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	return_316A06
		move.w	#0,obVelY(a0)

return_316A06:
		rts
; ---------------------------------------------------------------------------

loc_316A08:
		jsr	(sub_14EB4).l
		tst.w	d1
		bpl.s	return_316A20
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

return_316A20:
		rts
; ---------------------------------------------------------------------------

Knuckles_HitFloor:
		tst.w	obVelY(a0)
		bmi.s	return_316A44
		jsr	(Player_HitFloor).l
		tst.w	d1
		bpl.s	return_316A44
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		bclr	#1,obDoubleJump(a0)

return_316A44:
		rts
; ---------------------------------------------------------------------------

Knuckles_HitCeilingAndWalls2:
		jsr	Player_HitWall
		tst.w	d1
		bpl.s	loc_316A5E
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

loc_316A5E:
		jsr	(sub_14EB4).l
		tst.w	d1
		bpl.s	loc_316A76
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

loc_316A76:
		jsr	(Player_DontRunOnWalls).l
		tst.w	d1
		bpl.s	return_316A88
		sub.w	d1,obY(a0)
		move.w	#0,obVelY(a0)

return_316A88:
		rts
; ---------------------------------------------------------------------------

Knuckles_HitRightWall2:
		jsr	(sub_14EB4).l
		tst.w	d1
		bpl.s	loc_316AA2
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,obDoubleJump(a0)

loc_316AA2:
		jsr	(Player_DontRunOnWalls).l
		tst.w	d1
		bpl.s	loc_316ABC
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	return_316ABA
		move.w	#0,obVelY(a0)

return_316ABA:
		rts
; ---------------------------------------------------------------------------

loc_316ABC:
		tst.w	obVelY(a0)
		bmi.s	return_316ADE
		jsr		Player_HitFloor
		tst.w	d1
		bpl.s	return_316ADE
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		bclr	#1,obDoubleJump(a0)

return_316ADE:
		rts
; End of function Knuckles_DoLevelCollision2


; =============== S U B	R O U T	I N E =======================================


Knuckles_ResetOnFloor:
		tst.b	spindash_flag(a0)
		bne.s	Knuckles_ResetOnFloor_Part3
		move.b	#id_Walk,obAnim(a0)
; End of function Knuckles_ResetOnFloor


; =============== S U B	R O U T	I N E =======================================


Knuckles_ResetOnFloor_Part2:
		move.b	obHeight(a0),d0
		jsr	ResetHeight
		btst	#2,obStatus(a0)
		beq.s	Knuckles_ResetOnFloor_Part3
		bclr	#2,obStatus(a0)
		move.b	#0,obAnim(a0)
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,obY(a0)

Knuckles_ResetOnFloor_Part3:
		bclr	#1,obStatus(a0)
		bclr	#4,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#0,(v_flipangle).w
		move.b	#0,(v_flipsremaining).w
		move.b	#0,(v_flipspeed).w
		move.b	#0,obJumping(a0)
		move.w	#0,(v_itembonus).w
		move.w	#0,(v_scrolldelay).w
		move.b	#0,KnucklesGlideState(a0)
		cmp.b	#idK_Gliding,obAnim(a0)
		bcc.s	loc_316D5C
		cmp.b	#$14,obAnim(a0)
		bne.s	return_316D62

loc_316D5C:
		move.b	#0,obAnim(a0)

return_316D62:
		rts
; End of function Knuckles_ResetOnFloor_Part2

; =============== S U B	R O U T	I N E =======================================

Knuckles_Animate:
		lea	(KnucklesAniData).l,a1
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obNextAni(a0),d0
		beq.s	KAnim_Do
		move.b	d0,obNextAni(a0)
		move.b	#0,obAniFrame(a0)
		move.b	#0,obTimeFrame(a0)
		bclr	#5,obStatus(a0)

KAnim_Do:
		add.w	d0,d0
		add.w	(a1,d0.w),a1
		move.b	(a1),d0
		bmi.s	KAnim_WalkRun
		move.b	obStatus(a0),d1
		and.b	#1,d1
		and.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	KAnim_Delay
		move.b	d0,obTimeFrame(a0)

KAnim_Do2:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	obRender(a1,d1.w),d0
		cmp.b	#$FC,d0
		bcc.s	KAnim_End_FF

KAnim_Next:
		move.b	d0,obFrame(a0)
		addq.b	#1,obAniFrame(a0)

KAnim_Delay:
		rts
; ---------------------------------------------------------------------------

KAnim_End_FF:
		addq.b	#1,d0
		bne.s	KAnim_End_FE
		move.b	#0,obAniFrame(a0)
		move.b	obRender(a1),d0
		bra.s	KAnim_Next
; ---------------------------------------------------------------------------

KAnim_End_FE:
		addq.b	#1,d0
		bne.s	KAnim_End_FD
		move.b	obGfx(a1,d1.w),d0
		sub.b	d0,obAniFrame(a0)
		sub.b	d0,d1
		move.b	obRender(a1,d1.w),d0
		bra.s	KAnim_Next
; ---------------------------------------------------------------------------

KAnim_End_FD:
		addq.b	#1,d0
		bne.s	KAnim_End
		move.b	obGfx(a1,d1.w),obAnim(a0)

KAnim_End:
		rts
; ---------------------------------------------------------------------------

KAnim_WalkRun:
		addq.b	#1,d0
		bne.w	KAnim_Roll
		moveq	#0,d0
		move.b	(v_flipangle).w,d0	; if not, branch
		bne.w	KAnim_Tumble
		moveq	#0,d1
		move.b	obAngle(a0),d0
		bmi.s	loc_31704E
		beq.s	loc_31704E
		subq.b	#1,d0

loc_31704E:
		move.b	obStatus(a0),d2
		and.b	#1,d2
		bne.s	loc_31705A
		not.b	d0

loc_31705A:
		add.b	#$10,d0
		bpl.s	loc_317062
		moveq	#3,d1

loc_317062:
		and.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)
		bne.w	KAnim_Push

		lsr.b	#4,d0
		and.b	#6,d0
		move.w	obInertia(a0),d2
		bpl.s	loc_317086
		neg.w	d2

loc_317086:
		tst.b	(f_jumponly).w
		beq.w	loc_317090
		add.w	d2,d2

loc_317090:
		lea	(KnucklesAni_MachSpd).l,a1
		cmp.w	#$A00,d2
		bcc.s	loc_3170A4
		lea	(KnucklesAni_Run).l,a1
		cmp.w	#$600,d2
		bcc.s	loc_3170A4
		lea	(KnucklesAni_Walk).l,a1
		add.b	d0,d0

loc_3170A4:
		add.b	d0,d0
		move.b	d0,d3
		moveq	#0,d1
		move.b	obAniFrame(a0),d1
		move.b	obRender(a1,d1.w),d0
		cmp.b	#$FF,d0
		bne.s	loc_3170C2
		move.b	#0,obAniFrame(a0)
		move.b	obRender(a1),d0

loc_3170C2:
		move.b	d0,obFrame(a0)
		add.b	d3,obFrame(a0)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	return_3170E4
		neg.w	d2
		add.w	#$800,d2
		bpl.s	loc_3170DA
		moveq	#0,d2

loc_3170DA:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		addq.b	#1,obAniFrame(a0)

return_3170E4:
		rts
; ---------------------------------------------------------------------------

KAnim_Roll:
		subq.b	#1,obTimeFrame(a0)
		bpl.w	KAnim_Delay
		addq.b	#1,d0
		bne.s	KAnim_Push
		move.w	obInertia(a0),d2
		bpl.s	loc_317160
		neg.w	d2

loc_317160:
		lea	(KnucklesAni_Roll2).l,a1
		cmp.w	#$600,d2
		bcc.s	loc_317172
		lea	(KnucklesAni_Roll).l,a1

loc_317172:
		neg.w	d2
		add.w	#$400,d2
		bpl.s	loc_31717C
		moveq	#0,d2

loc_31717C:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)
		move.b	obStatus(a0),d1
		and.b	#1,d1
		and.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	KAnim_Do2
; ---------------------------------------------------------------------------

KAnim_Push:
		subq.b	#1,obTimeFrame(a0)
		bpl.w	KAnim_Delay
		move.w	obInertia(a0),d2
		bmi.s	loc_3171A8
		neg.w	d2

loc_3171A8:
		add.w	#$800,d2
		bpl.s	loc_3171B0
		moveq	#0,d2

loc_3171B0:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)
		lea	(KnucklesAni_Push).l,a1
		move.b	obStatus(a0),d1
		and.b	#1,d1
		and.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	KAnim_Do2

; ===========================================================================
KAnim_Tumble:
		move.b	(v_flipangle).w,d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	KAnim_Tumble_Left

		andi.b	#$FC,obRender(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#frK_Corkscrew1,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; loc_1B54E:
KAnim_Tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	@cont
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	@cont2
; ===========================================================================

@cont:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

@cont2:
		divu.w	#$16,d0
		addi.b	#frK_Corkscrew1,d0
		move.b	d0,obFrame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; End of function Knuckles_Animate

; ---------------------------------------------------------------------------
; Knuckles	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadKnucklesMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_Knuckles).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperKnuckles).l,a2
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
		move.l	#Art_Knuckles,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperKnuckles,d6

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
; End of function Knuckles_LoadGfx

LoadKnucklesMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_Knuckles,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Knuckles,(v_player+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperKnuckles,(v_player+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperKnuckles,(v_player+obMap).w
	@skip:
		rts

; =============== S U B	R O U T	I N E =======================================

; Doesn't exist in S2

sub_3192E6:
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		move.w	#-$10,a3
		move.w	#$800,d6
		jsr		FindFloor
		move.b	#$80,d2

loc_318FE8:
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	return_318FF4
		move.b	d2,d3

return_318FF4:
		rts

sub_318FF6:
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(v_anglebuffer).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		jsr		FindFloor
		move.b	#0,d2
		bra.s	loc_318FE8

loc_319208:
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		jsr		FindWall
		move.b	#$C0,d2
		bra.w	loc_318FE8

loc_3193D2:
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		jsr		FindWall
		move.b	#$40,d2
		bra.w	loc_318FE8
; END OF FUNCTION CHUNK	FOR sub_315C22
