; ---------------------------------------------------------------------------
; Object 07 - Invincibility Stars
; ---------------------------------------------------------------------------

InvStars_AniScript: equ $30 ; animation script used by sub-objects(in main object it's clear and unused) (4 bytes)
InvStars_SpeedIndex: equ $34  ; (2 bytes)
InvStars_PrevPosIndex: equ $36 ; clear and unused in main object

InvStars:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	InvStars_Index(pc,d0.w),d1
		jmp	InvStars_Index(pc,d1.w)
; ===========================================================================

InvStars_Index:	dc.w @InitObjects-InvStars_Index
		dc.w @MainObject-InvStars_Index
		dc.w @SubObject-InvStars_Index
; ===========================================================================

@SubObjectsData:
; Format:
;	dc.l AnimationScript
;	dc.w $(speed index)(sub3 anim)
	dc.l Ani_InvStars2
	dc.w $0B00	; If this change breaks something, the original value was just $B
	dc.l Ani_InvStars3
	dc.w $160D
	dc.l Ani_InvStars4
	dc.w $2C0D
; ===========================================================================

@InitObjects:
	jsr    (Unc_Stars_Load).l
	moveq    #0,d2
	lea    @SubObjectsData-6(pc),a2
	lea    (a0),a1

	moveq    #3,d1
@initStars:
	move.b	(a0),(a1) ; load obj35
	move.b	#4,obRoutine(a1)		; => @SubObject
	move.l	#Map_InvStars,obMap(a1)
	move.w	#vramShield,obGFX(a1)
	move.b  #%001000100,obRender(a1)
	move.b	#$10,mainspr_width(a1)
	move.b	#2,mainspr_childsprites(a1)
	move.w	obParent(a0),obParent(a1)
	move.b	d2,InvStars_PrevPosIndex(a1)
	addq.w	#1,d2
	move.l	(a2)+,InvStars_AniScript(a1)
	move.w	(a2)+,InvStars_SpeedIndex(a1)
	lea	SstLimit(a1),a1 ; a1=object
	dbf	d1,@initStars

	move.b	#2,obRoutine(a0)		; => @MainObject
	move.b	#4,InvStars_SpeedIndex(a0)

@MainObject:
	lea (v_player).w,a1 ; a1=character
	tst.b   (v_invinc).w
	beq.w	DeleteObject
	move.w	obX(a1),d0
	move.w	d0,obX(a0)
	move.w	obY(a1),d1
	move.w	d1,obY(a0)
	lea	sub2_x_pos(a0),a2
	lea	Ani_InvStars1,a3
	moveq	#0,d5

@getFrame_main:
	move.w	$38(a0),d2
	move.b	(a3,d2.w),d5
	bpl.s	@setFrameAndPosition_main
	clr.w	$38(a0)
	bra.s	@getFrame_main
; ===========================================================================

@setFrameAndPosition_main:
	addq.w	#1,$38(a0)
	lea	InvStars_Speeds,a6
	move.b	InvStars_SpeedIndex(a0),d6
	bsr.w	InvStars_get_speed
	move.w	d2,(a2)+	; sub2_x_pos
	move.w	d3,(a2)+	; sub2_y_pos
	move.w	d5,(a2)+	; sub2_mapframe
	addi.w	#$20,d6
	bsr.w	InvStars_get_speed
	move.w	d2,(a2)+	; sub3_x_pos
	move.w	d3,(a2)+	; sub3_y_pos
	move.w	d5,(a2)+	; sub3_mapframe
	moveq	#$12,d0
	btst	#0,obStatus(a1)
	beq.s	@display_main
	neg.w	d0

@display_main:
	add.b	d0,InvStars_SpeedIndex(a0)
	move.w	#$80,d0
	bra.w	DisplaySprite2
; ===========================================================================

@SubObject:
	lea (v_player).w,a1 ; a1=character
	tst.b   (v_invinc).w
	beq.w	DeleteObject
	lea	(v_trackpos).w,a5
	lea	(v_trackPlayer).w,a6

@getPosition_sub:
	move.b	InvStars_PrevPosIndex(a0),d1
	lsl.b	#2,d1
	move.w	d1,d2
	add.w	d1,d1
	add.w	d2,d1
	move.w	(a5),d0
	sub.b	d1,d0
	lea	(a6,d0.w),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	d0,obX(a0)
	move.w	d1,obY(a0)
	lea	sub2_x_pos(a0),a2
	movea.l	InvStars_AniScript(a0),a3

@getFrame_sub:
	move.w	$38(a0),d2
	move.b	(a3,d2.w),d5
	bpl.s	@setFrameAndPosition_sub
	clr.w	$38(a0)
	bra.s	@getFrame_sub
; ===========================================================================

@setFrameAndPosition_sub:
	swap	d5
	add.b	$35(a0),d2
	move.b	(a3,d2.w),d5
	addq.w	#1,$38(a0)
	lea	InvStars_Speeds(pc),a6
	move.b	InvStars_SpeedIndex(a0),d6
	bsr.s	InvStars_get_speed
	move.w	d2,(a2)+	; sub2_x_pos
	move.w	d3,(a2)+	; sub2_y_pos
	move.w	d5,(a2)+	; sub2_mapframe
	addi.w	#$20,d6
	swap	d5
	bsr.s	InvStars_get_speed
	move.w	d2,(a2)+	; sub3_x_pos
	move.w	d3,(a2)+	; sub3_y_pos
	move.w	d5,(a2)+	; sub3_mapframe
	moveq	#2,d0
	btst	#0,obStatus(a1)
	beq.s	loc_1DB20
	neg.w	d0

loc_1DB20:
	add.b    d0,InvStars_SpeedIndex(a0)
	move.w    #(1*$80),d0
	bra.w    DisplaySprite2
; ===========================================================================

InvStars_get_speed:
	andi.w	#$3E,d6 ; limit to 6 bits and clear first bit
	move.b	(a6,d6.w),d2 ; move x-move speed to d2
	move.b	obRender(a6,d6.w),d3 ; move y-move speed to d3
	ext.w	d2
	ext.w	d3
	add.w	d0,d2 ; add object x position to x-move speed
	add.w	d1,d3 ; add object y position to y-move speed
	rts
; ===========================================================================
; Speeds
InvStars_Speeds: ; x-move speed,	y-move speed
		dc.w   $F00,  $F03,  $E06,  $D08,  $B0B,  $80D,  $60E,  $30F
		dc.w    $10, -$3F1, -$6F2, -$8F3, -$BF5, -$DF8, -$EFA, -$FFD
		dc.w  $F000, -$F04, -$E07, -$D09, -$B0C, -$80E, -$60F, -$310
		dc.w   -$10,  $3F0,  $6F1,  $8F2,  $BF4,  $DF7,  $EF9,  $FFC

; ---------------------------------------------------------------------------
; Animation script - invincibility stars
; ---------------------------------------------------------------------------

; The animation script differs from the animate_sprite subroutine
; Every positive byte - mapping
; Every negative byte - loop flag

Ani_InvStars1:	dc.b   8,  5,  7,  6,  6,  7,  5,  8,  6,  7,  7,  6,$FF
	even
Ani_InvStars2:	dc.b   8,  7,  6,  5,  4,  3,  4,  5,  6,  7,$FF
		dc.b   3,  4,  5,  6,  7,  8,  7,  6,  5,  4
	even
Ani_InvStars3:	dc.b   8,  7,  6,  5,  4,  3,  2,  3,  4,  5,  6,  7,$FF
		dc.b   2,  3,  4,  5,  6,  7,  8,  7,  6,  5,  4,  3
	even
Ani_InvStars4:	dc.b   7,  6,  5,  4,  3,  2,  1,  2,  3,  4,  5,  6,$FF
		dc.b   1,  2,  3,  4,  5,  6,  7,  6,  5,  4,  3,  2
	even

Unc_Stars_Load:
	move.l    #Art_InvStars,d1
	move.w    #vramShield*$20,d2
	move.w    #$200,d3
	jsr    (QueueDMATransfer).l
	rts