;  =========================================================================
; |   Sonic the Hedgehog: Isle of Magnetic Artifacts for Sega Mega Drive    |
;  =========================================================================

Main		SECTION org(0)

		opt ws+ ; allows things like dc .w 1 + 2


DemoMode: equ 0 ; Set to 1 to compile limited "Demo Mode" 
		include	"Constants.asm"
		include	"Variables.asm"
		include	"Macros.asm"

		include "AMPS/lang.asm"
		include "AMPS/code/macro.asm"
		include "Error Handler/debugger.asm"

EnableSRAM: equ 0	; change to 1 to enable SRAM
BackupSRAM: equ 1
AddressSRAM: equ 3	; 0 = odd+even; 2 = even only; 3 = odd only
DebugPathSwappers: equ 1
ZoneCount: equ 9	; discrete zones are: BGZ (GHZ), SRZ (LZ), ATZ (MZ), HMZ (SLZ), BCZ (SYZ), BBZ (SBZ), MHZ, HPZ, TMZ. Ending is technically a zone, but why.

ExplodingPetals: equ 0 ; Joke feature. Set to 0 or remove the code to turn off.
		opt w-


; ===========================================================================

StartOfRom:
Vectors:
		dc.l	v_systemstack&$FFFFFF	; Initial stack pointer value
		dc.l	EntryPoint			; Start of program
		dc.l	BusError			; Bus error
		dc.l	AddressError		; Address error (4)
		dc.l	IllegalInstr		; Illegal instruction
		dc.l	ZeroDivide			; Division by zero
		dc.l	ChkInstr			; CHK exception
		dc.l	TrapvInstr			; TRAPV exception (8)
		dc.l	PrivilegeViol		; Privilege violation
		dc.l	Trace				; TRACE exception
		dc.l	Line1010Emu		; Line-A emulator
		dc.l	Line1111Emu		; Line-F emulator (12)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved) (16)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved) (20)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved)
		dc.l	ErrorExcept		; Unused (reserved) (24)
		dc.l	ErrorExcept		; Spurious exception
		dc.l	ErrorTrap			; IRQ level 1
		dc.l	ErrorTrap			; IRQ level 2
		dc.l	ErrorTrap			; IRQ level 3 (28)
		dc.l	HBlankRAM				; IRQ level 4 (horizontal retrace interrupt)
		dc.l	ErrorTrap			; IRQ level 5
		dc.l	VBlankRAM				; IRQ level 6 (vertical retrace interrupt)
		dc.l	ErrorTrap			; IRQ level 7 (32)
		dc.l	ErrorTrap			; TRAP #00 exception
		dc.l	ErrorTrap			; TRAP #01 exception
		dc.l	ErrorTrap			; TRAP #02 exception
		dc.l	ErrorTrap			; TRAP #03 exception (36)
		dc.l	ErrorTrap			; TRAP #04 exception
		dc.l	ErrorTrap			; TRAP #05 exception
		dc.l	ErrorTrap			; TRAP #06 exception
		dc.l	ErrorTrap			; TRAP #07 exception (40)
		dc.l	ErrorTrap			; TRAP #08 exception
		dc.l	ErrorTrap			; TRAP #09 exception
		dc.l	ErrorTrap			; TRAP #10 exception
		dc.l	ErrorTrap			; TRAP #11 exception (44)
		dc.l	ErrorTrap			; TRAP #12 exception
		dc.l	ErrorTrap			; TRAP #13 exception
		dc.l	ErrorTrap			; TRAP #14 exception
		dc.l	ErrorTrap			; TRAP #15 exception (48)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
		dc.l	ErrorTrap			; Unused (reserved)
MEGADRIVE:	dc.b	"SEGA MEGA DRIVE " ; Hardware system ID (Console name)
Date:			dc.b '(C)NTK 2022.SEP ' ; Release date
Title_Local:	dc.b 'StH: Isle of Magnetic Artifacts                 ' ; Domestic name
Title_Int:		dc.b 'StH: Isle of Magnetic Artifacts                 ' ; International name
Serial:		dc.b	"GM 00004049-01" ; Serial/version number (Rev non-0)
Checksum:	dc.w	$0
IOSupport:	dc.b	"J               " ; I/O support
RomStartLoc:dc.l	StartOfRom		; Start address of ROM
RomEndLoc:	dc.l	EndOfRom-1		; End address of ROM
RamStartLoc:dc.l	v_128x128		; Start address of RAM
RamEndLoc:	dc.l	$FFFFFF			; End address of RAM
SRAMSupport:
	if EnableSRAM=1
		dc.b	$52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
	else
		dc.l	$20202020
	endc
		dc.l	$20202020		; SRAM start ($200001)
		dc.l	$20202020		; SRAM end ($20xxxx)
Notes:		dc.b	"                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
Region:		dc.b	"JUE             " ; Region (Country code)
EndOfHeader:

; ===========================================================================

		include	"Includes/GPGX Detection.asm"
; ===========================================================================

EntryPoint:
		tst.l	(z80_port_1_control).l ; test port A & B control registers
		bne.s	PortA_Ok
		tst.w	(z80_expansion_control).l ; test port C control register

PortA_Ok:
		bne.s	SkipSetup ; Skip the VDP and Z80 setup code if port A, B or C is ok...?
		lea		SetupValues(pc),a5	; Load setup values array address.
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version (from $A10001)
		andi.b	#$F,d0
		beq.s	SkipSecurity	; If the console has no TMSS, skip the security stuff.
		move.l	MEGADRIVE.w,$2F00(a1) ; move "SEGA" to TMSS register ($A14000)

SkipSecurity:
		move.w	(a4),d0	; clear write-pending flag in VDP to prevent issues if the 68k has been reset in the middle of writing a command long word to the VDP.
		moveq	#0,d0	; clear d0
		movea.l	d0,a6	; clear a6
		move.l	a6,usp	; set usp to $0

		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf		d1,VDPInitLoop

		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the VRAM
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch

		moveq	#endinit-initz80-1,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf		d2,Z80InitLoop

		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)	; clear 4 bytes of RAM
		dbf		d6,ClrRAMLoop	; repeat until the entire RAM is clear
		move.l	(a5)+,(a4)	; set VDP display mode and increment mode
		move.l	(a5)+,(a4)	; set VDP to CRAM write

		moveq	#$1F,d3	; set repeat times
ClrCRAMLoop:
		move.l	d0,(a3)	; clear 2 palettes
		dbf		d3,ClrCRAMLoop	; repeat until the entire CRAM is clear
		move.l	(a5)+,(a4)	; set VDP to VSRAM write

		moveq	#$13,d4
ClrVSRAMLoop:
		move.l	d0,(a3)	; clear 4 bytes of VSRAM.
		dbf		d4,ClrVSRAMLoop	; repeat until the entire VSRAM is clear
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf		d5,PSGInitLoop	; repeat for other channels
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear all registers
		disable_ints

SkipSetup:
		bra.s	GameProgram	; begin game

; ===========================================================================
SetupValues:
		dc.w	$8000		; VDP register start number
		dc.w	$3FFF		; size of RAM/4
		dc.w	$100		; VDP register diff

		dc.l	z80_ram		; start	of Z80 RAM
		dc.l	z80_bus_request	; Z80 bus request
		dc.l	z80_reset		; Z80 reset
		dc.l	vdp_data_port	; VDP data
		dc.l	vdp_control_port	; VDP control

		dc.b	4			; VDP $80 - 8-colour mode
		dc.b	$14		; VDP $81 - Megadrive mode, DMA enable
		dc.b	($C000>>10)	; VDP $82 - foreground nametable address
		dc.b	($F000>>10)	; VDP $83 - window nametable address
		dc.b	($E000>>13)	; VDP $84 - background nametable address
		dc.b	($D800>>9)		; VDP $85 - sprite table address
		dc.b	0			; VDP $86 - unused
		dc.b	0			; VDP $87 - background colour
		dc.b	0			; VDP $88 - unused
		dc.b	0			; VDP $89 - unused
		dc.b	255		; VDP $8A - HBlank register
		dc.b	0			; VDP $8B - full screen scroll
		dc.b	$81		; VDP $8C - 40 cell display
		dc.b	($DC00>>10)	; VDP $8D - hscroll table address
		dc.b	0			; VDP $8E - unused
		dc.b	1			; VDP $8F - VDP increment
		dc.b	%00010001	; VDP $90 - 64 cell hscroll size
		dc.b	0			; VDP $91 - window h position
		dc.b	0			; VDP $92 - window v position
		dc.w	$FFFF		; VDP $93/94 - DMA length
		dc.w	0			; VDP $95/96 - DMA source
		dc.b	$80		; VDP $97 - DMA fill VRAM
		dc.l	$40000080		; VRAM address 0

initz80	z80prog 0
		di
		im	1
		ld	hl,YM_Buffer1			; we need to clear from YM_Buffer1
		ld	de,(YM_BufferEnd-YM_Buffer1)/8	; to end of Z80 RAM, setting it to 0FFh

.loop
		ld	a,0FFh				; load 0FFh to a
		rept 8
			ld	(hl),a			; save a to address
			inc	hl			; go to next address
		endr

		dec	de				; decrease loop counter
		ld	a,d				; load d to a
		zor	e				; check if both d and e are 0
		jr	nz, .loop			; if no, clear more memoty
.pc		jr	.pc				; trap CPU execution
	z80prog
		even
endinit
		dc.w	$8104		; VDP display mode
		dc.w	$8F02		; VDP increment
		dc.l	$C0000000		; CRAM write mode
		dc.l	$40000010		; VSRAM address 0

		dc.b	$9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,($A1000D).l
		beq.s	@check
		cmpi.l	#'init',(v_init).w ; has checksum routine already run?
		beq.w	GameInit	; if yes, branch

	@check:
		lea		(v_systemstack).w,a6
		moveq	#0,d7
		move.w	#$7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf		d6,@clearRAM			; clear RAM ($FE00-$FFFF)

		move.l	#EndOfHeader,v_csum_addr.w	; load end of header to checksum check
		clr.w	v_csum_value.w			; initial value of 0
		move.b	(z80_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w		; get region setting
		bsr.w	DetectGPGX
		move.b	d0,(f_gpgx).w
;		illegal
		move.l	#'init',(v_init).w		; set flag so checksum won't run again

GameInit:	
		lea		(v_128x128).l,a6
		moveq	#0,d7
		move.w	#(v_systemstack-v_128x128)/4-1,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf		d6,@clearRAM	; clear RAM ($0000-$FDFF)
		move.w	#$4EF9,VBlankRAM.w
		move.l	#VBlank,VBlankRout.w
		move.w	#$4EF9,HBlankRAM.w
		move.l	#NullBlank,HBlankRout.w
		jsr		(InitDMAQueue).l				
		bsr.w	VDPSetupGame
		jsr		LoadDualPCM
		bsr.w	JoypadInit			
		move.b	#id_Sega,(v_gamemode).w ; set Game Mode to Sega Screen

MainGameLoop:
		move.b	(v_gamemode).w,d0 ; load Game Mode
		andi.w	#$7C,d0	; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		movea.l	GameModeArray(pc,d0.w),a0 ; jump to apt location in ROM
		jsr		(a0)
		bra.s	MainGameLoop	; loop indefinitely

NullBlank:	rte
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:
ptr_GM_Sega:		dc.l	GM_Sega		; Sega Screen ($00)
ptr_GM_Title:		dc.l	GM_Title	; Title	Screen ($04)
ptr_GM_Demo:		dc.l	GM_Level	; Demo Mode ($08)
ptr_GM_Level:		dc.l	GM_Level	; Normal Level ($0C)
ptr_GM_Special:		dc.l	GM_Special	; Special Stage	($10)
ptr_GM_Cont:		dc.l	GM_Continue	; Continue Screen ($14)
ptr_GM_Ending:		dc.l	GM_Ending	; End of game sequence ($18)
ptr_GM_Credits:		dc.l	GM_Credits	; Credits ($1C)
ptr_GM_LevelSelect:	dc.l	GM_LevelSelect
ptr_GM_SoundTest:	dc.l	GM_SoundTest
	if DemoMode=1
ptr_GM_EODSplash:	dc.l	GM_EndOfDemo
	endc
; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:
		movem.l	d0-a6,-(sp)
		tst.b	(v_vbla_routine).w
		beq.w	VBla_00
		move.w	(vdp_control_port).l,d0
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_dup).w,(vdp_data_port).l ; send screen y-axis pos. to VSRAM
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf		d0,@waitPAL ; wait here in a loop doing nothing for a while...

	@notPAL:
		move.b	(v_vbla_routine).w,d0
		move.b	#0,(v_vbla_routine).w
		move.w	#1,(f_hbla_pal).w
		andi.w	#$3E,d0
		move.w	VBla_Index(pc,d0.w),d0
		jsr		VBla_Index(pc,d0.w)

VBla_Music:
		jsr		UpdateAMPS

VBla_Exit:
		addq.l	#1,(v_vbla_count).w
		movem.l	(sp)+,d0-a6

	@done:
		rte
; ===========================================================================
VBla_Index:
		dc.w	VBla_00-VBla_Index, VBla_02-VBla_Index
		dc.w	VBla_04-VBla_Index, VBla_06-VBla_Index
		dc.w	VBla_08-VBla_Index, VBla_0A-VBla_Index
		dc.w	VBla_0C-VBla_Index, VBla_0E-VBla_Index
		dc.w	VBla_10-VBla_Index, VBla_12-VBla_Index
		dc.w	VBla_14-VBla_Index, VBla_16-VBla_Index
		dc.w	VBla_0C-VBla_Index, VBla_18-VBla_Index
; ===========================================================================

VBla_00:
		cmpi.b	#$80+id_Level,(v_gamemode).w
		beq.s	@islevel
		cmpi.b	#id_Level,(v_gamemode).w ; is game on a level?
		bne.w	VBla_Music	; if not, branch

	@islevel:
		tst.b	(f_water).w ; is level LZ ?
		beq.w	VBla_Music	; if not, branch

		move.w	(vdp_control_port).l,d0
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf		d0,@waitPAL

	@notPAL:
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_dup).w,(vdp_data_port).l ; send screen y-axis pos. to VSRAM
		move.l	#NullBlank,(HBlankRout).w
		clr.b	(f_wtr_state).w
		clr.b	(f_bg_state).w
		tst.b	(f_background).w
		beq.w	@skipbg
		move.w	(v_bgheight).w,d0
		sub.w	(v_bg2scrposy_dup).w,d0
		bcc.s	@isbelow2
		tst.w	d0
		bpl.s	@isbelow2	; if bg is below top of screen, branch

		move.b	#223,(v_hbla_line).w
		move.b	#1,(f_bg_state).w ; screen is all underwater

	@isbelow2:
		cmpi.w	#223,d0		; is bg within 223 pixels of top of screen?
		bcs.s	@isvisible2	; if yes, branch
		move.w	#223,d0

	@isvisible2:
		move.b	d0,(v_hbla_line).w ; set water surface as on-screen

	@skipbg:
		tst.b	(f_water).w
		beq.w	@skip2
		moveq	#0,d1
		move.w	(v_waterpos1).w,d0
		sub.w	(v_screenposy).w,d0
		bcc.s	@isbelow
		tst.w	d0
		bpl.s	@isbelow	; if water is below top of screen, branch

		move.b	#223,(v_water_line).w
		move.b	#1,(f_wtr_state).w ; screen is all underwater
		writeCRAM	v_pal_water,$80,0
		bra.s	@waterbelow

	@isbelow:
		cmpi.w	#223,d0		; is water within 223 pixels of top of screen?
		bcs.s	@isvisible	; if yes, branch
		move.w	#223,d0
		bra.s	@skip

	@isvisible:
		tst.b	(f_background).w
		beq.s	@skip
		tst.b	(f_bg_state).w
		bne.s	@skip
		move.b	(v_hbla_line).w,d1
		sub.w	d1,d0
	@skip:
		move.b	d0,(v_water_line).w ; set water surface as on-screen

	@skip2:
		writeCRAM	v_pal_dry,$80,0
		tst.b	(f_water).w
		beq.s	@waterbelow
		tst.b	(f_background).w
		beq.w	@nobg
		move.w	(v_hbla_hreg).w,(a5)
		tst.b	(f_bg_state).w
		beq.s	@waterbg

	@nobg:
		move.l	#HBlank_Water,(HBlankRout).w
		move.w	(v_water_hreg).w,(a5)
		bra.s	@waterbelow

	@waterbg:
		cmpi.b	#223,(v_hbla_line).w
		bhs.s	@waterbelow
		move.l	#HBlank,(HBlankRout).w

	@waterbelow:
		tst.b	(f_bg_state).w
		bne.s	@bgabove

	@normalbg:
		move.w	#$8400+(vram_bg>>13),(a5) ; set background nametable address
		bra.s	@bgbelow

	@bgabove:
		move.w	#$8400+(vram_bg2>>13),(a5) ; set background nametable address
		move.l	#$40020010,(a5)
		move.w	(v_bg2scrposy_dup).w,-4(a5) ; send bg2 screen y-axis pos. to VSRAM

	@bgbelow:
		jsr		UpdateAMPS
		addq.l	#1,(v_vbla_count).w
		movem.l	(sp)+,d0-a6

	@loop:
		cmpi.b	#$E4,($C00008).l
		bhi.s	@loop
		tst.b	(f_bg_state).w
		bne.s	@water
		tst.b	(f_background).w
		beq.w	@water
		move.w	(v_water_hreg).w,($C00004).l
		rte

	@water:
		move.w	#$8ADF,($C00004).l
		rte
; ===========================================================================

VBla_02:
		bsr.w	VBla_06

VBla_14:
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts
; ===========================================================================

VBla_04:
		bsr.w	VBla_06
		jsr		ProcessDMAQueue
		cmpi.b	#id_Title,(v_gamemode).w
		beq.s	@notlevsel
		jsr		ProcessPlaneRender
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,(v_screenposx_dup).w
		movem.l	(v_fg_scroll_flags).w,d0-d1
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w
	@notlevsel:
		jsr		LoadTilesAsYouMove_BGOnly
		bsr.w	sub_1642
Count_Title:
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts
; ===========================================================================

VBla_06:
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w ; is water above top of screen?
		bne.s	@waterabove	; if yes, branch
		writeCRAM	v_pal_dry,$80,0
		bra.s	@waterbelow

	@waterabove:
		writeCRAM	v_pal_water,$80,0

	@waterbelow:
		tst.b	(f_bg_state).w
		bne.s	@bgabove
		move.w	#$8400+(vram_bg>>13),(a5) ; set background nametable address
		bra.s	@bgbelow

	@bgabove:
		move.w	#$8400+(vram_bg2>>13),(a5) ; set background nametable address
		move.l	#$40020010,(a5)
		move.w	(v_bg2scrposy_dup).w,-4(a5) ; send bg2 screen y-axis pos. to VSRAM

	@bgbelow:
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		rts
; ===========================================================================

VBla_10:
		cmpi.b	#id_Special,(v_gamemode).w ; is game on special stage?
		beq.w	VBla_0A		; if yes, branch

VBla_08:
		bsr.w	ReadJoypads
		move.l	#NullBlank,(HBlankRout).w
		clr.b	(f_wtr_state).w
		clr.b	(f_bg_state).w
		tst.b	(f_background).w
		beq.w	@skipbg
		move.w	(v_bgheight).w,d0
		sub.w	(v_bg2scrposy_dup).w,d0
		bcc.s	@isbelow2
		tst.w	d0
		bpl.s	@isbelow2	; if bg is below top of screen, branch

		move.b	#223,(v_hbla_line).w
		move.b	#1,(f_bg_state).w ; screen is all underwater

	@isbelow2:
		cmpi.w	#223,d0		; is bg within 223 pixels of top of screen?
		bcs.s	@isvisible2	; if yes, branch
		move.w	#223,d0

	@isvisible2:
		move.b	d0,(v_hbla_line).w ; set water surface as on-screen

	@skipbg:
		tst.b	(f_water).w
		beq.w	@skip2
		moveq	#0,d1
		move.w	(v_waterpos1).w,d0
		sub.w	(v_screenposy).w,d0
		bcc.s	@isbelow
		tst.w	d0
		bpl.s	@isbelow	; if water is below top of screen, branch

		move.b	#223,(v_water_line).w
		move.b	#1,(f_wtr_state).w ; screen is all underwater
		writeCRAM	v_pal_water,$80,0
		bra.s	@waterbelow

	@isbelow:
		cmpi.w	#223,d0		; is water within 223 pixels of top of screen?
		bcs.s	@isvisible	; if yes, branch
		move.w	#223,d0
		bra.s	@skip

	@isvisible:
		tst.b	(f_background).w
		beq.s	@skip
		tst.b	(f_bg_state).w
		bne.s	@skip
		move.b	(v_hbla_line).w,d1
		sub.w	d1,d0
	@skip:
		move.b	d0,(v_water_line).w ; set water surface as on-screen

	@skip2:
		writeCRAM	v_pal_dry,$80,0
		tst.b	(f_water).w
		beq.s	@waterbelow
		tst.b	(f_background).w
		beq.w	@nobg
		move.w	(v_hbla_hreg).w,(a5)
		tst.b	(f_bg_state).w
		beq.s	@waterbg

	@nobg:
		move.l	#HBlank_Water,(HBlankRout).w
		move.w	(v_water_hreg).w,(a5)
		bra.s	@waterbelow

	@waterbg:
		cmpi.b	#223,(v_hbla_line).w
		bhs.s	@waterbelow
		move.l	#HBlank,(HBlankRout).w

	@waterbelow:
		tst.b	(f_bg_state).w
		bne.s	@bgabove

	@normalbg:
		move.w	#$8400+(vram_bg>>13),(a5) ; set background nametable address
		bra.s	@bgbelow

	@bgabove:
		move.w	#$8400+(vram_bg2>>13),(a5) ; set background nametable address
		move.l	#$40020010,(a5)
		move.w	(v_bg2scrposy_dup).w,-4(a5) ; send bg2 screen y-axis pos. to VSRAM

	@bgbelow:
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		jsr		ProcessDMAQueue
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,(v_screenposx_dup).w
		movem.l	(v_fg_scroll_flags).w,d0-d1
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:
		jsr		LoadTilesAsYouMove
		jsr		(AnimateLevelGfx).l
		jsr		(HUD_Update).l
		bsr.w	ProcessDPLC2
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	@end		; if not, branch
		subq.w	#1,(v_demolength).w ; subtract 1 from time left

	@end:
		jsr		UpdateAMPS
		addq.l	#1,(v_vbla_count).w
		addq.l	#4,sp
		movem.l	(sp)+,d0-a6

	@loop:
		cmpi.b	#$E4,($C00008).l
		bhi.s	@loop
		tst.b	(f_bg_state).w
		bne.s	@water
		tst.b	(f_background).w
		beq.w	@water
		move.w	(v_water_hreg).w,($C00004).l
		rte

	@water:
		move.w	#$8ADF,($C00004).l
		rte

; End of function Demo_Time

; ===========================================================================

VBla_0A:
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		bsr.w	PalCycle_SS
		jsr		ProcessDMAQueue
		cmpi.b	#96,(v_hbla_line).w
		bcc.s	@update
		bra.w	@end

	@update:
		jsr		SS_LoadWalls
		tst.w	(v_demolength).w	; is there time left on the demo?
		beq.w	@end	; if not, return
		subq.w	#1,(v_demolength).w	; subtract 1 from time left in demo

	@end:
		rts
; ===========================================================================

VBla_0C:
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		move.w	#$8400+(vram_bg>>13),(a5) ; set background nametable address
		move.l	#NullBlank,(HBlankRout).w
		move.w	#$8ADF,(a5)
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		jsr		ProcessDMAQueue
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,(v_screenposx_dup).w
		movem.l	(v_fg_scroll_flags).w,d0-d1
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w
		jsr		LoadTilesAsYouMove
		jsr		(AnimateLevelGfx).l
		jsr		(HUD_Update).l
		jsr		sub_1642
		rts
; ===========================================================================

VBla_0E:
		bsr.w	VBla_06
		addq.b	#1,(v_pfade_size+1).w
		move.b	#$E,(v_vbla_routine).w
		rts
; ===========================================================================

VBla_12:
		bsr.w	VBla_06
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	sub_1642
; ===========================================================================

VBla_16:
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		jsr		ProcessDMAQueue
		cmpi.b	#96,(v_hbla_line).w
		bcc.s	@update
		bra.w	@end

	@update:
		jsr		SS_LoadWalls
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts
VBla_18:
		bsr.w	ReadJoypads
		jsr		LoadTilesAsYouMove
		jsr		(AnimateLevelGfx).l
		jsr		(HUD_Update).l
		jsr		ProcessDMAQueue
		jmp		ProcessDPLC

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HBlank:	; PalToCRAM
	    move.l	#$40020010,($C00004).l
	    move.w	(v_bg2scrposy_dupprev).w,($C00000).l ;write to VSRAM
		rept	$60
		nop
		endr
		move.w	#$8400+(vram_bg2>>13),($C00004).l ; set background nametable address
		move.w	#$8ADF,($C00004).l	; Reset HInt timing
		move.l	#HBlank_Water,(HBlankRout).w
		rte


HBlank_Water:
		movem.l	a0-a1,-(sp)
		lea	($C00000).l,a1
		lea	(v_pal_water).w,a0 ; load	pallet from RAM
		move.l	#$C0000000,4(a1) ; set VDP to CRAM write
		rept	$20
		move.l	(a0)+,(a1)	; move pallet to CRAM
		endr
		movem.l	(sp)+,a0-a1
	@lowwater:
		rte

; ===========================================================================

loc_119E:
		clr.b	(f_wtr_state+1).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
		jsr		UpdateAMPS
		movem.l	(sp)+,d0-a6
		rte
; End of function HBlank

; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (expansion/extra)
		rts
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea		(v_jpadhold1).w,a0 ; address where joypad states are written
		lea		($A10003).l,a1	; first	joypad port
		bsr.s	@read		; do the first joypad
		addq.w	#2,a1		; do the second	joypad

	@read:
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea		(vdp_control_port).l,a0
		lea		(vdp_data_port).l,a1
		lea		(VDPSetupArray).l,a2
		moveq	#$12,d7

	@setreg:
		move.w	(a2)+,(a0)
		dbf		d7,@setreg	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8A00+223,(v_hbla_hreg).w	; H-INT every 224th scanline
		moveq	#0,d0
		move.l	#$C0000000,(vdp_control_port).l ; set VDP to CRAM write
		move.w	#$3F,d7

	@clrCRAM:
		move.w	d0,(a1)
		dbf		d7,@clrCRAM	; clear	the CRAM

		clr.l	(v_scrposy_dup).w
		clr.w	(v_scrposx_dup).w
		move.l	d1,-(sp)
		fillVRAM	0,$FFFF,0

	@waitforDMA:
		move.w	(a5),d1
		btst	#1,d1		; is DMA (fillVRAM) still running?
		bne.s	@waitforDMA	; if yes, branch

		move.w	#$8F02,(a5)	; set VDP increment size
		move.l	(sp)+,d1
		rts
; End of function VDPSetupGame

; ===========================================================================

VDPSetupArray:
		dc.w	$8004		; 8-colour mode
		dc.w	$8134		; enable V.interrupts, enable DMA
		dc.w	$8200+(vram_fg>>10) ; set foreground nametable address
		dc.w	$8300+($A000>>10)	; set window nametable address
		dc.w	$8400+(vram_bg>>13) ; set background nametable address
		dc.w	$8500+(vram_sprites>>9) ; set sprite table address
		dc.w	$8600		; unused
		dc.w	$8700		; set background colour (palette entry 0)
		dc.w	$8800		; unused
		dc.w	$8900		; unused
		dc.w	$8A00		; default H.interrupt register
		dc.w	$8B00		; full-screen vertical scrolling
		dc.w	$8C81		; 40-cell display mode
		dc.w	$8D00+(vram_hscroll>>10) ; set background hscroll address
		dc.w	$8E00		; unused
		dc.w	$8F02		; set VDP increment size
		dc.w	$9001		; 64-cell hscroll size
		dc.w	$9100		; window horizontal position
		dc.w	$9200		; window vertical position

