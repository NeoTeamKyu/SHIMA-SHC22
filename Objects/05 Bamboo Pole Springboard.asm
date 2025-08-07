obVar2A = $2A
obVar2B = $2B
obVar2C = $2C

BambooSpringboard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BambooSpringboard_Index(pc,d0.w),d0
		jsr	BambooSpringboard_Index(pc,d0.w)
		bsr.w	DisplaySprite
		out_of_range_resp	DeleteObject
		rts
; End of function BambooSpringboard

; -------------------------------------------------------------------------------
BambooSpringboard_Index:
		dc.w	BambooSpringboard_Init-BambooSpringboard_Index
		dc.w	BambooSpringboard_MainNormal-BambooSpringboard_Index
		dc.w	BambooSpringboard_BounceNormal-BambooSpringboard_Index
; -------------------------------------------------------------------------------

BambooSpringboard_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#MapSpr_SpringBoard,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#$18,obWidth(a0)
		move.b	#4,obHeight(a0)
		move.w	#vramSprBrdBGZ,obGfx(a0)
		bclr	#0,obRender(a0)
		tst.b	obSubtype(a0)
		bne.s	@Flip
		btst	#0,obStatus(a0)
		beq.s	@NoFlip

	@Flip:
		bset	#0,obRender(a0)

	@NoFlip:
		rts
; End of function BambooSpringboard_Init

; -------------------------------------------------------------------------------

BambooSpringboard_MainNormal:
		lea	(v_player).w,a1
		cmpi.b	#6,(v_player+obRoutine).w	; Don't touch if you're dead.
		beq.s	@NoTouch
		cmpi.b	#8,(v_player+obRoutine).w	; Don't touch if you're drowning, either.
		beq.s	@NoTouch
		tst.b	(v_debuguse).l
		bne.s	@NoTouch
		moveq	#0,d0
		bsr.w	BambooSpringboard_Platform
		tst.b	d1
		beq.s	@NoTouch
		move.l	obY(a0),d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		swap	d1
		sub.l	d1,d0
		move.l	d0,obY(a1)
		addq.b	#2,obRoutine(a0)

	@NoTouch:
		rts
; End of function BambooSpringboard_MainNormal
; -------------------------------------------------------------------------------

BambooSpringboard_BounceNormal:
		move.b	#1,obAnim(a0)
		lea 	(v_player).w,a1
		clr.b	obDoubleJump(a1)
		cmpi.b	#4,obRoutine(a1)	; Softlock prevention!
		bne.s	@notHurt
		move.b	#2,obRoutine(a1)
	@notHurt:
		moveq	#1,d0
		bsr.w	BambooSpringboard_Platform
		tst.b	d1
		beq.s	@Touching
		move.w	obVelY(a1),d0
		addi.w	#$100,d0
		cmpi.w	#$A00,d0
		bmi.s	@CapYVel
		move.w	#$A00,d0

	@CapYVel:
		move.w	d0,d1
		addi.w	#$100,d1
		lsr.w	d1
		move.w	d1,obVar2C(a0)
		neg.w	d0
		move.w	d0,obVelY(a1)
		move.b	#$40,obVar2A(a0)
		tst.b	(v_springshoes).w
		bne.s	@Shoes
		bset	#1,obStatus(a1)
		beq.s	@ClearJump
		clr.b	obJumping(a1)

	@ClearJump:
		bclr	#5,obStatus(a1)
		clr.b	obStickToConvex(a1)
		move.b	#$E,obHeight(a1)
		move.b	#7,obWidth(a1)
		addq.w	#5,obY(a1)
		bset	#2,obStatus(a1)
		move.b	#id_Spring,obAnim(a1)	; Let's try this-- it sounds a little nicer.

	@Shoes:
		sfx		sfx_Springboard
		move.b	#0,obDelayAni(a0)
		move.b	#0,obVar2A(a0)
		move.b	obVar2C(a0),obVar2B(a0)

	@Touching:
		subq.b	#1,obVar2A(a0)
		bpl.s	@Frame
		move.b	obDelayAni(a0),obVar2A(a0)
		moveq	#0,d0
		move.b	obAniFrame(a0),d0
		addq.b	#1,d0
		andi.b	#3,d0
		move.b	d0,obAniFrame(a0)
		move.b	@AniScript(pc,d0),obFrame(a0)

	@Frame:
		subq.b	#1,obVar2B(a0)
		bpl.s	@CheckDone
		move.b	obVar2C(a0),obVar2B(a0)
		addq.b	#1,obVar2C(a0)
		addq.b	#1,obDelayAni(a0)

	@CheckDone:
		cmpi.b	#8,obDelayAni(a0)
		blo.s	@Done
		tst.b	obFrame(a0)
		beq.s	@ResetFrame

	@Done:
		rts

	@ResetFrame:
		subq.b	#2,obRoutine(a0)
		rts

	@AniScript:
		dc.b	0, 1, 0, 2
; End of function BambooSpringboard_BounceNormal
; -------------------------------------------------------------------------------

BambooSpringboard_Platform:
		tst.b	(v_debuguse).l
		bne.s	@NoTouch
		tst.w	obVelY(a1)
		bpl.s	@ChkTouch

	@NoTouch:
		bclr	#3,obStatus(a0)
		moveq	#0,d1
		rts

	@ChkTouch:
		lea	(BambooSpringboard_Size).l,a2
		andi.w	#7,d0
		asl.w	#2,d0
		lea	(a2,d0.w),a2
		move.w	obX(a0),d0
		move.w	obX(a1),d1
		move.b	obWidth(a1),d3
		ext.w	d3
		move.b	0(a2),d2
		ext.w	d2
		move.w	d0,d4
		move.w	d1,d5
		add.w	d2,d4
		sub.w	d3,d5
		cmp.w	d4,d5
		bpl.s	@ClearRide
		move.b	1(a2),d2
		ext.w	d2
		neg.w	d2
		move.w	d0,d4
		move.w	d1,d5
		sub.w	d2,d4
		add.w	d3,d5
		cmp.w	d5,d4
		bpl.s	@ClearRide
		move.w	obY(a0),d0
		move.w	obY(a1),d1
		move.b	obHeight(a1),d3
		ext.w	d3
		move.b	2(a2),d2
		ext.w	d2
		move.w	d0,d4
		move.w	d1,d5
		add.w	d2,d4
		sub.w	d3,d5
		cmp.w	d4,d5
		bpl.s	@ClearRide
		move.b	3(a2),d2
		ext.w	d2
		neg.w	d2
		move.w	d0,d4
		move.w	d1,d5
		sub.w	d2,d4
		add.w	d3,d5
		cmp.w	d5,d4
		bpl.s	@ClearRide
		bset	#3,obStatus(a0)
		moveq	#-$1,d1
		rts

	@ClearRide:
		bclr	#3,obStatus(a0)
		moveq	#0,d1
		rts
; End of function BambooSpringboard_Platform

; -------------------------------------------------------------------------------
BambooSpringboard_Size:
		dc.b	$C, $F4, 4,	$FC
		dc.b	$C, $F4, $C, 0
; -------------------------------------------------------------------------------
