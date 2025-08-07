; ---------------------------------------------------------------------------
; HUD Object code - SCORE, TIME, RINGS
; --------------------------------------------------------------------------- 
loc_40804:
		tst.w	(v_rings).w
		beq.s	loc_40820
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		bne.s	loc_40836
		cmpi.b	#9,(v_timemin).w
		bne.s	loc_40836
		addq.w	#2,d1
		bra.s	loc_40836
; ===========================================================================

loc_40820:
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		bne.s	loc_40836
		addq.w	#1,d1
		cmpi.b	#9,(v_timemin).w
		bne.s	loc_40836
		addq.w	#2,d1

loc_40836:
		move.w	#0,d3
		move.b	(v_movehud).w,d3		
		move.w	#$108,d2
		lea		(Map_HUD).l,a1
		movea.w	#vramHUD,a3
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	return_40858
		jsr		sub_D762

return_40858:
		rts
; End of function
