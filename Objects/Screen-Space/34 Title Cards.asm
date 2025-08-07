; ---------------------------------------------------------------------------
; Title card object
; Originally by lavagaming, rewritten by Ralakimus
; ---------------------------------------------------------------------------

; Frame IDs.
	rsreset
frTC_BGZ:	rs.b 1
frTC_SRZ:	rs.b 1
frTC_ATZ:	rs.b 1
frTC_HMZ:	rs.b 1
frTC_BCZ:	rs.b 1
frTC_BBZ:	rs.b 1
frTC_MHZ:	rs.b 1
frTC_HPZ:	rs.b 1
frTC_TMZ:	rs.b 1
frTC_ZONE:	rs.b 1
frTC_Act1:	rs.b 1
frTC_Act2:	rs.b 1
frTC_Act3:	rs.b 1
frTC_Blank1:rs.b 1
frTC_CCZ:	rs.b 1
frTC_Blank2:rs.b 1
frTC_Banner:rs.b 1
frTC_Alpha:	rs.b 1


oTtlCardXDestIn		EQU	$30				; Target X position (move in)
oTtlCardXDestOut	EQU	$32				; Target X position (move out)
oTtlCardYDestIn		EQU	$34				; Target Y position (move in)
oTtlCardYDestOut	EQU	$36				; Target Y position (move out)
oTtlCardDelay		EQU	$38				; Delay counter

TTLCARD_DELAY		EQU	60				; Title card delay
TTLCARD_SPEED		EQU	$15			; Title card speed
TTLCARD_PARTCNT		EQU	(TitleCard_Config_End-TitleCard_Config)/$10

; ---------------------------------------------------------------------------

TitleCard:
		moveq	#0,d0					; Run object routine
		move.b	obRoutine(a0),d0
		move.w	TitleCard_Index(pc,d0.w),d1
		jmp	TitleCard_Index(pc,d1.w)

; ---------------------------------------------------------------------------

TitleCard_Index:
		dc.w	TitleCard_Init-TitleCard_Index
		dc.w	TitleCard_MoveIn-TitleCard_Index
		dc.w	TitleCard_Wait-TitleCard_Index
		dc.w	TitleCard_MoveOut-TitleCard_Index
		dc.w	TitleCard_Delete-TitleCard_Index

; ---------------------------------------------------------------------------
; Configuration
; ---------------------------------------------------------------------------
; PARAMETERS:
;	tile   - Base tile
;	frame  - Sprite frame
;	xstart - Starting X position
;	xdest  - Target X position (move in)
;	xdest2 - Target X position (move out)
;	xstart - Starting Y position
;	ydest  - Target Y position (move in)
;	ydest2 - Target Y position (move out)
; ---------------------------------------------------------------------------

TTLCONF macro tile, frame, xstart, xdest, xdest2, ystart, ydest, ydest2
		dc.w	\tile					; Tile
		dc.b	2, \frame				; Routine, frame
		dc.w	\xstart+128, \xdest+128, \xdest2+128	; X start and targets
		dc.w	\ystart+128, \ydest+128, \ydest2+128	; Y start and targets
		endm

; ---------------------------------------------------------------------------

TitleCard_Config:
		; Zone name
		TTLCONF	vramTitleCard, frTC_BGZ,		-96, 160, 320,   96,  96,   96
		; "Zone"
		TTLCONF	vramTitleCard, frTC_ZONE,	-96, 216, 320,  128, 128,  128
		; Act number
		TTLCONF	vramTitleCard, frTC_Act1,	-96, 240, 320,  136, 136,  136
		; Banner
		TTLCONF	vramBanner, frTC_Banner,	80, 80, 80, -128,  96, -128
TitleCard_Config_End:

; ---------------------------------------------------------------------------
; Initialization
; ---------------------------------------------------------------------------

TitleCard_Init:
		lea	TitleCard_Config(pc),a2			; Configure title cards
		lea	(a0),a1					; Start with current object
		moveq	#TTLCARD_PARTCNT-1,d1			; Number of parts

