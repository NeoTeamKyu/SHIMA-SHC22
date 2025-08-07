; ---------------------------------------------------------------------------
; Subroutine to find a free object space

; output:
;	a1 = free position in object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFreeObj:
		lea	(v_lvlobjspace).w,a1 ; start address for object RAM
		move.w	#LevObjNum-1,d0

	@loop:
		tst.b	(a1)		; is object RAM	slot empty?
		beq.s	@found	; if yes, branch
		lea	SstLimit(a1),a1	; goto next object RAM slot
		dbf	d0,@loop	; repeat $5F times

		if DEBUG
			RaiseError "No Free Objects Found"
		endif

	@found:
		rts	

; End of function FindFreeObj


; ---------------------------------------------------------------------------
; Subroutine to find a free object space AFTER the current one

; output:
;	a1 = free position in object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindNextFreeObj:
		movea.l	a0,a1
		move.w	#v_lvlobjspace_End,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		if DEBUG
			blo.s	@overflow
		else
			blo.s	@found
		endif

	@loop:
		tst.b	(a1)
		beq.s	@found
		lea	SstLimit(a1),a1
		dbf	d0,@loop

	@found:
		rts	

		if DEBUG
	@overflow:
			RaiseError "No Free Objects Found after a0"
		endif

; End of function FindNextFreeObj