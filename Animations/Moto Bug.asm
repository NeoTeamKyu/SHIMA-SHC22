; ---------------------------------------------------------------------------
; Animation script - Motobug enemy
; ---------------------------------------------------------------------------
Ani_Moto:	dc.w @stand-Ani_Moto
		dc.w @walk-Ani_Moto
		dc.w @flame-Ani_Moto

@stand:		dc.b $F, 2, afEnd
		even
@walk:		dc.b 7,	0, 1, 0, 2, afEnd
@flame:		dc.b 2,	3, 4, 3, 4, 3, 4, afEnd
		even