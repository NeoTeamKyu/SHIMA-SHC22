; ---------------------------------------------------------------------------
; Player when they're drowning
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Player_Drowned:
		jsr  SpeedToPos		      ; Make Player able to move
		addi.w  #$10,y_vel(a0)		  ; Apply gravity
		bsr.w   Player_RecordPosition    ; Record position
		bsr.w   Player_Animate           ; Animate Player
		bsr.w   Player_LoadGfx           ; Load Player's DPLCs
		jmp   DisplaySprite           ; And finally, display Player