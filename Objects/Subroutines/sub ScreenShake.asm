; =============== S U B R O U T I N E =======================================


ShakeScreen_Setup:
		move.w	(v_Screen_shake_offset).w,(v_Screen_shake_last_offset).w
		moveq	#0,d1
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_4F406
		move.w	(v_Screen_shake_flag).w,d0
		beq.s	loc_4F406
		bmi.s	loc_4F3FA
		subq.w	#1,d0					; If EECC is positive, then it's a timed screen shake
		move.w	d0,(v_Screen_shake_flag).w
		move.b	ScreenShakeArray(pc,d0.w),d1
		ext.w	d1
		bra.s	loc_4F406
; ---------------------------------------------------------------------------

loc_4F3FA:
		move.w	(v_framecount).w,d0		; If EECC is negative, it's a constant screen shake
		andi.w	#$3F,d0
		move.b	ScreenShakeArray2(pc,d0.w),d1

loc_4F406:
		move.w	d1,(v_Screen_shake_offset).w
		rts
; End of function ShakeScreen_Setup


; =============== S U B R O U T I N E =======================================


ShakeScreen_BG:
		move.w	(v_Glide_screen_shake).w,d0
		beq.s	locret_4F422
		subq.w	#1,d0
		move.w	d0,(v_Glide_screen_shake).w
	;	move.b	ScreenShakeArray(pc,d0.w),d0
	;	ext.w	d0
	;	add.w	d0,(v_bgscreenposx_dup_unused).w

locret_4F422:
		rts
; End of function ShakeScreen_BG

; =============== S U B R O U T I N E =======================================


ShakeScreen_BG_Y:
		move.w	(v_Ground_Y_screen_shake).w,d0
		beq.s	locret_4F422_Y
		subq.w	#1,d0
		move.w	d0,(v_Ground_Y_screen_shake).w
		move.b	ScreenShakeArray(pc,d0.w),d0
		ext.w	d0
		add.w	d0,(v_bgscrposy_dup).w

locret_4F422_Y:
		rts
; End of function ShakeScreen_BG_Y

; ---------------------------------------------------------------------------
ScreenShakeArray:
		dc.b   1, -1,  1, -1,  2, -2,  2, -2,  3, -3,  3, -3,  4, -4,  4, -4
		dc.b   5, -5,  5, -5
ScreenShakeArray2:
		dc.b   1,  2,  1,  3,  1,  2,  2,  1,  2,  3,  1,  2,  1,  2,  0,  0
		dc.b   2,  0,  3,  2,  2,  3,  2,  2,  1,  3,  0,  0,  1,  0,  1,  3
		dc.b   1,  2,  1,  3,  1,  2,  2,  1,  2,  3,  1,  2,  1,  2,  0,  0
		dc.b   2,  0,  3,  2,  2,  3,  2,  2,  1,  3,  0,  0,  1,  0,  1,  3

		dc.w   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
		dc.w  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.w   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
		dc.w  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.w   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
		dc.w  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.w   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
		dc.w  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.w   1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0
		dc.w   0,  0,  0,  0,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

		dc.w   0,  0, -1, -1, -1, -1, -1, -1,  0,  0,  0,  1,  1,  1,  1,  1
		dc.w   1,  0,  0,  0, -1, -1, -1, -1, -1, -1,  0,  0,  0,  1,  1,  1
		dc.w   1,  1,  1,  0,  0,  0, -1, -1, -1, -1, -1, -1,  0,  0,  0,  1
		dc.w   1,  1,  1,  1,  1,  0, -1, -2, -2, -1,  0,  2,  2,  2,  2,  0
		dc.w   0,  0, -1, -1, -1, -1, -1, -1,  0,  0,  0,  1,  1,  1,  1,  1
		dc.w   1,  0,  0,  0, -1, -1, -1, -1, -1, -1,  0,  0,  0,  1,  1,  1