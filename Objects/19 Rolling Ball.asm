; ---------------------------------------------------------------------------
; Object 19 - GHZ rolling ball
; ---------------------------------------------------------------------------

RollingBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RollingBall_Index(pc,d0.w),d1
		jsr	RollingBall_Index(pc,d1.w)
		jmp	RememberState
; ===========================================================================
RollingBall_Index:	dc.w RollingBall_Spawn-RollingBall_Index
		dc.w RollingBall_Main-RollingBall_Index
		dc.w RollingBall_Waiting-RollingBall_Index
		dc.w RollingBall_Landing-RollingBall_Index
		dc.w RollingBall_MovingRiding-RollingBall_Index
; ===========================================================================
RollingBall_Spawn:
		lea		(v_ball).w,a1
		jsr		DeleteChild
		suba.w	#SstLimit,a1
		move.b	(a0),(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#2,obRoutine(a1)
		jmp		DeleteObject

; ===========================================================================
RollingBall_Main:
		; Increment routine
		addq.b	#2,obRoutine(a0) ; RollingBall_Waiting
		
		; Initialize graphics, and other properties
		move.l	#Map_GBall,obMap(a0)
		move.w	#$4000+vramBallLBGZ,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#20,obActWid(a0)
		move.w	#$280,obPriority(a0)
		move.b	#2,obStatus(a0)
		
		; Initialize collision size
		move.b	#9,obWidth(a0)
		move.b	#24,obHeight(a0)
		
RollingBall_Waiting:
		; Line up with floor
		jsr	(ObjFloorDist).l
		add.w	d1,obY(a0)

	@nobug:
		; Check if Player is to the right of us yet, and start moving if so
		move.w	(v_player+8).w,d0
		tst.w	obInertia(a0)
		beq.s	@notmoving
		addq.b	#2,obRoutine(a0) ; RollingBall_Landing
		bra.s	RollingBall_Landing

	@notmoving:
		cmp.w	obX(a0),d0
		ble.s	@left
		addq.b	#2,obRoutine(a0) ; RollingBall_Landing
		move.w	#$80,obInertia(a0)
		bra.s	RollingBall_Landing
		
	@left:
		; Act as solid
		move.w	obX(a0),d4
		bsr.w	RollingBall_Animate
		bra.w	RollingBall_Solid
		
; ===========================================================================

RollingBall_Landing:
		btst	#3,obStatus(a0)
		beq.w	RollingBall_MovingMain
		addq.b	#2,obRoutine(a0)
		move.b	#2,(v_SpringShoes).w
	;	move.b	#1,(f_jumponly).w

RollingBall_MovingRiding:
	;	cmpi.b	(v_SpringShoes).w
	;	beq.w	RollingBall_Falling
		tst.w	(v_debuguse).w
		bne.w	RollingBall_Falling
		btst	#3,obStatus(a0)
		beq.w	RollingBall_Falling
		lea	(v_player).w,a1
		tst.b	$30(a0)
		beq.s	@nospindash
		tst.b	spindash_flag(a1)
		bne.s	@nospindash
		move.b	#0,$30(a0)
		move.w	obInertia(a1),d0
		asr.w	d0
		neg.w	d0
		add.w	d0,obInertia(a1)
		bra.w	@saveinertia

	@nospindash:
		move.b	spindash_flag(a1),$30(a0)
		btst	#2,obStatus(a1)
		bne.s	@saveinertia2
		move.w	(v_plrspeedmax).w,d6
		move.w	(v_plrspeedacc).w,d5
		asr.w	d5
		move.w	(v_plrspeeddec).w,d4
		asr.w	d4
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		bne.s	@holdright	; if so, branch
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		bne.s	@holdleft	; if so, branch
		bra.s	@saveinertia2

	@holdright:
		bset	#0,obRender(a1)
		move.w	obInertia(a0),d0
		bmi.s	@stoppingright
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	@saveinertia
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	@saveinertia
		move.w	d6,d0
		bra.s	@saveinertia

	@stoppingright:
		add.w	d4,d0
		bcc.s	@saveinertia
		move.w	#$80,d0
		bra.s	@saveinertia

	@holdleft:
		bclr	#0,obRender(a1)
		move.w	obInertia(a0),d0
		bpl.s	@stoppingleft
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	@saveinertia
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	@saveinertia
		move.w	d1,d0
		bra.s	@saveinertia

	@stoppingleft:
		sub.w	d4,d0
		bcc.s	@saveinertia
		move.w	#-$80,d0

	@saveinertia:
		move.w	d0,obInertia(a0)

	@saveinertia2:
		bsr.s	RollingBall_MovingMain
		move.w	ObX(a0),ObX(a1)
		rts

RollingBall_Falling:
		subq.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)
		clr.b	(v_SpringShoes).w
	;	move.b	#0,(f_jumponly).w

