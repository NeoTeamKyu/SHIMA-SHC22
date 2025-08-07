; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)
; ---------------------------------------------------------------------------

SmashBlock:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Smab_Index(pc,d0.w),d1
		jsr	Smab_Index(pc,d1.w)
		bra.w	RememberState
; ===========================================================================
Smab_Index:	dc.w Smab_Main-Smab_Index
		dc.w Smab_Solid-Smab_Index
		dc.w Smab_Points-Smab_Index
; ===========================================================================

Smab_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		cmpi.b	#id_BGZ,(v_zone).w
		beq.s	@BGZ
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@MHZ
		move.l	#Map_SmabMTZ,obMap(a0)
		move.w	#$4000+vramBlocksMHZ,obGfx(a0)
		bra.s	@cont
	@BGZ:
		move.l	#Map_SmabBGZ,obMap(a0)
		move.w	#$4000+vramBlockBGZ,obGfx(a0)
		cmpi.b	#2,obSubtype(a0)
		bne.s	@cont
		move.w	#$4000,obGfx(a0)
		bra.s	@cont
	@MHZ:
		move.l	#Map_SmabMHZ,obMap(a0)
		move.w	#vramBlocksMHZ,obGfx(a0)
	@cont:
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$100,obPriority(a0)
		move.b	obSubtype(a0),obFrame(a0)

Smab_Solid:	; Routine 2

sonicAniFrame:	equ $32		; Sonic's current animation number
@count:		equ $34		; number of blocks hit + previous stuff

		move.w	(v_itembonus).w,$34(a0)
		move.b	(v_player+obAnim).w,sonicAniFrame(a0) ; load Sonic's animation number
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#3,obStatus(a0)	; has Sonic landed on the block?
		bne.s	@smash		; if yes, branch

	@notspinning:
		rts	
; ===========================================================================

@smash:	; this is a mess.
		;cmpi.b	#charID_Mighty,(v_character).w
		;bne.s	@notmighty
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notmighty
		cmpi.b	#id_Roll,sonicAniFrame(a0)		
		beq.s	@break
	@notmighty:
		cmpi.b	#2,obSubtype(a0)	; non-cracked
		beq.s	@notspinning		
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@notamy
		cmpi.b	#$29,sonicAniFrame(a0)	;"is Amy jump hammering?"
		beq.w	@break	; yes
		cmpi.b	#$28,sonicAniFrame(a0)	;"is Amy jump hammering?"
		beq.w	@break	; yes
		cmpi.b	#$22,sonicAniFrame(a0)	;"is Amy jump hammering?"
		beq.w	@break	; yes
		cmpi.b	#$20,sonicAniFrame(a0)	;"is Amy spin hammering?"
		beq.w	@break	; yes
		cmpi.b	#$1F,sonicAniFrame(a0)	;"is Amy hammering?"
		beq.w	@break	; yes
	@notamy:
		tst.b	obDoubleJump(a1)
		beq.s	@break		
		cmpi.b	#id_Roll,sonicAniFrame(a0) ; is Sonic rolling/jumping?
		bne.s	@notspinning	; if not, branch
		
	@break:
		move.w	@count(a0),(v_itembonus).w

		cmpi.b	#charID_Amy,(v_character).w
		beq.s	@cont						; no rolling for Amy
		cmpi.b	#charID_Mighty,(v_character).w
		bne.s	@notmighty2		; might as well do this now
		cmpi.b	#id_DropDash,sonicAniFrame(a0)
		beq.s	@noRebound

	@notmighty2:
		bset	#2,obStatus(a1)
		move.b	#$E,obHeight(a1)
		move.b	#7,obWidth(a1)
		move.b	#id_Roll,obAnim(a1) ; make Sonic roll

	@cont:
		move.w	#-$300,obVelY(a1) ; rebound Sonic
	@noRebound:
		bset	#1,obStatus(a1)
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#3,obStatus(a0)
		lea	(Smab_Speeds).l,a4 ; load broken fragment speed data
		moveq	#3,d1		; set number of	fragments to 4
		move.w	#$38,d2
		move.b	#sfx_Smash,d6
		bsr.w	SmashObject
		bsr.w	FindFreeObj	; the return
		bne.s	Smab_Points
		move.b	#id_Points,obID(a1) ; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	(v_itembonus).w,d2
		addq.w	#2,(v_itembonus).w ; increment bonus counter
		cmpi.w	#6,d2		; have fewer than 3 blocks broken?
		bcs.s	@bonus		; if yes, branch
		moveq	#6,d2		; set cap for points

	@bonus:
		moveq	#0,d0
		move.w	Smab_Scores(pc,d2.w),d0
		cmpi.w	#$20,(v_itembonus).w ; have 16 blocks been smashed?
		bcs.s	@givepoints	; if not, branch
		move.w	#1000,d0	; give higher points for 16th block
		moveq	#10,d2

	@givepoints:
		jsr	(AddPoints).l
		lsr.w	#1,d2
		move.b	d2,obFrame(a1)

Smab_Points:	; Routine 4
		bsr.w	SpeedToPos
		move.w	obsmashGrav(a0),d0
		add.w	d0,obVelY(a0)
		bsr.w	DisplaySprite
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		rts	
; ===========================================================================
Smab_Speeds:	dc.w -$200, -$200, $38	; x velocity, y velocity, gravity
		dc.w -$100, -$100, $38
		dc.w $200, -$200, $38
		dc.w $100, -$100, $38

Smab_Scores:	dc.w 10, 20, 50, 100
