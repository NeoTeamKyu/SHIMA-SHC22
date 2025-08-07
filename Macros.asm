; ---------------------------------------------------------------------------
; Align and pad
; input: length to align to, value to use as padding (default is 0)
; ---------------------------------------------------------------------------

align:		macro position, value
		if (narg=1)
		dcb.b (\position-(offset(*)%\position))%\position,0
		else
		dcb.b (\position-(offset(*)%\position))%\position,\value
		endc
		endm

; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
		if (narg=1)
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),(vdp_control_port).l
		else
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),controlport
		endc
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the VRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeVRAM:	macro
		lea	(vdp_control_port).l,a5
		move.l	#$94000000+(((\2>>1)&$FF00)<<8)+$9300+((\2>>1)&$FF),(a5)
		move.l	#$96000000+(((\1>>1)&$FF00)<<8)+$9500+((\1>>1)&$FF),(a5)
		move.w	#$9700+((((\1>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$4000+(\3&$3FFF),(a5)
		move.w	#$80+((\3&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA copy data from 68K (ROM/RAM) to the CRAM
; input: source, length, destination
; ---------------------------------------------------------------------------

writeCRAM:	macro
		lea	(vdp_control_port).l,a5
		move.l	#$94000000+(((\2>>1)&$FF00)<<8)+$9300+((\2>>1)&$FF),(a5)
		move.l	#$96000000+(((\1>>1)&$FF00)<<8)+$9500+((\1>>1)&$FF),(a5)
		move.w	#$9700+((((\1>>1)&$FF0000)>>16)&$7F),(a5)
		move.w	#$C000+(\3&$3FFF),(a5)
		move.w	#$80+((\3&$C000)>>14),(v_vdp_buffer2).w
		move.w	(v_vdp_buffer2).w,(a5)
		endm

; ---------------------------------------------------------------------------
; DMA fill VRAM with a value
; input: value, length, destination
; ---------------------------------------------------------------------------

fillVRAM:	macro value,length,loc
		lea	(vdp_control_port).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94000000+((length&$FF00)<<8)+$9300+(length&$FF),(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080+((loc&$3FFF)<<16)+((loc&$C000)>>14),(a5)
		move.w	#value,(vdp_data_port).l
		endm

; ---------------------------------------------------------------------------
; Copy a tilemap from 68K (ROM/RAM) to the VRAM without using DMA
; input: source, destination, width [cells], height [cells]
; ---------------------------------------------------------------------------

copyTilemap:	macro source,loc,width,height
		lea	(source).l,a1
		move.l	#$40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14),d0
		moveq	#width,d1
		moveq	#height,d2
		bsr.w	TilemapToVRAM
		endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

resetZ80:	macro
		move.w	#$100,(z80_reset).l
		endm

resetZ80a:	macro
		move.w	#0,(z80_reset).l
		endm

; ---------------------------------------------------------------------------
; disable interrupts
; ---------------------------------------------------------------------------

disable_ints:	macro
		move	#$2700,sr
		endm

; ---------------------------------------------------------------------------
; enable interrupts
; ---------------------------------------------------------------------------

enable_ints:	macro
		move	#$2300,sr
		endm

; ---------------------------------------------------------------------------
; long conditional jumps
; ---------------------------------------------------------------------------

jhi:		macro loc
		bls.s	@nojump
		jmp	loc
	@nojump:
		endm

jcc:		macro loc
		bcs.s	@nojump
		jmp	loc
	@nojump:
		endm

jhs:		macro loc
		jcc	loc
		endm

jls:		macro loc
		bhi.s	@nojump
		jmp	loc
	@nojump:
		endm

jcs:		macro loc
		bcc.s	@nojump
		jmp	loc
	@nojump:
		endm

jlo:		macro loc
		jcs	loc
		endm

jeq:		macro loc
		bne.s	@nojump
		jmp	loc
	@nojump:
		endm

jne:		macro loc
		beq.s	@nojump
		jmp	loc
	@nojump:
		endm

jgt:		macro loc
		ble.s	@nojump
		jmp	loc
	@nojump:
		endm

jge:		macro loc
		blt.s	@nojump
		jmp	loc
	@nojump:
		endm

jle:		macro loc
		bgt.s	@nojump
		jmp	loc
	@nojump:
		endm

jlt:		macro loc
		bge.s	@nojump
		jmp	loc
	@nojump:
		endm

jpl:		macro loc
		bmi.s	@nojump
		jmp	loc
	@nojump:
		endm

jmi:		macro loc
		bpl.s	@nojump
		jmp	loc
	@nojump:
		endm

; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

out_of_range:	macro exit,pos
		if (narg=2)
		move.w	pos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endc
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposx).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bhi.\0	exit
		endm
; -----------------------------------------------------------------------------------------------------
; macro to set obj pointer branch is when pointer is 0 and status tableaddr is the sst for that pointer
; -----------------------------------------------------------------------------------------------------
ObjSetPointer:	macro   branch,statustableaddr
                move.l statustableaddr(a0),d0 ; set pointer to d0
                beq.\0	branch       ; if the pointer is 0 then do not jmp to addr get correct rom addr because if its 0 it will jmp to vector table witch will crash
                move.l  d0,a1        ; copy d0 to a1
                jmp     (a1)         ; jmp to addr
                endm
; ---------------------------------------------------------------------
; subroutine to displaying using  DisplaySpriteEfficient subroutine
; ---------------------------------------------------------------------
DisplayEfficentPriority: macro  priorityValue
                lea    (v_spritequeue).w,a1
                lea     priorityValue(a1),a1  
	        jmp     DisplaySpriteEfficient
	        endm
