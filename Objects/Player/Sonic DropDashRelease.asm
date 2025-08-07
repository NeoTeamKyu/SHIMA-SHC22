Sonic_ReleaseDropDash:	; d0 is dash, d1 is max, d2 is x vel, d3 is inertia, and... d4 is v_jpadpress1
		cmpi.b	#4,obDoubleJump(a0) ; Is the drop dash in flag 4
		bne.w	@done ; if not skip
		btst	#1,obStatus(a0)	; is sonic in the air?
		bne.w	@done ; if so, don't release it yet
		move.b	#0,obDoubleJump(a0)
		move.b	#0,obDoubleJump_property(a0) ; clear both the flag and the property
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,anim(a0)
		addq.w	#5,y_pos(a0)	; add the difference between Sonic's rolling and standing heights
		move.w	obVelX(a0),d2
		move.w	obInertia(a0),d3
		tst.b	(v_super).w	;  if ( v0->SuperMode == 2 )
		beq.s	@notsuper
		move.w	#$C00,d0	; dash and max to $C00 and $D00 respectively
		move.w	#$D00,d1
		bra.s	@donesetspd
	@notsuper:
		move.w	#$800,d0	; dash and max to $800 and $C00 respectively
		move.w	#$C00,d1
	@donesetspd:
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		bne.s	@left	; if so, branch	(yes)
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		bne.s	@cont	; if so, branch	(yes)
		btst	#0,obStatus(a0)	; facing right?
		beq.s	@cont   ; set is left, clear is right. 0 is left, 1 is right. if it's bne.s, @left activates when facing right...

	@left:
		neg.w	d2	; flip x vel that we're measuring.
		neg.w	d3	; and our inertia, too

	@cont:  ; facing right/holding right
		tst.w	d2	; is x vel greater than or equal to 0?
		bge.s	@gezero
		tst.b	obAngle(a0)
		bne.s   @notzero
		move.w	d0,d3
		bra.s   @cont2

    @notzero:
		asr.w   #1,d3   ; cut it in half
		add.w   d0,d3   ; and add it to dashspeed, resulting in a slower than normal dash... wait, that's /adding/ to $C00 or $800...
		bra.s   @cont2

	@gezero:
		asr.w	#2,d3	; divide d3 (our inertia) by 4,
		add.w	d0,d3	; add the divided inertia to our dashspeed,
		cmp.w	d3,d1	; and check if we're going faster than maxspeed.	(dest - source...)
		bgt.s	@cont2	; if it's negative... don't go there
		move.w	d1,d3	; cap it!   (moving maxdash to inertia)

	@cont2:
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		bne.s	@left2	; if so, branch	(yes)
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		bne.s	@cont3	; if so, branch	(yes)
		btst	#0,obStatus(a0)	; facing right?
		beq.s	@cont3   ; set is left, clear is right. 0 is left, 1 is right. if it's bne.s, @left activates when facing right...

	@left2:
		neg.w	d3

	@cont3:
		move.w  d3,obInertia(a0)
		bset	#2,status(a0)
		tst.b	(v_super).w
		beq.s	@notsuper2
		move.b	#6,(v_dust+anim).w
		move.w	#$10,(v_Ground_Y_screen_shake).w ; Screen shake not yet implemented (only for super)
		sfx	sfx_ChargeRelease ; play peelout release sound
		bra.s	@cont4
	@notsuper2:
		move.b	#5,(v_dust+anim).w
		sfx	sfx_Dash ; play dash sound
	@cont4:
		move.w	#$1000,(v_cameralag).w
		bsr.s	Reset_Player_Position_Array
	@done:
		rts

Reset_Player_Position_Array:
		lea	(v_trackPlayer).w,a2
		move.w	#$3F,d0

	@loop:
		move.w	obX(a0),(a2)+
		move.w	obY(a0),(a2)+
	;	move.l	#0,(a2)+
		dbf	d0,@loop
		move.w	#0,(v_trackpos).w
		rts
; End of function Reset_Sonic_Position_Array