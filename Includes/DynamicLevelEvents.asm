; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DynamicLevelEvents:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	DLE_Index(pc,d0.w),d0
		jsr	DLE_Index(pc,d0.w) ; run level-specific events
		moveq	#2,d1
		move.w	(v_limitbtm1).w,d0
		sub.w	(v_limitbtm2).w,d0 ; has lower level boundary changed recently?
		beq.s	DLE_NoChg	; if not, branch
		bcc.s	loc_6DAC

		neg.w	d1
		move.w	(v_screenposy).w,d0
		cmp.w	(v_limitbtm1).w,d0
		bls.s	loc_6DA0
		move.w	d0,(v_limitbtm2).w
		andi.w	#$FFFE,(v_limitbtm2).w

loc_6DA0:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w

DLE_NoChg:
		rts
; ===========================================================================

loc_6DAC:
		move.w	(v_screenposy).w,d0
		addq.w	#8,d0
		cmp.w	(v_limitbtm2).w,d0
		bcs.s	loc_6DC4
		btst	#1,(v_player+obStatus).w
		beq.s	loc_6DC4
		add.w	d1,d1
		add.w	d1,d1

loc_6DC4:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w
		rts
; End of function DynamicLevelEvents

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for dynamic level events
; ---------------------------------------------------------------------------
DLE_Index:	dc.w DLE_BGZ-DLE_Index, DLE_LZ-DLE_Index
		dc.w DLE_MZ-DLE_Index, DLE_SLZ-DLE_Index
		dc.w DLE_SYZ-DLE_Index, DLE_SBZ-DLE_Index
		dc.w DLE_MHZ-DLE_Index, DLE_HPZ-DLE_Index
		dc.w DLE_TMZ-DLE_Index
		zonewarning DLE_Index,2
		dc.w DLE_Ending-DLE_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Blossom Gardens Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_BGZ:
;		cmpi.b	#3,(v_act).w	; Legacy?
;		beq.s	@cont
;		cmpi.w	#$202,(v_pal_dry+2).w	; Is the color shifting already active?
;		beq.s	@noShiftPlayer			; If so, skip.
;		ShiftPalUp1 $202				; Shift player palette up in the red and blue sections.
;	@noShiftPlayer:
	@cont:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_BGZx(pc,d0.w),d0
		jmp	DLE_BGZx(pc,d0.w)
; ===========================================================================
DLE_BGZx:	dc.w DLE_BGZ1-DLE_BGZx
		dc.w DLE_BGZ2-DLE_BGZx
		dc.w DLE_BGZ3-DLE_BGZx
		dc.w DLE_LBGZ-DLE_BGZx
; ===========================================================================

DLE_BGZ1:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	BGZ1DLE(pc,d0.w),d0
		jmp		BGZ1DLE(pc,d0.w)
; ===========================================================================
BGZ1DLE:
		dc.w	DLE_BGZ1Intro-BGZ1DLE
		dc.w	DLE_BGZ1Main-BGZ1DLE
; ===========================================================================

DLE_BGZ1Intro:
		tst.b	(v_dle_routine).w
		bne.s	@ret
		subi.w	#24,(v_player+obY).w
		tst.b	(v_levelstarted).w
		beq.s	@ret
		move.b	#-1,(v_player+obFrame).w
		move.b	#id_Fall,(v_player+obAnim).w	
		addq.b	#2,(v_dle_routine).w
	@ret:
		rts

DLE_BGZ1Main:
		cmpi.w	#$41A0,(v_screenposx).w
		bcc.s	@end	; end of level
;		cmpi.w	#$2AA0,(v_screenposx).w
;		bcc.s	@low
		move.w	#$620,(v_limitbtm1).w
		cmpi.w	#$23A0,(v_screenposx).w    ; has the camera reached $2400 on x-axis?
		bcs.s	@low    ; if not, branch
		move.w	#$380,(v_waterpos2).w
		move.w	#$380,(v_waterpos3).w
		move.w	#($380*3/4-$10),(v_bgheight).w
		rts
