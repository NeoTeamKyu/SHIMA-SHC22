
Abbey:
		pea     DisplaySprite   ; make deffered call of DisplaySprite
		moveq   #0,d0
		move.b  obRoutine(a0),d0    ; get current routine into d0
		move.w  @routines(pc,d0.w),d0 ; get routine offset into d0
		jmp     @routines(pc,d0.w)  ; jump to the routine pointer
; ===========================================================================

@routines:
		dc.w    Abbey_Init-@routines ; 0
		dc.w    Abbey_FindRings-@routines ; 2
		dc.w    Abbey_CheckTarget-@routines ; 4
		dc.w    Abbey_CheckRings-@routines ; 6

	; Variables

	rsset   obSubtype
Abbey_prevFrame:  rs.b    1 ; previous mapping frame
Abbey_Angle:  	 rs.b    1 ; Abbey's Angle
Abbey_Speed:	rs.w	1
Abbey_Target:	rs.w	1
Abbey_TargetX:	rs.w	1
Abbey_TargetY:	rs.w	1
Abbey_TargetCol:	rs.w	1
Abbey_TargetHeight:	rs.b	1
; ===========================================================================

Abbey_Init:
		move.l  #Map_Abbey,obMap(a0)    ; setup mappings
		move.b  #4,obRender(a0)	 ; enable worlds coordinates flag
		move.w  #$80,obPriority(a0)       ; setup render priority
		move.b  #8,obActWid(a0)	 ; setup render width radius
		move.w  #vramAbbey,obGfx(a0)	 ; setup graphics tile and flags
		lea		(v_player).w,a1	 ; get player object into a1
		move.w  obX(a1),obX(a0)	; inherit X pos
		move.w  obY(a1),obY(a0)	; inherit Y pos
		move.w	#0,obVelX(a0)
		move.w	#0,obVelY(a0)
		addq.b  #2,obRoutine(a0)	; go to the next routine
		move.w	#$600,Abbey_Speed(a0)
		move.b	#0,Abbey_Angle(a0)
; ===========================================================================

Abbey_FindRings:
		moveq	#-1,d1
		movea.l	(Ring_start_addr_ROM).w,a1	; load start and end addresses
        movea.l	(Ring_end_addr_ROM).w,a2
        cmpa.l	a1,a2	; are there no rings in this area?
        beq.w	Abbey_ChooseTarget	; if so, return
        movea.w	(Ring_start_addr_RAM).w,a4	; load start address
        bra.s	@start

    @next:
		addq.l	#4,a1
		addq.l	#2,a4
		cmpa.l	a1,a2		; are we at the last ring for this area?
		beq.s	@touch		; repeat $5F more times

	@start:
		tst.w	(a4)	; has this ring already been collided with?
		bne.w	@next	; if it has, branch
		move.w	(a1),d3	; load object's x-axis position
		move.w	2(a1),d4	; load object's y-axis position
		sub.w	obX(a0),d3
		muls.w	d3,d3
		sub.w	obY(a0),d4
		muls.w	d4,d4
		add.l	d4,d3
		cmp.l	d3,d1
		bls.w	@next
		move.l	d3,d1
		movea.l	a1,a3
		movea.l	a4,a5
		bra.w	@next

	@touch:
		cmpi.l	#-1,d1
		beq.w	Abbey_ChooseTarget
		move.w	(a3),d3	; load object's x-axis position
		move.w	2(a3),d4	; load object's y-axis position
		sub.w	(v_screenposx).w,d3
		sub.w	(v_screenposy).w,d4
		cmpi.w	#$140,d3
		bhi.w	Abbey_ChooseTarget
		cmpi.w	#$E0,d4
		bhi.w	Abbey_ChooseTarget
		move.l	(a3),Abbey_TargetX(a0)
		move.w	a5,Abbey_TargetCol(a0)
		move.b	#3,Abbey_TargetHeight(a0)
		addq.b	#4,obRoutine(a0) ; advance the object's routine counter

