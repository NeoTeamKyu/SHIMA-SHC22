CDFlapdoor:
	pea		RememberState
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	@routines(pc,d0.w),d0
	jsr	@routines(pc,d0.w)
	lea	Ani_Flapdoor,a1
	jmp	AnimateSprite

; ===========================================================================
@routines:
	dc.w	CDFlapdoor_Init-@routines
	dc.w	CDFlapdoor_Main-@routines

; ===========================================================================

CDFlapdoor_Init:
	addq.b	#2,obRoutine(a0)
	move.l	#Map_FlapdoorH,obMap(a0)
	cmp.b	#1,obSubtype(a0)
	bne.s	@hor
	move.l	#Map_FlapdoorV,obMap(a0)
@hor:
	move.w	#$80,obPriority(a0)
	move.b	#4,obRender(a0)
	moveq	#36,d0
	moveq	#8,d1
	cmp.b	#1,obSubtype(a0)	; is this a vertical flapdoor?
	bne.s	@notvert	; if not, branch
	exg		d0,d1
@notvert:
	move.b	d0,obActWid(a0)
	move.b	d1,obHeight(a0)
	move.w	#vramFlapBGZ,obGfx(a0)
CDFlapdoor_Main:
	lea		(v_player).w,a1
	move.b	obStatus(a1),-(sp)
	move.b	obStatus(a0),-(sp)
	move.w	obY(a1),-(sp)
	move.w	obX(a1),-(sp)
	move.w	obInertia(a1),-(sp)
	move.w	obVelX(a1),-(sp)
	move.w	obVelY(a1),-(sp)
	moveq	#0,d1
	add.b	obActWid(a0),d1
	moveq	#0,d2
	add.b	obHeight(a0),d2
	moveq	#2/2,d3		; Sonic's rolling collision height delta or smth
	add.b	obHeight(a0),d3
	move.w	obX(a0),d4
	lea		Solid_ResetFloor,a3
	cmp.b	#1,obSubtype(a0)
	beq.s	@solidtop
	btst	#1,obStatus(a0)
	beq.s	@solidtop
	lea		Solid_Return,a3
@solidtop:	
	jsr	SolidObject06
	tst.b	d4	; have Sonic collided with the object?
	beq.w	@return	; if not, branch
	cmp.b	#1,obSubtype(a0)
	beq.s	@ver
	btst	#1,obStatus(a0)
	bne.s	@vflip
	tst.w	(sp)	; was Sonic going up?
	bpl.w	@return	; if not, branch	
	bra.s	@restorpos

@vflip:
	tst.w	(sp)	; was Sonic going down?
	ble.w	@return	; if not, branch	
	bra.s	@restorpos

@ver:
	move.w	obX(a0),d0
	moveq	#0,d1
	move.b	obActWid(a0),d1
	btst	#0,obStatus(a0)
	bne.s	@hflip
	add.w	d1,d0
	subq.w	#1,d0
	sub.w	6(sp),d0
	bls.s	@return
	moveq	#0,d1
	move.b	2(sp),d1
	sub.w	d1,d0
	bls.s	@return
	tst.w	2(sp)	; was Sonic going right?
	bge.s	@restorpos	; if so, branch
	tst.w	4(sp)	; was Sonic going right?
	bge.s	@restorpos	; if so, branch
	bra.s	@return

@hflip:
	sub.w	d1,d0
	addq.w	#1,d0
	sub.w	6(sp),d0
	bhs.s	@return
	moveq	#0,d1
	move.b	2(sp),d1
	add.w	d1,d0
	bhs.s	@return
	tst.w	2(sp)	; was Sonic going left?
	ble.s	@restorpos	; if so, branch
	tst.w	4(sp)	; was Sonic going left?
	ble.s	@restorpos	; if so, branch
	bra.s	@return

@restorpos:
	; restore position and velocity before collision as if it didn't happen
	move.w	(sp)+,obVelY(a1)
	move.w	(sp)+,obVelX(a1)
	move.w	(sp)+,obInertia(a1)
	move.w	(sp)+,obX(a1)
	move.w	(sp)+,obY(a1)
	move.b	(sp)+,obStatus(a0)
	move.b	(sp)+,obStatus(a1)
	move.b	#1,obAnim(a0)
	rts
@return:
	lea		7*2(sp),sp
	rts

; ===========================================================================

Ani_Flapdoor:
	dc.w	@ani0-Ani_Flapdoor
	dc.w	@ani1-Ani_Flapdoor

; ===========================================================================

@ani0:
	dc.b	0,0,afEnd
@ani1:	
	dc.b	  1,0,1,1,1,1,afChange,0
	even

; ===========================================================================
