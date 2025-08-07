; ---------------------------------------------------------------------------
; Animation script - Tails's tails
; ---------------------------------------------------------------------------
TailsTailsAniData:
		dc.w TailsTailsAni_Blank-TailsTailsAniData	;  0
		dc.w TailsTailsAni_Swish-TailsTailsAniData	;  1
		dc.w TailsTailsAni_Flick-TailsTailsAniData	;  2
		dc.w TailsTailsAni_Directional-TailsTailsAniData	;  3
		dc.w TailsTailsAni_DownLeft-TailsTailsAniData	;  4
		dc.w TailsTailsAni_Down-TailsTailsAniData	;  5
		dc.w TailsTailsAni_DownRight-TailsTailsAniData	;  6
		dc.w TailsTailsAni_Spindash-TailsTailsAniData	;  7
		dc.w TailsTailsAni_Skidding-TailsTailsAniData	;  8
		dc.w TailsTailsAni_Pushing-TailsTailsAniData	;  9
		dc.w TailsTailsAni_FlyFast-TailsTailsAniData	; $A
		dc.w TailsTailsAni_Fly-TailsTailsAniData		; $B
		dc.w TailsTailsAni_FlyTired-TailsTailsAniData	; $C

TailsTailsAni_Blank:		dc.b $20,  0,$FF
		even
TailsTailsAni_Swish:		dc.b   7,  1, 2, 3, 4, 5,$FF
		even
TailsTailsAni_Flick:		dc.b   3,  1, 2, 3, 4, 5,$FD,  1
		even
TailsTailsAni_Directional:	dc.b $FC,6,7,8,9,$FF ; Tails is moving right
		even
TailsTailsAni_DownLeft:	dc.b   3,$A,$B,$C,$D,$FF ; Tails is moving up-right
		even
TailsTailsAni_Down:		dc.b   3,$E,$F,$10,$11,$FF ; Tails is moving up
		even
TailsTailsAni_DownRight:	dc.b   3,$12,$13,$14,$15,$FF ; Tails is moving up-left
		even
TailsTailsAni_Spindash:	dc.b   2,$18,$19,$1A,$1B,$FF
		even
TailsTailsAni_Skidding:	dc.b   2,$1C,$1D,$1E,$1F,$FF
		even
TailsTailsAni_Pushing:	dc.b   9,$1C,$1D,$1E,$1F,$FF
		even
TailsTailsAni_Hanging:	dc.b   9,$18,$19,$1A,$1B,$FF
		even
TailsTailsAni_FlyFast:	dc.b	0,$16,$17,$FF
		even
TailsTailsAni_Fly:		dc.b	1,$16,$17,$FF
		even
TailsTailsAni_FlyTired:	dc.b	$5,$20,$21,$22,$23,$FF
		even