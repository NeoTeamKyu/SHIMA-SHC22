; ---------------------------------------------------------------------------
; Subroutine to react to obColType(a0)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

ReactToItem:
		jsr		Touch_Rings	
		jsr		ShieldTouchResponse
		cmpi.b  #charID_Amy,(v_character).w
		bne.s	TouchResponse_NoHammer
	; All of this is Amy stuff
		cmpi.b	#$1F,obAnim(a0)		; is Amy hammering?
		bne.s 	TouchResponse_NoHammer	; branch if it isn't
		btst 	#0,obStatus(a0)
		beq	Collisions_Right
		move.w	obX(a0),d2		; load Amy's x-axis value
		move.w	obY(a0),d3		; load Amy's y-axis value
		subi.w	#$19,d2			; These values
		subi.w	#$1A,d3			; plus the next two
		move.w	#$22,d4			; represent the expanded
		move.w	#$32,d5			; attack range
		bra.s	Touch_Process	; branch to the object ram check
Collisions_Right:
		move.w	obX(a0),d2		; load Amy's x-axis value
		move.w	obY(a0),d3		; load Amy's y-axis value
		addi.w	#$19,d2			; These values
		subi.w	#$1A,d3			; plus the next two
		move.w	#$22,d4			; represent the expanded
		move.w	#$32,d5			; attack range
		sub.w	d4,d2
		bra.s	Touch_Process	; branch to the object ram check

TouchResponse_NoHammer:	; Non-Amy stuff
		move.w	obX(a0),d2	; load Player's x-axis position
		move.w	obY(a0),d3	; load Player's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5	; load Player's height
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#id_SpinDash,obAnim(a0)
		beq.s	@short
		cmpi.b	#id_Duck,obAnim(a0)
		bne.s	@notducking

	@short:
		addi.w	#$C,d3
		moveq	#$A,d5

	@notducking:
		move.w	#$10,d4
		add.w	d5,d5
Touch_Process:
		move.w	#0,a3
		lea	(v_lvlobjspace).w,a1 ; set object RAM start address
		move.w	#LevObjNum,d6

Touch_Loop:
		tst.b	obRender(a1)
		bpl.s	Touch_Next
		move.b	obColType(a1),d0 ; load collision type
		bne.s	Touch_Proximity	; if nonzero, branch

	Touch_Next:
		lea	SstLimit(a1),a1	; next object RAM
		dbf	d6,Touch_Loop	; repeat $5F more times
		rts
; ===========================================================================
Touch_Sizes:
;			width, height
		dc.b  $14, $14		; $01
		dc.b   $C, $14		; $02
		dc.b  $14,  $C		; $03
		dc.b	4, $10		; $04
		dc.b   $C, $12		; $05
		dc.b  $10, $10		; $06
		dc.b	6,   6		; $07
		dc.b  $18,  $C		; $08
		dc.b   $C, $10		; $09
		dc.b  $10,  $C		; $0A
		dc.b	8,   8		; $0B
		dc.b  $14, $10		; $0C
		dc.b  $14,   8		; $0D
		dc.b   $E,  $E		; $0E
		dc.b  $18, $18		; $0F
		dc.b  $28, $10		; $10
		dc.b  $10, $18		; $11
		dc.b	8, $10		; $12
		dc.b  $20, $70		; $13
		dc.b  $40, $20		; $14
		dc.b  $80, $20		; $15
		dc.b  $20, $20		; $16
		dc.b	8,   8		; $17
		dc.b	4,   4		; $18
		dc.b  $20,   8		; $19
		dc.b   $C,  $C		; $1A
		dc.b	8,   4		; $1B
		dc.b  $18,   4		; $1C
		dc.b  $28,   4		; $1D
		dc.b	4,   8		; $1E
		dc.b	4, $18		; $1F
		dc.b	4, $28		; $20
		dc.b	4, $20		; $21
		dc.b  $18, $18		; $22
		dc.b   $C, $18		; $23
		dc.b  $48,   8		; $24
	; new stuff
		dc.b  $20,  $C		; $25
		dc.b  $10,	$6		; $26
