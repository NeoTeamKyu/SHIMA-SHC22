; ---------------------------------------------------------------------------
; Subroutine for Player to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_Floor:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Player_HitLeftWall
		cmpi.b	#$80,d0
		beq.w	Player_HitCeilingAndWalls
		cmpi.b	#$C0,d0
		beq.w	Player_HitRightWall
		jsr		Player_HitWall
		tst.w	d1
		bpl.s	loc_135F0
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

		btst	#bitL,(v_jpadhold2).w
		beq.s	loc_135F0
		bsr.w	WallJump

loc_135F0:
		jsr 	sub_14EB4
		tst.w	d1
		bpl.s	loc_13602
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

		btst	#bitR,(v_jpadhold2).w
		beq.s	loc_13602
		bsr.w	WallJump

loc_13602:
		jsr	Player_HitFloor
		tst.w	d1
		bpl.w	locret_1367E
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361E
		cmp.b	d2,d0
		blt.s	locret_1367E

loc_1361E:
		move.b	d3,obAngle(a0)
		add.w	d1,obY(a0)
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@shf2
		tst.b	obDoubleJump_property(a0)
		beq.s	@part2
		move.b	#$29,obAnim(a0)
		bra.s	@shf2
	@part2:
		move.b	#0,obAnim(a0)
	@shf2:
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr	obVelY(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		jsr	(Player_ResetOnFloor).l
;		move.b	#id_Walk,obAnim(a0)	; some kind of fix? maybe pushing??
		rts	
; ===========================================================================

loc_1365C:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670
		move.w	#$FC0,obVelY(a0)

loc_13670:
		jsr	(Player_ResetOnFloor).l
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1367E
		neg.w	obInertia(a0)

locret_1367E:
		rts	
; ===========================================================================

Player_HitLeftWall:
		jsr		Player_HitWall
		tst.w	d1
		bpl.s	loc_1369A
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

loc_1369A:
		jsr	Player_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_136B4
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_136B2
		move.w	#0,obVelY(a0)

locret_136B2:
		rts	
; ===========================================================================

loc_136B4:
		tst.w	obVelY(a0)
		bmi.s	locret_136E0
		jsr	Player_HitFloor
		tst.w	d1
		bpl.s	locret_136E0
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		jsr	(Player_ResetOnFloor).l
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@end
	; Amy code
		tst.b	obDoubleJump_property(a0)
		beq.s	@part3
		move.b	#$29,obAnim(a0)	;	faceplant animation
		bra.s	@end
	@part3:
		move.b	#0,obAnim(a0)
	@end:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_136E0:
		rts	
; ===========================================================================

Player_HitCeilingAndWalls:
		jsr 	Player_HitWall
		tst.w	d1
		bpl.s	loc_136F4
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

		btst	#bitL,(v_jpadhold2).w
		beq.s	loc_136F4
		bsr.w	WallJump

loc_136F4:
		jsr	sub_14EB4
		tst.w	d1
		bpl.s	loc_13706
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

		btst	#bitR,(v_jpadhold2).w
		beq.s	loc_13706
		bsr.w	WallJump
loc_13706:
		jsr	Player_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_1373C
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726
		move.w	#0,obVelY(a0)
		rts	
; ===========================================================================

loc_13726:
		move.b	d3,obAngle(a0)
		jsr	(Player_ResetOnFloor).l
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1373C
		neg.w	obInertia(a0)

locret_1373C:
		rts	
; ===========================================================================

Player_HitRightWall:
		jsr	sub_14EB4
		tst.w	d1
		bpl.s	loc_13758
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

loc_13758:
		jsr	Player_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_13772
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_13770
		move.w	#0,obVelY(a0)

locret_13770:
		rts	
; ===========================================================================

loc_13772:
		tst.w	obVelY(a0)
		bmi.s	locret_1379E
		jsr	Player_HitFloor
		tst.w	d1
		bpl.s	locret_1379E
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		jsr	(Player_ResetOnFloor).l
		cmpi.b	#charID_Amy,(v_character).w
		bne.s	@cont
		tst.b	obDoubleJump_property(a0)
		beq.s	@part4
		move.b	#$29,obAnim(a0)
		bra.s	@cont
	@part4:
		move.b	#0,obAnim(a0)
	@cont:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_1379E:
		rts	
; End of function Player_Floor
