; ---------------------------------------------------------------------------
; Object 91 - Sonic and Abbey on the title screen and Sonic on the NTK logo
; ---------------------------------------------------------------------------

tSonTarget: equ $C8
tAbbTarget: equ $91

vramTitleAbbey:	equ	$440
vramTitleSonic:	equ	$310

vramTitleSonic2:	equ $490
vramTitleAbbey2:	equ	$5A0

; main object
	rsset	obDoubleJump
TCharsDelay:	rs.b	1
TCharsStartAnim: rs.b	1	; if set, main object will start animation
TCharsMainBuf:	rs.w	1	; gfx buffer for the main object

; DPLC object
	rsset	obDoubleJump
TCharsBufStart:	rs.w	1	; pointer to start of the vram buffer
TCharsBufCur:	rs.w	1	; pointer to current loading space of the vram buffer
TCharsParent:	rs.w	1	; pointer to parent object
TCharsLoadOff:	rs.b	1	; load offset for loading dplcs that take more than one frame
TCharsFrameNum: rs.b 	1


TitleSonic:
		cmpi.b	#id_Sega,(v_gamemode).w
		jeq		NTKSonic
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TChr_Index(pc,d0.w),d1
		jmp		TChr_Index(pc,d1.w)
; ===========================================================================
TChr_Index:
		dc.w	TChr_Main-TChr_Index		; 0
		dc.w	TChr_Delay-TChr_Index		; 2
		dc.w	TChr_Move-TChr_Index		; 4
		dc.w	TChr_DPLCInit-TChr_Index	; 6
		dc.w	TChr_DPLCMain-TChr_Index	; 8
; ===========================================================================

TChr_Main:		;Routine 0
		clr.b	TCharsStartAnim(a0)
		move.b	obSubtype(a0),obAnim(a0)	; Whee, they animations now.
		move.l	#Map_TChr,obMap(a0)
		move.w	#$80,obPriority(a0)
		move.b	#29,TCharsDelay(a0)		; set time delay to 0.5 seconds
		addq.b	#2,obRoutine(a0)
		jsr		FindFreeObj	; create child object
		move.w	a0,TCharsParent(a1)
		move.b	#6,obRoutine(a1)
		move.b	obID(a0),obID(a1)
		move.b	obAnim(a0),obAnim(a1)
		tst.b	obSubtype(a0)
		bne.s	@abbey
	@sonic:
		;lea		4(sp),sp
		;bsr.w	DeleteChild
		;bra.w	DeleteObject
		move.w	#vramTitleSonic,obGfx(a0)	; he's not on line 1 anymore
		move.w	#vramTitleSonic2,TCharsMainBuf(a0)
		move.w	#vramTitleSonic,obGfx(a1)
		move.w	#vramTitleSonic2,TCharsBufStart(a1)
		move.w	#tSonTarget,obFinalEasingPos(a0)
		move.w	#$20,obX(a0)
		move.w	#$EF,obY(a0)			; position is fixed to screen  ;obScreenY
		bra.s	TChr_Delay
	@abbey:
		;lea		4(sp),sp
		;bsr.w	DeleteChild
		;bra.w	DeleteObject
		move.w	#vramTitleAbbey,obGfx(a0)	; he's not on line 1 anymore
		move.w	#vramTitleAbbey2,TCharsMainBuf(a0)
		move.w	#vramTitleAbbey,obGfx(a1)
		move.w	#vramTitleAbbey2,TCharsBufStart(a1)
		move.w	#tAbbTarget,obFinalEasingPos(a0)
		move.w	#$20,obX(a0)
		move.w	#$10A,obY(a0)

TChr_Delay:		;Routine 2
		pea		TChr_Display(pc)
		subq.b	#1,TCharsDelay(a0)		; subtract 1 from time delay
		bpl.s	@wait					; if time remains, branch
		addq.b	#2,obRoutine(a0)		; go to next routine
	@wait:
		rts
; ===========================================================================

TChr_Move:		;Routine 4
		pea		TChr_Display(pc)
		tst.b	obSubtype(a0)
		bne.s	@abbey
	@sonic:
		cmpi.w	#tSonTarget,obX(a0)	; has Sonic reached final position?
		blt.s	@ease				; if under, branch
		move.w	#tSonTarget,obX(a0)	; in case he overshot
		rts
	@abbey:
		cmpi.w	#tAbbTarget,obX(a0)	; has Abbey reached final position?
		blt.s	@ease				; if under, branch.
		move.w	#tAbbTarget,obX(a0)	; in case she overshot
	@ease:
		move.w	obFinalEasingPos(a0),d0
		jmp		Ease

