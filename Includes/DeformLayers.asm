; ---------------------------------------------------------------------------
; Background layer deformation subroutines
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeformLayers:
		tst.b	(f_nobgscroll).w
		beq.s	loc_628E
		rts
; ===========================================================================

loc_628E:
		moveq	#0, d0
		move.w	d0, (v_fg_scroll_flags).w
		move.w	d0, (v_bg1_scroll_flags).w
		move.w	d0, (v_bg2_scroll_flags).w
		move.w	d0, (v_bg3_scroll_flags).w
		tst.b	(f_cameraenabled).w
		beq.s	@cameraDisabled
		bsr.w	ScrollHoriz
		bsr.w	ScrollVertical
	@cameraDisabled:
		bsr.w	DynamicLevelEvents
		move.w	(v_screenposy).w,(v_scrposy_dup).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	Deform_Index(pc,d0.w),d0
		jmp	Deform_Index(pc,d0.w)
; End of function DeformLayers

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for background layer deformation	code
; ---------------------------------------------------------------------------
Deform_Index:
		dc.w Deform_BGZ-Deform_Index,	Deform_LZ-Deform_Index
		dc.w Deform_MZ-Deform_Index,	Deform_SLZ-Deform_Index
		dc.w Deform_SYZ-Deform_Index,	Deform_SBZ-Deform_Index
		dc.w Deform_MHZ-Deform_Index,	Deform_TTZ-Deform_Index
		dc.w Deform_TMZ-Deform_Index
		zonewarning Deform_Index,2
		dc.w Deform_GHZ-Deform_Index
; ---------------------------------------------------------------------------
; Green	Hill Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_GHZ:
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	@notTitleA
		jmp		Deform_BGZ
	@notTitleA:
	; block 3 - distant mountains
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d6
		bsr.w	BGScroll_Block3
	; block 2 - hills & waterfalls
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d6
		bsr.w	BGScroll_Block2
	; calculate Y position
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(v_screenposy).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$20,d0
		bpl.s	@limitY
		moveq	#0,d0
	@limitY:
		move.w	d0,d4
		move.w	d0,(v_bgscrposy_dup).w
		move.w	(v_screenposx).w,d0
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	@notTitle
		moveq	#0,d0	; reset foreground position in title screen
	@notTitle:
		neg.w	d0
		swap	d0
	; auto-scroll clouds
		lea	(v_bgscroll_buffer).w,a2
		addi.l	#$10000,(a2)+
		addi.l	#$C000,(a2)+
		addi.l	#$8000,(a2)+
	; calculate background scroll
		move.w	(v_bgscroll_buffer).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$1F,d1
		sub.w	d4,d1
		bcs.s	@gotoCloud2
	@cloudLoop1:		; upper cloud (32px)
		move.l	d0,(a1)+
		dbf	d1,@cloudLoop1

	@gotoCloud2:
		move.w	(v_bgscroll_buffer+4).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$F,d1
	@cloudLoop2:		; middle cloud (16px)
		move.l	d0,(a1)+
		dbf	d1,@cloudLoop2

		move.w	(v_bgscroll_buffer+8).w,d0
		add.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#$F,d1
	@cloudLoop3:		; lower cloud (16px)
		move.l	d0,(a1)+
		dbf	d1,@cloudLoop3

		move.w	#$2F,d1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
	@mountainLoop:		; distant mountains (48px)
		move.l	d0,(a1)+
		dbf	d1,@mountainLoop

		move.w	#$27,d1
		move.w	(v_bg2screenposx).w,d0
		neg.w	d0
	@hillLoop:			; hills & waterfalls (40px)
		move.l	d0,(a1)+
		dbf	d1,@hillLoop

		move.w	(v_bg2screenposx).w,d0
		move.w	(v_screenposx).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$47,d1
		add.w	d4,d1
	@waterLoop:			; water deformation
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,@waterLoop
		rts
; End of function Deform_GHZ

