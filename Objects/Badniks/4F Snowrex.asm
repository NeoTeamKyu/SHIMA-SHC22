; ---------------------------------------------------------------------------
; Object 4F - Snowrex enemy from Melting Heights Zone
; ---------------------------------------------------------------------------

Snowrex:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Snowrex_Index(pc,d0.w),d1
		jmp		Snowrex_Index(pc,d1.w)
; ===========================================================================
Snowrex_Index:
		dc.w	Snowrex_Main-Snowrex_Index
		dc.w	Snowrex_2ndRout-Snowrex_Index
		dc.w	Snowrex_Delete-Snowrex_Index
	; This stuff was copied from Crabmeat, but I don't care.
		dc.w	Snowrex_BallMain-Snowrex_Index
		dc.w	Snowrex_BallMove-Snowrex_Index
	; Ice cubes for your drink...?
		dc.w	Snowrex_FrozenSmashCheck-Snowrex_Index
; ===========================================================================

Snowrex_Main:	; Initialize stuff...
		move.l	#Map_Snowrex,obMap(a0)
		move.w	#vramSnowrexMHZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#16,obActWid(a0)
		move.b	#15,obHeight(a0)
		move.b	#6,obWidth(a0)
		tst.b	obSubtype(a0)
		bne.s	Snowrex_FrozenInCube
	
Snowrex_SetValues:
		move.b	#$C,obColType(a0)
		jsr		(ObjectFall).l		; Movement stuff.
		jsr		(ObjFloorDist).l	; Are we on the floor?
		tst.w	d1
		bpl.s	@floornotfound		; What ~~pumpkin~~ floor?
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)	; Go to Snowrex_2ndRout.
		bchg	#0,obStatus(a0)		; Turn around.
	@floornotfound:
		rts

Snowrex_FrozenInCube:
		move.b	#0,obFrame(a0)
		jsr		(DisplaySprite).l
		jsr		(FindFreeObj).l
		bne.s	@fail
		move.b	#$A,obRoutine(a0)
		move.b	#id_SmashBlock,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	a1,obParent(a0)

	@fail:
		rts

Snowrex_FrozenSmashCheck:
		move.b	#0,obFrame(a0)
		jsr		(DisplaySprite).l
		movea.w	obParent(a0),a1
		tst.b	(a1)
		jeq		DeleteObject
		cmpi.b	#4,obRoutine(a1)
		bhs.s	@smashed
		rts

	@smashed:
		clr.b	obSubtype(a0)
		bset	#2,obStatus(a0)		; Don't allow him to shoot immediately.
		clr.b	obRoutine(a0)
		jsr		(DisplaySprite).l
		bra.w	Snowrex_SetValues

Snowrex_2ndRout:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Snowrex_2ndIndex(pc,d0.w),d1
		jsr		Snowrex_2ndIndex(pc,d1.w)
		lea		(Ani_Snowrex).l,a1
		jsr		(AnimateSprite).l
		jmp		(RememberState).l
; ===========================================================================
Snowrex_2ndIndex:
		dc.w	Snowrex_Move-Snowrex_2ndIndex
		dc.w	Snowrex_CheckFloor-Snowrex_2ndIndex	; Fuck it.
		dc.w	Snowrex_Shoot-Snowrex_2ndIndex
		dc.w	Snowrex_ShootWait-Snowrex_2ndIndex
; ---------------------------------------------------------------------------
snowrex_moveTimer:	equ $32	; Originally used as a word, but I don't see the purpose of that.
; Bit 2 of obStatus tells whether it shot on this cycle.
; ===========================================================================

Snowrex_Move:
		subq.b	#1,snowrex_moveTimer(a0)
		cmpi.b	#30,snowrex_moveTimer(a0)	; If it's
		bpl.s	@ret						; *above* 30, return
		btst	#2,obStatus(a0)				; Have we shot already?
		bne.s	@cont						; if so, don't shoot again
	; This is where we check where the player is.
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		jsr		Obj_GetOrientationToPlayer
		move.w	d2,d4
		move.w	d3,d5
		bsr.w	Snowrex_TestCharPos			; is the player close enough to attack?
		beq.s	@cont						; If not, continue walking.
		move.b	#4,ob2ndRout(a0)			; Shoot.
		bra.w	Snowrex_Shoot

	@cont:
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$80,obVelX(a0)	; Stupid Sonic 2. $FF80 = -$80
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	@ret
		neg.w	obVelX(a0)
	@ret:
		rts

