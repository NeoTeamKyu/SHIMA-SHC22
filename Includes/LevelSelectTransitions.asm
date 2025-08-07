; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select transitions (very WIP)
; ---------------------------------------------------------------------------

LevSelTrans_FadeRight:
    dc.l	@init   ; constructor
    dc.l    @run    ; executor
    dc.l    @end    ; destructor

; ===========================================================================
; Variables

    rsset 4 
    @sst_curfaderow: rs.b   1
    @sst_endfaderow: rs.b   1

; ===========================================================================

    @init:
        move.b  #40,@sst_endfaderow(a0)
        clr.b   @sst_curfaderow(a0)
        addq.l  #4,(a0) ; go to exectutor
        rts

    @run:
        addq.b  #1,@sst_curfaderow(a0)
        moveq   #0,d0
        move.b  @sst_curfaderow(a0),d0
        cmp.b   @sst_endfaderow(a0),d0
        blt.s   @cont
        addq.l  #4,(a0) ; go to destructor
    @cont:
        move.l  #($8680+$29)<<16+($8680+$29),d2
	    jsr     LevSel_FillRow
        rts

    @end:
        clr.l   (a0)
        rts

; ===========================================================================

LevSelTrans_FadeLeft:
    dc.l	@init   ; constructor
    dc.l    @run    ; executor
    dc.l    @end    ; destructor

; ===========================================================================
; Variables

    rsset 4 
    @sst_curfaderow: rs.b   1

; ===========================================================================

    @init:
        move.b  #40,@sst_curfaderow(a0)
        addq.l  #4,(a0)
        rts
    @run:
        subq.b  #1,@sst_curfaderow(a0)
        bne.s   @return
        addq.l  #4,(a0)
    @return:
        rts
    @end:
        clr.l   (a0)
        rts

; ===========================================================================