; ===========================================================================

		include	"Includes/PlaneRender.asm"

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		fillVRAM	0,$FFF,vram_fg ; clear foreground namespace

	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		fillVRAM	0,$FFF,vram_bg ; clear background namespace

	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		clr.l	(v_scrposy_dup).w
		clr.w	(v_scrposx_dup).w

		lea	(v_spritetablebuffer).w,a1
		moveq	#0,d0
		move.w	#($280/4)-1,d1

	@clearsprites:
		move.l	d0,(a1)+
		dbf		d1,@clearsprites ; clear sprite table (in RAM)

		lea		(v_hscrolltablebuffer).w,a1
		moveq	#0,d0
		move.w	#($400/4)-1,d1

	@clearhscroll:
		move.l	d0,(a1)+
		dbf		d1,@clearhscroll ; clear hscroll table (in RAM)
		rts
; End of function ClearScreen

; ===========================================================================
		include	"Includes/PauseGame.asm"

; ---------------------------------------------------------------------------
; Subroutine to	copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TilemapToVRAM:
		lea		(vdp_data_port).l,a6
		move.l	#$800000,d4

	Tilemap_Line:
		move.l	d0,4(a6)	; move d0 to VDP_control_port
		move.w	d1,d3

	Tilemap_Cell:
		move.w	(a1)+,(a6)	; write value to namespace
		dbf		d3,Tilemap_Cell	; next tile
		add.l	d4,d0		; goto next line
		dbf		d2,Tilemap_Line	; next line
		rts
; End of function TilemapToVRAM

		include	"Includes/1BPP Art Loader.asm"
		include	"Includes/UltraDMAQueue.asm"
		include	"Includes/Decompression/Nemesis.asm"
		include	"Includes/Decompression/Comper.asm"
		include	"Includes/Decompression/Enigma.asm"
		include	"Includes/Decompression/Kosinski.asm"

; ---------------------------------------------------------------------------
; Subroutine to load pattern load cues (aka to queue pattern load requests)
; ---------------------------------------------------------------------------

