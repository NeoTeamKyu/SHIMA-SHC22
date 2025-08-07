; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)
; ---------------------------------------------------------------------------

Scenery:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Scen_Index(pc,d0.w),d1
		jmp	Scen_Index(pc,d1.w)
; ===========================================================================
Scen_Index:	dc.w Scen_Main-Scen_Index
		dc.w Scen_ChkDel-Scen_Index
; ===========================================================================

Scen_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; copy object subtype to d0
		mulu.w	#$A,d0		; multiply by $A
		lea	Scen_Values(pc,d0.w),a1
		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1)+,obPriority(a0)
	; Fixes the priority to make it work with the 3K system.
		move.w	obPriority(a0),d0	; Move priority to d0
		lsr.w	#1,d0				; Logical shift right... probably multiplying by $80?
		andi.w	#$380,d0			; AND it by $380, basically capping it
		move.w	d0,obPriority(a0)	; Move that back to the priority as a word
		move.b	(a1)+,obColType(a0)

Scen_ChkDel:	; Routine 2
		out_of_range_resp	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Variables for	object $1C are stored in an array
; ---------------------------------------------------------------------------
Scen_Values:
		dc.l Map_Scen		; mappings address
		dc.w $44D8		; VRAM setting
		dc.b 0,	8, 2, 0		; frame, width,	priority, collision response
		dc.l Map_Scen
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_Scen
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_Bri
		dc.w $4000+vramBridgeLBGZ
		dc.b 1,	16, 1,	0
		dc.l Map_BGZSeaweed
		dc.w vramSeaweedBGZ
		dc.b 0, 8, 6, 0
		dc.l Map_HPZOrb
		dc.w $6362
		dc.b 0, 16, 1, 0
		dc.l Map_BGZShoji
		dc.w $C000+vramBlockBGZ
		dc.b 0, 16, 6, 0
		dc.l Map_MHZLamp
		dc.w vramDecorMHZ
		dc.b 0, 16, 6, 0
		dc.l Map_Bri
		dc.w $4000+vramDecorMHZ
		dc.b 1,	16, 1,	0
		even