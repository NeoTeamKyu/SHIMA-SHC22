; ---------------------------------------------------------------------------
; Animation script - signpost
; ---------------------------------------------------------------------------
Ani_Sign:
		dc.w @eggman-Ani_Sign	; 0
		dc.w @spin-Ani_Sign		; 1
		dc.w @spin-Ani_Sign		; 2
		dc.w @sonic-Ani_Sign	; 3
		dc.w @tails-Ani_Sign	; 4
		dc.w @knux-Ani_Sign		; 5
		dc.w @ray-Ani_Sign		; 6
		dc.w @metal-Ani_Sign	; 7
		dc.w @mighty-Ani_Sign	; 8
		dc.w @amy-Ani_Sign		; 9
		dc.w @legacy-Ani_Sign	; A

@eggman:	dc.b $F, 0, afEnd
		even
@spin:		dc.b 1,	0, 1, 2, 3, afEnd	; spin2 was taken out because it showed Sonic and that's no good~
		even
@sonic:		dc.b $F, 4, afEnd
		even
@tails:		dc.b $F, 5, afEnd
		even
@knux:		dc.b $F, 6, afEnd
		even
@ray:		dc.b $F, 7, afEnd
		even
@metal:		dc.b $F, 8, afEnd
		even
@mighty:	dc.b $F, 9, afEnd
		even
@amy:		dc.b $F,$A, afEnd
		even
@legacy:	dc.b $F,$B, afEnd
		even