TChr_Display:
		tst.b	TCharsStartAnim(a0)
		beq.s	@display
		tst.b	obTimeFrame(a0)
		bne.s	@nobufswap
		; swap buffers
		move.w	obGfx(a0),d1
		move.w	TCharsMainBuf(a0),d2
		move.w	d2,obGfx(a0)
		move.w	d1,TCharsMainBuf(a0)
	@nobufswap:
		lea		(Ani_TChr).l,a1
		jsr		(AnimateSprite).l
	@display:
		jmp		(DisplaySprite).l

; ===========================================================================

TChr_DPLCInit:
		addq.b	#2,obRoutine(a0)
		move.w	TCharsBufStart(a0),d1
		and.w	#$7FF,d1
		lsl.w	#5,d1
		move.w	d1,TCharsBufCur(a0)

TChr_DPLCMain:	; main dplc object routine
		lea		(Ani_TChr).l,a1
		jsr		(AnimateSprite).l
		tst.b	obTimeFrame(a0)
		bne.s	@nobufswap
		; swap buffers
		move.w	obGfx(a0),d1
		move.w	TCharsBufStart(a0),d2
		move.w	d2,obGfx(a0)
		move.w	d1,TCharsBufStart(a0)
		and.w	#$7FF,d1
		lsl.w	#5,d1
		move.w	d1,TCharsBufCur(a0)
	@nobufswap:
		tst.b	obAniFrame(a0)	; is this the first frame?
		beq.s	TChr_LoadGfx ; if so, branch
		; else, set main object to start an animation 
		move.w	TCharsParent(a0),a1
		st		TCharsStartAnim(a1)
		;bra.s	TChr_LoadGfx

TChr_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		tst.b	TCharsLoadOff(a0)
		bne.s	@cont
		cmp.b	TCharsFrameNum(a0),d0
		beq.w	@nochange
		move.b	d0,TCharsFrameNum(a0)

	@cont:
		lea	(DPLC_TChr).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d0
		move.b	TCharsLoadOff(a0),d0
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		sub.w	d0,d5
		bmi.s	@nochange
		add.w	d0,d0
		add.l	d0,a2
	; This block right here makes the graphics not fucking die.
		cmpi.w	#$9-1,d5
		bls.s	@notmax
		moveq	#$9-1,d5
		add.b	#$9,TCharsLoadOff(a0)
		bra.s	@ismax
	@notmax:
		clr.b	TCharsLoadOff(a0)
	@ismax:
	; Hopefully we can find a better fix for this eventually...
		move.w	TCharsBufCur(a0),d4	; get vram buffer pointer 
		move.l	#Art_TChr,d6

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
		move.w	d4,TCharsBufCur(a0)
	@nochange:
		rts

Ani_TChr:
		dc.w	@sonic-Ani_TChr
		dc.w	@abbey-Ani_TChr

@sonic:	dc.b	5,	@fr_S7, @fr_S8,	@fr_S1,	@fr_S2,	@fr_S3,	@fr_S4,	@fr_S5,	@fr_S6,	afEnd
@abbey:	dc.b	3,	@fr_A1,	@fr_A2,	afEnd
		even

	rsreset
@fr_S1:	rs.b	1
@fr_S2:	rs.b	1
@fr_S3:	rs.b	1
@fr_S4:	rs.b	1
@fr_S5:	rs.b	1
@fr_S6:	rs.b	1
@fr_S7:	rs.b	1
@fr_S8:	rs.b	1
@fr_A1:	rs.b	1
@fr_A2:	rs.b	1

; ===========================================================================
; The other half of this file.
; ===========================================================================

	rsset	obDoubleJump
NTKSonDelay:	rs.b	1
NTKSonFrameNum:	rs.b	1

NTKSonStart  = $130
NTKSonTarget = $11C

NTKSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	NTKSon_Index(pc,d0.w),d1
		jsr		NTKSon_Index(pc,d1.w)
		jmp		NTKSon_Display
