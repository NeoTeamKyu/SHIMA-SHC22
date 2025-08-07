; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------

Lamppost:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Lamp_Index(pc,d0.w),d1
		jsr	Lamp_Index(pc,d1.w)
		lea	(Ani_Lamppost).l,a1
		jsr	(AnimateSprite).l
		jmp	(RememberState).l
; ===========================================================================
Lamp_Index:	dc.w Lamp_Main-Lamp_Index
		dc.w Lamp_Blue-Lamp_Index
		dc.w Lamp_Finish-Lamp_Index
		dc.w Lamp_Twirl-Lamp_Index

lamp_origX:	equ $30		; original x-axis position
lamp_origY:	equ $32		; original y-axis position
lamp_time:	equ $36		; length of time to twirl the lamp
lamp_height = 32		; Was 64 in the original Sonic 1, because their lamps were 64px tall.
; ===========================================================================

Lamp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Lamp,obMap(a0)
		move.w	#vramLamp,obGfx(a0)	; $D800/$20
		move.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.w	#$280,obPriority(a0)
		lea	(v_objstate).w,a2
		move.w	obRespawnNo(a0),d0
		movea.w	d0,a2	; load address into a2
		btst	#0,(a2)
		bne.s	@red
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2 ; get lamppost number
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is this a "new" lamppost?
		bcs.s	Lamp_Blue	; if yes, branch

@red:
		bset	#0,(a2)
		move.b	#4,obRoutine(a0) ; goto Lamp_Finish next
		move.b	#2,obAnim(a0)	; use red lamppost frame
		rts	
; ===========================================================================

