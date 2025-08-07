; ----------------------------------------------------------------------------
; Object 2B - Wind-Up Koi (fish badnik) from BGZ
; ----------------------------------------------------------------------------
; OST Variables:
WindUpKoi_move_timer	= $2C	; time to wait before turning around
WindUpKoi_bubble_timer	= $2E	; time to wait before producing a bubble
WindUpKoi_prevframe		= $30
; Sprite_36DAC:
WindUpKoi:
		cmpi.w	#(id_BGZ<<8)+3,(v_zone).w
		bne.s	@cont
		jmp		Chopper
	@cont:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	WindUpKoi_Index(pc,d0.w),d1
		jmp	WindUpKoi_Index(pc,d1.w)
; ===========================================================================
; off_36DBA:
WindUpKoi_Index:
		dc.w WindUpKoi_Init-WindUpKoi_Index		; 0 - Initialize object variables
		dc.w WindUpKoi_Main-WindUpKoi_Index		; 2 - Moving back and forth until Sonic or Tails approach
		dc.w WindUpKoi_Waiting-WindUpKoi_Index	; 4 - Stopped, opening and closing mouth
		dc.w WindUpKoi_Charge-WindUpKoi_Index		; 6 - Charging at Sonic or Tails
; ===========================================================================
; loc_36DC2:
WindUpKoi_Init:
		lea		WindUpKoi_SubObjData(pc),a1
		bsr.w	LoadSubObject_Part3
		move.w	#$200,WindUpKoi_move_timer(a0)
		move.b	#$50,WindUpKoi_bubble_timer(a0)
		move.b	#-1,WindUpKoi_prevFrame(a0)
		moveq	#$40,d0		; enemy speed
		btst	#0,obStatus(a0)	; is enemy facing left?
		bne.s	@cont		; if not, branch
		neg.w	d0		; else reverse movement direction
	@cont:
		move.w	d0,obVelX(a0)	; set speed
		rts
; ===========================================================================
; loc_36DE4:
WindUpKoi_Main:
		subq.b	#1,WindUpKoi_bubble_timer(a0)
		bne.s	@cont			; branch, if timer isn't done counting down
		bsr.w	WindUpKoi_MakeBubble
	@cont:
		subq.w	#1,WindUpKoi_move_timer(a0)
		bpl.s	@cont2			; branch, if timer isn't done counting down
		move.w	#$200,WindUpKoi_move_timer(a0)	; else, reset timer...
		bchg	#0,obStatus(a0)		; ... change direction...
		bchg	#0,obRender(a0)
		neg.w	obVelX(a0)		; ... and reverse movement
	@cont2:
		jsr		(SpeedToPos).l
		bsr.w	Obj_GetOrientationToPlayer
		bsr.w	WindUpKoi_TestCharacterPos	; are Sonic or Tails close enough to attack?
		bne.s	WindUpKoi_PrepareCharge	; if yes, prepare to charge at them
		move.b	#0,obAnim(a0)
		bsr.w	Koi_HandleDPLC
		bra.w	WindUpKoi_Animate
; ===========================================================================
; loc_36E20
WindUpKoi_PrepareCharge:
		addq.b	#2,obRoutine(a0)	; => WindUpKoi_Waiting
		move.b	#$10,WindUpKoi_move_timer(a0)	; time to wait before charging at the player
		clr.w	obVelX(a0)		; stop movement
		bsr.w	Koi_HandleDPLC
		bra.w	WindUpKoi_Animate
; ===========================================================================
; loc_36E32:
WindUpKoi_Waiting:
		subq.b	#1,WindUpKoi_move_timer(a0)
		bmi.s	WindUpKoi_MoveTowardsPlayer		; branch, if wait time is over
		move.b	#1,obAnim(a0)
		bra.w	WindUpKoi_Animate
; ===========================================================================
; loc_36E3C:
WindUpKoi_MoveTowardsPlayer:
		addq.b	#2,obRoutine(a0)	; => WindUpKoi_Charge
		bsr.w	Obj_GetOrientationToPlayer
		lsr.w	#1,d0		; set speed based on closest character
		move.b	WindUpKoi_HorizontalSpeeds(pc,d0.w),obVelX(a0)	; horizontal
		addi.w	#$10,d3
		cmpi.w	#$20,d3		; is closest character withing $10 pixels above or $F pixels below?
		blo.s	@cont		; if not, branch
		lsr.w	#1,d1		; set speed based on closest character
		move.b	WindUpKoi_VerticalSpeeds(pc,d1.w),1+obVelY(a0)	; vertical
	@cont:
		move.b	#1,obAnim(a0)
		bra.w	WindUpKoi_Animate
; ===========================================================================
; byte_36E62:
WindUpKoi_HorizontalSpeeds:
		dc.b  -2	; 0 - player is left from object -> move left
		dc.b   2	; 1 - player is right from object -> move right
; byte_36E64:
WindUpKoi_VerticalSpeeds:
		dc.b $80	; 0 - player is above object -> ... move down?
		dc.b $80	; 1 - player is below object -> move down
; ===========================================================================
; loc_36E66:
WindUpKoi_Charge:
		jsr	(SpeedToPos).l
