; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

SSLevelSizeArray:
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0620, $0060

LevelSizeLoad:
		moveq	#0,d0
		move.b	d0,(v_dle_routine).w
		cmpi.b	#id_Special,(v_gamemode).w
		bne.s	@normalSizes
		move.b	(v_lastspecial).w,d0	; Testing...
		subq.b	#1,d0
		lsr.b	#1,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	SSLevelSizeArray(pc,d0.w),a0 ; load level	boundaries
		bra.s	@done
	@normalSizes:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	LevelSizeArray(pc,d0.w),a0 ; load level	boundaries
	@done:
		move.w	(a0)+,d0
		move.w	d0,(v_limitleft3-2).w
		move.l	(a0)+,d0
		move.l	d0,(v_limitleft2).w
		move.l	d0,(v_limitleft1).w
		move.l	(a0)+,d0
		move.l	d0,(v_limittop2).w
		move.l	d0,(v_limittop1).w
		move.w	(v_limitleft2).w,d0
		addi.w	#$240,d0
		move.w	d0,(v_limitleft3).w
		move.w	#$1010,(v_fg_xblock).w
		move.w	(a0)+,d0
		move.w	d0,(v_lookshift).w
		bra.w	LevSz_ChkLamp

; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array
; ---------------------------------------------------------------------------
LevelSizeArray:
		; BGZ
		dc.w $0004, $0000, $4200, $0000, $0620, $0060
		dc.w $0004, $0000, $4C40, $0000, $0720, $0060	
		dc.w $0004, $0000, $5080, $0000, $0420, $0060	; Changed width to $7FFF to test the whole level
		dc.w $0004, $0000, $24BF, $0000, $0300, $0060	; Legacy BGZ.
		; LZ
		dc.w $0004, $0000, $19BF, $0000, $0530, $0060
		dc.w $0004, $0000, $10AF, $0000, $0720, $0060
		dc.w $0004, $0000, $202F, $FF00, $0800, $0060
		dc.w $0004, $0000, $20BF, $0000, $0720, $0060
		; MZ
		dc.w $0004, $0000, $17BF, $0000, $01D0, $0060
		dc.w $0004, $0000, $17BF, $0000, $0520, $0060
		dc.w $0004, $0000, $1800, $0000, $0720, $0060
		dc.w $0004, $0000, $16BF, $0000, $0720, $0060
		; SLZ
		dc.w $0004, $0000, $1FBF, $0000, $0640, $0060
		dc.w $0004, $0000, $1FBF, $0000, $0640, $0060
		dc.w $0004, $0000, $2000, $0000, $06C0, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0720, $0060
		; SYZ
		dc.w $0004, $0000, $22C0, $0000, $0420, $0060
		dc.w $0004, $0000, $28C0, $0000, $0520, $0060
		dc.w $0004, $0000, $2C00, $0000, $0620, $0060
		dc.w $0004, $0000, $2EC0, $0000, $0620, $0060
		; SBZ
		dc.w $0004, $0000, $21C0, $0000, $0720, $0060
		dc.w $0004, $0000, $1E40, $FF00, $0800, $0060
		dc.w $0004, $2080, $2460, $0510, $0510, $0060
		dc.w $0004, $0000, $3EC0, $0000, $0720, $0060
		; MHZ
		dc.w $0004, $0000, $2FFF, $0000, $0720, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		dc.w $0004, $0000, $2960, $0000, $0220, $0060	; Boss!
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		; TTZ
		dc.w $0004, $0000, $3FFF, $0000, $0720, $0060	; Set to $800 to Y-wrap.
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		; TMZ
		dc.w $0004, $0000, $2FFF, $0000, $0720, $0060	; Set to $800 to Y-wrap.
		dc.w $0004, $0000, $2FFF, $0000, $0720, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0720, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0720, $0060
		zonewarning LevelSizeArray,$30
		; Ending
		dc.w $0004, $0000, $0500, $0110, $0110, $0060
		dc.w $0004, $0000, $0DC0, $0110, $0110, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
		dc.w $0004, $0000, $2FFF, $0000, $0320, $0060
; ===========================================================================

