; ---------------------------------------------------------------------------
; Object 93 - BKyuko
; ---------------------------------------------------------------------------

BossBGZ:
		moveq	#0,d0                  	; Clean out d0. Don't want it to be dirty, after all.
		move.b	obRoutine(a0),d0	    ; Move the object's routine counter to d0. We just cleaned it, so it's all 0.
		move.w	BKyuko_Index(pc,d0.w),d1	; Move our routine to d1, because that does something...?
		jmp 	BKyuko_Index(pc,d1.w)	; Jump to our index using the routine value that we put in d1. Assuming this runs constantly.
; ===========================================================================
	rsset   obSubtype
@moveOptionTimer:	rs.w 1	; word
BKyu_Inertia = $2C
BKyu_FrameNum = $2E
BKyu_CurrentlyHurting = $2F
BKyu_Deceleration = $32

BKyuko_Index:    dc.w    BKyuko_Init-BKyuko_Index		; 0
				dc.w    BKyuko_Main-BKyuko_Index		; 2
				dc.w	BKyuko_Hurt-BKyuko_Index		; 4
				dc.w	BKyuko_Defeated-BKyuko_Index	; 6
; ===========================================================================
BKyuko_Init:
		addq.b	#2,obRoutine(a0)	; => BKyukoBoss_Normal
		move.b	#$13,obHeight(a0)
		move.b  #9,obWidth(a0)
		move.l	#Map_BossKyuko,obMap(a0)
		move.w	#vramKoiBGZ,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0)

BKyuko_Main:
		tst.b	obColProp(a0)
		bne.s	@cont
		bra.w	BKyuko_Defeat
	@cont:
		jsr		BKyuko_HandleHits
		bsr.s	BKyuko_Actions
		jsr		BKyuko_Animate
		jsr 	BKyuko_LoadGfx
		jmp		BKyuko_Display

BKyuko_Actions:
		tst.b	(v_bossstatus).w
		beq.s	@cont
		rts
	@cont:
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	BKyuko_Modes(pc,d0.w),d1
		jmp		BKyuko_Modes(pc,d1.w)
; ===========================================================================
BKyuko_Modes:
		dc.w	BKyuko_MdNormal-BKyuko_Modes
		dc.w	BKyuko_MdAir-BKyuko_Modes
; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for handling actions and such.
; ---------------------------------------------------------------------------

BKyuko_MdNormal:
		bsr.w	WindUpKoi_TestCharacterPos
		
BKyuko_CollisionAndVelocity:
		jsr		ObjectFall
		jsr     (ObjFloorDist).l
		tst.w	d1
		bpl.s	@notonfloor
		add.w	d1,obY(a0)	; match	object's position with the floor
		move.w	#0,obVelY(a0)
		move.w	BKyu_Inertia(a0),obVelX(a0)
		bne.s	@walk
		move.b	#id_Wait,obAnim(a0)    ; use "standing" animation
		bra.s	@done
	@walk:
		move.b	#id_Walk,obAnim(a0)
		bra.s	@done
	@notonfloor:
		tst.b	obVelY(a0)
		beq.s	@done	; Zero, which probably means she's on the ground
		bgt.s	@down	; > 0, which means going... down?
		move.b	#id_Spring,obAnim(a0)	; Spring animation.
	@down:
		blt.s	@done
		move.b	#23,obAnim(a0)
	@done:
		jsr		BKyuko_LevelBound
		rts

BKyuko_Collision:
		jsr     (ObjFloorDist).l
		tst.w	d1
		bpl.s	@ret
		add.w	d1,obY(a0)	; match	object's position with the floor
		move.w	#0,obVelY(a0)
		bclr	#1,obStatus(a0)

	@ret:
		jsr		BKyuko_LevelBound
		rts

BKyuko_Delete:
		jmp		DeleteObject

BKyuko_HandleHits:
		cmpi.b	#6,obRoutine(a0)
		beq.w	BKyuko_Return
		tst.b	obColProp(a0)
		beq.w	BKyuko_Defeat
		tst.b	obColType(a0)
		bne.s	BKyuko_Return
		tst.b	flashtime(a0)
		bne.s	BKyuko_Display	; If it has time left, go to the Display part.
		btst	#1,BKyu_CurrentlyHurting(a0)
		bne.s	BKyuko_Display
	; Copied from HurtSonic.
		move.b	#4,obRoutine(a0)
		bset	#1,BKyu_CurrentlyHurting(a0)
		bset	#1,obStatus(a0)
		move.w	#-$400,obVelY(a0) ; make BKyuko bounce away from the object
		move.w	#-$200,obVelX(a0)
		move.w	obX(a0),d0
;		cmp.w	obX(a1),d0 ; if you plan on using this line, you have to call the player object to a1 first
;		you can either add a line to call the player object at a1 or just keep it as I have it
;		(idk how to do it in S1, since S2 and 3 have MainCharacter/Player_1 respectively), so I'm manually calling it here instead
		cmp.w	(v_player+obX).w,d0 
		bcs.s	@isleft		; if Sonic is left of the object, branch
		neg.w	obVelX(a0)	; if Sonic is right of the object, reverse
	@isleft:
		move.w	#0,BKyu_Inertia(a0)
		move.b	#id_Hurt,obAnim(a0)
		move.b	#$78,flashtime(a0)	; set temp invincible time to 2 seconds
		sfx		sfx_BossHit
