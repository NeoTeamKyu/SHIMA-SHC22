; ---------------------------------------------------------------------------
; Subroutine for Player when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_Water:
		tst.b	(f_water).w
		bne.s	@haswater	; if yes, branch

	@exit:
		rts
; ===========================================================================

	@haswater:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; is Player above the water?
		bge.w	@abovewater	; if yes, branch
		tst.w	obVelY(a0)	; check if player is moving upward (i.e. from jumping)
		bmi.s	@exit	; if yes, skip routine
		bset	#6,obStatus(a0)	; Set underwater bit
		bne.s	@exit
	;	bsr.w	ResumeMusic
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_objspace+$340+$32).w
		cmpi.b	#charID_Metal,(v_character).w
		beq.s	@contNoFilter
		cmpi.b	#shID_Bubb,(v_shield).w
		beq.s	@contNoFilter
		command	mus_ToWater	; get into water(tm)
	@contNoFilter:
		move.b	#id_DrownCount,(v_bubbles).w ; load bubbles object from Player's mouth
		move.b	#$81,(v_bubbles+obSubtype).w
	; Normal
		move.w	#$300,(v_plrspeedmax).w ; change Player's top speed
		move.w	#6,(v_plrspeedacc).w ; change Player's acceleration
		move.w	#$40,(v_plrspeeddec).w ; change Player's deceleration

		tst.b	(v_super).w	; Is character Super?
		beq.s	@skip			; If not branch
	; Super
		move.w	#$500,(v_plrspeedmax).w
		move.w	#$18,(v_plrspeedacc).w
		move.w	#$80,(v_plrspeeddec).w
	@skip:
		tst.b	(v_shoes).w	; does Player have Speed Shoes?
		beq.s	@noshoesbelow	; if not, branch
	; Speed shoes, deceleration was already set by Normal
		move.w	#$600,(v_plrspeedmax).w ; change Player's top speed
		move.w	#$C,(v_plrspeedacc).w ; change Player's acceleration
		move.w	#$80,(v_plrspeeddec).w	; Change player's deceleration, because apparently speed shoes' deceleration is supposed to be 2x normal
	@noshoesbelow:
		asr	obVelY(a0)		; Slow player once. The other two happen if they fail to water skim.
		beq.w	@exit		; branch if Player stops moving
		move.w	#$100,(v_dust+obAnim).w	; splash animation
		sfx	sfx_Splash	; play splash sound
	; Water skimming. Made entirely by me (Gemini) in like. ten minutes.
		btst	#1,obStatus(a0)	; In the air?
		beq.s	@noSkim			; If not, return.
		btst	#2,obStatus(a0)	; Spinning?
		beq.s	@noSkim			; If not, return.
		cmpi.b	#id_Roll,obAnim(a0)	; Are you SUUUUURE?
		beq.s	@continue			; If so, get over there.
		cmpi.b	#id_Roll2,obAnim(a0); ABSOLUTELY FUCKING POSITIVE?
		beq.s	@continue			; If so, get over there.
		tst.b	(v_character).w
		bne.s	@continue
		cmpi.b	#id_DropDash,obAnim(a0)	; Okay, but are we drop dashing as Sonic??
		bne.s	@noSkim
	@continue:
		btst	#0,obStatus(a0)	; Okay, but are you facing left or right?
		beq.s	@right			; If right, go there. If left, continue.
	@left:
		cmpi.w	#-$680,obVelX(a0)
		bgt.s	@noSkim
		bra.s	@skim
	@right:
		cmpi.w	#$680,obVelX(a0)
		blt.s	@noSkim
	@skim:
		neg.w	obVelY(a0)
		rts
	@noSkim:
		asr	obVelX(a0)
		asr	obVelY(a0)	; slow Player.
	@ret:
		rts
; ===========================================================================

@abovewater:
		bclr	#6,obStatus(a0)
		beq.w	@exit
	;	bsr.w	ResumeMusic
		move.w	#30,(v_air).w	; reset air to 30 seconds
		clr.b	(v_objspace+$340+$32).w
		command	mus_OutWater	; get out of water(tm)
	; Normal
		move.w	#$600,(v_plrspeedmax).w ; restore Player's speed
		move.w	#$C,(v_plrspeedacc).w ; restore Player's acceleration
		move.w	#$80,(v_plrspeeddec).w ; restore Player's deceleration
	
		tst.b	(v_super).w	; Is Player Super?
		beq.s	@Skipout			; If not branch
	; Super
		move.w	#$A00,(v_plrspeedmax).w	; Fixed values: these were the underwater ones
		move.w	#$30,(v_plrspeedacc).w
		move.w	#$100,(v_plrspeeddec).w
@Skipout:
		tst.b	(v_shoes).w	; does Player have Speed Shoes?
		beq.s	@noshoesbelow1	; if not, branch
	; Speed Shoes, deceleration already set by Normal ; Gem: Fixed values, these were using regular Player's.
		move.w	#$C00,(v_plrspeedmax).w ; change Player's top speed
		move.w	#$18,(v_plrspeedacc).w	; change Player's acceleration
		move.w	#$100,(v_plrspeeddec).w
	@noshoesbelow1:
		cmpi.b	#4,obRoutine(a0)	; is Player falling back from getting hurt?
		beq.s	@hurtFalling		; if yes, branch
		asl	obVelY(a0)
	@hurtFalling:
		tst.w	obVelY(a0)
		beq.w	@exit
		move.w	#$100,(v_dust+obAnim).w	; splash animation
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	@belowmaxspeed
		move.w	#-$1000,obVelY(a0) ; set maximum speed on leaving water

	@belowmaxspeed:
		sfx	sfx_Splash	; play splash sound
		rts
; End of function Player_Water