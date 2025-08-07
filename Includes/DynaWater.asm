; ===========================================================================
; Water Palette Loading for Sonic 1
; Created by BunniDev with ProjectFM, Gemini and RandomName's help
; frankly it's the only thing you've ever finished, you wanker
; ===========================================================================
; ---------------------------------------------------------------------------
; Initial palette shift loading
; Only run this at level start!
; ---------------------------------------------------------------------------

loadWaterShift:
		moveq	#0,d0
        move.b  (v_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
        add.b   (v_act).w,d0
        add.w   d0,d0
		add.w	d0,d0
		move.l	waterValTable(pc,d0.w),(waterValues).w
		bra.w	updateWaterShift

; ===========================================================================
; Per act version (Gotta be 4 acts because even (Also I'm sure it'd be more useful))
waterValTable:	; Entry format: blue<<3, zero, red<<3, green<<3
	; BGZ
	dc.b	-$2<<3, 0, -$4<<3, 0
	dc.b	-$2<<3, 0, -$4<<3, 0
	dc.b	-$2<<3, 0, -$4<<3, 0
	dc.b	0, 0, -$2<<3, -$2<<3
	; SRZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	$2<<3, 0, $2<<3, -$2<<3
	; ATZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; HMZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; BCZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; BBZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; Ending
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; MHZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; HPZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; TMZ
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	dc.b	0, 0, -$2<<3, -$2<<3
	; i'm not even gonna bother with the zonewarning this time...
; ===========================================================================
; ---------------------------------------------------------------------------
; Updates water palette
; Should be run every frame (Necessary for palette cycles)
; ---------------------------------------------------------------------------

updateWaterShift:
		moveq	#$40/2-1,d3		; update all colors (loop iterates through 2 colors at once)
		lea	(waterValues).w,a1	; get water values
		move.w	(a1)+,d0		; get blue into d0
		spl		d7				; get blue sign (0 - positive, $FF - negative)
		ext.w	d7				; extend sign to word
		move.b	(a1)+,d1		; get red into d1
		spl		d7				; get red sign (0 - positive, $FF - negative)
		and.w	#$E0E<<3,d7 	; get red and blue clamp values
		move.w	d7,d4			; copy it to low word of d4
		swap	d4 				; swap d4 words
		move.w	d7,d4 			; copy it to high word of d4
		move.b	(a1)+,d2		; get green
		spl		d7				; get green sign (0 - positive, $FF - negative)
		and.w	#$E<<3,d7		; get green clamp value
		move.w	d7,d5			; copy it to low word of d5
		swap	d5				; swap d5 words
		move.w	d7,d5			; copy it to high word of d5
		lea	(v_pal_dry).w,a1	; load normal palette into a1
		lea	(v_pal_water).w,a2	; load water palette into a2
	@colorLoop:
		move.l	(a1)+,d7		; get 2 colors
		move.l	d7,d6			; copy colors to d6
		and.l	#$0E0E0E0E,d7	; get only greens and reds
		lsl.l	#3,d7			; shift d7, so colors will range from $10101010(and 0) to $70707070
	@blue:
		add.w	d0,d7			; add/sub blue value
		bpl.s	@red			; if value is in range, branch
		and.w	#$FF,d7			; clear high byte of the word
		add.w	d4,d7			; apply blue and red clamp value
		sub.b	d4,d7			; udno red clamp value applying
	@red:
		add.b	d1,d7			; add/sub red value
		bpl.s	@blue2			; if value is in range, branch
		move.b	d4,d7			; apply red clamp value
	@blue2:
		swap	d7				; swap to another color
		; same thing again
		add.w	d0,d7
		bpl.s	@red2
		and.w	#$FF,d7
		add.w	d4,d7
		sub.b	d4,d7
	@red2:
		add.b	d1,d7
		bpl.s	@green
		move.b	d4,d7
	@green:
		lsr.l	#3,d7			; shift d7 back to its initial position
		; d6 is copy of those 2 colors
		and.l	#$00E000E0,d6	; get only greens
		lsr.l	#1,d6			; shift d6, so colors will range from $00100010(and 0) to $00700070
		add.b	d2,d6			; add green value	
		bpl.s	@green2			; if value is in range, branch
		move.b	d5,d6			; apply green clamp value
	@green2:
		swap	d6				; swap to another color	
		; same thing again
		add.b	d2,d6
		bpl.s	@nextColor
		move.b	d5,d6
	@nextColor:
		add.l	d6,d6			; shift d6 back to its initial position
		add.l	d6,d7			; combine all colors
		swap	d7				; swap them back
		move.l	d7,(a2)+		; copy colors to water palette
		dbf	d3,@colorLoop
	waterShiftEnd:
		rts
; ===========================================================================