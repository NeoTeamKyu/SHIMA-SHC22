; ---------------------------------------------------------------------------
; Object 08 - Gameroid enemy (BGZ)
;
; This object is based on an enemy from Sonic the Hedgehog 2 (8-bit).
; The enemy's name is apparently "Game-Game", but I don't care.
; This should be pretty simple... I think. (Inferno note: As if.)
;
; Start time: 03 July, 2022 @ 1:07 PM EST... except I spent 51 minutes trying to think.
; haha holy shit it's been a month and i'm only now making him move
; ---------------------------------------------------------------------------
Gameroid:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Gameroid_Index(pc,d0.w),d1
		jmp		Gameroid_Index(pc,d1.w)
; ===========================================================================
Gameroid_Index:
		dc.w	Game_Init-Gameroid_Index
		dc.w	Game_Actions-Gameroid_Index

game_speed:	equ $2A

	rsreset
routID_Game_Init:		rs.w	1
routID_Game_Actions:	rs.w	1
; ===========================================================================

Game_Init:
		move.l	#Map_Gameroid,obMap(a0)
		move.w	#vramGameroidBGZ,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#32,obActWid(a0)
		move.b	#32/2,obWidth(a0)
	; Standing height
		move.b	#26/2,obHeight(a0)
	; Shell-only height gets set later.
		move.b	#$A,obColType(a0)	; TODO: Make a new collision type that's solid on top, but hurts from the sides (and can be attacked from the sides).
		addq.b	#2,obRoutine(a0)
	; Subtype-based checks.
		tst.b	obSubtype(a0)
		bne.s	@flipped
	; Return because I haven't made anything else yet.
		rts

	@flipped:
		move.b	#0,obColType(a0)
		move.b	#3,obAnim(a0)	; Flipped over.
		move.b	#$A,ob2ndRout(a0)	; WaterPlatform 2nd routine
	; Shell-only height.
		move.b	#16/2,obHeight(a0)
		rts

; ===========================================================================

Game_Actions:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Game_2ndIndex(pc,d0.w),d1
		jsr		Game_2ndIndex(pc,d1.w)
		lea		(Ani_Gameroid).l,a1
		jsr		(AnimateSprite).l
		jmp		(RememberState).l
; ===========================================================================
Game_2ndIndex:
		dc.w	@walk-Game_2ndIndex					; 0
		dc.w	@findFloor-Game_2ndIndex			; 2
		dc.w	@goIntoShell-Game_2ndIndex			; 4
		dc.w	@rise-Game_2ndIndex					; 6
		dc.w	@attack-Game_2ndIndex				; 8
		dc.w	@waterPlatform-Game_2ndIndex		; A

	rsset	$30
Gameroid_OrigYPos:	rs.w	1	; this has a reason to be a word
Gameroid_TargetYPos:rs.w	1	; this too
Gameroid_PauseTime:	rs.b	1	; this had no reason to be a word

; ===========================================================================

@walk:
		subq.b	#1,Gameroid_PauseTime(a0)	; subtract 1 from pause	time
		bpl.s	@flipAnim		; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$80,obVelX(a0) ; move object to the left
		subq.w	#1,obX(a0)
		move.b	#1,obAnim(a0)	; walking animation
;		bchg	#0,obStatus(a0)
;		bne.s	@getOrientation

	@getOrientation:
		jsr		Obj_GetOrientationToPlayer
		move.w	d2,d4
		move.w	d3,d5
		bsr.w	Moto_TestCharPos	; is the player close enough to attack?
		beq.s	@done
;		nop
		clr.w	obVelX(a0)
		move.b	#7,obAnim(a0)	; get into shell
		move.b	#4,ob2ndRout(a0); Go to attack routine

	@done:
		rts
	
	@flipAnim:
		cmpi.b	#6,obAnim(a0)	; Flip animation?
		bne.s	@done			; if not, get outta here
		cmpi.b	#2,obAniFrame(a0)	; second shell frame?
		bne.s	@done			; still get outta here
		cmpi.b	#9,obTimeFrame(a0)	; specific timing...
		bne.s	@done
		bchg	#0,obStatus(a0)	; turn around
		neg.w	obVelX(a0)	; change direction
		addq.w	#2,obX(a0)
		rts
; ===========================================================================

