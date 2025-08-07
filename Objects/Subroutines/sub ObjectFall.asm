; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
		move.w	obVelX(a0),d0
		ext.l	d0
		lsl.l	#8,d0
		add.l	d0,obX(a0)
        cmp.w   #$FC8,obVelY(a0)   ; check if player's Y speed is lower than this value
        ble.s   @skipline       ; if yes, branch
        move.w  #$FC8,obVelY(a0)    ; alter player's Y speed
    
	@skipline:				
		move.w	obVelY(a0),d0	
		addi.w	#$38,obVelY(a0)	; increase vertical speed
		ext.l	d0
		lsl.l	#8,d0
		add.l	d0,obY(a0)
		rts	

; End of function ObjectFall