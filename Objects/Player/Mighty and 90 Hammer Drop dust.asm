MightyPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Mighty_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Mighty_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mighty_Index(pc,d0.w),d1
		jmp	Mighty_Index(pc,d1.w)
; ===========================================================================
Mighty_Index:	dc.w Mighty_Main-Mighty_Index
		dc.w Mighty_Control-Mighty_Index
		dc.w Player_Hurt-Mighty_Index
		dc.w Player_Death-Mighty_Index
		dc.w Player_ResetLevel-Mighty_Index
		dc.w Player_Drowned-Mighty_Index
; ===========================================================================

Mighty_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		ResetHeight
		move.l	#Map_Mighty,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_plrspeedmax).w ; Mighty's top speed
		move.w	#$C,(v_plrspeedacc).w ; Mighty's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Mighty's deceleration

Mighty_Control:	; Routine 2
		bsr.w	LoadHD_Dust_Check
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	locMi_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	locMi_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Mighty into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

locMi_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	locMi_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

locMi_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	locMi_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Mighty_Modes(pc,d0.w),d1
		jsr	Mighty_Modes(pc,d1.w)

locMi_12C7E:
		jsr	Player_Display
		jsr	Player_RecordPosition
		jsr	Player_Water
		jsr	Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	locMi_12CA6
		tst.b	obAnim(a0)
		bne.s	locMi_12CA6
		move.b	obNextAni(a0),obAnim(a0)

locMi_12CA6:
		bsr.w	Mighty_Animate
		tst.b	(f_lockmulti).w
		bmi.s	locMi_12CB6
		jsr	(ReactToItem).l

locMi_12CB6:
		bsr.w	Mighty_LoadGfx
		rts
; ===========================================================================
Mighty_Modes:	dc.w Mighty_MdNormal-Mighty_Modes
		dc.w Mighty_MdAir-Mighty_Modes
		dc.w Mighty_MdRoll-Mighty_Modes
		dc.w Mighty_MdJump-Mighty_Modes
; ===========================================================================
LoadHD_Dust_Check:
		subi.b	#1,(v_NewHD_Dust_Timer).w
		bpl.s	@noDust
		move.b	#3,(v_NewHD_Dust_Timer).w
		cmpi.b	#3,(v_HD_Dust_delay).w
		bne.s	@NotSecondDust
		lea	(DustVelocities2).l,a2
		bra.s	@Cont_DustSet
	@NotSecondDust:
		cmpi.b	#1,(v_HD_Dust_delay).w
		bne.s	@NoDust
		lea	(DustVelocities3).l,a2
	@Cont_DustSet:
		move.b	(v_HD_Dust_delay).w,d1
		bra.w	loc_19816_HD_Continued
	@noDust:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Mighty
; ---------------------------------------------------------------------------

Mighty_MdNormal:
		jsr	Player_CheckSpindash
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

Mighty_MdAir:	; Spring, walking off a platform...
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
		cmpi.b	#3,obDoubleJump(a0)
		beq.s	Mighty_MdWallJump
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		jsr	Player_LevelBound
		jsr	(ObjectFall).l

		btst	#6,obStatus(a0)
		beq.s	@done
		subi.w	#$28,obVelY(a0)

	@done:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts

Mighty_MdWallJump:
		subq.b	#1,obDoubleJump_property(a0)
		bmi.s	@clrDJV
		cmpi.b	#3,obDoubleJump(a0)
		beq.s	@skip

	@clrDJV:
		move.b	#2,obDoubleJump(a0)	; clear wall jump flag and
		move.b	#0,obDoubleJump_property(a0)
		move.b	#id_roll,obAnim(a0) ; use "jumping" animation
		bra.s	@done
	@skip:
		bsr.w	Player_JumpHeight
		jsr	(ObjectFall).l
		subi.w	#$38,obVelY(a0)
		cmpi.b	#$18,obDoubleJump_property(a0)
		bge.s	@done
		addi.w	#8,obVelY(a0)
	@done:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Mighty_MdRoll:
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

