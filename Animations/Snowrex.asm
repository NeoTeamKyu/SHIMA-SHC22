Ani_Snowrex:
		dc.w	@stand-Ani_Snowrex ; 0
		dc.w	@walk-Ani_Snowrex	; 1
		dc.w	@fire-Ani_Snowrex	; 2

@stand:	dc.b	9,	1,	afEnd
		even
@walk:	dc.b	9,	0,	1,	2,	1,	afEnd
		even
@fire:	dc.b	19,	3,	afEnd
		even
