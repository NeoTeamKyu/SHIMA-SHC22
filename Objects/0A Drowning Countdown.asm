; ---------------------------------------------------------------------------
; Object 0A - drowning countdown numbers and small bubbles that float out of
; Sonic's mouth (LZ)
; ---------------------------------------------------------------------------

DrownCount:
		tst.b	(v_player).w	; Why this was cmpi.b #0,(v_player).w instead of tst.b (v_player).w, i have no clue
		bne.s	@cont
		rts
	@cont:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Drown_Index(pc,d0.w),d1
		jmp	Drown_Index(pc,d1.w)
; ===========================================================================
Drown_Index:
ptr_Drown_Main:		dc.w Drown_Main-Drown_Index
ptr_Drown_Animate:	dc.w Drown_Animate-Drown_Index
ptr_Drown_ChkWater:	dc.w Drown_ChkWater-Drown_Index
ptr_Drown_Display:	dc.w Drown_Display-Drown_Index
ptr_Drown_Delete:	dc.w Drown_Delete-Drown_Index
ptr_Drown_Countdown:	dc.w Drown_Countdown-Drown_Index
ptr_Drown_AirLeft:	dc.w Drown_AirLeft-Drown_Index
ptr_Drown_DisplayNumber:	dc.w Drown_DisplayNumber-Drown_Index
			dc.w Drown_Delete-Drown_Index

drown_origX:	equ $30		; original x-axis position
drown_count:	equ	$36
drown_time:		equ $38		; time between each number changes
drownframenum:	equ $3C		; Frame to display

id_Drown_Main:		equ ptr_Drown_Main-Drown_Index		; 0
id_Drown_Animate:	equ ptr_Drown_Animate-Drown_Index		; 2
id_Drown_ChkWater:	equ ptr_Drown_ChkWater-Drown_Index	; 4
id_Drown_Display:	equ ptr_Drown_Display-Drown_Index		; 6
id_Drown_Delete:		equ ptr_Drown_Delete-Drown_Index		; 8
id_Drown_Countdown:	equ ptr_Drown_Countdown-Drown_Index	; $A
id_Drown_AirLeft:	equ ptr_Drown_AirLeft-Drown_Index		; $C
id_Drown_DisplayNumber:	equ ptr_Drown_DisplayNumber-Drown_Index	; $E
; ===========================================================================

Drown_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bub,obMap(a0)
		move.w	#$8000+vramBubblesBGZ,obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$80,obPriority(a0)
		move.b	obSubtype(a0),d0 ; get bubble type
		bpl.s	@smallbubble	; branch if $00-$7F

		addq.b	#8,obRoutine(a0) ; goto Drown_Countdown next
		move.l	#Map_Drown,obMap(a0)	; Huh?
		move.w	#$440,obGfx(a0)	; Uhhh... I don't think this is used at all...?
		andi.w	#$7F,d0
		move.b	d0,$33(a0)
		bra.w	Drown_Countdown
; ===========================================================================

@smallbubble:
		move.b	d0,obAnim(a0)
		move.w	obX(a0),drown_origX(a0)
		move.w	#-$88,obVelY(a0)

Drown_Animate:	; Routine 2
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l

Drown_ChkWater:	; Routine 4
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; has bubble reached the water surface?
		bcs.s	@wobble		; if not, branch

		move.b	#id_Drown_Display,obRoutine(a0) ; goto Drown_Display next
		addq.b	#7,obAnim(a0)	; Inferno tipped me off about this one (Gem)
		cmpi.b	#$D,obAnim(a0)
		beq.s	Drown_Display
		bcs.s	Drown_Display
		move.b	#$D,obAnim(a0)
		bra.s	Drown_Display
; ===========================================================================

