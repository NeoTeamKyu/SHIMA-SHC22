; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

GM_Level:
		bset	#7,(v_gamemode).w ; add $80 to screen mode (for pre level sequence)
		move.l	#NullBlank,HBlankRout.w
		moveq	#0, d0
		move.b	d0,(v_superpal).w
		move.b	d0,(v_levelstarted).w
		move.b	d0,(f_cameraenabled).w
		move.b	d0,(v_flipangle).w
		move.b	d0,(v_flipsremaining).w
		move.b	d0,(v_flipspeed).w
		tst.w	(f_demo).w
		bmi.s	Level_NoMusicFade
		command	mus_FadeOut	; fade out music

	Level_NoMusicFade:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrRam	; if yes, branch
		disable_ints
		locVRAM	(vramTitleCard*$20)
		lea		(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		enable_ints
		bsr.w	LoadLevelPLC
loc_37FC:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC		; Load standard patterns... Do this right! Any more PLCs than the life icon will softlock! If you do Chaos Spear, make sure to find out how to do it *right*.
		jsr		LoadPlayerLifeIcons

Level_ClrRam:
		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#(v_objspace_End-v_objspace)/4-1,d1

	Level_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrObjRam ; clear object RAM

		lea		(v_clearpalvars).w,a1
		moveq	#0,d0
		move.w	#(v_clearpalvars_end-v_clearpalvars)/4-1,d1

	Level_ClrVars1:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars1 ; clear misc variables

		lea		(v_clearvars).w,a1
		moveq	#0,d0
		move.w	#(v_clearvars_end-v_clearvars)/4-1,d1

	Level_ClrVars2:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars2 ; clear misc variables

		lea		(v_clearanivars).w,a1
		moveq	#0,d0
		move.w	#(v_clearanivars_end-v_clearanivars)/4-1,d1

	Level_ClrVars3:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrVars3 ; clear object variables

		disable_ints
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	#$8A00+223,(v_water_hreg).w ; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)
		ResetDMAQueue
;		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
;		bne.s	Level_LoadPal	; if not, branch
		move.l	#WaterTransition_LZ,(v_demolength-4).w

		move.w	#$8014,(a6)		; enable H-interrupts
		clr.b	(f_water).w		; disable water
		clr.b	(f_background).w		; disable background
		moveq	#0,d0
		move.b	d0,(v_victory).w	; clear victory anim (Saving 4 cycles)
		clr.b	(f_wtr_state).w		; clear	water state
		clr.b	(f_bg_state).w		; clear	water state
		move.b	(v_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		add.b	(v_act).w,d0
		add.w	d0,d0
		lea		(BgHeight).l,a1	; load water height array
		move.w	(a1,d0.w),d1
		move.w	d1,(v_bgheight).w
		tst.w	d1
		beq.s	@nobg
		move.b	#1,(f_background).w		; enable second background

	@nobg:
		lea		(WaterHeight).l,a1	; load water height array
		move.w	(a1,d0.w),d1
		tst.w	d1
		beq.s	Level_LoadPal
		move.w	d1,(v_waterpos1).w	; set water heights
		move.w	d1,(v_waterpos2).w
		move.w	d1,(v_waterpos3).w
		clr.b	(v_wtr_routine).w	; clear water routine counter
		move.b	#1,(f_water).w		; enable water

Level_LoadPal:
		move.w	#30,(v_air).w
		enable_ints
		jsr		LoadPlayerPal
		bsr.w	PalLoad2	; load Sonic's palette
		jsr		loadWaterShift	; Fade doesn't really work this way, but at least it's not stuck at black for a while? (This ends up causing issues for a couple frames.)
		tst.b	(v_lastlamp).w
		beq.s	Level_GetBgm
		move.b	(f_wtr_state_bak).w,(f_wtr_state).w

Level_GetBgm:
		command	mus_Reset	; fade reset music
		tst.w	(f_demo).w
		bmi.s	Level_SkipTtlCard
		bsr.w	ResetZoneMusic
		move.b	#id_TitleCard,(v_gameover).w ; load title card object

Level_LoadBannerArt:
		lea		(Kos_TitleCardBanner).l,a0	; Decompress title card art into RAM
		lea		(v_128x128).l,a1
		jsr		KosDec

		move.w	a1,d3				; Get length of uncompressed art
		lsr.w	#1,d3				; Divide by 2 for DMA queue

		move.l	#v_128x128,d1			; Queue DMA of title card art from RAM
		move.w	#$564*$20,d2
		jsr		(Add_To_DMA_Queue).l

Level_TtlCardLoop:
		move.b	#$C,(v_vbla_routine).w		; VSync
		bsr.w	WaitForVBla

		jsr		(ExecuteObjects).l		; Run objects
		jsr		(BuildSprites).l		; Display objects
		bsr.w	RunPLC				; Process PLCs

		jsr		CheckTitleCard			; Has the title card moved in?
		beq.s	Level_TtlCardLoop		; If not, wait
		tst.l	(v_plc_buffer).w		; Are the PLCs done loading?
		bne.s	Level_TtlCardLoop		; If not, wait

		move.b	#$C,(v_vbla_routine).w		; Wait for 1 more V-BLANK
		bsr.w	WaitForVBla
		jsr		(Hud_Base).l			; Load HUD graphics

Level_SkipTtlCard:
		jsr		LoadPlayerPal
		bsr.w	PalLoad1	; load Sonic's palette
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_fg_scroll_flags).w
		bsr.w	LoadZoneTiles	; load level art
		bsr.w	LevelDataLoad ; load block mappings and palettes
		bsr.w	LoadLevelPLC2
		disable_ints
		bsr.w	LoadTilesFromStart
		enable_ints
		bsr.w	ColIndexLoad
		bsr.w	LZWaterFeatures
		jsr		LoadPlayerObject
		tst.w	(f_demo).w
		bmi.s	Level_ChkDebug
		move.b	#1,(v_levelstarted).w
		st		(f_cameraenabled).w

Level_ChkDebug:
		tst.b	(f_debugcheat).w ; has debug cheat been entered?
		beq.s	Level_ChkWater	; if not, branch
		btst	#bitA,(v_jpadhold1).w ; is A button held?
		beq.s	Level_ChkWater	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

Level_ChkWater:
		move.w	#0,(v_jpadhold2).w
		move.w	#0,(v_jpadhold1).w
		tst.b	(f_water).w
		beq.s	Level_LoadObj	; if not, branch
		move.b	#id_WaterSurface,(v_wtrsurf1).w ; load water	surface	object
		move.w	#$60,(v_wtrsurf1+obX).w
		move.b	#id_WaterSurface,(v_wtrsurf2).w
		move.w	#$120,(v_wtrsurf2+obX).w

Level_LoadObj:
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@loadpetals
		tst.b	(v_zone).w
		bne.s	@nopetals
		cmpi.b	#3,(v_act).w
		beq.s	@nopetals

	@loadpetals:
		move.b	#id_ObjPetals,(v_oemeralds).w

	@nopetals:
		jsr		(ObjPosLoad).l
		move.b	#0,(Rings_manager_routine).w
		jsr		(RingsManager).l
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		tst.b	(v_lastlamp).w	; are you starting from	a lamppost?
		bne.s	Level_SkipClr	; if yes, branch
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.b	d0,(v_centstep).w
		move.b	d0,(v_lifecount).w ; clear lives counter

	Level_SkipClr:
		move.b	d0,(f_timeover).w
		move.b	d0,(v_shield).w	; clear shield
		move.b	d0,(v_invinc).w	; clear invincibility
		move.b	d0,(v_shoes).w	; clear speed shoes
		move.b	d0,(v_lastlamp-1).w
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w ; update score counter
		move.b	#1,(f_ringcount).w ; update rings counter
		move.w	d0,(v_btnpushtime1).w
	;	moveq	#0,d0
		tst.w	(f_demo).w	; is demo mode on?
		bpl.s	Level_Demo	; if yes, branch
		lea		(DemoEndDataPtr).l,a1 ; load ending demo data
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

Level_Demo:
		move.b	1(a1),(v_btnpushtime2).w ; load key press duration
		subq.b	#1,(v_btnpushtime2).w ; subtract 1 from duration
		move.w	#1800,(v_demolength).w
		tst.w	(f_demo).w
		bpl.s	Level_ChkWaterPal
		move.w	#540,(v_demolength).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	Level_ChkWaterPal
		move.w	#510,(v_demolength).w

Level_ChkWaterPal:
		move.w	#3,d1

	Level_DelayLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		dbf		d1,Level_DelayLoop
		move.w	#$202F,(v_pfade_start).w ; fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrCardArt ; if yes, branch
		jsr		MoveTitleCardOut	; Move title card out
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		moveq	#plcid_Explode,d0	; load explosion gfx
		jsr		(AddPLC).l

		cmpi.w	#(id_BGZ<<8)+3,(v_zone).w
		bne.s	@no
		move.w	#plcid_GHZAnimals,d0	; Placeholder, I think...? Or maybe it's just LBGZ.
		bra.s	@addplc
	@no:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		addi.w	#plcid_BGZAnimals,d0

@addplc:
		jsr		(AddPLC).l	; load animal gfx (level no. + $15)

Level_StartGame:
		move.b	#1,(f_timecount).w ; update time counter
		bclr	#7,(v_gamemode).w ; subtract $80 from mode to end pre-level stuff

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w ; add 1 to level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterFeatures
		jsr		(ExecuteObjects).l
		tst.w	(f_restart).w
		bne		GM_Level
		tst.w	(v_debuguse).w	; is debug mode being used?
		bne.w	Level_DoScroll	; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w ; did you just die?
		bcc.s	Level_SkipScroll ; if yes, branch

	Level_DoScroll:
		bsr.w	DeformLayers

	Level_SkipScroll:
		cmpi.b	#$90,(v_movehud).w
		beq.s	Level_SkipHUDScroll
		add.b	#4,(v_movehud).w

Level_SkipHUDScroll:	
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		jsr		(RingsManager).l
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		bsr.w	EndOfLevelArtLoad

		cmpi.b	#id_Demo,(v_gamemode).w
		beq.s	Level_ChkDemo	; if mode is 8 (demo), branch
		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is $C (level), branch
		rts
; ===========================================================================

Level_ChkDemo:
		tst.w	(f_restart).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w
		bne.s	Level_FadeDemo	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		tst.w	(f_demo).w	; is demo mode on & not ending sequence?
		bpl.s	Level_FadeDemo	; if yes, branch
		move.b	#id_Credits,(v_gamemode).w ; go to credits

Level_FadeDemo:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	Level_FDLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_3BC8
		move.w	#2,(v_palchgspeed).w
		bsr.w	FadeOut_ToBlack

loc_3BC8:
		tst.w	(v_demolength).w
		bne.s	Level_FDLoop
		rts
; ===========================================================================

		include	"Includes/LZWaterFeatures.asm"
		include	"Includes/MoveSonicInDemo.asm"

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:	; Thanks, Inferno.
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.b	d0,d0
		add.b	d0,d0
		add.b	(v_act).w,d0
		lsl.w	#3,d0					; MJ: multiply by 8 not 4
		move.l	ColPointers(pc,d0.w),(v_colladdr1).w	; MJ: get first collision set
		addq.w	#4,d0					; MJ: increase to next location
		move.l	ColPointers(pc,d0.w),(v_colladdr2).w	; MJ: get second collision set
		rts	
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
	; BGZ
		dc.l	Col_BGZ1_1, Col_BGZ1_2	; Act 1
		dc.l	Col_BGZ2_1, Col_BGZ2_2	; Act 2
		dc.l	Col_BGZ3_1, Col_BGZ3_2	; Act 3
		dc.l	Col_LBGZ_1, Col_LBGZ_2	; Act 4 (Legacy)
	; SRZ
		dc.l	Col_LZ_1, Col_LZ_2		; Act 1
		dc.l	Col_LZ_1, Col_LZ_2		; Act 2
		dc.l	Col_LZ_1, Col_LZ_2		; Act 3
		dc.l	Col_LZ_1, Col_LZ_2		; Act 4 (BBZ3)
	; ATZ
		dc.l	Col_MZ_1, Col_MZ_2		; Act 1
		dc.l	Col_MZ_1, Col_MZ_2		; Act 2
		dc.l	Col_MZ_1, Col_MZ_2		; Act 3
		dc.l	Col_MZ_1, Col_MZ_2		; Act 4 (Unused)
	; HMZ
		dc.l	Col_SLZ_1, Col_SLZ_2	; Act 1
		dc.l	Col_SLZ_1, Col_SLZ_2	; Act 2
		dc.l	Col_SLZ_1, Col_SLZ_2	; Act 3
		dc.l	Col_SLZ_1, Col_SLZ_2	; Act 4 (Unused)
	; BCZ
		dc.l	Col_SYZ_1, Col_SYZ_2	; Act 1
		dc.l	Col_SYZ_1, Col_SYZ_2	; Act 2
		dc.l	Col_SYZ_1, Col_SYZ_2	; Act 3
		dc.l	Col_SYZ_1, Col_SYZ_2	; Act 4
	; BBZ
		dc.l	Col_SBZ_1, Col_SBZ_2	; Act 1
		dc.l	Col_SBZ_1, Col_SBZ_2	; Act 2
		dc.l	Col_SBZ_1, Col_SBZ_2	; Act 3 (CCZ)
		dc.l	Col_SBZ_1, Col_SBZ_2	; Act 4 (Unused)
	; MHZ
		dc.l	Col_MHZ_1, Col_MHZ_2	; Act 1
		dc.l	Col_MHZ_1, Col_MHZ_2	; Act 2
		dc.l	Col_MHZ_1, Col_MHZ_2	; Act 3
		dc.l	Col_MHZ_1, Col_MHZ_2	; Act 4 (Unused)
	; HPZ
		dc.l	Col_HPZ_1, Col_HPZ_2	; Act 1
		dc.l	Col_HPZ_1, Col_HPZ_2	; Act 2
		dc.l	Col_HPZ_1, Col_HPZ_2	; Act 3
		dc.l	Col_HPZ_1, Col_HPZ_2	; Act 4 (Unused)
	; TMZ
		dc.l	Col_TMZ_1, Col_TMZ_2	; Act 1
		dc.l	Col_TMZ_1, Col_TMZ_2	; Act 2
		dc.l	Col_TMZ_1, Col_TMZ_2	; Act 3
		dc.l	Col_TMZ_1, Col_TMZ_2	; Act 4 (Unused)
		zonewarning	ColPointers,8*4	; We now have 4 sets of indexes per zone.
	; Ending
		dc.l	Col_End_1, Col_End_2	; Act 1
		dc.l	Col_End_1, Col_End_2	; Act 2
		dc.l	Col_End_1, Col_End_2	; Act 3
		dc.l	Col_End_1, Col_End_2	; Act 4

		include	"Includes/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; Subroutine to	change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SynchroAnimate:
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.w	@syncEnd

	; Used for GHZ spiked log
	@sync:
		subq.b	#1,(v_ani0_time).w ; has timer reached 0?
		bpl.s	@sync2		; if not, branch
		move.b	#$B,(v_ani0_time).w ; reset timer
		subq.b	#1,(v_ani0_frame).w ; next frame
		andi.b	#7,(v_ani0_frame).w ; max frame is 7

	; Used for rings and giant rings
	@sync2:
		subq.b	#1,(v_ani1_time).w
		bpl.s	@sync3
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
;		cmpi.b	#(Art_Ring_End-Art_Ring)>>7,(v_ani1_frame).w
;		bne.s	@sync2dyn
		andi.b	#3,(v_ani1_frame).w

	; Dynamic graphics? Nah, apparently not. I tried, and it just came out as... Knuckles?
;	@sync2dyn:
;		moveq	#0,d0
;		move.l	#Art_Ring>>1,d1
;		move.b	(v_ani1_frame).w,d0
;		lsl.w	#6,d0
;		add.l	d0,d1
;		move.w	#$7B2*$20,d2
;		move.w	#$80/2,d3
;		bsr.w	Add_To_DMA_Queue

	; Used for nothing
	@sync3:
		subq.b	#1,(v_ani2_time).w
		bpl.s	@sync4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		cmpi.b	#6,(v_ani2_frame).w
		blo.s	@sync4
		move.b	#0,(v_ani2_frame).w

	; Used for bouncing rings
	@sync4:
		tst.b	(v_ani3_time).w
		beq.s	@syncEnd
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

	@syncEnd:
		rts
; End of function SynchroAnimate

; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndOfLevelArtLoad:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		bne.w	@exit		; if yes, branch
		cmpi.b	#2,(v_act).w	; is act number 02 (act 3)?
		beq.w	@exit		; if yes, branch

		move.w	(v_screenposx).w,d0
		move.w	(v_limitright2).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0		; has Sonic reached the	edge of	the level?
		blt.w	@exit		; if not, branch
		tst.b	(f_timecount).w
		beq.w	@exit
		cmp.w	(v_limitleft2).w,d1
		beq.w	@exit
		move.w	d1,(v_limitleft2).w ; move left boundary to current screen position
		moveq	#plcid_LevelEnd,d0
		bra.w	NewPLC		; load signpost	patterns

	@exit:
		rts
; End of function EndOfLevelArtLoad