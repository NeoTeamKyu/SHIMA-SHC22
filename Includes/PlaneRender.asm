
; ---------------------------------------------------------------------------
; Initializes tile render
; ---------------------------------------------------------------------------
ResetPlaneRender macro
    move.w  #v_planebuffer,(v_planebuffer_addr).w
    endm

; ---------------------------------------------------------------------------
; Place Tile to plane into buffer (doesn't make plane wrapping!)
; input:
; d0 - row*2 + plane address,
; d1 - collumn<<7,
; d2 - tile,
; a5 - free plane buffer space
; ---------------------------------------------------------------------------
PlacePlaneTile:
    move.w  #1,(a5)+   ; set amount of tiles
    add.w   d1,d0    ; get vram tile address on plane
    move.w  d0,(a5)+    ; set vram tile address on plane
    move.w  d2,(a5)+    ; load tile
    rts

; ---------------------------------------------------------------------------
; Prepares tile buffer for placing row of tiles into buffer
; input:
; d0 - row*2 + plane address,
; d1 - collumn<<7,
; a5 - free plane buffer space
; returns:
; a4 - amount of tiles pointer
; ---------------------------------------------------------------------------
PrepareTileRow:
    lea     (a5),a4
    move.w  #-1,(a5)+   ; set amount of tiles and row flag
    add.w   d1,d0    ; get vram tile address on plane
    move.w  d0,(a5)+    ; set vram tile address on plane
    rts

; ---------------------------------------------------------------------------
; Prepares tile buffer for placing collumn of tiles into buffer
; input:
; d0 - row*2 + plane address,
; d1 - collumn<<7,
; a5 - free plane buffer space
; returns:
; a4 - amount of tiles pointer
; ---------------------------------------------------------------------------
PrepareTileCollumn:
    lea     (a5),a4
    move.w  #1,(a5)+   ; set amount of tiles
    add.w   d1,d0    ; get vram tile address on plane
    move.w  d0,(a5)+    ; set vram tile address on plane
    rts

; ---------------------------------------------------------------------------
; Flushes and Processes Plane Buffer
; ---------------------------------------------------------------------------
ProcessPlaneRender:
    move.w  (v_planebuffer_addr).w,a5
    clr.w   (a5)
    lea (vdp_data_port).l,a5
    lea (v_planebuffer).w,a0
    move.w  #$8F00,d0
@flushloop:
    moveq   #0,d1
    move.b  #2,d0
    move.w  (a0)+,d1 ; get amount of tiles
    beq.w   @return ; return if amount of tiles is 0
    bpl.s   @rendercollumn
    neg.w   d1
    move.b  #$80,d0
@rendercollumn:
    move.w  d0,4(a5)
    moveq   #0,d2
    move.w  (a0)+,d2    ; get plane tile vram address
    lsl.l   #2,d2
    lsr.w   #2,d2
    or.w    #$4000,d2
    swap    d2
    move.l  d2,4(a5)
    cmp.w   #1,d1
    beq.s   @onetile
    lsr.w   #1,d1
    bcs.s   @writeodd  
    subq.w  #1,d1
@writeloop:
    move.l  (a0)+,(a5)
    dbf     d1,@writeloop
    bra.s   @flushloop

@writeodd:
    subq.w  #1,d1
    move.w  (a0)+,(a5)
@writeoddloop:
    move.l  (a0)+,(a5)
    dbf     d1,@writeoddloop
    bra.s   @flushloop

@onetile:
    move.w  (a0)+,(a5)
    bra.s   @flushloop

@return:
    move.w  #$8F02,4(a5)    ; reset vdp increment register
    ResetPlaneRender
    rts