RollingBall_MovingMain:
		; Remember our original x-position for solid stuff
		move.w	obX(a0),d4
		btst	#1,obStatus(a0)
		beq.s	@notfalling
		jsr	Player_HitFloor
		tst.w	d1
		bpl.s	@falling
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bclr	#1,obStatus(a0)
		move.w	obVelX(a0),obInertia(a0)

	@notfalling:
		; Get pushed by floor below us
		jsr		(RollingBall_RollRepel).l
		; Set our velocity from our inertia and angle
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bsr.w	RollingBall_HitWall
        move.w    d4,-(sp)
		bsr.w	RollingBall_Collide
        move.w    (sp)+,d4
		jsr		SpeedToPos
		move.b	#9,obWidth(a0)
		bsr.w	RollingBall_DestroyEnemies
		bsr.w	RollingBall_Animate
		bra.w	RollingBall_Solid

	@falling:
		bsr.w	RollingBall_HitWall
		jsr		ObjectFall
		move.b	#9,obWidth(a0)
		bsr.w	RollingBall_DestroyEnemies
		bsr.w	RollingBall_Animate
		bra.w	RollingBall_Solid
		; Draw and unload once off-scre
		
; = Player collision routine ================================================
RollingBall_Solid:
		move.w	obX(a0),d4
		move.w	#34,d1 ; Add 10, Player's width
		move.w	#24,d2
		move.w	#24,d3
		jsr	SolidObject
		cmpi.b	#1,d4
		bne.s	@done
		tst.w	$32(a0)
		beq.s	@Playerstill
		move.w	$32(a0),d0
		asr.w	#2,d0
		move.w	obX(a1),d1
		sub.w	obX(a0),d1
		bpl.s	@checkleft
		btst	#0,obStatus(a1)
		beq.s	@noproblem
		neg.w	d0
		bra.s	@noproblem

	@checkleft:
		btst	#0,obStatus(a1)
		bne.s	@noproblem
		neg.w	d0

	@noproblem:
		add.w	d0,obInertia(a0)
		move.b	#4,obRoutine(a0)
		bra.s	@done

	@Playerstill:
		subi.w	#$10,obInertia(a0)
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		bpl.s	@done
		addi.w	#$20,obInertia(a0)

	@done:
		move.w	obInertia(a1),$32(a0)
		rts