; ---------------------------------------------------------------------------

    @low:
		move.w	#$600,(v_waterpos2).w
		move.w	#$600,(v_waterpos3).w
		move.w	#($600*3/4-$10),(v_bgheight).w
		rts
; ---------------------------------------------------------------------------

    @end:
		move.w	#$240,(v_limitbtm1).w
; ---------------------------------------------------------------------------

    @ret:
		rts

; ===========================================================================

DLE_BGZ2:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	BGZ2DLE(pc,d0.w),d0
		jmp	BGZ2DLE(pc,d0.w)
; ===========================================================================
BGZ2DLE:	
		dc.w	DLE_BGZ2Intro-BGZ2DLE
		dc.w 	DLE_BGZ2Main-BGZ2DLE
; ===========================================================================

DLE_BGZ2Intro:
		tst.b	(v_dle_routine).w
		bne.s	@ret
;		move.w	#-$10,(v_player+obX).w		
		move.b	#btnR,(v_jpadhold2).w ; make Sonic run to the right
		move.w	#$A00,(v_player+obInertia).w  ; make sonic run at $0A00 speed
		move.b 	#id_Run,(v_player+obAnim).w ; use boost animation
		tst.b	(v_levelstarted).w
		beq.s	@ret
		addq.b	#2,(v_dle_routine).w
	@ret:
		rts

DLE_BGZ2Main:
		move.w	#$600,(v_waterpos2).w
		move.w	#$600,(v_waterpos3).w
		move.w	(v_waterpos2).w,d1
		asr.w	d1
		move.w	d1,d0
		asr.w	d0
		add.w	d0,d1
		sub.w	#$10,d1
		move.w	d1,(v_bgheight).w
		rts
; ===========================================================================

DLE_BGZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	BGZ3DLE(pc,d0.w),d0
		jmp	BGZ3DLE(pc,d0.w)
; ===========================================================================
BGZ3DLE:	dc.w DLE_BGZ3main-BGZ3DLE
			dc.w DLE_BGZ3cutscene-BGZ3DLE
			;dc.w DLE_BGZ3cutscene2-BGZ3DLE			
			;dc.w DLE_BGZ3boss-BGZ3DLE
			dc.w DLE_BGZ3end-BGZ3DLE
; ===========================================================================

; DeltaWooloo: I'll uncomment these lines once BGZ3 has a working boss.

DLE_BGZ3main:
		cmpi.w	#$4E00,(v_screenposx).w
		bcc.s	loc_6E98		
		
locret_6E96:
		rts
; ---------------------------------------------------------------------------
		
loc_6E98:
		move.w	#$1C0,(v_limitbtm1).w
		rts

; ---------------------------------------------------------------------------

;DLE_BGZ3boss:
		;cmpi.w	#$960,(v_screenposx).w
		;bcc.s	loc_6EB0
		;subq.b	#2,(v_dle_routine).w

;loc_6EB0:
;		cmpi.w	#$2960,(v_screenposx).w
;		bcs.s	locret_6EE8
;		jsr	FindFreeObj
;		bne.s	loc_6ED0
;		move.b	#id_BossBGZ,obID(a1)
;		move.w	#$2A60,obX(a1)
;		move.w	#$280,obY(a1)
;		move.b	#palid_BGZBoss,d0
;		jsr		PalLoad2

;loc_6ED0:
;		music	mus_BadApplePC98 ; play boss music
;		move.b	#1,(f_lockscreen).w ; lock screen
;		addq.b	#2,(v_dle_routine).w
;		rts	; Boss patterns are unnecessary.
; ---------------------------------------------------------------------------

