; ---------------------------------------------------------------------------
; New Menu Screem
; ---------------------------------------------------------------------------
	rsset	$FFFF8000
CurrentSel:	rs.b	1		;Current Selection
CurLstNum:	rs.b	1		;Current Options List #
NumOptions:	rs.b	1		;Number of options in the list
CurBounce:	rs.b	1		;Counter for making the cursor bounce
MBGFrame:	rs.b	1		;Frame counter for background
MBGScroll:	rs.b	1		;Scroll counter for the background
NumLst:		rs.w	1		;How many lists to go back through in (CurrentLst*4)
OptionJMP:	rs.w	1		;Makes a "jmp (address)"
OptionAddr:	rs.l	1		;"(address)
CurrentLst:	rs.l	1		;Current List being used for Options
DescInit:	rs.b	40		;Where we store the unmodified version of the description
DescBuffer:	rs.b	40		;Buffer for the Description visual trick
PrevLst:	rs.l	1		;Addresses of previous lists we were on, expands
; Don't put any vars past this

FontPntr:		equ		$680-$33
OptionsPos:		equ		$40000003|((5*$20000)+(2*$800000))	;X + Y
DescPos:		equ		$40000003|((3*$20000)+(20*$800000))
CursorPos:		equ		($80+(3*$8))	;Cursor X in tiles + screen margin
CursorXMargin:	equ		16

AniArt_MenuBG:

@size:	equ 9	; number of tiles per frame

		subq.b	#1,(MBGScroll).w ; decrement timer
		bpl.s	@end ; branch if not 0

		move.b	#59,(MBGScroll).w ; time to display each frame
		lea		(Art_MenuBG).l,a1 ; load menu BG patterns
		move.b	(MBGFrame).w,d0
		addq.b	#1,(MBGFrame).w ; increment frame counter
		andi.b	#1,d0		; there are only 2 frames
		beq.s	@isframe0	; branch if frame 0
		lea		@size*$20(a1),a1 ; use graphics for frame 1

	@isframe0:
		locVRAM	0		; VRAM address
		move.w	#@size-1,d1	; number of 8x8	tiles
		jmp		LoadTiles
	
	@end:
		rts

MenuScreen:
		command	mus_Stop
		bsr.w	PaletteFadeOut
		bsr.w	ClearScreen
		disable_ints
		move.w	#$8B00, (vdp_control_port)
		
		moveq	#0, d0
		move.b	d0, (CurrentSel).w
		move.b	d0, (CurLstNum).w
		move.b	d0, (NumOptions).w
		move.b	d0, (CurBounce).w
		move.b	d0, (MBGFrame).w
		move.b	d0, (MBGScroll).w
		move.w	d0, (NumLst).w
		move.w	#$4EF9, (OptionJMP).w
		move.l	d0, (OptionAddr).w
		move.l	#OptionsTable1, (CurrentLst).w
		lea		vdp_data_port, a6				;Vdp_data_port
		lea		4(a6), a5						;Vdp_control_port

		move.w	#$8400+(vram_bg>>13), (a6)	; set background nametable address
		move.w	#$9001, (a6)				; 64-cell hscroll size
		locVRAM	0
		lea		Nem_MenuBG, a0				; For the first frames of being in the menu.
		bsr.w	NemDec
		lea		v_128x128, a1
		lea		Eni_MenuBG, a0				; load menu background mappings
		moveq	#0, d0
		bsr.w	EniDec
		copyTilemap	v_128x128,$E000,63,31
		
		locVRAM	$D000,(vdp_control_port).l
		lea		(Nem_MenuFont).l,a0
		jsr		NemDec
		
		move.l	(CurrentLst).w, a1
		moveq	#0, d2
		bsr.w	PrintAll
		
		moveq	#$30, d0			;Initial value to fill the buffer with
		moveq	#(40*2)-1, d1
		lea		DescInit, a1
		lea		(a1), a2
	@InitBuffers:
		move.b	d0, (a1)+
		dbra	d1, @InitBuffers
		
		move.l	#DescPos, d1
		moveq	#0, d2
		move.l	(CurrentLst).w, a1
		bsr.w	LoadDesc
		
		enable_ints
		bsr.w	PaletteFadeIn
		music	mus_MM8StageSelect
		
