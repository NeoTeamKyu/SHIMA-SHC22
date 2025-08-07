; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

GiantRing:
	; Remove this rts once special stages are semi-playable.
		rts
	; Actual object code.
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	dc.w GRing_Main-GRing_Index
		dc.w GRing_Animate-GRing_Index
		dc.w GRing_Collect-GRing_Index
		dc.w GRing_Delete-GRing_Index
	; Combined into this object from the giant ring flash
		dc.w Flash_Main-GRing_Index
		dc.w Flash_ChkDel-GRing_Index
		dc.w GRing_Delete-GRing_Index
; ---------------------------------------------------------------------------
GRing_FrameNum = $2E
; ===========================================================================

GRing_Main:	; Routine 0
		move.l	#Map_GRing,obMap(a0)
		move.w	#$2000+vramMotobugBGZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)
		tst.b	obRender(a0)
		bpl.s	GRing_Animate
		cmpi.b	#6,(v_emeralds).w ; do you have 6 emeralds?
		beq.w	GRing_Delete	; if yes, branch
		cmpi.w	#50,(v_rings).w	; do you have at least 50 rings?
		bcc.s	GRing_Okay	; if yes, branch
		rts	
; ===========================================================================

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$52,obColType(a0)

GRing_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)
		out_of_range_resp	DeleteObject
		bsr.w	GRing_LoadGfx
		bra.w	DisplaySprite
; ===========================================================================

GRing_Collect:	; Routine 4
		subq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.w	GRing_PlaySnd
		move.b	#id_GiantRing,0(a1) ; load giant ring flash object
		move.b	#8,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,$3C(a1)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0	; has Sonic come from the left?
		bcs.s	GRing_PlaySnd	; if yes, branch
		bset	#0,obRender(a1)	; reverse flash	object

GRing_PlaySnd:
		sfx	sfx_BigRing	; play giant ring sound
; ===========================================================================

GRing_Delete:	; Routines 6 and C
		bra.w	DeleteObject
; ===========================================================================
; Combined the giant ring flash into this. It's unnecessary for them to be seperate.
Flash_Main:	; Routine 8
		addq.b	#2,obRoutine(a0)
		move.l	#Map_GRing,obMap(a0)
		move.w	#$2000+vramMotobugBGZ,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#0,obPriority(a0)
		move.b	#$20,obActWid(a0)
;		move.b	#-$1,obFrame(a0)
		move.b	#4,obFrame(a0)

Flash_ChkDel:	; Routine A
		bsr.s	Flash_Collect
		out_of_range	DeleteObject
		bsr.w	GRing_LoadGfx
		bra.w	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Flash_Collect:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	@ret
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#$B,obFrame(a0)	; has animation	finished?
		bcc.s	Flash_End	; if yes, branch
		cmpi.b	#7,obFrame(a0)	; is 3rd frame displayed?
		bne.s	@ret	; if not, branch
		movea.l	$3C(a0),a1	; get parent object address
		move.b	#6,obRoutine(a1) ; delete parent object
		move.b	#id_Null,(v_player+obAnim).w ; make Sonic invisible
		move.b	#1,(f_bigring).w ; stop	Sonic getting bonuses
		clr.b	(v_invinc).w	; remove invincibility
		clr.b	(v_shield).w	; remove shield

	@ret:
		rts	
; ===========================================================================

Flash_End:
		addq.b	#2,obRoutine(a0)
		move.w	#0,(v_player).w ; remove Sonic object
		addq.l	#4,sp
		rts	
; End of function Flash_Collect

GRing_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	GRing_FrameNum(a0),d0
		beq.s	@nochange
		move.b	d0,GRing_FrameNum(a0)
		lea	(DPLC_GRing).l,a2
	
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4    ; get art tile
		andi.w  #$7FF,d4	; clear art flags
		lsl.w   #5,d4	   ; get VRAM address
		move.l	#Art_GRing,d6

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
; End of function Sonic_LoadGfx