DLE_BGZ3cutscene:
		move.w	(v_screenposx).w,(v_limitleft2).w
		cmpi.w	#$4FF0,(v_screenposx).w
		bcs.s	locret_6EE8
		addq.b	#2,(v_dle_routine).w		
		move.b	#1,(f_lockctrl).w ; lock	controls
		move.w	#$800,(v_jpadhold2).w ; make player run to the right			
		rts
; ===========================================================================

locret_6EE8:
		rts
; ---------------------------------------------------------------------------

DLE_BGZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts

; ===========================================================================
DLE_LBGZ:
		move.w	#$300,(v_limitbtm1).w ; set lower y-boundary
		cmpi.w	#$1780,(v_screenposx).w ; has the camera reached $1780 on x-axis?
		bcs.s	@return	; if not, branch
		move.w	#$400,(v_limitbtm1).w ; set lower y-boundary

	@return:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_LZ:
	; This will apply for all three acts.
		move.w	(v_waterpos2).w,d1
		asr.w	d1
		move.w	d1,d0
		asr.w	d0
		add.w	d0,d1
		sub.w	#$10,d1
		move.w	d1,(v_bgheight).w

		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_LZx(pc,d0.w),d0
		jmp	DLE_LZx(pc,d0.w)
; ===========================================================================
DLE_LZx:	dc.w DLE_LZ1-DLE_LZx
		dc.w DLE_LZ2-DLE_LZx
		dc.w DLE_LZ3-DLE_LZx
		dc.w DLE_SBZ3-DLE_LZx
; ===========================================================================

DLE_LZ1:
		tst.b	(v_dle_routine).w
		bne.s	@ret
		subi.w	#24,(v_player+obY).w
		tst.b	(v_levelstarted).w
		beq.s	@ret
		move.b	#-1,(v_player+obFrame).w
		move.b	#id_WaterSlide,(v_player+obAnim).w
		addq.b	#2,(v_dle_routine).w
	@ret:
		rts

DLE_LZ2:
		rts
; ===========================================================================

DLE_LZ3:
		move.b	#1,(f_water).w
		tst.b	(f_switch+$F).w	; has switch $F	been pressed?
		beq.s	loc_6F28	; if not, branch
		move.l a1,-(sp)
		move.l a3,-(sp)
		lea    (Level_layout_main).w,a3
		movea.w $14(a3),a1
		add.w  #$C,a1
		move.b  #$17,(a1)+
		move.b  #$18,(a1)+
		move.l (sp)+,a3
		move.l (sp)+,a1
		sfx	sfx_Rumble	; play sound $B7 (rumbling)

loc_6F28:
		tst.b	(v_dle_routine).w
		bne.s	locret_6F64
		cmpi.w	#$1CA0,(v_screenposx).w
		bcs.s	locret_6F62
		cmpi.w	#$600,(v_screenposy).w
		bcc.s	locret_6F62
		jsr	FindFreeObj
		bne.s	loc_6F4A
		move.b	#id_BossLabyrinth,obID(a1) ; load LZ boss object

loc_6F4A:
		music	mus_Boss	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		jmp	AddPLC		; load boss patterns
; ===========================================================================

locret_6F62:
		rts
; ===========================================================================

locret_6F64:
		rts
; ===========================================================================

DLE_SBZ3:
		cmpi.w	#$D00,(v_screenposx).w
		bcs.s	locret_6F8C
		cmpi.w	#$18,(v_player+obY).w ; has Sonic reached the top of the level?
		bcc.s	locret_6F8C	; if not, branch
		clr.b	(v_lastlamp).w
		move.w	#1,(f_restart).w ; restart level
		move.w	#(id_SBZ<<8)+2,(v_zone).w ; set level number to 0502 (FZ)
		move.b	#1,(f_lockmulti).w ; freeze Sonic

