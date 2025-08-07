; ---------------------------------------------------------------------------
; Animation script - springs
; ---------------------------------------------------------------------------
Ani_Spring:
		dc.w @vertidle-Ani_Spring
		dc.w @vert-Ani_Spring
		dc.w @horizidle-Ani_Spring
		dc.w @horiz-Ani_Spring
@vertidle:	dc.b	$F, 0, afEnd
		even
@vert:	dc.b 0,	1, 2, 3, 4, 5, 6, 7, 8,	9, 0, afChange, 0
		even
@horizidle:	dc.b	$F,	$A, afEnd
		even
@horiz:	dc.b 0,$B,$C,$D,$E,$F,$10,$11,$12,$13,$A, afChange, 2
		even