MenuScreenMain:
		move.b	#4, (v_vbla_routine).w
		bsr.w	WaitForVBla
		
; Animation
		bsr.w	AniArt_MenuBG
; Scrolling
		lea		v_menuscrolltimer, a0
		addi.l	#65536*8/60, (a0)
		move.w	(a0), d0
		neg.w	d0
		move.w	d0, (v_scrposy_dup+2).w
		move.w	d0, (v_hscrolltablebuffer+2).w
		
		bsr.w	DrawCursor
		
	;These will be changed if we move our cursor
	;(Provided for ProcessDesc)
		moveq	#0, d2
		move.b	(CurrentSel).w, d2
		move.l	(CurrentLst).w, a1
		
		btst	#bitDn, (v_jpadpress1)
		beq.s	@NoDown
		lea		OptionCount, a0			;Something with accessing the table isn't working
		moveq	#0, d0
		move.b	(CurLstNum).w, d0
		subq.b	#1, d0
		move.b	(a0,d0.w), d0
		subq.b	#1, d0
		cmp.b	(CurrentSel).w, d0
		beq.s	@NoDown
		addq.b	#1, (CurrentSel).w
		bsr.w	ChangeOption
	@NoDown:
		btst	#bitUp, (v_jpadpress1)
		beq.s	@NoUp
		tst.b	(CurrentSel).w
		beq.s	@NoUp
		subq.b	#1, (CurrentSel).w
		bsr.w	ChangeOption
	@NoUp:
	
	;Run the Description Effect
		move.l	#DescPos, d1
		bsr.w	ProcessDesc
		
		btst	#bitSTART, (v_jpadpress1)
		beq.s	@NoSTART
		bra.w	SelectOption
	@NoSTART:
		btst	#bitA, (v_jpadpress1)
		beq.s	@NoA
		bra.w	SelectOption
	@NoA:
		
		btst	#bitB, (v_jpadpress1)
		beq.w	MenuScreenMain
		sfx		sfx_Cancel
		tst.w	(NumLst).w				;If we're at the main page
		beq.w	ReturnTitle				;Return to titlescreen
		bsr.w	DecreasePage			;Otherwise go back a page
		bra.w	MenuScreenMain
		
; ---------------------------------------------------------------------------
; Changes depending on CurrentSel
ChangeOption:
		sfx		sfx_Choose
		moveq	#0, d2
		move.l	#DescPos, d1
		move.b	(CurrentSel).w, d2
		move.l	(CurrentLst).w, a1
		bsr.w	LoadDesc
		rts
	
; ---------------------------------------------------------------------------
DecreasePage:
		subq.w	#4, (NumLst).w
		lea		PrevLst, a0
		move.w	(NumLst).w, d0
		move.l	(a0,d0.w), (CurrentLst).w
		bra.s	ChangePage
		
; d1.l	= Page Address
AdvancePage:
		lea		PrevLst, a0
		lea		CurrentLst, a2
		move.w	(NumLst).w, d0
		move.l	(a2), (a0,d0.w)		;Put the list we're on onto PrevLst
		addq.w	#4, (NumLst).w		;Set to go back one list
		move.l	d1, (a2)			;Put next page onto CurrentLst
	
; CurrentLst.l	= Page to change to
ChangePage:
		move.l	#$40000003, d1
		moveq	#28-1, d0
		bsr.w	ClearRow
		
		lea		CurrentLst, a2
		clr.b	(CurrentSel).w
		moveq	#0, d2
		move.l	(a2), a1
		bsr.w	PrintAll
		move.l	#DescPos, d1
		moveq	#0, d2
		move.l	(a2), a1
		bsr.w	LoadDesc
		rts
		
