; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

GM_Credits:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$9200,(a6)		; window vertical position
		move.w	#$8B03,(a6)		; line scroll mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		clr.w 	v_creditsnum	; clear credits slide number
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen
		ResetDMAQueue

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#(v_objspace_End-v_objspace)/4-1,d1
	Cred_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,Cred_ClrObjRam ; clear object RAM

		locVRAM	$0
		lea		(Nem_CreditText).l,a0 ;	load credits alphabet patterns
		bsr.w	NemDec

		lea		(v_pal_dry_dup).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	Cred_ClrPal:
		move.l	d0,(a1)+
		dbf		d1,Cred_ClrPal ; fill palette with black
		moveq	#palid_Credits,d0	; load Sonic's palette
		bsr.w	PalLoad1	; load Sonic's palette
		
	Cred_LoadMaps:
		jsr		Credits_MapLoad
		move.b	#0,(v_levelstarted).w
		st		(f_cameraenabled).w
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l

	Cred_SkipObjGfx:
		move.w	#360,(v_demolength).w ; display a credit for 2 seconds
		bsr.w	PaletteFadeIn

Cred_WaitLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	RunPLC
		tst.w	(v_demolength).w ; have 2 seconds elapsed?
		bne.s	Cred_WaitLoop	; if not, branch
		tst.l	(v_plc_buffer).w ; have level gfx finished decompressing?
		bne.s	Cred_WaitLoop	; if not, branch
		cmpi.w	#9,(v_creditsnum).w ; have the credits finished?
		beq.w	Cred_SEGA	; if yes, branch
		addq.w	#1,(v_creditsnum).w
		bsr.w	PaletteFadeOut
		bra.w   Cred_LoadMaps
		
Cred_SEGA:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts

; ---------------------------------------------------------------------------
; Ending sequence demo loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndingDemoLoad:
		cmpi.w	#9,(v_creditsnum).w ; have credits finished?
		bhs.s	EndDemo_Exit	; if yes, branch
		move.w	#$8001,(f_demo).w ; set demo+ending mode
		move.b	#id_Demo,(v_gamemode).w ; set game mode to 8 (demo)
		move.b	#3,(v_lives).w	; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastlamp).w ; clear lamppost counter
		cmpi.w	#4,(v_creditsnum).w ; is SLZ demo running?
		bne.s	EndDemo_Exit	; if not, branch
		lea		(EndDemo_LampVar).l,a1 ; load lamppost variables
		lea		(v_lastlamp).w,a2
		move.w	#8,d0

	EndDemo_LampLoad:
		move.l	(a1)+,(a2)+
		dbf		d0,EndDemo_LampLoad

EndDemo_Exit:
		rts
; End of function EndingDemoLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in the end sequence demos
; ---------------------------------------------------------------------------
EndDemo_Levels:
		incbin	"Miscellaneous/Demo Level Order - Ending.bin"

; ---------------------------------------------------------------------------
; Lamppost variables in the end sequence demo (Star Light Zone)
; ---------------------------------------------------------------------------
EndDemo_LampVar:
		dc.b	1,	1		; number of the last lamppost
		dc.w	$A00, $62C		; x/y-axis position
		dc.w	13			; rings
		dc.l	0			; time
		dc.b	0,	0		; dynamic level event routine counter
		dc.w	$800		; level bottom boundary
		dc.w	$957, $5CC		; x/y axis screen position
		dc.w	$4AB, $3A6, 0, $28C, 0, 0 ; scroll info
		dc.w	$308		; water height
		dc.b	1,	1		; water routine and state
; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

TryAgainEnd:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8720,(a6)	; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#(v_objspace_End-v_objspace)/4-1,d1
	TryAg_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,TryAg_ClrObjRam ; clear object RAM

		moveq	#plcid_TryAgain,d0
		bsr.w	QuickPLC	; load "TRY AGAIN" or "END" patterns

		lea		(v_pal_dry_dup).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	TryAg_ClrPal:
		move.l	d0,(a1)+
		dbf		d1,TryAg_ClrPal ; fill palette with black

		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		clr.w	(v_pal_dry_dup+$40).w
		move.b	#id_EndEggman,(v_gameover).w ; load Eggman object
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		move.w	#1800,(v_demolength).w ; show screen for 30 seconds
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------
TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		bne.s	TryAg_Exit	; if yes, branch
		tst.w	(v_demolength).w ; has 30 seconds elapsed?
		beq.s	TryAg_Exit	; if yes, branch
		cmpi.b	#id_Credits,(v_gamemode).w
		beq.s	TryAg_MainLoop

TryAg_Exit:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts

; ===========================================================================

		include	"Objects/Screen-Space/8B Try Again & End Eggman.asm"
		include	"Animations/Try Again & End Eggman.asm"
		include	"Objects/Screen-Space/8C Try Again Emeralds.asm"
Map_EEgg:	include	"Mappings/Try Again & End Eggman.asm"

; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	"Demos/Ending - GHZ1.bin"
		even
Demo_EndMZ:		incbin	"Demos/Ending - MZ.bin"
		even
Demo_EndSYZ:	incbin	"Demos/Ending - SYZ.bin"
		even
Demo_EndLZ:		incbin	"Demos/Ending - LZ.bin"
		even
Demo_EndSLZ:	incbin	"Demos/Ending - SLZ.bin"
		even
Demo_EndSBZ1:	incbin	"Demos/Ending - SBZ1.bin"
		even
Demo_EndSBZ2:	incbin	"Demos/Ending - SBZ2.bin"
		even
Demo_EndGHZ2:	incbin	"Demos/Ending - GHZ2.bin"