; ==============================================================================
; ------------------------------------------------------------------------------
; Nemesis decompression routine
; ------------------------------------------------------------------------------
; Optimized by vladikcomper
; ------------------------------------------------------------------------------
 
NemDec_RAM:
    movem.l d0-a1/a3-a6,-(sp)
    lea NemDec_WriteRowToRAM(pc),a3
    bra.s   NemDec_Main
 
; ------------------------------------------------------------------------------
NemDec:
    movem.l d0-a1/a3-a6,-(sp)
    lea $C00000,a4      ; load VDP Data Port     
    lea NemPCD_WriteRowToVDP(pc),a3
 
NemDec_Main:
    lea (v_ngfx_buffer).w,a1        ; load Nemesis decompression buffer
    move.w  (a0)+,d2        ; get number of patterns
    bpl.s   @0          ; are we in Mode 0?
    lea $A(a3),a3       ; if not, use Mode 1
@0  lsl.w   #3,d2
    movea.w d2,a5
    moveq   #7,d3
    moveq   #0,d2
    moveq   #0,d4
    bsr.w   NemDec_BuildCodeTable
    move.b  (a0)+,d5        ; get first byte of compressed data
    asl.w   #8,d5           ; shift up by a byte
    move.b  (a0)+,d5        ; get second byte of compressed data
    move.w  #$10,d6         ; set initial shift value
    bsr.s   NemDec2
    movem.l (sp)+,d0-a1/a3-a6
    rts
 
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, processes the actual compressed data
; ---------------------------------------------------------------------------
 
NemDec2:
    move.w  d6,d7
    subq.w  #8,d7           ; get shift value
    move.w  d5,d1
    lsr.w   d7,d1           ; shift so that high bit of the code is in bit position 7
    cmpi.b  #%11111100,d1       ; are the high 6 bits set?
    bcc.s   NemDec_InlineData   ; if they are, it signifies inline data
    andi.w  #$FF,d1
    add.w   d1,d1
    sub.b   (a1,d1.w),d6        ; ~~ subtract from shift value so that the next code is read next time around
    cmpi.w  #9,d6           ; does a new byte need to be read?
    bcc.s   @0          ; if not, branch
    addq.w  #8,d6
    asl.w   #8,d5
    move.b  (a0)+,d5        ; read next byte
@0  move.b  1(a1,d1.w),d1
    move.w  d1,d0
    andi.w  #$F,d1          ; get palette index for pixel
    andi.w  #$F0,d0
 
NemDec_GetRepeatCount:
    lsr.w   #4,d0           ; get repeat count
 
NemDec_WritePixel:
    lsl.l   #4,d4           ; shift up by a nybble
    or.b    d1,d4           ; write pixel
    dbf d3,NemDec_WritePixelLoop; ~~
    jmp (a3)            ; otherwise, write the row to its destination
; ---------------------------------------------------------------------------
 
NemPCD_NewRow:
    moveq   #0,d4           ; reset row
    moveq   #7,d3           ; reset nybble counter
 
NemDec_WritePixelLoop:
    dbf d0,NemDec_WritePixel
    bra.s   NemDec2
; ---------------------------------------------------------------------------
 
NemDec_InlineData:
    subq.w  #6,d6           ; 6 bits needed to signal inline data
    cmpi.w  #9,d6
    bcc.s   @0
    addq.w  #8,d6
    asl.w   #8,d5
    move.b  (a0)+,d5
@0  subq.w  #7,d6           ; and 7 bits needed for the inline data itself
    move.w  d5,d1
    lsr.w   d6,d1           ; shift so that low bit of the code is in bit position 0
    move.w  d1,d0
    andi.w  #$F,d1          ; get palette index for pixel
    andi.w  #$70,d0         ; high nybble is repeat count for pixel
    cmpi.w  #9,d6
    bcc.s   NemDec_GetRepeatCount
    addq.w  #8,d6
    asl.w   #8,d5
    move.b  (a0)+,d5
    bra.s   NemDec_GetRepeatCount
 
; ---------------------------------------------------------------------------
; Subroutines to output decompressed entry
; Selected depending on current decompression mode
; ---------------------------------------------------------------------------
 
NemPCD_WriteRowToVDP:
loc_1502:
    move.l  d4,(a4)         ; write 8-pixel row
    subq.w  #1,a5
    move.w  a5,d4           ; have all the 8-pixel rows been written?
    bne.s   NemPCD_NewRow         ; if not, branch
    rts
; ---------------------------------------------------------------------------
 
NemPCD_WriteRowToVDP_XOR:
    eor.l   d4,d2           ; XOR the previous row by the current row
    move.l  d2,(a4)         ; and write the result
    subq.w  #1,a5
    move.w  a5,d4
    bne.s   NemPCD_NewRow
    rts
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToRAM:
    move.l  d4,(a4)+        ; write 8-pixel row
    subq.w  #1,a5
    move.w  a5,d4           ; have all the 8-pixel rows been written?
    bne.s   NemPCD_NewRow         ; if not, branch
    rts
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToRAM_XOR:
    eor.l   d4,d2           ; XOR the previous row by the current row
    move.l  d2,(a4)+        ; and write the result
    subq.w  #1,a5
    move.w  a5,d4
    bne.s   NemPCD_NewRow
    rts
 
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, builds the code table (in RAM)
; ---------------------------------------------------------------------------
 
NemDec_BuildCodeTable:
    move.b  (a0)+,d0        ; read first byte
 
@ChkEnd:
    cmpi.b  #$FF,d0         ; has the end of the code table description been reached?
    bne.s   @NewPalIndex        ; if not, branch
    rts
; ---------------------------------------------------------------------------
 
@NewPalIndex:
    move.w  d0,d7
 
@ItemLoop:
    move.b  (a0)+,d0        ; read next byte
    bmi.s   @ChkEnd         ; ~~
    move.b  d0,d1
    andi.w  #$F,d7          ; get palette index
    andi.w  #$70,d1         ; get repeat count for palette index
    or.w    d1,d7           ; combine the two
    andi.w  #$F,d0          ; get the length of the code in bits
    move.b  d0,d1
    lsl.w   #8,d1
    or.w    d1,d7           ; combine with palette index and repeat count to form code table entry
    moveq   #8,d1
    sub.w   d0,d1           ; is the code 8 bits long?
    bne.s   @ItemShortCode      ; if not, a bit of extra processing is needed
    move.b  (a0)+,d0        ; get code
    add.w   d0,d0           ; each code gets a word-sized entry in the table
    move.w  d7,(a1,d0.w)        ; store the entry for the code
    bra.s   @ItemLoop       ; repeat
; ---------------------------------------------------------------------------
 
@ItemShortCode:
    move.b  (a0)+,d0        ; get code
    lsl.w   d1,d0           ; shift so that high bit is in bit position 7
    add.w   d0,d0           ; get index into code table
    moveq   #1,d5
    lsl.w   d1,d5
    subq.w  #1,d5           ; d5 = 2^d1 - 1
    lea (a1,d0.w),a6        ; ~~
 
@ItemShortCodeLoop:
    move.w  d7,(a6)+        ; ~~ store entry
    dbf d5,@ItemShortCodeLoop   ; repeat for required number of entries
    bra.s   @ItemLoop