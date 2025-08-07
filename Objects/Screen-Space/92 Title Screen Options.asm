; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------

TitleOpt:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TSO_Index(pc,d0.w),d1
		jsr	TSO_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
TSO_Index:
		dc.w TSO_Main-TSO_Index
		dc.w TSO_Menu-TSO_Index
; ===========================================================================

TSO_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#284,obX(a0)
		move.w	#300,obY(a0)
		move.l	#Map_TSO,obMap(a0)
		move.w	#$200,obGfx(a0)
	
TSO_Menu:
		move.b	(v_jpadpress1).w,d2
		btst	#bitDn,d2	; is up	pressed?
		beq.s	@TSOUp		; if not, check for up
		sfx		sfx_Choose
		addq.b	#1,(v_titleoptions).w	; add 1 to the crap
		cmpi.b	#3,(v_titleoptions).w	; is it 2?
		bne.s	@return	; if it's 2 or less, go away
		clr.b	(v_titleoptions).w

	@TSOUp:
		btst	#bitUp,d2	; is up	pressed?
		beq.s	@return
		sfx		sfx_Choose
		subq.b	#1,(v_titleoptions).w
		bpl.s	@return
	;	cmpi.b	#-1,(v_titleoptions).w
	;	bne.s	@return
		move.b	#2,(v_titleoptions).w

	@return:
		move.b	(v_titleoptions).w,obFrame(a0)
		rts