Abbey_CheckRings:
		move.w	obX(a0),d2	; get character's position
		move.w	obY(a0),d3
		subi.w	#3,d2	; assume X radius to be 3
		moveq	#0,d5
	;	move.b	obHeight(a0),d5
	;	subq.b	#3,d5
		sub.w	d5,d3	; subtract (Y radius - 3) from Y pos
		move.w	#6,d1	; set ring radius
		move.w	#$C,d6	; set ring diameter
		move.w	#$10,d4	; set character's X diameter
		add.w	d5,d5	; set Y diameter
		move.w	Abbey_TargetCol(a0),a4

	@Touch_Rings_Loop:
		tst.w	(a4)	; has this ring already been collided with?
		bne.w	@destroyed	; if it has, branch
		move.w	Abbey_TargetX(a0),d0		; get ring X pos
		sub.w	d1,d0		; get ring left edge X pos
		sub.w	d2,d0		; subtract character's left edge X pos
		bcc.s	@goSomeWhere1		; if character's to the left of the ring, branch
		add.w	d6,d0		; add ring diameter
		bcs.s	@loc_17130		; if character's colliding, branch
		bra.w	Abbey_Follow	; otherwise, test next ring

; ===========================================================================

@goSomeWhere1:
		cmp.w	d4,d0		; has character crossed the ring?
		bhi.w	Abbey_Follow	; if they have, branch

	@loc_17130:
		move.w	Abbey_TargetY(a0),d0	; get ring Y pos	; why is it 2?
		sub.w	d1,d0		; get ring top edge pos
		sub.w	d3,d0		; subtract character's top edge pos
		bcc.s	@CheckRingLooping		; if character's above the ring, branch
		add.w	d6,d0		; add ring diameter
		bcs.s	@CheckForShield			; if character's colliding, branch
		bra.w	Abbey_Follow	; otherwise, test next ring

	@CheckRingLooping:
		cmp.w	d5,d0		; has character crossed the ring?
		bhi.w	Abbey_Follow	; if they have, branch

	@CheckForShield:
		move.w	#$604,(a4)
		jsr	loc_17168
		lea	(Ring_consumption_table+2).w,a1

	@loc_17152:
		tst.w	(a1)+		; is this slot free?
		bne.s	@loc_17152		; if not, repeat until you find one
		move.w	a4,-(a1)	; set ring address
		addq.w	#1,(Ring_consumption_table).w	; increase count

	@destroyed:
		subq.b	#4,obRoutine(a0)
		bra.w	Abbey_Follow
; ===========================================================================

Abbey_ChooseTarget:
		lea		(v_player).w,a2	 ; get player object into a2
		lea	(v_lvlobjspace).w,a1 ; set object RAM start address
		moveq	#0,d1
		moveq	#-1,d5
		move.w	#LevObjNum-1,d6

	@loop:
		tst.b	obRender(a1)
		bpl.s	@next
		move.b	obColType(a1),d0 ; load collision type
		bne.s	@proximity	; if nonzero, branch

	@next:
		lea	SstLimit(a1),a1	; next object RAM
		dbf	d6,@loop	; repeat $5F more times
		move.w	a2,Abbey_Target(a0)
		movea.w	a2,a1
		cmpi.l	#-1,d5
		beq.w	Abbey_CheckTarget
		move.w	obX(a2),d3	; load object's x-axis position
		move.w	obY(a2),d4	; load object's y-axis position
		sub.w	(v_screenposx).w,d3
		sub.w	(v_screenposy).w,d4
		cmpi.w	#$140,d3
		bhi.s	Abbey_CheckTarget
		cmpi.w	#$E0,d4
		bhi.s	Abbey_CheckTarget
		addq.b	#2,obRoutine(a0)
		bra.w	Abbey_CheckTarget

	@proximity:
		tst.b	d0
		bmi.s	@next
		btst	#6,obRender(a1)
		bne.s	@next
		move.w	obX(a1),d3	; load object's x-axis position
		sub.w	obX(a0),d3
		muls.w	d3,d3
		move.w	obY(a1),d4	; load object's y-axis position
		sub.w	obY(a0),d4
		muls.w	d4,d4
		add.l	d4,d3
		cmp.l	d3,d5
		bls.s	@next
		move.l	d3,d5
		movea.w	a1,a2
		bra.s	@next
; ===========================================================================

