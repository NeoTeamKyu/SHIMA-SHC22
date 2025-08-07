; ----------------------------------------------------------------------------
; Object 08 - Water splash, Spindash dust, skid dust
; ----------------------------------------------------------------------------

SpindashDust_previous_frame:	equ $30
SpindashDust_dust_timer:	equ $32

; Sprite_1DD20:
SpindashDust:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SpindashDust_Index(pc,d0.w),d1
		jmp		SpindashDust_Index(pc,d1.w)
; ===========================================================================
; off_1DD2E:
SpindashDust_Index:
		dc.w	SpindashDust_Init-SpindashDust_Index		; 0
		dc.w	SpindashDust_Main-SpindashDust_Index		; 2
		dc.w	SpindashDust_Delete-SpindashDust_Index	; 4
		dc.w	SpindashDust_CheckSkid-SpindashDust_Index	; 6
; ===========================================================================
; loc_1DD36:
SpindashDust_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_SpindashDust,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.w	#vramDust,obGfx(a0)
		move.w	#v_player,obParent(a0)

; loc_1DD90:
SpindashDust_Main:
		movea.w	obParent(a0),a2 ; a2=character
		moveq	#0,d0
		move.b	obAnim(a0),d0	; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	SpindashDust_DisplayModes(pc,d0.w),d1
		jmp		SpindashDust_DisplayModes(pc,d1.w)
; ===========================================================================
; off_1DDA4:
SpindashDust_DisplayModes:
		dc.w	SpindashDust_Display-SpindashDust_DisplayModes			; 0
		dc.w	SpindashDust_MdSplash-SpindashDust_DisplayModes			; 2
		dc.w	SpindashDust_MdSpindashDust-SpindashDust_DisplayModes	; 4
		dc.w	SpindashDust_MdSkidDust-SpindashDust_DisplayModes		; 6
		dc.w	SpindashDust_MdDJEffect-SpindashDust_DisplayModes		; 8
		dc.w	SpindashDust_Release-SpindashDust_DisplayModes			; $A
		dc.w	SpindashDust_ReleaseSuper-SpindashDust_DisplayModes		; $C
; ===========================================================================
; loc_1DDAC:
SpindashDust_MdSplash:
		move.w	(v_waterpos1).w,obY(a0)
		tst.b	obNextAni(a0)
		bne.w	SpindashDust_Display
		move.w	obX(a2),obX(a0)
		move.b	#0,obStatus(a0)
		andi.w	#$7FFF,obGfx(a0)
		tst.w	(v_player+obVelY).w		; Player moving up?
		bpl.s	@noFlip					; if not, don't flip
		bset	#1,obStatus(a0)			; Flip vertically.
	@noFlip:
		bra.w	SpindashDust_Display
; ===========================================================================
; loc_1DDCC:
SpindashDust_MdSpindashDust:
;		cmpi.b	#$C,(v_air).w
;		blo.s	SpindashDust_ResetDisplayMode
		cmpi.b	#4,obRoutine(a2)
		bhs.w	SpindashDust_ResetDisplayMode
		tst.b	spindash_flag(a2)
		beq.w	SpindashDust_ResetDisplayMode
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
		andi.b	#1,obStatus(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		subi.w	#4,obY(a0);	; Tails is shorter than Sonic
	@nottails:
		tst.b	obNextAni(a0)
		bne.w	SpindashDust_Display
		andi.w	#$7FFF,obGfx(a0)
		tst.w	obGfx(a2)
		bpl.w	SpindashDust_Display
		ori.w	#(1<<15),obGfx(a0)
;		bra.s	SpindashDust_Display
; ===========================================================================
; loc_1DE20:
SpindashDust_MdSkidDust:
;		cmpi.b	#$C,(v_air).w
;		blo.s	SpindashDust_ResetDisplayMode
		bra.w	SpindashDust_Display

SpindashDust_MdDJEffect:
		tst.b	obNextAni(a0)
		bne.w	SpindashDust_Display
		move.w	obY(a2),obY(a0)
		add.w	#$12,obY(a0)
		move.w	obX(a2),obX(a0)
		move.b	#0,obStatus(a0)
		andi.w	#$7FFF,obGfx(a0)

SpindashDust_Release:
		tst.b	obNextAni(a0)
		bne.s	SpindashDust_Display
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
		andi.b	#1,obStatus(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		subi.w	#4,obY(a0);	; Tails is shorter than Sonic
	@nottails:
		tst.b	obNextAni(a0)
		bne.s	SpindashDust_Display
		andi.w	#$7FFF,obGfx(a0)

SpindashDust_ReleaseSuper:
		tst.b	obNextAni(a0)
		bne.s	SpindashDust_Display
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
		andi.b	#1,obStatus(a0)
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		subi.w	#4,obY(a0);	; Tails is shorter than Sonic
	@nottails:
		tst.b	obNextAni(a0)
		bne.s	SpindashDust_Display
		andi.w	#$7FFF,obGfx(a0)