Mighty_MdJump:	; Actually jumping.
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
		cmpi.b	#3,obDoubleJump(a0)
		beq.w	Mighty_MdWallJump
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		jsr	Player_LevelBound
		jsr	(ObjectFall).l

		btst	#6,obStatus(a0)
		beq.s	@done
		subi.w	#$28,obVelY(a0)

	@done:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to	animate	Mighty's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Mighty_Animate:
		lea	(Ani_Mighty).l,a1
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
		move.b	obAngle(a0),d0	; get Mighty's angle
		bmi.s	@cont
		beq.s	@cont
		subq.b	#1,d0

	@cont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Mighty mirrored horizontally?
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
		btst	#5,obStatus(a0)	; is Mighty pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Mighty's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		lea	(MtyAni_MachSpeed).l,a1
		cmpi.w	#$A00,d2
		bcc.s	@running

		lea	(MtyAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Mighty at running speed?
		bcc.s	@running	; if yes, branch

		lea	(MtyAni_Walk).l,a1 ; use walking animation
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
		move.w	obInertia(a0),d2 ; get Mighty's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(MtyAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Mighty moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(MtyAni_Roll).l,a1 ; use slower	animation

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
		move.w	obInertia(a0),d2 ; get Mighty's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3	
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(MtyAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	@loadframe

@tumble:
		move.b	(v_flipangle).w,d0
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	@tumble_Left

		andi.b	#$FC,obRender(a0)
		addi.b	#$B,d0
		divu.w	#$16,d0
		addi.b	#$90,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; loc_1B54E:
@tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	locM_1B566
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	locM_1B572
; ===========================================================================

locM_1B566:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

locM_1B572:
		divu.w	#$16,d0
		addi.b	#$90,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; End of function Mighty_Animate

; ---------------------------------------------------------------------------
; Mighty	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Mighty_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadMightyMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
;		tst.b	(v_super).w
;		bne.s	@superplc
		lea	(DPLC_Mighty).l,a2
;		bra.s	@cont
;	@superplc:
;		lea	(DPLC_SuperMighty).l,a2
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
		move.l	#Art_Mighty,d6
;		bra.s	@readentry
;	@superart:
;		move.l	#Art_SuperMighty,d6

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
; End of function Mighty_LoadGfx

LoadMightyMap:
;		tst.b	(v_super).w
;		bne.s	@super
	@normal:
		cmpi.l	#Map_Mighty,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Mighty,(v_player+obMap).w
;		bra.s	@skip
;	@super:
;		cmpi.l	#Map_SuperMighty,(v_player+obMap).w
;		beq.s	@skip
;		move.l	#Map_SuperMighty,(v_player+obMap).w
	@skip:
		rts

; =============== S U B R O U T I N E =======================================
HammerDrop_Create_Dust:
		move.b	#0,(v_HD_Dust_delay).w
		move.b	#3,(v_NewHD_Dust_Timer).w
		move.w	obX(a0),(v_HD_Dust_delay_posx).w
		move.w	obY(a0),(v_HD_Dust_delay_posy).w
		moveq	#5,d1

HammerDrop_Create_Dust_Part2:
		cmpi.b	#3,d1
		beq.w	Delay_HDD
		cmpi.b	#1,d1
		beq.w	Delay_HDD

loc_19816_HD_Continued:
		jsr	(FindFreeObj).l		; Find free object slot
		bne.w	locret_19862_HD			; If one can't be found, return
		move.b	#id_HammerDrop_Dust,0(a1)	; Make new object a Dust (made it separate due to some things
		move.w	(v_HD_Dust_delay_posx).w,obX(a1)		; Inherit x_pos from source object
		move.w	(v_HD_Dust_delay_posy).w,obY(a1)		; Inherit y_pos from source object
		addi.w	#$A,obY(a1)
		move.l	(v_dust+obMap).w,obMap(a1)	; Inherit mappings from source object
		move.w	(v_dust+obGFX).w,obGFX(a1)	; Inherit art_tile from source object
		move.b	#$10,obHeight(a1)	; this sets Mighty's collision height (2*pixels)
		move.b	#$10,obWidth(a1)
		move.b	#4,obRender(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	#$10,obActWid(a1)
		move.b	#3,obAnim(a1)
		addi.w	#4,obX(a1)
		cmpi.b	#4,d1
		beq.s	.Left
		cmpi.b	#2,d1
		beq.s	.Left
		tst.b	d1
		bne.s	.notLeft

	.Left:
		subi.w	#8,obX(a1)

	.notLeft:
		move.w	(a2)+,obX(a1)			; Give x_vel (unique to each of the six Dusts)
		move.w	(a2)+,obY(a1)
		move.b	#0,(v_HD_Dust_delay).w
		dbf	d1,HammerDrop_Create_Dust_Part2

locret_19862_HD:
		rts
; End of function HammerDrop_Create_Dust

Delay_HDD:
		move.b	d1,(v_HD_Dust_delay).w
		rts
; ---------------------------------------------------------------------------

DustVelocities:dc.w   $200, -$30 ; First Batch
		dc.w   -$200, -$30
		even

DustVelocities2:		dc.w   $180, -$20 ; Second Batch
		dc.w   -$180, -$20
		even

DustVelocities3:		dc.w   $100, -$10 ; Third Batch
		dc.w   -$100, -$10
		even
; ---------------------------------------------------------------------------

HammerDrop_Dust:
		jsr	(SpeedToPos).l
		lea	(Ani_SpindashDust).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRoutine(a0)
		bne.s	HammerDrop_Dust_Delete
		jsr	Dust_LoadGfx
		jsr	(DisplaySprite).l
		bra.s	Touch_HammerDropDust
; ---------------------------------------------------------------------------

HammerDrop_Dust_Delete:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------
Touch_HammerDropDust:
		; Here goes the hit detection (have to rewrite it to the S1 format so removed the code
		rts