locret_6F8C:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Marble Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_MZ:
;		cmpi.w	#$002,(v_pal_dry+$22).w	; Is the color shifting already active?
;		beq.s	@noShiftLvl				; If so, skip.
;		ShiftPalUp2 $002				; Shift the primary level palette first, so it doesn't get cancelled out.
;	@noShiftLvl:
;		cmpi.w	#$002,(v_pal_dry+2).w	; Is the color shifting already active?
;		beq.s	@noShiftPlayer			; If so, skip.
;		ShiftPalUp1 $002				; Shift player palette up in the red section.
;	@noShiftPlayer:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_MZx(pc,d0.w),d0
		jmp	DLE_MZx(pc,d0.w)
; ===========================================================================
DLE_MZx:	dc.w DLE_MZ1-DLE_MZx
		dc.w DLE_MZ2-DLE_MZx
		dc.w DLE_MZ3-DLE_MZx
; ===========================================================================

DLE_MZ1:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_6FB2(pc,d0.w),d0
		jmp	off_6FB2(pc,d0.w)
; ===========================================================================
off_6FB2:	dc.w loc_6FBA-off_6FB2
		dc.w loc_6FEA-off_6FB2
		dc.w loc_702E-off_6FB2
		dc.w loc_7050-off_6FB2
; ===========================================================================

loc_6FBA:
		move.w	#$1D0,(v_limitbtm1).w
		cmpi.w	#$700,(v_screenposx).w
		bcs.s	locret_6FE8
		move.w	#$220,(v_limitbtm1).w
		cmpi.w	#$D00,(v_screenposx).w
		bcs.s	locret_6FE8
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$340,(v_screenposy).w
		bcs.s	locret_6FE8
		addq.b	#2,(v_dle_routine).w

locret_6FE8:
		rts
; ===========================================================================

loc_6FEA:
		cmpi.w	#$340,(v_screenposy).w
		bcc.s	loc_6FF8
		subq.b	#2,(v_dle_routine).w
		rts
; ===========================================================================

loc_6FF8:
		move.w	#0,(v_limittop2).w
		cmpi.w	#$E00,(v_screenposx).w
		bcc.s	locret_702C
		move.w	#$340,(v_limittop2).w
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$A90,(v_screenposx).w
		bcc.s	locret_702C
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$370,(v_screenposy).w
		bcs.s	locret_702C
		addq.b	#2,(v_dle_routine).w

locret_702C:
		rts
; ===========================================================================

loc_702E:
		cmpi.w	#$370,(v_screenposy).w
		bcc.s	loc_703C
		subq.b	#2,(v_dle_routine).w
		rts
; ===========================================================================

loc_703C:
		cmpi.w	#$500,(v_screenposy).w
		bcs.s	locret_704E
		cmpi.w	#$B80,(v_screenposx).w
		bcs.s	locret_704E
		move.w	#$500,(v_limittop2).w
		addq.b	#2,(v_dle_routine).w

locret_704E:
		rts
; ===========================================================================

loc_7050:
		cmpi.w	#$B80,(v_screenposx).w
		bcc.s	locj_76B8
		cmpi.w	#$340,(v_limittop2).w
		beq.s	locret_7072
		subq.w	#2,(v_limittop2).w
		rts
locj_76B8:
		cmpi.w	#$500,(v_limittop2).w
		beq.s	locj_76CE
		cmpi.w	#$500,(v_screenposy).w
		bcs.s	locret_7072
		move.w	#$500,(v_limittop2).w
locj_76CE:
		cmpi.w	#$E70,(v_screenposx).w
		bcs.s	locret_7072
		move.w	#0,(v_limittop2).w
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$1430,(v_screenposx).w
		bcs.s	locret_7072
		move.w	#$210,(v_limitbtm1).w

locret_7072:
		rts
; ===========================================================================

DLE_MZ2:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$1700,(v_screenposx).w
		bcs.s	locret_7088
		move.w	#$200,(v_limitbtm1).w

locret_7088:
		rts
; ===========================================================================

DLE_MZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_7098(pc,d0.w),d0
		jmp	off_7098(pc,d0.w)
; ===========================================================================
off_7098:	dc.w DLE_MZ3boss-off_7098
		dc.w DLE_MZ3end-off_7098
