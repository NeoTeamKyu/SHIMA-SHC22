GM_LevelSelect:
	command	mus_FadeOut	; fade out music
	bsr.w	ClearPLC    ; clear PLC Buffer
	bsr.w	PaletteFadeOut  ; Fade Out Palette
	clr.w   (v_levselitem).w
	jsr		LevSel_ChangeZone
	move.w	(v_levselzone).w,(v_zone).w
	move.b  #-1,(v_levselfaderow).w
	enable_ints
@noPLC:
	disable_ints
	bsr.w	ClearScreen
	lea		vdp_data_port, a6				;Vdp_data_port
	lea		4(a6), a5						;Vdp_control_port
	ResetDMAQueue
	; Load Level Select Text
	
	locVRAM	$D000,(vdp_control_port).l
	lea		(Nem_MenuFont).l,a0
	jsr		NemDec
	
	clr.b	(f_wtr_state).w ; disable fullscreen water
	moveq	#palid_Sonic,d0	; load Sonic's palette
	bsr.w	PalLoad1
	bsr.w   ResetZoneMusic  ; load music
	ResetPlaneRender
	move.w  #4*64,d2
	bsr.w   LevSel_DrawBorders
	bsr.w   LevSel_DrawZoneText
@wait:
	move.b	#4,(v_vbla_routine).w
	bsr.w	WaitForVBla
	bsr.w   RunPLC
	tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
	bne.s	@wait ; if yes, branch
	move.b	#0,(v_levelstarted).w
	clr.b	(f_cameraenabled).w
	bsr.w	LevelSizeLoad
	move.w  #0,(v_screenposy).w    ; set FG vertical position to 0
	bsr.w	DeformLayers
	bsr.w   LevSel_ScrollFG
	bsr.w	LoadZoneTiles	; load level art
	bsr.w	LevelDataLoad ; load block mappings and palettes
	bsr.w   LoadBGFromStart
	bsr.w	PaletteFadeIn
LevSel_MainLoop:
	move.b	#4,(v_vbla_routine).w
	bsr.w	WaitForVBla
	addq.w	#1,(v_framecount).w ; add 1 to level timer
	addq.w	#4,(v_screenposx).w
	bsr.w   LevSel_Controls
	bsr.w	DeformLayers
	bsr.w   LevSel_ScrollFG
	bsr.w   RunPLC
	move.w  (v_zone).w,d0
	cmp.w   (v_levselzone).w,d0
	beq.s   @noreload
	bsr.w   LevSel_ReloadLevel
@noreload:
	bra.s   LevSel_MainLoop

; ===========================================================================
; d2 - amount of border lines to draw*64

LevSel_DrawBorders:
	move.w  (v_planebuffer_addr).w,a5
	move.w  #vram_fg+0*2,d0
	move.w  #24<<7,d1
	bsr.w   PrepareTileCollumn
	move.w  d2,(a4)
	move.w  d2,d0
	lsr.w   #1,d0
	subq.w  #1,d0
@loop:
	move.l  #($8680+$33)<<16+($8680+$33),(a5)+
	dbf     d0,@loop
	move.w  a5,(v_planebuffer_addr).w
	addq.w  #2,(v_screenposx).w
	move.w  #2<<8,(v_scrshiftx).w
	rts

; ===========================================================================

LevSel_DrawZoneText:
	moveq   #0,d0
	move.b  (v_levselzone).w,d0
	and.w   #16-1,d0	; Changed from #8-1 because bitwise, so power of 2, and thus The Magnet's name now works
	lea     LevSelStr_Index,a0
	add.w   d0,d0
	add.w   d0,d0
	move.l  (a0,d0.w),a0
	disable_ints
	moveq   #-(20-5),d2
	move.w  (v_planebuffer_addr).w,a5
	bsr.w   LevSel_DrawString
	lea     LevSelStr_Act,a0
	bsr.w   LevSel_DrawString
	moveq   #0,d0
	move.b  (v_levselzone+1).w,d0
	lea     LevSelStr_Num,a0
	addq.w  #1+3,d0
	and.w   #$F,d0
	add.w   d0,d0
	add.w   d0,d0
	move.l  (a0,d0.w),a0
	bsr.w   LevSel_DrawString
	move.w  a5,(v_planebuffer_addr).w
	enable_ints
	rts

; ===========================================================================
; d2 - string pos (if negative, string will be centered)

LevSel_DrawString:
	tst.w   (a0)
	beq.s   @nullstr
	move.w  d2,d0
	bpl.s   @pos
	neg.w   d0
@pos:
	add.w   d0,d0
	add.w   #vram_fg,d0
	move.w  #24<<7,d1
	bsr.w   PrepareTileCollumn
	move.w  (a0),d0
	move.w  d0,(a4)
	tst.w   d2
	bpl.s   @nocenter
	neg.w   d2
	move.w  d0,d1
	and.w   #$FFFE,d1   ; make d0 even
	sub.w   d1,2(a4)
	asr.w   #1,d1
	sub.w   d1,d2