Deform_BGZ:	; lmao im a monke
		cmpi.b	#id_Title,(v_gamemode).w
		beq.s	@titlesc
		cmpi.b	#3,(v_act).w
		beq.w	Deform_GHZ	; Legacy BGZ
	@titlesc:
		moveq	#$00,d4					; set no X movement redraw
		move.w	(v_scrshifty).w,d5			; load Y movement
		ext.l	d5					; extend to long-word
		asl.l	#$05,d5					; multiply by 100, then divide by 2
		bsr.w	Bg_Scroll_Y				; perform redraw for Y
		moveq	#$00,d4					; set no X movement redraw
		move.w	(v_scrshifty).w,d5			; load Y movement
		ext.l	d5					; extend to long-word
		asl.l	#$06,d5					; multiply by 100, then divide by 2
		move.l	d5,d6
		asl.l	d6
		add.l	d6,d5
		bsr.w	Bg_Scroll_Y2				; perform redraw for Y
		move.w	(v_bg2scrposy_dupprev).w,(v_bg2scrposy_dupprev2).w		; save as VSRAM BG scroll position
		move.w	(v_bg2scrposy_dup).w,(v_bg2scrposy_dupprev).w		; save as VSRAM BG scroll position
		move.w	(v_bg2screenposy).w,(v_bg2scrposy_dup).w		; save as VSRAM BG scroll position
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w		; save as VSRAM BG scroll position

	; stars
		move.w	#0,(v_bgscroll_buffer).w			; set speed 1
	; mountains
		move.w	(v_screenposx).w,d0	; load X position
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	@notTitleA
		addi.w  #$10,(v_screenposx).w
		cmpi.w  #$10,(v_screenposx).w
		bhs.s   @notTitleA
		move.w  #$10,(v_screenposx).w
	@notTitleA:
		neg.w	d0					; reverse direction
		asr.w	#$05,d0					; divide by 4
		move.w	d0,(v_bgscroll_buffer+2).w			; set speed 2
	; trees
		move.w	(v_screenposx).w,d0	; load X position
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	@notTitleB
		addi.w  #$10,(v_screenposx).w
		cmpi.w  #$10,(v_screenposx).w
		bhs.s   @notTitleB
		move.w  #$10,(v_screenposx).w
	@notTitleB:
		neg.w	d0					; reverse direction
		asr.w	#$03,d0					; divide by 4
		move.w	d0,(v_bgscroll_buffer+4).w			; set speed 2
	; ground
		move.w	(v_screenposx).w,d0			; load X position
		neg.w	d0					; reverse direction
		asr.w	d0					; divide by 4
		move.w	d0,d1
		asr.w	d1
		add.w	d1,d0
		move.w	d0,(v_bgscroll_buffer+6).w			; set speed 2
		lea	DBGZabove(pc),a0			; load scroll data to use
		lea	DBGZbelow(pc),a3			; load scroll data to use
		cmpi.b	#id_Title,(v_gamemode).w
		bne.w	DeformScroll2
		bra.w	DeformScroll_Title				; continue	
; ---------------------------------------------------------------------------
; Scroll data
; ---------------------------------------------------------------------------

DBGZabove:
		dc.w	v_bgscroll_buffer,  	$60				; stars
		dc.w	v_bgscroll_buffer+2,	$20				; mountains
		dc.w	v_bgscroll_buffer+4,	$F8				; trees
		dc.w	$0000

; ---------------------------------------------------------------------------
; Scroll data
; ---------------------------------------------------------------------------

DBGZbelow:
		dc.w	v_bgscroll_buffer+6,	$178				; ground
		dc.w	$0000
; End of function Deform_BGZ

; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_LZ:
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	BGScroll_XY
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#223,d1
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0

	@loop:
		move.l	d0,(a1)+
		dbf	d1,@loop
		move.w	(v_waterpos1).w,d0
		sub.w	(v_screenposy).w,d0
		rts
; End of function Deform_LZ

