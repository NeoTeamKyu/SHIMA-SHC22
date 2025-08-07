; Emulator detection - original by Ralakimus/Devon,
; trimmed down to only tell the difference between GPGX
; and not GPGX by ProjectFM
; -------------------------------------------------------------------------
; Configuration
; -------------------------------------------------------------------------

VDPDEBUG_WRITE		equ	$01		; What gets written into the VDP debug register
DMAHALT_THRESHOLD	equ	$80		; DMA Z80 halt counter threshold

; -------------------------------------------------------------------------
; GPGX detector
; -------------------------------------------------------------------------
; NOTICE: DESTROYS VRAM AND OVERWRITES Z80 RAM
; -------------------------------------------------------------------------
; RETURNS:
;	d0.b	- 0 if not, 1 if so
; -------------------------------------------------------------------------

DetectGPGX:
	; Check what reading the VDP debug register does (check ReadVDPDebugReg's notes for more details)
	; This is a known issue in Kega Fusion, Steam, old versions of BlastEm, Gens, Picodrive, Genecyst,
	; and Mega Sg. Here, we only check the nonzero results, since multiple emulators will return 0, and thus
	; need further checks to be done first.

	bsr.w	ReadVDPDebugReg			; Read VDP debug register
	tst.w	d0			; Did it return -1?
	bne.w	.NotGPGX			; If so, then GPGX hasn't been detected

	; Detect DMA interruption (check CheckDMAZ80Halt's notes for more details)
	; Only BlastEm, Exodus, Mega Sg, and hardware will make the Z80 halt during the DMA.
	; BlastEm should have already been detected through the VDP debug register, so
	; we only need to worry about the other 3 now.

	bsr.w	CheckDMAZ80Halt			; Test DMA Z80 halt
	tst.b	d0				; Did the Z80 get halted?
	beq.s	.FoundGPGX			; If not, then the platform is not hardware, Exodus, or Mega Sg

.NotGPGX
	moveq	#0,d0
	rts

.FoundGPGX:
	moveq	#1,d0
	rts

; -------------------------------------------------------------------------
; Read VDP debug register
; -------------------------------------------------------------------------
; Reading the VDP debug register yields different results for different
; hardware, clones, and emulators.
; -------------------------------------------------------------------------
; Kega will return -1, some will return 0, some will return the
; 68000 instruction prefetch (like hardware does), Steam will
; return the NOP opcode, and old versions of BlastEm will return the last
; thing written to it.
; -------------------------------------------------------------------------
; RETURNS:
;	d0.w	- Value read from the VDP debug register
; -------------------------------------------------------------------------

ReadVDPDebugReg:
	move.w	#VDPDEBUG_WRITE,$C0001C		; Write to the VDP debug register (for BlastEm detection)
	move.w	$C0001C,d0			; Read VDP debug register
	move.w	#0,$C0001C			; Reset VDP debug register
	rts

; -------------------------------------------------------------------------
; Check DMA Z80 halt
; -------------------------------------------------------------------------
; NOTICE: DESTROYS VRAM AND OVERWRITES Z80 RAM
; -------------------------------------------------------------------------
; On hardware, while there is a DMA from 68000 memory, the Z80 should
; halt if it also tries to access 68000 memory at the same time, at least
; until it is finished with the DMA. Most emulators do not emulate this.
; -------------------------------------------------------------------------
; To detect it, there's a Z80 program that constantly reads from 68000
; memory while also incrementing a counter, and then do 2 very large
; DMA transfers from 68000. If the Z80 is halted during the DMAs, then the
; counter should not go very high at all, otherwise, it should skyrocket.
; -------------------------------------------------------------------------
; RETURNS:
;	d0.b	- 0 = DMA did not make the Z80 halt
;		  1 = DMA did make the Z80 halt
; -------------------------------------------------------------------------

CheckDMAZ80Halt:
	lea	Z80DMAHaltTest(pc),a0		; Load the Z80 program
	move.w	#Z80DMAHaltTest_End-Z80DMAHaltTest-1,d0
	bsr.w	EmuDet_LoadZ80

	lea	$C00004,a1			; Prepare the first DMA
	move.l	#$81148F02,(a1)
	move.l	#$947F93FF,(a1)
	move.l	#$96009500,(a1)
	move.w	#$9700,(a1)
	move.w	#$4000,(a1)
	move.w	#$0080,-(sp)

	move.w	#$100,$A11100			; Make the Z80 go into the counter loop

.StopZ80:
	btst	#0,$A11100
	bne.s	.StopZ80
	move.b	#$00,Z80DMAHaltTest_Loop1
	move.b	#$00,Z80DMAHaltTest_Loop1+1
	move.b	#$00,Z80DMAHaltTest_Loop1+2
	move.w	#0,$A11100

	move.w	(sp)+,(a1)			; Start the first DMA

	move.l	#$947F93FF,(a1)			; Start the second DMA
	move.l	#$96009500,(a1)
	move.w	#$9700,(a1)
	move.w	#$4000,(a1)
	move.w	#$0080,-(sp)
	move.w	(sp)+,(a1)

	move.w	#$100,$A11100			; Make the Z80 finish up

.StopZ80_2:
	btst	#0,$A11100
	bne.s	.StopZ80_2
	move.b	#$00,Z80DMAHaltTest_Loop2Ins
	move.b	#$00,Z80DMAHaltTest_Loop2Ins+1
	move.b	#$00,Z80DMAHaltTest_Loop2Ins+2
	move.w	#0,$A11100

	moveq	#$7F,d0				; Ensure that the Z80 transfers the counter to RAM first
	dbf	d0,*

	move.w	#$100,$A11100			; Get the Z80 counter

.StopZ80_3:
	btst	#0,$A11100
	bne.s	.StopZ80_3
	moveq	#0,d0
	move.b	Z80DMAHaltTest_Cnt+1,d0
	lsl.w	#8,d0
	move.b	Z80DMAHaltTest_Cnt,d0
	move.w	#0,$A11100

	move.w	#$8F01,(a1)			; Clear VRAM
	move.l	#$94FF93FF,(a1)
	move.l	#$96009500,(a1)
	move.w	#$9780,(a1)
	move.w	#$4000,(a1)
	move.w	#$0080,-(sp)
	move.w	(sp)+,(a1)
	move.w	#0,-4(a1)

.WaitVRAMClr:
	move.w	(a1),d1
	btst	#1,d1
	bne.s	.WaitVRAMClr
	move.w	#$8F02,(a1)

	cmpi.w	#DMAHALT_THRESHOLD,d0		; Check if the Z80 DMA test counter was a low value
	bcc.s	.NoDMAHalt			; If not, then the Z80 did not halt
	moveq	#1,d0
	rts

.NoDMAHalt:
	moveq	#0,d0
	rts

; -------------------------------------------------------------------------
; Z80 side of the DMA interrupt detector
; -------------------------------------------------------------------------

Z80DMAHaltTest:
	dc.b	$F3		; di		; Disable interrupts

	; Z80DMAHaltTest_Loop1:			; Wait for the 68000 to start with
	dc.b	$C3,$01,$00	; jp Z80DMAHaltTest_Loop1
						; the DMA thing

	dc.b	$21,$00,$00	; ld hl,$0000	; Initialize the counter	

	; Z80DMAHaltTest_Loop2:
	dc.b	$3A,$00,$80	; ld a,($8000)	; Attempt a read from 68000 memory
	dc.b	$23		; inc hl	; Increment the counter

	; Z80DMAHaltTest_Loop2Ins:		; Loop
	dc.b	$C3,$07,$00	; jp Z80DMAHaltTest_Loop2

	dc.b	$7D		; ld a,l	; Transfer the counter over to RAM
	dc.b	$32,$19,$00	; ld (Z80DMAHaltTest_Cnt),a
	dc.b	$7C		; ld a,h
	dc.b	$32,$1A,$00	; ld (Z80DMAHaltTest_Cnt+1),a

	; Z80DMAHaltTest_Loop3:			; Loop here forever
	dc.b	$C3,$16,$00	; jp Z80DMAHaltTest_Loop3

	; Z80DMAHaltTest_Cnt:
	dc.b	$00,$00		; dw $0000	; Finalized Z80 counter
Z80DMAHaltTest_End:
	even

Z80DMAHaltTest_Loop1		equ	$A00001
Z80DMAHaltTest_Loop2		equ	$A00007
Z80DMAHaltTest_Loop2Ins		equ	$A0000B
Z80DMAHaltTest_Cnt		equ	$A00019

; -------------------------------------------------------------------------
; Load a Z80 program
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Z80 program
;	d0.w	- Z80 program size minus 1
; -------------------------------------------------------------------------

EmuDet_LoadZ80:
	move.w	#$100,$A11100			; Request Z80 bus
	move.w	#$100,$A11200			; Z80 reset off

.Z80Bus:					; Wait for Z80 bus
	btst	#0,$A11100
	bne.s	.Z80Bus

	lea	$A00000,a1			; Load the Z80 program

.Load:
	move.b	(a0)+,(a1)+
	dbf	d0,.Load

	move.w	#0,$A11200			; Z80 reset on
	moveq	#$7F,d0				; Wait for Z80 reset
	dbf	d0,*

	move.w	#0,$A11100			; Z80 start
	move.w	#$100,$A11200			; Z80 reset off
	rts

; -------------------------------------------------------------------------