; ===========================================================================

Touch_Proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Touch_Sizes-2(pc,d0.w),a2
		
		btst	#6,obRender(a1)
		bne.s	Touch_Next
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	@outsidex	; branch if not touching
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	@withinx	; branch if touching
		bra.w	Touch_Next
; ===========================================================================

@outsidex:
		bsr	React_ChkWaterTag	;TIS
		cmp.w	d4,d0
		bhi.w	Touch_Next

@withinx:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	@outsidey	; branch if not touching
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	@withiny	; branch if touching
		bra.w	Touch_Next
; ===========================================================================

@outsidey:
		bsr	React_ChkWaterTag	;TIS
		cmp.w	d5,d0
		bhi.w	Touch_Next

@withiny:
	@chktype:
                
		move.b	obSubtype(a1),d1 ;TIS load subtype
		cmpi.b	#$F0,d1		;TIS - is subtype $F0?
		beq	React_WaterTag	;TIS if yes, branch
		cmpi.b	#$F1,d1		;TIS - is subtype $F0?
		beq	React_WaterTag	;TIS if yes, branch
		move.b	obColType(a1),d1 ; load collision type
		andi.b	#$C0,d1		; is obColType $40 or higher?
		beq.w	React_Enemy	; if not, branch
		cmpi.b	#$C0,d1		; is obColType $C0 or higher?
		beq.w	React_Special	; if yes, branch
		tst.b	d1		; is obColType $80-$BF?
		bmi.w	React_ChkHurt	; if yes, branch

