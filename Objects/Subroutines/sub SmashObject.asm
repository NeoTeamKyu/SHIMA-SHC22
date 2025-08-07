; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ walls and MZ	blocks)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

SmashObject:				; XREF: Obj3C_Smash
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,obRender(a0)
		move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
	;	move.w  obRespawnNo(a0),d0
	;	beq.s   .cont
	;	movea.w d0,a2
	;	bclr    #7,(a2)

	@cont:
		move.b	#4,obRoutine(a1)
		move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.w	(a4)+,obVelX(a1)
		move.w	(a4)+,obVelY(a1)
		move.w	(a4)+,obsmashGrav(a1)
		subq.w #1,d1
		lea (v_lvlobjspace).w,a1
		move.w #(v_lvlobjspace_End-v_lvlobjspace)/$40-1,d0
; ===========================================================================

Smash_Loop:
		tst.b (a1)
		beq.s @cont ; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w SingleObjLoad because we already know there's a free object slot in memory.
		lea $40(a1),a1
		dbf d0,Smash_Loop ; Branch correction again.
		bne.s Smash_PlaySnd ; We're moving this line here.
	@cont:
		; And that's it, copy/paste complete.
		addq.w #5,a3

Smash_LoadFrag:				; XREF: SmashObject
		move.b	#4,obRoutine(a1)
		move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.w	(a4)+,obVelX(a1)
		move.w	(a4)+,obVelY(a1)
		move.w	(a4)+,obsmashGrav(a1)

loc_D268:
		dbf	d1,Smash_Loop

Smash_PlaySnd:
		tst.b	d6
		beq.s	@noSound
	; Shitty hack to play no sound if this is passed.
		cmpi.b	#sfx_ChargeStop,d6
		beq.s	@ret
	; Oh well, lol
		move.b	d6,mQueue+2.w
		bra.s	@ret
	@noSound:
		sfx	sfx_Smash	; play smashing sound
	@ret:
		rts
; End of function SmashObject