; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp	Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index
		dc.w Mon_Solid-Mon_Index
		dc.w Mon_BreakOpen-Mon_Index
		dc.w Mon_Animate-Mon_Index
		dc.w Mon_Display-Mon_Index
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#$E,obWidth(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#vramMonitors,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$F,obActWid(a0)
		move.w	obRespawnNo(a0),d0
		movea.w	d0,a2	; load address into a2
		;bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)	; has monitor been broken?
		beq.s	@notbroken	; if not, branch
		move.b	#8,obRoutine(a0) ; run "Mon_Display" routine
		move.b	#$10,obFrame(a0)	; use broken monitor frame
		rts	
; ===========================================================================

	@notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

Mon_Solid:	; Routine 2
		move.b	ob2ndRout(a0),d0 ; is monitor set to fall?
		beq.s	@normal		; if not, branch
		subq.b	#2,d0
		bne.s	@fall

		; 2nd Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,obStatus(a1) ; is Sonic on top of the monitor?
		bne.w	@ontop		; if yes, branch
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

	@ontop:
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Mon_Animate
; ===========================================================================

@fall:		; 2nd Routine 4
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.w	Mon_Animate
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

@normal:	; 2nd Routine 0	; loc_A1EC in hive
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Mon_SolidSides
		beq.w	loc_A25C
		tst.w	obVelY(a1)
		bmi.s	loc_A20A
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notknux
		cmpi.b	#$20,obAnim(a1)
		beq.w	loc_A25C
		cmpi.b	#$26,obAnim(a1)
		beq.s	loc_A25C
	@notknux:
		cmpi.b	#charID_Legacy,(v_character).w
		beq.s	@legacyskip
		tst.b	(v_character).w
		bne.s	@notsonic
	@legacyskip:
		cmpi.b	#id_DropDash,obAnim(a1)	; is Sonic spindashing?
		beq.s	loc_A25C
	@notsonic:
		cmpi.b	#id_Roll,obAnim(a1) ; is Sonic rolling?
		beq.s	loc_A25C	; if yes, branch
		cmpi.b	#id_Spindash,obAnim(a1)	; is Sonic spindashing?
		beq.s	loc_A25C

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,obY(a1)
		bsr.w	loc_74AE
		move.b	#2,ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	obVelX(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	obVelX(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_A246:
		btst	#1,obStatus(a1)
		bne.s	loc_A26A
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		bra.s	Mon_Animate
; ===========================================================================

loc_A25C:
		btst	#5,obStatus(a0)
		beq.s	Mon_Animate
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notknux
		cmpi.b	#$20,obAnim(a1)
		beq.s	loc_A26A
		cmpi.b	#$26,obAnim(a1)
		beq.s	loc_A26A
	@notknux:
		tst.b	(v_character).w
		bne.s	@notsonic
		cmpi.b	#id_DropDash,obAnim(a1)	; is Sonic in his Drop Dash animation?
		beq.s	loc_A26A	; if so, branch
	@notsonic:
		cmpi.b	#id_Roll,obAnim(a1)	; is Sonic in his jumping/rolling animation?
		beq.s	loc_A26A	; if so, branch
		cmpi.b	#id_Drown,obAnim(a1)	; is Sonic in his drowning animation?
		beq.s	loc_A26A	; if so, branch
		move.w	#1,obAnim(a1)	; clear obAnim and set obNextAni to 1, putting Sonic in his walking animation

loc_A26A:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

Mon_Animate:	; Routine 6
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		bsr.w	DisplaySprite
		bra.w	RememberState
; ===========================================================================

Mon_BreakOpen:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.s	Mon_Explode
		move.b	#id_PowerUp,0(a1) ; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

Mon_Explode:
		bsr.w	FindFreeObj
		bne.s	@fail
		move.b	#id_ExplosionItem,0(a1) ; load explosion object
		addq.b	#2,obRoutine(a1) ; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	@fail:
		bsr.w	FindFreeObj
		bne.s	@fail2
		move.b	#id_MonitorShards,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
	@fail2:
		move.w	obRespawnNo(a0),d0
		movea.w	d0,a2	; load address into a2
		bset	#0,(a2)
		move.b	#$E,obAnim(a0)	; set monitor type to broken
		bra.w	DisplaySprite