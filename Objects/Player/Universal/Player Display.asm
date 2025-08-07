; ---------------------------------------------------------------------------
; Subroutine to display Player and set music
; ---------------------------------------------------------------------------

Player_Display:
		move.b	flashtime(a0),d0
		beq.s	@display
		subq.b	#1,flashtime(a0)
		lsr.w	#3,d0
		bcc.s	@chkinvincible

	@display:
		jsr	(DisplaySprite).l

	@chkinvincible:
		tst.b	(v_invinc).w	; does Player have invincibility?
		beq.s	@chkshoes	; if not, branch
		tst.b	(v_super).w ; Prevent Player from getting (invincibility, shoes) if Super
		bne.w	ExitDisplay
		tst.b	invtime(a0)	; check	time remaining for invinciblity
		beq.s	@chkshoes	; if no	time remains, branch
		move.b	(v_framebyte).w,d0
		andi.b	#7,d0
		bne.s	@chkshoes
		subq.b	#1,invtime(a0)	; subtract 1 from time
		bne.s	@chkshoes
		tst.b	(f_lockscreen).w
		bne.s	@removeinvincible
		cmpi.w	#12,(v_air).w
		bcs.s	@removeinvincible
		jsr		ResumeMusic2

	@removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility

	@chkshoes:
		tst.b	(v_shoes).w	; does Player have speed	shoes?
		beq.s	ExitDisplay		; if not, branch
		tst.b	shoetime(a0)	; check	time remaining
		beq.s	ExitDisplay
		move.b	(v_framebyte).w,d0
		andi.b	#7,d0
		bne.s	ExitDisplay
		subq.b	#1,shoetime(a0)	; subtract 1 from time
		bne.s	ExitDisplay
		move.w	#$600,(v_plrspeedmax).w ; restore Player's speed
		move.w	#$C,(v_plrspeedacc).w ; restore Player's acceleration
		move.w	#$80,(v_plrspeeddec).w ; restore Player's deceleration
		btst	#6,obStatus(a0)	; is Player underwater?
		beq.s	@isdry		; if not, branch
		move.w	#$300,(v_plrspeedmax).w ; change Player's top speed
		move.w	#$6,(v_plrspeedacc).w	; change Player's acceleration
		move.w	#$40,(v_plrspeeddec).w	; change Player's deceleration
	@isdry:
		move.b	#0,(v_shoes).w	; cancel speed shoes
		command	mus_ShoesOff	; run music at normal speed

	ExitDisplay:
		rts