@nocenter:
	add.w   d0,d2
	move.w  (a0)+,d0
	subq.w  #1,d0
	moveq	#0, d3
@strloop:
	move.w  (a0)+, d3
	subq.w	#3, d3			;Adjusting for font
	move.w	d3, (a5)+
	dbf     d0,@strloop
@nullstr:
	rts

; ===========================================================================
; d0 - row
; d2 - filler longword

LevSel_FillRow:
	move.w (v_planebuffer_addr).w,a5
	add.w   d0,d0
	add.w   #vram_fg,d0
	move.w  #0,d1
	bsr.w   PrepareTileRow
	move.w  #-24,(a4)
	moveq   #24/2-1,d0
@loop:
	move.l  d2,(a5)+
	dbf     d0,@loop
	move.w  a5,(v_planebuffer_addr).w
	rts

; ===========================================================================

LevSel_ScrollFG:
	lea (v_hscrolltablebuffer).w,a0
	move.w   #($380/4)-1,d1
	moveq   #0,d0
@loop:
	move.w  d0,(a0)+
	lea     2(a0),a0
	dbf     d1,@loop
	rts

; ===========================================================================

LevSel_Controls:
	move.b  (v_jpadpress1).w,d0
	btst    #bitR,d0
	bne.s   @nextLevel
	btst    #bitL,d0
	bne.s   @prevLevel
	btst    #bitStart,d0
	bne.w   @playLevel
	rts
@nextLevel:
	addq.w  #1,(v_levselitem).w
	cmp.w  #(LevSel_Ptrs_End-LevSel_Ptrs)/2-1,(v_levselitem).w
	bls.s   @nowrap
	clr.w   (v_levselitem).w
@nowrap:
	bsr.w   LevSel_ChangeZone
	move.w  #1*64,d2
	bsr.w   LevSel_DrawBorders
	bsr.w   LevSel_DrawZoneText
	move.b  #1,(v_levselfadedir).w
@nofade:
	rts
@prevLevel:
	subq.w  #1,(v_levselitem).w
	bpl.s   @nowrap2
	move.w  #(LevSel_Ptrs_End-LevSel_Ptrs)/2-1,(v_levselitem).w
@nowrap2:
	bsr.w   LevSel_ChangeZone
	move.w  #1*64,d2
	bsr.w   LevSel_DrawBorders
	bsr.w   LevSel_DrawZoneText
	move.b  #-1,(v_levselfadedir).w
@nofade2:
	rts

@playLevel:
	lea		(v_systemstack).w,sp
	bsr.w   PlayLevel
	bra.w	MainGameLoop

; ===========================================================================

LevSel_ChangeZone:
	move.w  (v_levselitem).w,d0
	add.w   d0,d0
	lea     LevSel_Ptrs,a1
	move.w  (a1,d0.w),(v_levselzone).w
	rts

; ===========================================================================

LevSel_MoveFade:
	tst.b   (v_levselfadedir).w
	bmi.s   @negdir
	addq.b  #1,(v_levselfaderow).w
	cmp.b   #40,(v_levselfaderow).w
	bls.s   @return
	bra.s   @endfade
@negdir:
	subq.b  #1,(v_levselfaderow).w
	bpl.s   @return
@endfade:
	move.b  #-1,(v_levselfaderow).w
@return:
	rts

; ===========================================================================

LevSel_StartFade:
	clr.b   (v_levselfaderow).w
	tst.b   (v_levselfadedir).w
	bpl.s   @return
	move.b  #40,(v_levselfaderow).w
@return:
	rts

; ===========================================================================

LevSel_ReloadLevel:
	bsr.w   LevSel_StartFade
@frameloop:
	move.b	#4,(v_vbla_routine).w
	bsr.w	WaitForVBla
	addq.w	#1,(v_framecount).w ; add 1 to level timer
	moveq   #0,d0
	move.b  (v_levselfaderow).w,d0
	move.l  #($8680+$33)<<16+($8680+$33),d2
	jsr     LevSel_FillRow
	bsr.w   LevSel_Controls
	bsr.w   LevSel_MoveFade
	tst.b   (v_levselfaderow).w
	bmi.s   @fullfade
	bsr.w   RunPLC
	bra.s   @frameloop
@fullfade:
	move.b	#4,(v_vbla_routine).w
	bsr.w	WaitForVBla
	move.w  (v_levselzone).w,(v_zone).w
	bsr.w   ResetZoneMusic  ; load music
	move.b	#0,(v_levelstarted).w
	clr.b	(f_cameraenabled).w
	bsr.w	LevelSizeLoad
	move.w  #0,(v_screenposy).w    ; set FG vertical position to 0
	bsr.w	DeformLayers
	bsr.w   LevSel_ScrollFG
	bsr.w	LoadZoneTiles	; load level art
	bsr.w	LevelDataLoad ; load block mappings and palettes
	move.w	(v_levselzone).w,d0
	cmp.w	(v_zone).w,d0
	bne.s	@fullfade
	; LevelDataLoad loads palette into duplicate buffer, so it has to be copied manually unless game's doing fading later
	lea     (v_pal_dry_dup).w,a0
	lea     (v_pal_dry).w,a1
	moveq   #($80/4)-1,d0