; = Level collision routine =================================================
RollingBall_Collide:
		addi.b	#4,obWidth(a0)
		move.b	(v_top_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		btst	#4,obStatus(a0)
		beq.s	@14602
		rts

	@14602:
		moveq	#3,d0
		move.b	d0,(v_anglebuffer).w
		move.b	d0,(v_anglebuffer+2).w
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		bpl.s	@14624
		move.b	obAngle(a0),d0
		bpl.s	@1461E
		subq.b	#1,d0

	@1461E:
		addi.b	#$20,d0
		bra.s	@14630
; ===========================================================================

	@14624:
		move.b	obAngle(a0),d0
		bpl.s	@1462C
		addq.b	#1,d0

	@1462C:
		addi.b	#$1F,d0

	@14630:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	@WalkVertL
		cmpi.b	#$80,d0
		beq.w	@WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	@WalkVertR
	;	subi.b	#11,obWidth(a0)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		jsr	FindFloor	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer+2).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		jsr	FindFloor	; MJ: check solidity
		move.w	(sp)+,d0
		jsr	Player_Angle
		tst.w	d1
		beq.s	@146BE
		bpl.s	@146C0
		cmpi.w	#-$E,d1
		blt.s	@146E6
		add.w	d1,obY(a0)

	@146BE:
		rts	
; ===========================================================================

	@146C0:
		cmpi.w	#$E,d1
		bgt.s	@146CC

	@146C6:
		add.w	d1,obY(a0)
		rts	
; ===========================================================================

	@146CC:
		bset	#1,obStatus(a0)
		rts	
; ===========================================================================

	@146E6:
		rts	

	@WalkVertR:
		jmp	Player_WalkVertR

	@WalkCeiling:
		jmp	Player_WalkCeiling

	@WalkVertL:
		jmp	Player_WalkVertL


; = Wall collision routine =================================================
RollingBall_HitWall:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	@1307C
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	@1307C
		bmi.s	@13024
		neg.w	d1

	@13024:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		jsr	RollingBall_RollSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	@1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	@13078
		cmpi.b	#$40,d0
		beq.s	@13066
		cmpi.b	#$80,d0
		beq.s	@13060
		add.w	d1,obVelX(a0)
		neg.w	obInertia(a0)
		rts	
; ===========================================================================

	@13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

	@13066:
		sub.w	d1,obVelX(a0)
		neg.w	obInertia(a0)
		rts	
; ===========================================================================

	@13078:
		add.w	d1,obVelY(a0)

	@1307C:
		rts	

RollingBall_RollSpeed:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(v_anglebuffer).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	@14D1A
		move.b	d1,d0
		bpl.s	@14D14
		subq.b	#1,d0

	@14D14:
		addi.b	#$20,d0
		bra.s	@14D24
; ===========================================================================

	@14D1A:
		move.b	d1,d0
		bpl.s	@14D20
		addq.b	#1,d0

	@14D20:
		addi.b	#$1F,d0

	@14D24:
		andi.b	#$C0,d0
		beq.s	@14DF0
		cmpi.b	#$80,d0
		beq.s	@14F7C
		andi.b	#$38,d1
		bne.s	@14D3C
		addq.w	#8,d2

	@14D3C:
		cmpi.b	#$40,d0
		beq.s	@1504A
		addi.w	#24,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		jsr	FindWall	; MJ: check solidity
		move.b	#-$40,d2
		bra.w	@14E0A

	@14DF0:
		addi.w	#24,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		jsr	FindFloor	; MJ: check solidity
		move.b	#0,d2

	@14E0A:
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	@14E16
		move.b	d2,d3

	@14E16:
		rts

	@14F7C:
		subi.w	#24,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		jsr	FindFloor	; MJ: check solidity
		move.b	#-$80,d2
		bra.s	@14E0A

	@1504A:
		subi.w	#24,d3
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		jsr	FindWall	; MJ: check solidity
		move.b	#$40,d2
		bra.s	@14E0A

; = Slope gravity speed =====================================================
RollingBall_RollRepel:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		asr.l	#1,d0
		add.w	d0,obInertia(a0)
		rts

; = Animation routine =======================================================
			even
RollingBall_AnimN: dc.b 1, 1, 1
			even
RollingBall_AnimR:	dc.b 1, 2, 3
			even
RollingBall_AnimL:	dc.b 3, 2, 1
			even

RollingBall_Animate:
		; Wait for next frame
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from frame duration
		bpl.s	@postanimate		; if time remains, branch to post animate
		
		; Get our speed factor
		move.w	obInertia(a0),d0
		bmi.s	@nonegspeed
		neg.w	d0
@nonegspeed:
		addi.w	#$400,d0
		bpl.s	@nocap
		moveq	#0,d0
@nocap:
	
		; Apply to our frame duration
		lsr.w	#7,d0
		move.b	d0,obTimeFrame(a0)
		tst.b	(f_jumponly)
		beq.s	@nextframe
		move.b	d0,obTimeFrame(a1)
	
@nextframe:
		; Go to next frame
		addi.b	#1,obAniFrame(a0)
		cmpi.b	#3,obAniFrame(a0)
		blt.s	@postanimate
		move.b	#0,obAniFrame(a0)
@postanimate:
		
		; Get our appropriate animation
		tst.w	obInertia(a0)
		beq.s	@still
		bmi.s	@left
		lea	(RollingBall_AnimR).l,a1
		bra.s	@loadframe
@left:
		lea	(RollingBall_AnimL).l,a1
		bra.s	@loadframe
@still:
		lea	(RollingBall_AnimN).l,a1
		
@loadframe:
		; Copy our animation frame
		moveq	#0,d0
		move.b	obAniFrame(a0),d0
		move.b	(a1,d0.w),obFrame(a0)
		
		; Check if we should blink
		btst	#0,(v_vbla_byte).w
		beq.s	@noblink
		move.b	#0,obFrame(a0)
@noblink:
		rts
		
; = Collision with enemeies =================================================

RollingBall_DestroyEnemies:
		move.w	obX(a0),d2	; load the ball's x-axis position
		move.w	obY(a0),d3	; load the ball's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	#24,d5	; load the ball's height
		subq.b	#3,d5
		sub.w	d5,d3
		move.w	#24,d4
		add.w	d5,d5
		lea	(v_lvlobjspace).w,a1 ; set object RAM start address
		move.w	#LevObjNum-1,d6

	@loop:
		tst.b	obRender(a1)
		bpl.s	@next
		move.b	obColType(a1),d0 ; load collision type
		bne.w	@proximity	; if nonzero, branch

	@next:
		lea	SstLimit(a1),a1	; next object RAM
		dbf	d6,@loop	; repeat $5F more times

		moveq	#0,d0
		rts	
; ===========================================================================
@sizes:		;   width, height
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
; ===========================================================================

	@proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	@sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	@outsidex	; branch if not touching
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	@withinx	; branch if touching
		bra.w	@next
; ===========================================================================

@outsidex:
		cmp.w	d4,d0
		bhi.w	@next

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
		bra.w	@next
; ===========================================================================

@outsidey:
		cmp.w	d5,d0
		bhi.w	@next

@withiny:
	@chktype:
		move.b	obColType(a1),d1 ; load collision type
		andi.b	#$C0,d1		; is obColType $40 or higher?
		beq.w	@breakenemy	; if not, branch
	;	cmpi.b	#$C0,d1		; is obColType $C0 or higher?
	;	beq.w	@breakenemy	; if yes, branch
		addq.b	#2,obRoutine(a1) ; advance the monitor's routine counter
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
		jsr	AddPoints
		move.b	#id_ExplosionItem,0(a1) ; change object to explosion
		move.b	#0,obRoutine(a1)
		rts

@points:	dc.w 10, 20, 50, 100	; points awarded div 10

; ===========================================================================