SSStartLocArray:
		incbin	"Level Data/Start Positions/ss1.bin"
		incbin	"Level Data/Start Positions/ss2.bin"
		incbin	"Level Data/Start Positions/ss3.bin"
		incbin	"Level Data/Start Positions/ss4.bin"
		incbin	"Level Data/Start Positions/ss5.bin"
		incbin	"Level Data/Start Positions/ss6.bin"
		dc.w	$80,$A8
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Ending start location array
; ---------------------------------------------------------------------------
EndingStLocArray:
		include	"Includes/Start Location Array - Ending.asm"

; ===========================================================================

LevSz_ChkLamp:
		tst.b	(v_lastlamp).w	; have any lampposts been hit?
		beq.s	LevSz_StartLoc	; if not, branch
		jsr	(Lamp_LoadInfo).l
		move.w	(v_player+obX).w,d1
		move.w	(v_player+obY).w,d0
		bra.w	LevSz_SkipStartPos
; ===========================================================================

LevSz_StartLoc:
		cmpi.b	#id_Special,(v_gamemode).w	; special stage?
		bne.s	@normalStartLoc
		move.b	(v_lastspecial).w,d0
		subq.b	#1,d0
		lsr.b	#1,d0
		lea	SSStartLocArray(pc,d0.w),a1 ; MJ: load Player's start location address
		bra.s	@done
	@normalStartLoc:
		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	StartLocArray(pc,d0.w),a1 ; MJ: load Player's start location address
	@done:
		tst.w	(f_demo).w	; is ending demo mode on?
		bpl.w	LevSz_PlayerPos	; if not, branch
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	EndingStLocArray(pc,d0.w),a1 ; load Player's start location
		bra.w	LevSz_PlayerPos
; ===========================================================================
; ---------------------------------------------------------------------------
; Player start location array
; ---------------------------------------------------------------------------
StartLocArray:	include	"Includes/Start Location Array - Levels.asm"

LevSz_PlayerPos:
		moveq	#0,d1
		move.b	d1,(v_super).w
		move.b	d1,(v_superpal).w
		move.w	(a1)+,d1
		move.w	d1,(v_player+obX).w ; set Player's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(v_player+obY).w ; set Player's position on y-axis
		move.b	(v_gamemode).w,d2			; MJ: load game mode
		andi.w	#$FC,d2					; MJ: keep in range
		cmpi.b	#4,d2					; MJ: is screen mode at title?
		bne.s	SetScreen				; MJ: if not, branch
		move.w	#$50,d1					; MJ: set positions for title screen
		move.w	#$3B0,d0				; MJ: ''
		move.w	d1,(v_player+obX).w			; MJ: save to object 1 so title screen follows
		move.w	d0,(v_player+obY).w			; MJ: ''

SetScreen:
	LevSz_SkipStartPos:
		clr.b	(v_cameralag).w
		clr.w	(v_trackpos).w		; reset Player's position tracking index
		lea	(v_trackPlayer).w,a2	; load the tracking array into a2
		moveq	#63,d2			; begin a 64-step loop
	@looppoint:
		move.w	d1,(a2)+		; fill in X
		move.w	d0,(a2)+		; fill in Y
		dbf	d2,@looppoint		; loop
		subi.w	#160,d1		; is Player more than 160px from left edge?
		bcc.s	SetScr_WithinLeft ; if yes, branch
		moveq	#0,d1

	SetScr_WithinLeft:
		move.w	(v_limitright2).w,d2
		cmp.w	d2,d1		; is Player inside the right edge?
		bcs.s	SetScr_WithinRight ; if yes, branch
		move.w	d2,d1

	SetScr_WithinRight:
		move.w	d1,(v_screenposx).w ; set horizontal screen position

		subi.w	#96,d0		; is Player within 96px of upper edge?
		bcc.s	SetScr_WithinTop ; if yes, branch
		moveq	#0,d0

	SetScr_WithinTop:
		cmp.w	(v_limitbtm2).w,d0 ; is Player above the bottom edge?
		blt.s	SetScr_WithinBottom ; if yes, branch
		move.w	(v_limitbtm2).w,d0

	SetScr_WithinBottom:
		move.w	d0,(v_screenposy).w ; set vertical screen position
;		bra.w	BgScrollSpeed