; ---------------------------------------------------------------------------
; Does what it says
SelectOption:
		tst.b	(CurrentSel).w			;First option?
		bne.s	@notFirst
		tst.w	(NumLst).w				;First list (main)?
		bne.s	@notFirst
		sfx		sfx_StartGame
		bra.s	@cont
	@notFirst:
		sfx		sfx_Select
		cmpi.b	#4,(CurrentSel).w				;First list (main)?
		bne.s	@cont
		tst.w	(NumLst).w				;First list (main)?
		bne.s	@cont
		music	mus_Icescape

	@cont:
		moveq	#0, d0
		move.b	(CurrentSel).w, d0
		add.w	d0, d0
		move.l	(CurrentLst).w, a1
		move.w	(a1,d0.w), d0
		lea		(a1,d0.w), a0
		move.l	(a0), (OptionAddr).w	;Get label stored in option
		beq.w	MenuScreenMain			;Do nothing if option is null
		jmp		(OptionJMP).w
		
; Draws the bouncing sprite cursor
DrawCursor:
		move.l	#$78000003, (a5)
		addq.b	#3, (CurBounce).w
		moveq	#0, d0
		move.b	(CurBounce).w, d0
		bsr.w	Calcsine
		bpl.s	@NoClear
		neg.w	d0
	@NoClear:
		lsr.w	#$5, d0
		add.b	#CursorPos, d0
		move.w	(CurrentSel).w, d1
		lsr.w	#$4, d1
		add.w	#CursorXMargin+$80, d1
		
		move.w	d1, (a6)
		move.w	#$0000, (a6)
		move.w	#$06B1, (a6)
		move.w	d0, (a6)
		rts
		
; ---------------------------------------------------------------------------
; a1	= Pointer to Table
; d0.w 	= Table Offset
; d1.w 	= X and Y

PrintOption:
		add.w	d0, d0
		move.w	(a1,d0.w), d0
		lea		(a1,d0.w), a0
		lea		NamePos(a0), a0			;Put pointer past Option name and table num
		swap	d1
		or.l	#$40000003, d1
		move.l	d1, (a5)
	@DrawPlane:
		moveq	#0, d0
		move.b	(a0)+, d0
		bmi.s	@Return				;Check if end of option
		add.w	#FontPntr, d0
		move.w	d0, (a6)
		bra.s	@DrawPlane
	@Return:
		rts
		
; ---------------------------------------------------------------------------
; a1	= Pointer to Table
; d0.w	= Table Offset (Unused?)
; d1.w	= VRAM Address for location
; d2.w	= Which option in Table

LoadDesc:
		add.w	d2, d2
		move.w	(a1,d2.w), d2
		lea		(a1,d2.w), a0		;Grab which option
		lea		NamePos(a0), a0			;Put pointer past Option name and table num
	@GetDesc1:
		tst.b	(a0)+				;Search for beginning of description
		bpl.s	@GetDesc1
		tst.b	(a0)
		bne.s	@GetDesc2
		lea		1(a0), a0			;Compensating for last option in list
	@GetDesc2:
		moveq	#1-1, d0
		bsr.w	ClearRow			;Clear for description
		
		moveq	#$30, d0			;Initial value to fill the buffer with
		moveq	#40-1, d1
		lea		DescInit, a1
		lea		(a1), a2
	@InitBuffers:
		move.b	d0, (a1)+
		dbra	d1, @InitBuffers
		
	@LoadCopy:
		moveq	#0, d0
		move.b	(a0)+, d0
		bmi.s	@Return
		move.b	d0, (a2)+
		bra.s	@LoadCopy
	@Return:
		rts
		
