; ---------------------------------------------------------------------------
; Subroutine to    display    a sprite/object, when a0 is the    object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B    R O U T    I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
        lea    (v_spritequeue).w,a1
        adda.w  obPriority(a0),a1 ; get sprite priority
        cmpi.w    #$7E,(a1)    ; is this part of the queue full?
        bcc.s    DSpr_Full    ; if yes, branch
        addq.w    #2,(a1)        ; increment sprite count
        adda.w    (a1),a1        ; jump to empty position
        move.w    a0,(a1)        ; insert RAM address for object

    DSpr_Full:
        rts    

; End of function DisplaySprite


; ---------------------------------------------------------------------------
; Subroutine to    display    a 2nd sprite/object, when a1 is    the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B    R O U T    I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite1:
        lea    (v_spritequeue).w,a2
        adda.w  obPriority(a1),a2
        cmpi.w    #$7E,(a2)
        bcc.s    DSpr1_Full
        addq.w    #2,(a2)
        adda.w    (a2),a2
        move.w    a1,(a2)

    DSpr1_Full:
        rts    

; End of function DisplaySprite1

DisplaySprite2:
    lea    (v_spritequeue).w,a1
    adda.w    d0,a1
    cmpi.w    #$7E,(a1)
    bhs.s    return_16542
    addq.w    #2,(a1)
    adda.w    (a1),a1
    move.w    a0,(a1)

return_16542:
    rts
; End of function DisplaySprite