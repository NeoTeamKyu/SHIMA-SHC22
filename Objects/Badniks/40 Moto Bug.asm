; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (BGZ)
; ---------------------------------------------------------------------------

MotoBug:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Moto_Index(pc,d0.w),d1
		jmp	Moto_Index(pc,d1.w)
; ===========================================================================
Moto_Index:	dc.w Moto_Main-Moto_Index
		dc.w Moto_Action-Moto_Index
		dc.w Moto_Animate-Moto_Index
		dc.w Moto_Delete-Moto_Index
		dc.w Moto_Flame-Moto_Index
; ===========================================================================

Moto_Main:	; Routine 0
		move.l	#Map_Moto,obMap(a0)
		move.w	#vramMotobugLBGZ,obGfx(a0)	; Different VRAM location for LBGZ.
		cmpi.b	#3,(v_act)
		beq.s	@LBGZ
		move.w	#vramMotobugBGZ,obGfx(a0)
	@LBGZ:
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#$14,obActWid(a0)
		cmpi.b	#2,obAnim(a0)	; is object an exhaust flame?
		beq.s	@flame		; if yes, branch
		move.b	#$E,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.b	#$C,obColType(a0)
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	@notonfloor
		add.w	d1,obY(a0)	; match	object's position with the floor
		move.w	#0,obVelY(a0)
		addq.b	#2,obRoutine(a0) ; goto Moto_Action next
		bchg	#0,obStatus(a0)

	@notonfloor:
		rts
; ===========================================================================

@flame:
		move.b	#8,obRoutine(a0) ; goto Moto_Animate next
		bra.w	Moto_Animate
; ===========================================================================

Moto_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Moto_ActIndex(pc,d0.w),d1
		jsr	Moto_ActIndex(pc,d1.w)
		lea	(Ani_Moto).l,a1
		bsr.w	AnimateSprite

		include	"Objects/Subroutines/sub RememberState.asm" ; Moto_Action terminates in this file

; ===========================================================================
Moto_ActIndex:	dc.w @move-Moto_ActIndex
		dc.w @findfloor-Moto_ActIndex

Moto_Time:		equ $30
; ===========================================================================

@move:
		subq.w	#1,Moto_Time(a0)	; subtract 1 from pause	time
		bpl.s	@wait		; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$100,obVelX(a0) ; move object to the left
		subq.w	#1,obX(a0)
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	@cont
		neg.w	obVelX(a0)	; change direction
		addq.w	#2,obX(a0)

	@cont:
		move.l	obParent3(a0),a1
		cmpi.b	#id_MotoBug,obID(a1)
		beq.s	@wait
		jsr		Obj_GetOrientationToPlayer
		move.w	d2,d4
		move.w	d3,d5
		bsr.w	Moto_TestCharPos	; is the player close enough to attack?
		beq.s	@done
		move.w	obVelX(a0),d3
		asl.w	#1,d3
		move.w	d3,obVelX(a0)
		bra.s	@loadExhaustFlame

	@wait:
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	@done:
		rts
; ===========================================================================

@findfloor:
		bsr.w	SpeedToPos
		jsr	(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	@pause
		cmpi.w	#$C,d1
		bge.s	@pause
		add.w	d1,obY(a0)	; match	object's position with the floor
		bra.s	@cont

	@loadExhaustFlame:
		bsr.w	FindFreeObj
		bne.s	@noflame

		move.b	#id_MotoBug,obID(a1) ; load exhaust flame object
;		move.b	#8,obRoutine(a1) ; causes the flame to not appear
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)
		move.l	a0,obParent3(a1)
		move.l	a1,obParent3(a0)
		sfx	sfx_UnknownRevving

	@noflame:
		rts

@pause:
		subq.b	#2,ob2ndRout(a0)
		move.w	#59,Moto_Time(a0)	; set pause time to 1 second
		move.w	#0,obVelX(a0)	; stop the object moving
		move.b	#0,obAnim(a0)
		rts

Moto_TestCharPos:
		addi.w	#$20,d3
		cmpi.w	#$40,d3			; is character too low?
		bhs.s	@noCharge	; if yes, branch
		tst.w	d2			; is character to the left?
		bmi.s	@testLeft	; if yes, branch
		tst.w	obVelX(a0)		; is object moving left, towards character?
		bpl.s	@noCharge	; if not, branch
		bra.w	@testHorizDist

@testLeft:
		tst.w	obVelX(a0)		; is object moving right, towards character?
		bmi.s	@noCharge	; if not, branch
		neg.w	d2			; get absolute value

@testHorizDist:
		cmpi.w	#$20,d2			; is distance less than $20?
		blo.s	@noCharge	; if yes, don't attack
		cmpi.w	#$70,d2			; is distance less than $A0?
		blo.s	@inRange	; if yes, attack

@noCharge:
		moveq	#0,d2			; -> don't charge at player
		rts

@inRange:
		moveq	#1,d2			; -> charge at player
		rts
; ===========================================================================

Moto_Animate:	; Routine 4
		lea	(Ani_Moto).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Moto_Delete:	; Routine 6
		bra.w	DeleteObject

Moto_Flame:
		move.l	obParent3(a0),a1
		cmpi.b	#id_MotoBug,obID(a1)
		bne.s	@del
		tst.b	Moto_Time(a1)
		beq.s	@del
;		addq.w	#7,obY(a0)
;		moveq	#$D,d0
;		btst	#0,obStatus(a0)
;		beq.s	@noflip
;		neg.w	d0
;	
;	@noflip:
;		add.w	d0,obX(a0)
		jmp		Moto_Animate

	@del:
		bra.s	Moto_Delete