; ---------------------------------------------------------------------------
; check if object moves out of range
; input: location to jump to if out of range, x-axis pos (obX(a0) by default)
; ---------------------------------------------------------------------------

out_of_range_resp:	macro exit,pos
		if (narg=2)
		move.w	pos,d0		; get object position (if specified as not obX)
		else
		move.w	obX(a0),d0	; get object position
		endc
		andi.w	#$FF80,d0	; round down to nearest $80
		move.w	(v_screenposx).w,d1 ; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0		; approx distance between object and screen
		cmpi.w	#128+320+192,d0
		bls.s	@nodel
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.\0	exit		; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
		bra.\0	exit	; and delete object

	@nodel:
		endm

; ---------------------------------------------------------------------------
; AMPS macros
; ---------------------------------------------------------------------------

; Macro for playing a command
command		macro id
	move.b #id,mQueue.w
    endm

; Macro for playing music
music		macro id
	move.b #id,mQueue+1.w
    endm

; Macro for playing sound effect
sfx		macro id
	move.b #id,mQueue+2.w
    endm

; ---------------------------------------------------------------------------
; bankswitch between SRAM and ROM
; (remember to enable SRAM in the header first!)
; ---------------------------------------------------------------------------

gotoSRAM:	macro
		move.b  #1,($A130F1).l
		endm

gotoROM:	macro
		move.b  #0,($A130F1).l
		endm

; ---------------------------------------------------------------------------
; compare the size of an index with ZoneCount constant
; (should be used immediately after the index)
; input: index address, element size
; ---------------------------------------------------------------------------

zonewarning:	macro loc,elementsize
	@end:
		if (@end-loc)-(ZoneCount*elementsize)<>0
		inform 1,"Size of \loc ($%h) does not match ZoneCount ($\#ZoneCount).",(@end-loc)/elementsize
		endc
		endm

; fills a region of 68k RAM with 0
clearRAM:		macro startaddr,endaddr
		lea	(startaddr).l,a6
		moveq	#0,d7
		move.w	#endaddr,d6
	@clearRAM\@:
		move.l	d7,(a6)+
		dbf	d6,@clearRAM\@
		endm

;-- Copypaste from s2git to make the s2 Menu happy --

; values for the type argument
VRAM: 	equ	%100001
CRAM: 	equ %101011
VSRAM:	equ	%100101

; values for the rwd argument
READ: 	equ %001100
WRITE:	equ %000111
DMA: 	equ	%100111

menutxt	macro	text
		dc.b	strlen(\text)-1
		dc.b	\text
		endm

; reads ASCII strings and passes them to character generator
asc        macro str
ct =    0                            ; accumulates the total num of characters
    rept narg                        ; repeat for every argumeny
lc =        0                        ; the position in the string

    dc.b strlen(\str)-1                    ; put the string length before the string itself
    rept strlen(\str)                    ; repeat for each character in string
cc         substr lc+1,lc+1,\str                ; get a single character into cc
arg =        '\cc'                        ; convert it to a character
            char.b arg                ; put the character into the ROM (as byte)

lc =        lc+1                        ; go to the next character
ct =        ct+1                        ; increment character count
        endr
    shift
    endr
    endm

; translates ASCII character to proper hex value
char        macro c
    if c=' '
        dc.\0 0                        ; example 1: single letters

    elseif c='*'
        dc.\0 $1A                        ; example 1: single letters

    elseif (c>='0')&(c<='9')
        dc.\0 \c-'0'+$20                ; example 2: range of letters ; gem note: '0' = $30. it's the ascii representation

    elseif (c>='A')&(c<='Z')
        dc.\0 \c-$41+$1E                ; example 2: range of letters ; gem note: '0' = $30. it's the ascii representation

    else
        dc.\0 \c                    ; example 3: any other character
    endif
    endm

; Palette shifting.
; discusting
ShiftPalUp1		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+2).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteUp	; Adds shade to palette and caps at max value for each parameter
	endm

ShiftPalDown1		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+2).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteDown	; Subtracts shade from palette and caps at min value for each parameter
	endm

ShiftPalUpLevel		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$22).w,a1
		moveq	#$2D,d3
		jsr		ShiftPaletteUp	; Adds shade to palette and caps at max value for each parameter
	endm

ShiftPalDownLevel		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$22).w,a1
		moveq	#$2D,d3
		jsr		ShiftPaletteDown	; Subtracts shade from palette and caps at min value for each parameter
	endm

ShiftPalUp2		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$22).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteUp	; Adds shade to palette and caps at max value for each parameter
	endm

ShiftPalDown2		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$22).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteDown	; Subtracts shade from palette and caps at min value for each parameter
	endm

ShiftPalUp3		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$42).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteUp	; Adds shade to palette and caps at max value for each parameter
	endm

ShiftPalDown3		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$42).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteDown	; Subtracts shade from palette and caps at min value for each parameter
	endm

ShiftPalUp4		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$62).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteUp	; Adds shade to palette and caps at max value for each parameter
	endm

ShiftPalDown4		macro color
		moveq	#(color&$E),d0
		moveq	#(color&$E0),d1
		move.w	#(color&$E00),d2
		lea	(v_pal_dry+$62).w,a1
		moveq	#$E,d3
		jsr		ShiftPaletteDown	; Subtracts shade from palette and caps at min value for each parameter
	endm