; Inputs:
; a1.w	= Pointer to table
; d1.w	= VRAM address for display
; d2.w	= Which option in the list
ProcessDesc:
		add.w	d2, d2
		move.w	(a1,d2.w), d2
		lea		(a1,d2.w), a0		;Grab which option
		lea		NamePos(a0), a0			;Put pointer past Option name and table num
	@GetDesc1:
		tst.b	(a0)+				;Search for beginning of description
		bpl.s	@GetDesc1
		tst.b	(a0)
		bne.s	@GetDesc2
		lea		1(a0), a0			;Compensating for last option in list
	@GetDesc2:
		
		move.l	d1, (a5)
		lea		DescInit, a0
		lea		DescBuffer, a1
		moveq	#40-1, d1
	@EffectLoop:
		moveq	#0, d0
		move.b	(a1)+, d0
		cmp.b	(a0)+, d0
		beq.s	@Equal
		addq.b	#1, d0
		cmp.b	#$64, d0
		bne.s	@NoReset
		moveq	#$20, d0
	@NoReset:
		move.b	d0, -1(a1)
	@Equal:
		add.w	#FontPntr, d0
		move.w	d0, (a6)
		dbra	d1, @EffectLoop
		rts
		
; ---------------------------------------------------------------------------
; Take a guess
ClearRow:
		move.l	d1, (a5)
		moveq	#40-1, d3
	@RowLoop:
		move.w	#0, (a6)
		dbra	d3, @RowLoop
		add.l	#$800000, d1
		dbra	d0, ClearRow
		rts
		
; ---------------------------------------------------------------------------
; a1	= Pointer to Table
; d2.b	= Start Offset

PrintAll:
		move.l	#OptionsPos, d1		;Starting position to print all options
	@PrintLoop:
		moveq	#0, d0
		move.b	d2, d0
		move.w	(a1,d0.w), d0
		lea		(a1,d0.w), a0
		move.b	TblPos(a0), d0		;Grabbing tbl value from option
		move.b	d0, (CurLstNum).w	;Save list we're on (Couldn't find better spot)
		lea		NamePos(a0), a0		;Grabbing start position of the option's name
		move.l	d1, (a5)
	@DrawPlane:
		moveq	#0, d0
		move.b	(a0)+, d0
		bmi.s	@CheckNext			;Check if end of option
		add.w	#FontPntr, d0
		move.w	d0, (a6)
		bra.s	@DrawPlane
	@CheckNext:
		addq.b	#2, d2
		add.l	#$1000000, d1		;Go down 2 rows ($800000*2)
		tst.b	(a0)
		bne.s	@PrintLoop
	@Return:
		rts
		
; ---------------------------------------------------------------------------

	;For context, see the Option macro
	NamePos:	equ	5	;Byte position for the start of an option's name
	TblPos:		equ	4	;Byte position for the table number of an option
	
	cnt: = 0
	opcnt: = 0

Option:	macro
	cnt: = cnt+1
	Option\#tbl\\#cnt:
		dc.l	\1
		dc.b	tbl				;Changed from a word (Why in the world was it a word?)
		if	(narg=3)
			dc.b	\2, -1, \3, -1
		else
			dc.b	\2, -1, \3, \4, -1
		endc
		even
	endm
	
OptionTbl:	macro
	opcnt: = opcnt+1
	pushp	'\#cnt'
	\1:
	rpt: = cnt
	rept	cnt
		rpt: = rpt-1
		num: = cnt-rpt
			dc.w	Option\#tbl\\#num-\1
	endr
	even
	cnt: = 0
	endm
	
OptionCnt:	macro
	\1:
	temp: = 0
	rpt: = opcnt
	rept \#opcnt
		local n\#opcnt
		popp n\#opcnt
		opcnt: = opcnt-1
	endr
	rept \#rpt
		temp: = temp+1
		dc.b	n\#temp
	endr
	even
	endm