Lamp_Blue:	; Routine 2
		tst.w	(v_debuguse).w	; is debug mode	being used?
		bne.w	@donothing	; if yes, branch
		tst.b	(f_lockmulti).w
		bmi.w	@donothing
		move.b	(v_lastlamp).w,d1
		andi.b	#$7F,d1
		move.b	obSubtype(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is this a "new" lamppost?
		bcs.s	@chkhit		; if yes, branch
		move.w	obRespawnNo(a0),d0
		movea.w	d0,a2	; load address into a2
		bset	#0,(a2)
		move.b	#4,obRoutine(a0)
		move.b	#2,obAnim(a0)
		bra.w	@donothing
; ===========================================================================

@chkhit:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		addq.w	#8,d0
		cmpi.w	#$10,d0
		bcc.w	@donothing
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		addi.w	#lamp_height,d0	; Height of lamppost. Was 64 in Sonic 1. Not $64, just 64, which equals $40.
		cmpi.w	#40+lamp_height,d0	; Max radius to check... I think. Was 104 in Sonic 1.
		bcc.s	@donothing

		sfx	sfx_Checkpoint	; play actual checkpoint sound
		addq.b	#2,obRoutine(a0)
		jsr	(FindFreeObj).l
		bne.s	@fail
		move.b	#id_Lamppost,obID(a1)	; load twirling	lamp object
		move.b	#6,obRoutine(a1) ; goto Lamp_Twirl next
		move.w	obX(a0),lamp_origX(a1)
		move.w	obY(a0),lamp_origY(a1)
		subi.w	#8,lamp_origY(a1)
		move.l	#Map_Lamp,obMap(a1)
		move.w	#vramLamp,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#8,obActWid(a1)
		move.w	#$200,obPriority(a1)
		move.b	#1,obAnim(a1)	; use "ball only" frame
		move.w	#$20,lamp_time(a1)
		move.l	a0,obParent(a1)
		move.l	a1,obParent(a0)

	@fail:
		bsr.w	Lamp_StoreInfo
		move.w	obRespawnNo(a0),d0
		movea.w	d0,a2	; load address into a2
		bset	#0,(a2)

	@donothing:
		rts	
; ===========================================================================

Lamp_Finish:	; Routine 4
		cmpi.b	#1,obAnim(a0)
		jeq		DeleteObject
		move.l	obParent(a0),a1
		tst.b	lamp_time(a1)
		bpl.s	@ret
		cmpi.b	#2,obAnim(a0)
		beq.s	@ret
		move.b	#2,obAnim(a0)
		sfx		sfx_Lava
	@ret:
		rts	
; ===========================================================================

Lamp_Twirl:	; Routine 6
		subq.w	#1,lamp_time(a0) ; decrement timer
		bpl.s	@continue	; if time remains, keep twirling
		move.b	#4,obRoutine(a0) ; goto Lamp_Finish next

	@continue:
		move.b	obAngle(a0),d0
		subi.b	#$10,obAngle(a0)
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$C00,d1
		swap	d1
		add.w	lamp_origX(a0),d1
		move.w	d1,obX(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	lamp_origY(a0),d0
		move.w	d0,obY(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Lamp_StoreInfo:
		move.b	obSubtype(a0),(v_lastlamp).w 				; lamppost number
		move.b	(v_lastlamp).w,(v_lastlamp_bak).w			; last lamppost hit
		move.w	obX(a0),(v_playerX_bak).w					; x-position
		move.w	obY(a0),(v_playerY_bak).w					; y-position
		move.w	(v_rings).w,(v_rings_bak).w					; rings
		move.b	(v_lifecount).w,(v_lifecount_bak).w			; lives
		move.l	(v_time).w,(v_time_bak).w					; time
		move.b	(v_dle_routine).w,(v_dle_routine_bak).w		; routine counter for dynamic level events
		move.w	(v_limitbtm2).w,(v_limitbtm2_bak).w			; lower y-boundary of level
		move.w	(v_screenposx).w,(v_screenposx_bak).w		; screen x-position
		move.w	(v_screenposy).w,(v_screenposy_bak).w		; screen y-position
		move.w	(v_bgscreenposx).w,(v_bgscreenposx_bak).w	; bg position
		move.w	(v_bgscreenposy).w,(v_bgscreenposy_bak).w	; bg position
		move.w	(v_bg2screenposx).w,(v_bg2screenposx_bak).w	; bg position
		move.w	(v_bg2screenposy).w,(v_bg2screenposy_bak).w	; bg position
		move.w	(v_bg3screenposx).w,(v_bg3screenposx_bak).w	; bg position
		move.w	(v_bg3screenposy).w,(v_bg3screenposy_bak).w	; bg position
		move.w	(v_waterpos2).w,(v_waterpos2_bak).w			; water height
		move.b	(v_wtr_routine).w,(v_wtr_routine_bak).w		; rountine counter for water
		move.b	(f_wtr_state).w,(f_wtr_state_bak).w			; water direction
		rts

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Lamp_LoadInfo:
		move.b	(v_lastlamp_bak).w,(v_lastlamp).w
		move.w	(v_playerX_bak).w,(v_player+obX).w
		move.w	(v_playerY_bak).w,(v_player+obY).w
		move.w	(v_rings_bak).w,(v_rings).w
		move.b	(v_lifecount_bak).w,(v_lifecount).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.l	(v_time_bak).w,(v_time).w
		move.b	#59,(v_timecent).w
		subq.b	#1,(v_timesec).w
		move.b	(v_dle_routine_bak).w,(v_dle_routine).w
		move.w	(v_limitbtm2_bak).w,(v_limitbtm2).w
		move.w	(v_limitbtm2_bak).w,(v_limitbtm1).w
		move.w	(v_screenposx_bak).w,(v_screenposx).w
		move.w	(v_screenposy_bak).w,(v_screenposy).w
		move.w	(v_bgscreenposx_bak).w,(v_bgscreenposx).w
		move.w	(v_bgscreenposy_bak).w,(v_bgscreenposy).w
		move.w	(v_bg2screenposx_bak).w,(v_bg2screenposx).w
		move.w	(v_bg2screenposy_bak).w,(v_bg2screenposy).w
		move.w	(v_bg3screenposx_bak).w,(v_bg3screenposx).w
		move.w	(v_bg3screenposy_bak).w,(v_bg3screenposy).w
		move.w	(v_waterpos2_bak).w,(v_waterpos2).w
		move.b	(v_wtr_routine_bak).w,(v_wtr_routine).w
		move.b	(f_wtr_state_bak).w,(f_wtr_state).w

		tst.b	(v_lastlamp).w
		bpl.s	locret_170F6
		move.w	(v_playerX_bak).w,d0
		subi.w	#$A0,d0
		move.w	d0,(v_limitleft2).w

locret_170F6:
		rts	

Ani_Lamppost:
		dc.w	@noFlame-Ani_Lamppost
		dc.w	@flameOnly-Ani_Lamppost
		dc.w	@lit-Ani_Lamppost

@noFlame:	dc.b	$7F,0,	afEnd
@flameOnly:	dc.b	1,	1,	2,	1,	3,	afEnd
@lit:		dc.b	1,	4,	5,	6,	7,	8,	9,	$A,	$B,	$C,	$D,	afBack,	2
		even