; ---------------------------------------------------------------------------
; Subroutine to convert 1BPP art to 4BPP, then transfer to VRAM

; input:
;   a5 = art file
;	d2 = palette index wanted(?)

; output:
;   VRAM location given with locVRAM
; ---------------------------------------------------------------------------
VDP_Load1BPP:
		move.w	(a5)+,d7
		lea		(vdp_data_port).l,a6

	@loop1:
		move.l	(a5)+,d3
		moveq	#8-1,d0

	@loop2:
		moveq	#4-1,d4
		moveq	#0,d5

	@loop3:
	; Originally, this rol.w line's first operator was #4,
	; but I changed it to d2 so we can change the color index... maybe?
		rol.w	d2,d5
		rol.l	#1,d3
		bcc.s	@loopTheShit
		or.b	d1,d5

	@loopTheShit:
		dbf		d4,@loop3
		move.w	d5,(a6)
		dbf		d0,@loop2
		dbf		d7,@loop1
		rts