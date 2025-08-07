; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

GM_Sega:	
		bsr.w	ClrObjRAM
		command	mus_Stop	; stop music
		bsr.w	ClearPLC	
		bsr.w	PaletteWhiteOut
		music	mus_Pichuun	; play "SEGA" sound
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8700,(a6)	; set background colour (palette entry 0)
		move.w	#$8B00,(a6)	; full-screen vertical scrolling
		clr.b	(f_wtr_state).w
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen	
		ResetDMAQueue
		locVRAM	0
		lea		(Nem_NTKLogo).l,a0 ; load NTK	logo patterns
		bsr.w	NemDec
		lea		(v_128x128).l,a1
		lea		(Eni_NTKLogo).l,a0 ; load NTK	logo mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	v_128x128,$C000,39,27

	@loadpal:
		moveq	#palid_NTKLogo,d0
		bsr.w	PalLoad1	; load NTK logo palette. It's now $20 in length, which means it should also load Sonic's.
		bsr.w	PaletteFadeIn
		move.w	#0,(v_pal_buffer+$12).w
		move.w	#0,(v_pal_buffer+$10).w
		move.b	#0,(v_levelstarted).w
		clr.b	(f_cameraenabled).w

		clr.l	(v_scrposy_dup).l	; Clear a longword, because of v_bgscrposy_dup
		clr.w	(v_scrposx_dup).w	; Clear a word, because it's just a word

		clr.l	(v_screenposx).l
		clr.l	(v_screenposy).l

		clr.b	v_csum_start.w			; clear start button check
		st		(v_demolength).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l

Sega_WaitPal:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.b	#id_TitleSonic,(v_banner).w ; load Sonic object
;		move.b	#id_SonicPlayer,(v_player).w ; load Sonic object
		bsr.w	DoChecksum
		move.b	(v_jpadpress1).w,d0		; is Start button pressed?
		or.b	d0,v_csum_start.w		; if so, save it in a variable
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	#4*60,(v_demolength).w	; 4 seconds, used to be 1

Sega_WaitEnd:
		move.b	#$14,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	DoChecksum
		move.b	(v_jpadpress1).w,d0		; is Start button pressed?
		or.b	d0,v_csum_start.w		; if so, save it in a variable
		bra.s	Sega_WaitEnd			; we go to title screen when checksum check is done

DoChecksum:
	; Boy. I sure do hope that me removing the funny checksum code doesn't fuck anything up.

ChecksumEndChk:
		tst.w	(v_demolength).w		; check if playback has ended
		beq.s	Sega_GotoTitle			; if yes, branch
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		tst.b	v_csum_start.w			; check if start button was pressed
		bpl.s	Sega_Locret			; if not, do not return
		cmp.l	#Sega_WaitEnd,(sp)		; check if we are already in this routine
		blo.s	Sega_Locret			; if not, wait more anyway

; loc_395E:
Sega_GotoTitle:
		move.b	#id_Title,(v_gamemode).w	; go to title screen
		addq.l	#4,sp				; do not return

Sega_Locret:
		rts