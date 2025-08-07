; ---------------------------------------------------------------------------
; Object 9E - Stupid Dumb Unnamed Robo-Fairy (Melting Heights)
; ---------------------------------------------------------------------------
; For a little context, this is a straight port from North Island, so it WILL
; be buggy!!
; ---------------------------------------------------------------------------

BossMHZ:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossMHZ_Index(pc,d0.w),d1
		jsr	BossMHZ_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
	rsset   obSubtype
BossMHZ_move_option_timer:	rs.w 1	; word
BossMHZ_obY_next:			rs.w 1	; word
BossMHZ_FloatDown_Flag:		rs.b 1	; byte
BossMHZ_hover_counter:		rs.b 1	; byte
BossMHZ_PrevFrame:			rs.b 1
; off_15CD6:
BossMHZ_Index:
		dc.w BossMHZ_Init-BossMHZ_Index	; 0
		dc.w BossMHZ_Main-BossMHZ_Index	; 2
		dc.w BossMHZ_SwishAttack-BossMHZ_Index	; 4
		dc.w BossMHZ_PHold2-BossMHZ_Index	; 6
		dc.w BossMHZ_Defeated-BossMHZ_Index	; 8
; ===========================================================================
; loc_15CDA:
BossMHZ_Init:
		move.w	#$100,obVelY(a0)	; move her down
		jsr	(SpeedToPos).l
		cmpi.w	#$210,obY(a0) ; please let this work
		bne.s	BossMHZ_AnimateNormal	; if it works... go to the animate part??? thanks arz boss for being confusing af
		move.w	#0,obVelY(a0)	; stop her too, i guess
		move.b	#1,BossMHZ_FloatDown_Flag(a0)
		addq.b	#2,obRoutine(a0)

BossMHZ_AnimateNormal:
		move.l	#Map_SDURF,mappings(a0)
		move.w	#$400,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,width_pixels(a0)
		move.w	#$200,priority(a0)
		move.w	obY(a0),BossMHZ_obY_next(a0); very large sine wave.
		tst.b	BossMHZ_FloatDown_Flag(a0)
		beq.s	BossMHZ_Main_Only_Animate
		move.b	#$F,collision_flags(a0)
		move.b	#8,collision_property(a0)

BossMHZ_Idle_timer:
		move.w	#6*60,BossMHZ_move_option_timer(a0)
		tst.w	obVelX(a0)
		bhs.s	@notnegate
		move.w	#-$200,obVelX(a0)
		bra.s	@setobRoutine
	@notnegate:
		move.w	#$200,obVelX(a0)
	@setobRoutine:
		move.b	#2,obRoutine(a0)
; loc_15D02:
BossMHZ_Main:
		subq.w	#1,BossMHZ_move_option_timer(a0)
		bmi.w	BossMHZ_DoSwishAttack
		bsr.w	BossMHZ_SineWaveAndHandleHits
		bsr.s	BossMHZ_Main_Move

	BossMHZ_Main_Only_Animate:
		lea		(Ani_SDURF).l,a1 ; this specific order makes it work fine. dunno why...
		tst.b	invtime(a0)	; is boss invulnerable?
		beq.s	@notInv				; if not, branch
		move.b	#2,obAnim(a0)
		bra.s	@fuck
	@notInv:
		move.b	#1,obAnim(a0)
	@fuck:
		jsr	(AnimateSprite).l
		jmp		SDURF_LoadGfx
	;	jmp		Obj_DeleteBehindScreen

BossMHZ_Main_Move:	; shared obRoutine, checks positions and sets direction
		move.w	obX(a0),d0
		cmpi.w	#$2960,d0	; Is this the left boundary?
		ble.s	@leftBound	; if lower or equal, negate x velocity
		cmpi.w	#$2AA0,d0 ; Is this the right boundary?
		blt.s	@move			; if lower than it, only move

	@leftBound:
		neg.w	obVelX(a0)	; change direction of velocity
	@move:
		move.l	obX(a0),d2
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,obX(a0)	; set obX depening on velocity
		jsr		Obj_GetOrientationToPlayer
		bclr	#0,obRender(a0)	; face right
		bclr	#0,status(a0)
		tst.w	d0		; is player to object's left?
		bne.s	@display		; if not, branch
		bset	#0,obRender(a0)	; face left
		bset	#0,status(a0)
	@display:
		jmp	(DisplaySprite).l

BossMHZ_SineWaveAndHandleHits:
		tst.b	BossMHZ_FloatDown_Flag(a0)
		beq.s	BossMHZ_HandleHits
		; do hovering motion using sine wave
		move.b	BossMHZ_hover_counter(a0),d0
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	BossMHZ_obY_next(a0),d0		; get y position for next frame, add sine value
		move.w	d0,obY(a0)			; set y and x positions
		addq.b	#2,BossMHZ_hover_counter(a0)