@InitLoop:
		move.b	(a0),(a1)				; Set object ID
	   	clr.b	obRender(a1)			; Set render flags
	   	move.l	#Map_Card,mappings(a1)			; Set mappings
		clr.w	obPriority(a1)				; Set priority

		move.w	(a2)+,obGfx(a1)			; Set tile
		move.b	(a2)+,obRoutine(a1)			; Set routine
		move.b	(a2)+,d0				; Get frame
		bne.s	@CheckActNum				; If it's not a zone name frame, branch
	
		add.b	(v_zone).w,d0				; Add zone number
	; At first, I thought this was redundant, but then I realized that this is for the act number and zone name frames. Oops?
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w		; Are we in Scrap Brain Zone act 3?
		bne.s	@CheckFZZone				; If not, branch
		moveq	#frTC_BBZ,d0					; Override frame
		bra.s	@SetFrame

@CheckFZZone:
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w		; Are we in Scrap Brain Zone act 3?
		bne.s	@SetFrame				; If not, branch
		moveq	#frTC_CCZ,d0					; Override frame
		bra.s	@SetFrame

@CheckActNum:
		cmpi.b	#frTC_Act1,d0					; Is it an act number frame?
		bne.s	@SetFrame				; If not, branch
		add.b	(v_act).w,d0				; Add act number

		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w		; Are we in Final Zone?
		bne.s	@CheckSBZ3Act				; If not, branch
		moveq	#frTC_Blank1,d0					; Override frame
		bra.s	@SetFrame

@CheckSBZ3Act:
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w		; Are we in Scrap Brain Zone act 3?
		bne.s	@SetFrame				; If not, branch
		moveq	#frTC_Act3,d0					; Override frame

@SetFrame:
		move.b	d0,obFrame(a1)			; Set frame

		move.w	(a2)+,obX(a1)				; Set starting X
		move.w	(a2)+,oTtlCardXDestIn(a1)		; Set target X (move in)
		move.w	(a2)+,oTtlCardXDestOut(a1)		; Set target X (move out)

		move.w	(a2)+,obY(a1)				; Set starting Y
		move.w	(a2)+,oTtlCardYDestIn(a1)		; Set target Y (move in)
		move.w	(a2)+,oTtlCardYDestOut(a1)		; Set target Y (move out)

		lea	SstLimit(a1),a1				; Next part
		dbf	d1,@InitLoop				; Loop until all parts are initialized

; ---------------------------------------------------------------------------
; Move part in
; ---------------------------------------------------------------------------

TitleCard_MoveIn:
		move.w	oTtlCardXDestIn(a0),d0			; Move to target position
		move.w	oTtlCardYDestIn(a0),d1
		bsr.s	TitleCard_Move
	
; ---------------------------------------------------------------------------
; Hold part in place
; ---------------------------------------------------------------------------

TitleCard_Wait:
		move.w	#TTLCARD_DELAY,oTtlCardDelay(a0)	; Set delay counter
		bra.w	DisplaySprite				; Draw sprite

; ---------------------------------------------------------------------------
; Move part out
; ---------------------------------------------------------------------------

TitleCard_MoveOut:
		tst.w	oTtlCardDelay(a0)			; Is the delay counter set?
		beq.s	@Move					; If not, branch
		subq.w	#1,oTtlCardDelay(a0)			; Decrement delay counter
		bpl.s	@Display				; If it hasn't run out, branch

@Move:
		move.w	oTtlCardXDestOut(a0),d0			; Move to target position
		move.w	oTtlCardYDestOut(a0),d1
		bsr.s	TitleCard_Move

@Display:
		bra.w	DisplaySprite				; Draw part sprite

; ---------------------------------------------------------------------------
; Delete part
; ---------------------------------------------------------------------------

TitleCard_Delete:
		cmpa.w	#v_gameover,a0				; Is this the first part?
		bne.s	@Delete					; If not, branch

		lea	SstLimit(a0),a1				; Check if other parts have moved out yet
		moveq	#TTLCARD_PARTCNT-1-1,d1			; Number of parts

@CheckPos:
		move.w	obX(a1),d0				; Has this part reached its target X position?
		cmp.w	oTtlCardXDestOut(a1),d0
		bne.s	@NotDone				; If not, branch
		move.w	obY(a1),d0				; Has this part reached its target Y position?
		cmp.w	oTtlCardYDestOut(a1),d0
		bne.s	@NotDone				; If not, branch

		lea	SstLimit(a1),a1				; Next part
		dbf	d1,@CheckPos				; Loop until all parts are checked

		moveq	#plcid_Explode,d0			; Queue explosion PLCs
		jsr	AddPLC

		moveq	#0,d0					; Queue animal PLCs
		move.b	(v_zone).w,d0
		addi.w	#plcid_BGZAnimals,d0
		cmpi.w	#(id_BGZ<<8)+3,(v_zone).w
		bne.s	@QueueAnimalPLCs
		move.w	#plcid_BGZAnimals,d0
	
