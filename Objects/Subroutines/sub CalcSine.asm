; ---------------------------------------------------------------------------
; Subroutine calculate a sine

; input:
;	d0 = angle

; output:
;	d0 = sine
;	d1 = cosine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:
        andi.w  #$FF,d0
        addq.w  #8,d0
        add.w   d0,d0
        move.w  Sine_Data+($40*2)-16(pc,d0.w),d1
        move.w  Sine_Data-16(pc,d0.w),d0
        rts
; End of function CalcSine

; ===========================================================================

Sine_Data:	incbin	"Miscellaneous\sinewave.bin"	; values for a 360 degree sine wave

; ===========================================================================