; loc_1DE28:
SpindashDust_Display:
		lea		(Ani_SpindashDust).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Dust_LoadGfx
		jmp		(DisplaySprite).l
; ===========================================================================
; loc_1DE3E:
SpindashDust_ResetDisplayMode:
		move.b	#0,obAnim(a0)
		rts
; ===========================================================================

SpindashDust_Delete:
		jmp		DeleteObject
; ===========================================================================
; loc_1DE4A:
SpindashDust_CheckSkid:
		movea.w	obParent(a0),a2 ; a2=character
		moveq	#$10,d1
		cmpi.b	#id_Stop,obAnim(a2)	; SonAni_Stop
		beq.s	SpindashDust_SkidDust
		moveq	#6,d1
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notKnux
		cmpi.b	#3,KnucklesGlideState(a2)
		beq.s	SpindashDust_SkidDust
	@notKnux:
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@notAmy
		cmpi.b	#1,obDoubleJump_property(a2)
		bne.s	@notAmy
		cmpi.b	#$2A,obAnim(a2)
		beq.s	@notAmy
		btst	#1,obStatus(a2)
		beq.s	SpindashDust_SkidDust	; What the fuck. This works if I reverse the check as it should if I did so -- only in the air -- but not otherwise?
		rts
	@notAmy:
		move.b	#2,obRoutine(a0)
		move.b	#0,SpindashDust_dust_timer(a0)
		rts
; ===========================================================================
; loc_1DE64:
SpindashDust_SkidDust:
		subq.b	#1,SpindashDust_dust_timer(a0)
		bpl.w	Dust_LoadGfx
		move.b	#3,SpindashDust_dust_timer(a0)
		jsr		FindFreeObj
		bne.w	Dust_LoadGfx
		move.b	id(a0),id(a1) ; load SpindashDust
		move.w	obX(a2),obX(a1)
		move.w	obY(a2),obY(a1)
		add.w	d1,obY(a1)
		cmpi.b	#charID_Tails,(v_character).w
		beq.s	@tails
	; Amy checks
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@notShort
		cmpi.b	#1,obDoubleJump_property(a2)
		bne.s	@notShort
		btst	#1,obStatus(a2)
		bne.s	@notShort
		addi.w	#8,obY(a1)
		addi.w	#4,obY(a1)
		bra.s	@notShort
	@tails:
		subi.w	#4,obY(a1)	; Tails is shorter than Sonic
	@notShort:
		move.b	#0,obStatus(a1)
		move.b	#3,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#$80,obPriority(a1)
		move.b	#4,obActWid(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obParent(a0),obParent(a1)
		andi.w	#$7FFF,obGfx(a1)
		tst.w	obGfx(a2)
		bpl.s	Dust_LoadGfx
		ori.w	#(1<<15),obGfx(a1)
		rts
; ===========================================================================
; loc_1DEE4:
Dust_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	SpindashDust_previous_frame(a0),d0
		beq.s	@nochange
		move.b	d0,SpindashDust_previous_frame(a0)
		lea		(DPLC_SpindashDust).l,a2
	
	@cont:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w	#$7FF,d4	; clear art flags
		lsl.w	#5,d4	   ; get VRAM address
		move.l	#Art_SplashAndDust,d6

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
		jsr		(QueueDMATransfer).l
		dbf		d5,@readentry	; repeat for number of entries

	@nochange:
		rts
; ===========================================================================
; animation script
; off_1DF38:
Ani_SpindashDust:
		dc.w	SpindashDustAni_Null-Ani_SpindashDust			; 0
		dc.w	SpindashDustAni_Splash-Ani_SpindashDust			; 1
		dc.w	SpindashDustAni_Dash-Ani_SpindashDust			; 2
		dc.w	SpindashDustAni_Skid-Ani_SpindashDust			; 3
		dc.w	SpindashDustAni_Skid-Ani_SpindashDust			; 4
		dc.w	SpindashDustAni_Release-Ani_SpindashDust		; 5
		dc.w	SpindashDustAni_ReleaseSuper-Ani_SpindashDust	; 6
SpindashDustAni_Null:	dc.b	$1F,  0,afEnd
		even
SpindashDustAni_Splash:	dc.b	3,  1,  2,  3,  4,  5,  6, 7,	afChange,  0
		even
SpindashDustAni_Dash:	dc.b	1, $A, $B, $C, $D, $E, $F,$10,afEnd
		even
SpindashDustAni_Skid:	dc.b	3,$11,$12,$13,$14,afRoutine
		even
SpindashDustAni_Release:dc.b	1, $16, $17, $18, $19, $1A, $1B, $1C, $1D, afChange, 0
		even
SpindashDustAni_ReleaseSuper:	dc.b	2, $1E, $1F, $20, $21, $22, afChange, 0
		even