; ---------------------------------------------------------------------------
; Marble Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_MZ:
	; block 1 - dungeon interior
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#2,d6
		bsr.w	BGScroll_Block1
	; block 3 - mountains
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		moveq	#6,d6
		bsr.w	BGScroll_Block3
	; block 2 - bushes & antique buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#4,d6
		bsr.w	BGScroll_Block2
	; calculate y-position of background
		move.w	#$200,d0	; start with 512px, ignoring 2 chunks
		move.w	(v_screenposy).w,d1
		subi.w	#$1C8,d1	; 0% scrolling when y <= 56px 
		bcs.s	@noYscroll
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		asr.w	#2,d1
		add.w	d1,d0
	@noYscroll:
		move.w	d0,(v_bg2screenposy).w
		move.w	d0,(v_bg3screenposy).w
		bsr.w	BGScroll_YAbsolute
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
	; do something with redraw flags
		move.b	(v_bg1_scroll_flags).w,d0
		or.b	(v_bg2_scroll_flags).w,d0
		or.b	d0,(v_bg3_scroll_flags).w
		clr.b	(v_bg1_scroll_flags).w
		clr.b	(v_bg2_scroll_flags).w
	; calculate background scroll buffer
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#2,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#5,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		move.w	#4,d1
	@cloudLoop:		
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,@cloudLoop

		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#1,d1
	@mountainLoop:		
		move.w	d0,(a1)+
		dbf	d1,@mountainLoop

		move.w	(v_bg2screenposx).w,d0
		neg.w	d0
		move.w	#8,d1
	@bushLoop:		
		move.w	d0,(a1)+
		dbf	d1,@bushLoop

		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		move.w	#$F,d1
	@interiorLoop:		
		move.w	d0,(a1)+
		dbf	d1,@interiorLoop

		lea	(v_bgscroll_buffer).w,a2
		move.w	(v_bgscreenposy).w,d0
		subi.w	#$200,d0	; subtract 512px (unused 2 chunks)
		move.w	d0,d2
		cmpi.w	#$100,d0
		bcs.s	@limitY
		move.w	#$100,d0
	@limitY:
		andi.w	#$1F0,d0
		lsr.w	#3,d0
		lea	(a2,d0),a2
		bra.w	Bg_Scroll_X
; End of function Deform_MZ

; ---------------------------------------------------------------------------
; Star Light Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SLZ:
	; vertical scrolling
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	Bg_Scroll_Y
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
	; calculate background scroll buffer
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$1C,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		move.w	#$1B,d1
	@starLoop:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,@starLoop

		move.w	d2,d0
		asr.w	#3,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	#4,d1
	@buildingLoop1:		; distant black buildings
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop1

		move.w	d2,d0
		asr.w	#2,d0
		move.w	#4,d1
	@buildingLoop2:		; closer buildings
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop2

		move.w	d2,d0
		asr.w	#1,d0
		move.w	#$1D,d1
	@bottomLoop:		; bottom part of background
		move.w	d0,(a1)+
		dbf	d1,@bottomLoop

		lea	(v_bgscroll_buffer).w,a2
		move.w	(v_bgscreenposy).w,d0
		move.w	d0,d2
		subi.w	#$C0,d0
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0),a2
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_X:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#$E,d1
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	@pixelJump(pc,d2.w)		; skip pixels for first row
	@blockLoop:
		move.w	(a2)+,d0
	@pixelJump:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,@blockLoop
		rts

; ---------------------------------------------------------------------------
; Spring Yard Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SYZ:
	; vertical scrolling
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#4,d5
		move.l	d5,d1
		asl.l	#1,d5
		add.l	d1,d5
		bsr.w	Bg_Scroll_Y
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
	; calculate background scroll buffer
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#8,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		move.w	#7,d1
	@cloudLoop:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,@cloudLoop

		move.w	d2,d0
		asr.w	#3,d0
		move.w	#4,d1
	@mountainLoop:
		move.w	d0,(a1)+
		dbf	d1,@mountainLoop

		move.w	d2,d0
		asr.w	#2,d0
		move.w	#5,d1
	@buildingLoop:
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop

		move.w	d2,d0
		move.w	d2,d1
		asr.w	#1,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$E,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		move.w	#$D,d1
	@bushLoop:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,@bushLoop

		lea	(v_bgscroll_buffer).w,a2
		move.w	(v_bgscreenposy).w,d0
		move.w	d0,d2
		andi.w	#$1F0,d0
		lsr.w	#3,d0
		lea	(a2,d0),a2
		bra.w	Bg_Scroll_X
; End of function Deform_SYZ