@wobble:
		tst.b	(f_wtunnelmode).w ; is Sonic in a water tunnel?
		beq.s	@notunnel	; if not, branch
		addq.w	#4,drown_origX(a0)

	@notunnel:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea	(Drown_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	drown_origX(a0),d0
		move.w	d0,obX(a0)
		bsr.w	Drown_ShowNumber
		jsr	(SpeedToPos).l
		tst.b	obRender(a0)
		bpl.s	@delete
		jmp	(DisplaySprite).l

	@delete:
		jmp	(DeleteObject).l
; ===========================================================================

Drown_DisplayNumber:	; Routine $E
		cmpi.w	#$C,(v_air).w
		bhi.s	Drown_Delete

Drown_Display2:
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l
		bsr.s	Drown_ShowNumber
		bsr.w	Countdown_LoadGfx
		jmp	(DisplaySprite).l

Drown_Display:	; Routine 6
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l
		bsr.s	Drown_ShowNumber
		jmp	(DisplaySprite).l
; ===========================================================================

Drown_Delete:	; Routine 8, Routine $10
		jmp	(DeleteObject).l
; ===========================================================================

Drown_AirLeft:	; Routine $C
		cmpi.w	#$C,(v_air).w	; check air remaining
		bhi.s	Drown_AirLeft_Delete		; if higher than $C, branch
		subq.w	#1,drown_time(a0)
		bne.s	@display
		move.b	#id_Drown_DisplayNumber,obRoutine(a0) ; goto Drown_DisplayNumber next
		addq.b	#7,obAnim(a0)
		bra.s	Drown_Display2
; ===========================================================================

	@display:
		lea	(Ani_Drown).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRender(a0)
		bpl.s	Drown_AirLeft_Delete
		bsr.w	Countdown_LoadGfx
		jmp	(DisplaySprite).l

Drown_AirLeft_Delete:	
		jmp	(DeleteObject).l
; ===========================================================================

Drown_ShowNumber:
		tst.w	drown_time(a0)
		beq.s	@nonumber
		subq.w	#1,drown_time(a0)	; decrement timer
		bne.s	@nonumber	; if time remains, branch
		cmpi.b	#7,obAnim(a0)
		bcc.s	@nonumber

		move.l	#Map_Countdown,obMap(a0)
		move.w	#$8000+vramDrownCount,obGfx(a0)
		move.b	#-1,drownframenum(a0)
		move.w	#15,drown_time(a0)
		clr.w	obVelY(a0)
		move.b	#$80,obRender(a0)
		move.w	obX(a0),d0
		sub.w	(v_screenposx).w,d0
		addi.w	#$80,d0
		move.w	d0,obX(a0)
		move.w	obY(a0),d0
		sub.w	(v_screenposy).w,d0
		addi.w	#$80,d0
		move.w	d0,obY(a0)
		move.b	#id_Drown_AirLeft,obRoutine(a0) ; goto Drown_AirLeft next
		bra.w	Countdown_LoadGfx

	@nonumber:
		rts	
; ===========================================================================
Drown_WobbleData:
		dc.b 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3
		dc.b -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1
		dc.b 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3
		dc.b -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1
; ===========================================================================

Drown_Countdown:; Routine $A
		tst.w	$2C(a0)
		bne.w	@loc_13F86
		cmpi.b	#shID_Bubb,(v_shield).w	; does Sonic have a bubble shield?
		beq.w	@nocountdown	; if so, branch
		cmpi.b	#6,(v_player+obRoutine).w
		bcc.w	@nocountdown
		btst	#6,(v_player+obStatus).w ; is Sonic underwater?
		beq.w	@nocountdown	; if not, branch

		subq.w	#1,drown_time(a0)	; decrement timer
		bpl.w	@nochange	; branch if time remains
		move.w	#59,drown_time(a0)
		move.w	#1,drown_count(a0)
		jsr	(RandomNumber).l
		andi.w	#1,d0
		move.b	d0,$34(a0)
		move.w	(v_air).w,d0	; check air remaining
		cmpi.w	#25,d0
		beq.s	@warnsound	; play sound if	air is 25
		cmpi.w	#20,d0
		beq.s	@warnsound
		cmpi.w	#15,d0
		beq.s	@warnsound
		cmpi.w	#12,d0
		bhi.s	@reduceair	; if air is above 12, branch

	;	bne.s	@skipmusic	; if air is less than 12, branch
	;	music	mus_Drowning	; play countdown music

	@skipmusic:
		subq.b	#1,$32(a0)
		bpl.s	@reduceair
		move.b	$33(a0),$32(a0)
		bset	#7,drown_count(a0)
		bra.s	@reduceair
; ===========================================================================

@warnsound:
		sfx	sfx_AirDing	; play "ding-ding" warning sound

@reduceair:
		subq.w	#1,(v_air).w	; subtract 1 from air remaining
		bcc.w	@gotomakenum	; if air is above 0, branch

		; Sonic drowns here
	;	bsr.w	ResumeMusic
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_objspace+$340+$32).w
		move.b	#$81,(f_lockmulti).w ; lock controls
		sfx	sfx_Drown	; play drowning sound
		move.b	#$A,$34(a0)
		move.w	#1,drown_count(a0)
		move.w	#$78,$2C(a0)
		move.l	a0,-(sp)
		lea	(v_player).w,a0
		bsr.w	Player_ResetOnFloor
		move.b	#id_Drown,obAnim(a0)	; use Sonic's drowning animation
		bset	#1,obStatus(a0)
		bset	#7,obGfx(a0)
		move.w	#0,obVelY(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		move.b	#1,(f_nobgscroll).w
		movea.l	(sp)+,a0
		rts	
