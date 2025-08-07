LegacyPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Legacy_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

Legacy_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Legacy_Index(pc,d0.w),d1
		jmp	Legacy_Index(pc,d1.w)
; ===========================================================================
Legacy_Index:	dc.w Legacy_Main-Legacy_Index
		dc.w Legacy_Control-Legacy_Index
		dc.w Player_Hurt-Legacy_Index
		dc.w Player_Death-Legacy_Index
		dc.w Player_ResetLevel-Legacy_Index
		dc.w Player_Drowned-Legacy_Index
; ===========================================================================

Legacy_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		(ResetHeight).l
		move.l	#Map_Legacy,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_plrspeedmax).w ; Legacy's top speed
		move.w	#$C,(v_plrspeedacc).w ; Legacy's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Legacy's deceleration

Legacy_Control:	; Routine 2
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	locLS_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	locLS_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Legacy into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

locLS_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	locLS_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

locLS_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	locLS_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Legacy_Modes(pc,d0.w),d1
		jsr	Legacy_Modes(pc,d1.w)

locLS_12C7E:
		jsr	Player_Display
		jsr	Player_RecordPosition
		jsr	Player_Water
	jsr		Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	locLS_12CA6
		tst.b	obAnim(a0)
		bne.s	locLS_12CA6
		move.b	obNextAni(a0),obAnim(a0)

locLS_12CA6:
		bsr.w	Legacy_Animate
		tst.b	(f_lockmulti).w
		bmi.s	locLS_12CB6
		jsr	(ReactToItem).l

locLS_12CB6:
		bsr.w	Legacy_LoadGfx
		rts
; ===========================================================================
Legacy_Modes:	dc.w Legacy_MdNormal-Legacy_Modes
		dc.w Legacy_MdAir-Legacy_Modes
		dc.w Legacy_MdRoll-Legacy_Modes
		dc.w Legacy_MdJump-Legacy_Modes
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Legacy
; ---------------------------------------------------------------------------

Legacy_MdNormal:
		jsr Metal_Peelout
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

Legacy_MdAir:	; Spring, walking off a platform...
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		bsr.w   Legacy_AirRoll
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		jsr	Player_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	locLS_12E5C
		subi.w	#$28,obVelY(a0)

locLS_12E5C:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Legacy_MdRoll:
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

Legacy_MdJump:	; Actually jumping.
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		bsr.w   Legacy_DownKick
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		jsr	Player_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	locLS_12EA6
		subi.w	#$28,obVelY(a0)