; ---------------------------------------------------------------------------
; Scrap	Brain Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SBZ:
		tst.b	(v_act).w
		bne.w	Deform_SBZ2
	; block 1 - lower black buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#2,d6
		bsr.w	BGScroll_Block1
	; block 3 - distant brown buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		moveq	#6,d6
		bsr.w	BGScroll_Block3
	; block 2 - upper black buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#4,d6
		bsr.w	BGScroll_Block2
	; vertical scrolling
		moveq	#0,d4
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#5,d5
		bsr.w	BGScroll_YRelative

		move.w	(v_bgscreenposy).w,d0
		move.w	d0,(v_bg2screenposy).w
		move.w	d0,(v_bg3screenposy).w
		move.w	d0,(v_bgscrposy_dup).w
		move.b	(v_bg1_scroll_flags).w,d0
		or.b	(v_bg3_scroll_flags).w,d0
		or.b	d0,(v_bg2_scroll_flags).w
		clr.b	(v_bg1_scroll_flags).w
		clr.b	(v_bg3_scroll_flags).w
	; calculate background scroll buffer
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		asr.w	#2,d2
		move.w	d2,d0
		asr.w	#1,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#4,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		move.w	#3,d1
	@cloudLoop:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,@cloudLoop

		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		move.w	#9,d1
	@buildingLoop1:		; distant brown buildings
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop1

		move.w	(v_bg2screenposx).w,d0
		neg.w	d0
		move.w	#6,d1
	@buildingLoop2:		; upper black buildings
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop2

		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		move.w	#$A,d1
	@buildingLoop3:		; lower black buildings
		move.w	d0,(a1)+
		dbf	d1,@buildingLoop3
		lea	(v_bgscroll_buffer).w,a2
		move.w	(v_bgscreenposy).w,d0
		move.w	d0,d2
		andi.w	#$1F0,d0
		lsr.w	#3,d0
		lea	(a2,d0),a2
		bra.w	Bg_Scroll_X
;-------------------------------------------------------------------------------
Deform_SBZ2:;loc_68A2:
	; plain background deformation
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#5,d5
		bsr.w	BGScroll_XY
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
	; copy fg & bg x-position to hscroll table
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#223,d1
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
	@loop:
		move.l	d0,(a1)+
		dbf	d1,@loop
		rts
; End of function Deform_SBZ

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level horizontally as Player moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz:
		move.w	(v_screenposx).w,d4 ; save old screen position
		bsr.s	MoveScreenHoriz
		move.w	(v_screenposx).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_xblock).w,d1
		eor.b	d1,d0
		bne.s	@return
		eori.b	#$10,(v_fg_xblock).w
		move.w	(v_screenposx).w,d0
		sub.w	d4,d0		; compare new with old screen position
		bpl.s	@scrollRight

		bset	#2,(v_fg_scroll_flags).w ; screen moves backward
		rts

	@scrollRight:
		bset	#3,(v_fg_scroll_flags).w ; screen moves forward

	@return:
		rts
; End of function ScrollHoriz


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveScreenHoriz:
		move.b	(v_cameralag).w,d1
		beq.s	@cont1
		tst.w	(v_player+obVelX).w	; is Player moving horizontally?
		bne.s	@cont0
		clr.b	(v_cameralag).w	; clear lag
		bra.s	@cont1

	@cont0:
		sub.b	#1,d1
		move.b	d1,(v_cameralag).w
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	(v_trackpos).w,d0
		sub.b	d1,d0
		lea	(v_trackPlayer).w,a1
		move.w	(a1,d0.w),d0
		and.w	#$7FFF,d0
		bra.s	@cont2

	@cont1:
		move.w	(v_player+obX).w,d0

	@cont2:
		sub.w	(v_screenposx).w,d0 ; Sonic's distance from left edge of screen
		subi.w	#144,d0		; is distance less than 144px?
		bmi.s	SH_BehindMid	; if yes, branch			<---- cs to mi (for negative)
		subi.w	#16,d0		; is distance more than 160px?
		bpl.s	SH_AheadOfMid	; if yes, branch			<---- cc to pl (for negative)
		clr.w	(v_scrshiftx).w
		rts
; ===========================================================================

SH_AheadOfMid:	; loc_65CC in hivebrain
		cmpi.w	#16,d0		; is Player within 16px of middle area?
		bcs.s	SH_Ahead16	; if yes, branch
		move.w	#16,d0		; set to 16 if greater

	SH_Ahead16:
		add.w	(v_screenposx).w,d0
		cmp.w	(v_limitright2).w,d0
		blt.s	SH_SetScreen
		move.w	(v_limitright2).w,d0

SH_SetScreen:
		move.w	d0,d1
		sub.w	(v_screenposx).w,d1
		asl.w	#8,d1	
		move.w	d0,(v_screenposx).w ; set new screen position
		move.w	d1,(v_scrshiftx).w ; set distance for screen movement
		rts
; ===========================================================================

SH_BehindMid:
		cmpi.w	#-$10,d0
		bgt.s	SH_Behind16
		move.w	#-$10,d0	

	SH_Behind16:
		add.w	(v_screenposx).w,d0
		cmp.w	(v_limitleft2).w,d0
		bgt.s	SH_SetScreen
		move.w	(v_limitleft2).w,d0
		bra.s	SH_SetScreen
; End of function MoveScreenHoriz

