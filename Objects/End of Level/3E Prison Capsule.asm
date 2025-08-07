; ----------------------------------------------------------------------------
; Object 3E - prison capsule, ported from Sonic 2 because I like that one better.
; ----------------------------------------------------------------------------
; Sprite_3F1E4:
Prison:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pri_Index(pc,d0.w),d1
		jmp	Pri_Index(pc,d1.w)
; ===========================================================================
; off_3F1F2:
Pri_Index:
		dc.w	Pri_LoadVars-Pri_Index	;  0
		dc.w	Pri_BodyMain-Pri_Index	;  2
		dc.w	Pri_Switched-Pri_Index	;  4
		dc.w	loc_3F38E-Pri_Index	;  6
		dc.w	Pri_Animals-Pri_Index	;  8
		dc.w	Pri_EndAct-Pri_Index	; $A

pri_origY:	equ $30		; original y-axis position

Pri_Var:	; ???, routine, width, frame, priority (high and low bytes)
		dc.b	0,	2,$20,	0,	$02,	$00
		dc.b	$28,4,$10,	4,	$02,	$80	; 5
		dc.b	$18,6,	8,	5,	$01,	$80	; 10
		dc.b	0,	8,$20,	0,	$02,	$00	; 15
; ===========================================================================

Pri_LoadVars:
		movea.l	a0,a1
		lea		$38(a0),a3 ; then advances to $3A then $3C
		lea		Pri_Var(pc),a2
		moveq	#3,d1
		bra.s	Pri_Main
; ===========================================================================

Pri_MainLoop:
		jsr		FindFreeObj
		bne.s	loc_3F272
		move.w	a1,(a3)+

Pri_Main:
		move.b	0(a0),0(a1) ; load obj
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obY(a0),pri_origY(a1)
		move.l	#Map_Pri,obMap(a1)
		move.w	#$49D,obGfx(a1)
		move.b	#$84,obRender(a1)
		moveq	#0,d0
		move.b	(a2)+,d0
		sub.w	d0,obY(a1)
		move.w	obY(a1),pri_origY(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obActWid(a1)
		move.b	(a2)+,obFrame(a1)
		move.w	(a2)+,obPriority(a1)

loc_3F272:
		dbf	d1,Pri_MainLoop
		rts
; ===========================================================================

Pri_BodyMain:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	off_3F2AE(pc,d0.w),d1
		jsr		off_3F2AE(pc,d1.w)
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	#$18,d3
		move.w	obX(a0),d4
		lea		(v_player).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		jsr		(SolidObject).l
		movem.l	(sp)+,d1-d4
		;btst	#3,obStatus(a0)
		;beq.s	@RemeberBranch
		lea		(Ani_Prison).l,a1
		jsr		(AnimateSprite).l
;@RemeberBranch:
		jmp		(RememberState).l
; ===========================================================================
off_3F2AE:
		dc.w	Pri_Explosion-off_3F2AE	; 0
		dc.w	Pri_MakeAnimals-off_3F2AE	; 2
		dc.w	Pri_Return-off_3F2AE	; 4
; ===========================================================================

Pri_Explosion:
		movea.w	$38(a0),a1 ; a1=object
		tst.w	$32(a1)
		beq.s	@ret	; rts
		movea.w	$3A(a0),a2 ; a2=object
		jsr		(FindFreeObj).l
		bne.s	@noKaboom
		move.b	#id_ExplosionItem,0(a1) ; load explosion object
		addq.b	#2,obRoutine(a1) ; don't create an animal
		move.w	obX(a2),obX(a1)
		move.w	obY(a2),obY(a1)
	@noKaboom:
		move.w	#-$400,obVelY(a2)
		move.w	#$800,obVelX(a2)
		addq.b	#2,ob2ndRout(a2)
		move.w	#$1D,$34(a0)
		addq.b	#2,ob2ndRout(a0)
	@ret:
		rts
; ===========================================================================

Pri_MakeAnimals:
		subq.w	#1,$34(a0)
		bpl.s	Pri_Return
		move.b	#1,anim(a0)
		moveq	#7,d6
		move.w	#$9A,d5
		moveq	#-$1C,d4

	@loop:
		jsr		(FindFreeObj).l
		bne.s	@endLoop
		move.b	#id_Animals,0(a1) ; load obj
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		add.w	d4,obX(a1)
		move.b	#1,$38(a1)
		addq.w	#7,d4
		move.w	d5,$36(a1)
		subq.w	#8,d5
		dbf		d6,@loop

	@endLoop:
		movea.w	$3C(a0),a2 ; a2=object
		move.w	#180,obTimeFrame(a2)
		addq.b	#2,ob2ndRout(a2)
		addq.b	#2,ob2ndRout(a0)

Pri_Return:
		rts
; ===========================================================================

Pri_Switched:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#8,d3
		move.w	obX(a0),d4
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		jsr		(SolidObject).l
		movem.l	(sp)+,d1-d4
		move.w	pri_origY(a0),obY(a0)

		btst	#3,obStatus(a0)
		beq.s	@del

		addq.w	#8,obY(a0)
		clr.b	(f_timecount).w
		clr.b	(f_lockscreen).w ; lock screen position
		move.b	#1,(f_lockctrl).w ; lock controls
		move.w	#0,(v_jpadhold2).w ; stop the character from moving
		move.w	#1,$32(a0) ; set stod on flag

	@del:
		jmp		(RememberState).l
; ===========================================================================

loc_3F38E:
		tst.b	ob2ndRout(a0)
		beq.s	@del
		tst.b	obRender(a0)
		jpl		DeleteObject	; haha yeah i get to use those fancy schmancy macros now c:<
		jsr		(ObjectFall).l
	@del:
		jmp		(RememberState).l
; ===========================================================================

Pri_Animals:
		tst.b	ob2ndRout(a0)
		beq.s	@wait
		move.b	(v_vbla_byte).w,d0 ; This is weird. S1 does it in reverse-- moveq #7 to d0, then and.b v_vbla_byte to d0.
		andi.b	#7,d0
		bne.s	@noanimal
		jsr		(FindFreeObj).l
		bne.s	@noanimal
		move.b	#id_Animals,0(a1) ; load obj
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).l
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	@ispositive
		neg.w	d0

	@ispositive:
		add.w	d0,obX(a1)
		move.b	#1,$38(a1)
		move.w	#$C,$36(a1)

	@noanimal:
		subq.w	#1,obTimeFrame(a0)
		bne.s	@wait
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)

	@wait:
		rts
; ===========================================================================

Pri_EndAct:	; Routine $E
		moveq	#LevObjNum-1,d0
		moveq	#id_Animals,d1
		lea		(v_lvlobjspace).w,a1 ; load object RAM

	@findanimal:
		cmp.b	(a1),d1		; is object $28	(animal) loaded?
		beq.s	@found		; if yes, branch
		lea		SstLimit(a1),a1 ; a1=object
		dbf		d0,@findanimal	; repeat $3E times

		jsr		(GotThroughAct).l
		jmp		(DeleteObject).l

	@found:
		rts
; ===========================================================================
; animation script
; off_3F428:
Ani_Prison:
		dc.w	@close-Ani_Prison	; 0
		dc.w	@open-Ani_Prison	; 1

@close:	dc.b	$F,	0,	afEnd
		even
@open:	dc.b	3,	0,	1,	2,	3,	afBack,	1
		even