; ---------------------------------------------------------------------------
; Subroutine to	set scroll speed of some backgrounds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BgScrollSpeed:
		tst.b	(v_lastlamp).w
		bne.s	loc_6206
		move.w	d0,(v_bgscreenposy).w
		move.w	d0,(v_bg2screenposy).w
		move.w	d1,(v_bgscreenposx).w
		move.w	d1,(v_bg2screenposx).w
		move.w	d1,(v_bg3screenposx).w

loc_6206:
		moveq	#0,d2
		move.b	(v_zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ===========================================================================
BgScroll_Index:	dc.w BgScroll_BGZ-BgScroll_Index, BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_MZ-BgScroll_Index, BgScroll_SLZ-BgScroll_Index
		dc.w BgScroll_SYZ-BgScroll_Index, BgScroll_SBZ-BgScroll_Index
		dc.w BgScroll_MHZ-BgScroll_Index, BgScroll_TTZ-BgScroll_Index
		dc.w BgScroll_TMZ-BgScroll_Index
		zonewarning BgScroll_Index,2
		dc.w BgScroll_End-BgScroll_Index
; ===========================================================================

BgScroll_BGZ:
		moveq	#0,d0
		cmpi.w	#(id_BGZ<<8)+3,(v_zone).w	; BGZ4 (Legacy BGZ)?
		beq.s	@GHZScrolling	; Branch to the correct scroll code.
		move.l	d0,(v_bgscreenposx).w
		move.l	#$2000000,(v_bg2screenposx).w
		move.l	#$2000000,(v_bg3screenposx).w
		move.l	(v_screenposy),d0
		asr.l	#3,d0
		move.l	d0,(v_bgscreenposy).w
		move.l	(v_screenposy),d0
		asr.l	#1,d0
		move.l	d0,d1
		asr.l	d1
		add.l	d1,d0
		swap	d0
		move.w	d0,(v_bg2screenposy).w
		subi.w	#$40,d0	; Adjust this to adjust the height of the second bg on the tilemap
		move.w	d0,(v_bg3screenposy).w
		rts
	@GHZScrolling:
		clr.l	(v_bgscreenposx).w
		clr.l	(v_bgscreenposy).w
		clr.l	(v_bg2screenposy).w
		clr.l	(v_bg3screenposy).w
		lea	(v_bgscroll_buffer).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

BgScroll_LZ:
		asr.l	#1,d0
		move.w	d0,(v_bgscreenposy).w
		rts
; ===========================================================================

BgScroll_MZ:
		rts
; ===========================================================================

BgScroll_SLZ:
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,(v_bgscreenposy).w
		clr.l	(v_bgscreenposx).w
		rts
; ===========================================================================

BgScroll_SYZ:
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,(v_bgscreenposy).w
		clr.l	(v_bgscreenposx).w
		rts
; ===========================================================================

BgScroll_SBZ:
		andi.w	#$7F8,d0
		asr.w	#3,d0
		addq.w	#1,d0
		move.w	d0,(v_bgscreenposy).w
		rts
; ===========================================================================

BgScroll_End:
;		cmpi.b	#3,(v_act).w	; Title screen?
;		beq.w	BgScroll_BGZ	; Scroll like BGZ.
; NOTE: Title screen doesn't actually scroll. I don't know how we'd fix this, but I kind of want to.
		move.w	(v_screenposx).w,d0
		asr.w	#1,d0
		move.w	d0,(v_bgscreenposx).w
		move.w	d0,(v_bg2screenposx).w
		asr.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(v_bg3screenposx).w
		clr.l	(v_bgscreenposy).w
		clr.l	(v_bg2screenposy).w
		clr.l	(v_bg3screenposy).w
		lea	(v_ngfx_buffer-$200).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
; ===========================================================================

BgScroll_MHZ:
		moveq	#0,d0
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,(v_bg2screenposx).w
		move.l	d0,(v_bg2screenposy).w
		move.l	d0,(v_bg3screenposx).w
		move.l	d0,(v_bg3screenposy).w
		rts

BgScroll_TTZ:
		asr.w	#1,d0
		move.w	d0,(v_bgscreenposy).w
		clr.l	(v_bgscreenposx).w
		rts

BgScroll_TMZ:
		moveq	#0,d0
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,(v_bg2screenposx).w
		move.l	d0,(v_bg2screenposy).w
		move.l	d0,(v_bg3screenposx).w
		move.l	d0,(v_bg3screenposy).w
		rts
; ===========================================================================