; ===========================================================================
		tst.w	d0
		bpl.s	loc_6610
		move.w	#-2,d0
		bra.s	SH_BehindMid

loc_6610:
		move.w	#2,d0
		bra.s	SH_AheadOfMid

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level vertically as Player moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollVertical:
		moveq	#0,d1
		move.w	(v_player+obY).w,d0
		sub.w	(v_screenposy).w,d0 ; Player's distance from top of screen
		btst	#2,(v_player+obStatus).w ; is Player rolling?
		beq.s	SV_NotRolling	; if not, branch
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@normalheight
		subq.w	#1,d0
		bra.s	SV_NotRolling
	@normalheight:
		subq.w	#5,d0

	SV_NotRolling:
		btst	#1,(v_player+obStatus).w ; is Player jumping?
		beq.s	loc_664A	; if not, branch

		addi.w	#32,d0
		sub.w	(v_lookshift).w,d0
		bcs.s	loc_6696
		subi.w	#64,d0
		bcc.s	loc_6696
		tst.b	(f_bgscrollvert).w
		bne.s	loc_66A8
		bra.s	loc_6656
; ===========================================================================

loc_664A:
		sub.w	(v_lookshift).w,d0
		bne.s	loc_665C
		tst.b	(f_bgscrollvert).w
		bne.s	loc_66A8

loc_6656:
		clr.w	(v_scrshifty).w
		rts
; ===========================================================================

loc_665C:
		; make vertical camera movement smoother by lineraly interpolating it
		move.w	d0,d1 ; copy camera offset to d1
		asr.w	#2,d0 ; divide the number to smooth camera movement
		bne.s	@skip 
		move.w	d1,d0 ; if the result is 0 get the initial offset in case it's less than divisor	
		asr.w	#1,d0 ; try to divide the number by lower value
		bne.s	@skip
		move.w	d1,d0 ; if the result is 0 get the initial offset in case it's less than divisor	
	@skip:
		cmpi.w	#$60,(v_lookshift).w
		bne.s	loc_6684
		move.w	(v_player+obInertia).w,d1
		bpl.s	loc_666C
		neg.w	d1

loc_666C:
		cmpi.w	#$800,d1
		bcc.s	loc_6696
		move.w	#$600,d1
		cmpi.w	#6,d0
		bgt.s	loc_66F6
		cmpi.w	#-6,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6684:
		move.w	#$200,d1
		cmpi.w	#2,d0
		bgt.s	loc_66F6
		cmpi.w	#-2,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6696:
		move.w	#$1000,d1
		cmpi.w	#$10,d0
		bgt.s	loc_66F6
		cmpi.w	#-$10,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_66A8:
		moveq	#0,d0
		move.b	d0,(f_bgscrollvert).w

loc_66AE:
		moveq	#0,d1
		move.w	d0,d1
		add.w	(v_screenposy).w,d1
		tst.w	d0
		bpl.w	loc_6700
		bra.w	loc_66CC
; ===========================================================================

loc_66C0:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	(v_screenposy).w,d1
		swap	d1

loc_66CC:
		cmp.w	(v_limittop2).w,d1
		bgt.s	loc_6724
		cmpi.w	#-$100,d1
		bgt.s	loc_66F0
		andi.w	#$7FF,d1
		andi.w	#$7FF,(v_player+obY).w
		andi.w	#$7FF,(v_screenposy).w
		andi.w	#$3FF,(v_bgscreenposy).w
		bra.s	loc_6724
; ===========================================================================

loc_66F0:
		move.w	(v_limittop2).w,d1
		bra.s	loc_6724
; ===========================================================================

loc_66F6:
		ext.l	d1
		asl.l	#8,d1
		add.l	(v_screenposy).w,d1
		swap	d1

loc_6700:
		cmp.w	(v_limitbtm2).w,d1
		blt.s	loc_6724
		subi.w	#$800,d1
		bcs.s	loc_6720
		andi.w	#$7FF,(v_player+obY).w
		subi.w	#$800,(v_screenposy).w
		andi.w	#$3FF,(v_bgscreenposy).w
		bra.s	loc_6724
; ===========================================================================

loc_6720:
		move.w	(v_limitbtm2).w,d1

loc_6724:
		move.w	(v_screenposy).w,d4
		swap	d1
		move.l	d1,d3
		sub.l	(v_screenposy).w,d3
		ror.l	#8,d3
		move.w	d3,(v_scrshifty).w
		move.l	d1,(v_screenposy).w
		move.w	(v_screenposy).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_yblock).w,d1
		eor.b	d1,d0
		bne.s	@return
		eori.b	#$10,(v_fg_yblock).w
		move.w	(v_screenposy).w,d0
		sub.w	d4,d0
		bpl.s	@scrollBottom
		bset	#0,(v_fg_scroll_flags).w
		rts