@copyloop:
	move.l  (a0)+,(a1)+
	dbf     d0,@copyloop
	bsr.w   LoadBGFromStart
	bsr.w   LevSel_StartFade
@frameloop2:
	move.b	#4,(v_vbla_routine).w
	bsr.w	WaitForVBla
	addq.w	#1,(v_framecount).w ; add 1 to level timer
	bsr.w	DeformLayers
	bsr.w   LevSel_ScrollFG
	moveq   #0,d0
	move.b  (v_levselfaderow).w,d0
	moveq   #0,d2
	jsr     LevSel_FillRow
	bsr.w   LevSel_Controls
	bsr.w   LevSel_MoveFade
	tst.b   (v_levselfaderow).w
	bmi.s   @end
	bsr.w   RunPLC
	bra.s   @frameloop2
@end:
	rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select - level pointers
; ---------------------------------------------------------------------------
LevSel_Ptrs:
		; correct level order
		dc.b id_BGZ, 0
		dc.b id_BGZ, 1
		dc.b id_BGZ, 2
		dc.b id_BGZ, 3  ; Legacy BGZ!
		dc.b id_MHZ, 0
		dc.b id_MHZ, 1
		dc.b id_MHZ, 2
		dc.b id_MZ, 0
		dc.b id_MZ, 1
		dc.b id_MZ, 2
		dc.b id_LZ, 0
		dc.b id_LZ, 1
		dc.b id_LZ, 2
		dc.b id_SYZ, 0
		dc.b id_SYZ, 1
		dc.b id_SYZ, 2
		dc.b id_SLZ, 0
		dc.b id_SLZ, 1
		dc.b id_SLZ, 2
		dc.b id_TMZ, 0
		dc.b id_TMZ, 1
		dc.b id_TMZ, 2
		dc.b id_SBZ, 0
		dc.b id_SBZ, 1
		dc.b id_LZ, 3
		dc.b id_SBZ, 2
		dc.b id_HPZ, 0
		dc.b id_HPZ, 1
		dc.b id_HPZ, 2
LevSel_Ptrs_End:
		dc.b id_SS, 0		; Special Stage
		dc.w $8000		; Sound Test
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select strings
; ---------------------------------------------------------------------------

LevSelStr_Index:
	dc.l    LevSelStr_BGZ   ; 0
	dc.l    LevSelStr_SRZ   ; 1
	dc.l    LevSelStr_ATZ   ; 2
	dc.l    LevSelStr_HMZ   ; 3
	dc.l    LevSelStr_BCZ   ; 4
	dc.l    LevSelStr_BBZ   ; 5
	dc.l    LevSelStr_MHZ   ; 6
	dc.l	LevSelStr_HPZ	; 7
	dc.l	LevSelStr_TMZ	; 8
	dc.l	LevSelStr_SS	; 9...?

LevSelStr_BGZ:
	planeASCII  $8680, "blossom gardens \^0"
LevSelStr_SRZ:
	planeASCII  $8680, "sunken relic \^0"
LevSelStr_ATZ:
	planeASCII  $8680, "ashen temple \^0"
LevSelStr_BCZ:
	planeASCII  $8680, "bumper city \^0"
LevSelStr_HMZ:
	planeASCII  $8680, "hoshi metro \^0"
LevSelStr_BBZ:
	planeASCII  $8680, "badnik blitz \^0"
LevSelStr_BBZ3:
	planeASCII  $8680, "conflict core \^0"
LevSelStr_MHZ:
	planeASCII  $8680, "melting heights \^0"
LevSelStr_HPZ:
	planeASCII	$8680, "hidden palace \^0"
LevSelStr_TMZ:
	planeASCII	$8680, "the magnet \^0"
LevSelStr_SS:
	planeASCII	$8680, "special stage"

LevSelStr_Act:
	planeASCII  $8680, "act \^0"

LevSelStr_Num:
	dc.l    @0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@A,@B,@C,@D,@E,@F

@0:
	planeASCII  $8680, "0\^0"
@1:
	planeASCII  $8680, "1\^0"
@2:
	planeASCII  $8680, "2\^0"
@3:
	planeASCII  $8680, "3\^0"
@4:
	planeASCII  $8680, "4\^0"
@5:
	planeASCII  $8680, "5\^0"
@6:
	planeASCII  $8680, "6\^0"
@7:
	planeASCII  $8680, "7\^0"
@8:
	planeASCII  $8680, "8\^0"
@9:
	planeASCII  $8680, "9\^0"
@A:
	planeASCII  $8680, "a\^0"
@B:
	planeASCII  $8680, "b\^0"
@C:
	planeASCII  $8680, "c\^0"
@D:
	planeASCII  $8680, "d\^0"
@E:
	planeASCII  $8680, "e\^0"
@F:
	planeASCII  $8680, "f\^0"

; ===========================================================================