@findFloor:
		bsr.w	SpeedToPos
		jsr	(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	@pause
		cmpi.w	#$C,d1
		bge.s	@pause
		add.w	d1,obY(a0)	; match	object's position with the floor

		cmpi.b	#2,obFrame(a0)	; @fr_Walk2 doesn't work because it's not in the same label thing
		beq.s	@noMove
		move.w	#-$80,obVelX(a0) ; move object to the left
		btst	#0,obStatus(a0)
		beq.s	@getOrientation
		neg.w	obVelX(a0)
		bra.s	@getOrientation
	@noMove:
		clr.w	obVelX(a0)

		bra.w	@getOrientation

@pause:
		subq.b	#2,ob2ndRout(a0)
		move.b	#6,obAnim(a0)
		move.b	#59,Gameroid_PauseTime(a0)	; set pause time to 1 second
		move.w	#0,obVelX(a0)	; stop the object moving
		rts
; ===========================================================================

@goIntoShell:
		cmpi.b	#7,obAnim(a0)
		bne.s	@gisDone
		cmpi.b	#2,obAniFrame(a0)
		bne.s	@gisDone
		cmpi.b	#9,obTimeFrame(a0)
		bne.s	@gisDone
		move.w	obY(a0),Gameroid_OrigYPos(a0)
		moveq	#0,d1
		move.w	Gameroid_OrigYPos(a0),d1
		sub.w	#$10,d1
		move.w	d1,Gameroid_TargetYPos(a0)
		move.b	#$26,obColType(a0)
		move.b	#12/2,obHeight(a0)	; no decimal height values, that's dumb
		addq.w	#2,obY(a0)
		addq.b	#2,ob2ndRout(a0)	; rising section

	@gisDone:
		rts
; ---------------------------------------------------------------------------

@rise:
		cmpi.b	#4,obAnim(a0)
		bne.s	@riseDone
		cmpi.b	#9,obAniFrame(a0)
		blt.s	@riseDone
	; easing
		move.w	Gameroid_TargetYPos(a0),d1
		sub.w	obY(a0),d1	; less difference, less speed
		beq.s	@noDiff	; if difference is zero, branch
		asr.w	#2,d1	; it's signed number, so lsr won't work there
	@addDiff:
		add.w	d1,obY(a0)
	@riseDone:
		rts
	@noDiff:
		move.w	d0,Gameroid_TargetYPos(a0)
		clr.b	Gameroid_PauseTime(a0)
		addq.b	#2,ob2ndRout(a0)
		rts
; ---------------------------------------------------------------------------

@attack:
		cmpi.b	#5,obAnim(a0)
		bne.s	@atkRet
		tst.b	Gameroid_PauseTime(a0)
		bne.s	@atkDone
		move.w	#$300,obVelX(a0)
		move.b	#1,Gameroid_PauseTime(a0)
		jsr		Obj_GetOrientationToPlayer
		tst.b	d0
		bne.s	@atkDone
	@left:
		neg.w	obVelX(a0)
	@atkDone:
		jsr		SpeedToPos
	@atkRet:
		rts
; ===========================================================================

@waterPlatform:
		bsr.s	Game_ToWaterSurface
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr		(PlatformObject).l
		rts

; ===========================================================================

Game_ToFloor:
		jsr		(ObjectFall).l
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	@notOnFloor	; Above floor?
		add.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
		bchg	#0,obStatus(a0)
	
	@notOnFloor:
		rts
; ===========================================================================

Game_ToWaterSurface:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr	ExitPlatform
	; Uncommenting this part causes it to disappear when you touch it.
	; This has the effect of also causing the slope bug. Every time.
;		btst    #3,obStatus(a0)
;		bne.s   @fall
;		move.w	(v_player+obVelY).w,game_speed(a0)
		
@resumeoperations:
		jsr		(ObjectFall).l
		moveq	#0,d1
		jsr		(ObjWaterDist).l
		tst.w	d1
		bpl.s	@aboveSurface
	@belowSurface:
		subq.w	#8,obVelY(a0)
		rts

	@aboveSurface:
		clr.w	obVelY(a0)
		move.w	(v_waterpos1).w,obY(a0)
	@ret:
		rts
		
@fall:
		move.w game_speed(a0),d1
		tst.w  d1
		bmi.s  @resumeoperations ; This way, we HAVE to be going down for it to fire.
		asr.w  #1,d1
		move.w d1,obVelY(a0)
		bclr   #3,(v_player+obStatus).w
		bra.s  @resumeoperations
		
; ===========================================================================

Ani_Gameroid:
		dc.w	@stand-Ani_Gameroid			; 0
		dc.w	@walk-Ani_Gameroid			; 1
		dc.w	@inShell-Ani_Gameroid		; 2
		dc.w	@upsideDown-Ani_Gameroid	; 3
		dc.w	@revSpin-Ani_Gameroid		; 4
		dc.w	@spinning-Ani_Gameroid		; 5
		dc.w	@turnaround-Ani_Gameroid	; 6
		dc.w	@getIntoShl-Ani_Gameroid	; 7

	@stand:		dc.b	$7F,@fr_Stand,	afEnd
	@walk:		dc.b	9,	@fr_Walk1,	@fr_Walk2,	@fr_Walk3,	@fr_Walk2,	afEnd
	@inShell:	dc.b	$7F,@fr_Shell,	afEnd
	@upsideDown:dc.b	$7F,@fr_Down,	afEnd
	@revSpin:	dc.b	4,	@fr_Spin1,	@fr_Shell,	@fr_Spin1,	@fr_Shell,	@fr_Spin1,	@fr_Shell,	@fr_Spin2,	@fr_Shell,	@fr_Spin2,	@fr_Shell,	@fr_Spin2,	@fr_Shell
				dc.b		@fr_Spin1,	@fr_Shell,	@fr_Spin1,	@fr_Shell,	@fr_Spin2,	@fr_Shell,	@fr_Spin2,	@fr_Shell,	afChange,	5
	@spinning:	dc.b	2,	@fr_Spin1,	@fr_Shell,	@fr_Spin2,	@fr_Shell,	afEnd
	@turnaround:dc.b	9,	@fr_Turn1,	@fr_Turn2,	@fr_Turn2,	@fr_Turn1,	afChange,	0
	@getIntoShl:dc.b	9,	@fr_Turn1,	@fr_Turn2,	@fr_Shell,	@fr_Shell,	@fr_Shell,	afChange,	4
;							Right about here^ is where Gameroid's height should decrease, its collision type should change, and by the time that's done, it'll be revving up
		even

	rsreset
@fr_Stand:	rs.b	1	; Shut up, I know it's the same as fr_Walk2, but for the sake of being able to move after touching the side, I have to do this.
@fr_Walk1:	rs.b	1
@fr_Walk2:	rs.b	1
@fr_Walk3:	rs.b	1
@fr_Turn1:	rs.b	1
@fr_Turn2:	rs.b	1
@fr_Shell:	rs.b	1
@fr_Spin1:	rs.b	1
@fr_Spin2:	rs.b	1
@fr_Down:	rs.b	1