Abbey_CheckTarget:
		move.w	Abbey_Target(a0),a1
		move.w	obX(a1),Abbey_TargetX(a0)
		move.w	obY(a1),Abbey_TargetY(a0)
		move.b	obColType(a1),Abbey_TargetCol(a0)
		move.b	obHeight(a1),Abbey_TargetHeight(a0)
		cmpi.l	#v_player,a1
		beq.s	Abbey_Follow
		move.w	obX(a1),d3	; load object's x-axis position
		move.w	obY(a1),d4	; load object's y-axis position
		sub.w	(v_screenposx).w,d3
		sub.w	(v_screenposy).w,d4
		cmpi.w	#$140,d3
		bhi.s	@done
		cmpi.w	#$E0,d4
		bhi.s	@done
		move.b	Abbey_TargetCol(a0),d0
		tst.b	d0
		bne.s	Abbey_Follow

	@done:
		move.b	#2,obRoutine(a0)

Abbey_Follow:
		bsr.w	Abbey_Move
		bclr	#0,obRender(a0)
		move.w  #$80,obPriority(a0)
		tst.w	obVelX(a0)
		bpl.s	@face_right
		bset	#0,obRender(a0)
		move.w  #$180,obPriority(a0)

	@face_right:
		subq.b  #1,obTimeFrame(a0)      ; are we need to change frame?
		bpl.s   @wait		   ; if not, branch
		bchg    #0,obFrame(a0)	  ; change frame
		move.b  #4,obTimeFrame(a0)      ; reset animation timer

	@wait:
		bra.w   Abbey_HandleDPLC
; ===========================================================================

Abbey_Move:
		move.w	Abbey_TargetX(a0),d0
		sub.w	obX(a0),d0
		muls.w	d0,d0
		move.w	Abbey_TargetY(a0),d1
		moveq	#0,d5
		move.b	Abbey_TargetHeight(a0),d5
		sub.w	d5,d1
		sub.w	obY(a0),d1
		muls.w	d1,d1
		add.l	d1,d0
		move.l	d0,d6
		lsr.l	#6,d0
		add.l	#$200,d0
		moveq	#0,d1
		move.w	Abbey_Speed(a0),d1
		sub.l	d1,d0
		andi.b	#$C0,d0
		tst.l	d0
		beq.s	@speedset
		addi.w	#$40,d1
		tst.l	d0
		bpl.s	@speedset
		subi.w	#$80,d1

	@speedset:
		move.w	d1,Abbey_Speed(a0)
		move.w	Abbey_TargetX(a0),d1
		sub.w	obX(a0),d1
		move.w	Abbey_TargetY(a0),d2
		sub.w	obY(a0),d2
		jsr	(CalcAngle).l
		move.b	d0,d4
		move.b	Abbey_Angle(a0),d3
		sub.b	d3,d4
		jsr	(RandomNumber).l
		andi.b	#$3F,d0
		sub.b	#$20,d0
		add.b	d4,d0
		asr.b	#3,d0
		move.b	(v_player).w,d1
		cmp.b	(a1),d1
		beq.s	@sonic
		cmpi.l	#$200,d6
		bcs.s	@clockwise
		cmpi.l	#$400,d6
		bcs.s	@sonic
		asr.b	#1,d0

	@sonic:
		asr.b	#1,d0

	@clockwise:
		add.b	d3,d0
		move.b	d0,Abbey_Angle(a0)
		jsr	(CalcSine).l
		muls.w	Abbey_Speed(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	Abbey_Speed(a0),d0
		asr.l	#8,d0
		asr.l	#1,d0
		move.w	d0,obVelY(a0)
		jmp	SpeedToPos

; ===========================================================================
; ---------------------------------------------------------------------------
; Copy of Sonic_LoadGFX
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Abbey_HandleDPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	Abbey_prevFrame(a0),d0
		beq.s	@nochange
		move.b	d0,Abbey_prevFrame(a0)
		lea	(DPLC_Abbey).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		move.l	#Art_Abbey,d6
		tst.b	(v_super).w
		beq.s	@readentry
		move.l	#Art_SuperAbbey,d6

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
; End of function Sonic_LoadGfx