; ===========================================================================

	@scrollBottom:
		bset	#1,(v_fg_scroll_flags).w

	@return:
		rts
; End of function ScrollVertical


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; Scrolls background and sets redraw flags.
; d4 - background x offset * $10000
; d5 - background y offset * $10000

BGScroll_XY:
		move.l	(v_bgscreenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0	; add x-shift for this frame
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_xblock).w,d3
		eor.b	d3,d1
		bne.s	BGScroll_YRelative	; no change in Y
		eori.b	#$10,(v_bg1_xblock).w
		sub.l	d2,d0	; new - old
		bpl.s	@scrollRight
		bset	#2,(v_bg1_scroll_flags).w
		bra.s	BGScroll_YRelative
	@scrollRight:
		bset	#3,(v_bg1_scroll_flags).w
BGScroll_YRelative:
		move.l	(v_bgscreenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	@return
		eori.b	#$10,(v_bg1_yblock).w
		sub.l	d3,d0
		bpl.s	@scrollBottom
		bset	#0,(v_bg1_scroll_flags).w
		rts
	@scrollBottom:
		bset	#1,(v_bg1_scroll_flags).w
	@return:
		rts
; End of function BGScroll_XY

Bg_Scroll_Y:
		move.l	(v_bgscreenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	@return
		eori.b	#$10,(v_bg1_yblock).w
		sub.l	d3,d0
		bpl.s	@scrollBottom
		bset	#4,(v_bg1_scroll_flags).w
		rts
	@scrollBottom:
		bset	#5,(v_bg1_scroll_flags).w
	@return:
		rts

Bg_Scroll_Y2:
		move.l	(v_bg2screenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(v_bg2screenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg2_yblock).w,d2
		eor.b	d2,d1
		bne.s	@return
		eori.b	#$10,(v_bg2_yblock).w
		sub.l	d3,d0
		bpl.s	@scrollBottom
		bset	#4,(v_bg2_scroll_flags).w
		rts
	@scrollBottom:
		bset	#5,(v_bg2_scroll_flags).w
	@return:
		rts


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BGScroll_YAbsolute:
		move.w	(v_bgscreenposy).w,d3
		move.w	d0,(v_bgscreenposy).w
		move.w	d0,d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	@return
		eori.b	#$10,(v_bg1_yblock).w
		sub.w	d3,d0
		bpl.s	@scrollBottom
		bset	#0,(v_bg1_scroll_flags).w
		rts
	@scrollBottom:
		bset	#1,(v_bg1_scroll_flags).w
	@return:
		rts
; End of function BGScroll_YAbsolute

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;sub_D938: ;Vertical_Bg_Deformation1:
SetVertiScrollFlagsBG:		;	used by WFZ, HTZ, HPZ, ARZ
		move.l	(v_bgscreenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0	; add y-shift for this frame

;loc_D940: ;Vertical_Bg_Deformation2:
SetVertiScrollFlagsBG2:
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	@ret	; rts
		eori.b	#$10,(v_bg1_yblock).w
		sub.l	d3,d0
		bpl.s	@movedUp
; Background has moved down
		bset	d6,(v_bg1_scroll_flags).w	; everytime v_bg1_yblock changes from $10 to $00
		rts
; ===========================================================================
	@movedUp:
; Background has moved up
		addq.b	#1,d6
		bset	d6,(v_bg1_scroll_flags).w	; everytime v_bg1_yblock changes from $00 to $10
	@ret:
		rts
; End of function SetVertiScrollFlagsBG

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; d6 - bit to set for redraw

BGScroll_Block1:
		move.l	(v_bgscreenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_xblock).w,d3
		eor.b	d3,d1
		bne.s	@return
		eori.b	#$10,(v_bg1_xblock).w
		sub.l	d2,d0
		bpl.s	@scrollRight
		bset	d6,(v_bg1_scroll_flags).w
		bra.s	@return
	@scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg1_scroll_flags).w
	@return:
		rts
; End of function BGScroll_Block1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BGScroll_Block2:
		move.l	(v_bg2screenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bg2screenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg2_xblock).w,d3
		eor.b	d3,d1
		bne.s	@return
		eori.b	#$10,(v_bg2_xblock).w
		sub.l	d2,d0
		bpl.s	@scrollRight
		bset	d6,(v_bg2_scroll_flags).w
		bra.s	@return
	@scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg2_scroll_flags).w
	@return:
		rts
;-------------------------------------------------------------------------------
BGScroll_Block3:
		move.l	(v_bg3screenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bg3screenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg3_xblock).w,d3
		eor.b	d3,d1
		bne.s	@return
		eori.b	#$10,(v_bg3_xblock).w
		sub.l	d2,d0
		bpl.s	@scrollRight
		bset	d6,(v_bg3_scroll_flags).w
		bra.s	@return
	@scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg3_scroll_flags).w
	@return:
		rts

Deform_MHZ:	; lmao im a monke
   lea       @ParallaxScriptMHZ, a1
   jmp       ExecuteParallaxScript

; ---------------------------------------------------------------

@ParallaxScriptMHZ:

_normal = $0000
_moving = $0200
_linear = $0400

   ;        Mode           Speed/dist       Number of lines
	dc.w	_normal,		$0000,			88					; stars
	dc.w	_normal,		$0008,			8					; clouds
	dc.w	_normal,		$0010,			16					; clouds
	dc.w	_normal,		$0020,			40					; clouds
	dc.w	_normal,		$0048,			88;72				; clouds
	dc.w	-1
; End of function Deform_MHZ

Deform_TTZ:
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		moveq	#2,d6
		bsr.w	BGScroll_Block1
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#7,d5
		moveq	#6,d6
		bsr.w	SetVertiScrollFlagsBG
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#1,d0

		move.w	#7,d1
	@loop1:
		move.w	d0,(a1)+
		dbf	d1,@loop1

		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#8,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		lea	(v_bgscroll_buffer+$60).w,a2
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		swap	d3
		add.l	d0,d3
		swap	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0

		move.w	#$19,d1
	@loop2:    ; loc_63DA
		move.w	d0,(a1)+
		dbf	d1,@loop2

		adda.w	#$E,a1
		move.w	d2,d0
		asr.w	#1,d0

		move.w	#$17,d1
	@loop3:     ; loc_63EC
		move.w	d0,(a1)+
		dbf	d1,@loop3

		lea	(v_bgscroll_buffer).w,a2
		move.w	(v_bgscreenposy).w,d0
		move.w	d0,d2
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
; SwScrl_HPZ_Continued:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	#$E,d1
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp		@loopmid4(pc,d2.w)
; ===========================================================================

	@loop4:
		move.w	(a2)+,d0
	@loopmid4: ; what the fuck is this?
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,@loop4
		rts
; End of function Deform_TTZ

; ---------------------------------------------------------------------------
; The Magnet Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_TMZ:
   lea       @ParallaxScriptTMZ, a1
   jmp       ExecuteParallaxScript

; ---------------------------------------------------------------

@ParallaxScriptTMZ:

_normal = $0000
_moving = $0200
_linear = $0400
	; This must equal out to 240.
;			Mode			Speed/dist		Number of lines
	dc.w	_normal,		$0000,			64					; stars
	dc.w	_normal,		$0008,			32					; clouds
	dc.w	_normal,		$0010,			32					; clouds
	dc.w	_normal,		$0020,			32					; clouds
	dc.w	_normal,		$0040,			80					; clouds
	dc.w	-1
; End of function Deform_TMZ

; ===========================================================================
; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list
; ---------------------------------------------------------------------------
DeformScroll_Title:
		lea	(v_hscrolltablebuffer).w,a2			; load H-scroll buffer
		move.w	#$00E0,d7				; prepare number of scanlines
		move.w	(v_bgscreenposy).w,d6			; load Y position
		bra.s    DS_FindStart

DeformScroll:
		lea	(v_hscrolltablebuffer).w,a2			; load H-scroll buffer
		move.w	#$00E0,d7				; prepare number of scanlines
		move.w	(v_bgscreenposy).w,d6			; load Y position
		move.l	(v_screenposx).w,d1			; prepare FG X position
		neg.l	d1					; reverse position

DS_FindStart:
		move.w	(a0)+,d0				; load scroll speed address
		beq.s	DS_Last					; if the list is finished, branch
		movea.w	d0,a1					; set scroll speed address
		sub.w	(a0)+,d6				; subtract size
		bpl.s	DS_FindStart				; if we haven't reached the start, branch
		neg.w	d6					; get remaining size
		sub.w	d6,d7					; subtract from total screen size
		bmi.s	DS_EndSection				; if the screen is finished, branch

DS_NextSection:
		subq.w	#$01,d6					; convert for dbf
		move.w	(a1),d1					; load X position

DS_NextScanline:
		move.l	d1,(a2)+				; save scroll position
		dbf	d6,DS_NextScanline			; repeat for all scanlines
		move.w	(a0)+,d0				; load scroll speed address
		beq.s	DS_Last					; if the list is finished, branch
		movea.w	d0,a1					; set scroll speed address
		move.w	(a0)+,d6				; load size

DS_CheckSection:
		sub.w	d6,d7					; subtract from total screen size
		bpl.s	DS_NextSection				; if the screen is not finished, branch

DS_EndSection:
		add.w	d6,d7					; get remaining screen size and use that instead

DS_Last:
		subq.w	#$01,d7					; convert for dbf
		bmi.s	DS_Finish				; if finished, branch
		move.w	(a1),d1					; load X position

DS_LastScanlines:
		move.l	d1,(a2)+				; save scroll position
		dbf	d7,DS_LastScanlines			; repeat for all scanlines

DS_Finish:
		rts						; return

; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Deform scanlines correctly using a list
; ---------------------------------------------------------------------------

DeformScroll2:
		lea	(v_hscrolltablebuffer).w,a2			; load H-scroll buffer
		move.w	(v_bgscreenposy).w,d6			; load Y position
		move.l	(v_screenposx).w,d1			; prepare FG X position
		neg.l	d1					; reverse position
		tst.b	(f_water).w
		beq.s	@Nowater
	; whee band-aid fixes (that actually don't even work, so i commented them out)
;		cmpi.b	#id_Sega,(v_gamemode).w
;		beq.s	@Nowater
;		cmpi.b	#id_Credits,(v_gamemode).w
;		beq.s	@Nowater
	; end of bullshit
		move.w	(v_bgheight).w,d0
		sub.w	(v_bg2scrposy_dup).w,d0
		bcc.s	@isbelow2
		tst.w	d0
		bpl.s	@isbelow2	; if bg is below top of screen, branch

		move.b	#223,(v_hbla_line2).w
		bra.s	@Underwater

	@isbelow2:
		cmpi.w	#223,d0		; is bg within 223 pixels of top of screen?
		bcs.s	@isvisible2	; if yes, branch
		move.w	#223,d0

	@isvisible2:
		move.b	d0,(v_hbla_line2).w ; set water surface as on-screen
		moveq	#1,d7
		add.b	(v_hbla_line2).w,d7				; prepare number of scanlines
		bsr.s	@FindStart
		move.l	a3,a0
		move.w	#$DF,d7
		sub.b	(v_hbla_line2).w,d7				; prepare number of scanlines
		tst.b	d7
		beq.s	@Finish
		bra.s	@FindStart

	@Underwater:
		move.l	a3,a0

	@Nowater:
		move.w	#$E0,d7

	@FindStart:
		move.w	(a0)+,d0				; load scroll speed address
		beq.s	@Last					; if the list is finished, branch
		movea.w	d0,a1					; set scroll speed address
		sub.w	(a0)+,d6				; subtract size
		bpl.s	@FindStart				; if we haven't reached the start, branch
		neg.w	d6					; get remaining size
		sub.w	d6,d7					; subtract from total screen size
		bmi.s	@EndSection				; if the screen is finished, branch

	@NextSection:
		subq.w	#$01,d6					; convert for dbf
		move.w	(a1),d1					; load X position

	@NextScanline:
		move.l	d1,(a2)+				; save scroll position
		dbf	d6,@NextScanline			; repeat for all scanlines
		move.w	(a0)+,d0				; load scroll speed address
		beq.s	@Last					; if the list is finished, branch
		movea.w	d0,a1					; set scroll speed address
		move.w	(a0)+,d6				; load size

	@CheckSection:
		sub.w	d6,d7					; subtract from total screen size
		bpl.s	@NextSection				; if the screen is not finished, branch

	@EndSection:
		add.w	d6,d7					; get remaining screen size and use that instead

	@Last:
		subq.w	#$01,d7					; convert for dbf
		bmi.s	@Finish				; if finished, branch
		move.w	(a1),d1					; load X position

	@LastScanlines:
		move.l	d1,(a2)+				; save scroll position
		dbf	d7,@LastScanlines			; repeat for all scanlines

	@Finish:
		rts						; return

; ===========================================================================