; obColType is $40-$7F (powerups)

		move.b	obColType(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0		; is collision type $46	?
		beq.w	React_Monitor	; if yes, branch
        move.b	flashtime(a0),d0		; Get invulnerability_timer from whoever branched to TouchResponse

		cmpi.b	#90,d0					; Is there more than 90 frames on the timer remaining?
		bhs.w	@invincible					; If so, branch
		addq.b	#2,obRoutine(a1) ; advance the object's routine counter

	@invincible:
		rts

; Removed a routine called "TouchChild" because it's unnecessary for anything but Stagway, which has been removed in and of itself.

return_3F7C6:
	rts
; ===========================================================================

ShieldTouchResponse: ; code ported from Sonic 3K
		move.b	(v_shield).w,d0	
		and.b	#$E,d0			; does the player have any shields.
		beq.s	locret_1045C
		move.w	obX(a0),d2			; Get player's x_pos
		move.w	obY(a0),d3			; Get player's y_pos
		subi.w	#$12,d2				; Subtract width of shield
		subi.w	#$12,d3				; Subtract height of shield
		move.w	#$30,d4				; Player's width
		move.w	#$30,d5				; Player's height
		lea		(v_objspace).w,a1
		move.w	#(v_objspace_end-v_objspace)/$40-1,d6
		
ShieldTouch_Loop:
		move.b	obColType(a1),d0		; Get its collision_flags
		andi.b	#$C0,d0				; Get only collision type bits
		cmpi.b	#$80,d0				; Is only the high bit set ("harmful")?
		beq.s	ShieldTouch_Width		; If so, branch

ShieldTouch_NextObj:
		lea		$40(a1),a1 ; load obj address ; goto next object
		dbf		d6,ShieldTouch_Loop ; repeat 6F more times

locret_1045C:
		rts
; ---------------------------------------------------------------------------

ShieldTouch_Width:
		move.b	obColType(a1),d0		; Get collision_flags
		andi.w	#$3F,d0				; Get only collision size
		beq.s	ShieldTouch_NextObj		; If it doesn't have a size, branch
		add.w	d0,d0				; Turn into index
		lea		(Touch_Sizes).l,a2
		lea		(a2,d0.w),a2			; Go to correct entry
		moveq	#0,d1
		move.b	(a2)+,d1			; Get width value from Touch_Sizes
		move.w	obX(a1),d0			; Get object's x_pos
		sub.w	d1,d0				; Subtract object's width
		sub.w	d2,d0				; Subtract player's left collision boundary
		bhs.s	@checkrightside			; If player's left side is to the left of the object, branch
		add.w	d1,d1				; Double object's width value
		add.w	d1,d0				; Add object's width*2 (now at right of object)
		blo.s	ShieldTouch_Height		; If carry, branch (player is within the object's boundaries)
		bra.s	ShieldTouch_NextObj		; If not, loop and check next object
; ---------------------------------------------------------------------------

	@checkrightside:
		cmp.w	d4,d0				; Is player's right side to the left of the object?
		bhi.s	ShieldTouch_NextObj		; If so, loop and check next object

ShieldTouch_Height:
		moveq	#0,d1
		move.b	(a2)+,d1			; Get height value from Touch_Sizes
		move.w	obY(a1),d0			; Get object's y_pos
		sub.w	d1,d0				; Subtract object's height
		sub.w	d3,d0				; Subtract player's bottom collision boundary
		bcc.s	@checktop			; If bottom of player is under the object, branch
		add.w	d1,d1				; Double object's height value
		add.w	d1,d0				; Add object's height*2 (now at top of object)
		bcs.w	React_ChkHurt_Bounce			; If carry, branch (player is within the object's boundaries)
		bra.s	ShieldTouch_NextObj		; If not, loop and check next object
; ---------------------------------------------------------------------------

	@checktop:
		cmp.w	d5,d0				; Is top of player under the object?
		bhi.s	ShieldTouch_NextObj		; If so, loop and check next object

React_ChkHurt_Bounce:
		move.w	obX(a0),d1		; Find the vector between the player and the sprite
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr		(CalcAngle).l		; Find the angle of the vector
		jsr		(CalcSine).l		; Get the scalars for that angle
		muls.w	#-$800,d1		; Distribute a vector speed of -$800 along X and Y velocities at that angle
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	#-$800,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)	
		moveq	#-1,d0		; Break out of collision without hurting player
		rts			
; End of function ShieldTouchResponse

; ===========================================================================

React_Monitor:
		cmpi.b  #charID_Amy,(v_character).w
		bne.s	@moncont
		cmpi.b	#$29,obAnim(a0)	;"is Amy jump hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$28,obAnim(a0)	;"is Amy jump hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$22,obAnim(a0)	;"is Amy jump hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$20,obAnim(a0)	;"is Amy spin hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$1F,obAnim(a0)	;"is Amy hammering?"
		beq.w	@break_monitorcont2	; yes
	@moncont:
	; Removed monitor falling
	;	tst.w	obVelY(a0)	; is Player moving upwards?
	;	bpl.s	@movingdown	; if not, branch

	;	move.w	obY(a0),d0
	;	subi.w	#$10,d0
	;	cmp.w	obY(a1),d0
	;	bcs.w	@donothing
	;	neg.w	obVelY(a0)	; reverse Player's vertical speed
	;	move.w	#-$180,obVelY(a1)
	;	tst.b	ob2ndRout(a1)
	;	bne.w	@donothing
	;	addq.b	#4,ob2ndRout(a1) ; advance the monitor's routine counter
	;	rts
; ===========================================================================

@movingdown:
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@notamy
		cmpi.b	#$22,obAnim(a0)	;"is Amy jump hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$20,obAnim(a0)	;"is Amy spin hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#$1F,obAnim(a0)	;"is Amy hammering?"
		beq.w	@break_monitorcont2	; yes
		cmpi.b	#2,obAnim(a0)	; is Player rolling/jumping?
		bne.w	@donothing

	@notamy:
		cmpi.b	#charID_Legacy,(v_character).w
		bne.s	@notlegacy2
		cmpi.b	#id_DropDash,obAnim(a0)
		beq.w	@breaknorevy
		cmpi.b	#id_DieMad,obAnim(a0)
		beq.w	@breaknorevy

	@notlegacy2:
		cmpi.b	#charID_Mighty,(v_character).w ; Are we Mighty?
		bne.s	@notmighty2 ; if not check for Knuckles
		cmpi.b	#$22,obAnim(a0) ; Are we Hammer Dropping? (Note: Replace $22 with id)
		beq.w	@breaknorevy ; if so, break but without a bounce

	@notmighty2:
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notknux
		cmpi.b	#$20,obAnim(a0)
		beq.s	@break
		cmpi.b	#$26,obAnim(a0)
		beq.s	@break

	@notknux:
		tst.b	(v_character).w
		bne.s	@notsonic
		cmpi.b	#id_DropDash,obAnim(a0) ; is Sonic rolling/jumping?
		beq.s	@break
		btst	#6,obDoubleJump(a0)
		beq.w	@notsonic
		move.w	#0,x_vel(a0)
		move.w	#$600,y_vel(a0)
		btst	#6,status(a0)
		beq.s	@notuwhoming
		move.w	#$300,y_vel(a0)
	@notuwhoming:
		move.b	#0,obDoubleJump(a0)
		bclr	#6,obDoubleJump(a0)
		bra.s	@break
	@notsonic:
		cmpi.b	#id_Roll,obAnim(a0) ; is Sonic rolling/jumping?
		beq.s	@break
		tst.b	(v_springshoes).w
		beq.w	@donothing
		move.w  obX(a0),d1    ; move Player's x-position to d1
		move.w  obY(a0),d2    ; move Player's y-position to d2
		sub.w   obX(a1),d1    ; sub object x-position of Player's x-position
		sub.w   obY(a1),d2    ; sub object y-position of Player's y-position
		jsr    (CalcAngle).l
		subi.b    #$A0,d0
		cmpi.b    #$40,d0
		bcc.w    @donothing
	@break:
		neg.w	obVelY(a0)	; reverse Player's y-motion
	@breaknorevy:
		move.b	#1,jumping(a0)
		; check for smashable blocks
		move.w	#0,a3
		lea	(v_lvlobjspace).w,a2 ; set object RAM start address
		move.w	#LevObjNum,d6

	@loop:
		cmpi.b	#id_SmashBlock,(a2)
		bne.s	@next
		cmpi.b	#2,obRoutine(a2)
		bne.s	@next
		move.w	obX(a1),d0
		move.w	obX(a2),d1
		sub.w	d0,d1
		addi.w	#8,d1
		cmpi.w	#$10,d1
		bhi.s	@next
		move.w	obY(a1),d0
		move.w	obY(a2),d1
		sub.w	d0,d1
		addi.w	#8,d1
		cmpi.w	#$10,d1
		bhi.s	@next
		rts

	@next:
		lea	SstLimit(a2),a2	; next object RAM
		dbf	d6,@loop	; repeat $5F more times

		addq.b	#2,obRoutine(a1) ; advance the monitor's routine counter
		rts

	@break_monitorcont2:
		neg.w	obVelY(a0)
		btst	#3,obStatus(a0)	; is Player standing on the platform?
		beq.s	@break_monitorcont	; if not, branch
		bclr	#3,obStatus(a0)	; is Player rolling/jumping?
	@break_monitorcont:
		addq.b	#2,obRoutine(a1)	; advance the monitor's routine counter (2,$24)
		tst.w	(v_hammerspin).w	; was the monitor destroyed with a jumpdash?
		jne		BounceJD	; if yes, branch

	@donothing:
		rts
; ===========================================================================

React_Enemy:      
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@notamy
		cmpi.b	#$29,obAnim(a0)	; is Amy jump hammering?
		beq.w	 @donthurtsonic 	; if yes, branch
		cmpi.b	#$28,obAnim(a0)	; is Amy jump hammering?
		beq.w	 @donthurtsonic 	; if yes, branch
		cmpi.b	#$25,obAnim(a0)	; is Amy jump hammering?
		beq.w	 @donthurtsonic 	; if yes, branch
		cmpi.b	#$22,obAnim(a0)	; is Amy jump hammering?
		beq.w	 @donthurtsonic 	; if yes, branch
		cmpi.b	#$20,obAnim(a0)	; is Amy spin hammering?
		beq.w	 @donthurtsonic 	; if yes, branch
		cmpi.b	#$1F,obAnim(a0)	; is Amy hammering?
		beq.w	 @donthurtsonic 	; if yes, branch

@notamy:
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@notknux
		cmp.b	#1,KnucklesGlideState(a0)
		beq.w	@donthurtsonic
		cmp.b	#3,KnucklesGlideState(a0)
		beq.w	@donthurtsonic

	@notknux:
		tst.b	(v_invinc).w	; is Sonic invincible?
		bne.w	@donthurtsonic	; if yes, branch
		cmpi.b	#charID_Legacy,(v_character).w
		beq.s	@slcont
		tst.b	(v_character).w
		bne.s	@notsonicorlegacy

	@slcont:
		cmpi.b	#id_DropDash,obAnim(a0)	; Same ID as down kick, perfect!
		beq.w	@donthurtsonic
		tst.b	(v_character).w
		beq.s	@notsonicorlegacy
		cmpi.b	#id_DieMad,obAnim(a0)
		beq.w	@donthurtsonic
		
	@notsonicorlegacy:
		cmpi.b	#charID_Mighty,(v_character).w ; Are we Mighty?
		bne.s	@notmighty3 ; if not Skip Hammer Drop Check
		cmpi.b	#$22,obAnim(a0) ; Are we Hammer Dropping? (Note: Replace $22 with id)
		beq.w	@donthurtsonic ; if so, don't hurt Mighty

	@notmighty3:
		tst.b	(v_springshoes).w
		beq.s	@nosprings
		move.w  obX(a0),d1    ; move Sonic's x-position to d1
		move.w  obY(a0),d2    ; move Sonic's y-position to d2
		sub.w   obX(a1),d1    ; sub object x-position of Sonic's x-position
		sub.w   obY(a1),d2    ; sub object y-position of Sonic's y-position
		jsr    (CalcAngle).l
		subi.b    #$A0,d0
		cmpi.b    #$40,d0
		bcs.w    @donthurtsonic

	@nosprings:
		cmpi.b	#id_Spindash,obAnim(a0)
		beq.w	@donthurtsonic
		cmpi.b	#id_Roll,obAnim(a0) ; is Sonic rolling/jumping?
		beq.w	@donthurtsonic
		cmpi.b	#$22,obAnim(a0)
		beq.w	@donthurtsonic
		cmpi.b	#charID_Tails,(v_character).w
		bne.w	React_ChkHurt

	@tails:
		tst.b    obDoubleJump(a0)        ; is Tails flying?
		beq.w    React_ChkHurt    ; if not, branch
		btst    #6,obStatus(a0)        ; is Tails underwater?
		bne.w    React_ChkHurt        ; if yes, branch
		move.w  obX(a0),d1    ; move Tails' x-position to d1
		move.w  obY(a0),d2    ; move Tails' y-position to d2
		sub.w   obX(a1),d1    ; sub object x-position of Tails' x-position
		sub.w   obY(a1),d2    ; sub object y-position of Tails' y-position
		jsr    (CalcAngle).l
		subi.b    #$20,d0
		cmpi.b    #$40,d0
		bcc.w    React_ChkHurt

	@donthurtsonic:
		tst.b	obColProp(a1)
		beq.s	@breakenemy
		cmpi.b	#charID_Legacy,(v_character).w
		bne.s	@notlegacy
		cmpi.b	#id_DropDash,obAnim(a0)
		beq.s	@skipbouncing
		cmpi.b	#id_DieMad,obAnim(a0)
		beq.s	@skipbouncing
	@notlegacy:
		cmpi.b	#charID_Mighty,(v_character).w ; Are we Mighty?
		bne.s	@notmighty ; if not, bounce
		cmpi.b	#$22,obAnim(a0) ; Are we Hammer Dropping? (Note: Replace $22 with id)
		beq.w	@skipbouncing ; if so, skip bounce

	@notmighty:
		cmpi.b	#charID_Knuckles,(v_character).w
		bne.s	@cont
		cmp.b	#1,KnucklesGlideState(a0)
		bne.s	@cont
		move.b	#2,KnucklesGlideState(a0)
		move.b	#$21,anim(a0)
@cont:			
		neg.w	obVelX(a0)	; repel Sonic
		neg.w	obVelY(a0)
		asr	obVelX(a0)
		asr	obVelY(a0)
	@skipbouncing:
		move.b	#0,obColType(a1)
		subq.b	#1,obColProp(a1)
		bne.s	@flagnotclear
		bset	#7,obStatus(a1)

	@flagnotclear:
		rts
; ===========================================================================

@breakenemy:
		bset	#7,obStatus(a1)
		moveq	#0,d0
		move.w	(v_itembonus).w,d0
		addq.w	#2,(v_itembonus).w ; add 2 to item bonus counter
		cmpi.w	#6,d0
		bcs.s	@bonusokay
		moveq	#6,d0		; max bonus is lvl6

	@bonusokay:
		move.w	d0,$3E(a1)
		move.w	@points(pc,d0.w),d0
		cmpi.w	#$20,(v_itembonus).w ; have 16 enemies been destroyed?
		bcs.s	@lessthan16	; if not, branch
		move.w	#1000,d0	; fix bonus to 10000
		move.w	#$A,$3E(a1)

	@lessthan16:
		jsr		AddPoints
		move.b	#id_ExplosionItem,obID(a1) ; change object to explosion
		move.b	#0,obRoutine(a1)
		btst	#6,obDoubleJump(a0)
		beq.w	@nothoming
		move.w	#0,x_vel(a0)
		move.w	#-$600,y_vel(a0)
		btst	#6,status(a0)
		beq.s	@notuwhoming
		move.w	#-$300,y_vel(a0)
	@notuwhoming:
		move.b	#0,obDoubleJump(a0)
		bclr	#6,obDoubleJump(a0)
		rts

@points:	dc.w 10, 20, 50, 100	; points awarded div 10

	@nothoming:
		cmpi.b	#charID_Legacy,(v_character).w
		bne.s	@skip
		cmpi.b	#id_DropDash,obAnim(a0)
		beq.s	@lt16leg
		cmpi.b	#id_DieMad,obAnim(a0)
		beq.s	@lt16leg

	@skip:
		cmpi.b	#charID_Mighty,(v_character).w ; Are we Mighty?
		bne.s	@notmighty4 ; if not, bounce
		cmpi.b	#$22,obAnim(a0) ; Are we Hammer Dropping? (Note: Replace $22 with id)
		beq.w	@lt16leg; if so, skip bounce

	@notmighty4:
		tst.w	obVelY(a0)
		bmi.s	@bouncedown
		move.w	obY(a0),d0
		cmp.w	obY(a1),d0
		bcc.s	@bounceup
		neg.w	obVelY(a0)
		move.b	#1,jumping(a0)
		rts

	@lt16leg:
		move.w	obY(a0),d0
		rts
; ===========================================================================

	@bouncedown:
		addi.w	#$100,obVelY(a0)
		rts

	@bounceup:
		subi.w	#$100,obVelY(a0)
		rts

; ===========================================================================

FireObjects:
		dc.b	$14, $35, $4D, $4E, $54, $6D, $74
FireObjects_end:
		even
				
React_Caterkiller:
		bset	#7,obStatus(a1)

React_ChkHurt:
		cmpi.b	#shID_Fire,(v_shield).w 
		bne.s	@noFireShield
		lea		FireObjects(pc),a2
		moveq	#FireObjects_end-FireObjects-1,d0

	@loop:	
		move.b	(a2)+,d1
		cmp.b	(a1),d1
		beq.s	@isflashing
		dbf		d0,@loop

	@noFireShield:		
		cmpi.b	#shID_Elec,(v_shield).w
		bne.s	@noLightningShield
		cmpi.b	#$6E,(a1)
		beq.s	@isflashing
	
	@noLightningShield:
		tst.b	(v_invinc).w	; is Sonic invincible?
		beq.s	@notinvincible	; if not, branch

; loc_3F86A:
@isflashing:
		moveq	#-1,d0
		rts
; ===========================================================================

	@notinvincible:
		cmpi.b	#charID_Mighty,(v_character).w
		bne.s	@notMighty
		btst	#0,obShieldDeflect(a1)		; Test the "bounce off shield" bit in the sprite's shield reaction type
		beq.s	@notMighty	; If it's not set, ignore the checks
		cmpi.b	#id_roll,obAnim(a0)
		beq.w	React_ChkHurt_Bounce
		cmpi.b	#id_duck,obAnim(a0)
		beq.w	React_ChkHurt_Bounce
		cmpi.b	#id_spindash,obAnim(a0)
		beq.w	React_ChkHurt_Bounce
		cmpi.b	#$22,obAnim(a0)
		beq.w	React_ChkHurt_Bounce

	@notMighty:
		nop
		tst.b	flashtime(a0)		; is Sonic flashing?
		bne.s	@isflashing	; if yes, branch
		movea.l	a1,a2

; End of function ReactToItem
; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
		btst	#bitGodMode,(v_miscOptions).w
		beq.s	@cont ; Player has god mode enabled.
		rts
	@cont:
		tst.b	(v_springshoes).w	; does Sonic have a pogo spring?
		bne.s	@hasPogoSpring	; if yes, branch
		tst.b	(v_shield).w	; does Sonic have a shield?
		bne.s	@hasShield	; if yes, branch
		tst.w	(v_rings).w	; does Sonic have any rings?
		beq.w	@norings	; if not, branch

		jsr	(FindFreeObj).l
		bne.s	@hasShield
		move.b	#id_RingLoss,obID(a1) ; load bouncing multi rings object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
	; Going to assume this is for Abbey.
	; After all, her second routine is to find rings,
	; so it makes sense that she would go into a frenzy
	; and pick up your rings after you lose them.
		tst.b	(v_character).w
		bne.s	@hasShield
		move.b	#2,(v_followobject+obRoutine).w	; Make Abbey go pick up any rings in the area ASAP.

	@hasShield:
		clr.b	(v_shield).w	; remove shield
		bra.s	@contNoRingLoss
	@hasPogoSpring:
		clr.b	(v_springshoes).w	; remove shoes
	@contNoRingLoss:
		move.b	#4,obRoutine(a0)
		jsr		Player_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#-$400,obVelY(a0) ; make Sonic bounce away from the object
		move.w	#-$200,obVelX(a0)
		btst	#6,obStatus(a0)	; is Sonic underwater?
		beq.s	@isdry		; if not, branch

		move.w	#-$200,obVelY(a0) ; slower bounce
		move.w	#-$100,obVelX(a0)

	@isdry:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		bcs.s	@isleft		; if Sonic is left of the object, branch
		neg.w	obVelX(a0)	; if Sonic is right of the object, reverse

	@isleft:
		move.b #0,spindash_flag(a0) ; clear Spin Dash flag
		move.w	#0,obInertia(a0)
		move.b	#id_Hurt,obAnim(a0)
		move.b	#$78,flashtime(a0)	; set temp invincible time to 2 seconds
		move.w	#sfx_Death,d0	; load normal damage sound
		cmpi.b	#id_Spikes,(a2)	; was damage caused by spikes?
		beq.s	@setspikesound	; if so, branch
		cmpi.b	#id_Harpoon,(a2) ; was damage caused by LZ harpoon?
		bne.s	@sound		; if not, branch

	@setspikesound:	; if not, branch
		moveq	#sfx_SpikeHit,d0 ; load spikes damage sound

	@sound:
		move.b	d0,mQueue+2.w
		moveq	#-1,d0
		rts
; ===========================================================================

@norings:
		tst.w	(f_debugmode).w	; is debug mode	cheat on?
		bne.w	@hasshield	; if yes, branch

; ---------------------------------------------------------------------------
; Subroutine to	kill Player
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillPlayer:
		tst.w	(v_debuguse).w	; is debug mode	active?
		bne.s	@dontdie	; if yes, branch
		move.b	#0,(v_invinc).w	; remove invincibility
		move.b	#6,obRoutine(a0)
		jsr	Player_ResetOnFloor
		bset	#1,obStatus(a0)
		move.w	#-$700,obVelY(a0)
		move.w	#0,obInertia(a0)
		move.w	obY(a0),$38(a0)
		move.b	#id_Death,obAnim(a0)
		bset	#7,obGfx(a0)
		move.w	#sfx_Death,d0	; play normal death sound
		cmpi.b	#id_Spikes,(a2)	; check	if you were killed by spikes
		bne.s	@sound
		moveq	#sfx_SpikeHit,d0 ; load spikes damage sound

	@sound:
		move.b	d0,mQueue+2.w

	@dontdie:
		moveq	#-1,d0
		rts
; End of function KillPlayer


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


React_Special:
		move.b	obColType(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1		; is collision type $CB	?
		beq.s	@caterkiller	; if yes, branch
		cmpi.b	#$C,d1		; is collision type $CC	?
		beq.s	@yadrin		; if yes, branch
		cmpi.b	#$17,d1		; is collision type $D7	?
		beq.s	@D7orE1		; if yes, branch
		cmpi.b	#$21,d1		; is collision type $E1	?
		beq.s	@D7orE1		; if yes, branch
		rts
; ===========================================================================

@caterkiller:
		bra.w	React_Caterkiller
; ===========================================================================

@yadrin:
		sub.w	d0,d5
		cmpi.w	#8,d5
		bcc.s	@normalenemy
		move.w	obX(a1),d0
		subq.w	#4,d0
		btst	#0,obStatus(a1)
		beq.s	@noflip
		subi.w	#$10,d0

	@noflip:
		sub.w	d2,d0
		bcc.s	@loc_1B13C
		addi.w	#$18,d0
		bcs.s	@loc_1B140
		bra.s	@normalenemy
; ===========================================================================

	@loc_1B13C:
		cmp.w	d4,d0
		bhi.s	@normalenemy

	@loc_1B140:
		bra.w	React_ChkHurt
; ===========================================================================

	@normalenemy:
		bra.w	React_Enemy
; ===========================================================================

@D7orE1:
		addq.b	#1,obColProp(a1)
		rts
; End of function React_Special

; ||||||||||||||| S U B    R O U T    I N E |||||||||||||||||||||||||||||||||||||||

React_ChkWaterTag:
		cmpi.b    #1,(v_tagwater).w    ;TIS
		bne    NotWaterTag
		move.b    #0,(v_tagwater).w    ;TIS
	NotWaterTag:
		rts

React_WaterTag:
		cmpi.b    #1,(v_tagwater).w    ;TIS
		beq    SkipWaterTag
		move.b    #1,(v_tagwater).w    ;TIS
	SkipWaterTag:
		rts