@QueueAnimalPLCs:
		jsr	AddPLC

@Delete:
		bra.w	DeleteObject				; Delete part

@NotDone:
		rts

; ---------------------------------------------------------------------------
; Move a part
; ---------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Target X position
;	d1.w - Target Y position
; ---------------------------------------------------------------------------

TitleCard_Move:
		cmp.w	obX(a0),d0				; Check distance from target X position
		beq.s	@MoveY					; If we aren't moving this part horizontally, branch
		bgt.s	@MoveRight				; If this part should move right, branch

@MoveLeft:
		subi.w	#TTLCARD_SPEED,obX(a0)		; Move left
		cmp.w	obX(a0),d0				; Have we moved past the target X position?
		blt.s	@MoveY					; If not, branch
		bra.s	@CapX					; If so, cap at target X position

@MoveRight:
		addi.w	#TTLCARD_SPEED,obX(a0)		; Move right
		cmp.w	obX(a0),d0				; Have we moved past the target X position?
		bgt.s	@MoveY					; If not, branch

@CapX:
		move.w	d0,obX(a0)				; Cap at target X position
		addq.b	#2,obRoutine(a0)				; Set to next routine
		rts

; ---------------------------------------------------------------------------

@MoveY:
		cmp.w	obY(a0),d1				; Check distance from target Y position
		beq.s	@End					; If we aren't moving this part vertically, branch
		bgt.s	@MoveDown				; If this part should move down, branch

@MoveUp:
		subi.w	#TTLCARD_SPEED,obY(a0)		; Move up
		cmp.w	obY(a0),d1				; Have we moved past the target Y position?
		blt.s	@End					; If not, branch
		bra.s	@CapY					; If so, cap at target Y position

@MoveDown:
		addi.w	#TTLCARD_SPEED,obY(a0)		; Move down
		cmp.w	obY(a0),d1				; Have we moved past the target Y position?
		bgt.s	@End					; If not, branch

@CapY:
		move.w	d1,obY(a0)				; Cap at target Y position
		addq.b	#2,obRoutine(a0)				; Set to next routine

@End:
		rts
	
; ---------------------------------------------------------------------------
; Check if the title card has fully moved in
; ---------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Not moved in/Moved in
; ---------------------------------------------------------------------------

CheckTitleCard:
		lea	(v_gameover).w,a0			; Title card object slots
		moveq	#TTLCARD_PARTCNT-1,d1			; Number of parts

@CheckPos:
		move.w	obX(a0),d0				; Has this part reached its target X position?
		cmp.w	oTtlCardXDestIn(a0),d0
		bne.s	@NotDone				; If not, branch
		move.w	obY(a0),d0				; Has this part reached its target Y position?
		cmp.w	oTtlCardYDestIn(a0),d0
		bne.s	@NotDone				; If not, branch

		lea	SstLimit(a0),a0				; Next part
		dbf	d1,@CheckPos				; Loop until all parts are checked

		moveq	#1,d0					; Clear zero flag
		rts

@NotDone:
		moveq	#0,d0					; Set zero flag
		rts

; ---------------------------------------------------------------------------
; Move title card out
; ---------------------------------------------------------------------------

MoveTitleCardOut:
		lea	(v_gameover).w,a0			; Title card object slots
		moveq	#TTLCARD_PARTCNT-1,d1			; Number of parts

@MoveOut:
		addq.b	#2,obRoutine(a0)				; Set to move out
		lea	SstLimit(a0),a0				; Next part
		dbf	d1,@MoveOut				; Loop until all parts are set to move
		clr.b	(v_super).w
	@superChallengeCheck:
		btst	#bitSupChall,(v_miscOptions).w
		beq.s	@done
		move.w	#25,(v_rings).w
		ori.b	#1,(f_ringcount).w ; update the ring counter
		jsr		SuperPlayer_Cont
	@done:
		rts

; ---------------------------------------------------------------------------