; ---------------------------------------------------------------------------
; Menu Options and Option Lists
; - Define a table with "tbl" and a number preceding the previous table
; - End a table with "OptionTbl" and a name for this table
; - The last option in a table MUST include a 0 in it's 3 parameter THEN do a description

	;Font Equivalents:
	;Input == Result
	;` == )
	;3456789 == 0123456
	;: == 7
	;< == 9
	;= == *
	;[ == !
	;] == +
	;\ == "
	;@ == .
	;^ == '
	;_ == (
	;> == @
	;? == :
	;A through Z == A through Z
	
	tbl: = 1
	Option	PlayLevel, "START GAME", "GET CRACKIN^"
	Option	ChangeCharacter, "CHANGE CHARACTER", "CHOOSE YOUR FIGHTER["
;	Option	NullCode, "SAVE GAMES", "SAVE YOUR GAME DUMMY!"
	Option	GM_SoundTest, "SOUND TEST", "LISTEN TO THE SOUNDTRACK"
	Option	GameSettings, "GAME SETTINGS", "CHANGE MODES OR ADJUST SOUNDS"
	Option	GM_Credits, "CREDITS", "WHO DID WHAT"
	Option	ReturnTitle, "RETURN TO TITLE", 0, "GO BACK TO THE TITLESCREEN"
	OptionTbl	OptionsTable1
	
	tbl: = 2
	Option	SetChar, "SONIC THE HEDGEHOG", "EXCELS IN GOING FAST@"
	Option	SetChar, "MILES \TAILS\ PROWER", "CAN FLY FOR A LIMITED TIME@"
	Option	SetChar, "KNUCKLES THE ECHIDNA", 0, "CAN GLIDE AND CLIMB WALLS@"
;	Option	SetChar, "KYUKO THE FOX", "THIS CHARACTER IS A WORK IN PROGRESS@"
;	Option	SetChar, "METAL SONIC", "SONIC CD MOVESET@ PEELOUT AND SPIN DASH@"
;	Option	SetChar, "MIGHTY THE ARMADILLO", "CAN CLIMB WALLS@ SPIKE RESISTANT@"
;	Option	SetChar, "AMY ROSE", "HAS A VERY LARGE HAMMER@ CANNOT ROLL@"
;	Option	SetChar, "LEGACY SONIC", 0, "SONIC KYUKYOKU 534;^S SONIC@"
	OptionTbl	CharSelTable
	
	tbl: = 3
	Option	ToggleMiscOptions, "TOGGLE MUSIC", "TURNS MUSIC ON OR OFF@"
	Option	ToggleMiscOptions, "TOGGLE SFX", "TURNS SOUND EFFECTS ON OR OFF@"
	Option	ToggleMiscOptions, "LIVES SYSTEM", "TOGGLES LIVES AND GAME OVERS@"
	Option	ToggleMiscOptions, "GOD MODE", "COMPLETE INVINCIBILITY _MINUS PITS`"
	Option	ToggleMiscOptions, "SUPER CHALLENGE", 0, "REACH THE END BEFORE RINGS RUN OUT["
	OptionTbl	GameSettingsTable
	
	OptionCnt	OptionCount		;End the list of options with this
; ---------------------------------------------------------------------------
NullCode:	equ	$00000000
		
ReturnTitle:
		rts
		
SetChar:
		move.b	(CurrentSel).w,(v_character).w
		bsr.w	DecreasePage
		bra.w	MenuScreenMain

ToggleMiscOptions:
		moveq	#0,d3
		move.b	(CurrentSel).w,d3
		bchg	d3,(v_miscOptions).w
		cmpi.b	#bitMusic,d3	; Did we just toggle music?
		bne.s	@done			; If not, go away.
		btst	#bitMusic,(v_miscOptions).w	; Did we turn it off?
		bne.s	@musOff						; if so, fade out
		music	mus_MM8StageSelect
		bra.s	@done
	@musOff:
		command	mus_Stop
	@done:
		bsr.w	DecreasePage
		bra.w	MenuScreenMain

ChangeCharacter:
		move.l	#CharSelTable, d1
		bsr.w	AdvancePage
		bra.w	MenuScreenMain
		
GameSettings:
		move.l	#GameSettingsTable, d1
		bsr.w	AdvancePage
		bra.w	MenuScreenMain

; ---------------------------------------------------------------------------
Nem_MenuFont:    incbin    "art/nemesis/Standard font.bin"
		even