locLS_12EA6:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to	animate	Legacy's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Legacy_Animate:
		lea	(Ani_Legacy).l,a1
		tst.b	(v_super).w
		beq.s	@doneloadinganim
		lea	(Ani_DarkLegacy).l,a1
	@doneloadinganim:
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
		move.b	obAngle(a0),d0	; get Sonic's angle
		bmi.s	@cont
		beq.s	@cont
		subq.b	#1,d0

	@cont:
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Sonic mirrored horizontally?
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
		btst	#5,obStatus(a0)	; is Legacy pushing something?
		bne.w	@push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2 ; get Legacy's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		lea	(LegAni_3rdRun).l,a1
		cmpi.w	#$A00,d2
		bcc.s	@running

		lea	(LegAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Legacy at running speed?
		bcc.s	@running	; if yes, branch

		lea	(LegAni_Walk).l,a1 ; use walking animation
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
		move.w	obInertia(a0),d2 ; get Legacy's speed
		bpl.s	@nomodspeed2
		neg.w	d2

	@nomodspeed2:
		lea	(LegAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Legacy moving fast?
		bcc.s	@rollfast	; if yes, branch
		lea	(LegAni_Roll).l,a1 ; use slower	animation

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
		move.w	obInertia(a0),d2 ; get Legacy's speed
		bmi.s	@negspeed
		neg.w	d2

	@negspeed:
		addi.w	#$800,d2
		bpl.s	@belowmax3	
		moveq	#0,d2

	@belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(LegAni_Push).l,a1
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
		addi.b	#frL_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts
; ===========================================================================
; locL_1B54E:
@tumble_Left:
		andi.b	#$FC,obRender(a0)
		tst.b	$29(a0)
		beq.s	locL_1B566
		ori.b	#1,obRender(a0)
		addi.b	#$B,d0
		bra.s	locL_1B572
; ===========================================================================

locL_1B566:
		ori.b	#3,obRender(a0)
		neg.b	d0
		addi.b	#$8F,d0

locL_1B572:
		divu.w	#$16,d0
		addi.b	#frL_Corkscrew1,d0
		move.b	d0,mapping_frame(a0)
		move.b	#0,obTimeFrame(a0)
		rts

; End of function Legacy_Animate

; ---------------------------------------------------------------------------
; Legacy	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Legacy_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		bsr.w	LoadLegacyMap
		cmp.b	(v_plrframenum).w,d0
		beq.s	@nochange
		move.b	d0,(v_plrframenum).w
		tst.b	(v_super).w
		bne.s	@superplc
		lea	(DPLC_Legacy).l,a2
		bra.s	@cont
	@superplc:
		lea	(DPLC_DarkLegacy).l,a2
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
		tst.b	(v_super).w
		bne.s	@superart
		move.l	#Art_Legacy,d6
		bra.s	@readentry
	@superart:
		move.l	#Art_DarkLegacy,d6

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
; End of function Legacy_LoadGfx

LoadLegacyMap:
		tst.b	(v_super).w
		bne.s	@super
	@normal:
		cmpi.l	#Map_Legacy,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_Legacy,(v_player+obMap).w
		bra.s	@skip
	@super:
		cmpi.l	#Map_DarkLegacy,(v_player+obMap).w
		beq.s	@skip
		move.l	#Map_DarkLegacy,(v_player+obMap).w
	@skip:
		rts

Legacy_AirRoll:
		tst.b	(v_springshoes).w
		bne.s	@ret

	@cont:
		btst    #1,obStatus(a0)   ; is Sonic in the air?
		beq.s   @ret   ; if not, branch
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.s   @ret   ; if not, branch
		move.b  #$20,obAnim(a0)   ; use "air roll"   animation
		sfx		sfx_AirRoll
		bset    #2,obStatus(a0)   ; force Sonic to roll
		move.b  #1,obDoubleJump(a0)	; why this was under @ret, i probably will find out when i build ; i did not find out

	@ret:
		rts
; End of function Legacy_AirRoll

Legacy_DownKick: ; what the fuck is this???
		tst.b	(v_springshoes).w
		bne.s	@ret
		cmpi.b   #2,obDoubleJump(a0)
		beq.s   @setNewFlag
		cmpi.b   #3,obDoubleJump(a0)        ; was Stomp flag set?
		beq.s	@ret                ; EB: was it set? if not, branch
		cmpi.b   #4,obDoubleJump(a0)        ; was Stomp flag set?
		beq.s	@ret                ; EB: was it set? if not, branch
		cmpi.b   #5,obDoubleJump(a0)        ; was Stomp flag set?
		beq.s	@ret                ; EB: was it set? if not, branch
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnA,d0
		beq.w	@ret
		move.b  #3,obDoubleJump(a0)    ; if not, set Stomp flag
	@continue:
		tst.b	(v_super).w
		bne.s	@noshield
		cmpi.b	#shID_Fire,(v_shield).w
		beq.s	@fireKick
	@noshield:
		sfx     sfx_Dash
		move.b	#id_DropDash,obAnim(a0)	; use Sonic's DK (DONKEY KONG) animation
		move.w	#$880,obVelX(a0)            ; EB: set X speed	; Slight buff.
		btst	#0,obStatus(a0)        ; is sonic facing left?
		bne.s	@noflip        ; if not, branch
		bra.s   @sety

	@noflip:
		neg.w   obVelX(a0)            ; EB: set X speed

	@sety:
		move.w	#$500,obVelY(a0)

	@ret:
		rts                             ; EB: return

	@setNewFlag:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnA,d0
		beq.w	@ret
		move.b  #5,obDoubleJump(a0)    ; set Stomp to flag 5 to prevent infinite jumps
		bra.w	@continue

	@fireKick:	; Fire shield kick
		sfx		sfx_FireKick
		move.b	#id_DieMad,obAnim(a0)
		move.b	#1,(v_oshield+obAnim).w
		move.w	#$980,d0
		btst	#0,obStatus(a0)        ; is sonic facing left?
		bne.s	@noflip2        ; if not, branch
		bra.s   @sety2
	
	@noflip2:
		neg.w	d0
	
	@sety2:
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		move.w	#0,obVelY(a0)
		move.w	#$1000,(v_cameralag).w
		jsr	Reset_Player_Position_Array
		rts

; Post-Kick double jump
Legacy_DoubleJump_PK:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnC,d0
		beq.s   Legacy_DJ_return
		move.b  #4,obDoubleJump(a0)    ; set Double jump flag to 4 to prevent infinite jumps
		bra.s	Legacy_DJ_continue

Legacy_DoubleJump:
		cmpi.b   #2,obDoubleJump(a0)
		beq.s   Legacy_DJ_return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnC,d0
		beq.s   Legacy_DJ_return
		move.b  #2,obDoubleJump(a0)
Legacy_DJ_continue:
		sfx	    sfx_DoubleJump		; play jumping sound
		move.b  #id_Spring,obAnim(a0)
		btst    #6,obStatus(a0)
		bne.s   @underwater
		move.w  #-$600,obVelY(a0)
		bra.s   Legacy_DJ_return
	@underwater:
		move.w  #-$450,obVelY(a0)
Legacy_DJ_return:
		rts
; ---------------------------------------------------------------------------
; Legacy's balance code (ported from Sonic 3K)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; ---------------------------------------------------------------------------
; balancing checks for when you're on the right edge of an object
; loc_1A410:
Legacy_BalanceOnObjRight:
		btst	#0,obStatus(a0)
		bne.s	@loc1
		move.b	#$B,obAnim(a0)
		addq.w	#6,d2
		cmp.w	d2,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
    ; on right edge of object but facing left:
@loc1:	bclr	#0,obStatus(a0)
		move.b	#$B,obAnim(a0)
		addq.w	#6,d2
		cmp.w	d2,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the left edge of an object
; loc_1A44E:
Legacy_BalanceOnObjLeft:
		btst	#0,obStatus(a0)
		beq.s	@loc2
		move.b	#$B,obAnim(a0)
		cmpi.w	#-4,d1
		bge.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
    ; on left edge of object but facing right:
@loc2:	bset	#0,obStatus(a0)
		move.b	#$B,obAnim(a0)
		cmpi.w	#-4,d1
		bge.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
; ---------------------------------------------------------------------------
; balancing checks for when you're on the edge of part of the level
; loc_1A48C:
Legacy_Balance:
		move.w	obX(a0),d3
		jsr	ObjFloorDist
		cmpi.w	#$C,d1
		blt.w	Player_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	Legacy_BalanceLeft
		btst	#0,obStatus(a0)
		bne.s	@loc3
		move.b	#$B,obAnim(a0)
		move.w	obX(a0),d3
		subq.w	#6,d3
		jsr	ObjFloorDist2
		cmpi.w	#$C,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
    ; on right edge but facing left:
@loc3:	bclr	#0,obStatus(a0)
		move.b	#$B,obAnim(a0)
		move.w	obX(a0),d3
		subq.w	#6,d3
		jsr	ObjFloorDist2
		cmpi.w	#$C,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
; ---------------------------------------------------------------------------

Legacy_BalanceLeft:
		cmpi.b	#3,$37(a0)
		bne.w	Player_LookUp
		btst	#0,obStatus(a0)
		beq.s	@loc4
		move.b	#$B,obAnim(a0)
		move.w	obX(a0),d3
		addq.w	#6,d3
		jsr	ObjFloorDist2
		cmpi.w	#$C,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
    ; on left edge but facing right:
@loc4:	bset	#0,obStatus(a0)
		move.b	#$B,obAnim(a0)
		move.w	obX(a0),d3
		addq.w	#6,d3
		jsr	ObjFloorDist2
		cmpi.w	#$C,d1
		blt.w	Player_ResetScr
		move.b	#6,obAnim(a0)
		bra.w	Player_ResetScr
; ===========================================================================