; ARGUMENTS
; d0 = index of PLC list
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; LoadPLC:
AddPLC:
		movem.l	a1-a2,-(sp)
		lea		(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea		(a1,d0.w),a1		; jump to relevant PLC
		lea		(v_plc_buffer).w,a2 ; PLC buffer space

	@findspace:
		tst.l	(a2)		; is space available in RAM?
		beq.s	@copytoRAM	; if yes, branch
		addq.w	#6,a2		; if not, try next space
		bra.s	@findspace
; ===========================================================================

@copytoRAM:
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf		d0,@loop	; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2 ; a1=object
		rts
; End of function AddPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; Queue pattern load requests, but clear the PLQ first

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;	  _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;	 (or if you change the size of Plc_Buffer, the limit becomes (Plc_Buffer_Only_End-Plc_Buffer)/6)

; LoadPLC2:
NewPLC:
		movem.l	a1-a2,-(sp)
		lea		(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea		(a1,d0.w),a1	; jump to relevant PLC
		bsr.s	ClearPLC	; erase any data in PLC buffer space
		lea		(v_plc_buffer).w,a2
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip		; if it's negative, skip the next loop

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf		d0,@loop		; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2
		rts
; End of function NewPLC

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; ---------------------------------------------------------------------------
; Subroutine to	clear the pattern load cues
; ---------------------------------------------------------------------------

; Clear the pattern load queue ($FFF680 - $FFF700)


ClearPLC:
		lea		(v_plc_buffer).w,a2 ; PLC buffer space in RAM
		moveq	#$1F,d0	; bytesToLcnt(v_plc_buffer_end-v_plc_buffer)

	@loop:
		clr.l	(a2)+
		dbf		d0,@loop
		rts
; End of function ClearPLC

; ---------------------------------------------------------------------------
; Subroutine to	use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC:
		tst.l	(v_plc_buffer).w
		beq.s	Rplc_Exit
		tst.w	(f_plc_execute).w
		bne.s	Rplc_Exit
		movea.l	(v_plc_buffer).w,a0
		lea		(NemPCD_WriteRowToVDP).l,a3
		lea		(v_ngfx_buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_160E
		adda.w	#$A,a3

loc_160E:
		andi.w	#$7FFF,d2
		bsr.w	NemDec_BuildCodeTable
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,(v_ptrnemcode+4).w
		move.l	d0,(v_ptrnemcode+8).w
		move.l	d0,(v_ptrnemcode+$C).w
		move.l	d5,(v_ptrnemcode+$10).w
		move.l	d6,(v_ptrnemcode+$14).w
		move.w	d2,(f_plc_execute).w

Rplc_Exit:
		rts
; End of function RunPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1642:
		tst.w	(f_plc_execute).w
		beq.w	locret_16DA
		move.w	#9,(f_plc_execute+2).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$120,(v_plc_buffer+4).w
		bra.s	loc_1676
; End of function sub_1642


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

ProcessDPLC:
		tst.w	(f_plc_execute).w
		beq.w	locret_16DA	; rts
		move.w	#6,(f_plc_execute+2).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$C0,(v_plc_buffer+4).w
		bra.s	loc_1676

; sub_165E:
ProcessDPLC2:
		tst.w	(f_plc_execute).w
		beq.s	locret_16DA
		move.w	#3,(f_plc_execute+2).w
		moveq	#0,d0
		move.w	(v_plc_buffer+4).w,d0
		addi.w	#$60,(v_plc_buffer+4).w

loc_1676:
		lea		(vdp_control_port).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(v_plc_buffer).w,a0
		movea.l	(v_ptrnemcode).w,a3
		move.l	(v_ptrnemcode+4).w,d0
		move.l	(v_ptrnemcode+8).w,d1
		move.l	(v_ptrnemcode+$C).w,d2
		move.l	(v_ptrnemcode+$10).w,d5
		move.l	(v_ptrnemcode+$14).w,d6
		lea		(v_ngfx_buffer).w,a1

loc_16AA:
		movea.w	#8,a5
		bsr.w	NemPCD_NewRow
		subq.w	#1,(f_plc_execute).w
		beq.s	loc_16DC
		subq.w	#1,(f_plc_execute+2).w
		bne.s	loc_16AA
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,(v_ptrnemcode+4).w
		move.l	d1,(v_ptrnemcode+8).w
		move.l	d2,(v_ptrnemcode+$C).w
		move.l	d5,(v_ptrnemcode+$10).w
		move.l	d6,(v_ptrnemcode+$14).w

locret_16DA:
		rts
; ===========================================================================

loc_16DC:
		lea		(v_plc_buffer).w,a0
		moveq	#$15,d0

loc_16E2:
		move.l	6(a0),(a0)+
		dbf		d0,loc_16E2
		rts
; End of function ProcessDPLC2

; ---------------------------------------------------------------------------
; Subroutine to	execute	the pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


QuickPLC:
		lea		(ArtLoadCues).l,a1 ; load the PLC index
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea		(a1,d0.w),a1
		move.w	(a1)+,d1	; get length of PLC

	Qplc_Loop:
		movea.l	(a1)+,a0	; get art pointer
		moveq	#0,d0
		move.w	(a1)+,d0	; get VRAM address
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(vdp_control_port).l ; converted VRAM address to VDP format
		bsr.w	NemDec		; decompress
		dbf		d1,Qplc_Loop	; repeat for length of PLC
		rts
; End of function QuickPLC

		include	"Includes/PaletteCycle.asm"

Pal_LZCyc2:	incbin	"palette/Cycles/Cycle - LZ Conveyor Belt.bin"
Pal_SLZCyc:	incbin	"palette/Cycles/Cycle - SLZ.bin"
Pal_SYZCyc1:	incbin	"palette/Cycles/Cycle - SYZ1.bin"
Pal_SYZCyc2:	incbin	"palette/Cycles/Cycle - SYZ2.bin"

		include	"Includes/SBZ Palette Scripts.asm"

Pal_SBZCyc1:	incbin	"palette/Cycles/Cycle - SBZ 1.bin"
Pal_SBZCyc2:	incbin	"palette/Cycles/Cycle - SBZ 2.bin"
Pal_SBZCyc3:	incbin	"palette/Cycles/Cycle - SBZ 3.bin"
Pal_SBZCyc4:	incbin	"palette/Cycles/Cycle - SBZ 4.bin"
Pal_SBZCyc5:	incbin	"palette/Cycles/Cycle - SBZ 5.bin"
Pal_SBZCyc6:	incbin	"palette/Cycles/Cycle - SBZ 6.bin"
Pal_SBZCyc7:	incbin	"palette/Cycles/Cycle - SBZ 7.bin"
Pal_SBZCyc8:	incbin	"palette/Cycles/Cycle - SBZ 8.bin"
Pal_SBZCyc9:	incbin	"palette/Cycles/Cycle - SBZ 9.bin"
Pal_SBZCyc10:	incbin	"palette/Cycles/Cycle - SBZ 10.bin"

Pal_SuperSonic:		incbin	"palette/Cycles/Super/Super Sonic.bin"
Pal_SuperTails:		incbin	"palette/Cycles/Super/Super Tails.bin"
Pal_SuperKnuckles:	incbin	"palette/Cycles/Super/Super Knuckles.bin"
; Kyuko won't be turning Super.
;Pal_SuperMetal:	incbin	"palette/Cycles/Super/Super Metal.bin"
Pal_SuperMighty:	incbin	"palette/Cycles/Super/Super Mighty.bin"
;Pal_SuperAmy:		incbin	"palette/Cycles/Super/Super Amy.bin"
Pal_SuperLegacy:	incbin	"palette/Cycles/Super/Super Legacy.bin"
; ---------------------------------------------------------------------------
; Subroutine to	fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$3F,(v_pfade_start).w

PalFadeIn_Alt:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	(v_pfade_size).w,d0

Pal_ToBlack:
		move.w	d1,(a0)+
		dbf		d0,Pal_ToBlack	; fill pallet with $000	(black)
		moveq	#$0E,d4					; MJ: prepare maximum colour check
		moveq	#$00,d6					; MJ: clear d6

loc_1DCE:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitforVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		loc_1DCE				; MJ: if null, delay a frame
		bsr.s	Pal_FadeIn
		subq.b	#$02,d4					; MJ: decrease colour check
		bne		loc_1DCE				; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w			; MJ: wait for V-blank again (so colours transfer)
		bra		WaitforVBla				; MJ: ''

; End of function Pal_FadeTo

; ---------------------------------------------------------------------------
; Pallet fade-in subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:				; XREF: Pal_FadeTo
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		lea		(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_1DFA:
		bsr.s	Pal_AddColor
		dbf		d0,loc_1DFA
;		cmpi.b	#id_LZ,(v_zone).w	; I don't think this is necessary...
;		bne.s	locret_1E24
		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_1E1E:
		bsr.s	Pal_AddColor
		dbf		d0,loc_1E1E

locret_1E24:
		rts
; End of function Pal_FadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:				; XREF: Pal_FadeIn
		move.b	(a1),d5					; MJ: load blue
		move.w	(a1)+,d1				; MJ: load green and red
		move.b	d1,d2					; MJ: load red
		lsr.b	#$04,d1					; MJ: get only green
		andi.b	#$0E,d2					; MJ: get only red
		move.w	(a0),d3					; MJ: load current colour in buffer
		cmp.b	d5,d4					; MJ: is it time for blue to fade?
		bhi		FCI_NoBlue				; MJ: if not, branch
		addi.w	#$0200,d3				; MJ: increase blue

FCI_NoBlue:
		cmp.b	d1,d4					; MJ: is it time for green to fade?
		bhi		FCI_NoGreen				; MJ: if not, branch
		addi.b	#$20,d3					; MJ: increase green

FCI_NoGreen:
		cmp.b	d2,d4					; MJ: is it time for red to fade?
		bhi		FCI_NoRed				; MJ: if not, branch
		addq.b	#$02,d3					; MJ: increase red

FCI_NoRed:
		move.w	d3,(a0)+				; MJ: save colour
		rts

; End of function Pal_AddColor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$3F,(v_pfade_start).w
		moveq	#$07,d4					; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6

loc_1E5C:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitforVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		loc_1E5C				; MJ: if null, delay a frame
		bsr.s	FadeOut_ToBlack
		dbf		d4,loc_1E5C
		rts
; End of function Pal_FadeFrom

; ---------------------------------------------------------------------------
; Pallet fade-out subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:				; XREF: Pal_FadeFrom
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_1E82:
		bsr.s	Pal_DecColor
		dbf		d0,loc_1E82

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_1E98:
		bsr.s	Pal_DecColor
		dbf		d0,loc_1E98
		rts
; End of function Pal_FadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor:				; XREF: Pal_FadeOut
		move.w	(a0),d5					; MJ: load colour
		move.w	d5,d1					; MJ: copy to d1
		move.b	d1,d2					; MJ: load green and red
		move.b	d1,d3					; MJ: load red
		andi.w	#$0E00,d1				; MJ: get only blue
		beq		FCO_NoBlue				; MJ: if blue is finished, branch
		subi.w	#$0200,d5				; MJ: decrease blue

FCO_NoBlue:
		andi.w	#$00E0,d2				; MJ: get only green (needs to be word)
		beq		FCO_NoGreen				; MJ: if green is finished, branch
		subi.b	#$20,d5					; MJ: decrease green

FCO_NoGreen:
		andi.b	#$0E,d3					; MJ: get only red
		beq		FCO_NoRed				; MJ: if red is finished, branch
		subq.b	#$02,d5					; MJ: decrease red

FCO_NoRed:
		move.w	d5,(a0)+				; MJ: save new colour
		rts

; End of function Pal_DecColor

; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$3F,(v_pfade_start).w
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	(v_pfade_size).w,d0

PalWhite_Loop:
		move.w	d1,(a0)+
		dbf		d0,PalWhite_Loop ; fill pallet with $000 (black)
		moveq	#$0E,d4 ; MJ: prepare maximum colour check
		moveq	#$00,d6 ; MJ: clear d6

loc_1EF4:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6 ; MJ: change delay counter
		beq		loc_1EF4 ; MJ: if null, delay a frame
		bsr.s	Pal_WhiteToBlack
		subq.b	#$02,d4 ; MJ: decrease colour check
		bne		loc_1EF4 ; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w ; MJ: wait for V-blank again (so colours transfer)
		bra		WaitForVBla ; MJ: ''
; End of function Pal_MakeWhite


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_WhiteToBlack: ; XREF: Pal_MakeWhite
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		lea		(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_1F20:
		bsr.s	Pal_DecColor2
		dbf		d0,loc_1F20
		tst.b	(f_water).w
		bne.s	locret_1F4A
		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

loc_1F44:
		bsr.s	Pal_DecColor2
		dbf		d0,loc_1F44

locret_1F4A:
		rts
; End of function Pal_WhiteToBlack


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor2: ; XREF: Pal_WhiteToBlack
		move.b	(a1),d5 ; MJ: load blue
		move.w	(a1)+,d1 ; MJ: load green and red
		move.b	d1,d2 ; MJ: load red
		lsr.b	#$04,d1 ; MJ: get only green
		andi.b	#$0E,d2 ; MJ: get only red
		move.w	(a0),d3 ; MJ: load current colour in buffer
		cmp.b	d5,d4 ; MJ: is it time for blue to fade?
		bls		FCI2_NoBlue ; MJ: if not, branch
		subi.w	#$0200,d3 ; MJ: dencrease blue

FCI2_NoBlue:
		cmp.b	d1,d4 ; MJ: is it time for green to fade?
		bls		FCI2_NoGreen ; MJ: if not, branch
		subi.b	#$20,d3 ; MJ: dencrease green

FCI2_NoGreen:
		cmp.b	d2,d4 ; MJ: is it time for red to fade?
		bls		FCI2_NoRed ; MJ: if not, branch
		subq.b	#$02,d3 ; MJ: dencrease red

FCI2_NoRed:
		move.w	d3,(a0)+ ; MJ: save colour
		rts
; End of function Pal_DecColor2

; ---------------------------------------------------------------------------
; Subroutine to make a white flash when you enter a special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut: ; XREF: SpecialStage
		move.w	#$3F,(v_pfade_start).w
		moveq	#$07,d4 ; MJ: set repeat times
		moveq	#$00,d6 ; MJ: clear d6

loc_1F86:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6 ; MJ: change delay counter
		beq		loc_1F86 ; MJ: if null, delay a frame
		bsr.s	WhiteOut_ToWhite
		dbf		d4,loc_1F86
		rts
; End of function Pal_MakeFlash


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite: ; XREF: Pal_MakeFlash
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_1FAC:
		bsr.s	WhiteOut_AddColour
		dbf		d0,loc_1FAC

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

loc_1FC2:
		bsr.s	WhiteOut_AddColour
		dbf		d0,loc_1FC2
		rts
; End of function Pal_ToWhite


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour: ; XREF: Pal_ToWhite
		move.w	(a0),d5 ; MJ: load colour
		cmpi.w	#$EEE,d5
		beq.s	FCO2_NoRed
		move.w	d5,d1 ; MJ: copy to d1
		move.b	d1,d2 ; MJ: load green and red
		move.b	d1,d3 ; MJ: load red
		andi.w	#$0E00,d1 ; MJ: get only blue
		cmpi.w	#$0E00,d1
		beq		FCO2_NoBlue ; MJ: if blue is finished, branch
		addi.w	#$0200,d5 ; MJ: increase blue

FCO2_NoBlue:
		andi.w	#$00E0,d2 ; MJ: get only green (needs to be word)
		cmpi.w	#$00E0,d2
		beq		FCO2_NoGreen ; MJ: if green is finished, branch
		addi.b	#$20,d5 ; MJ: increase green

FCO2_NoGreen:
		andi.b	#$0E,d3 ; MJ: get only red
		cmpi.b	#$0E,d3
		beq		FCO2_NoRed ; MJ: if red is finished, branch
		addq.b	#$02,d5 ; MJ: increase red

FCO2_NoRed:
		move.w	d5,(a0)+ ; MJ: save new colour
		rts
; End of function WhiteOut_AddColour

; ---------------------------------------------------------------------------
; Subroutines to load palettes

; input:
;	d0 = index number for palette
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea		(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		adda.w	#v_pal_dry_dup-v_pal_dry,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf		d7,@loop
		rts
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea		(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		move.w	(a1)+,d7	; get length of palette

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf		d7,@loop
		rts
; End of function PalLoad2

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad_Loop: ;Quick load - TIS
		move.w	(a1)+,(a2)+			  ;Copy pallete data to RAM
		dbf		d0,PalLoad_Loop			   ;Loop d0 (length)
		rts

; ===========================================================================

		include	"Includes/DynaWater.asm"

		include	"Includes/Palette Pointers.asm"
; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
; NTKyu logo
Pal_NTKLogo:		incbin	"palette/Neo Team Kyukyoku Logo.bin"
Pal_Sonic:			incbin	"palette/Sonic.bin"
; The reason Sonic's is up here -- ^ -- is because he's in the logo, too.
; Players
Pal_Tails:			incbin	"palette/Tails.bin"
Pal_Knuckles:		incbin	"palette/Knuckles.bin"
Pal_Kyuko:			incbin	"palette/Kyuko.bin"
Pal_Metal:			incbin	"palette/Metal.bin"
Pal_Mighty:			incbin	"palette/Mighty.bin"
Pal_Amy:			incbin	"palette/Amy.bin"
Pal_LegacySonic:	incbin	"palette/Legacy Sonic.bin"
; Levels
Pal_BGZ1:			incbin	"palette/Blossom Gardens Zone Act 1.bin"
Pal_BGZ2:			incbin	"palette/Blossom Gardens Zone Act 2.bin"
Pal_BGZ3:			incbin	"palette/Blossom Gardens Zone Act 3.bin"
Pal_LBGZ:			incbin	"palette/Legacy Blossom Gardens Zone.bin"
Pal_LZ:				incbin	"palette/Labyrinth Zone.bin"
Pal_MZ:				incbin	"palette/Marble Zone.bin"
Pal_SLZ:			incbin	"palette/Star Light Zone.bin"
Pal_SYZ:			incbin	"palette/Spring Yard Zone.bin"
Pal_SBZ1:			incbin	"palette/SBZ Act 1.bin"
Pal_SBZ2:			incbin	"palette/SBZ Act 2.bin"
Pal_SBZ3:			incbin	"palette/SBZ Act 3.bin"
Pal_MHZ:			incbin	"palette/Melting Heights Zone.bin"
Pal_HPZ:			incbin	"palette/Hidden Palace Zone.bin"
Pal_TMZ:			incbin	"palette/The Magnet Zone.bin"
; Bosses
Pal_BGZBoss:		incbin	"palette/Blossom Gardens Zone Boss.bin"
Pal_MHZBoss:		incbin	"palette/Melting Heights Zone Boss.bin"
; Special Stage
Pal_SpecialStage:	incbin	"palette/Special Stage.bin"
Pal_SSResult:		incbin	"palette/Special Stage Results.bin"
Pal_Continue:		incbin	"palette/Special Stage Continue Bonus.bin"
; Ending and Credits
Pal_Ending:			incbin	"palette/Ending.bin"
Pal_Credits:		incbin	"palette/Credits.bin"
; The Menu.
Pal_Menu:			incbin	"palette/Menu.bin"
Pal_Options:		incbin	"palette/Options.bin"

; ---------------------------------------------------------------------------
; Subroutine to	clear the entire object space.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClrObjRAM:
		lea		(v_objspace).w,a1
		move.w	#(v_objspace_End-v_objspace)/4-1,d1
	@clr1:
		move.l	d0,(a1)+
		dbf		d1,@clr1	; fill object space ($D000-$EFFF) with 0
		rts
; End of function ClrObjRAM

; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WaitForVBla:
		enable_ints

	@wait:
		tst.b	(v_vbla_routine).w ; has VBlank routine finished?
		bne.s	@wait		; if not, branch
		rts
; End of function WaitForVBla

		include	"Objects/Subroutines/sub RandomNumber.asm"
		include	"Objects/Subroutines/sub CalcSine.asm"
		include	"Objects/Subroutines/sub CalcSqrt.asm" ; from REV00, might be useful tho
		include	"Objects/Subroutines/sub CalcAngle.asm"
		
; ===========================================================================

; ---------------------------------------------------------------------------
; Game Modes
; ---------------------------------------------------------------------------
		include	"Modes/SegaScreen.asm"
		include	"Modes/TitleScreen.asm"
		include	"Modes/Level.asm"
		include	"Modes/SpecialStage.asm"
		include	"Modes/Continue.asm"
		include	"Modes/Ending.asm"
		include	"Modes/Credits.asm"
		include	"Modes/LevelSelect.asm"
		even


; ---------------------------------------------------------------------------
; A bunch of level shit
; ---------------------------------------------------------------------------
		include	"Includes/LevelSizeLoad & BgScrollSpeed.asm"
		include	"Includes/DeformLayers.asm"


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6886:
LoadTilesAsYouMove_BGOnly:
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
	; First, update the background
		lea		(v_bg1_scroll_flags_dup).w,a2	; Scroll block 1 scroll flags
		lea		(v_bgscreenposx_dup).w,a3	; Scroll block 1 X coordinate
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg&$2000)+((vram_bg&$C000)<<2),d2	; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock1
		lea		(v_bg2_scroll_flags_dup).w,a2	; Scroll block 2 scroll flags
		lea		(v_bg2screenposx_dup).w,a3	; Scroll block 2 X coordinate
		bsr.w	DrawBGScrollBlock2
		lea		(v_bg3_scroll_flags_dup).w,a2	; Scroll block 3 scroll flags
		lea		(v_bg3screenposx_dup).w,a3	; Scroll block 3 X coordinate
		bra.w	DrawBGScrollBlock3

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		tst.b	(f_background).w
		beq.s	@singleback
	; First, update the background
		lea		(v_bg1_scroll_flags_dup).w,a2	; Scroll block 1 scroll flags
		lea		(v_bg3screenposx_dup).w,a3	; Scroll block 1 X coordinate
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg2&$2000)+((vram_bg2&$C000)<<2),d2	; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock2

	@singleback:
		lea		(v_bg1_scroll_flags_dup).w,a2	; Scroll block 1 scroll flags
		lea		(v_bgscreenposx_dup).w,a3	; Scroll block 1 X coordinate
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg&$2000)+((vram_bg&$C000)<<2),d2	; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock1
		lea		(v_bg2_scroll_flags_dup).w,a2	; Scroll block 2 scroll flags
		lea		(v_bg2screenposx_dup).w,a3	; Scroll block 2 X coordinate
		bsr.w	DrawBGScrollBlock2
		lea		(v_bg3_scroll_flags_dup).w,a2	; Scroll block 3 scroll flags
		lea		(v_bg3screenposx_dup).w,a3	; Scroll block 3 X coordinate
		bsr.w	DrawBGScrollBlock3
	; Then, update the foreground
		lea		(v_fg_scroll_flags_dup).w,a2	; Foreground scroll flags
		lea		(v_screenposx_dup).w,a3		; Foreground X coordinate
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		move.l	#$4000+(vram_fg&$2000)+((vram_fg&$C000)<<2),d2	; VRAM thing for selecting Plane A
	; The FG's update function is inlined here
		tst.b	(a2)
		beq.s	locret_6952	; If there are no flags set, nothing needs updating
		bclr	#0,(a2)
		beq.s	loc_6908
	; Draw new tiles at the top
		moveq	#-16,d4	; Y coordinate. Note that 16 is the size of a block in pixels
		moveq	#-16,d5 ; X coordinate
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4 ; Y coordinate
		moveq	#-16,d5 ; X coordinate
		bsr.w	DrawBlocks_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
	; Draw new tiles at the bottom
		move.w	#224,d4	; Start at bottom of the screen. Since this draws from top to bottom, we don't need 224+16
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
	; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
	; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#336,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#336,d5
		bsr.w	DrawBlocks_TB

locret_6952:
		rts
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6954:
DrawBGScrollBlock1:
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
	; Draw new tiles at the top
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
	; Draw new tiles at the top
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_698E:
		bclr	#2,(a2)
		beq.s	locj_6D56
	; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

locj_6D56:
		bclr	#3,(a2)
		beq.s	locj_6D70
	; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#336,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#336,d5
		bsr.w	DrawBlocks_TB

locj_6D70:
		bclr	#4,(a2)
		beq.s	locj_6D88
	; Draw entire row at the top
		moveq	#-16,d4
		moveq	#0,d5
		bsr.w	Calc_VRAM_Pos_2
		moveq	#-16,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3

locj_6D88:
		bclr	#5,(a2)
		beq.s	DrawBG1_CheckBit6
	; Draw entire row at the bottom
		move.w	#224,d4
		moveq	#0,d5
		bsr.w	Calc_VRAM_Pos_2
		move.w	#224,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3

DrawBG1_CheckBit6:
		bclr	#6,(a2)
		beq.s	DrawBG1_CheckBit7
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	DrawBlocks_LR_2

DrawBG1_CheckBit7:
		bclr	#7,(a2)
		beq.s	locret_69F2
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$E0,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	DrawBlocks_LR_2

locret_69F2:
		rts
; End of function DrawBGScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Essentially, this draws everything that isn't scroll block 1
; sub_69F4:
DrawBGScrollBlock2:
		tst.b	(a2)
		beq.w	locj_6DF2
		cmpi.b	#id_SBZ,(v_zone).w
		beq.w	Draw_SBz
		bclr	#0,(a2)
		beq.s	locj_6DD2
	; Draw new tiles on the left
		move.w	#224/2,d4	; Draw the bottom half of the screen
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224/2,d4
		moveq	#-16,d5
		moveq	#3-1,d6		; Draw three rows... could this be a repurposed version of the above unused code?
		bsr.w	DrawBlocks_TB_2
locj_6DD2:
		bclr	#1,(a2)
		beq.s	locj_6DF2
	; Draw new tiles on the right
		move.w	#224/2,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224/2,d4
		move.w	#320,d5
		moveq	#3-1,d6
		bsr.w	DrawBlocks_TB_2
locj_6DF2:
		rts
;===============================================================================
locj_6DF4:
		dc.b	$00,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$04
		dc.b	$04,$04,$04,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$00
;===============================================================================
Draw_SBz:
		moveq	#-16,d4
		bclr	#0,(a2)
		bne.s	locj_6E28
		bclr	#1,(a2)
		beq.s	locj_6E72
		move.w	#224,d4
locj_6E28:
		lea		(locj_6DF4+1).l,a0
		move.w	(v_bgscreenposy).w,d0
		add.w	d4,d0
		andi.w	#$1F0,d0
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		lea		(locj_6FE4).l,a3
		movea.w	(a3,d0.w),a3
		beq.s	locj_6E5E
		moveq	#-16,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos
		movem.l	(sp)+,d4/d5
		bsr.w	DrawBlocks_LR
		bra.s	locj_6E72
;===============================================================================
locj_6E5E:
		moveq	#0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos_2
		movem.l	(sp)+,d4/d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3
locj_6E72:
		tst.b	(a2)
		bne.s	locj_6E78
		rts
;===============================================================================
locj_6E78:
		moveq	#-16,d4
		moveq	#-16,d5
		move.b	(a2),d0
		andi.b	#$A8,d0
		beq.s	locj_6E8C
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#320,d5
locj_6E8C:
		lea		(locj_6DF4).l,a0
		move.w	(v_bgscreenposy).w,d0
		andi.w	#$1F0,d0
		lsr.w	#4,d0
		lea		(a0,d0.w),a0
		bra.w	locj_6FEC
;===============================================================================
; locj_6EA4:
DrawBGScrollBlock3:
		tst.b	(a2)
		beq.w	locj_6EF0
		cmpi.b	#id_MZ,(v_zone).w
		beq.w	Draw_Mz
		bclr	#0,(a2)
		beq.s	locj_6ED0
	; Draw new tiles on the left
		move.w	#$40,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$40,d4
		moveq	#-16,d5
		moveq	#3-1,d6
		bsr.w	DrawBlocks_TB_2
locj_6ED0:
		bclr	#1,(a2)
		beq.s	locj_6EF0
	; Draw new tiles on the right
		move.w	#$40,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$40,d4
		move.w	#320,d5
		moveq	#3-1,d6
		bsr.w	DrawBlocks_TB_2
locj_6EF0:
		rts
locj_6EF2:
		dc.b	$00,$00,$00,$00,$00,$00,$06,$06,$04,$04,$04,$04,$04,$04,$04,$04
		dc.b	$04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
		dc.b	$02,$00
;===============================================================================
Draw_Mz:
		moveq	#-16,d4
		bclr	#0,(a2)
		bne.s	locj_6F66
		bclr	#1,(a2)
		beq.s	locj_6FAE
		move.w	#224,d4
locj_6F66:
		lea		(locj_6EF2+1).l,a0
		move.w	(v_bgscreenposy).w,d0
		subi.w	#$200,d0
		add.w	d4,d0
		andi.w	#$7F0,d0
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		movea.w	locj_6FE4(pc,d0.w),a3
		beq.s	locj_6F9A
		moveq	#-16,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos
		movem.l	(sp)+,d4/d5
		bsr.w	DrawBlocks_LR
		bra.s	locj_6FAE
;===============================================================================
locj_6F9A:
		moveq	#0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos_2
		movem.l	(sp)+,d4/d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3
locj_6FAE:
		tst.b	(a2)
		bne.s	locj_6FB4
		rts
;===============================================================================
locj_6FB4:
		moveq	#-16,d4
		moveq	#-16,d5
		move.b	(a2),d0
		andi.b	#$A8,d0
		beq.s	locj_6FC8
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#320,d5
locj_6FC8:
		lea		(locj_6EF2).l,a0
		move.w	(v_bgscreenposy).w,d0
		subi.w	#$200,d0
		andi.w	#$7F0,d0
		lsr.w	#4,d0
		lea		(a0,d0.w),a0
		bra.w	locj_6FEC
;===============================================================================
locj_6FE4:
		dc.w	v_bgscreenposx_dup, v_bgscreenposx_dup, v_bg2screenposx_dup, v_bg3screenposx_dup
locj_6FEC:
		moveq	#((224+16+16)/16)-1,d6
		move.l	#$800000,d7
locj_6FF4:
		moveq	#0,d0
		move.b	(a0)+,d0
		btst	d0,(a2)
		beq.s	locj_701C
		move.w	locj_6FE4(pc,d0.w),a3
		movem.l	d4/d5/a0,-(sp)
		movem.l	d4/d5,-(sp)
		bsr.w	GetBlockData
		movem.l	(sp)+,d4/d5
		bsr.w	Calc_VRAM_Pos
		bsr.w	DrawBlock
		movem.l	(sp)+,d4/d5/a0
locj_701C:
		addi.w	#16,d4
		dbf		d6,locj_6FF4
		clr.b	(a2)
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from left to right
; when the camera's moving up or down
; DrawTiles_LR:
DrawBlocks_LR:
		moveq	#((320+16+16)/16),d6	; Draw the entire width of the screen + two extra columns
; DrawTiles_LR_2:
DrawBlocks_LR_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1
	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1		; Two tiles ahead
		andi.b	#$7F,d1		; Wrap around row
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5		; Move X coordinate one block ahead
		dbf		d6,@loop
		rts
; End of function DrawBlocks_LR

; DrawTiles_LR_3:
DrawBlocks_LR_3:
		move.l	#$800000,d7
		move.l	d0,d1
	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData_2
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5
		dbf		d6,@loop
		rts
; End of function DrawBlocks_LR_3

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from top to bottom
; when the camera's moving left or right
; DrawTiles_TB:
DrawBlocks_TB:
		moveq	#((224+16+16)/16)-1,d6	; Draw the entire height of the screen + two extra rows
; DrawTiles_TB_2:
DrawBlocks_TB_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1
	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addi.w	#$100,d1	; Two rows ahead
		andi.w	#$FFF,d1	; Wrap around plane
		movem.l	(sp)+,d4-d5
		addi.w	#16,d4		; Move X coordinate one block ahead
		dbf		d6,@loop
		rts
; End of function DrawBlocks_TB_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Draws a block's worth of tiles
; Parameters:
; a0 = Pointer to block metadata (block index and X/Y flip)
; a1 = Pointer to block
; a5 = Pointer to VDP command port
; a6 = Pointer to VDP data port
; d0 = VRAM command to access plane
; d2 = VRAM plane A/B specifier
; d7 = Plane row delta
; DrawTiles:
DrawBlock:
		or.l	d2,d0	; OR in that plane A/B specifier to the VRAM command
		swap	d0
		btst	#3,(a0)	; Check Y-flip bit	; MJ: checking bit 3 not 4 (Flip)
		bne.s	DrawFlipY
		btst	#2,(a0)	; Check X-flip bit	; MJ: checking bit 2 not 3 (Flip)
		bne.s	DrawFlipX
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write bottom two tiles
		rts
; ===========================================================================

DrawFlipX:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4	; Invert X-flip bits of each tile
		swap	d4		; Swap the tiles around
		move.l	d4,(a6)		; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)		; Write bottom two tiles
		rts
; ===========================================================================

DrawFlipY:
		btst	#2,(a0)		; MJ: checking bit 2 not 3 (Flip)
		bne.s	DrawFlipXY
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts
; ===========================================================================

DrawFlipXY:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts
; End of function DrawBlocks

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Gets address of block at a certain coordinate
; Parameters:
; a4 = Pointer to level layout
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns:
; a0 = Address of block metadata
; a1 = Address of block
; DrawBlocks:
GetBlockData:
		add.w	(a3),d5		; MJ: load X position to d5
GetBlockData_2:
		add.w	4(a3),d4	; MJ: load Y position to d4
		lea		(v_16x16).w,a1	; MJ: load Block's location
	; Turn Y coordinate into index into level layout
		move.w	d4,d0		; MJ: copy Y position to d3
		lsr.w	#5,d0
		and.w	(Layout_row_index_mask).w,d0
		movea.w	(a4,d0.w),a1		
		; Set X coordinate in level layout
		lsr.w	#3,d5		; MJ: divide X position by 8
		move.w	d5,d0		; MJ: copy to d0
		lsr.w	#4,d0		; MJ: divide by 10 (Not 20)
;		andi.w	#$7F,d0
		moveq	#-1,d3		; MJ: prepare FFFF in d3
		clr.w	d3
		; Turn chunk ID from level layout
		move.b  (a1,d0.w),d3
		lsl.w	#7,d3		; MJ: multiply by 80
		; Turn Y coordinate into index into chunk
		andi.w	#$70,d4		; MJ: keep Y pos within 80 pixels
		; Turn X coordinate into index into chunk
		andi.w	#$E,d5		; MJ: keep X pos within 10	
		
		; Get chunk metadata
		add.w	d4,d3		; MJ: add calc'd Y pos to ror'd d3
		add.w	d5,d3		; MJ: add calc'd X pos to ror'd d3
		movea.l	d3,a0		; MJ: set address (Chunk to read)
		move.w	(a0),d3
		lea	(v_16x16).w,a1	; MJ: load Block's location
		; Turn block ID into address
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts
; End of function GetBlockData


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Produces a VRAM plane access command from coordinates
; Parameters:
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns VDP command in d0
Calc_VRAM_Pos:
		add.w	(a3),d5
Calc_VRAM_Pos_2:
		add.w	4(a3),d4
	; Floor the coordinates to the nearest pair of tiles (the size of a block).
	; Also note that this wraps the value to the size of the plane:
	; The plane is 64*8 wide, so wrap at $100, and it's 32*8 tall, so wrap at $200
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
	; Transform the adjusted coordinates into a VDP command
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#0,d0	; Highest bits of plane VRAM address
		move.w	d4,d0
		rts
; End of function Calc_VRAM_Pos

; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadBGFromStart:
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		lea		(v_bgscreenposx).w,a3
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg&$2000)+((vram_bg&$C000)<<2),d2
		bra.w	DrawChunks

LoadTilesFromStart:
		tst.b	(f_background).w
		beq.s	@singleback
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		lea		(v_bg3screenposx).w,a3
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg2&$2000)+((vram_bg2&$C000)<<2),d2
		bsr.s	DrawChunks

	@singleback:
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		lea		(v_screenposx).w,a3
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		move.l	#$4000+(vram_fg&$2000)+((vram_fg&$C000)<<2),d2
		bsr.s	DrawChunks
		lea		(v_bgscreenposx).w,a3
		move.w	(a3),d0
		lea	(Level_layout_main).w,a4	; MJ: Load address of layout BG
		addq.w	#2,a4
		move.l	#$4000+(vram_bg&$2000)+((vram_bg&$C000)<<2),d2
		cmpi.w	#(id_BGZ<<8)+3,(v_zone).w
		beq.w	Draw_GHz_Bg
		cmpi.b	#id_MZ,(v_zone).w
		beq.w	Draw_Mz_Bg
		cmpi.w	#(id_SBZ<<8)+0,(v_zone).w
		beq.w	Draw_SBz_Bg
		cmpi.b	#id_EndZ,(v_zone).w
		beq.w	Draw_GHz_Bg
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawChunks:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6

	@loop:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf		d6,@loop
		rts
; End of function DrawChunks

Draw_GHz_Bg:
		moveq	#0,d4
		moveq	#((224+16+16)/16)-1,d6
locj_7224:
		movem.l	d4-d6,-(sp)
		lea		(locj_724a),a0
		move.w	(v_bgscreenposy).w,d0
		add.w	d4,d0
		andi.w	#$F0,d0
		bsr.w	locj_72Ba
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf		d6,locj_7224
		rts
locj_724a:
		dc.b	$00,$00,$00,$00,$06,$06,$06,$04,$04,$04,$00,$00,$00,$00,$00,$00
;-------------------------------------------------------------------------------
Draw_Mz_Bg:;locj_725a:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6
locj_725E:
		movem.l	d4-d6,-(sp)
		lea		(locj_6EF2+1),a0
		move.w	(v_bgscreenposy).w,d0
		subi.w	#$200,d0
		add.w	d4,d0
		andi.w	#$7F0,d0
		bsr.w	locj_72Ba
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf		d6,locj_725E
		rts
;-------------------------------------------------------------------------------
Draw_SBz_Bg:;locj_7288:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6
locj_728C:
		movem.l	d4-d6,-(sp)
		lea		(locj_6DF4+1),a0
		move.w	(v_bgscreenposy).w,d0
		add.w	d4,d0
		andi.w	#$1F0,d0
		bsr.w	locj_72Ba
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf		d6,locj_728C
		rts
;-------------------------------------------------------------------------------
locj_72B2:
		dc.w	v_bgscreenposx, v_bgscreenposx, v_bg2screenposx, v_bg3screenposx
locj_72Ba:
		lsr.w	#4,d0
		move.b	(a0,d0.w),d0
		movea.w	locj_72B2(pc,d0.w),a3
		beq.s	locj_72da
		moveq	#-16,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos
		movem.l	(sp)+,d4/d5
		bsr.w	DrawBlocks_LR
		bra.s	locj_72EE
locj_72da:
		moveq	#0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	Calc_VRAM_Pos_2
		movem.l	(sp)+,d4/d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3
locj_72EE:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelDataLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		jsr		LoadLevelHeadersIntoA2
		lea		(a2,d0.w),a2
		addq.l	#4,a2
		movea.l	(a2)+,a0
		lea		(v_16x16).w,a1	; RAM address for 16x16 mappings
		move.w	#0,d0
		jsr		EniDec
		movea.l	(a2)+,a0
		lea		(v_128x128).l,a1 ; RAM address for 128x128 mappings
		jsr		KosDec
		bsr.w	LevelLayoutLoad
		cmpi.w  #-$100,(v_limittop2).w
		bgt.s   @notwrapped
		move.w	#$3C,(Layout_row_index_mask).w
		bra.s   @cont
		
@notwrapped:
		move.w	#$7C,(Layout_row_index_mask).w
		
@cont:
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; is level SBZ3 (LZ4) ?
		bne.s	@notSBZ3	; if not, branch
		moveq	#palid_SBZ3,d0	; use SB3 palette

	@notSBZ3:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2?
		beq.s	@isSBZorFZ	; if yes, branch
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
		bne.s	@normalpal	; if not, branch

	@isSBZorFZ:
		moveq	#palid_SBZ2,d0	; use SBZ2/FZ palette

	@normalpal:
		bsr.w	PalLoad1	; load palette (based on d0)
		rts
; End of function LevelDataLoad

LoadLevelHeadersIntoA2:
		cmpi.b	#3,(v_act).w	; Act 4? Only used in LZ for SBZ3.
		bne.s	@notAct4
		lea		(LevelHeaders4).l,a2
		rts
	@notAct4:
		cmpi.b	#2,(v_act).w	; Act 3?
		bne.s	@notAct3
		lea		(LevelHeaders3).l,a2
		rts
	@notAct3:
		cmpi.b	#1,(v_act).w	; Act 2?
		bne.s	@notAct2
		lea		(LevelHeaders2).l,a2
		rts
	@notAct2:
		lea		(LevelHeaders).l,a2
		rts

; ---------------------------------------------------------------------------
; Subroutine to load primary level PLCs
; ---------------------------------------------------------------------------
LoadLevelPLC:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		jsr		LoadLevelHeadersIntoA2
		lea		(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	@skipPLC	; if PLC is 0, branch
		jmp		AddPLC		; load pattern load cues
	@skipPLC:
		rts

; ---------------------------------------------------------------------------
; Subroutine to load secondary level PLCs
; ---------------------------------------------------------------------------
LoadLevelPLC2:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		jsr		LoadLevelHeadersIntoA2
		lea		4(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	@skipPLC	; if 2nd PLC is 0 (i.e. the ending sequence), branch
		jmp		AddPLC		; load pattern load cues
	@skipPLC:
		rts

; ===========================================================================

LoadZoneTiles:
		moveq	#0,d0			; Clear d0
		move.b	(v_zone).w,d0		; Load number of current zone to d0
		lsl.w	#4,d0			; Multiply by $10, converting the zone ID into an offset
		jsr		LoadLevelHeadersIntoA2	; Load LevelHeaders's address into a2
		lea		(a2,d0.w),a2		; Offset LevelHeaders by the zone-offset, and load the resultant address to a2
		move.l	(a2)+,d0		; Move the first longword of data that a2 points to to d0, this contains the zone's first PLC ID and its art's address.
								; The auto increment is pointless as a2 is overwritten later, and nothing reads from a2 before then
		andi.l	#$FFFFFF,d0			; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
		movea.l	d0,a0			; Load the address of the zone's art into a0 (source)
		lea		(v_128x128).l,a1		; Load v_256x256/StartOfRAM (in this context, an art buffer) into a1 (destination)
		jsr		KosDec			; Decompress a0 to a1 (Kosinski compression)

		move.w	a1,d3			; Move a word of a1 to d3, note that a1 doesn't exactly contain the address of v_256x256/StartOfRAM anymore, after KosDec, a1 now contains v_256x256/StartOfRAM + the size of the file decompressed to it, d3 now contains the length of the file that was decompressed
		move.w	d3,d7			; Move d3 to d7, for use in seperate calculations

		andi.w	#$FFF,d3		; Remove the high nibble of the high byte of the length of decompressed file, this nibble is how many $1000 bytes the decompressed art is
		lsr.w	#1,d3			; Half the value of 'length of decompressed file', d3 becomes the 'DMA transfer length'

		rol.w	#4,d7			; Rotate (left) length of decompressed file by one nibble
		andi.w	#$F,d7			; Only keep the low nibble of low byte (the same one filtered out of d3 above), this nibble is how many $1000 bytes the decompressed art is

@loop:
		move.w	d7,d2			; Move d7 to d2, note that the ahead dbf removes 1 byte from d7 each time it loops, meaning that the following calculations will have different results each time
		lsl.w	#7,d2
		lsl.w	#5,d2			; Shift (left) d2 by $C, making it high nibble of the high byte, d2 is now the size of the decompressed file rounded down to the nearest $1000 bytes, d2 becomes the 'destination address'

		move.l	#$FFFFFF,d1		; Fill d1 with $FF
		move.w	d2,d1			; Move d2 to d1, overwriting the last word of $FF's with d2, this turns d1 into 'StartOfRAM'+'However many $1000 bytes the decompressed art is', d1 becomes the 'source address'

		jsr		(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
		move.w	d7,-(sp)		; Store d7 in the Stack
		jsr		ProcessDMAQueue
		cmp.b	#id_LevelSelect,(v_gamemode).w
		bne.s	@notlvlSel
		jsr		LevSel_Controls
	@notlvlSel:
		jsr		RunPLC
		move.w	(sp)+,d7		; Restore d7 from the Stack
		move.w	#$800,d3		; Force the DMA transfer length to be $1000/2 (the first cycle is dynamic because the art's DMA'd backwards)
		dbf		d7,@loop		; Loop for each $1000 bytes the decompressed art is

		rts
; End of function LoadZoneTiles

; ===========================================================================
; ---------------------------------------------------------------------------
; Level	layout loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; This method now releases free ram space from A408 - A7FF

LevelLayoutLoad:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(Level_Index).l,a0
		movea.l	(a0,d0.w),a0
		lea	(Level_layout_header).w,a1
		move.w	#(v_planebuffer_addr-Level_layout_header)/2-1,d2

loc_1C382:
		move.w	(a0)+,(a1)+
		dbf	d2,loc_1C382
		rts
; End of function LevelLayoutLoad
; ===========================================================================

		include	"Includes/DynamicLevelEvents.asm"

		include	"Includes/Parallax Engine.asm"

		include	"Objects/11 Bridge.asm"

Map_Bri:include	"Mappings/Bridge.asm"
        even
; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PlatformObject:
		lea		(v_player).w,a1
		tst.w	obVelY(a1)	; is Sonic moving up/jumping?
		bmi.w	Plat_Exit	; if yes, branch

;		perform x-axis range check
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit

	Plat_NoXCheck:
		move.w	obY(a0),d0
		subq.w	#8,d0

Platform3:
;		perform y-axis range check
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	Plat_Exit
		cmpi.w	#-$10,d0
		blo.w	Plat_Exit

		tst.b	(f_lockmulti).w
		bmi.w	Plat_Exit
		cmpi.b	#6,obRoutine(a1)
		bhs.w	Plat_Exit
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
	; Gameroid code
		cmpi.b	#id_Gameroid,obID(a0)
		bne.s	@cont
		tst.b	obVelY(a1)
		beq.s	@cont
		move.w	obVelY(a1),d2
		asr		d2		; divide y velocity by 2
		move.w	d2,obVelY(a0)
		bra.s	loc_74AE
	@cont:
		addq.b	#2,obRoutine(a0)

loc_74AE:
		btst	#3,obStatus(a1)
		beq.s	loc_74DC
	;	moveq	#0,d0
		movea.w	obInteract(a1),a2
	;	lsl.w	#6,d0
	;	addi.l	#v_objspace&$FFFFFF,d0
	;	movea.l	d0,a2
		bclr	#3,obStatus(a2)
		cmpi.b	#4,obRoutine(a2)
		bne.s	loc_74DC
		subq.b	#2,obRoutine(a2)

loc_74DC:
	;	move.w	a0,d0
	;	subi.w	#-$3000,d0
	;	lsr.w	#6,d0
	;	andi.w	#$7F,d0
	;	move.b	d0,obStandOnObject(a1)
		move.w	a0,obInteract(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		(Player_ResetOnFloor).l
		jsr		Sonic_ReleaseDropDash
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,obStatus(a1)
		bset	#3,obStatus(a0)

Plat_Exit:
		rts
; End of function PlatformObject

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject:
		lea		(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	Plat_Exit
		btst	#0,obRender(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Solid:
		lea		(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Obj15_Solid

; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
;
; input variables:
; d1 = object width
; d3 = object height / 2
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; loc_19C32:
PlatformObjectS2:
		lea		(v_player).w,a1 ; a1=character
		btst	#3,obStatus(a0)
		beq.w	PlatformObject_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	PlatformObject_SingleCharacter2
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	PlatformObject_SingleCharacter2
		cmp.w	d2,d0
		blo.s	loc_19C802

	PlatformObject_SingleCharacter2:
		bclr	#3,obStatus(a1)
		bset	#1,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
	loc_19C802:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; ===========================================================================

	PlatformObject_cont:
		tst.w	obVelY(a1)
		bmi.w	return_19E8E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	return_19E8E
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	return_19E8E

	loc_19DD8:
		move.w	obY(a0),d0
		sub.w	d3,d0
	;loc_19DDE:
	PlatformObject_ChkYRange:
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	return_19E8E
		cmpi.w	#-$10,d0
		blo.w	return_19E8E
		cmpi.b	#4,d6
		beq.s	@notplayer
	;	tst.b	$2A(a1)
	;	bmi.w	return_19E8E
		cmpi.b	#6,obRoutine(a1)
		bhs.w	return_19E8E

	@notplayer:
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
	;loc_19E14:
	RideObject_SetRide:
		btst	d6,obStatus(a1)
		beq.s	loc_19E30
	;	moveq	#0,d0
		movea.w	obInteract(a1),a3
	;	lsl.w	#6,d0
	;	addi.l	#v_objspace,d0
	;	movea.l	d0,a3	; a3=object
		bclr	d6,obStatus(a3)

	loc_19E30:
	;	move.w	a0,d0
	;	subi.w	#v_objspace,d0
	;	lsr.w	#6,d0
	;	andi.w	#$7F,d0
	;	move.b	d0,obStandOnObject(a1)
		move.w	a0,obInteract(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		tst.b	(v_springshoes).w
		bne.s	RideObject_SpringShoes
		btst	#1,obStatus(a1)
		beq.s	loc_19E7E
		cmpi.b	#charID_Mighity,(v_character).w ; Are we Mighty?
		bne.s	@notmighty ; If not, ignore the following code
		cmpi.b	#1,obDoubleJump(a1)
		bne.s	@notmighty
		move.b	#$40,$3E(a0)

	@notmighty:
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		(Player_ResetOnFloor).l
		jsr		Sonic_ReleaseDropDash
		movea.l	(sp)+,a0 ; a0=character

	loc_19E7E:
		bset	d6,obStatus(a1)
	;	bclr	#1,obStatus(a1)
		bset	d6,obStatus(a0)

	return_19E8E:
		rts

	RideObject_SpringShoes:
		btst	#1,obStatus(a1)
		beq.s	return_19E8E
		move.b	#2,(v_springshoes).w
		move.b	#$40,$3E(a0)
		bset	d6,obStatus(a1)
		bset	d6,obStatus(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off	a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExitPlatform:
		move.w	d1,d2

ExitPlatform2:
		add.w	d2,d2
		lea		(v_player).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_75E0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_75E0
		cmp.w	d2,d0
		blo.s	locret_75F2

loc_75E0:
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)

locret_75F2:
		rts
; End of function ExitPlatform


		include	"Objects/15 Swinging Platforms (part 1).asm"

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm:
		lea		(v_player).w,a1
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.s	MvSonic2
; End of function MvSonicOnPtfm

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm2:
		lea		(v_player).w,a1
		move.w	obY(a0),d0
		subi.w	#9,d0

MvSonic2:
		tst.b	(f_lockmulti).w
		bmi.s	locret_7B62
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	locret_7B62
		tst.w	(v_debuguse).w
		bne.s	locret_7B62
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)
		tst.b	(v_shield).w	 ; does the player have a shield?
		beq.s	locret_7B62	   ; if not, branch
		move.w	d0,(v_oshield+obRoutine+obY).w   ; apply change to shield's Y-Position
		sub.w	d2,(v_oshield+obRoutine+obX).w   ; apply change to shield's X-Position

locret_7B62:
		rts
; End of function MvSonicOnPtfm2

		include	"Objects/15 Swinging Platforms (part 2).asm"
Map_Swing_GHZ:	include	"Mappings/Swinging Platforms (GHZ).asm"
Map_Swing_SLZ:	include	"Mappings/Swinging Platforms (SLZ).asm"
;		include	"Objects/17.asm"
		include	"Objects/18 Platforms.asm"
Map_Plat_LBGZ:include	"Mappings/Platforms (LBGZ).asm"
Map_Plat_GHZ:	include	"Mappings/Platforms (GHZ).asm"
Map_Plat_SYZ:	include	"Mappings/Platforms (SYZ).asm"
Map_Plat_SLZ:	include	"Mappings/Platforms (SLZ).asm"
		include	"Objects/19 Rolling Ball.asm"
Map_GBall:	include	"Mappings/GHZ Ball.asm"
		include	"Objects/1A Collapsing Ledge.asm"
		include	"Objects/53 Collapsing Floors.asm"

; ===========================================================================

Ledge_Fragment:
		move.b	#0,ledge_collapse_flag(a0)

loc_847A:
		lea		(CFlo_Data1).l,a4
		moveq	#$18,d1
		addq.b	#2,obFrame(a0)

loc_8486:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,obRender(a0)
		move.b	0(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
		bra.s	loc_84B2
; ===========================================================================

loc_84AA:
		jsr		FindFreeObj
		bne.s	loc_84F2
		addq.w	#5,a3

loc_84B2:
		move.b	#6,obRoutine(a1)
		move.b	d4,0(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	(a4)+,ledge_timedelay(a1)
		cmpa.l	a0,a1
		bhs.s	loc_84EE
		bsr.w	DisplaySprite1

loc_84EE:
		dbf		d1,loc_84AA

loc_84F2:
		bsr.w	DisplaySprite
		sfx		sfx_Collapse	; play collapsing sound
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
CFlo_Data1:
		dc.b	$1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b	$16, $12, $E, $A, 6, 2, $14, $10, $C, 0
CFlo_Data2:
		dc.b	$1E, $16, $E, 6, $1A, $12,	$A, 2
CFlo_Data3:
		dc.b	$16, $1E, $1A, $12, 6, $E,	$A, 2

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	MZ platforms)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnSlope:
		lea		(v_player).w,a1
		btst	#3,obStatus(a1)
		beq.s	locret_856E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,obRender(a0)
		beq.s	loc_854E
		not.w	d0
		add.w	d1,d0

loc_854E:
		move.b	(a2,d0.w),d1
		ext.w	d1
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_856E:
		rts
; End of function MvSonicOnSlope

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Ledge_SlopeData:incbin	"Miscellaneous/GHZ Collapsing Ledge Heightmap.bin"
		even
Nem_LBGZLedge:	incbin	"art/nemesis/LBGZ Collapsing Ledge.bin"
		even
Nem_LBGZPlat:	incbin	"art/nemesis/LBGZ Platforms.bin"
		even

Map_Ledge:	include	"Mappings/Collapsing Ledge.asm"
Map_CFlo:	include	"Mappings/Collapsing Floors.asm"

		include	"Objects/1C Scenery.asm"
Map_Scen:	include	"Mappings/Scenery.asm"
Map_BGZSeaweed:	include	"Mappings/BGZ Seaweed.asm"
Map_BGZShoji:	include	"Mappings/BGZ Shoji.asm"
Map_MHZLamp:	include	"Mappings/MHZ Lamp.asm"
Map_HPZOrb:	include	"Mappings/HPZ Orb.asm"
		include	"Objects/1D Flower Cannon.asm"
Map_FlowerCannon:	include	"Mappings/Flower Cannon.asm"
DPLC_FlowerCannon:	include	"DPLCs/Flower Cannon.asm"

		include	"Objects/2A SBZ Small Door.asm"
		include	"Animations/SBZ Small Door.asm"
Map_ADoor:	include	"Mappings/SBZ Small Door.asm"

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall:
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4
		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	obVelX(a1)
		bmi.s	loc_8A92
		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	obVelX(a1)
		bpl.s	loc_8A92

loc_8A82:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_8A92:
		btst	#1,obStatus(a1)
		bne.s	loc_8AB6
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		rts
; ===========================================================================

loc_8AA8:
		btst	#5,obStatus(a0)
		beq.s	locret_8AC2
;		move.w	#id_Run,obAnim(a1)	; Mercury Walking In Air Fix
		bra.s	loc_8AB6pushclear

loc_8AB6:
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		WallJump
		movea.l	(sp)+,a0

loc_8AB6pushclear:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

locret_8AC2:
		rts
; ===========================================================================

loc_8AC4:
		tst.w	obVelY(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,obY(a1)
		move.w	#0,obVelY(a1)

locret_8AD8:
		rts
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.s	loc_8B48
		tst.b	(f_lockmulti).w
		bmi.s	loc_8B48
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_8B48
		tst.w	(v_debuguse).w
		bne.s	loc_8B48
		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts
; End of function Obj44_SolidWall2

; ===========================================================================

		include	"Objects/Badniks/1E Ball Hog.asm"
		include	"Objects/Badniks/20 Cannonball.asm"
		include	"Objects/24, 27 & 3F Explosions.asm"
		include	"Animations/Ball Hog.asm"
Map_Hog:	include	"Mappings/Ball Hog.asm"
Map_ExplodeItem:	include	"Mappings/Explosion.asm"
Map_ExplodeBomb:	include	"Mappings/Fiery Explosion.asm"
Map_ExplodeLant:	include	"Mappings/Lantern Explosion.asm"
Map_MonitorShard:	include	"Mappings/Monitor Shards.asm"
		include	"Objects/28 Animals.asm"

		include	"Objects/Badniks/29 Mosqui.asm"
Ani_Mosqui:	include	"Animations/Mosqui.asm"
Map_Mosqui:	include	"Mappings/Mosqui.asm"

		include	"Objects/9F Points.asm"

		include	"Objects/05 Bamboo Pole Springboard.asm"

MapSpr_SpringBoard:	include	"Mappings/Bamboo Pole Springboard.asm"

		include	"Objects/06 Flapdoors.asm"
Map_Animal1:	include	"Mappings/Animals 1.asm"
Map_Animal2:	include	"Mappings/Animals 2.asm"
Map_Animal3:	include	"Mappings/Animals 3.asm"
Map_Poi:		include	"Mappings/Points.asm"

		include	"Objects/Badniks/1F Crabmeat.asm"
		include	"Animations/Crabmeat.asm"
Map_Crab:	include	"Mappings/Crabmeat.asm"
		include	"Objects/Badniks/22 Buzz Bomber.asm"
		include	"Objects/Badniks/23 Buzz Bomber Missile.asm"
		include	"Animations/Buzz Bomber.asm"
		include	"Animations/Buzz Bomber Missile.asm"
Map_Buzz:	include	"Mappings/Buzz Bomber.asm"
Map_Missile:	include	"Mappings/Buzz Bomber Missile.asm"

		include	"Objects/0E, 25, 37 Rings.asm"
		include	"Objects/End of Level/4B Giant Ring.asm"

		include	"Animations/Rings.asm"
Map_Ring:	include	"Mappings/Rings.asm"

Map_GRing:	include	"Mappings/Giant Ring.asm"
DPLC_GRing:	include	"DPLCs/Giant Ring.asm"
		include	"Objects/Powerups/21 Monitor Shards.asm"
		include	"Objects/Powerups/26 Monitor.asm"
		include	"Objects/Powerups/2E Monitor Content Power-Up.asm"
		include	"Objects/Powerups/26 Monitor (SolidSides subroutine).asm"
		include	"Animations/Monitor.asm"
Map_Monitor:	include	"Mappings/Monitor.asm"
Map_MonitorIcon:include	"Mappings/Monitor Icons.asm"
		include	"Objects/Screen-Space/91 Title Screen Characters and NTK Logo Sonic.asm"
		include	"Objects/Screen-Space/92 Title Screen Options.asm"

		include	"Objects/Subroutines/sub AnimateSprite.asm"

Map_TSO:	include	"Mappings/Title Screen Options.asm"
Map_TChr:	include	"Mappings/Title Screen Characters.asm"
DPLC_TChr:	include	"DPLCs/Title Screen Characters.asm"

		include	"Objects/Badniks/2B Wind-Up Koi and Chopper.asm"
Map_WindUpKoi:	include	"Mappings/Wind-Up Koi.asm"
DPLC_WindUpKoi:	include	"DPLCs/Wind-Up Koi.asm"
		include	"Animations/Chopper.asm"
Map_Chop:	include	"Mappings/Chopper.asm"
		include	"Objects/Badniks/2C Jaws.asm"
		include	"Animations/Jaws.asm"
Map_Jaws:	include	"Mappings/Jaws.asm"
		include	"Objects/Badniks/2D Burrobot.asm"
		include	"Animations/Burrobot.asm"
Map_Burro:	include	"Mappings/Burrobot.asm"

		include	"Objects/Hazards/2F MZ Large Grassy Platforms.asm"
		include	"Objects/Hazards/35 Burning Grass.asm"
		include	"Animations/Burning Grass.asm"
Map_LGrass:	include	"Mappings/MZ Large Grassy Platforms.asm"
Map_Fire:	include	"Mappings/Fireballs.asm"
		include	"Objects/30 MZ Large Green Glass Blocks.asm"
Map_Glass:	include	"Mappings/MZ Large Green Glass Blocks.asm"
		include	"Objects/Hazards/31 Chained Stompers.asm"
		include	"Objects/Hazards/45 Sideways Stomper.asm"
Map_CStom:	include	"Mappings/Chained Stompers.asm"
Map_SStom:	include	"Mappings/Sideways Stomper.asm"

		include	"Objects/32 Button.asm"
Map_But:	include	"Mappings/Button.asm"

		include	"Objects/33 Pushable Blocks.asm"
Map_Push:	include	"Mappings/Pushable Blocks.asm"
Map_PushMHZ:include "Mappings/MHZ Pushable Block.asm"

		include	"Objects/Screen-Space/34 Title Cards.asm"
		include	"Objects/Screen-Space/A0 Game Over.asm"
		include	"Objects/Screen-Space/A1 Got Through Card.asm"
		include	"Objects/Screen-Space/7E Special Stage Results.asm"
		include	"Objects/Screen-Space/7F SS Result Chaos Emeralds.asm"

Map_Card:	include	"Mappings/Title Cards.asm"
Map_Over:	include	"Mappings/Game Over.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_Got:
		dc.w	M_Got_SonicHas-Map_Got
		dc.w	M_Got_Passed-Map_Got
		dc.w	M_Got_Score-Map_Got
		dc.w	M_Got_TBonus-Map_Got
		dc.w	M_Got_RBonus-Map_Got
		dc.w	M_Got_Blank-Map_Got
		dc.w	M_Got_Act1-Map_Got
		dc.w	M_Got_Act2-Map_Got
		dc.w	M_Got_Act3-Map_Got
		dc.w	M_Got_Zone-Map_Got
		dc.w	M_Got_TailsHas-Map_Got
		dc.w	M_Got_KnucklesHas-Map_Got
		dc.w	M_Got_KyukoHas-Map_Got
		dc.w	M_Got_MetalHas-Map_Got
		dc.w	M_Got_MightyHas-Map_Got
		dc.w	M_Got_AmyHas-Map_Got
		dc.w	M_Got_LegacyHas-Map_Got

M_Got_SonicHas:		dc.b $8		; SONIC HAS
		dc.b $F8, $5, $0, $3E, $BC	; S
		dc.b $F8, $5, $0, $32, $CC	; O
		dc.b $F8, $5, $0, $2E, $DC	; N
		dc.b $F8, $1, $0, $20, $EC	; I
		dc.b $F8, $5, $0, $8, $F4	; C
		dc.b $F8, $5, $0, $1C, $14	; H
		dc.b $F8, $5, $0, $0, $24	; A
		dc.b $F8, $5, $0, $3E, $34	; S
M_Got_Passed:		dc.b $6		; PASSED
		dc.b $F8, $5, $0, $36, $D0	; P
		dc.b $F8, $5, $0, $0, $E0	; A
		dc.b $F8, $5, $0, $3E, $F0	; S
		dc.b $F8, $5, $0, $3E, $0	; S
		dc.b $F8, $5, $0, $10, $10	; E
		dc.b $F8, $5, $0, $C, $20	; D
M_Got_Score:		dc.b $6		; Score counter
		dc.b $FC, $C, $21, $4A, $B0	; SCOR
		dc.b $FC, $0, $21, $5A, $D0	; E
		dc.b $FC, $8, $1, $5B, $18	; First half of score
		dc.b $FC, $C, $1, $5E, $30	; Second half of score
		dc.b $F7, $4, $0, $6E, $CD	; Top half of oval
		dc.b $FF, $4, $18, $6E, $CD	; Bottom half of oval
M_Got_TBonus:		dc.b $7		; Time bonus counter
		dc.b $FC, $C, $21, $4E, $B0	; TIME
		dc.b $FC, $C, $20, $66, $D9	; BONU
		dc.b $FC, $0, $21, $4A, $F9	; S
		dc.b $F7, $4, $0, $6E, $F6	; Top half of oval
		dc.b $FF, $4, $18, $6E, $F6	; Bottom half of oval
		dc.b $FC, $C, $FF, $F0, $28	; First four digits of bonus
		dc.b $FC, $0, $1, $61, $48	; Last digit of bonus
M_Got_RBonus:		dc.b $7		; Ring bonus counter (this is actually bugged right now)
		dc.b $FC, $C, $21, $52, $B0	; RING
		dc.b $FC, $C, $20, $66, $D9	; BONU
		dc.b $FC, $0, $21, $4A, $F9	; S
		dc.b $F7, $4, $0, $6E, $F6	; Top half of oval
		dc.b $FF, $4, $18, $6E, $F6	; Bottom half of oval
		dc.b $FC, $C, $FF, $F4, $28	; First four digits of bonus
		dc.b $FC, $0, $1, $61, $48	; Last digit of bonus (but it shares the same info as the time bonus...?)
M_Got_Blank:		dc.b $0		; Used to be the oval, but if we remove it, we get to have the entire alphabet.
M_Got_Act1:			dc.b $2		; ACT 1
		dc.b $4, $C, $0, $53, $EC	; ACT (...4 tiles? for 3 letters?)
		dc.b $F4, $2, $0, $57, $C	; 1
M_Got_Act2:			dc.b $2		; ACT 2
		dc.b $4, $C, $0, $53, $EC	; ACT (...4 tiles? for 3 letters?)
		dc.b $F4, $6, $0, $5A, $8	; 2
M_Got_Act3:			dc.b $2		; ACT 3
		dc.b $4, $C, $0, $53, $EC	; ACT (...4 tiles? for 3 letters?)
		dc.b $F4, $6, $0, $60, $8	; 3
M_Got_Zone:			dc.b $4		; ZONE
		dc.b $6, $5, $0, $4E, $B4	; Z
		dc.b $6, $5, $0, $32, $C4	; O
		dc.b $6, $5, $0, $2E, $D4	; N
		dc.b $6, $5, $0, $10, $E4	; E
M_Got_TailsHas:		dc.b $8		; TAILS HAS
		dc.b $F8, $5, $0, $42, $BC	; T
		dc.b $F8, $5, $0, $0, $CC	; A
		dc.b $F8, $1, $0, $20, $DC	; I
		dc.b $F8, $5, $0, $26, $E4	; L
		dc.b $F8, $5, $0, $3E, $F4	; S
		dc.b $F8, $5, $0, $1C, $14	; H
		dc.b $F8, $5, $0, $0, $24	; A
		dc.b $F8, $5, $0, $3E, $34	; S
M_Got_KnucklesHas:	dc.b $A		; KNUCKLES HAS
		dc.b $F8, $5, $0, $22, $A8	; K
		dc.b $F8, $5, $0, $2E, $B8	; N
		dc.b $F8, $5, $0, $46, $C8	; U
		dc.b $F8, $5, $0, $8, $D8	; C
		dc.b $F8, $D, $0, $22, $E8	; KL
		dc.b $F8, $5, $0, $10, $8	; E
		dc.b $F8, $5, $0, $3E, $18	; S
		dc.b $F8, $5, $0, $1C, $38	; H
		dc.b $F8, $5, $0, $0, $48	; A
		dc.b $F8, $5, $0, $3E, $58	; S
M_Got_KyukoHas:		dc.b $8		; KYUKO HAS
		dc.b $F8, $5, $0, $4A, $C8	; K
		dc.b $F8, $5, $0, $1C, $18	; Y
		dc.b $F8, $5, $0, $0, $28	; U
		dc.b $F8, $5, $0, $3E, $38	; K
		dc.b $F8, $5, $0, $22, $B8	; O
		dc.b $F8, $5, $0, $22, $E8	; H
		dc.b $F8, $5, $0, $46, $D8	; A
		dc.b $F8, $5, $0, $32, $F8	; S
M_Got_MetalHas:		dc.b $8		; METAL HAS
		dc.b $F8, $5, $0, $1C, $18	; M
		dc.b $F8, $5, $0, $0, $28	; E
		dc.b $F8, $5, $0, $3E, $38	; T
		dc.b $F8, $5, $0, $2A, $B8	; A
		dc.b $F8, $5, $0, $10, $C8	; L
		dc.b $F8, $5, $0, $42, $D8	; H
		dc.b $F8, $5, $0, $26, $F8	; A
		dc.b $F8, $5, $0, $0, $E8	; S
M_Got_MightyHas:	dc.b $8		; MIGHTY HAS
		dc.b $F8, $5, $0, $2A, $B4	; M
		dc.b $F8, $1, $0, $20, $C4	; I
		dc.b $F8, $D, $0, $18, $CC	; GH
		dc.b $F8, $5, $0, $42, $EC	; T
		dc.b $F8, $5, $0, $4A, $FC	; Y
		dc.b $F8, $5, $0, $1C, $1C	; H
		dc.b $F8, $5, $0, $0, $2C	; A
		dc.b $F8, $5, $0, $3E, $3C	; S
M_Got_AmyHas:		dc.b $6		; AMY HAS
		dc.b $F8, $5, $0, $0, $C8	; A
		dc.b $F8, $5, $0, $2A, $D8	; M
		dc.b $F8, $5, $0, $4A, $E8	; Y
		dc.b $F8, $5, $0, $1C, $8	; H
		dc.b $F8, $5, $0, $0, $18	; A
		dc.b $F8, $5, $0, $3E, $28	; S
M_Got_LegacyHas:	dc.b $9		; LEGACY HAS
		dc.b $F8, $5, $0, $26, $B0	; L
		dc.b $F8, $5, $0, $10, $C0	; E
		dc.b $F8, $5, $0, $18, $D0	; G
		dc.b $F8, $5, $0, $0, $E0	; A
		dc.b $F8, $5, $0, $8, $F0	; C
		dc.b $F8, $5, $0, $4A, $0	; Y
		dc.b $F8, $5, $0, $1C, $20	; H
		dc.b $F8, $5, $0, $0, $30	; A
		dc.b $F8, $5, $0, $3E, $40	; S
		even

; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_SSR:	include	"Mappings/SS Results.asm"

Map_SSRC:	include	"Mappings/SS Result Chaos Emeralds.asm"

		include	"Objects/Hazards/36 Spikes.asm"
Map_Spike:	include	"Mappings/Spikes.asm"
		include	"Objects/3B Purple Rock.asm"
;		include	"Objects/49.asm"
Map_BGZStatues:	include	"Mappings/BGZ Statues.asm"
Map_LRock:	include	"Mappings/LBGZ Rock.asm"
		include	"Objects/3C Smashable Wall.asm"

		include	"Objects/Subroutines/sub SmashObject.asm"

; ===========================================================================
; Smashed block	fragment speeds
;
Smash_FragSpd1:
		dc.w	$400, -$500, $70	; x velocity, y velocity, gravity
		dc.w	$600, -$100, $70
		dc.w	$600, $100, $70
		dc.w	$400, $500, $70
		dc.w	$600, -$600, $70
		dc.w	$800, -$200, $70
		dc.w	$800, $200, $70
		dc.w	$600, $600, $70

Smash_FragSpd2:
		dc.w	-$600, -$600, $70
		dc.w	-$800, -$200, $70
		dc.w	-$800, $200, $70
		dc.w	-$600, $600, $70
		dc.w	-$400, -$500, $70
		dc.w	-$600, -$100, $70
		dc.w	-$600, $100, $70
		dc.w	-$400, $500, $70

Map_Smash:	include	"Mappings/Smashable Walls.asm"

; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExecuteObjects:
		lea		(v_objspace).w,a0 ; set address for object RAM
		moveq	#(v_objspace_End-v_objspace)/SstLimit-1,d7
		moveq	#0,d0

loc_D348:
		move.b	(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr		(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea		SstLimit(a0),a0	; next object
		dbf		d7,loc_D348
		rts
; ===========================================================================

loc_D362:
		cmpi.b	#$A,(v_player+obRoutine).w	  ; Has Sonic drowned?
		beq.s	loc_D348			; If so, run objects a little longer
		moveq	#(v_lvlobjspace-v_objspace)/SstLimit-1,d7
		bsr.s	loc_D348
		moveq	#LevObjNum-1,d7
		bsr.s	loc_D368
		moveq	#(v_objspace_End-v_lvlobjspace_End)/SstLimit-1,d7
		bra.s	loc_D348

loc_D368:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_D378
		tst.b	obRender(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea		SstLimit(a0),a0

loc_D37C:
		dbf		d7,loc_D368
		rts
; End of function ExecuteObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
		include	"Includes/Object Pointers.asm"

; ---------------------------------------------------------------------------
; LoadSubObject
; loads information from a sub-object into this object a0
; ---------------------------------------------------------------------------
LoadSubObject_Part3:
		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		move.w	(a1)+,obPriority(a0)
		move.b	(a1)+,d0
		or.b	d0,obRender(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1),obColType(a0)
		addq.b	#2,obRoutine(a0)
		rts
; ===========================================================================
; the format of the data there is
;	dc.l obMap
;	dc.w obGfx
;	dc.w obPriority (high and low bytes, since it's the 3K system)
;	dc.b obRender, obActWid, obColType
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Get Orientation To Player
; Returns the horizontal and vertical distances of the closest player object.
;
; input variables:
;  a0 = object
;
; returns:
;  a1 = address of closest player character
;  d0 = 0 if player is left from object, 2 if right
;  d1 = 0 if player is above object, 2 if below
;  d2 = closest character's horizontal distance to object
;  d3 = closest character's vertical distance to object
;
; writes:
;  d0, d1, d2, d3
;  a1
; ---------------------------------------------------------------------------
;loc_366D6:
Obj_GetOrientationToPlayer:
		moveq	#0,d0
		moveq	#0,d1
		lea		(v_player).w,a1 ; a1=character
		move.w	obX(a0),d2
		sub.w	obX(a1),d2
		tst.w	d2
		bpl.s	@left	; branch, if enemy is on left to player
		addq.w	#2,d0
	@left:
		move.w	obY(a0),d3
		sub.w	obY(a1),d3	; vertical distance to closest character
		bhs.s	@below	; branch, if enemy is under player
		addq.w	#2,d1
	@below:
		rts
; ===========================================================================

		include	"Objects/Subroutines/sub ObjectFall.asm"
		include	"Objects/Subroutines/sub SpeedToPos.asm"
		include	"Objects/Subroutines/sub DisplaySprite.asm"
		include	"Objects/Subroutines/sub DeleteObject.asm"

; ===========================================================================
BldSpr_ScrPos:
		dc.l	0				; blank
		dc.l	v_screenposx&$FFFFFF	; main screen x-position
		dc.l	v_bgscreenposx&$FFFFFF	; background x-position	1
		dc.l	v_bg3screenposx&$FFFFFF	; background x-position	2
; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:		; XREF: TitleScreen; et al
		lea		(v_spritetablebuffer).w,a2 ; set address for sprite table
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(v_levelstarted).w ; this was level_started_flag
		beq.s	BuildSprites_2
		jsr		loc_40804
		bsr.w	BuildRings
	BuildSprites_2:
		lea		(v_spritequeue).w,a4
		moveq	#7,d7

	loc_D66A:
		tst.w	(a4)
		beq.w	loc_D72E
		moveq	#2,d6

	loc_D672:
		movea.w	(a4,d6.w),a0
		tst.l	obMap(a0)		; does this object have any mappings?
		beq.w	loc_D726	;	; if not, branch
		andi.b	#$7F,obRender(a0)	; clear on-screen flag
		move.b	obRender(a0),d0
		move.w	obX(a0),d3
		move.w	obY(a0),d2
		move.b	d0,d4
		btst	#6,d0	; is the multi-draw flag set?
		bne.w	BuildSprites_MultiDraw	; if it is, branch
BuildSprite_Normal:
		andi.w	#$C,d0
		beq.s	loc_D700	; if it is, branch
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1	; is the object right edge to the left of the screen?
		bmi.w	loc_D726	; if it is, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1	; is the object left edge to the right of the screen?
		bge.w	loc_D726	; if it is, branch
		addi.w	#128,d3
		btst	#4,d4		; is the accurate Y check flag set?
		beq.s	BuildSprites_ApproxYCheck	; if not, branch
		moveq	#0,d0
		move.b	obHeight(a0),d0
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D726	; if the object is above the screen
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	loc_D726	; if the object is below the screen
		addi.w	#128,d2
		bra.s	loc_D700

BuildSprites_ApproxYCheck:
		sub.w	4(a1),d2
		addi.w	#128,d2
		andi.w	#$7FF,d2
		cmpi.w	#-32+128,d2	; assume Y radius to be 32 pixels
		blo.s	loc_D726
		cmpi.w	#32+128+224,d2
		bhs.s	loc_D726
	loc_D700:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D71C
		move.b	obFrame(a0),d1
		add.w	d1,d1					; MJ: changed from byte to word (we want more than 7F sprites)
		adda.w	(a1,d1.w),a1
		moveq	#0,d1					; MJ: clear d1 (because of our byte to word change)
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_D720

	loc_D71C:
		bsr.w	sub_D750

	loc_D720:
		ori.b	#$80,obRender(a0) ;bset	#7,1(a0)

	loc_D726:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D672

	loc_D72E:
		lea		$80(a4),a4
		dbf		d7,loc_D66A
		move.b	d5,(v_spritecount).w
		cmpi.b	#80,d5
		beq.s	loc_D748
		move.l	#0,(a2)
		rts
; ===========================================================================

	loc_D748:
		move.b	#0,-5(a2)
		rts
; End of function BuildSprites

BuildSprites_MultiDraw:
		move.l	a4,-(sp)
		lea		(v_screenposx).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0

	; check if object is within X bounds
		move.b	mainspr_width(a0),d0	; load pixel width
		;move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1				; is the object right edge to the left of the screen?
		bmi.w	BuildSprites_MultiDraw_NextObj   ; if it is, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1			  ; is the object left edge to the right of the screen?
		bge.w	BuildSprites_MultiDraw_NextObj   ; if it is, branch
		addi.w	#128,d3

	; check if object is within Y bounds
		btst	#4,d4				; is the accurate Y check flag set?
		beq.s	BuildSpritesMulti_ApproxYCheck
		moveq	#0,d0
		move.b	mainspr_height(a0),d0		 ; load pixel height
		;move.w	obY(a0),d2
		sub.w	4(a4),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.w	BuildSprites_MultiDraw_NextObj  ; if the object is above the screen
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.w	BuildSprites_MultiDraw_NextObj  ; if the object is below the screen
		addi.w	#128,d2
		bra.s	BuildSpritesMulti_DrawSprite
BuildSpritesMulti_ApproxYCheck:
		move.w	obY(a0),d2
		sub.w	4(a4),d2
		addi.w	#128,d2
		andi.w	#$7FF,d2
		cmpi.w	#-32+128,d2
		blo.s	BuildSprites_MultiDraw_NextObj
		cmpi.w	#32+128+224,d2
		bhs.s	BuildSprites_MultiDraw_NextObj
BuildSpritesMulti_DrawSprite:
		moveq	#0,d1
		move.b	mainspr_mapframe(a0),d1		 ; get current frame
		beq.s	@noparenttodraw
		add.w	d1,d1
		movea.l	a5,a1				; a5 is mappings(a0), copy to a1
		adda.w	(a1,d1.w),a1
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1				; get number of pieces
		bmi.s	@noparenttodraw		  ; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite			 ; draw the sprite
		move.w	(sp)+,d4
	@noparenttodraw:
		ori.b	#$80,render_flags(a0)		 ; set onscreen flag
		lea		sub2_x_pos(a0),a6		; address of first child sprite info
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0	 ; get child sprite count
		subq.w	#1,d0				 ; if there are 0, go to next object
		bcs.s	BuildSprites_MultiDraw_NextObj

	@drawchildloop:
		swap	d0
		move.w	(a6)+,d3			 ; get X pos
		sub.w	(a4),d3			  ; subtract the screen's x position
		addi.w	#128,d3
		move.w	(a6)+,d2			 ; get Y pos
		sub.w	4(a4),d2   ; subtract the screen's y position
		addi.w	#128,d2
		andi.w	#$7FF,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1			 ; get mapping frame
		add.w	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1				; get number of pieces
		bmi.s	@nochildleft			 ; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite
		move.w	(sp)+,d4
	@nochildleft:
		swap	d0
		dbf		d0,@drawchildloop		 ; repeat for number of child sprites
	; loc_16804:
	BuildSprites_MultiDraw_NextObj:
		movea.l	(sp)+,a4
		bra.w	loc_D726; End of function BuildSprites


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_1680A:
ChkDrawSprite:
		cmpi.b	#80,d5		; has the sprite limit been reached?
		blo.s	loc_1681C	; if it hasn't, branch
		rts	; otherwise, return

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D750:				; XREF: BuildSprites
		movea.w	2(a0),a3
loc_1681C:
		btst	#0,d4
		bne.s	loc_D796
		btst	#1,d4
		bne.w	loc_D7E4
; End of function sub_D750


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D762:				; XREF: sub_D762; SS_ShowLayout
		cmpi.b	#$50,d5
		beq.s	locret_D794
sub_D762_2:				; XREF: sub_D762; SS_ShowLayout
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf		d1,sub_D762

locret_D794:
		rts
; End of function sub_D762

; ===========================================================================

loc_D796:
		btst	#1,d4
		bne.w	loc_D82A

loc_D79E:
		cmpi.b	#$50,d5
		beq.s	locret_D7E2
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7DC
		addq.w	#1,d0

loc_D7DC:
		move.w	d0,(a2)+
		dbf		d1,loc_D79E

locret_D7E2:
		rts
; ===========================================================================

loc_D7E4:				; XREF: sub_D750
		cmpi.b	#$50,d5
		beq.s	locret_D828
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D822
		addq.w	#1,d0

loc_D822:
		move.w	d0,(a2)+
		dbf		d1,loc_D7E4

locret_D828:
		rts
; ===========================================================================

loc_D82A:
		cmpi.b	#$50,d5
		beq.s	locret_D87C
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D876
		addq.w	#1,d0

loc_D876:
		move.w	d0,(a2)+
		dbf		d1,loc_D82A

locret_D87C:
		rts

		include	"Objects/Subroutines/sub ChkObjectVisible.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load a level's objects
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


; ---------------------------------------------------------------------------
; Objects Manager
; Subroutine to load objects whenever they are close to the screen. Unlike in
; normal s2, in this version every object gets an entry in the respawn table.
; This is necessary to get the additional y-range checks to work.
;
; input variables:
;  -none-
;
; writes:
;  d0, d1, d2
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;  d6 = camera position
;
;  a0 = address in object placement list
;  a3 = address in object respawn table
;  a6 = object loading routine
; ---------------------------------------------------------------------------

; loc_17AA4
ObjPosLoad:
		moveq	#0,d0
		move.b	(v_opl_routine).w,d0
		jmp		ObjPosLoad_States(pc,d0.w)

; ============== JUMP TABLE	=============================================
ObjPosLoad_States:
		bra.w	ObjPosLoad_Init		; 0
		bra.w	ObjPosLoad_Main		; 2
; ============== END JUMP TABLE	=============================================

ObjPosLoad_Init:
		addq.b	#4,(v_opl_routine).w

		lea		(v_objstate).w,a0
		moveq	#0,d0
		move.w	#$BF,d1 ; set loop counter
	OPLBack1:
		move.l	d0,(a0)+
		dbf		d1,OPLBack1

	; Start of new special stage test.
		cmpi.b	#id_Special,(v_gamemode).w	; special stage?
		bne.s	@normalLayouts
		move.b	(v_lastspecial).w,d0	; Testing...
		subq.b	#1,d0
		lsr.b	#1,d0
		lea		(SSObjPos_Index).l,a0	; load the first pointer in the object layout list pointer index,
		adda.w	(a0,d0.w),a0		; load the pointer to the current object layout
		bra.s	@done
	@normalLayouts:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea		(ObjPos_Index).l,a0	; load the first pointer in the object layout list pointer index,
		adda.w	(a0,d0.w),a0		; load the pointer to the current object layout
	@done:
	; End of new special stage test.
	; initialize each object load address with the first object in the layout
		move.l	a0,(v_opl_data).w
		move.l	a0,(v_opl_data+4).w
		lea		(v_objstate).w,a3

		move.w	(v_screenposx).w,d6
		subi.w	#$80,d6	; look one chunk to the left
		bcc.s	OPL1	; if the result was negative,
		moveq	#0,d6	; cap at zero
OPL1:
		andi.w	#$FF80,d6	; limit to increments of $80 (width of a chunk)

		movea.l	(v_opl_data).w,a0	; get first object in layout

	OPLBack2:	; at the beginning of a level this gives respawn table entries to any object that is one chunk
	; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
		cmp.w	(a0),d6		; is object's x position >= d6?
		bls.s	OPL2		; if yes, branch
		addq.w	#6,a0	; next object
		addq.w	#1,a3	; respawn index of next object going right
		bra.s	OPLBack2
; ---------------------------------------------------------------------------

OPL2:
		move.l	a0,(v_opl_data).w	; remember rightmost object that has been processed, so far (we still need to look forward)
		move.w	a3,(v_opl_data+8).w	; and its respawn table index

		lea		(v_objstate).w,a3	; reset a3
		movea.l	(v_opl_data+4).w,a0	; reset a0
		subi.w	#$80,d6		; look even farther left (any object behind this is out of range)
		bcs.s	OPL3		; branch, if camera position would be behind level's left boundary

	OPLBack3:	; count how many objects are behind the screen that are not in range and need to remember their state
		cmp.w	(a0),d6		; is object's x position >= d6?
		bls.s	OPL3		; if yes, branch
		addq.w	#6,a0
		addq.w	#1,a3	; respawn index of next object going left
		bra.s	OPLBack3	; continue with next object
; ---------------------------------------------------------------------------

OPL3:
		move.l	a0,(v_opl_data+4).w	; remember current object from the left
		move.w	a3,(v_opl_data+$C).w	; and its respawn table index

		move.w	#-1,(v_scrposx_last).w	; make sure ObjPosLoad_GoingForward is run

		move.w	(v_screenposy).w,d0
		andi.w	#$FF80,d0
		move.w	d0,(v_scrposy_last).w	; make sure the Y check isn't run unnecessarily during initialization
; ---------------------------------------------------------------------------

ObjPosLoad_Main:
		tst.w	(v_limitbtm1).w	; does this level y-wrap?
		bpl.s	ObjMan_Main_NoYWrap	; if not, branch
		lea		(ChkLoadObj_YWrap).l,a6	; set object loading routine
		move.w	(v_screenposy).w,d3
		andi.w	#$FF80,d3	; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4	; set lower boundary
		subi.w	#$80,d3		; set upper boundary
		bpl.s	OPL4		; branch, if upper boundary > 0
		andi.w	#$7FF,d3	; wrap value
		bra.s	ObjMan_Main_Cont
; ---------------------------------------------------------------------------

OPL4:
		move.w	#$7FF,d0
		addq.w	#1,d0
		cmp.w	d0,d4
		bls.s	OPL5		; branch, if lower boundary < $7FF
		andi.w	#$7FF,d4	; wrap value
		bra.s	ObjMan_Main_Cont
; ---------------------------------------------------------------------------

ObjMan_Main_NoYWrap:
		move.w	(v_screenposy).w,d3
		andi.w	#$FF80,d3	; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4	; set lower boundary
		subi.w	#$80,d3		; set upper boundary
		bpl.s	OPL5
		moveq	#0,d3	; no negative values allowed

OPL5:
		lea		(ChkLoadObj).l,a6	; set object loading routine

ObjMan_Main_Cont:
		move.w	#$FFF,d5	; this will be used later when we load objects
		move.w	(v_screenposx).w,d6
		andi.w	#$FF80,d6
		cmp.w	(v_scrposx_last).w,d6	; is the X range the same as last time?
		beq.w	ObjPosLoad_SameXRange	; if yes, branch
		bge.s	ObjPosLoad_GoingForward	; if new pos is greater than old pos, branch

	; if the player is moving back
		move.w	d6,(v_scrposx_last).w	; remember current position for next time

		movea.l	(v_opl_data+4).w,a0	; get current object going left
		movea.w	(v_opl_data+$C).w,a3	; and its respawn table index

		subi.w	#$80,d6			; look one chunk to the left
		bcs.s	ObjMan_GoingBack_Part2	; branch, if camera position would be behind level's left boundary

		jsr		(FindFreeObj).l		; find an empty object slot
		bne.s	ObjMan_GoingBack_Part2		; branch, if there are none
	OPLBack4:	; load all objects left of the screen that are now in range
		cmp.w	-6(a0),d6		; is the previous object's X pos less than d6?
		bge.s	ObjMan_GoingBack_Part2	; if it is, branch
		subq.w	#6,a0		; get object's address
		subq.w	#1,a3		; and respawn table index
		jsr		(a6)		; load object
		bne.s	OPL6		; branch, if SST is full
		subq.w	#6,a0
		bra.s	OPLBack4	; continue with previous object
; ---------------------------------------------------------------------------

OPL6:
	; undo a few things, if the object couldn't load
		addq.w	#6,a0	; go back to last object
		addq.w	#1,a3	; since we didn't load the object, undo last change

ObjMan_GoingBack_Part2:
		move.l	a0,(v_opl_data+4).w	; remember current object going left
		move.w	a3,(v_opl_data+$C).w	; and its respawn table index
		movea.l	(v_opl_data).w,a0	; get next object going right
		movea.w	(v_opl_data+8).w,a3	; and its respawn table index
		addi.w	#$300,d6	; look two chunks beyond the right edge of the screen

	OPLBack5:	; subtract number of objects that have been moved out of range (from the right side)
		cmp.w	-6(a0),d6	; is the previous object's X pos less than d6?
		bgt.s	OPL7		; if it is, branch
		subq.w	#6,a0		; get object's address
		subq.w	#1,a3		; and respawn table index
		bra.s	OPLBack5	; continue with previous object
; ---------------------------------------------------------------------------

OPL7:
		move.l	a0,(v_opl_data).w	; remember next object going right
		move.w	a3,(v_opl_data+8).w	; and its respawn table index
		bra.s	ObjPosLoad_SameXRange
; ---------------------------------------------------------------------------

ObjPosLoad_GoingForward:
		move.w	d6,(v_scrposx_last).w

		movea.l	(v_opl_data).w,a0	; get next object from the right
		movea.w	(v_opl_data+8).w,a3	; and its respawn table index
		addi.w	#$280,d6	; look two chunks forward
		jsr		(FindFreeObj).l		; find an empty object slot
		bne.s	ObjMan_GoingForward_Part2	; branch, if there are none

	OPLBack6:	; load all objects right of the screen that are now in range
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	ObjMan_GoingForward_Part2	; if yes, branch
		jsr		(a6)		; load object (and get address of next object)
		addq.w	#1,a3		; respawn index of next object to the right
		beq.s	OPLBack6	; continue loading objects, if the SST isn't full

ObjMan_GoingForward_Part2:
		move.l	a0,(v_opl_data).w	; remember next object from the right
		move.w	a3,(v_opl_data+8).w	; and its respawn table index
		movea.l	(v_opl_data+4).w,a0	; get current object from the left
		movea.w	(v_opl_data+$C).w,a3	; and its respawn table index
		subi.w	#$300,d6		; look one chunk behind the left edge of the screen
		bcs.s	ObjMan_GoingForward_End	; branch, if camera position would be behind level's left boundary

	OPLBack7:	; subtract number of objects that have been moved out of range (from the left)
		cmp.w	(a0),d6			; is object's x position >= d6?
		bls.s	ObjMan_GoingForward_End	; if yes, branch
		addq.w	#6,a0	; next object
		addq.w	#1,a3	; respawn index of next object to the left
		bra.s	OPLBack7	; continue with next object
; ---------------------------------------------------------------------------

ObjMan_GoingForward_End:
		move.l	a0,(v_opl_data+4).w	; remember current object from the left
		move.w	a3,(v_opl_data+$C).w	; and its respawn table index

ObjPosLoad_SameXRange:
		move.w	(v_screenposy).w,d6
		andi.w	#$FF80,d6
		move.w	d6,d3
		cmp.w	(v_scrposy_last).w,d6	; is the y range the same as last time?
		beq.w	ObjPosLoad_SameYRange	; if yes, branch
		bge.s	ObjPosLoad_GoingDown	; if the player is moving down

	; if the player is moving up
		tst.w	(v_limittop2).w	; does the level y-wrap?
		bpl.s	ObjMan_GoingUp_NoYWrap	; if not, branch
		tst.w	d6
		bne.s	ObjMan_GoingUp_YWrap
		cmpi.w	#$80,(v_scrposy_last).w
		bne.s	ObjMan_GoingDown_YWrap

ObjMan_GoingUp_YWrap:
		subi.w	#$80,d3			; look one chunk up
		bpl.s	ObjPosLoad_YCheck	; go to y check, if camera y position >= $80
		andi.w	#$7FF,d3		; else, wrap value
		bra.s	ObjPosLoad_YCheck

; ---------------------------------------------------------------------------

ObjMan_GoingUp_NoYWrap:
		subi.w	#$80,d3				; look one chunk up
		bmi.w	ObjPosLoad_SameYRange	; don't do anything if camera y position is < $80
		bra.s	ObjPosLoad_YCheck
; ---------------------------------------------------------------------------

ObjPosLoad_GoingDown:
		tst.w	(v_limittop2).w		; does the level y-wrap?
		bpl.s	ObjMan_GoingDown_NoYWrap	; if not, branch
		tst.w	(v_scrposy_last).w
		bne.s	ObjMan_GoingDown_YWrap
		cmpi.w	#$80,d6
		bne.s	ObjMan_GoingUp_YWrap

ObjMan_GoingDown_YWrap:
		addi.w	#$180,d3		; look one chunk down
		cmpi.w	#$7FF,d3
		bcs.s	ObjPosLoad_YCheck	; go to  check, if camera y position < $7FF
		andi.w	#$7FF,d3		; else, wrap value
		bra.s	ObjPosLoad_YCheck
; ---------------------------------------------------------------------------

ObjMan_GoingDown_NoYWrap:
		addi.w	#$180,d3			; look one chunk down
		cmpi.w	#$7FF,d3
		bhi.s	ObjPosLoad_SameYRange	; don't do anything, if camera is too close to bottom

ObjPosLoad_YCheck:
		jsr		(FindFreeObj).l		; get an empty object slot
		bne.s	ObjPosLoad_SameYRange	; branch, if there are none
		move.w	d3,d4
		addi.w	#$80,d4
		move.w	#$FFF,d5	; this will be used later when we load objects
		movea.l	(v_opl_data+4).w,a0	; get next object going left
		movea.w	(v_opl_data+$C).w,a3	; and its respawn table index
		move.l	(v_opl_data).w,d7	; get next object going right
		sub.l	a0,d7	; d7 = number of objects between the left and right boundaries * 6
		beq.s	ObjPosLoad_SameYRange	; branch if there are no objects inbetween
		addq.w	#2,a0	; align to object's y position

	OPLBack8:	; check, if current object needs to be loaded
		tst.b	(a3)	; is object already loaded?
		bmi.s	OPL8	; if yes, branch
		move.w	(a0),d1
		and.w	d5,d1	; get object's y position
		cmp.w	d3,d1
		bcs.s	OPL8	; branch, if object is out of range from the top
		cmp.w	d4,d1
		bhi.s	OPL8	; branch, if object is out of range from the bottom
		bset	#7,(a3)	; mark object as loaded
	; load object
		move.w	-2(a0),obX(a1)
		move.w	(a0),d1
		move.w	d1,d2
		and.w	d5,d1	; get object's y position
		move.w	d1,obY(a1)
		rol.w	#3,d2
		andi.w	#3,d2	; get object's render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		move.b	2(a0),0(a1)
		move.b	3(a0),obSubtype(a1)
		move.w	a3,obRespawnNo(a1)
		jsr		(FindFreeObj).l	; find new object slot
		bne.s	ObjPosLoad_SameYRange	; brach, if there are none left
OPL8:
		addq.w	#6,a0	; address of next object
		addq.w	#1,a3	; and its respawn index
		subq.w	#6,d7	; subtract from size of remaining objects
		bne.s	OPLBack8	; branch, if there are more

ObjPosLoad_SameYRange:
		move.w	d6,(v_scrposy_last).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutines to check if an object needs to be loaded,
; with and without y-wrapping enabled.
;
; input variables:
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;
;  a0 = address in object placement list
;  a1 = object
;  a3 = address in object respawn table
;
; writes:
;  d1, d2, d7
; ---------------------------------------------------------------------------
ChkLoadObj_YWrap:
		tst.b	(a3)	; is object already loaded?
		bpl.s	OPL9	; if not, branch
		addq.w	#6,a0	; address of next object
		moveq	#0,d1	; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL9:
		move.w	(a0)+,d7	; obX
		move.w	(a0)+,d1	; there are three things stored in this word
		move.w	d1,d2	; does this object skip y-Checks?
		bmi.s	OPL10	; if yes, branch
		and.w	d5,d1	; obY
		cmp.w	d3,d1
		bcc.s	LoadObj_YWrap
		cmp.w	d4,d1
		bls.s	LoadObj_YWrap
		addq.w	#2,a0	; address of next object
		moveq	#0,d1	; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL10:
		and.w	d5,d1	; obY

LoadObj_YWrap:
		bset	#7,(a3)	; mark object as loaded
		move.w	d7,obX(a1)
		move.w	d1,obY(a1)
		rol.w	#3,d2	; adjust bits
		andi.w	#3,d2	; get render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		move.b	(a0)+,(a1)
		move.b	(a0)+,obSubtype(a1)
		move.w	a3,obRespawnNo(a1)
		bra.s	FindFreeObj	; find new object slot

;loc_17F36
ChkLoadObj:
		tst.b	(a3)	; is object already loaded?
		bpl.s	OPL11	; if not, branch
		addq.w	#6,a0	; address of next object
		moveq	#0,d1	; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

OPL11:
		move.w	(a0)+,d7	; obX
		move.w	(a0)+,d1	; there are three things stored in this word
		move.w	d1,d2	; does this object skip y-Checks?	;*6
		bmi.s	OPL13	; if yes, branch
		and.w	d5,d1	; obY
		cmp.w	d3,d1
		bcs.s	OPL12	; branch, if object is out of range from the top
		cmp.w	d4,d1
		bls.s	LoadObj	; branch, if object is in range from the bottom
OPL12:
		addq.w	#2,a0	; address of next object
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

OPL13:
		and.w	d5,d1	; obY

LoadObj:
		bset	#7,(a3)	; mark object as loaded
		move.w	d7,obX(a1)
		move.w	d1,obY(a1)
		rol.w	#3,d2	; adjust bits
		andi.w	#3,d2	; get render flags and status
		move.b	d2,obRender(a1)
		move.b	d2,obStatus(a1)
		move.b	(a0)+,(a1)
		move.b	(a0)+,obSubtype(a1)
		move.w	a3,obRespawnNo(a1)
	; continue straight to FindFreeObj
; End of function ChkLoadObj
; ===========================================================================

		include	"Objects/Subroutines/sub FindFreeObj.asm"
		include	"Objects/Subroutines/sub RingsManager.asm"
		include	"Objects/41 Springs.asm"
		include	"Animations/Springs.asm"
Map_Spring:	include	"Mappings/Springs.asm"
Map_DiagSprings:	include "Mappings/Diagonal Springs.asm"
		include	"Objects/Badniks/42 Newtron.asm"
		include	"Animations/Newtron.asm"
Map_Newt:	include	"Mappings/Newtron.asm"
		include	"Objects/Badniks/43 Roller.asm"
		include	"Animations/Roller.asm"
Map_Roll:	include	"Mappings/Roller.asm"

;		include	"Objects/Subroutines/sub FlickerMove.asm"	; No clue where this is used, if anywhere.

		include	"Objects/Hazards/13 Lava Ball Maker.asm"
		include	"Objects/Hazards/14 Lava Ball.asm"
		include	"Animations/Fireballs.asm"

		include	"Objects/Hazards/6D Flamethrower.asm"
		include	"Animations/Flamethrower.asm"
Map_Flame:	include	"Mappings/Flamethrower.asm"

		include	"Objects/46 MZ Bricks.asm"
Map_Brick:	include	"Mappings/MZ Bricks.asm"

		include	"Objects/12 Light.asm"
Map_Light:	include	"Mappings/Light.asm"
		include	"Objects/47 Bumper.asm"
		include	"Animations/Bumper.asm"
Map_Bump:	include	"Mappings/Bumper.asm"

		include	"Objects/End of Level/0D Signpost.asm" ; includes "GotThroughAct" subroutine
		include	"Animations/Signpost.asm"
Map_Sign:	include	"Mappings/Signpost.asm"
DPLC_Sign:	include	"DPLCs/Signpost.asm"

		include	"Objects/Hazards/4C & 4D Lava Geyser Maker.asm"
		include	"Objects/Hazards/4E Wall of Lava.asm"
		include	"Objects/Hazards/54 Lava Tag.asm"
Map_LTag:	include	"Mappings/Lava Tag.asm"
		include	"Animations/Lava Geyser.asm"
		include	"Animations/Wall of Lava.asm"
Map_Geyser:	include	"Mappings/Lava Geyser.asm"
Map_LWall:	include	"Mappings/Wall of Lava.asm"

		include	"Objects/Badniks/40 Moto Bug.asm" ; includes "Objects/Subroutines/sub RememberState.asm"
		include	"Animations/Moto Bug.asm"
Map_Moto:	include	"Mappings/Moto Bug.asm"

		include	"Objects/Badniks/08 Gameroid.asm"
Map_Gameroid:	include	"Mappings/Gameroid.asm"

		include	"Objects/Subroutines/Lava subroutines.asm"

		include	"Objects/Badniks/4F Snowrex.asm"
	include	"Animations/Snowrex.asm"
Map_Snowrex:	include "Mappings/Snowrex.asm"
		include	"Objects/Badniks/4A Snow Tulipon.asm"
Map_SnowTulipon:	include	"Mappings/Snow Tulipon.asm"


		include	"Objects/Badniks/50 Yadrin.asm"
		include	"Animations/Yadrin.asm"
Map_Yad:	include	"Mappings/Yadrin.asm"

		include	"Objects/Subroutines/sub SolidObject.asm"

		include	"Objects/51 Smashable Green Block.asm"
Map_SmabBGZ:	include	"Mappings/Smashable Block - BGZ.asm"
Map_SmabMHZ:	include	"Mappings/Smashable Block - MHZ.asm"
Map_SmabMTZ:	include	"Mappings/Smashable Block - MTZ.asm"

		include	"Objects/52 Moving Blocks.asm"
Map_MBlock:	include	"Mappings/Moving Blocks (MZ and SBZ).asm"
Map_MBlockLZ:	include	"Mappings/Moving Blocks (LZ).asm"

		include	"Objects/Badniks/55 Basaran.asm"
		include	"Animations/Basaran.asm"
Map_Bas:	include	"Mappings/Basaran.asm"

		include	"Objects/56 Floating Blocks and Doors.asm"
Map_FBlock:	include	"Mappings/Floating Blocks and Doors.asm"
Map_FBlockGHZ:	include	"Mappings/GHZ Floating Blocks and Doors.asm"
		include	"Objects/Hazards/57 Spiked Ball and Chain.asm"
Map_SBall:	include	"Mappings/Spiked Ball and Chain (SYZ).asm"
Map_SBall2:	include	"Mappings/Spiked Ball and Chain (LZ).asm"
		include	"Objects/Hazards/58 Big Spiked Ball.asm"
Map_BBall:	include	"Mappings/Big Spiked Ball.asm"
		include	"Objects/59 SLZ Elevators.asm"
Map_Elev:	include	"Mappings/SLZ Elevators.asm"
		include	"Objects/5A SLZ Circling Platform.asm"
Map_Circ:	include	"Mappings/SLZ Circling Platform.asm"
		include	"Objects/5B Staircase.asm"
Map_Stair:	include	"Mappings/Staircase.asm"
		include	"Objects/Screen-Space/5C Pylon.asm"
Map_Pylon:	include	"Mappings/Pylon.asm"
		include	"Objects/1B Water Surface.asm"
Map_Surf:	include	"Mappings/Water Surface.asm"
		include	"Objects/Powerups/07 Invincibility Stars.asm"
Map_InvStars:	include	"Mappings/Invincibility Stars.asm"
		include	"Objects/0B Pole that Breaks.asm"
Map_Pole:	include	"Mappings/Pole that Breaks.asm"
		include	"Objects/0C Flapping Door.asm"
		include	"Animations/Flapping Door.asm"
Map_Flap:	include	"Mappings/Flapping Door.asm"

		include	"Objects/Invisible/71 Invisible Barriers.asm"
Map_Invis:	include	"Mappings/Invisible Barriers.asm"

		include	"Objects/5D Fan.asm"
Map_Fan:	include	"Mappings/Fan.asm"
		include	"Objects/5E Seesaw.asm"
Map_Seesaw:	include	"Mappings/Seesaw.asm"
Map_SSawBall:	include	"Mappings/Seesaw Ball.asm"
		include	"Objects/Badniks/5F Bomb Enemy.asm"
		include	"Animations/Bomb Enemy.asm"
Map_Bomb:	include	"Mappings/Bomb Enemy.asm"

		include	"Objects/Badniks/60 Orbinaut.asm"
		include	"Animations/Orbinaut.asm"
Map_Orb:	include	"Mappings/Orbinaut.asm"

		include	"Objects/Hazards/16 Harpoon.asm"
		include	"Animations/Harpoon.asm"
Map_Harp:	include	"Mappings/Harpoon.asm"
		include	"Objects/61 LZ Blocks.asm"
Map_LBlock:	include	"Mappings/LZ Blocks.asm"
		include	"Objects/Hazards/62 Gargoyle.asm"
Map_Gar:	include	"Mappings/Gargoyle.asm"
		include	"Objects/63 LZ Conveyor.asm"
Map_LConv:	include	"Mappings/LZ Conveyor.asm"
		include	"Objects/64 Bubbles.asm"
		include	"Animations/Bubbles.asm"
Map_Bub:	include	"Mappings/Bubbles.asm"
Map_BubGen:	include	"Mappings/Bubble Generator.asm"
Map_Countdown:	include	"Mappings/Countdown Numbers.asm"
DPLC_Countdown:	include	"DPLCs/Countdown Numbers.asm"
		include	"Objects/65 Waterfalls.asm"
		include	"Animations/Waterfalls.asm"
Map_WFall	include	"Mappings/Waterfalls.asm"

; ===========================================================================

ResetHeight:
		cmpi.b	#charID_Tails,(v_character).w
		beq.s	@tailsheight
	@normalheight:
		move.b	#$13,(v_player+obHeight).w
		move.b	#9,(v_player+obWidth).w
		rts
	@tailsheight:
		move.b	#$F,(v_player+obHeight).w
		move.b	#9,(v_player+obWidth).w
		rts

ReloadPlayerMappings:
		lea		(v_player).w,a0
PlayerMapsToA0:
		move.w	a0,-(sp)
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		tst.b	(v_super).w
		bne.s	@super
		move.l	@mapLUT(pc,d0.w),obMap(a0)
		move.w	(sp)+,a0
		rts

	@super:
		move.l	@SuperMapLUT(pc,d0.w),obMap(a0)
		move.w	(sp)+,a0
		rts

	@mapLUT:
		dc.l	Map_Sonic, Map_Tails, Map_Knuckles, Map_Kyuko, Map_Metal, Map_Mighty, Map_Amy, Map_Legacy

	@SuperMapLUT:
		dc.l	Map_SuperSonic, Map_Tails, Map_Knuckles, Map_Kyuko, Map_Metal, Map_Mighty, Map_Amy, Map_Legacy

Player_LoadGfx:
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@loadGFXLUT(pc,d0.w),a1
		jsr		(a1)
		rts

	@loadGFXLUT:
		dc.l	Sonic_LoadGfx,Tails_LoadGfx,Knuckles_LoadGfx,Kyuko_LoadGfx,Metal_LoadGfx,Mighty_LoadGfx,Amy_LoadGfx,Legacy_LoadGfx

Player_Animate:
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@animateLUT(pc,d0.w),a1
		jsr		(a1)
		rts

	@animateLUT:
		dc.l	Sonic_Animate,Tails_Animate,Knuckles_Animate,Kyuko_Animate,Metal_Animate,Mighty_Animate,Amy_Animate,Legacy_Animate

LoadEndingCharacterMaps:
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	@mapLUT(pc,d0.w),(v_player+obMap).w
		rts

	@mapLUT:
		dc.l	Map_ESon, Map_ETai, Map_EKnu, Map_ESon, Map_ESon, Map_ESon, Map_ESon, Map_ESon

LoadEndingCharacterPLC:
		moveq	#0,d0
		move.b	(v_character).w,d0
		move.b	@plcLUT(pc,d0.w),d0
		bmi.s	@noPLC
		jsr		QuickPLC	; load ending sequence patterns
	@noPLC:
		rts

	@plcLUT:
		dc.b	plcid_EndingSonic, plcid_EndingTails
		dc.b	plcid_EndingKnuckles, plcid_EndingSonic
		dc.b	plcid_EndingSonic, plcid_EndingSonic
		dc.b	plcid_EndingSonic, plcid_EndingSonic
		even

; These subroutines add and subtract shades from the palette and cap each parameter to prevent overflow

ShiftPaletteUp:
	@loop:

	@redblack:
		move.w	(a1),d4
		andi.w	#$E,d4
		add.b	d0,d4
		cmpi.b	#$E,d4
		bls.s	@greenblack
		moveq	#$E,d4

	@greenblack:
		move.w	(a1),d5
		andi.w	#$E0,d5
		add.w	d1,d5
		cmpi.w	#$E0,d5
		bls.s	@blueblack
		moveq	#$E0,d5

	@blueblack:
		add.b	d5,d4
		move.w	(a1),d5
		andi.w	#$E00,d5
		add.w	d2,d5
		cmpi.w	#$E00,d5
		bls.s	@gtfo
		move.w	#$E00,d5

	@gtfo:
		add.w	d5,d4
		move.w	d4,(a1)
		adda.w	#2,a1   ; Advance in the address
		dbf		d3,@loop ; Loop
		rts


ShiftPaletteDown:
	@loop:

	@redblack:
		move.w	(a1),d4
		andi.w	#$E,d4
		sub.b	d0,d4 ; Add the desired color shift to the palette
		bcc.s	@greenblack
		moveq	#0,d4

	@greenblack:
		move.w	(a1),d5
		andi.w	#$E0,d5
		sub.w	d1,d5 ; Add the desired color shift to the palette
		bcc.s	@blueblack
		moveq	#0,d5

	@blueblack:
		add.b	d5,d4
		move.w	(a1),d5
		andi.w	#$E00,d5
		sub.w	d2,d5 ; Add the desired color shift to the palette
		bcc.s	@gtfo
		moveq	#0,d5

	@gtfo:
		add.w	d5,d4
		move.w	d4,(a1)
		adda.w	#2,a1   ; Advance in the address
		dbf		d3,@loop ; Loop
		rts

LoadPlayerPal:
		moveq	#0,d0
		move.b	(v_character).w,d0
		move.b	@palLUT(pc,d0.w),d0
		rts

	@palLUT:
		dc.b	palid_Sonic, palid_Tails, palid_Knuckles, palid_Kyuko, palid_Metal, palid_Mighty, palid_Amy, palid_LegacySonic

LoadPlayerObject:
		move.b	#id_SpindashDust,(v_dust).w
		move.b	#id_SonicPlayer,(v_player).w ; load Sonic object
		clr.w	(v_debuguse).w	; VC: Fix invalid sprite at the first frame of a level (this did not work)
		tst.b	(v_character).w
		bne.s	@tailsCheck
		move.b	#id_Abbey,(v_followobject).w	; load Abbey object
		bra.s	@done
	@tailsCheck:
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@done
		addi.w	#4,(v_player+obY).w
	@done:
		rts

LoadPlayerLifeIcons:
		moveq	#0,d0
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.s	@cont
		move.b	(v_character).w,d0
		move.b	@lifeicons(pc,d0.w),d0
		jmp		AddPLC

	@cont:
		move.b	#plcid_NoLife,d0
		jmp		AddPLC

	@lifeicons:
		dc.b	plcid_SonicLife,plcid_TailsLife,plcid_KnucklesLife,plcid_KyukoLife,plcid_MetalLife,plcid_MightyLife,plcid_AmyLife,plcid_LegacyLife

LoadContinueScreenChars:	; TODO: add Mighty, Amy, and Legacy
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@contscrcha(pc,d0.w),a0
		jsr		NemDec
		locVRAM	$AA20
		rts

	@contscrcha:
		dc.l	Nem_ContSonic,Nem_ContTails,Nem_ContKnuckles,Nem_ContSonic,Nem_ContMetal,Nem_ContSonic,Nem_ContSonic,Nem_ContSonic

LoadContinueIcons:	; TODO: add Mighty, Amy, and Legacy
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@contico(pc,d0.w),a0
		jsr		NemDec
		moveq	#10,d1
		rts

	@contico:
		dc.l	Nem_MiniSonic,Nem_MiniTails,Nem_MiniKnuckles,Nem_MiniSonic,Nem_MiniMetal,Nem_MiniSonic,Nem_MiniSonic,Nem_MiniSonic

ContScrMaps:	; Metal uses Sonic's, because they're so damn similar. Also, add Mighty, Amy, and maybe Legacy.

		move.w	a0,-(sp)
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	@mapLUT(pc,d0.w),obMap(a0)
		move.w	(sp)+,a0
		rts

	@mapLUT:
		dc.l	Map_ContScr, Map_ContScrT, Map_ContScrK, Map_ContScr, Map_ContScr, Map_ContScr, Map_ContScr, Map_ContScr
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

SonicPlayer:
; TODO: write special stage player code after finishing concept
;		cmpi.b	#id_Special,(v_gamemode).w	; special stage?
;		bne.s	@notspecial
;		jmp		PlayerSpecial	; jump to SS player code
;	@notspecial:
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@playerLUT(pc,d0.w),a1
		jmp		(a1)

	@playerLUT:
		dc.l	@cont,TailsPlayer,KnucklesPlayer,KyukoPlayer,MetalPlayer,MightyPlayer,AmyPlayer,LegacyPlayer

	@cont:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Sonic_Normal	; if not, branch
		jmp		(DebugMode).l
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp		Sonic_Index(pc,d1.w)
; ===========================================================================
Sonic_Index:
		dc.w	Sonic_Main-Sonic_Index
		dc.w	Sonic_Control-Sonic_Index
		dc.w	Player_Hurt-Sonic_Index
		dc.w	Player_Death-Sonic_Index
		dc.w	Player_ResetLevel-Sonic_Index
		dc.w	Player_Drowned-Sonic_Index
; ===========================================================================

Sonic_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		jsr		ResetHeight
		move.l	#Map_Sonic,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#$600,(v_plrspeedmax).w ; Sonic's top speed
		move.w	#$C,(v_plrspeedacc).w ; Sonic's acceleration
		move.w	#$80,(v_plrspeeddec).w ; Sonic's deceleration

Sonic_Control:	; Routine 2
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	loc_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	loc_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================
; This entire fucking chain is really really dumb. It might work, but *I hate it.*
loc_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	loc_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

loc_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	loc_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr		Sonic_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Player_Display
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water
		bsr.w	Player_Super
		move.b	(v_anglebuffer).w,obNextTilt(a0)
		move.b	(v_anglebuffer+2).w,obTilt(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		tst.b	obAnim(a0)
		bne.s	loc_12CA6
		move.b	obNextAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(f_lockmulti).w
		bmi.s	loc_12CB6
		jsr		(ReactToItem).l

loc_12CB6:

		bsr.w	Sonic_LoadGfx
		rts
; ===========================================================================
Sonic_Modes:
		dc.w	Sonic_MdNormal-Sonic_Modes
		dc.w	Sonic_MdAir-Sonic_Modes
		dc.w	Sonic_MdRoll-Sonic_Modes
		dc.w	Sonic_MdJump-Sonic_Modes
; ===========================================================================

		include	"Objects/Player/Universal/Player Display.asm"
		include	"Objects/Player/Universal/Player RecordPosition.asm"
		include	"Objects/Player/Universal/Player Water.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_MdNormal:
;		bsr.w	Metal_Peelout	; For testing mach speed sprites.
		bsr.w	Player_CheckSpindash
		bsr.w	Player_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Player_Roll
		bsr.w	Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Sonic_MdAir:	; Spring, walking off a platform...
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
        cmp.w   #$FC8,obVelY(a0)   ; check if player's Y speed is lower than this value
        ble.s   @skipline       ; if yes, branch
        move.w  #$FC8,obVelY(a0)    ; alter player's Y speed
    
	@skipline:		
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12E5C
		subi.w	#$28,obVelY(a0)

loc_12E5C:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		rts
; ===========================================================================

Sonic_MdRoll:
		tst.b	obPinball(a0)
		bne.s	@cont
		bsr.w	Player_Jump
	@cont:
		bsr.w	Player_RollRepel
		bsr.w	Player_RollSpeed
		bsr.w	Player_LevelBound
		jsr		(SpeedToPos).l
		jsr		Player_AnglePos
		bsr.w	Player_SlopeRepel
		rts
; ===========================================================================

Sonic_MdJump:	; Actually jumping.
		cmpi.b	#id_Spring,obAnim(a0)
		bne.s	@cont
		tst.b	obVelY(a0)
		blt.s	@cont
		move.b	#id_Fall,obAnim(a0)
	@cont:
		tst.b	obSpindashCounter(a0)
		beq.s	@dontClear
		clr.b	obSpindash(a0)
	@dontClear:
		bsr.w	Player_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12EA6
		subi.w	#$28,obVelY(a0)

loc_12EA6:
		bsr.w	Player_JumpAngle
		bsr.w	Player_Floor
		bsr.w	Sonic_ReleaseDropDash
		rts

		include	"Objects/Player/Universal/Player Move.asm"
		include	"Objects/Player/Universal/Player RollSpeed.asm"
		include	"Objects/Player/Universal/Player JumpDirection.asm"
		include	"Objects/Player/Universal/Player LevelBound.asm"
		include	"Objects/Player/Universal/Player Roll.asm"
		include	"Objects/Player/Universal/Player Jump.asm"
		include	"Objects/Player/Sonic DropDash.asm"
		include	"Objects/Player/Sonic DropDashRelease.asm"
		include	"Objects/Player/Universal/Player Spindash.asm"
		include	"Objects/Player/Universal/Player JumpHeight.asm"
		include	"Objects/Player/Universal/Player SlopeResist.asm"
		include	"Objects/Player/Universal/Player RollRepel.asm"
		include	"Objects/Player/Universal/Player SlopeRepel.asm"
		include	"Objects/Player/Universal/Player JumpAngle.asm"
		include	"Objects/Player/Universal/Player Floor.asm"
		include	"Objects/Player/Mighty WallJump.asm"
		include	"Objects/Player/Mighty HammerDrop.asm"
		include	"Objects/Player/Universal/Player ResetOnFloor.asm"
		include	"Objects/Player/Universal/Player (part 2).asm"
		include	"Objects/Player/Universal/Player Drowns.asm"
		include	"Objects/Player/Sonic Animate.asm"
		include	"Objects/Player/Sonic LoadGfx.asm"

		include	"Objects/0A Drowning Countdown.asm"

		include	"Objects/Player/Tails and 9A his tails.asm"
		include	"Objects/Player/Knuckles.asm"
		include	"Objects/Player/Kyuko.asm"
		include	"Objects/Player/Metal Sonic.asm"
		include	"Objects/Player/Mighty and 90 Hammer Drop dust.asm"
		include	"Objects/Player/Amy and 99 Hearts.asm"
Map_Hearts:	include	"Mappings/Hearts.asm"
		include	"Objects/Player/Legacy Sonic.asm"

		include	"Objects/Screen-Space/9B Petals and Snow.asm"
Map_Petals:	include	"Mappings/Falling Petals.asm"
Map_Snow:	include	"Mappings/Falling Snow.asm"
; ---------------------------------------------------------------------------
; Subroutine to	play music for LZ/SBZ3 after a countdown
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ResumeMusic:
		cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
		bhi.s	@over12		; if yes, branch
		bsr.s	ResumeMusic2

	@over12:
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_objspace+$340+$32).w
		rts
; End of function ResumeMusic

; This resumes it in general... mostly taken from bosses and cross-compared with Sonic 2.
; Note that this IS NOT called in any form during the 1-up sound.
ResumeMusic2:
		tst.b	(v_super).w
		beq.s	@resume_invinc
		music	mus_SuperTheme
		bra.s	@resume_play

	@resume_invinc:
		tst.b	(v_invinc).w
		beq.s	@resume_normal
		tst.b	(v_player+invtime).w
		beq.s	@resume_normal
		music	mus_Invincibility
		bra.s	@resume_play

	@resume_normal:
		jmp		ResetZoneMusic

	@resume_play:
		move.b	d0,mQueue+1.w	; play music
		rts

; ===========================================================================

		include	"Animations/Drowning Countdown.asm"
Map_Drown:	include	"Mappings/Drowning Countdown.asm"

		include	"Objects/Powerups/38, 96, 98 Shields.asm"
Ani_ElementalShields:	include "Animations/Elemental Shields.asm"
Map_Shield:	include	"Mappings/Shield.asm"
DPLC_Shield:	include	"DPLCs/Shield.asm"
Map_BubbleShield:	include "Mappings/Bubble Shield.asm"
DPLC_BubbleShield:	include "DPLCs/Bubble Shield.asm"
Map_FireShield:	include "Mappings/Fire Shield.asm"
DPLC_FireShield:include "DPLCs/Fire Shield.asm"
Map_LightningShield:	include "Mappings/Lightning Shield.asm"
DPLC_LightningShield:	include "DPLCs/Lightning Shield.asm"
Map_GoldShield:	include "Mappings/Gold Shield.asm"
DPLC_GoldShield:include "DPLCs/Gold Shield.asm"

		include	"Objects/Powerups/9C Spring Shoes.asm"
Map_BGZLantern:	include "Mappings/BGZ Lanterns.asm"

		include	"Objects/02 Floating Lantern.asm"
		include	"Animations/Spring Shoes.asm"
Map_SpringShoes:	include	"Mappings/SpringShoes.asm"
		include	"Objects/Player/8F Abbey.asm"

		include	"Objects/Invisible/03 Collision Switcher.asm"
Map_PathSwapper:	include "Mappings/Collision Switcher.asm"
		include "Objects/Invisible/04 Pinball Marker.asm"

		include	"Objects/Player/Universal/9D Spindash Dust.asm"
Map_SpindashDust:	include "Mappings/Spindash Dust.asm"
DPLC_SpindashDust:	include "DPLCs/Spindash Dust.asm"

		include	"Animations/Shield.asm"
		include	"Animations/Special Stage Entry (Unused).asm"
		include	"Animations/Gold Shield.asm"
Map_Vanish:	include	"Mappings/Special Stage Entry (Unused).asm"

		include	"Objects/Player/Universal/Player AnglePos.asm"

		include	"Objects/Subroutines/sub FindNearestTile.asm"

LoadAngleMap:
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@s2angle
		cmpi.b	#id_HPZ,(v_zone).w
		beq.s	@s2angle
		cmpi.b	#id_BGZ,(v_zone).w
		bne.s	@s1angle
	@s2angle:
		cmpi.b	#3,(v_act).w	; Act 4? (Legacy BGZ!)
		beq.s	@s1angle
		lea		(AngleMapS2).l,a2
		rts
	@s1angle:
		lea		(AngleMap).l,a2		; MJ: load angle map data to a2
		rts

LoadColArray1:
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@s2col1
		cmpi.b	#id_HPZ,(v_zone).w
		beq.s	@s2col1
		cmpi.b	#id_BGZ,(v_zone).w
		bne.s	@s1col1
	@s2col1:
		cmpi.b	#3,(v_act).w	; Act 4? (Legacy BGZ!)
		beq.s	@s1col1
		lea		(CollArray1S2).l,a2
		rts
	@s1col1:
		lea		(CollArray1).l,a2
		rts

LoadColArray2:
		cmpi.b	#id_MHZ,(v_zone).w
		beq.s	@s2col2
		cmpi.b	#id_HPZ,(v_zone).w
		beq.s	@s2col2
		cmpi.b	#id_BGZ,(v_zone).w
		bne.s	@s1col2
	@s2col2:
		cmpi.b	#3,(v_act).w	; Act 4? (Legacy BGZ!)
		beq.s	@s1col2
		lea		(CollArray2S2).l,a2
		rts
	@s1col2:
		lea		(CollArray2).l,a2
		rts

		include	"Objects/Subroutines/sub Child Objects.asm"
		include	"Objects/Subroutines/sub FindFloor.asm"
		include	"Objects/Subroutines/sub FindWall.asm"
		include	"Objects/Subroutines/sub ScreenShake.asm"

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_WalkSpeed:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer+2).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_14D1A
		move.b	d1,d0
		bpl.s	loc_14D14
		subq.b	#1,d0

loc_14D14:
		addi.b	#$20,d0
		bra.s	loc_14D24
; ===========================================================================

loc_14D1A:
		move.b	d1,d0
		bpl.s	loc_14D20
		addq.b	#1,d0

loc_14D20:
		addi.b	#$1F,d0

loc_14D24:
		andi.b	#$C0,d0
		beq.w	loc_14DF0
		cmpi.b	#$80,d0
		beq.w	loc_14F7C
		andi.b	#$38,d1
		bne.s	loc_14D3C
		addq.w	#8,d2

loc_14D3C:
		cmpi.b	#$40,d0
		beq.w	loc_1504A
		bra.w	loc_14EBC

; End of function Player_WalkSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14D48:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer+2).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_14FD6
		cmpi.b	#$80,d0
		beq.w	Player_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	sub_14E50

; End of function sub_14D48

; ---------------------------------------------------------------------------
; Subroutine to	make Player land	on the floor after jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_HitFloor:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_top_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea		(v_anglebuffer+2).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#0,d2

loc_14DD0:
		move.b	(v_anglebuffer+2).w,d3
		cmp.w	d0,d1
		ble.s	loc_14DDE
		move.b	(v_anglebuffer).w,d3
		exg		d0,d1

loc_14DDE:
		btst	#0,d3
		beq.s	locret_14DE6
		move.b	d2,d3

locret_14DE6:
		rts

; End of function Player_HitFloor

; ===========================================================================
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14DF0:
		addi.w	#$A,d2
		lea		(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.b	#0,d2

loc_14E0A:
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14E16
		move.b	d2,d3

locret_14E16:
		rts

		include	"Objects/Subroutines/sub ObjFloorDist.asm"
		include	"Objects/Subroutines/sub ObjWaterDist.asm"


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14E50:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea		(v_anglebuffer+2).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_14DD0

; End of function sub_14E50


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14EB4:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14EBC:
		addi.w	#$A,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.b	#-$40,d2
		bra.w	loc_14E0A

; End of function sub_14EB4

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea		(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindWall	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14F06
		move.b	#-$40,d3

locret_14F06:
		rts

; End of function ObjHitWallRight

; ---------------------------------------------------------------------------
; Subroutine preventing	Player from running on walls and	ceilings when he
; touches them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_DontRunOnWalls:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea		(v_anglebuffer+2).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_14DD0
; End of function Player_DontRunOnWalls

; ===========================================================================
; ...Um?
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14F7C:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.b	#-$80,d2
		bra.w	loc_14E0A

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitCeiling:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindFloor	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14FD4
		move.b	#-$80,d3

locret_14FD4:
		rts
; End of function ObjHitCeiling

; ===========================================================================

loc_14FD6:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea		(v_anglebuffer+2).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_14DD0

; ---------------------------------------------------------------------------
; Subroutine to	stop Player when	he jumps at a wall
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_HitWall:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_1504A:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.b	#$40,d2
		bra.w	loc_14E0A
; End of function Player_HitWall

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
	; Engine bug: colliding with left walls is erratic with this function.
	; The cause is this: a missing instruction to flip collision on the found
	; 16x16 block; this one: ; Uncommented.
		eori.w	#$F,d3
		lea		(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindWall	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_15098
		move.b	#$40,d3

locret_15098:
		rts
; End of function ObjHitWallLeft

; ===========================================================================

		include	"Objects/66 Rotating Junction.asm"
Map_Jun:	include	"Mappings/Rotating Junction.asm"
		include	"Objects/67 Running Disc.asm"
Map_Disc:	include	"Mappings/Running Disc.asm"
		include	"Objects/68 Conveyor Belt.asm"
		include	"Objects/69 SBZ Spinning Platforms.asm"
		include	"Animations/SBZ Spinning Platforms.asm"
Map_Trap:	include	"Mappings/Trapdoor.asm"
Map_Spin:	include	"Mappings/SBZ Spinning Platforms.asm"
		include	"Objects/Hazards/6A Saws and Pizza Cutters.asm"
Map_Saw:	include	"Mappings/Saws and Pizza Cutters.asm"
		include	"Objects/Hazards/6B SBZ Stomper and Door.asm"
Map_Stomp:	include	"Mappings/SBZ Stomper and Door.asm"
		include	"Objects/6C SBZ Vanishing Platforms.asm"
		include	"Animations/SBZ Vanishing Platforms.asm"
Map_VanP:	include	"Mappings/SBZ Vanishing Platforms.asm"
		include	"Objects/Hazards/6E Electrocuter.asm"
		include	"Animations/Electrocuter.asm"
Map_Elec:	include	"Mappings/Electrocuter.asm"
		include	"Objects/6F SBZ Spin Platform Conveyor.asm"
		include	"Animations/SBZ Spin Platform Conveyor.asm"

off_164A6:
		dc.w	word_164B2-off_164A6, word_164C6-off_164A6, word_164DA-off_164A6
		dc.w	word_164EE-off_164A6, word_16502-off_164A6, word_16516-off_164A6
word_164B2:	dc.w	$10, $E80,	$E14, $370, $EEF, $302,	$EEF, $340, $E14, $3AE
word_164C6:	dc.w	$10, $F80,	$F14, $2E0, $FEF, $272,	$FEF, $2B0, $F14, $31E
word_164DA:	dc.w	$10, $1080, $1014,	$270, $10EF, $202, $10EF, $240,	$1014, $2AE
word_164EE:	dc.w	$10, $F80,	$F14, $570, $FEF, $502,	$FEF, $540, $F14, $5AE
word_16502:	dc.w	$10, $1B80, $1B14,	$670, $1BEF, $602, $1BEF, $640,	$1B14, $6AE
word_16516:	dc.w	$10, $1C80, $1C14,	$5E0, $1CEF, $572, $1CEF, $5B0,	$1C14, $61E
; ===========================================================================

		include	"Objects/70 Girder Block.asm"
Map_Gird:	include	"Mappings/Girder Block.asm"
		include	"Objects/Invisible/72 Teleporter.asm"

		include	"Objects/Badniks/78 Caterkiller.asm"
		include	"Animations/Caterkiller.asm"
Map_Cat:	include	"Mappings/Caterkiller.asm"

		include	"Objects/79 Lamppost.asm"
Map_Lamp:	include	"Mappings/Lamppost.asm"
		include	"Objects/End of Level/7D Hidden Bonuses.asm"
Map_Bonus:	include	"Mappings/Hidden Bonuses.asm"

; ---------------------------------------------------------------------------
; Defeated boss	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossDefeated:
		move.b	(v_vbla_byte).w,d0
		andi.b	#7,d0
		bne.s	locret_178A2
		jsr		(FindFreeObj).l
		bne.s	locret_178A2
		move.b	#id_ExplosionBomb,0(a1)	; load explosion object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

locret_178A2:
		rts
; End of function BossDefeated

; ---------------------------------------------------------------------------
; Subroutine to	move a boss
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossMove:
		movem.w	obVelX(a0),d0/d2
		lsl.l	#8,d0
		add.l	d0,$30(a0)
		lsl.l	#8,d2
		add.l	d2,$38(a0)
		rts
; End of function BossMove

; ===========================================================================

		include	"Animations/Eggman.asm"
Map_Eggman:	include	"Mappings/Eggman.asm"
Map_BossItems:	include	"Mappings/Boss Items.asm"
		include	"Objects/Bosses/77 Boss - Labyrinth.asm"
		include	"Objects/Bosses/73 Boss - Marble.asm"
		include	"Objects/Bosses/74 MZ Boss Fire.asm"

		include	"Objects/Bosses/7A Boss - Star Light.asm"
		include	"Objects/Bosses/7B SLZ Boss Spikeball.asm"
Map_BSBall:	include	"Mappings/SLZ Boss Spikeball.asm"
		include	"Objects/Bosses/75 Boss - Spring Yard.asm"
		include	"Objects/Bosses/76 SYZ Boss Blocks.asm"
Map_BossBlock:	include	"Mappings/SYZ Boss Blocks.asm"

		include	"Objects/End of Level/82 Eggman - Scrap Brain 2.asm"
		include	"Animations/Eggman - Scrap Brain 2 & Final.asm"
Map_SEgg:	include	"Mappings/Eggman - Scrap Brain 2.asm"
		include	"Objects/End of Level/83 SBZ Eggman's Crumbling Floor.asm"
Map_FFloor:	include	"Mappings/SBZ Eggman's Crumbling Floor.asm"
		include	"Objects/Bosses/85 Boss - Final.asm"
		include	"Animations/FZ Eggman in Ship.asm"
Map_FZDamaged:	include	"Mappings/FZ Damaged Eggmobile.asm"
Map_FZLegs:	include	"Mappings/FZ Eggmobile Legs.asm"
		include	"Objects/Bosses/84 FZ Eggman's Cylinders.asm"
Map_EggCyl:	include	"Mappings/FZ Eggman's Cylinders.asm"
		include	"Objects/Bosses/86 FZ Plasma Ball Launcher.asm"
		include	"Animations/Plasma Ball Launcher.asm"
Map_PLaunch:	include	"Mappings/Plasma Ball Launcher.asm"
		include	"Animations/Plasma Balls.asm"
Map_Plasma:	include	"Mappings/Plasma Balls.asm"
		include	"Objects/End of Level/3E Prison Capsule.asm"
		include	"Objects/Powerups/8D Super Trails.asm"

		include	"Objects/Powerups/8E 0517Stars.asm"
Map_HyperStars:		include	"Mappings/Hyper Stars.asm"

		include	"Animations/Prison Capsule.asm"
Map_Pri:	include	"Mappings/Prison Capsule.asm"

		include	"Objects/Subroutines/sub ReactToItem.asm"

Map_FlapdoorH:	include	"Mappings/Horizontal Flapdoor.asm"
Map_FlapdoorV:	include	"Mappings/Vertical Flapdoor.asm"

		include	"Objects/Bosses/93 Boss - Blossom Gardens.asm"
Map_BossKyuko:		include	"Mappings/Boss Kyuko.asm"
DPLC_BossKyuko:		include	"DPLCs/Boss Kyuko.asm"
				include	"Animations/Boss Kyuko.asm"

		include	"Objects/Bosses/9E Boss - Melting Heights.asm"
		include	"Objects/Screen-Space/A2 Thats All Folks.asm"		
Map_SDURF:		include	"Mappings/SDURF.asm"
DPLC_SDURF:		include	"DPLCs/SDURF.asm"
; ---------------------------------------------------------------------------
; Subroutine to	show the special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_ShowLayout:
		bsr.w	SS_AniWallsRings
		bsr.w	SS_AniItems
		move.w	d5,-(sp)
		lea		(v_planebuffer_addr).w,a1
		move.b	(v_ssangle).w,d0
		jsr		(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(v_screenposx).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(v_screenposy).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$F,d7

loc_1B19E:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_1B1C0:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf		d6,loc_1B1C0

		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf		d7,loc_1B19E

		move.w	(sp)+,d5
		lea		(v_128x128).l,a0
		moveq	#0,d0
		move.w	(v_screenposy).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(v_screenposx).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea		(v_planebuffer_addr).w,a4
		move.w	#$F,d7

loc_1B20C:
		move.w	#$F,d6

loc_1B210:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_1B268
		cmpi.b	#$4E,d0
		bhi.s	loc_1B268
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		blo.s	loc_1B268
		cmpi.w	#$1D0,d3
		bhs.s	loc_1B268
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		blo.s	loc_1B268
		cmpi.w	#$170,d2
		bhs.s	loc_1B268
		lea		($FF4000).l,a5
		lsl.w	#3,d0
		lea		(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_1B268
		jsr		(sub_D762).l

loc_1B268:
		addq.w	#4,a4
		dbf		d6,loc_1B210

		lea		$70(a0),a0
		dbf		d7,loc_1B20C

		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	loc_1B288
		move.l	#0,(a2)
		rts
; ===========================================================================

loc_1B288:
		move.b	#0,-5(a2)
		rts
; End of function SS_ShowLayout

; ---------------------------------------------------------------------------
; Subroutine to	animate	walls and rings	in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniWallsRings:

		lea		($FF4005).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_1B2C8
		move.b	#7,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#3,(v_ani1_frame).w

loc_1B2C8:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_1B2E4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_1B2E4:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_1B326
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_1B326:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_1B350
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_1B350:
		lea		($FF4016).l,a1
		lea		(SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea		(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts
; End of function SS_AniWallsRings

SS_LoadWalls:
		moveq	#0,d0
		move.b	(v_ssangle).w,d0	; get the Special Stage angle
		lsr.b	#2,d0			; modify so it can be used as a frame ID
		andi.w	#$F,d0
		cmp.b	(v_ssangleprev).w,d0	; does the modified angle match the recorded value?
		beq.s	@return			; if so, branch

		lea		($C00000).l,a6
		lea		(Nem_SSWalls).l,a1	; load wall art
		move.w	d0,d1
		lsl.w	#8,d1
		add.w	d1,d1
		add.w	d1,a1

		locVRAM	$2840			; VRAM address

		move.w	#$F,d1			; number of 8x8 tiles
		jsr		LoadTiles
		move.b	d0,(v_ssangleprev).w	; record the modified angle for comparison

	@return:
		rts

; ===========================================================================
SS_WaRiVramSet:
		dc.w	$142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w	$142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w	$2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w	$2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w	$4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w	$4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w	$6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
		dc.w	$6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
; ---------------------------------------------------------------------------
; Subroutine to	remove items when you collect them in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_RemoveCollectedItem:
		lea		($FF4400).l,a2
		move.w	#$1F,d0

loc_1B4C4:
		tst.b	(a2)
		beq.s	locret_1B4CE
		addq.w	#8,a2
		dbf		d0,loc_1B4C4

locret_1B4CE:
		rts
; End of function SS_RemoveCollectedItem

; ---------------------------------------------------------------------------
; Subroutine to	animate	special	stage items when you touch them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniItems:
		lea		($FF4400).l,a0
		move.w	#$1F,d7

loc_1B4DA:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_1B4E8
		lsl.w	#2,d0
		movea.l	SS_AniIndex-4(pc,d0.w),a1
		jsr		(a1)

loc_1B4E8:
		addq.w	#8,a0

loc_1B4EA:
		dbf		d7,loc_1B4DA

		rts
; End of function SS_AniItems

; ===========================================================================
SS_AniIndex:
		dc.l	SS_AniRingSparks
		dc.l	SS_AniBumper
		dc.l	SS_Ani1Up
		dc.l	SS_AniReverse
		dc.l	SS_AniEmeraldSparks
		dc.l	SS_AniGlassBlock
; ===========================================================================

SS_AniRingSparks:
		subq.b	#1,2(a0)
		bpl.s	locret_1B530
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRingData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B530
		clr.l	(a0)
		clr.l	4(a0)

locret_1B530:
		rts
; ===========================================================================
SS_AniRingData:	dc.b	$42, $43, $44, $45, 0, 0
; ===========================================================================

SS_AniBumper:
		subq.b	#1,2(a0)
		bpl.s	locret_1B566
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniBumpData(pc,d0.w),d0
		bne.s	loc_1B564
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts
; ===========================================================================

loc_1B564:
		move.b	d0,(a1)

locret_1B566:
		rts
; ===========================================================================
SS_AniBumpData:	dc.b	$32, $33, $32, $33, 0, 0
; ===========================================================================

SS_Ani1Up:
		subq.b	#1,2(a0)
		bpl.s	locret_1B596
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_Ani1UpData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B596
		clr.l	(a0)
		clr.l	4(a0)

locret_1B596:
		rts
; ===========================================================================
SS_Ani1UpData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniReverse:
		subq.b	#1,2(a0)
		bpl.s	locret_1B5CC
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRevData(pc,d0.w),d0
		bne.s	loc_1B5CA
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts
; ===========================================================================

loc_1B5CA:
		move.b	d0,(a1)

locret_1B5CC:
		rts
; ===========================================================================
SS_AniRevData:	dc.b	$2B, $31, $2B, $31, 0, 0
; ===========================================================================

SS_AniEmeraldSparks:
		subq.b	#1,2(a0)
		bpl.s	locret_1B60C
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniEmerData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B60C
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,(v_objspace+obRoutine).w
		sfx		sfx_Goal	; play special stage GOAL	sound

locret_1B60C:
		rts
; ===========================================================================
SS_AniEmerData:	dc.b	$46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniGlassBlock:
		subq.b	#1,2(a0)
		bpl.s	locret_1B640
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniGlassData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B640
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1B640:
		rts
; ===========================================================================
SS_AniGlassData:dc.b	$4B, $4C, $4D, $4E, $4B, $4C, $4D,	$4E, 0,	0

; ---------------------------------------------------------------------------
; Subroutine to	load special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_Load:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0 ; load number of last special stage entered
		addq.b	#1,(v_lastspecial).w
		cmpi.b	#6,(v_lastspecial).w
		blo.s	SS_ChkEmldNum
		move.b	#0,(v_lastspecial).w ; reset if higher than 6

SS_ChkEmldNum:
		cmpi.b	#6,(v_emeralds).w ; do you have all emeralds?
		beq.s	SS_LoadData	; if yes, branch
		moveq	#0,d1
		move.b	(v_emeralds).w,d1
		subq.b	#1,d1
		blo.s	SS_LoadData
		lea		(v_emldlist).w,a3 ; check which emeralds you have

SS_ChkEmldLoop:
		cmp.b	(a3,d1.w),d0
		bne.s	SS_ChkEmldRepeat
		bra.s	SS_Load
; ===========================================================================

SS_ChkEmldRepeat:
		dbf		d1,SS_ChkEmldLoop

SS_LoadData:
		lsl.w	#2,d0
		jsr		LevelSizeLoad
;		lea		SS_StartLoc(pc,d0.w),a1
;		move.w	(a1)+,(v_player+obX).w
;		move.w	(a1)+,(v_player+obY).w
		jsr		ObjPosLoad
		move.b	#0,(Rings_manager_routine).w
		jsr		(RingsManager).l
		move.b	#1,(v_levelstarted).w
		st		(f_cameraenabled).w
;		jsr		(ExecuteObjects).l
;		jsr		(BuildSprites).l
		lea		($FF4000).l,a1
		move.w	#0,d0
		jsr		(EniDec).l
		lea		(v_128x128).l,a1
		move.w	#$FFF,d0

SS_ClrRAM3:
		clr.l	(a1)+
		dbf		d0,SS_ClrRAM3

		lea		($FF1020).l,a1
		lea		($FF4000).l,a0
		moveq	#$3F,d1

loc_1B6F6:
		moveq	#$3F,d2

loc_1B6F8:
		move.b	(a0)+,(a1)+
		dbf		d2,loc_1B6F8

		lea		SstLimit(a1),a1
		dbf		d1,loc_1B6F6

		lea		($FF4008).l,a1
		lea		(SS_MapIndex).l,a0
		moveq	#$4D,d1

loc_1B714:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf		d1,loc_1B714

		lea		($FF4400).l,a1
		move.w	#$3F,d1

loc_1B730:
		clr.l	(a1)+
		dbf		d1,loc_1B730

		rts
; End of function SS_Load

; ===========================================================================

SS_MapIndex:
		include	"Includes/Special Stage Mappings & VRAM Pointers.asm"

Map_SS_R:	include	"Mappings/SS R Block.asm"
Map_SS_Glass:	include	"Mappings/SS Glass Block.asm"
Map_SS_Up:	include	"Mappings/SS UP Block.asm"
Map_SS_Down:	include	"Mappings/SS DOWN Block.asm"
		include	"Mappings/SS Chaos Emeralds.asm"

		include	"Includes/AnimateLevelGfx.asm"

		include	"Objects/Screen-Space/HUD.asm"
Map_HUD:	include	"Mappings/HUD.asm"

; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(f_scorecount).w ; set score counter to update
		lea		(v_score).w,a3
		add.l	d0,(a3)
		move.l	#999999,d1
		cmp.l	(a3),d1 ; is score below 999999?
		bhi.s	@belowmax ; if yes, branch
		move.l	d1,(a3) ; reset score to 999999
	@belowmax:
		move.l	(a3),d0
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.s	@noextralife		; Fuck your extra lives, the player won't be using them anyway.
		cmp.l	(v_scorelife).w,d0 ; has Player got 50000+ points?
		blo.s	@noextralife ; if not, branch
		addi.l	#5000,(v_scorelife).w ; increase requirement by 50000
		addq.b	#1,(v_lives).w ; give extra life
		addq.b	#1,(f_lifecount).w
		music	mus_ExtraLife

@noextralife:
		rts
; End of function AddPoints

		include	"Includes/HUD_Update.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ContScrCounter:
		locVRAM	$DF80
		lea		(vdp_data_port).l,a6
		lea		(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea		(Art_Hud).l,a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		blo.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea		(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf		d6,ContScr_Loop	; repeat 1 more	time

		rts
; End of function ContScrCounter

; ===========================================================================

		include	"Includes/HUD (part 2).asm"

		include	"Objects/Player/Universal/DebugMode.asm"
		include	"Includes/DebugList.asm"
		include	"Includes/LevelHeaders.asm"
		include	"Includes/Pattern Load Cues.asm"

Nem_NTKLogo:	incbin	"art/nemesis/Neo Team Kyukyoku Logo.bin"	; Neo Team Kyukyoku logo
		even
Eni_NTKLogo:	incbin	"Tilemaps/Neo Team Kyukyoku Logo.bin" ; Neo Team Kyukyoku logo (mappings)
		even
Eni_Title:	incbin	"Tilemaps/Title Screen.bin" ; title screen foreground (mappings)
		even
Nem_TitleFg:	incbin	"art/nemesis/Title Screen Foreground.bin"
		even
; This one's so it isn't clouds for the first few frames.
Nem_MenuBG:	incbin	"art/nemesis/Menu Background.bin"
		even
Eni_MenuBG:	incbin	"Tilemaps/Menu Background.bin"
		even

; ---------------------------------------------------------------------------
; Mappings, DPLCs, & animations - Characters
; ---------------------------------------------------------------------------
Map_Abbey:			include	"Mappings/Abbey.asm"
DPLC_Abbey:			include	"DPLCs/Abbey.asm"
; Abbey doesn't use animations.

Map_Sonic:			include	"Mappings/Sonic.asm"
DPLC_Sonic:			include	"DPLCs/Sonic.asm"
Map_SuperSonic:		include	"Mappings/Super Sonic.asm"
DPLC_SuperSonic:	include	"DPLCs/Super Sonic.asm"
					include	"Animations/Sonic.asm"

Map_Tails:			include	"Mappings/Tails.asm"
DPLC_Tails:			include	"DPLCs/Tails.asm"
					include	"Animations/Tails.asm"

Map_TailsTails:		include	"Mappings/Tails's tails.asm"
DPLC_TailsTails:	include	"DPLCs/Tails's tails.asm"
					include	"Animations/Tails's tails.asm"

Map_Knuckles:		include	"Mappings/Knuckles.asm"
DPLC_Knuckles:		include	"DPLCs/Knuckles.asm"
					include	"Animations/Knuckles.asm"

Map_Kyuko:			include	"Mappings/Kyuko.asm"
DPLC_Kyuko:			include	"DPLCs/Kyuko.asm"
					include	"Animations/Kyuko.asm"

Map_Metal:			include	"Mappings/Metal Sonic.asm"
DPLC_Metal:			include	"DPLCs/Metal Sonic.asm"
					include	"Animations/Metal.asm"

Map_Mighty:			include	"Mappings/Mighty.asm"
DPLC_Mighty:		include	"DPLCs/Mighty.asm"
					include	"Animations/Mighty.asm"

Map_Amy:			include	"Mappings/Amy.asm"
DPLC_Amy:			include	"DPLCs/Amy.asm"
					include	"Animations/Amy.asm"

Map_Legacy:			include	"Mappings/Legacy Sonic.asm"
DPLC_Legacy:		include	"DPLCs/Legacy Sonic.asm"
Map_DarkLegacy:		include	"Mappings/Dark Legacy Sonic.asm"
DPLC_DarkLegacy:	include	"DPLCs/Dark Legacy Sonic.asm"
					include	"Animations/Legacy.asm"
; Sonic on the Neo Team Kyukyoku screen
Map_NTKSon:			include	"Mappings/NTKyu Logo Sonic.asm"
DPLC_NTKSon:		include	"DPLCs/NTKyu Logo Sonic.asm"

		even
Art_TChr:			incbin	"art/uncompressed/Title Screen Characters.bin"
		even

; I am in your walls.
Map_SSWalls:		include	"Mappings/SS Walls.asm"

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Nem_SSWalls:	incbin	"art/uncompressed/Special Walls.bin" ; special stage walls
		even
Eni_SSBg1:		incbin	"Tilemaps/SS Background 1.bin" ; special stage background (mappings)
		even
Nem_SSBgFish:	incbin	"art/nemesis/Special Birds & Fish.bin" ; special stage birds and fish background
		even
Eni_SSBg2:		incbin	"Tilemaps/SS Background 2.bin" ; special stage background (mappings)
		even
Nem_SSBgCloud:	incbin	"art/nemesis/Special Clouds.bin" ; special stage clouds background
		even
Nem_SSGOAL:		incbin	"art/nemesis/Special GOAL.bin" ; special stage GOAL block
		even
Nem_SSRBlock:	incbin	"art/nemesis/Special R.bin"	; special stage R block
		even
Nem_SS1UpBlock:	incbin	"art/nemesis/Special 1UP.bin" ; special stage 1UP block
		even
Nem_SSEmStars:	incbin	"art/nemesis/Special Emerald Twinkle.bin" ; special stage stars from a collected emerald
		even
Nem_SSRedWhite:	incbin	"art/nemesis/Special Red-White.bin" ; special stage red/white block
		even
Nem_SSZone1:	incbin	"art/nemesis/Special ZONE1.bin" ; special stage ZONE1 block
		even
Nem_SSZone2:	incbin	"art/nemesis/Special ZONE2.bin" ; ZONE2 block
		even
Nem_SSZone3:	incbin	"art/nemesis/Special ZONE3.bin" ; ZONE3 block
		even
Nem_SSZone4:	incbin	"art/nemesis/Special ZONE4.bin" ; ZONE4 block
		even
Nem_SSZone5:	incbin	"art/nemesis/Special ZONE5.bin" ; ZONE5 block
		even
Nem_SSZone6:	incbin	"art/nemesis/Special ZONE6.bin" ; ZONE6 block
		even
Nem_SSUpDown:	incbin	"art/nemesis/Special UP-DOWN.bin" ; special stage UP/DOWN block
		even
Nem_SSEmerald:	incbin	"art/nemesis/Special Emeralds.bin" ; special stage chaos emeralds
		even
Nem_SSGhost:	incbin	"art/nemesis/Special Ghost.bin" ; special stage ghost block
		even
Nem_SSWBlock:	incbin	"art/nemesis/Special W.bin"	; special stage W block
		even
Nem_SSGlass:	incbin	"art/nemesis/Special Glass.bin" ; special stage destroyable glass block
		even
Nem_ResultEm:	incbin	"art/nemesis/Special Result Emeralds.bin" ; chaos emeralds on special stage results screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - BGZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:		incbin	"art/nemesis/GHZ Flower Stalk.bin"
		even
Nem_GHZDoors:	incbin	"art/nemesis/GHZ Doors.bin"
		even
Nem_Swing:		incbin	"art/nemesis/GHZ Swinging Platform.bin"
		even
Nem_LBGZBridge:	incbin	"art/nemesis/GHZ Bridge.bin"
		even
Nem_MHZDeco:	incbin	"art/nemesis/MHZ Decorations.bin"
		even
Nem_GhzUnkBlock:incbin	"art/nemesis/Unused - GHZ Block.bin"
		even
Nem_Ball:		incbin	"art/nemesis/GHZ Giant Ball.bin"
		even
Nem_Spikes:		incbin	"art/nemesis/Spikes.bin"
		even
Nem_BambSpikes:	incbin	"art/nemesis/Bamboo Spikes.bin"
		even
Nem_IceSpikes:	incbin	"art/nemesis/Ice Spikes.bin"
		even
Nem_BGZStatues:	incbin	"art/nemesis/BGZ Statues.bin"
		even
Nem_BGZLantern:	incbin	"art/nemesis/BGZ Lantern.bin"
		even
Nem_LBGZRock:	incbin	"art/nemesis/LBGZ Rock.bin"
		even
Nem_GHZSmaWall:	incbin	"art/nemesis/GHZ Breakable Wall.bin"
		even
Nem_MHZSmaWall:	incbin	"art/nemesis/MHZ Breakable Wall.bin"
		even
Nem_BambooBoard:incbin	"art/nemesis/Bamboo Pole Springboard.bin"
		even
Nem_CDFlapdoor:	incbin	"art/nemesis/CD Flapdoor.bin"
		even
Nem_MHZBlocks:	incbin	"art/nemesis/MHZ Ice Blocks.bin"
		even
Nem_Petals:		incbin	"art/nemesis/Falling Petals.bin"
		even
Nem_Snow:		incbin	"art/nemesis/Falling Snow.bin"
		even
Nem_BGZBlock:	incbin	"art/nemesis/BGZ Blocks.bin"
		even
Nem_HPZBlock:	incbin	"art/nemesis/HPZ Blocks.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_Water:		incbin	"art/nemesis/LZ Water Surface.bin"
		even
Nem_GenWater:	incbin	"art/nemesis/Generic Water Surface.bin"
		even
Nem_Splash:		incbin	"art/nemesis/LZ Water & Splashes.bin"
		even
Nem_LzSpikeBall:incbin	"art/nemesis/LZ Spiked Ball & Chain.bin"
		even
Nem_FlapDoor:	incbin	"art/nemesis/LZ Flapping Door.bin"
		even
Nem_Bubbles:	incbin	"art/nemesis/Bubbles.bin"
		even
Nem_BubbleGen:	incbin	"art/nemesis/Bubble Generator.bin"
		even
Nem_LzBlock3:	incbin	"art/nemesis/LZ 32x16 Block.bin"
		even
Nem_LzDoor1:	incbin	"art/nemesis/LZ Vertical Door.bin"
		even
Nem_Harpoon:	incbin	"art/nemesis/LZ Harpoon.bin"
		even
Nem_LzPole:		incbin	"art/nemesis/LZ Breakable Pole.bin"
		even
Nem_LzDoor2:	incbin	"art/nemesis/LZ Horizontal Door.bin"
		even
Nem_LzWheel:	incbin	"art/nemesis/LZ Wheel.bin"
		even
Nem_Gargoyle:	incbin	"art/nemesis/LZ Gargoyle & Fireball.bin"
		even
Nem_LzBlock2:	incbin	"art/nemesis/LZ Blocks.bin"
		even
Nem_LzPlatfm:	incbin	"art/nemesis/LZ Rising Platform.bin"
		even
Nem_Cork:		incbin	"art/nemesis/LZ Cork.bin"
		even
Nem_LzBlock1:	incbin	"art/nemesis/LZ 32x32 Block.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	incbin	"art/nemesis/MZ Metal Blocks.bin"
		even
Nem_MzSwitch:	incbin	"art/nemesis/MZ Switch.bin"
		even
Nem_MzGlass:	incbin	"art/nemesis/MZ Green Glass Block.bin"
		even
Nem_UnkGrass:	incbin	"art/nemesis/Unused - Grass.bin"
		even
Nem_MzFire:		incbin	"art/nemesis/Fireballs.bin"
		even
Nem_Lava:		incbin	"art/nemesis/MZ Lava.bin"
		even
Nem_MzBlock:	incbin	"art/nemesis/MZ Green Pushable Block.bin"
		even
Nem_MzUnkBlock:	incbin	"art/nemesis/Unused - MZ Background.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:		incbin	"art/nemesis/SLZ Seesaw.bin"
		even
Nem_SlzSpike:	incbin	"art/nemesis/SLZ Little Spikeball.bin"
		even
Nem_Fan:		incbin	"art/nemesis/SLZ Fan.bin"
		even
Nem_SlzWall:	incbin	"art/nemesis/SLZ Breakable Wall.bin"
		even
Nem_Pylon:		incbin	"art/nemesis/SLZ Pylon.bin"
		even
Nem_SlzSwing:	incbin	"art/nemesis/SLZ Swinging Platform.bin"
		even
Nem_SlzBlock:	incbin	"art/nemesis/SLZ 32x32 Block.bin"
		even
Nem_SlzCannon:	incbin	"art/nemesis/SLZ Cannon.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:		incbin	"art/nemesis/SYZ Bumper.bin"
		even
Nem_SyzSpike2:	incbin	"art/nemesis/SYZ Small Spikeball.bin"
		even
Nem_LzSwitch:	incbin	"art/nemesis/Switch.bin"
		even
Nem_SyzSpike1:	incbin	"art/nemesis/SYZ Large Spikeball.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
Nem_SbzWheel1:	incbin	"art/nemesis/SBZ Running Disc.bin"
		even
Nem_SbzWheel2:	incbin	"art/nemesis/SBZ Junction Wheel.bin"
		even
Nem_Cutter:		incbin	"art/nemesis/SBZ Pizza Cutter.bin"
		even
Nem_Stomper:	incbin	"art/nemesis/SBZ Stomper.bin"
		even
Nem_SpinPform:	incbin	"art/nemesis/SBZ Spinning Platform.bin"
		even
Nem_TrapDoor:	incbin	"art/nemesis/SBZ Trapdoor.bin"
		even
Nem_SbzFloor:	incbin	"art/nemesis/SBZ Collapsing Floor.bin"
		even
Nem_Electric:	incbin	"art/nemesis/SBZ Electrocuter.bin"
		even
Nem_SbzBlock:	incbin	"art/nemesis/SBZ Vanishing Block.bin"
		even
Nem_FlamePipe:	incbin	"art/nemesis/SBZ Flaming Pipe.bin"
		even
Nem_SbzDoor1:	incbin	"art/nemesis/SBZ Small Vertical Door.bin"
		even
Nem_SlideFloor:	incbin	"art/nemesis/SBZ Sliding Floor Trap.bin"
		even
Nem_SbzDoor2:	incbin	"art/nemesis/SBZ Large Horizontal Door.bin"
		even
Nem_Girder:		incbin	"art/nemesis/SBZ Crushing Girder.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	incbin	"art/nemesis/Enemy Ball Hog.bin"
		even
Nem_Crabmeat:	incbin	"art/nemesis/Enemy Crabmeat.bin"
		even
Nem_Buzz:		incbin	"art/nemesis/Enemy Buzz Bomber.bin"
		even
Nem_Mosqui:		incbin	"art/nemesis/Enemy Mosqui.bin"
		even
Nem_UnkExplode:	incbin	"art/nemesis/Unused - Explosion.bin"
		even
Nem_Burrobot:	incbin	"art/nemesis/Enemy Burrobot.bin"
		even
Nem_Chopper:	incbin	"art/nemesis/Enemy Chopper.bin"
		even
Nem_Jaws:		incbin	"art/nemesis/Enemy Jaws.bin"
		even
Nem_Roller:		incbin	"art/nemesis/Enemy Roller.bin"
		even
Nem_Motobug:	incbin	"art/nemesis/Enemy Motobug.bin"
		even
Nem_Gameroid:	incbin	"art/nemesis/Enemy Gameroid.bin"
		even
Nem_Newtron:	incbin	"art/nemesis/Enemy Newtron.bin"
		even
Nem_Yadrin:		incbin	"art/nemesis/Enemy Yadrin.bin"
		even
Nem_Basaran:	incbin	"art/nemesis/Enemy Basaran.bin"
		even
Nem_Splats:		incbin	"art/nemesis/Enemy Splats.bin"
		even
Nem_Bomb:		incbin	"art/nemesis/Enemy Bomb.bin"
		even
Nem_Orbinaut:	incbin	"art/nemesis/Enemy Orbinaut.bin"
		even
Nem_Cater:		incbin	"art/nemesis/Enemy Caterkiller.bin"
		even
Nem_Snowrex:	incbin	"art/nemesis/Enemy Snowrex.bin"
		even
Nem_SnowTulipon:incbin	"art/nemesis/Enemy Snow Tulipon.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_TitleCard:		incbin	"art/nemesis/Title Cards.bin"
		even
Kos_TitleCardBanner:incbin	"art/kosinski/Title Card Banner.bin"
		even
Nem_Hud:			incbin	"art/nemesis/HUD.bin"	; HUD (rings, time, score)
		even
Nem_LivesNone:		incbin	"art/nemesis/HUD - Life Counter Icon - Nothing.bin"
		even
Nem_Lives:			incbin	"art/nemesis/HUD - Life Counter Icon.bin"
		even
Nem_LivesT:			incbin	"art/nemesis/HUD - Life Counter Icon - Tails.bin"
		even
Nem_LivesK:			incbin	"art/nemesis/HUD - Life Counter Icon - Knuckles.bin"
		even
Nem_LivesKyu:		incbin	"art/nemesis/HUD - Life Counter Icon - Kyuko.bin"
		even
Nem_LivesMS:		incbin	"art/nemesis/HUD - Life Counter Icon - Metal Sonic.bin"
		even
Nem_LivesM:			incbin	"art/nemesis/HUD - Life Counter Icon - Mighty.bin"
		even
Nem_LivesA:			incbin	"art/nemesis/HUD - Life Counter Icon - Amy.bin"
		even
Nem_LivesLS:		incbin	"art/nemesis/HUD - Life Counter Icon - Legacy.bin"
		even
Nem_Ring:			incbin	"art/nemesis/Rings.bin"
		even
Nem_Monitors:		incbin	"art/nemesis/Monitors.bin"
		even
Nem_Explode:		incbin	"art/nemesis/Explosion.bin"
		even
Nem_ExplodeLant:	incbin	"art/nemesis/Lantern Explosion.bin"
		even
Nem_Points:			incbin	"art/nemesis/Points.bin"	; points from destroyed enemy or object
		even
Nem_GameOver:		incbin	"art/nemesis/Game Over.bin"	; game over / time over
		even
Nem_Spring:			incbin	"art/nemesis/Spring.bin"
		even
Nem_SpringD:		incbin	"art/nemesis/Diagonal Springs.bin"
		even
Nem_Lamp:			incbin	"art/nemesis/Lamppost.bin"
		even
Nem_Bonus:			incbin	"art/nemesis/Hidden Bonuses.bin" ; hidden bonuses at end of a level
		even
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:		incbin	"art/nemesis/Continue Screen Sonic.bin"
		even
Nem_MiniSonic:		incbin	"art/nemesis/Continue Screen Stuff.bin"
		even
Nem_ContTails:		incbin	"art/nemesis/Continue Screen Tails.bin"
		even
Nem_MiniTails:		incbin	"art/nemesis/Continue Screen Stuff - Tails.bin"
		even
Nem_ContKnuckles:	incbin	"art/nemesis/Continue Screen Knuckles.bin"
		even
Nem_MiniKnuckles:	incbin	"art/nemesis/Continue Screen Stuff - Knuckles.bin"
		even
Nem_ContMetal:		incbin	"art/nemesis/Continue Screen Metal.bin"
	even
Nem_MiniMetal:		incbin	"art/nemesis/Continue Screen Stuff - Metal.bin"
	even
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
; S1
Nem_Rabbit:		incbin	"art/nemesis/Animal Rabbit.bin"
		even
Nem_Chicken:	incbin	"art/nemesis/Animal Chicken.bin"
		even
Nem_BlackBird:	incbin	"art/nemesis/Animal Blackbird.bin"
		even
Nem_Seal:		incbin	"art/nemesis/Animal Seal.bin"
		even
Nem_Pig:		incbin	"art/nemesis/Animal Pig.bin"
		even
Nem_Flicky:		incbin	"art/nemesis/Animal Flicky.bin"
		even
Nem_Squirrel:	incbin	"art/nemesis/Animal Squirrel.bin"
		even
; S2
Nem_Eagle:		incbin	"art/nemesis/Animal Locky.bin"
		even
Nem_Bear:		incbin	"art/nemesis/Animal Becky.bin"
		even
Nem_Mouse:		incbin	"art/nemesis/Animal Micky.bin"
		even
; SCD
Nem_Dove:		incbin	"art/nemesis/Animal Vicky.bin"
		even
Nem_Sheep:		incbin	"art/nemesis/Animal Flocky.bin"
		even
; S3D
Nem_RedFlicky:	incbin	"art/nemesis/Animal Red Flicky.bin"
		even
; """Original"""
Nem_BlackBear:	incbin	"art/nemesis/Animal Bucky.bin"
		even
Nem_Panda:		incbin	"art/nemesis/Animal Packy.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
; Title Screen
Blk16_Title:incbin	"Level Data/16x16 Blocks/Title.bin"
		even
Kos_Title:	incbin	"art/kosinski/levels/Title.bin"	; Title primary patterns
		even
Blk128_Title:incbin	"Level Data/128x128 Chunks/Title.bin"
		even
; Legacy Blossom Gardens
Blk16_LBGZ:	incbin	"Level Data/16x16 Blocks/LBGZ.bin"
		even
Kos_LBGZ:	incbin	"art/kosinski/levels/Legacy BGZ.bin"	; LBGZ primary patterns
		even
Blk128_LBGZ:incbin	"Level Data/128x128 Chunks/LBGZ.bin"
		even
; Blossom Gardens
	; Act 1
Blk16_BGZ1:	incbin	"Level Data/16x16 Blocks/BGZ1.bin"
		even
Kos_BGZ1:	incbin	"art/kosinski/levels/BGZ1.bin"	; BGZ primary patterns
		even
Blk128_BGZ1:	incbin	"Level Data/128x128 Chunks/BGZ1.bin"
		even
	; Act 2
Blk16_BGZ2:	incbin	"Level Data/16x16 Blocks/BGZ2.bin"
		even
Kos_BGZ2:	incbin	"art/kosinski/levels/BGZ2.bin"	; BGZ primary patterns
		even
Blk128_BGZ2:incbin	"Level Data/128x128 Chunks/BGZ2.bin"
		even
	; Act 3
Blk16_BGZ3:	incbin	"Level Data/16x16 Blocks/BGZ3.bin"
		even
Kos_BGZ3:	incbin	"art/kosinski/levels/BGZ3.bin"	; BGZ primary patterns
		even
Blk128_BGZ3:	incbin	"Level Data/128x128 Chunks/BGZ3.bin"
		even
; Melting Heights
Blk16_MHZ:	incbin	"Level Data/16x16 Blocks/MHZ.bin"
		even
Kos_MHZ:	incbin	"art/kosinski/levels/MHZ.bin"	; MHZ primary patterns
		even
Blk128_MHZ:	incbin	"Level Data/128x128 Chunks/MHZ.bin"
		even
; Sunken Relic
Blk16_LZ:	incbin	"Level Data/16x16 Blocks/LZ.bin"
		even
Kos_LZ:		incbin	"art/kosinski/levels/LZ.bin"	; SRZ primary patterns
		even
Blk128_LZ:	incbin	"Level Data/128x128 Chunks/LZ.bin"
		even
; Ashen Temple
Blk16_MZ:	incbin	"Level Data/16x16 Blocks/MZ.bin"
		even
Kos_MZ:		incbin	"art/kosinski/levels/MZ.bin"	; ATZ primary patterns
		even
Blk128_MZ:	incbin	"Level Data/128x128 Chunks/MZ.bin"
		even
; Hoshi Metro
Blk16_SLZ:	incbin	"Level Data/16x16 Blocks/SLZ.bin"
		even
Kos_SLZ:	incbin	"art/kosinski/levels/SLZ.bin"	; HMZ primary patterns
		even
Blk128_SLZ:	incbin	"Level Data/128x128 Chunks/SLZ.bin"
		even
; Bumper City
Blk16_SYZ:	incbin	"Level Data/16x16 Blocks/SYZ.bin"
		even
Kos_SYZ:	incbin	"art/kosinski/levels/SYZ.bin"	; BCZ primary patterns
		even
Blk128_SYZ:	incbin	"Level Data/128x128 Chunks/SYZ.bin"
		even
; Badnik Blitz & Conflict Core
Blk16_SBZ:	incbin	"Level Data/16x16 Blocks/SBZ.bin"
		even
Kos_SBZ:	incbin	"art/kosinski/levels/SBZ.bin"	; BBZ primary patterns
		even
Blk128_SBZ:	incbin	"Level Data/128x128 Chunks/SBZ.bin"
		even
; Hidden Palace
Blk16_HPZ:	incbin	"Level Data/16x16 Blocks/HPZ.bin"
		even
Kos_HPZ:	incbin	"art/kosinski/levels/HPZ.bin"	; HPZ primary patterns
		even
Blk128_HPZ:	incbin	"Level Data/128x128 Chunks/HPZ.bin"
		even
; The Magnet
Blk16_TMZ:	incbin	"Level Data/16x16 Blocks/TMZ.bin"
		even
Kos_TMZ:	incbin	"art/kosinski/levels/TMZ.bin"	; TMZ primary patterns
		even
Blk128_TMZ:	incbin	"Level Data/128x128 Chunks/TMZ.bin"
		even
; Ending
Blk16_End:	incbin	"Level Data/16x16 Blocks/End.bin"
		even
Kos_End:	incbin	"art/kosinski/levels/Ending.bin"	; Ending primary patterns
		even
Blk128_End:	incbin	"Level Data/128x128 Chunks/End.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:		incbin	"art/nemesis/Boss - Main.bin"
		even
Nem_Weapons:	incbin	"art/nemesis/Boss - Weapons.bin"
		even
Nem_Prison:		incbin	"art/nemesis/Prison Capsule.bin"
		even
Nem_Sbz2Eggman:	incbin	"art/nemesis/Boss - Eggman in SBZ2 & FZ.bin"
		even
Nem_FzBoss:		incbin	"art/nemesis/Boss - Final Zone.bin"
		even
Nem_FzEggman:	incbin	"art/nemesis/Boss - Eggman after FZ Fight.bin"
		even
Nem_Exhaust:	incbin	"art/nemesis/Boss - Exhaust Flame.bin"
		even
Nem_EndEm:		incbin	"art/nemesis/Ending - Emeralds.bin"
		even
Nem_EndSonic:	incbin	"art/nemesis/Ending - Sonic.bin"
		even
Nem_EndTails:	incbin	"art/nemesis/Ending - Tails.bin"
		even
Nem_EndKnuckles:incbin	"art/nemesis/Ending - Knuckles.bin"
		even
Nem_TryAgain:	incbin	"art/nemesis/Ending - Try Again.bin"
		even
Kos_EndFlowers:	incbin	"art/kosinski/Flowers at Ending.bin" ; ending sequence animated flowers
		even
Nem_EndFlower:	incbin	"art/nemesis/Ending - Flowers.bin"
		even
Nem_CreditText:	incbin	"art/nemesis/Ending - Credits.bin"
		even
Nem_EndStH:		incbin	"art/nemesis/Ending - StH Logo.bin"
		even
Nem_Hearts:		incbin	"art/nemesis/Heart.bin"
		even
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:		incbin	"Level Data/Collision/Angle Map.bin"
		even
CollArray1:		incbin	"Level Data/Collision/Collision Array (Normal).bin"
		even
CollArray2:		incbin	"Level Data/Collision/Collision Array (Rotated).bin"
		even
AngleMapS2:		incbin	"Level Data/Collision/Angle Map S2.bin"
		even
CollArray1S2:	incbin	"Level Data/Collision/Collision Array (Normal) S2.bin"
		even
CollArray2S2:	incbin	"Level Data/Collision/Collision Array (Rotated) S2.bin"
		even
Col_BGZ1_1:		incbin	"Level Data/Collision/BGZ1-1.bin"	; BGZ1 index 1
		even
Col_BGZ1_2:		incbin	"Level Data/Collision/BGZ1-2.bin"	; BGZ1 index 2
		even
Col_BGZ2_1:		incbin	"Level Data/Collision/BGZ2-1.bin"	; BGZ2 index 1
		even
Col_BGZ2_2:		incbin	"Level Data/Collision/BGZ2-2.bin"	; BGZ2 index 2
		even
Col_BGZ3_1:		incbin	"Level Data/Collision/BGZ3-1.bin"	; BGZ3 index 1
		even
Col_BGZ3_2:		incbin	"Level Data/Collision/BGZ3-2.bin"	; BGZ3 index 2
		even
Col_LBGZ_1:		incbin	"Level Data/Collision/LBGZ-1.bin"	; LBGZ index 1
		even
Col_LBGZ_2:		incbin	"Level Data/Collision/LBGZ-2.bin"	; LBGZ index 2
		even
Col_LZ_1:		incbin	"Level Data/Collision/LZ-1.bin"	; LZ index 1
		even
Col_LZ_2:		incbin	"Level Data/Collision/LZ-2.bin"	; LZ index 2
		even
Col_MZ_1:		incbin	"Level Data/Collision/MZ-1.bin"	; MZ index 1
		even
Col_MZ_2:		incbin	"Level Data/Collision/MZ-2.bin"	; MZ index 2
		even
Col_SLZ_1:		incbin	"Level Data/Collision/SLZ-1.bin"	; SLZ index 1
		even
Col_SLZ_2:		incbin	"Level Data/Collision/SLZ-2.bin"	; SLZ index 2
		even
Col_SYZ_1:		incbin	"Level Data/Collision/SYZ-1.bin"	; SYZ index 1
		even
Col_SYZ_2:		incbin	"Level Data/Collision/SYZ-2.bin"	; SYZ index 2
		even
Col_SBZ_1:		incbin	"Level Data/Collision/SBZ-1.bin"	; SBZ index 1
		even
Col_SBZ_2:		incbin	"Level Data/Collision/SBZ-2.bin"	; SBZ index 2
		even
Col_End_1:		incbin	"Level Data/Collision/End-1.bin"	; Ending index 1, to prevent wacky shit from happening during that ending.
		even
Col_End_2:		incbin	"Level Data/Collision/End-2.bin"	; Ending index 2, for the same reason.
		even
Col_MHZ_1:  	incbin  "Level Data/Collision/MHZ-1.bin"
		even
Col_MHZ_2:  	incbin  "Level Data/Collision/MHZ-2.bin"
		even
Col_HPZ_1:  	incbin  "Level Data/Collision/HPZ-1.bin"
		even
Col_HPZ_2:  	incbin  "Level Data/Collision/HPZ-2.bin"
		even
Col_TMZ_1:  	incbin  "Level Data/Collision/TMZ-1.bin"
		even
Col_TMZ_2:  	incbin  "Level Data/Collision/TMZ-2.bin"
		even

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	; MJ: unused data and BG data have been stripped out
		dc.l	Level_BGZ1
		dc.l	Level_BGZ2
		dc.l	Level_BGZ3
		dc.l	Level_LBGZ
		dc.l	Level_LZ1
		dc.l	Level_LZ2
		dc.l	Level_LZ3
		dc.l	Level_SBZ3
		dc.l	Level_MZ1
		dc.l	Level_MZ2
		dc.l	Level_MZ3
		dc.l	Level_Null
		dc.l	Level_SLZ1
		dc.l	Level_SLZ2
		dc.l	Level_SLZ3
		dc.l	Level_Null
		dc.l	Level_SYZ1
		dc.l	Level_SYZ2
		dc.l	Level_SYZ3
		dc.l	Level_Null
		dc.l	Level_SBZ1
		dc.l	Level_SBZ2
		dc.l	Level_SBZ2
		dc.l	Level_Null
		dc.l	Level_MHZ1
		dc.l	Level_MHZ2
		dc.l	Level_MHZ3
		dc.l	Level_Null
		dc.l	Level_HPZ1
		dc.l	Level_HPZ2
		dc.l	Level_HPZ3
		dc.l	Level_Null
		dc.l	Level_TMZ1
		dc.l	Level_TMZ2
		dc.l	Level_TMZ3
		dc.l	Level_Null
		zonewarning	Level_Index,16
		dc.l	Level_End
		dc.l	Level_End
		dc.l	Level_Null
		dc.l	Level_Title

Level_Null:

Level_BGZ1:	incbin	"Level Data/Layouts/bgz1.bin"
		even
Level_BGZ2:	incbin	"Level Data/Layouts/bgz2.bin"
		even
Level_BGZ3:	incbin	"Level Data/Layouts/bgz3.bin"
		even
Level_LBGZ:	incbin	"Level Data/Layouts/lbgz.bin"
		even
Level_LZ1:	incbin	"Level Data/Layouts/lz1.bin"
		even
Level_LZ2:	incbin	"Level Data/Layouts/lz2.bin"
		even
Level_LZ3:	incbin	"Level Data/Layouts/lz3.bin"
		even
Level_SBZ3:	incbin	"Level Data/Layouts/sbz3.bin"
		even

Level_MZ1:	incbin	"Level Data/Layouts/mz1.bin"
		even
Level_MZ2:	incbin	"Level Data/Layouts/mz2.bin"
		even
Level_MZ3:	incbin	"Level Data/Layouts/mz3.bin"
		even

Level_SLZ1:	incbin	"Level Data/Layouts/slz1.bin"
		even
Level_SLZ2:	incbin	"Level Data/Layouts/slz2.bin"
		even
Level_SLZ3:	incbin	"Level Data/Layouts/slz3.bin"
		even

Level_SYZ1:	incbin	"Level Data/Layouts/syz1.bin"
		even
Level_SYZ2:	incbin	"Level Data/Layouts/syz2.bin"
		even
Level_SYZ3:	incbin	"Level Data/Layouts/syz3.bin"
		even

Level_SBZ1:	incbin	"Level Data/Layouts/sbz1.bin"
		even
Level_SBZ2:	incbin	"Level Data/Layouts/sbz2.bin"
		even

Level_End:	incbin	"Level Data/Layouts/ending.bin"
		even
Level_EndGood:	incbin	"Level Data/Layouts/ending_good.bin"
		even
Level_Title:	incbin	"Level Data/Layouts/title.bin"
		even

Level_MHZ1:	incbin	"Level Data/Layouts/MHZ1.bin"
		even
Level_MHZ2:	incbin	"Level Data/Layouts/MHZ2.bin"
		even
Level_MHZ3:	incbin	"Level Data/Layouts/MHZ3.bin"
		even

Level_HPZ1:	incbin	"Level Data/Layouts/HPZ1.bin"
		even
Level_HPZ2:	incbin	"Level Data/Layouts/HPZ2.bin"
		even
Level_HPZ3:	incbin	"Level Data/Layouts/HPZ3.bin"
		even

Level_TMZ1:	incbin	"Level Data/Layouts/TMZ1.bin"
		even
Level_TMZ2:	incbin	"Level Data/Layouts/TMZ2.bin"
		even
Level_TMZ3:	incbin	"Level Data/Layouts/TMZ3.bin"
		even

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:
		; GHZ
		dc.w	ObjPos_BGZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_BGZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_BGZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_LBGZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; LZ
		dc.w	ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; MZ
		dc.w	ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SLZ
		dc.w	ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SYZ
		dc.w	ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SYZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SYZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SBZ
		dc.w	ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_FZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; MHZ
		dc.w	ObjPos_MHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_MHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; HPZ
		dc.w	ObjPos_HPZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_HPZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_HPZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_HPZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; TMZ
		dc.w	ObjPos_TMZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_TMZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_TMZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_TMZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		zonewarning	ObjPos_Index,$10
		; Ending
		dc.w	ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w	ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; --- Put extra object data here. ---
ObjPosLZPlatform_Index:
		dc.w	ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w	ObjPos_LZ2pf1-ObjPos_Index, ObjPos_LZ2pf2-ObjPos_Index
		dc.w	ObjPos_LZ3pf1-ObjPos_Index, ObjPos_LZ3pf2-ObjPos_Index
		dc.w	ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
ObjPosSBZPlatform_Index:
		dc.w	ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.w	ObjPos_SBZ1pf3-ObjPos_Index, ObjPos_SBZ1pf4-ObjPos_Index
		dc.w	ObjPos_SBZ1pf5-ObjPos_Index, ObjPos_SBZ1pf6-ObjPos_Index
		dc.w	ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.b	$FF, $FF, 0, 0, 0,	0


ObjPos_BGZ1:	incbin	"Level Data/Object Positions/bgz1.bin"
		even
ObjPos_BGZ2:	incbin	"Level Data/Object Positions/bgz2.bin"
		even
ObjPos_BGZ3:	incbin	"Level Data/Object Positions/bgz3.bin"
		even
ObjPos_LBGZ:	incbin	"Level Data/Object Positions/lbgz.bin"
		even
ObjPos_LZ1:		incbin	"Level Data/Object Positions/lz1.bin"
		even
ObjPos_LZ2:		incbin	"Level Data/Object Positions/lz2.bin"
		even
ObjPos_LZ3:		incbin	"Level Data/Object Positions/lz3.bin"
		even
ObjPos_SBZ3:	incbin	"Level Data/Object Positions/sbz3.bin"
		even
ObjPos_LZ1pf1:	incbin	"Level Data/Object Positions/lz1pf1.bin"
		even
ObjPos_LZ1pf2:	incbin	"Level Data/Object Positions/lz1pf2.bin"
		even
ObjPos_LZ2pf1:	incbin	"Level Data/Object Positions/lz2pf1.bin"
		even
ObjPos_LZ2pf2:	incbin	"Level Data/Object Positions/lz2pf2.bin"
		even
ObjPos_LZ3pf1:	incbin	"Level Data/Object Positions/lz3pf1.bin"
		even
ObjPos_LZ3pf2:	incbin	"Level Data/Object Positions/lz3pf2.bin"
		even
ObjPos_MZ1:		incbin	"Level Data/Object Positions/mz1.bin"
		even
ObjPos_MZ2:		incbin	"Level Data/Object Positions/mz2.bin"
		even
ObjPos_MZ3:		incbin	"Level Data/Object Positions/mz3.bin"
		even
ObjPos_SLZ1:	incbin	"Level Data/Object Positions/slz1.bin"
		even
ObjPos_SLZ2:	incbin	"Level Data/Object Positions/slz2.bin"
		even
ObjPos_SLZ3:	incbin	"Level Data/Object Positions/slz3.bin"
		even
ObjPos_SYZ1:	incbin	"Level Data/Object Positions/syz1.bin"
		even
ObjPos_SYZ2:	incbin	"Level Data/Object Positions/syz2.bin"
		even
ObjPos_SYZ3:	incbin	"Level Data/Object Positions/syz3.bin"
		even
ObjPos_SBZ1:	incbin	"Level Data/Object Positions/sbz1.bin"
		even
ObjPos_SBZ2:	incbin	"Level Data/Object Positions/sbz2.bin"
		even
ObjPos_FZ:		incbin	"Level Data/Object Positions/fz.bin"
		even
ObjPos_SBZ1pf1:	incbin	"Level Data/Object Positions/sbz1pf1.bin"
		even
ObjPos_SBZ1pf2:	incbin	"Level Data/Object Positions/sbz1pf2.bin"
		even
ObjPos_SBZ1pf3:	incbin	"Level Data/Object Positions/sbz1pf3.bin"
		even
ObjPos_SBZ1pf4:	incbin	"Level Data/Object Positions/sbz1pf4.bin"
		even
ObjPos_SBZ1pf5:	incbin	"Level Data/Object Positions/sbz1pf5.bin"
		even
ObjPos_SBZ1pf6:	incbin	"Level Data/Object Positions/sbz1pf6.bin"
		even
ObjPos_End:		incbin	"Level Data/Object Positions/ending.bin"
		even
ObjPos_MHZ1:	incbin	"Level Data/Object Positions/MHZ1.bin"
		even
ObjPos_MHZ2:	incbin	"Level Data/Object Positions/MHZ2.bin"
		even
ObjPos_MHZ3:	incbin	"Level Data/Object Positions/MHZ3.bin"
		even
ObjPos_HPZ1:	incbin	"Level Data/Object Positions/HPZ1.bin"
		even
ObjPos_HPZ2:	incbin	"Level Data/Object Positions/HPZ2.bin"
		even
ObjPos_HPZ3:	incbin	"Level Data/Object Positions/HPZ3.bin"
		even
ObjPos_TMZ1:	incbin	"Level Data/Object Positions/TMZ1.bin"
		even
ObjPos_TMZ2:	incbin	"Level Data/Object Positions/TMZ2.bin"
		even
ObjPos_TMZ3:	incbin	"Level Data/Object Positions/TMZ3.bin"
		even
ObjPos_Null:	dc.b	$FF, $FF, 0, 0, 0,	0
		even

SSObjPos_Index:
		dc.w	ObjPos_SS1-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.w	ObjPos_SS2-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.w	ObjPos_SS3-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.w	ObjPos_SS4-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.w	ObjPos_SS5-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.w	ObjPos_SS6-SSObjPos_Index, ObjPos_Null-SSObjPos_Index
		dc.b	$FF, $FF, 0, 0, 0,	0

ObjPos_SS1:		incbin	"Level Data/Object Positions/SS1.bin"
		even
ObjPos_SS2:		incbin	"Level Data/Object Positions/SS2.bin"
		even
ObjPos_SS3:		incbin	"Level Data/Object Positions/SS3.bin"
		even
ObjPos_SS4:		incbin	"Level Data/Object Positions/SS4.bin"
		even
ObjPos_SS5:		incbin	"Level Data/Object Positions/SS5.bin"
		even
ObjPos_SS6:		incbin	"Level Data/Object Positions/SS6.bin"
		even

; ---------------------------------------------------------------------------
; Ring locations index
; ---------------------------------------------------------------------------
RingPos_Index:
		; GHZ
		dc.l	RingPos_BGZ1
		dc.l	RingPos_BGZ2
		dc.l	RingPos_BGZ3
		dc.l	RingPos_LBGZ
		; LZ
		dc.l	RingPos_LZ1
		dc.l	RingPos_LZ2
		dc.l	RingPos_LZ3
		dc.l	RingPos_SBZ3
		; MZ
		dc.l	RingPos_MZ1
		dc.l	RingPos_MZ2
		dc.l	RingPos_MZ3
		dc.l	RingPos_MZ1
		; SLZ
		dc.l	RingPos_SLZ1
		dc.l	RingPos_SLZ2
		dc.l	RingPos_SLZ3
		dc.l	RingPos_SLZ1
		; SYZ
		dc.l	RingPos_SYZ1
		dc.l	RingPos_SYZ2
		dc.l	RingPos_SYZ3
		dc.l	RingPos_SYZ1
		; SBZ
		dc.l	RingPos_SBZ1
		dc.l	RingPos_SBZ2
		dc.l	RingPos_FZ
		dc.l	RingPos_SBZ1
		; MHZ
		dc.l	RingPos_MHZ1
		dc.l	RingPos_MHZ2
		dc.l	RingPos_MHZ3
		dc.l	RingPos_MHZ1
		; HPZ
		dc.l	RingPos_HPZ1
		dc.l	RingPos_HPZ2
		dc.l	RingPos_HPZ3
		dc.l	RingPos_HPZ1
		; TMZ
		dc.l	RingPos_TMZ1
		dc.l	RingPos_TMZ2
		dc.l	RingPos_TMZ3
		dc.l	RingPos_TMZ1
		zonewarning	RingPos_Index,$10
		; Ending
		dc.l	RingPos_End
		dc.l	RingPos_End
		dc.l	RingPos_End
		dc.l	RingPos_End

RingPos_BGZ1:	incbin	"Level Data/Ring Positions/bgz1.bin"
		even
RingPos_BGZ2:	incbin	"Level Data/Ring Positions/bgz2.bin"
		even
RingPos_BGZ3:	incbin	"Level Data/Ring Positions/bgz3.bin"
		even
RingPos_LBGZ:	incbin	"Level Data/Ring Positions/lbgz.bin"
		even
RingPos_LZ1:	incbin	"Level Data/Ring Positions/lz1.bin"
		even
RingPos_LZ2:	incbin	"Level Data/Ring Positions/lz2.bin"
		even
RingPos_LZ3:	incbin	"Level Data/Ring Positions/lz3.bin"
		even
RingPos_SBZ3:	incbin	"Level Data/Ring Positions/sbz3.bin"
		even
RingPos_MZ1:	incbin	"Level Data/Ring Positions/mz1.bin"
		even
RingPos_MZ2:	incbin	"Level Data/Ring Positions/mz2.bin"
		even
RingPos_MZ3:	incbin	"Level Data/Ring Positions/mz3.bin"
		even
RingPos_SLZ1:	incbin	"Level Data/Ring Positions/slz1.bin"
		even
RingPos_SLZ2:	incbin	"Level Data/Ring Positions/slz2.bin"
		even
RingPos_SLZ3:	incbin	"Level Data/Ring Positions/slz3.bin"
		even
RingPos_SYZ1:	incbin	"Level Data/Ring Positions/syz1.bin"
		even
RingPos_SYZ2:	incbin	"Level Data/Ring Positions/syz2.bin"
		even
RingPos_SYZ3:	incbin	"Level Data/Ring Positions/syz3.bin"
		even
RingPos_SBZ1:	incbin	"Level Data/Ring Positions/sbz1.bin"
		even
RingPos_SBZ2:	incbin	"Level Data/Ring Positions/sbz2.bin"
		even
RingPos_FZ:		incbin	"Level Data/Ring Positions/fz.bin"
		even
RingPos_End:	incbin	"Level Data/Ring Positions/ending.bin"
		even
RingPos_MHZ1:	incbin	"Level Data/Ring Positions/MHZ1.bin"
		even
RingPos_MHZ2:	incbin	"Level Data/Ring Positions/MHZ2.bin"
		even
RingPos_MHZ3:	incbin	"Level Data/Ring Positions/MHZ3.bin"
		even
RingPos_HPZ1:	incbin	"Level Data/Ring Positions/HPZ1.bin"
		even
RingPos_HPZ2:	incbin	"Level Data/Ring Positions/HPZ2.bin"
		even
RingPos_HPZ3:	incbin	"Level Data/Ring Positions/HPZ3.bin"
		even
RingPos_TMZ1:	incbin	"Level Data/Ring Positions/TMZ1.bin"
		even
RingPos_TMZ2:	incbin	"Level Data/Ring Positions/TMZ2.bin"
		even
RingPos_TMZ3:	incbin	"Level Data/Ring Positions/TMZ3.bin"
		even
RingPos_Null:	dc.b	$FF, $FF, 0, 0, 0,	0
; ===========================================================================

	include	"Includes/Enigma Credits.asm"	; here we include the "Credits_MapLoad" subroutine
		even
EniCred_0:	incbin	"Tilemaps/Enigma Credits/cred0.bin"	; Credits #0 mappings
		even
EniCred_1:	incbin	"Tilemaps/Enigma Credits/cred1.bin"	; Credits #1 mappings
		even
EniCred_2:	incbin	"Tilemaps/Enigma Credits/cred2.bin"	; Credits #2 mappings
		even
EniCred_3:	incbin	"Tilemaps/Enigma Credits/cred3.bin"	; Credits #3 mappings
		even
EniCred_4:	incbin	"Tilemaps/Enigma Credits/cred4.bin"	; Credits #4 mappings
		even
EniCred_5:	incbin	"Tilemaps/Enigma Credits/cred5.bin"	; Credits #5 mappings
		even
EniCred_6:	incbin	"Tilemaps/Enigma Credits/cred6.bin"	; Credits #6 mappings
		even
EniCred_7:	incbin	"Tilemaps/Enigma Credits/cred7.bin"	; Credits #7 mappings
		even
EniCred_8:	incbin	"Tilemaps/Enigma Credits/cred8.bin"	; Credits #8 mappings
		even
EniCred_9:	incbin	"Tilemaps/Enigma Credits/cred9.bin"	; Credits #9 mappings
		even

; ---------------------------------------------------------------------------
; Uncompressed art. Like, all of it. In the entire game. Yes.
; ---------------------------------------------------------------------------
			include	"Includes/Uncompressed Art.asm"

SonicSays:	dc.b	"Don't be a thief, kids. If you wanna take something, you gotta ask. If you do steal anything, I'll tell Abbey to find your IP address, fly and do a home invasion with all her flicky friends."
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound Test Screen
; ---------------------------------------------------------------------------
; GM_SoundTest:
		include	"Sound Test/Sound Test.asm"

		include	"AMPS/code/smps2asm.asm"
		include	"AMPS/code/68k.asm"
DualPCM:
		PUSHS					; store section information for Main
Z80Code		SECTION	org(0), file("AMPS/.z80")	; create a new section for Dual PCM
		z80prog 0				; init z80 program
zchkoffs = 1
		include "AMPS/code/z80.asm"		; code for Dual PCM
DualPCM_sz:	z80prog					; end z80 program
		POPS					; go back to Main section

		PUSHS					; store section information for Main
mergecode	SECTION	file("AMPS/.z80.dat"), org(0)	; create settings file for storing info about how to merge things
		dc.l offset(DualPCM), Z80_Space		; store info about location of file and size available

	if zchkoffs
		rept zfuturec
			popp zoff			; grab the location of the patch
			popp zbyte			; grab the correct byte
			dc.w zoff			; write the address
			dc.b zbyte, '>'			; write the byte and separator
		endr
	endif
		POPS					; go back to Main section

	ds.b Z80_Space					; reserve space for the Z80 driver
	even
	opt ae+
		include	"Error Handler/ErrorHandler.asm"

	if DemoMode=1
		include "Includes/End Of Demo Screen.asm"
	endc
	
EndOfRom:	END
