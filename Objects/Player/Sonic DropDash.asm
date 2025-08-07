Sonic_DropDash: ; AngelKOR64: Code converted from my S3K hack to make use of the InstaAndShieldMoves format easier
		tst.b	(v_super).w
		bne.s	@cont
		cmpi.b	#1,(v_shield).w
		bgt.s	DropDash_Return
	@cont:
		move.b    (v_jpadhold2).w,d0
		andi.b    #btnABC,d0    ; is A, B or C pressed?
		beq.w	DropDash_Return	; if not, return
		move.b	#3,obDoubleJump(a0) ; Set the Double Jump flag to 3
;		bclr	#4,obStatus(a0) not necessary but I'll keep it here commented just in case
		addq.b	#1,obDoubleJump_property(a0) ; Begin the counter
		cmpi.b	#22,obDoubleJump_property(a0) ; Has it been 21 frames
		beq.s	DropDash_Start ;if so, Start the Drop Dash
		bra.s	DropDash_Return ; otherwise, return

DropDash_Start:
		move.b  #id_DropDash,obAnim(a0) ; set the animation
		move.b	#4,obDoubleJump(a0) ;set the flag to 4 (to skip this code afterwards)
		sfx     sfx_DropDash		; play Drop Dash sound
		rts
; ---------------------------------------------------------------------------

DropDash_Continue:
		move.b    (v_jpadhold2).w,d0
		andi.b    #btnABC,d0 ; is A, B or C still held?
		beq.w	Reset_DropDash	; if not, reset the Drop Dash
		bra.s	DropDash_Return

Reset_DropDash:
		move.b	#0,obDoubleJump_property(a0) ; 
		move.b	#0,obDoubleJump(a0) ; Clear the flag
		move.b	#0,jumping(a0) ; clear the jumping flag
		move.b  #id_Roll,obAnim(a0) ; Set to rolling animation
		sfx     sfx_DropCancel		; play Drop Dash cancel sound

DropDash_Return:
		rts