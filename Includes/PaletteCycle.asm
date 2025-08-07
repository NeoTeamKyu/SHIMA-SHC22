; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteCycle:
		bsr.w	PCycle_SuperSonic
		moveq	#0,d2
		moveq	#0,d0
		move.b	(v_zone).w,d0	; get level number
		add.w	d0,d0
		move.w	PCycle_Index(pc,d0.w),d0
		jsr	PCycle_Index(pc,d0.w) ; jump to relevant palette routine
		jmp		updateWaterShift
; End of function PaletteCycle

; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routines
; ---------------------------------------------------------------------------
PCycle_Index:	dc.w PCycle_BGZ-PCycle_Index
		dc.w PCycle_LZ-PCycle_Index
		dc.w PCycle_MZ-PCycle_Index
		dc.w PalCycle_SLZ-PCycle_Index
		dc.w PalCycle_SYZ-PCycle_Index
		dc.w PalCycle_SBZ-PCycle_Index
        dc.w PalCycle_None-PCycle_Index
		dc.w PalCycle_HPZ-PCycle_Index
		dc.w PalCycle_None-PCycle_Index
		zonewarning PCycle_Index,2
		dc.w PCycle_GHZ-PCycle_Index	; Ending
; ===========================================================================

PCycle_BGZ:	; Come back
		cmpi.b	#3,(v_act).w ; Legacy BGZ?
		beq.w	PCycle_GHZ	; that uses GHZ stuff so go ahead
		rts
		lea		(v_pal_dry+$78).w,a0

	@cont:
		subq.w	#1,(v_pcyc_time).w ; decrement timer
		bpl.s	@skip	; if time remains, branch

		move.w	#5,(v_pcyc_time).w ; reset timer to 5 frames
		jsr		PalRotRight_4

	@skip:
		rts
; End of function PCycle_BGZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PCycle_GHZ:
		lea		(v_pal_dry+$50).w,a0

	@cont:
		subq.w	#1,(v_pcyc_time).w ; decrement timer
		bpl.s	@skip	; if time remains, branch

		move.w	#5,(v_pcyc_time).w ; reset timer to 5 frames
		jsr		PalRotRight_4

	@skip:
		rts
; End of function PCycle_GHZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PCycle_LZ:
; Waterfalls
		lea	(v_pal_dry+$56).w,a0

		subq.w	#1,(v_pcyc_time).w ; decrement timer
		bpl.s	PCycLZ_Skip1	; if time remains, branch

		move.w	#2,(v_pcyc_time).w ; reset timer to 2 frames
		jsr		PalRotLeft_4

PCycLZ_Skip1:	; No clue how to do this one.
; Conveyor belts
		move.w	(v_framecount).w,d0
		andi.w	#7,d0
		move.b	PCycLZ_Seq(pc,d0.w),d0 ; get byte from palette sequence
		beq.s	PCycLZ_Skip2	; if byte is 0, branch
		moveq	#1,d1
		tst.b	(f_conveyrev).w	; have conveyor belts been reversed?
		beq.s	PCycLZ_NoRev	; if not, branch
		neg.w	d1

	PCycLZ_NoRev:
		move.w	(v_ani3_buf+2).w,d0
		andi.w	#3,d0
		add.w	d1,d0
		cmpi.w	#3,d0
		bcs.s	loc_1A0A
		move.w	d0,d1
		moveq	#0,d0
		tst.w	d1
		bpl.s	loc_1A0A
		moveq	#2,d0

loc_1A0A:
		move.w	d0,(v_ani3_buf+2).w
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(Pal_LZCyc2).l,a0
		lea	(v_pal_dry+$76).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)

PCycLZ_Skip2:
		rts
; End of function PCycle_LZ

; ===========================================================================
PCycLZ_Seq:	dc.b 1,	0, 0, 1, 0, 0, 1, 0
; ===========================================================================

PCycle_MZ:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SLZ:
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1A80
		move.w	#7,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addq.w	#1,d0
		cmpi.w	#6,d0
		bcs.s	loc_1A60
		moveq	#0,d0

loc_1A60:
		move.w	d0,(v_pcyc_num).w
		move.w	d0,d1
		add.w	d1,d1
		add.w	d1,d0
		add.w	d0,d0
		lea	(Pal_SLZCyc).l,a0
		lea	(v_pal_dry+$56).w,a1
		move.w	(a0,d0.w),(a1)
		move.l	2(a0,d0.w),4(a1)

locret_1A80:
		rts
; End of function PalCycle_SLZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SYZ:
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1AC6
		move.w	#5,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addq.w	#1,(v_pcyc_num).w
		andi.w	#3,d0
		lsl.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		lea	(Pal_SYZCyc1).l,a0
		lea	(v_pal_dry+$6E).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		lea	(Pal_SYZCyc2).l,a0
		lea	(v_pal_dry+$76).w,a1
		move.w	(a0,d1.w),(a1)
		move.w	2(a0,d1.w),4(a1)

locret_1AC6:
		rts
; End of function PalCycle_SYZ

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PalCycle_None:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SBZ:
		lea	(Pal_SBZCycList1).l,a2
		tst.b	(v_act).w
		beq.s	loc_1ADA
		lea	(Pal_SBZCycList2).l,a2

loc_1ADA:
		lea	(v_ani3_buf+2).w,a1
		move.w	(a2)+,d1

loc_1AE0:
		subq.b	#1,(a1)
		bmi.s	loc_1AEA
		addq.l	#2,a1
		addq.l	#6,a2
		bra.s	loc_1B06
; ===========================================================================

loc_1AEA:
		move.b	(a2)+,(a1)+
		move.b	(a1),d0
		addq.b	#1,d0
		cmp.b	(a2)+,d0
		bcs.s	loc_1AF6
		moveq	#0,d0