; ===========================================================================

DLE_MZ3boss:
		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#$1560,(v_screenposx).w
		bcs.s	locret_70E8
		move.w	#$210,(v_limitbtm1).w
		cmpi.w	#$17F0,(v_screenposx).w
		bcs.s	locret_70E8
		jsr	FindFreeObj
		bne.s	loc_70D0
		move.b	#id_BossMarble,obID(a1) ; load MZ boss object
		move.w	#$19F0,obX(a1)
		move.w	#$22C,obY(a1)

loc_70D0:
		music	mus_ImmortalSmoke	; play boss music	(WIP version of the song, needs loop points eventually...)
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		jmp	AddPLC		; load boss patterns
; ===========================================================================

locret_70E8:
		rts
; ===========================================================================

DLE_MZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Star Light Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SLZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_SLZx(pc,d0.w),d0
		jmp	DLE_SLZx(pc,d0.w)
; ===========================================================================
DLE_SLZx:	dc.w DLE_SLZ12-DLE_SLZx
		dc.w DLE_SLZ12-DLE_SLZx
		dc.w DLE_SLZ3-DLE_SLZx
; ===========================================================================

DLE_SLZ12:
		rts
; ===========================================================================

DLE_SLZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_7118(pc,d0.w),d0
		jmp	off_7118(pc,d0.w)
; ===========================================================================
off_7118:	dc.w DLE_SLZ3main-off_7118
		dc.w DLE_SLZ3boss-off_7118
		dc.w DLE_SLZ3end-off_7118
; ===========================================================================

DLE_SLZ3main:
		cmpi.w	#$1E70,(v_screenposx).w
		bcs.s	locret_7130
		move.w	#$210,(v_limitbtm1).w
		addq.b	#2,(v_dle_routine).w

locret_7130:
		rts
; ===========================================================================

DLE_SLZ3boss:
		cmpi.w	#$2000,(v_screenposx).w
		bcs.s	locret_715C
		jsr	FindFreeObj
		bne.s	loc_7144
		move.b	#id_BossStarLight,(a1) ; load SLZ boss object

loc_7144:
		music	mus_Boss	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_SLZBoss,d0
		jmp	AddPLC		; load boss patterns
; ===========================================================================

locret_715C:
		rts
; ===========================================================================

DLE_SLZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SYZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_SYZx(pc,d0.w),d0
		jmp	DLE_SYZx(pc,d0.w)
; ===========================================================================
DLE_SYZx:	dc.w DLE_SYZ1-DLE_SYZx
		dc.w DLE_SYZ2-DLE_SYZx
		dc.w DLE_SYZ3-DLE_SYZx
; ===========================================================================

DLE_SYZ1:
		rts
; ===========================================================================

DLE_SYZ2:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$25A0,(v_screenposx).w
		bcs.s	locret_71A2
		move.w	#$420,(v_limitbtm1).w
		cmpi.w	#$4D0,(v_player+obY).w
		bcs.s	locret_71A2
		move.w	#$520,(v_limitbtm1).w

locret_71A2:
		rts
; ===========================================================================

DLE_SYZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_71B2(pc,d0.w),d0
		jmp	off_71B2(pc,d0.w)
; ===========================================================================
off_71B2:	dc.w DLE_SYZ3main-off_71B2
		dc.w DLE_SYZ3boss-off_71B2
		dc.w DLE_SYZ3end-off_71B2
; ===========================================================================

DLE_SYZ3main:
		cmpi.w	#$2AC0,(v_screenposx).w
		bcs.s	locret_71CE
		jsr	(FindFreeObj).l
		bne.s	locret_71CE
		move.b	#id_BossBlock,(a1) ; load blocks that boss picks up
		addq.b	#2,(v_dle_routine).w

locret_71CE:
		rts
; ===========================================================================