; ===========================================================================

@loc_13F86:
		subq.w	#1,$2C(a0)
		bne.s	@loc_13F94
		move.b	#6,(v_player+obRoutine).w
		rts	
; ===========================================================================

	@loc_13F94:
		move.l	a0,-(sp)
		lea	(v_player).w,a0
		jsr	(SpeedToPos).l
		addi.w	#$10,obVelY(a0)
		movea.l	(sp)+,a0
		bra.s	@nochange
; ===========================================================================

@gotomakenum:
		bra.s	@makenum
; ===========================================================================

@nochange:
		tst.w	drown_count(a0)
		beq.w	@nocountdown
		subq.w	#1,$3A(a0)
		bpl.w	@nocountdown

@makenum:
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,$3A(a0)
		jsr	(FindFreeObj).l
		bne.w	@nocountdown
		move.b	#id_DrownCount,0(a1) ; load object
		move.w	(v_player+obX).w,obX(a1) ; match X position to Sonic
		moveq	#6,d0
		btst	#0,(v_player+obStatus).w
		beq.s	@noflip
		neg.w	d0
		move.b	#$40,obAngle(a1)

	@noflip:
		add.w	d0,obX(a1)
		move.w	(v_player+obY).w,obY(a1)
		move.b	#6,obSubtype(a1)
		tst.w	$2C(a0)
		beq.w	@loc_1403E
		andi.w	#7,$3A(a0)
		addi.w	#0,$3A(a0)
		move.w	(v_player+obY).w,d0
		subi.w	#$C,d0
		move.w	d0,obY(a1)
		jsr	(RandomNumber).l
		move.b	d0,obAngle(a1)
		move.w	(v_framecount).w,d0
		andi.b	#3,d0
		bne.s	@loc_14082
		move.b	#$E,obSubtype(a1)
		bra.s	@loc_14082
; ===========================================================================

@loc_1403E:
		btst	#7,drown_count(a0)
		beq.s	@loc_14082
		sfx	sfx_Countdown
		move.w	(v_air).w,d2
		lsr.w	#1,d2
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	@loc_1406A
		bset	#6,drown_count(a0)
		bne.s	@loc_14082
		move.b	d2,obSubtype(a1)
		move.w	#$1C,drown_time(a1)

	@loc_1406A:
		tst.b	$34(a0)
		bne.s	@loc_14082
		bset	#6,drown_count(a0)
		bne.s	@loc_14082
		move.b	d2,obSubtype(a1)
		move.w	#$1C,drown_time(a1)

@loc_14082:
		subq.b	#1,$34(a0)
		bpl.s	@nocountdown
		clr.w	drown_count(a0)

@nocountdown:
		rts	

; ---------------------------------------------------------------------------
; Countdown	graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Countdown_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	drownframenum(a0),d0
		beq.s	@nochange
		move.b	d0,drownframenum(a0)
		lea	(DPLC_Countdown).l,a2

		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		move.l	#Art_Countdown,d6

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
; End of function Countdown_LoadGfx