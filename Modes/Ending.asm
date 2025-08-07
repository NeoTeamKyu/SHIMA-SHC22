; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

GM_Ending:
		command	mus_Stop	; stop music
		bsr.w	PaletteFadeOut

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#(v_objspace_End-v_objspace)/4-1,d1
	End_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,End_ClrObjRam ; clear object	RAM

		lea		(v_clearpalvars).w,a1
		moveq	#0,d0
		move.w	#(v_clearpalvars_end-v_clearpalvars)/4-1,d1

	End_ClrVars1:
		move.l	d0,(a1)+
		dbf		d1,End_ClrVars1 ; clear misc variables

		lea		(v_clearvars).w,a1
		moveq	#0,d0
		move.w	#(v_clearvars_end-v_clearvars)/4-1,d1

	End_ClrVars2:
		move.l	d0,(a1)+
		dbf		d1,End_ClrVars2 ; clear misc variables

		lea		(v_clearanivars).w,a1
		moveq	#0,d0
		move.w	#(v_clearanivars_end-v_clearanivars)/4-1,d1

	End_ClrVars3:
		move.l	d0,(a1)+
		dbf		d1,End_ClrVars3 ; clear object variables

		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
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
		move.w	(v_hbla_hreg).w,(a6)
		ResetDMAQueue

		move.w	#30,(v_air).w
		move.w	#id_EndZ<<8,(v_zone).w ; set level number to 0600 (extra flowers)
		cmpi.b	#6,(v_emeralds).w ; do you have all 6 emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#(id_EndZ<<8)+1,(v_zone).w ; set level number to 0601 (no flowers)

End_LoadData:
		moveq	#plcid_Ending,d0
		bsr.w	QuickPLC	; load ending sequence patterns
		jsr		LoadEndingCharacterPLC
		jsr		(Hud_Base).l
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_fg_scroll_flags).w
		bsr.w	LoadZoneTiles	; load level art
		bsr.w	LevelDataLoad ; load block mappings and palettes
		bsr.w	LoadLevelPLC2
		bsr.w	LoadTilesFromStart
		move.l	#Col_End_1,(v_colladdr1).w ; MJ: Set first collision for ending
		move.l	#Col_End_2,(v_colladdr2).w ; MJ: Set second collision for ending
		enable_ints
	; Disabled due to a crash.
;		lea		(Kos_EndFlowers).l,a0 ;	load extra flower patterns
;		lea		(FlowersBuffer).l,a1 ; RAM address to buffer the patterns
;		bsr.w	KosDec
	; Buffer was too small, I think.
		jsr		LoadPlayerPal
		bsr.w	PalLoad1	; load Sonic's palette
		music	mus_Ending	; play ending sequence music
		btst	#bitA,(v_jpadhold1).w ; is button A pressed?
		beq.s	End_LoadSonic	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

End_LoadSonic:
		jsr		LoadPlayerObject
		bset	#0,(v_player+obStatus).w ; make Sonic face left
		move.b	#1,(f_lockctrl).w ; lock controls
		move.w	#(btnL<<8),(v_jpadhold2).w ; move Sonic to the left
		move.w	#$F800,(v_player+obInertia).w ; set Sonic's speed
		move.b	#1,(v_levelstarted).w
		st		(f_cameraenabled).w
		jsr		(ObjPosLoad).l
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w
		move.b	d0,(v_shield).w
		move.b	d0,(v_invinc).w
		move.b	d0,(v_shoes).w
		move.b	d0,(v_lastlamp-1).w
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_ringcount).w
		move.b	#0,(f_timecount).w
		move.w	#1800,(v_demolength).w
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		move.w	#$3F,(v_pfade_start).w
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		bsr.w	PaletteCycle
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		cmpi.b	#id_Ending,(v_gamemode).w ; is game mode $18 (ending)?
		beq.s	End_ChkEmerald	; if yes, branch

		move.b	#id_Credits,(v_gamemode).w ; goto credits
		music	mus_Credits	; play credits music
		move.w	#0,(v_creditsnum).w ; set credits index number to 0
		rts
; ===========================================================================

End_ChkEmerald:
		tst.w	(f_restart).w	; has Sonic released the emeralds?
		beq.w	End_MainLoop	; if not, branch

		clr.w	(f_restart).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	End_AllEmlds:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	End_SlowFade
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

	End_SlowFade:
		tst.w	(f_restart).w
		beq.w	End_AllEmlds
		clr.w	(f_restart).w
	;	move.l	#Level_EndGood,(v_lvllayoutfg).w ; MJ: set extra flowers version of ending's layout to be read
	;	lea		(vdp_control_port).l,a5
	;	lea		(vdp_data_port).l,a6
	;	lea		(v_screenposx).w,a3
	;	movea.l	(v_lvllayoutfg).w,a4	; MJ: Load address of layout
	;	move.l	#$4000+(vram_fg&$2000)+((vram_fg&$C000)<<2),d2	; VRAM thing for selecting Plane A
	;	bsr.w	DrawChunks
		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		jsr		LoadPlayerPal
		bsr.w	PalLoad1	; load Sonic's palette
		bsr.w	PaletteWhiteIn
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:
		move.b	(v_playerend).w,d0
		bne.s	End_MoveSon2
		cmpi.w	#$90,(v_player+obX).w ; has Sonic passed $90 on x-axis?
		bhs.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_playerend).w
		move.b	#1,(f_lockctrl).w ; lock player's controls
		move.w	#(btnR<<8),(v_jpadhold2).w ; move Sonic to the right
		rts
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0
		bne.s	End_MoveSon3
		cmpi.w	#$A0,(v_player+obX).w ; has Sonic passed $A0 on x-axis?
		blo.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_playerend).w
		moveq	#0,d0
		move.b	d0,(f_lockctrl).w
		move.w	d0,(v_jpadhold2).w ; stop Sonic moving
		move.w	d0,(v_player+obInertia).w
		move.b	#$81,(f_lockmulti).w ; lock controls & position
		move.b	#3,(v_player+obFrame).w
		move.w	#(id_Wait<<8)+id_Wait,(v_player+obAnim).w ; use "standing" animation
		move.b	#3,(v_player+obTimeFrame).w
		rts
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,(v_playerend).w
		move.w	#$A0,(v_player+obX).w
		move.b	#id_EndSonic,(v_player).w ; load Sonic ending sequence object
		clr.w	(v_player+obRoutine).w

End_MoveSonExit:
		rts
; End of function End_MoveSonic

; ===========================================================================

		include	"Objects/Screen-Space/87 Ending Sequence Sonic.asm"
		include	"Animations/Ending Sequence Sonic.asm"
		include	"Objects/Screen-Space/88 Ending Sequence Emeralds.asm"
		include	"Objects/Screen-Space/89 Ending Sequence STH.asm"
Map_ESon:	include	"Mappings/Ending Sequence Sonic.asm"
Map_ETai:	include	"Mappings/Ending Sequence Tails.asm"
Map_EKnu:	include	"Mappings/Ending Sequence Knuckles.asm"
Map_ECha:	include	"Mappings/Ending Sequence Emeralds.asm"
Map_ESth:	include	"Mappings/Ending Sequence STH.asm"

; The funny. Specifically aligned so extracting him is easy. :shushing_face:
	align 16
		incbin	"art/uncompressed/scrunkulous scringore.bin"
	align 16
		dc.b	"It was you. YOU are the CRINGE-ASS NAE NAE BABY of legend."