; loc_36E6A:
WindUpKoi_Animate:
		lea	(Ani_WindUpKoi).l,a1
		jsr	AnimateSprite
		bsr.w	Koi_HandleDPLC
		jmp	(RememberState).l
; ===========================================================================
; loc_36E78:
WindUpKoi_MakeBubble:
		move.b	#$50,WindUpKoi_bubble_timer(a0)	; reset timer
		jsr     FindFreeObj
		bne.s	@ret
		move.b	#id_DrownCount,obID(a1) ; load obj
		move.b	#6,obSubtype(a1) ; <== Obj90_SubObjData2
		move.w	obX(a0),obX(a1)	; align objects horizontally
		moveq	#$18,d0			; load x-offset
		btst	#0,obRender(a0)	; is object facing left?
		beq.s	@cont			; if not, branch
		neg.w	d0			; else mirror offset
	@cont:
		add.w	d0,obX(a1)		; add horizontal offset
		move.w	obY(a0),obY(a1)	; align objects vertically
		addq.w	#6,obY(a1)		; move object 6 pixels down

	@ret:
		rts
; ===========================================================================
; loc_36EB2:
WindUpKoi_TestCharacterPos:
		addi.w	#$20,d3
		cmpi.w	#$40,d3			; is character too low?
		bhs.s	WindUpKoi_DoNotCharge	; if yes, branch
		tst.w	d2			; is character to the left?
		bmi.s	WindUpKoi_TestPosLeft	; if yes, branch
		tst.w	obVelX(a0)		; is object moving left, towards character?
		bpl.s	WindUpKoi_DoNotCharge	; if not, branch
		bra.w	WindUpKoi_TestHorizontalDist
; ===========================================================================
; loc_36ECA:
WindUpKoi_TestPosLeft:
		tst.w	obVelX(a0)		; is object moving right, towards character?
		bmi.s	WindUpKoi_DoNotCharge	; if not, branch
		neg.w	d2			; get absolute value

; loc_36ED2:
WindUpKoi_TestHorizontalDist:
		cmpi.w	#$20,d2			; is distance less than $20?
		blo.s	WindUpKoi_DoNotCharge	; if yes, don't attack
		cmpi.w	#$A0,d2			; is distance less than $A0?
		blo.s	WindUpKoi_PlayerInRange	; if yes, attack

; loc_36EDE:
WindUpKoi_DoNotCharge:
		moveq	#0,d2			; -> don't charge at player
		rts
; ===========================================================================
; loc_36EE2:
WindUpKoi_PlayerInRange:
		moveq	#1,d2			; -> charge at player
		rts
; ===========================================================================
; off_36EE6:
WindUpKoi_SubObjData:	; fmt: mappings, vram location, priority, render flags, width in pixels, collision flags
		dc.l	Map_WindUpKoi
		dc.w	vramKoiBGZ
		dc.w	$100
		dc.b	4
		dc.b	$20
		dc.b	$25
		even
; ===========================================================================
; animation script
; off_36EF0:
Ani_WindUpKoi:
		dc.w	@normal-Ani_WindUpKoi
		dc.w	@fast-Ani_WindUpKoi
@normal:		dc.b	9,	0,	1,	2,	3,afEnd
@fast:			dc.b	4,	0,	4,	5,	6,afEnd
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Copy of Sonic_LoadGFX
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Koi_HandleDPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	WindUpKoi_prevFrame(a0),d0
		beq.s	@nochange
		move.b	d0,WindUpKoi_prevFrame(a0)
		lea	(DPLC_WindUpKoi).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w	#$7FF,d4	; clear art flags
		lsl.w	#5,d4	   ; get VRAM address
		move.l	#Art_WindUpKoi,d6

    @readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries

    @nochange:
		rts	
; End of function Sonic_LoadGfx

; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------

Chopper:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Chop_Index(pc,d0.w),d1
		jsr	Chop_Index(pc,d1.w)
		bra.w	RememberState
; ===========================================================================
Chop_Index:	dc.w Chop_Main-Chop_Index
		dc.w Chop_ChgSpeed-Chop_Index

chop_origY:	equ $30
; ===========================================================================

Chop_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Chop,obMap(a0)
		move.w	#vramChopperLBGZ,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#9,obColType(a0)
		move.b	#$10,obActWid(a0)
		move.w	#-$700,obVelY(a0) ; set vertical speed
		move.w	obY(a0),chop_origY(a0) ; save original position

Chop_ChgSpeed:	; Routine 2
		lea	(Ani_Chop).l,a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce speed
		move.w	chop_origY(a0),d0
		cmp.w	obY(a0),d0	; has Chopper returned to its original position?
		bcc.s	@chganimation	; if not, branch
		move.w	d0,obY(a0)
		move.w	#-$700,obVelY(a0) ; set vertical speed

	@chganimation:
		move.b	#1,obAnim(a0)	; use fast animation
		subi.w	#$C0,d0
		cmp.w	obY(a0),d0
		bcc.s	@nochg
		move.b	#0,obAnim(a0)	; use slow animation
		tst.w	obVelY(a0)	; is Chopper at	its highest point?
		bmi.s	@nochg		; if not, branch
		move.b	#2,obAnim(a0)	; use stationary animation

	@nochg:
		rts	