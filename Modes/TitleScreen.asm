GM_Title:

		command	mus_Stop	; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		command	mus_Reset	 ; fade reset music

		disable_ints
		move.l	#NullBlank,HBlankRout.w
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)	; set background colour (palette line 2, entry 0)
		bsr.w	ClearScreen
	if DemoMode=1
	    jsr SHC2022	
	endc			
		ResetDMAQueue

		moveq	#0, d0
		move.w	d0,(v_screenposx).w
		move.w	d0,(v_screenposy).w

	;-- Moved these into an area that makes more sense --
		move.b	d0, (f_wtr_state).w
		move.b	d0, (v_levelstarted).w
		move.b	d0, (f_debugmode).w 	; disable debug mode
		move.w	d0,(v_title_dcount).w
		move.w	d0,(v_title_ccount).w
		move.w	d0,(v_correctcheatentries).w

		move.b	d0,(v_lastlamp).w 		; clear lamppost counter
		move.w	d0,(v_debuguse).w 		; disable debug item placement mode
		move.w	d0,(f_demo).w			; disable debug mode
		move.w	d0,(v_csum_addr-2).w 	; unused variable
		move.w	d0,(v_pcyc_time).w 		; disable palette cycling
		move.b	d0,(f_wtr_state).w
		move.b	d0,(f_bg_state).w
		move.b	d0,(f_water).w
		move.b	d0,(f_background).w
		lea		(v_objspace).w,a1
		move.w	#(v_objspace_End-v_objspace)/4-1,d1
	Tit_ClrObj1:
		move.l	d0,(a1)+
		dbf		d1,Tit_ClrObj1	; fill object space ($D000-$EFFF) with 0

		lea		(v_pal_dry_dup).w,a1
		moveq	#cBlack,d0
		move.w	#$1F,d1
	Tit_ClrPal:
		move.l	d0,(a1)+
		dbf		d1,Tit_ClrPal	; fill palette with 0 (black)
		st		(f_cameraenabled).w
		disable_ints
		locVRAM	$4000
		lea		(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec

		move.w	#(id_EndZ<<8)+3,(v_zone).w	; set level to Ending act 4.
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		lea		(v_16x16).w,a1
		lea		(Blk16_Title).l,a0 		; load	GHZ 16x16 mappings
		moveq	#0, d0				;I think this is alright to change to
		bsr.w	EniDec
		lea		(Blk128_Title).l,a0 	; load GHZ 128x128 mappings
		lea		(v_128x128).l,a1
		bsr.w	KosDec
		lea		(v_128x128).l,a1
		lea		(Eni_Title).l,a0 ; load	title screen mappings
		moveq	#0,d0
		bsr.w	EniDec

		if	DemoMode=0
			copyTilemap	v_128x128,$C20C,$21,$15
		else
			copyTilemap	v_128x128,($C20C+$280),$21,$15		;$C20C (moved down 20 cells)
		endif
		
		jsr		LoadZoneTiles
		bsr.w	LevelDataLoad ; load block mappings and palettes
		disable_ints
		bsr.w	LoadBGFromStart
		enable_ints
		moveq	#palid_Sonic,d0	; load Sonic's palette
		bsr.w	PalLoad1	; load Sonic's palette
		moveq	#palid_BGZ1,d0	; load title screen palette
		bsr.w	PalLoad1
		;move.w	#$178,(v_demolength).w ; run title screen for $178 frames
		lea		(v_gameover).w,a1
		moveq	#0,d0
		moveq	#$10-1,d1		; this was causing some problems, fixed the bug

	Tit_ClrObj2:
		move.l	d0,(a1)+
		dbf		d1,Tit_ClrObj2

		move.b	#id_TitleSonic,(v_banner).w ; load big Sonic object
		move.b	#id_TitleSonic,(v_boss).w ; load big Abbey object
		move.b	#1,(v_boss+obSubtype).w
		if DemoMode=0
		move.b	#id_TitleOpt,(v_gameover).w ; load title screen options
		endc
		ResetPlaneRender

		move.b	#4,(v_vbla_routine).w	; we can not afford to run the sound driver too
		bsr.w	WaitForVBla		; late, or we will lose the YM data and break music
		music	mus_Title		; play title screen music
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#0, d0
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		bsr.w	RunPLC
		cmpi.w	#$FFFF,(v_screenposx).w	; has the screen passed $3C00 on x-axis?			
		blo.s	Tit_EnterCheat	; if not, branch	
		rts
; ===========================================================================

Tit_EnterCheat:
		lea		(LevSelCode).l,a0 ; load US code
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
	if DemoMode=0	
		move.b	(v_jpadpress1).w,d0 ; get button press
		andi.b	#btnDir,d0	; read only UDLR buttons
		cmp.b	(a0),d0		; does button press match the cheat code?
		bne.s	Tit_ResetCheat	; if not, branch
		addq.w	#1,(v_title_dcount).w ; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea		(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)	; cheat depends on how many times C is pressed

	Tit_PlayRing:
		move.b	#1,(a0,d1.w)	; activate cheat
		sfx		sfx_RingRight	; play ring sound when code is entered
		bra.s	Tit_CountC
	endc		
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		move.w	#0,(v_title_dcount).w ; reset UDLR counter

Tit_CountC:
	if DemoMode=0
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnC,d0	; is C button pressed?
		beq.s	loc_3230	; if not, branch
		addq.w	#1,(v_title_ccount).w ; increment C counter
	endc
	
loc_3230:
;		tst.w	(v_demolength).w
;		beq.w	GotoDemo
		andi.b	#btnStart,(v_jpadpress1).w ; check if Start is pressed
		beq.w	Tit_MainLoop	; if not, branch

		move.w	#id_BGZ<<8,(v_zone).w		;Just in case we start a level!
		if DemoMode=0
		moveq	#0, d0
		move.b	(v_titleoptions).w, d0
		add.w	d0, d0
		add.w	d0, d0
		jmp		MenuTable(pc,d0.w)

MenuTable:
		bra.w	PlayLevel
		bra.w	MenuScreen

	Tit_ConfLevSel:
		move.b	#id_LevelSelect,(v_gamemode).w
		else
		bra.w	MenuScreen
		endc
		rts

	if def(n)
		inform 1,"try to make more original variable name pls :V(n is \#n)"
		disable n	; anyway
	endif

	n: equs "\^n"	; asm68k exploit


; ===========================================================================
; ---------------------------------------------------------------------------
; code buffering stuff
; ---------------------------------------------------------------------------

	code_0: equs ""
	codec: = 0

asmb macro
	rept narg
		if def(code_\#codec)
			disable code_\#codec
		endif
		code_\#codec: equs \1
		codec: = codec + 1
		shift
	endr
	endm

asmb_print macro
	local i, str, substr, quotetype
	i: = 0
	rept codec
		str: equs code_\#i
		\str
		i: = i + 1
	endr
	codec: = 0
	endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Converts ascii char(ch) to char format presented in 1st tile of that character in hud art
; returns:
; ch = char number | flags
; ---------------------------------------------------------------------------

convASCII2: macro
		case ch
='0'
		ch: = 0
='1'
		ch: = 1
='2'
		ch: = 2
='3'
		ch: = 3
='4'
		ch: = 4
='5'
		ch: = 5
='6'
		ch: = 6
='7'
		ch: = 7
='8'
		ch: = 8
='9'
		ch: = 9
='$'
		ch: = 10
='-'
		ch: = 11
='='
		ch: = 12
='>'
		ch: = 14
='<'
		ch: = 14|$800	; H flip
=' '
		ch: = 0
='a'
		ch: = 17
='b'
		ch: = 18
='c'
		ch: = 19
='d'
		ch: = 20
='e'
		ch: = 21
='f'
		ch: = 22
='g'
		ch: = 23
='h'
		ch: = 24
='i'
		ch: = 25
='j'
		ch: = 26
='k'
		ch: = 27
='l'
		ch: = 28
='m'
		ch: = 29
='n'
		ch: = 30
='o'
		ch: = 31
='p'
		ch: = 32
='q'
		ch: = 33
='r'
		ch: = 34
='s'
		ch: = 35
='t'
		ch: = 36
='u'
		ch: = 37
='v'
		ch: = 38
='w'
		ch: = 39
='x'
		ch: = 40
='y'
		ch: = 41
='z'
		ch: = 42
='\n'
		ch: = -2
='\^n'
		ch: = -2
='\^0'
		ch: = -1
=?
		inform	3,"Character \#ch is not supported"
		endcase
		endm

; ===========================================================================
; ---------------------------------------------------------------------------
; Converts ascii char(ch) to char format presented in 1st tile of that character in hud art
; input:
;   gfx - art tile and flags,
;   string - guess what?
; returns:
; ch = char number
; ---------------------------------------------------------------------------

planeASCII	macro   gfx, string
	lc: = 0
	len: = 0
	asmb		"dc.w len"
	while	(lc < strlen(\string))
		curCh:  substr lc+1,lc+1,\string	; current symbol
		ch: = "\curCh"
		convASCII2 ; returns ch as converted ascii
		if (ch = -1)
			;asmb "dc.w	-1"
			len: = lc
			lc: = strlen(\string)
		elseif (ch = -2)
			asmb "dc.w	0"
			inform 2,"newline ain't supported yet"
		else
			asmb "dc.w \gfx + \#ch"
		endif
		lc: = lc + 1
	endw
	asmb_print
	endm
	
; ===========================================================================
; ---------------------------------------------------------------------------
; Easing (Rændom and Fuzzy)
; ---------------------------------------------------------------------------
Ease:
		move.l	obFinalEasingPos(a0),d1	; copy final pos
		sub.l	obX(a0),d1	; less difference, less speed
		beq.s	@noDiff	; if difference is zero, branch
		cmp.l	#1<<16,d1	; is difference less than zero (fixed point 16.16)?
		ble.s	@setFinalPos	; if yes, branch
		asr.l	#2,d1	; it's signed number, so lsr won't work there
	@addDiff:
		add.l	d1,obX(a0)
	@noDiff:
		rts
	@setFinalPos:
		move.l	d0,obFinalEasingPos(a0)
		rts

EaseRtL:	; This is probably super dangerous, but who cares?
		move.l	obFinalEasingPos(a0),d1	; copy final pos
		sub.l	obX(a0),d1	; less difference, less speed
		beq.s	@noDiff	; if difference is zero, branch
		asr.l	#2,d1	; it's signed number, so lsr won't work there
	@addDiff:
		add.l	d1,obX(a0)
	@noDiff:
		rts
	@setFinalPos:
		move.l	d0,obFinalEasingPos(a0)
		rts

; ===========================================================================

PlayLevel:
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		move.b	#3,(v_lives).w	; set lives to 3	; Not necessary if you don't have lives enabled, but keeping this like this anyway to make sure nothing weird happens.
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastspecial).w ; clear special stage number
		move.b	d0,(v_emeralds).w ; clear emeralds
		move.l	d0,(v_emldlist).w ; clear emeralds
		move.l	d0,(v_emldlist+4).w ; clear emeralds
		move.b	d0,(v_continues).w ; clear continues
		move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		command	mus_FadeOut	; fade out music
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevSelCode:
		dc.b	btnUp,btnDn,btnL,btnR,0,$FF
		even
;hello hacker fucker, this is gemini0. heres the deal. if you hack this hack, i will not find you. i am bad at finding people, so your legs are safe. please dont though, its not nice
;181 characters...

	dc.b	"hello hacker fucker, this is john kyukyoku. heres the deal. if you hack this hack, i will not find you. i am bad at finding people, so your legs are safe. please dont though, its not nice"

; ===========================================================================

; ---------------------------------------------------------------------------
; Music	playlist
; ---------------------------------------------------------------------------
MusicList:
		dc.b	mus_BGZ1			; GHZ1
		dc.b	mus_BGZ2			; GHZ2
		dc.b	mus_BGZ3			; GHZ3
		dc.b	mus_EHZ				; LBGZ
		dc.b	mus_Beep			; LZ1
		dc.b	mus_LZ				; LZ2
		dc.b	mus_LZ				; LZ3
		dc.b	mus_SBZ				; LZ4
		dc.b	mus_MZ				; MZ1
		dc.b	mus_MZ				; MZ2
		dc.b	mus_MZ				; MZ3
		dc.b	mus_MZ				; MZ4
		dc.b	mus_SpaceQueens		; SLZ1
		dc.b	mus_SLZ				; SLZ2
		dc.b	mus_SLZ				; SLZ3
		dc.b	mus_SpaceQueens		; SLZ4
		dc.b	mus_ChineseBicycle	; SYZ1
		dc.b	mus_IceScream		; SYZ2
		dc.b	mus_ChineseBicycle	; SYZ3
		dc.b	mus_ChineseBicycle	; SYZ4
		dc.b	mus_SBZ				; SBZ1
		dc.b	mus_SBZ				; SBZ2
		dc.b	mus_FZ				; SBZ3
		dc.b	mus_SBZ				; SBZ4
		dc.b	mus_Icescape		; MHZ1
		dc.b	mus_ICESCAPE_ACT_2	; MHZ2
		dc.b	mus_LunateElf		; MHZ3
		dc.b	mus_Icescape		; MHZ4
	if DemoMode=0		
		dc.b	mus_MCZ2P			; HPZ1
		dc.b	mus_MCZ2P			; HPZ2
		dc.b	mus_MCZ2P			; HPZ3
		dc.b	mus_MCZ2P			; HPZ4
		dc.b	mus_FBZ1			; TMZ1
		dc.b	mus_FBZ1			; TMZ2
		dc.b	mus_FBZ1			; TMZ3
		dc.b	mus_FBZ1			; TMZ4	
		zonewarning	MusicList,4
	else	
		dc.b	mus_LZ			; HPZ1
		dc.b	mus_LZ			; HPZ2
		dc.b	mus_LZ			; HPZ3
		dc.b	mus_LZ			; HPZ4
		dc.b	mus_SBZ			; TMZ1
		dc.b	mus_SBZ			; TMZ2
		dc.b	mus_SBZ			; TMZ3
		dc.b	mus_SBZ			; TMZ4	
	endc		
		dc.b	mus_BGZ1			; END1
		dc.b	mus_BGZ1			; END2
		dc.b	mus_BGZ1			; END3
		dc.b	mus_BGZ1			; END4
	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to reset music to current zone default music
; ---------------------------------------------------------------------------

ResetZoneMusic:
		moveq	#0,d0
		move.w	(v_zone).w,d0
		ror.b	#2,d0
		lsr.w	#6,d0
		lea		(MusicList).l,a1 ; load	music playlist
		move.b	(a1,d0.w),d0
		move.b	d0,(v_savedmusic).w
		move.b	d0,mQueue+1.w	; play music
		rts
		
; ===========================================================================
; ---------------------------------------------------------------------------
; Menu Screen
; ---------------------------------------------------------------------------
		include	"Includes/Menu Screen.asm"