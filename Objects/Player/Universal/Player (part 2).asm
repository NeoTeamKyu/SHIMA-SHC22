; ---------------------------------------------------------------------------
; Player when they get hurt
; ---------------------------------------------------------------------------

Player_Hurt:	; Routine 4
		clr.b	(v_cameralag).w
		jsr	(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)	; Underwater?
		beq.s	@cont
		subi.w	#$20,obVelY(a0)
		cmpi.b	#charID_Metal,(v_character).w
		beq.s	@cont
		command	mus_ToWater	; get into water(tm)

	@cont:
		bsr.w	Player_HurtStop
		bsr.w	Player_LevelBound
		bsr.w	Player_RecordPosition
		bsr.w	Player_Animate
		bsr.w	Player_Water
		bsr.w	Player_LoadGfx
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine to	stop Player falling after they've been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_HurtStop:
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0
		bcs.s	@kill
		bsr.w	Player_Floor
		btst	#1,obStatus(a0)
		bne.s	@ret
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,flashtime(a0)

	@ret:
		rts

	@kill:
		jmp	KillPlayer
; End of function Player_HurtStop

; ---------------------------------------------------------------------------
; Player when they die
; ---------------------------------------------------------------------------

Player_Death:	; Routine 6
		tst.w	(f_debugmode).w
		beq.s	@cont
		btst	#btnB,(v_jpadpress1).w
		beq.s	@cont
		move.w	#1,(v_debuguse).w
		clr.b	(f_lockctrl).w
		rts
	@cont:
		tst.b	(v_super).w
		beq.s	@cont2
		clr.b	(v_super).w
		move.b	#2,(v_superpal).w
	@cont2:
		bsr.w	GameOver
		jsr	(ObjectFall).l
		bsr.w	Player_RecordPosition
		bsr.w	Player_Animate
		bsr.w	Player_LoadGfx
		jmp	(DisplaySprite).l

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:
		move.w	(v_screenposy).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	locret_13900
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w	; stop time counter
		btst	#bitLives,(v_miscOptions).w	; Did the player turn off lives?
		bne.w	loc_138D4	; They won't be losing any anyway, so go away.
		addq.b	#1,(f_lifecount).w ; update lives counter
		subq.b	#1,(v_lives).w	; subtract 1 from number of lives
		bne.s	loc_138D4
		move.w	#0,$3A(a0)
		move.b	#id_GameOverCard,(v_gameover).w ; load GAME object
		move.b	#0,(v_gameover+obRoutine).w
		move.b	#id_GameOverCard,(v_banner).w ; load OVER object
		move.b	#0,(v_banner+obRoutine).w
		move.b	#1,(v_banner+obFrame).w ; set OVER object to correct frame
		clr.b	(f_timeover).w

loc_138C2:
		music	mus_GameOver	; play game over music
		moveq	#3,d0
		jmp	(AddPLC).l	; load game over patterns
; ===========================================================================

loc_138D4:
		move.w	#60,$3A(a0)	; set time delay to 1 second
		tst.b	(f_timeover).w	; is TIME OVER tag set?
		beq.s	locret_13900	; if not, branch
		move.w	#0,$3A(a0)
		move.b	#id_GameOverCard,(v_gameover).w ; load TIME object
		move.b	#0,(v_gameover+obRoutine).w
		move.b	#id_GameOverCard,(v_banner).w ; load OVER object
		move.b	#0,(v_banner+obRoutine).w
		move.b	#2,(v_gameover+obFrame).w
		move.b	#3,(v_banner+obFrame).w
		bra.s	loc_138C2
; ===========================================================================

locret_13900:
		rts
; End of function GameOver

; ---------------------------------------------------------------------------
; Player when the level is restarted
; ---------------------------------------------------------------------------

Player_ResetLevel:; Routine 8
		tst.w	$3A(a0)
		beq.s	@ret
		subq.w	#1,$3A(a0)	; subtract 1 from time delay
		bne.s	@ret
		move.w	#1,(f_restart).w ; restart the level

	@ret:
		rts