;		subq.b	#1,obColProp(a0)

BKyuko_Display:
		move.b	flashtime(a0),d0
		beq.s	@finished
		subq.b	#1,flashtime(a0)
		lsr.w	#3,d0
		bcc.s	BKyuko_Return
		bra.s	@display
	@finished:
		move.b	#$F,obColType(a0)
		bclr	#1,BKyu_CurrentlyHurting(a0)
	@display:
		jmp	(DisplaySprite).l

BKyuko_Return:
		rts

BKyuko_Hurt:
		jsr		(ObjectFall).l
	; Uh... that's water stuff. What?
;		addi.w	#$30,obVelY(a0)
;		btst	#6,obStatus(a0)
;		beq.s	@cont
;		subi.w	#$20,obVelY(a0)
;
;	@cont:
		jsr		BKyuko_HurtStop
		jsr		BKyuko_Animate
		jsr 	BKyuko_LoadGfx
		jmp		(DisplaySprite).l

BKyuko_HurtStop:
		jsr	BKyuko_Collision
		btst	#1,obStatus(a0)
		bne.s	@ret
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,BKyu_Inertia(a0)
		move.b	#id_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,flashtime(a0)

	@ret:
		rts

BKyuko_Defeat:
		move.b	#0,obColType(a0)
		jsr		ResumeMusic2

;		jsr	(LoadPLC_AnimalExplosion).l
		moveq	#100,d0
		jsr     AddPoints
;		move.w	#$B3,(Boss_Countdown).w ; whatever the fuck this means.
		tst.b	(v_bossstatus).w
		bne.s	@cont
		move.b	#1,(v_bossstatus).w
	@cont:
		move.b	#6,obRoutine(a0)
		moveq	#plcid_Capsule,d0
		jmp		(AddPLC).l

BKyuko_Defeated:
		cmpi.w	#$2AC0,(v_limitright2).w	; has camera reached its target position?
		bcc.s	BKyuko_ChkDel	; if yes, branch
		addq.w	#2,(v_limitright2).w		; else, move camera
		move.b	#0,obColType(a0)
		bra.s	BKyuko_RunAway

BKyuko_ChkDel:
		tst.b	obRender(a0)
		bpl.w	BKyuko_Delete

BKyuko_RunAway:
		bclr	#0,obStatus(a0)
		move.b	#0,obColType(a0)
		addq.w	#8,BKyu_Inertia(a0)
		move.b	#id_Run,obAnim(a0)
		jsr		ObjectFall
		jsr		BKyuko_Collision
		move.w	BKyu_Inertia(a0),obVelX(a0)
		jsr		BKyuko_Animate
		jsr 	BKyuko_LoadGfx
		jmp		DisplaySprite

BKyuko_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	BKyu_FrameNum(a0),d0
		beq.s	@nochange
		move.b	d0,BKyu_FrameNum(a0)
		lea	(DPLC_BossKyuko).l,a2

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
		move.l	#Art_BossKyuko,d6

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

BKyuko_Animate:
		lea	(Ani_BossKyuko).l,a1
		moveq	#0,d0
		move.b	obAnim(a0),d0
;		tst.b	obVelY(a0)
;		bne.w	@jump
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
		bmi.s	@walking	; if animation is walk/run/roll/jump, branch
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

@walking:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	@delay		; if time remains, branch

		addq.b	#1,d0		; is animation walking/running?
		bne.w	@jump	; if not, branch
		moveq	#0,d0		; is animation walking/running?
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Sonic's angle
		bmi.s	@wrrcont
		beq.s	@wrrcont
		subq.b	#1,d0

	@wrrcont:
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

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	BKyu_Inertia(a0),d2 ; get BKyuko's speed
		bpl.s	@nomodspeed
		neg.w	d2		; modulus speed

	@nomodspeed:
		tst.b	d2
		bne.s	@cont1
		lea	(BKyuAni_Idle).l,a1 ; use waiting animation
		bra.s	@ret

	@cont1:
		lea	(BKyuAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Sonic at running speed?
		bcc.s	@running	; if yes, branch

		lea	(BKyuAni_Walk).l,a1 ; use walking animation
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

@jump:
		tst.b	obVelY(a0)
		bgt.s	@down
		move.b	#15,obAnim(a0)
	@down:
		blt.s	@ret
		move.b	#23,obAnim(a0)
	@ret:
		rts

BKyuko_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Player touched the	side boundary?
		bhi.s	@sides		; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	@screenlocked
		addi.w	#$40,d0

	@screenlocked:
		tst.b	(v_bossstatus).w
		bne.s	@ret
		cmp.w	d1,d0		; has Player touched the	side boundary?
		bls.s	@sides		; if yes, branch
		rts

	@sides:
		move.w	d0,obX(a0)
		move.w	#0,obX+2(a0)
		move.w	#0,obVelX(a0)	; stop Player moving
		move.w	#0,BKyu_Inertia(a0)
	@ret:
		rts