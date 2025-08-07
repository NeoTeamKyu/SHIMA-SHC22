; ===========================================================================
; ----------------------------------------------------------------------------
; Object 90 - Obj_HyperSonic_Stars from 0517
; ----------------------------------------------------------------------------
HyperStars_Object:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	HyperStars_Object_Index(pc,d0.w),d1
		jmp		HyperStars_Object_Index(pc,d1.w)
; ===========================================================================
; off_1E0FE: HyperStars_Object_States:
HyperStars_Object_Index:
		dc.w	HyperStars_Object_Init-HyperStars_Object_Index		; 0
		dc.w	HyperStars_Object_InitMain-HyperStars_Object_Index	; 2
		dc.w	HyperStars_Object_Main-HyperStars_Object_Index		; 4
		dc.w	HyperStars_Object_Main_child-HyperStars_Object_Index; 6
; ===========================================================================
; loc_1E102:
HyperStars_Object_Init:
		move.l	#Art_HyperStars,d1
		move.w	#vramShield*$20,d2
		move.w	#$230,d3	; updated from #$100, because this finally transfers the whole file
		jsr		(QueueDMATransfer).l
		lea		(a0),a1
		moveq	#0,d0
		moveq	#0,d2
		moveq	#4-1,d1
	@createObject:
		move.b	0(a0),0(a1) ; load HyperStars_Object
		move.b	#2,obRoutine(a1)
		move.b	d0,obAngle(a1)
		addi.b	#$40,d0
		addq.b	#1,d2
		move.b	d2,obTimeFrame(a1)
		lea		SstLimit(a1),a1
		dbf		d1,@createObject
; ---------------------------------------------------------------------------
HyperStars_Object_InitMain:
		subq.b	#1,obTimeFrame(a0)
		bne.s	@return
		move.l	#Map_HyperStars,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.w	#vramShield,obGFX(a0)
		move.b	#6,obFrame(a0)
		cmpa.w	#v_invinc,a0
		beq.s	@isParent
		move.b	#6,obRoutine(a0)
		bra.s	HyperStars_Object_Main_child
	@return:
		rts
; ---------------------------------------------------------------------------

	@isParent:
		addq.b	#2,obRoutine(a0)

HyperStars_Object_Main:
		tst.b	obAnim(a0)
		beq.s	HyperStars_Object_Main_child
		clr.b	obAnim(a0)
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		moveq	#2,d2

HyperStars_Object_Main_child:
		tst.b	(v_super).w
		jeq		DeleteObject
		addq.b	#1,obFrame(a0)
		cmpi.b	#6,obFrame(a0)
		bcs.s	@belowFrame6
		move.b	#0,obFrame(a0)

	@belowFrame6:
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		asl.w	#5,d1
		move.w	d1,d3
		move.w	d1,d2
		move.b	$30(a0),d0
		jsr		(CalcSine).l
		asr.w	#4,d0
		addi.w	#$40,d0 ; '@'
		sub.b	(v_player+obAngle).w,d0
		jsr		(CalcSine).l
		muls.w	d0,d2
		muls.w	d1,d3
		swap	d2
		swap	d3
		add.w	(v_player+obX).w,d2
		add.w	(v_player+obY).w,d3
		move.w	d2,obX(a0)
		move.w	d3,obY(a0)
		move.w	#$80,obPriority(a0)
		tst.b	obAngle(a0)
		bpl.s	@cont
		move.w	#$100,obPriority(a0)

	@cont:
		addq.b	#8,obAngle(a0)
		addq.b	#4,$30(a0)
		andi.w	#$7FFF,obGFX(a0)
		tst.b	(v_player+obGFX).w
		bpl.s	@display
		ori.w	#$8000,obGFX(a0)

	@display:
		jmp		(DisplaySprite).l