DLE_SYZ3boss:
		cmpi.w	#$2C00,(v_screenposx).w
		bcs.s	locret_7200
		move.w	#$4CC,(v_limitbtm1).w
		jsr	(FindFreeObj).l
		bne.s	loc_71EC
		move.b	#id_BossSpringYard,(a1) ; load SYZ boss	object
		addq.b	#2,(v_dle_routine).w

loc_71EC:
		music	mus_Boss	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		moveq	#plcid_Boss,d0
		jmp	AddPLC		; load boss patterns
; ===========================================================================

locret_7200:
		rts
; ===========================================================================

DLE_SYZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SBZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_SBZx(pc,d0.w),d0
		jmp	DLE_SBZx(pc,d0.w)
; ===========================================================================
DLE_SBZx:	dc.w DLE_SBZ1-DLE_SBZx
		dc.w DLE_SBZ2-DLE_SBZx
		dc.w DLE_FZ-DLE_SBZx
; ===========================================================================

DLE_SBZ1:
		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#$1880,(v_screenposx).w
		bcs.s	locret_7242
		move.w	#$620,(v_limitbtm1).w
		cmpi.w	#$2000,(v_screenposx).w
		bcs.s	locret_7242
		move.w	#$2A0,(v_limitbtm1).w

locret_7242:
		rts
; ===========================================================================

DLE_SBZ2:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_7252(pc,d0.w),d0
		jmp	off_7252(pc,d0.w)
; ===========================================================================
off_7252:	dc.w DLE_SBZ2main-off_7252
		dc.w DLE_SBZ2boss-off_7252
		dc.w DLE_SBZ2boss2-off_7252
		dc.w DLE_SBZ2end-off_7252
; ===========================================================================

DLE_SBZ2main:
		move.w	#$800,(v_limitbtm1).w
		cmpi.w	#$1800,(v_screenposx).w
		bcs.s	locret_727A
		move.w	#$510,(v_limitbtm1).w
		cmpi.w	#$1E00,(v_screenposx).w
		bcs.s	locret_727A
		addq.b	#2,(v_dle_routine).w

locret_727A:
		rts
; ===========================================================================

DLE_SBZ2boss:
		cmpi.w	#$1EB0,(v_screenposx).w
		bcs.s	locret_7298
		jsr	(FindFreeObj).l
		bne.s	locret_7298
		move.b	#id_FalseFloor,(a1) ; load collapsing block object
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_EggmanSBZ2,d0
		jmp	AddPLC		; load SBZ2 Eggman patterns
; ===========================================================================

locret_7298:
		rts
; ===========================================================================

DLE_SBZ2boss2:
		cmpi.w	#$1F60,(v_screenposx).w
		bcs.s	loc_72B6
		jsr	(FindFreeObj).l
		bne.s	loc_72B0
		move.b	#id_ScrapEggman,(a1) ; load SBZ2 Eggman object
		addq.b	#2,(v_dle_routine).w

loc_72B0:
		move.b	#1,(f_lockscreen).w ; lock screen

loc_72B6:
		bra.s	loc_72C2
; ===========================================================================

DLE_SBZ2end:
		cmpi.w	#$2050,(v_screenposx).w
		bcs.s	loc_72C2
		rts
; ===========================================================================

loc_72C2:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================

DLE_FZ:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_72D8(pc,d0.w),d0
		jmp	off_72D8(pc,d0.w)
; ===========================================================================
off_72D8:
		dc.w DLE_FZStart-off_72D8, DLE_FZmain-off_72D8
		dc.w DLE_FZboss-off_72D8, DLE_FZend-off_72D8
		dc.w DLE_FZReturn-off_72D8, DLE_FZend2-off_72D8
; ===========================================================================

DLE_FZStart:
		tst.b	(v_levelstarted).w
		beq.s	@ret
		move.b	#-1,(v_player+obFrame).w
		move.b	#id_Spring,(v_player+obAnim).w
		move.w	#-$800,(v_player+obVelY).w
		addq.b	#2,(v_dle_routine).w
	@ret:
		rts