loc_1AF6:
		move.b	d0,(a1)+
		andi.w	#$F,d0
		add.w	d0,d0
		movea.w	(a2)+,a0
		movea.w	(a2)+,a3
		move.w	(a0,d0.w),(a3)

loc_1B06:
		dbf	d1,loc_1AE0
		subq.w	#1,(v_pcyc_time).w
		bpl.s	locret_1B64
		lea	(Pal_SBZCyc4).l,a0
		move.w	#1,(v_pcyc_time).w
		tst.b	(v_act).w
		beq.s	loc_1B2E
		lea	(Pal_SBZCyc10).l,a0
		move.w	#0,(v_pcyc_time).w

loc_1B2E:
		moveq	#-1,d1
		tst.b	(f_conveyrev).w
		beq.s	loc_1B38
		neg.w	d1

loc_1B38:
		move.w	(v_pcyc_num).w,d0
		andi.w	#3,d0
		add.w	d1,d0
		cmpi.w	#3,d0
		bcs.s	loc_1B52
		move.w	d0,d1
		moveq	#0,d0
		tst.w	d1
		bpl.s	loc_1B52
		moveq	#2,d0

loc_1B52:
		move.w	d0,(v_pcyc_num).w
		add.w	d0,d0
		lea	(v_pal_dry+$58).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)

locret_1B64:
		rts	
; End of function PalCycle_SBZ

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PalCycle_HPZ:
		lea		(v_pal_dry+$72).w,a0

    @cont:
		subq.w	#1,(v_pcyc_time).w ; decrement timer
		bpl.s	@skip	; if time remains, branch

		move.w	#4,(v_pcyc_time).w ; reset timer to 4 frames
		jsr		PalRotRight_4

    @skip:
		rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
;
;	v_palframe - Current palette frame
;	v_paltimer - When reaches zero, palette goes to next frame
;	v_superpal - Super Sonic palette cycle status (0 = not super(normal) | 1 = fading to super | -1 = super | 2 = fading to normal (technically can be any value > 1))

; sub_213E:
PCycle_SuperSonic:
		move.b	(v_superpal).w,d0
		beq.w	locret_214E	; if palette in not super status, branch
		bmi.w	PalCycle_SuperSonic_normal	; if palette in super status, branch
		subq.b	#1,d0		
		bne.w	PalCycle_SuperSonic_revert	; if palette in fading to normal status, branch

		; fade from Sonic's to Super Sonic's palette
		; run frame timer
		subq.b	#1,(v_paltimer).w
		bpl.w	locret_214E
		move.b	#3,(v_paltimer).w
	; increment palette frame and update sonic's palette
		jsr		LoadSuperPal

	@fadeincont:
		move.w	(v_palframe).w,d0
		addq.w	#8,(v_palframe).w
		cmpi.w	#$30,(v_palframe).w
		blo.s	@loc1
		move.b	#-1,(v_superpal).w
		move.b	#0,(f_lockmulti).w	; unlock controls

@loc1:
		lea	(v_pal_dry+4).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

locret_214E:
		rts
; ---------------------------------------------------------------------------

PalCycle_SuperSonic_revert:
		subq.b	#1,(v_paltimer).w
		bpl.s	locret_214E
		move.b	#3,(v_paltimer).w
	; increment palette frame and update sonic's palette
		jsr		LoadSuperPal

	@fadeincont:
		move.w	(v_palframe).w,d0
		subq.w	#8,(v_palframe).w
		bhs.s	loc_2178
		move.w	#0,(v_palframe).w
		move.b	#0,(v_superpal).w

loc_2178:
		lea	(v_pal_dry+4).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		rts
; ---------------------------------------------------------------------------

PalCycle_SuperSonic_normal:
		subq.b	#1,(v_paltimer).w
		bpl.w	locret_214E
		move.b	#7,(v_paltimer).w
	; increment palette frame and update sonic's palette
		jsr		LoadSuperPal

	@fadeincont:
		move.w	(v_palframe).w,d0
		addq.w	#8,(v_palframe).w
		cmpi.w  #$78,(v_palframe).w
		bcs.s	loc_21D8
		move.w	#$30,(v_palframe).w

loc_21D8:
		lea	(v_pal_dry+4).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		rts
; End of function PalCycle_SuperSonic

; ===========================================================================
;----------------------------------------------------------------------------
; Super palettes
;----------------------------------------------------------------------------

LoadSuperPal:
		moveq	#0,d0
		move.b	(v_character).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@SuperPalLUT(pc,d0.w),a0
		rts

	@SuperPalLUT:
		dc.l	Pal_SuperSonic, Pal_SuperTails, Pal_SuperKnuckles, Pal_SuperSonic, Pal_SuperSonic, Pal_SuperMighty, Pal_SuperSonic, Pal_SuperLegacy

PalRotLeft_4:
        move.w    (a0)+,d0
        move.w    (a0)+,d1
        move.l    (a0)+,d2
        move.w    d0,-(a0)
        move.l    d2,-(a0)
        move.w    d1,-(a0)
		rts

PalRotRight_4:        
        move.w    (a0)+,d0
        move.l    (a0)+,d1
        move.w    (a0)+,d2
        move.l    d1,-(a0)
        move.w    d0,-(a0)
        move.w    d2,-(a0)
		rts

PalRotLeft_3:
        move.w    (a0)+,d0
        move.l    (a0)+,d1
        move.w    d0,-(a0)
        move.l    d1,-(a0)
		rts

PalRotRight_3:
        move.l    (a0)+,d0
        move.w    (a0)+,d1
        move.l    d0,-(a0)
        move.w    d1,-(a0)
		rts