; ===========================================================================
NTKSon_Index:
		dc.w	NTKSon_Init-NTKSon_Index		;$0 ; Initialize
		dc.w	NTKSon_Delay-NTKSon_Index		;$2	; Delay for moving in
		dc.w	NTKSon_Move-NTKSon_Index		;$4	; Move in
		dc.w	NTKSon_Delay2-NTKSon_Index		;$6 ; Wait and play ring sound
		dc.w	NTKSon_Delay3-NTKSon_Index		;$8	; Wait for the animation to be done.
		dc.w	NTKSon_Move2-NTKSon_Index		;$A ; Move out
; ===========================================================================

NTKSon_Init:		;Routine 0
		move.b	#0,obAnim(a0)			; Slide "animation".
		addq.b	#2,obRoutine(a0)
		move.b	#4,obRender(a0)	; I am so mad. Why the fuck does this work like this????
		move.w	#NTKSonStart,obX(a0)
		move.w	#$A0,obY(a0)			; position is fixed to screen  ;obScreenY
		move.l	#Map_NTKSon,obMap(a0)
		move.w	#vramCharacter,obGfx(a0)			; he's not on line 1 anymore
		move.w	#$80,obPriority(a0)
		move.b	#29,NTKSonDelay(a0)		; set time delay to 0.5 seconds

NTKSon_Delay:		;Routine 2
		subq.b	#1,NTKSonDelay(a0)		; subtract 1 from time delay
		bpl.s	@wait					; if time remains, branch
		addq.b	#2,obRoutine(a0)		; go to next routine
		move.w	#NTKSonTarget,obFinalEasingPos(a0)
	@wait:
		rts
; ===========================================================================

NTKSon_Move:		;Routine 4
		cmpi.w	#NTKSonTarget,obX(a0)
		bne.s	@cont
		move.b	#29,NTKSonDelay(a0)
		addq.b	#2,obRoutine(a0)		; Go to the waiting part.
		move.b	#1,obAnim(a0)
		rts
	@cont:
		move.w	#NTKSonTarget,d0
		jmp		EaseRtL

NTKSon_Delay2:		;Routine 6
		cmpi.b	#5,obAniFrame(a0)		; Is it the third frame of the animation script?
		bne.s	@not3
		sfx		sfx_RingRight
	@not3:
		subq.b	#1,NTKSonDelay(a0)		; subtract 1 from time delay
		bpl.s	@wait					; if time remains, branch
		move.b	#2,obAnim(a0)			; Stop having the thumbs up animation.
		addq.b	#2,obRoutine(a0)		; go to next routine
		move.b	#14,NTKSonDelay(a0)		; Set delay.
	@wait:
		rts

NTKSon_Delay3:		;Routine 8
		subq.b	#1,NTKSonDelay(a0)		; subtract 1 from time delay
		bpl.s	@wait					; if time remains, branch
		addq.b	#2,obRoutine(a0)		; go to next routine
		move.w	#NTKSonStart,obFinalEasingPos(a0)
	@wait:
		rts

NTKSon_Move2:		;Routine A
		cmpi.w	#NTKSonStart,obX(a0)
		bne.s	@cont
		rts
	@cont:
		move.w	#NTKSonStart,d0
		jmp		Ease

NTKSon_Display:
		lea		(Ani_NTKSon).l,a1
		jsr		(AnimateSprite).l
		bsr.s	NTKSon_LoadGfx
		jmp		(DisplaySprite).l

NTKSon_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	NTKSonFrameNum(a0),d0
		beq.s	@nochange
		move.b	d0,NTKSonFrameNum(a0)
		lea	(DPLC_NTKSon).l,a2

	@cont:
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4; get art tile
		andi.w	#$7FF,d4	; clear art flags
		lsl.w	#5,d4		; get VRAM address
		move.l	#Art_NTKSon,d6

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

Ani_NTKSon:
		dc.w	@slide-Ani_NTKSon
		dc.w	@thumbsup-Ani_NTKSon
		dc.w	@unthumb-Ani_NTKSon

@slide:		dc.b	0,	1,	afEnd
@thumbsup:	dc.b	0,	1,	1,	2,	2,	3,	3,	afBack,	1	; Don't go back any frames. This is to prevent the ring sound from playing repeatedly.
@unthumb:	dc.b	1,	3,	2,	1,	afChange,	0
		even