; ===========================================================================

DLE_FZmain:
		cmpi.w	#$2148,(v_screenposx).w
		bcs.s	loc_72F4
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_FZBoss,d0
		jsr	AddPLC		; load FZ boss patterns

loc_72F4:
		bra.s	loc_72C2
; ===========================================================================

DLE_FZboss:
		cmpi.w	#$2300,(v_screenposx).w
		bcs.s	loc_7312
		jsr	(FindFreeObj).l
		bne.s	loc_7312
		move.b	#id_BossFinal,(a1) ; load FZ boss object
		addq.b	#2,(v_dle_routine).w
		move.b	#1,(f_lockscreen).w ; lock screen

loc_7312:
		bra.s	loc_72C2
; ===========================================================================

DLE_FZend:
		cmpi.w	#$2450,(v_screenposx).w
		bcs.s	loc_7320
		addq.b	#2,(v_dle_routine).w

loc_7320:
		bra.w	loc_72C2
; ===========================================================================

DLE_FZReturn:
		rts
; ===========================================================================

DLE_FZend2:
		bra.w	loc_72C2
; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence dynamic level events (empty)
; ---------------------------------------------------------------------------

DLE_Ending:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; MHZ dynamic level events
; ---------------------------------------------------------------------------

DLE_MHZ:
		tst.b	(v_victory).w
		bne.s	@skipspawning
		move.b	#id_ObjPetals,(v_lvlobjspace).w
	@skipspawning:
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		move.w	DLE_MHZx(pc,d0.w),d0
		jmp	DLE_MHZx(pc,d0.w)
; ===========================================================================
DLE_MHZx:	dc.w DLE_MHZ1-DLE_MHZx
		dc.w DLE_MHZ2-DLE_MHZx
		dc.w DLE_MHZ3-DLE_MHZx
; ===========================================================================

DLE_MHZ1:
		rts
; ===========================================================================

DLE_MHZ2:
		rts
; ===========================================================================

DLE_MHZ3:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	@DLETable(pc,d0.w),d0
		jmp	@DLETable(pc,d0.w)
; ===========================================================================
@DLETable:
		dc.w DLE_MHZ3main-@DLETable
		dc.w DLE_MHZ3boss-@DLETable
		dc.w DLE_MHZ3end-@DLETable
; ===========================================================================

DLE_MHZ3main:
		addq.b	#2,(v_dle_routine).w
		rts

DLE_MHZ3boss:
		cmpi.w	#$960,(v_screenposx).w
		bcc.s	@cont
		subq.b	#2,(v_dle_routine).w

@cont:
		cmpi.w	#$2960,(v_screenposx).w
		bcs.s	@ret
		move.w	#$200,(v_limitbtm1).w
		jsr	FindFreeObj
		bne.s	@cont2
		move.b	#id_BossMHZ,obID(a1)
		move.w	#$2A60,obX(a1)
		move.w	#$180,obY(a1)
		move.b	#palid_MHZBoss,d0
		jsr		PalLoad2

@cont2:
		music	mus_Cirno	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		jmp		AddPLC		; load boss patterns
; ===========================================================================

@ret:
		rts
; ===========================================================================

DLE_MHZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; HPZ dynamic level events (these are a copy of KEH's dynamic water stuff)
; ---------------------------------------------------------------------------

DLE_HPZ:
		move.w	#$0600,(v_waterpos3).w		; set default level
		move.w	(v_screenposx).w,d0			; load camera X position
		cmpi.w	#$1C00,d0				; has it reached the slide?
		bcs.s	@noSlide			; if not, branch
		move.w	#$0750,(v_waterpos3).w		; set new level

	@noSlide:
		rts

; ---------------------------------------------------------------------------
; TMZ dynamic level events (there are none lol)
; ---------------------------------------------------------------------------

DLE_TMZ:
		rts