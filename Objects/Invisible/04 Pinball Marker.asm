; ----------------------------------------------------------------------------
; Object 04 - Pinball mode enable/disable
; (used in Casino Night Zone to determine when Sonic should stay in a ball)
; ----------------------------------------------------------------------------
; Sprite_2115C:
PinballMarker:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	PinballMarker_Index(pc,d0.w),d1
	jsr	PinballMarker_Index(pc,d1.w)
	if DebugPathSwappers
		tst.w	(f_debugmode).w
		bne.s	@JmpToRememberState
	endif
		; like RememberState, but doesn't display (Sonic 2's MarkObjGone3)
		out_of_range_resp.s	@delete
		rts

	@delete:
		jmp	DeleteObject
	
	@JmpToRememberState:
		jmp	RememberState
; ===========================================================================
; off_21170: PinballMarker_States:
PinballMarker_Index:
		dc.w PinballMarker_Init-PinballMarker_Index	; 0
		dc.w PinballMarker_MainX-PinballMarker_Index	; 2
		dc.w PinballMarker_MainY-PinballMarker_Index	; 4
; ===========================================================================
; loc_21176:
PinballMarker_Init:
	addq.b	#2,routine(a0) ; => PinballMarker_MainX
	move.l	#Map_PathSwapper,mappings(a0)
		move.w	#$7B2,obGfx(a0)
	ori.b	#4,render_flags(a0)
	move.b	#$10,width_pixels(a0)
	move.w	#$280,priority(a0)
	move.b	subtype(a0),d0
	btst	#2,d0
	beq.s	PinballMarker_Init_CheckX
	addq.b	#2,routine(a0) ; => PinballMarker_MainY
	andi.w	#7,d0
	move.b	d0,mapping_frame(a0)
	andi.w	#3,d0
	add.w	d0,d0
	move.w	word_211E8(pc,d0.w),$32(a0)
	move.w	y_pos(a0),d1
	lea	(v_player).w,a1 ; a1=character
	cmp.w	y_pos(a1),d1
	bhs.s	@cont
	move.b	#1,$34(a0)
@cont:
	bra.w	PinballMarker_MainY
; ===========================================================================
word_211E8:
	dc.w   $20
	dc.w   $40	; 1
	dc.w   $80	; 2
	dc.w  $100	; 3
; ===========================================================================
; loc_211F0:
PinballMarker_Init_CheckX:
	andi.w	#3,d0
	move.b	d0,mapping_frame(a0)
	add.w	d0,d0
	move.w	word_211E8(pc,d0.w),$32(a0)
	move.w	x_pos(a0),d1
	lea	(v_player).w,a1 ; a1=character
	cmp.w	x_pos(a1),d1
	bhs.s	PinballMarker_MainX
	move.b	#1,$34(a0)

; loc_21224:
PinballMarker_MainX:

	tst.w	(v_debuguse).w
	bne.s	return_21284
	move.w	x_pos(a0),d1
	lea	$34(a0),a2 ; a2=object
	lea	(v_player).w,a1 ; a1=character
@cont:
	tst.b	(a2)+
	bne.s	PinballMarker_MainX_Alt
	cmp.w	x_pos(a1),d1
	bhi.s	return_21284
	move.b	#1,-1(a2)
	move.w	y_pos(a0),d2
	move.w	d2,d3
	move.w	$32(a0),d4
	sub.w	d4,d2
	add.w	d4,d3
	move.w	y_pos(a1),d4
	cmp.w	d2,d4
	blo.s	return_21284
	cmp.w	d3,d4
	bhs.s	return_21284
	btst	#0,render_flags(a0)
	bne.s	@cont2
	move.b	#1,pinball_mode(a1) ; enable must-roll "pinball mode"
	bra.s	loc_212C4
; ---------------------------------------------------------------------------
@cont2:
	move.b	#0,pinball_mode(a1) ; disable pinball mode

return_21284:
	rts
; ===========================================================================
; loc_21286:
PinballMarker_MainX_Alt:
	cmp.w	x_pos(a1),d1
	bls.s	return_21284
	move.b	#0,-1(a2)
	move.w	y_pos(a0),d2
	move.w	d2,d3
	move.w	$32(a0),d4
	sub.w	d4,d2
	add.w	d4,d3
	move.w	y_pos(a1),d4
	cmp.w	d2,d4
	blo.s	return_21284
	cmp.w	d3,d4
	bhs.s	return_21284
	btst	#0,render_flags(a0)
	beq.s	@cont
	move.b	#1,pinball_mode(a1)
	bra.s	loc_212C4
; ---------------------------------------------------------------------------
@cont:
	move.b	#0,pinball_mode(a1)
	rts
; ===========================================================================

loc_212C4:
	btst	#2,status(a1)
	beq.s	@cont
	rts
; ---------------------------------------------------------------------------
@cont:
	bset	#2,status(a1)
	move.b	#$E,y_radius(a1)
	move.b	#7,x_radius(a1)
	move.b	#id_Roll,anim(a1)
	addq.w	#5,y_pos(a1)
	sfx		sfx_Roll
	rts

; ===========================================================================
; loc_212F6:
PinballMarker_MainY:

	tst.w	(v_debuguse).w
	bne.s	return_21350
	move.w	y_pos(a0),d1
	lea	$34(a0),a2 ; a2=object
	lea	(v_player).w,a1 ; a1=character
@cont
	tst.b	(a2)+
	bne.s	PinballMarker_MainY_Alt
	cmp.w	y_pos(a1),d1
	bhi.s	return_21350
	move.b	#1,-1(a2)
	move.w	x_pos(a0),d2
	move.w	d2,d3
	move.w	$32(a0),d4
	sub.w	d4,d2
	add.w	d4,d3
	move.w	x_pos(a1),d4
	cmp.w	d2,d4
	blo.s	return_21350
	cmp.w	d3,d4
	bhs.s	return_21350
	btst	#0,render_flags(a0)
	bne.s	@cont2
	move.b	#1,pinball_mode(a1)
	bra.w	loc_212C4
; ---------------------------------------------------------------------------
@cont2:
	move.b	#0,pinball_mode(a1)

return_21350:
	rts
; ===========================================================================
; loc_21352:
PinballMarker_MainY_Alt:
	cmp.w	y_pos(a1),d1
	bls.s	return_21350
	move.b	#0,-1(a2)
	move.w	x_pos(a0),d2
	move.w	d2,d3
	move.w	$32(a0),d4
	sub.w	d4,d2
	add.w	d4,d3
	move.w	x_pos(a1),d4
	cmp.w	d2,d4
	blo.s	return_21350
	cmp.w	d3,d4
	bhs.s	return_21350
	btst	#0,render_flags(a0)
	beq.s	@cont
	move.b	#1,pinball_mode(a1)
	bra.w	loc_212C4
; ---------------------------------------------------------------------------
@cont:
	move.b	#0,pinball_mode(a1)
	rts