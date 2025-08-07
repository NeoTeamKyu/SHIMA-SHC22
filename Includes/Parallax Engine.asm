; ===============================================================
; ---------------------------------------------------------------
; Vladikcomper's Parallax Engine
; Version 0.50
; ---------------------------------------------------------------
; 2014, Vladikcomper
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Main routine that runs the script
; ---------------------------------------------------------------
; INPUT:
;	a1	Script
; ---------------------------------------------------------------

ExecuteParallaxScript:
	lea	v_hscrolltablebuffer,a0

	move	v_screenposx,d0			; d0 = BG Position
	swap	d0
	clr.w	d0
	moveq	#0,d7
	
@ProcessBlock:
	move.b	(a1)+,d7			; load scrolling mode for the current block in script
	bmi.s	@Return				; if end of list reached, branch
	move.w	@ParallaxRoutines(pc,d7),d6
	move.b	(a1)+,d7			; load scrolling mode parameter
	jmp	@ParallaxRoutines(pc,d6)

@Return:
	rts

; ---------------------------------------------------------------
@ParallaxRoutines:
	dc.w	@Parallax_Normal-@ParallaxRoutines
	dc.w	@Parallax_Moving-@ParallaxRoutines  
	dc.w	@Parallax_Linear-@ParallaxRoutines

; ---------------------------------------------------------------
; Scrolling routine: Static solid block
; ---------------------------------------------------------------
; Input:
;	d7	.w	$00PP, where PP is parameter
;
; Notice:
;	Don't pollute the high byte of d7!
;
; ---------------------------------------------------------------

@Parallax_Normal:

	; Calculate positions
	move.l	d0,d1				; d1 = X (16.16)
	swap	d1				; d1 = X (Int)
	mulu.w	(a1)+,d1			; d1 = X*Coef (24.8)
	lsl.l	#8,d1				; d1 = X*Coef (16.16)
	move.w	v_screenposx,d1
	neg.w	d1
	swap	d1
	neg.w	d1				; d1 = $00BB, where BB is -X*Coef

	; Execute code according to number of lines set
	move.w	(a1)+,d6			; d6 = N, where N is Number of lines
	move.w	d6,d5				; d5 = N    
	lsr.w	#5,d5				; d5 = N/32
	andi.w	#31,d6				; d6 = N%32
	neg.w	d6				; d6 = -N%32
	add.w	#32,d6				; d6 = 32-N%32
	add.w	d6,d6
	jmp	@0(pc,d6)

	; Main functional block (2 bytes per loop)
@0	rept	32
	move.l	d1,(a0)+
	endr
	dbf	d5,@0

	jmp	@ProcessBlock			; process next bloku!
	
; ---------------------------------------------------------------
; Scrolling routine: Moving solid block
; ---------------------------------------------------------------
; Input:
;	d7	.w	$00PP, where PP is parameter
;
; Notice:
;	Don't pollute the high byte of d7!
;
; ---------------------------------------------------------------

@Parallax_Moving:

	; Calculate positions
	move.l	d0,d1				; d1 = X (16.16)
	swap	d1				; d1 = X (Int)
	mulu.w	(a1)+,d1			; d1 = X*Coef (24.8)
	lsl.l	#8,d1				; d1 = X*Coef (16.16)
	move.w	v_screenposx,d1
	neg.w	d1
	swap	d1
	neg.w	d1				; d1 = $00BB, where BB is -X*Coef
	
	; Add frame factor
	move.w	v_framecount,d3
	lsr.w	d7,d3
	sub.w	d3,d1

	; Execute code according to number of lines set
	move.w	(a1)+,d6			; d6 = N, where N is Number of lines
	move.w	d6,d5				; d5 = N    
	lsr.w	#5,d5				; d5 = N/32
	andi.w	#31,d6				; d6 = N%32
	neg.w	d6				; d6 = -N%32
	add.w	#32,d6				; d6 = 32-N%32
	add.w	d6,d6
	jmp	@0(pc,d6)


; ---------------------------------------------------------------
; Scrolling routine: Linear Parallax / Psedo-surface
; ---------------------------------------------------------------
; Input:
;	d7	.w	$00PP, where PP is parameter
;
; Notice:
;	Don't pollute the high byte of d7!
;
; ---------------------------------------------------------------

@Parallax_Linear:

	; Calculate positions
	move.l	d0,d1				; d1 = X (16.16)
	swap	d1				; d1 = X (Int)
	mulu.w	(a1)+,d1			; d1 = X*Coef (24.8)
	lsl.l	#8,d1				; d1 = X*Coef (16.16)
	neg.l	d1				; d1 = Initial position
	move.l	d1,d2
	asr.l	d7,d2				; d2 = Linear factor

	move.w	v_screenposx,d3
	neg.w	d3
	swap	d3

	; Execute code according to number of lines set
	move.w	(a1)+,d6			; d6 = N, where N is Number of lines
	move.w	d6,d5				; d5 = N    
	lsr.w	#4,d5				; d5 = N/16
	andi.w	#15,d6				; d6 = N%16
	neg.w	d6				; d6 = -N%16
	add.w	#16,d6				; d6 = 16-N%16
	move.w	d6,d4
	add.w	d6,d6
	add.w	d6,d6
	add.w	d4,d6
	add.w	d6,d6
	jmp	@1(pc,d6)

	; Main functional block (10 bytes per loop)
@1	rept	16
	swap	d1
	move.w	d1,d3
	move.l	d3,(a0)+
	swap	d1
	add.l	d2,d1
	endr
	dbf	d5,@1

	jmp	@ProcessBlock			; process next bloku!