BossMHZ_HandleHits:
		cmpi.b	#8,obRoutine(a0)	; is boss exploding or retreating?
		beq.s	MC_MainEnd_Return		; if yes, branch
		tst.b	collision_property(a0)	; has boss run out of hits?
		beq.w	SDURF_Defeat		; if yes, branch
		tst.b	collision_flags(a0)	; are boss' collisions enabled?
		bne.s	MC_MainEnd_Return		; if yes, branch
		tst.b	invtime(a0)	; is boss invulnerable?
		bne.s	@flash				; if yes, branch
		move.b	#$20,invtime(a0)	; make boss invulnerable
		sfx	sfx_BossHit	; play boss damage sound
@flash:
	; do palette flashing effect
		lea	(v_pal_dry+$22).w,a1 ; load 2nd pallet, 2nd entry
		moveq	#0,d0		; move 0 (black) to d0
		tst.w	(a1)
		bne.s	@set
		move.w	#cWhite,d0	; move 0EEE (white) to d0
@set:
		move.w	d0,(a1)		; set color to white or black
		subq.b	#1,invtime(a0)	; decrease boss' invulnerable time
		bne.s	MC_MainEnd_Return			; branch, if it hasn't run out
		move.b	#$F,collision_flags(a0)		; else, restore collisions

MC_MainEnd_Return:
		rts

BossMHZ_DoSwishAttack:
		move.w	#6*60,BossMHZ_move_option_timer(a0)
		tst.w	obVelX(a0)
		bhs.s	@notnegate
		move.w	#-$380,obVelX(a0)
		bra.s	@setobRoutine
	@notnegate:
		move.w	#$380,obVelX(a0)
	@setobRoutine:
		move.b	#4,obRoutine(a0)
		rts
; ===========================================================================
; loc_2D5C4:
SDURF_Defeat:
		jsr		ResumeMusic2
;		jsr	(LoadPLC_AnimalExplosion).l
		moveq	#100,d0
		jsr     AddPoints
;		move.w	#$B3,(Boss_Countdown).w ; whatever the fuck this means.
		tst.b	(v_bossstatus).w
		bne.s	@cont
		move.b	#1,(v_bossstatus).w
	@cont:
		move.b	#8,obRoutine(a0)
		moveq	#plcid_Capsule,d0
		jmp		(AddPLC).l

BossMHZ_SwishAttack:
		subq.w	#1,BossMHZ_move_option_timer(a0)
		bmi.w	BossMHZ_Idle_timer
		bsr.w	BossMHZ_Main_Move
		move.b	BossMHZ_hover_counter(a0),d0
		jsr	(CalcSine).l
		asr.w	#1,d1
		add.w	BossMHZ_obY_next(a0),d1	; get y position for next frame, add sine value
		cmp.w	#$210,d1
		bgt.s	@noNeg
		move.w	#$210,d1
	@noNeg:
		move.w	d1,obY(a0)			; set y positions
		addq.b	#2,BossMHZ_hover_counter(a0)
		bra.w	BossMHZ_HandleHits
BossMHZ_PHold2:	rts

BossMHZ_Defeated:
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		cmpi.w	#$2C00,(v_limitright2).w	; has camera reached its target position?
		bcc.s	MC_ChkDel	; if yes, branch
		addq.w	#2,(v_limitright2).w		; else, move camera
		bra.s	MCir_ARZBossSubC
; ===========================================================================
; loc_30976:
MC_ChkDel:
		tst.b	obRender(a0)
		bpl.w	MCir_Delete

; loc_3097C:
MCir_ARZBossSubC:
		jsr		SpeedToPos
		bsr.w	BossMHZ_SineWaveAndHandleHits
; lets go
		lea		(Ani_SDURF).l,a1 ; this specific order makes it work fine. dunno why...
		move.b	#3,obAnim(a0)
		jsr	(AnimateSprite).l
		jmp		SDURF_LoadGfx
	

; more code here if/when i make more
SDURF_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	(BossMHZ_PrevFrame).w,d0
		beq.s	@nochange
		move.b	d0,(BossMHZ_PrevFrame).w
		lea	(DPLC_SDURF).l,a2

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
		move.l	#Art_SDURF,d6

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
; End of function SDURF_LoadGfx

MCirPLC_Return:
		rts
; ===========================================================================
MCir_Delete:
		jmp		DeleteObject
; ===========================================================================
Ani_SDURF:
	dc.w	SDURFAni_Blank-Ani_SDURF
	dc.w	SDURFAni_Idle-Ani_SDURF
	dc.w	SDURFAni_Hurt-Ani_SDURF
	dc.w	SDURFAni_Tired-Ani_SDURF
SDURFAni_Blank:	dc.b	$77,0,afBack,1
	even
SDURFAni_Idle:	dc.b	2,$E,$F,$10,$11,afEnd
	even
SDURFAni_Hurt:	dc.b	$77,1,afEnd
	even
SDURFAni_Tired:	dc.b	2,2,3,4,5,afEnd ; I cannot believe I managed to fucking use afBack instead of afEnd again.
	even