Snowrex_TestCharPos:
		addq.w	#8,d3			; Add 8px to test box Y position
		cmpi.w	#$68,d3			; is distance greater than $68 (104px)?
		bhs.s	@noShoot		; if yes, branch
		tst.w	d2				; is character to the left?
		bmi.s	@testLeft		; if yes, branch
		btst	#0,obStatus(a0)	; is object facing left, towards character?
		bne.s	@noShoot		; if not, branch
		bra.w	@testHorizDist

@testLeft:
		btst	#0,obStatus(a0)	; is object facing right, towards character?
		beq.s	@noShoot		; if not, branch
		neg.w	d2				; get absolute value

@testHorizDist:
		tst.w	d2				; is distance less than 0? (is player behind Snowrex?)
		blo.s	@noShoot		; if yes, don't attack
		cmpi.w	#$40,d2			; is distance less than $40 (64px)?
		blo.s	@inRange		; if yes, attack

@noShoot:
		moveq	#0,d2			; -> don't shoot at player
		rts

@inRange:
		moveq	#1,d2			; -> shoot at player
		rts

Snowrex_CheckFloor:
		jsr		(SpeedToPos).l
		jsr		(ObjFloorDist).l
		cmpi.w	#-$8,d1	; Stupid Sonic 2, again! $FFF8 = -8
		blt.s	@hitSide
		cmpi.w	#$C,d1
		bge.s	@hitSide
		add.w	d1,obY(a0)
		rts
	@hitSide:
		subq.b	#2,ob2ndRout(a0)
		move.b	#59,snowrex_moveTimer(a0)
		bclr	#2,obStatus(a0)	; Allow to shoot again.
		clr.w	obVelX(a0)
		move.b	#0,obAnim(a0)
		rts

Snowrex_Shoot:
		jsr		(FindFreeObj).l
		bne.s	@fail
		move.b	#id_Snowrex,obID(a1)
		move.b	#6,obRoutine(a1)	; It's a ball. (SPHERICAL)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#-$100,obVelX(a1)	; Move to the left.
		btst	#0,obStatus(a0)
		beq.s	@noFlip
		neg.w	obVelX(a1)			; Nevermind, move to the right.
	@noFlip:
		sfx		sfx_Dash
		move.b	#2,obAnim(a0)		; Shoot animation.
		addq.b	#2,ob2ndRout(a0)
	@fail:
		rts
	; Wait until you're done shooting...
Snowrex_ShootWait:
		tst.b	obTimeFrame(a0)
		bne.s	@notYet

		bset	#2,obStatus(a0)		; We shot.
		subq.b	#6,ob2ndRout(a0)

	@notYet:
		rts

Snowrex_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Sub-object - missile that the	Snowrex throws
; ---------------------------------------------------------------------------

Snowrex_BallMain:	; Routine 6
		bclr	#0,obShieldDeflect(a0)	; Not deflectable
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Snowrex,obMap(a0)
		move.w	#vramSnowrexMHZ,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#$87,obColType(a0)
		move.b	#16,obActWid(a0)
		move.w	#-$400,obVelY(a0)
		move.b	#4,obFrame(a0)

Snowrex_BallMove:	; Routine 8
		btst	#7,obStatus(a0)
		bne.s	@explode
		bsr.w	ObjectFall
		bsr.w	DisplaySprite
	; Check if it hit the floor, and if it did, set that bit
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	@nah
		bset	#7,obStatus(a0)
	; Continue
	@nah:
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below the level boundary?
		jcs		DeleteObject		; if yes, branch
		rts

	@explode:
		move.l	#0,obVelX(a0)	; Clears both X and Y speeds, since they're right next to eachother
		sfx		sfx_Explode		; Play explosion SFX.
		move.b	#id_FireShield_Dissipate,obID(a0) ; change object to an explosion (Obj24)
		move.b	#0,obRoutine(a0)
		jmp		(FireShield_Dissipate).l