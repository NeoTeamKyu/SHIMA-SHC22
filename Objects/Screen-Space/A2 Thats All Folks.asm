; ---------------------------------------------------------------------------
; Object A2 - That's All, Folks! logo
; ---------------------------------------------------------------------------

ThatsAllFolks:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TLF_Index(pc,d0.w),d1
		jsr	TLF_Index(pc,d1.w)	
		bsr.w	PLCLoad_TAF
		jmp		DisplaySprite			
; ===========================================================================
TLF_Index:	dc.w TLF_Main-TLF_Index	
			dc.w TLF_DoneInit-TLF_Index    
			
TLF_time:	equ $30		; time until exit
; ===========================================================================
TLF_Main:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_TAF,obMap(a0)
		move.w	#$541,obGfx(a0)
		move.b	#4,obRender(a0)		
		move.w	#$80,obPriority(a0)
		move.b 	#$18,obActWid(a0)
		move.w	#560,TLF_time(a0) ; set duration for delay (5 seconds)

TLF_DoneInit:
		subq.w	#1,TLF_time(a0) ; subtract 1 from duration
		bpl.s	TLF_Wait
		move.b	#id_EndOfDemoScreen,(v_gamemode).w ; exit to credits

	TLF_Wait:
		rts

PLCLoad_TAF:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		lea	(DPLC_TAF).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		move.l	#Unc_TAF,d6

    @readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readentry	; repeat for number of entries

    @nochange:
		rts
	

DPLC_TAF:	
	include		"DPLCs\That's All Folks.asm"
	even
	
Map_TAF:	
	include		"Mappings\That's All Folks.asm"
	even
	
Unc_TAF:
	incbin		"art\uncompressed\That's All Folks.bin"
	even
		