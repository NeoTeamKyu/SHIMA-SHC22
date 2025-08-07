; ---------------------------------------------------------------------------
; Subroutine to	record Player's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_RecordPosition:
		move.w	(v_trackpos).w,d0
		lea	(v_trackPlayer).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(v_trackbyte).w
		rts	
; End of function Player_RecordPosition