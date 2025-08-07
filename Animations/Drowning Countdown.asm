; ---------------------------------------------------------------------------
; Animation script - countdown numbers and bubbles (LZ)
; ---------------------------------------------------------------------------
Ani_Drown:	dc.w @zeroappear-Ani_Drown
		dc.w @oneappear-Ani_Drown
		dc.w @twoappear-Ani_Drown
		dc.w @threeappear-Ani_Drown
		dc.w @fourappear-Ani_Drown
		dc.w @fiveappear-Ani_Drown
		dc.w @smallbubble-Ani_Drown
		dc.w @zeroflash-Ani_Drown
		dc.w @oneflash-Ani_Drown
		dc.w @twoflash-Ani_Drown
		dc.w @threeflash-Ani_Drown
		dc.w @fourflash-Ani_Drown
		dc.w @fiveflash-Ani_Drown
		dc.w @blank-Ani_Drown
		dc.w @mediumbubble-Ani_Drown
@zeroappear:	dc.b 5,	0, 1, 2, 3, 4, 5, 9, afRoutine
		even
@oneappear:	dc.b 5,	0, 1, 2, 3, 4, 8, $E,	afRoutine
		even
@twoappear:	dc.b 5,	0, 1, 2, 3, 4, 8, $D,	afRoutine
		even
@threeappear:	dc.b 5,	0, 1, 2, 3, 4, 7, $C,	afRoutine
		even
@fourappear:	dc.b 5,	0, 1, 2, 3, 4, 5, $B, afRoutine
		even
@fiveappear:	dc.b 5,	0, 1, 2, 3, 4, 6, $A, afRoutine
		even
@smallbubble:	dc.b $E, 0, 1, 2, afRoutine
		even
@zeroflash:	dc.b 7,	$F, 9, $F, 9, $F, 9, afRoutine
@oneflash:	dc.b 7,	$F, $E, $F, $E, $F, $E, afRoutine
@twoflash:	dc.b 7,	$F, $D, $F, $D, $F, $D, afRoutine
@threeflash:	dc.b 7,	$F, $C, $F, $C, $F, $C, afRoutine
@fourflash:	dc.b 7,	$F, $B, $F, $B, $F, $B, afRoutine
@fiveflash:	dc.b 7,	$F, $A, $F, $A, $F, $A, afRoutine
@blank:		dc.b $E, afRoutine
@mediumbubble:	dc.b $E, 1, 2, 3, 4, afRoutine
		even