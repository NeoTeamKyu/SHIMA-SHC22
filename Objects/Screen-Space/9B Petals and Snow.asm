; ---------------------------------------------------------------------------
; Object 9B - Falling petals and snow
; ---------------------------------------------------------------------------

petalTimer = $38
petalFrame = $39

ObjPetals:
		btst    #6,obRender(a0)                ; Is this object set to render sub sprites?
		bne.s   ObjPetals_SubSprs                ; If so, branch
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	ObjPetals_Index(pc,d0.w),d0
		jmp	ObjPetals_Index(pc,d0.w)

ObjPetals_SubSprs:
		move.w    #$200,d0                ; Display sprites
		jmp    DisplaySprite2

; ===========================================================================
ObjPetals_Index:
		dc.w ObjPetals_Init-ObjPetals_Index
		dc.w ObjPetals_Spawn-ObjPetals_Index
; ===========================================================================

ObjPetals_Init:
		moveq	#1,d1
		addq.b	#2,obRoutine(a0)                ; Set as initialized
		lea	$3A(a0),a2

	@createobj:
		jsr	FindFreeObj                ; Find a free object slot
		bne.s	@nofreeobj
		move.w	a1,(a2)+                ; Set as child object
		move.b #id_ObjPetals,(a1)                    ; Load test object
		move.b #%01000100,obRender(a1)            ; Set to render sub sprites
		move.w #vramPetalsBGZ,obGfx(a1)                ; Base tile ID
		move.l #Map_Petals,obMap(a1)            ; Mappings
		tst.b	(v_zone).w
		beq.s	@BGZ
		move.w #vramSnowMHZ,obGfx(a1)                ; Base tile ID
		move.l #Map_Snow,obMap(a1)            ; Mappings
	@BGZ:
		move.b #$30,mainspr_width(a1)            ; Set main sprite width
		move.b #$30,mainspr_height(a1)            ; Set main sprite height
		move.b	#8,mainspr_childsprites(a1)        ; Set number of child sprites
		dbf	d1,@createobj

	@nofreeobj:

ObjPetals_Spawn:
		subq.b	#1,petalTimer(a0)
		bpl.s	ObjPetals_Move
		move.b	#$10,petalTimer(a0)
		move.w	$3A(a0),a1
		bsr.s	@checksub
		move.w	$3C(a0),a1
		bsr.s	@checksub
	;	move.w	$3E(a0),a1
	;	bsr.s	@checksub
		bra.s	ObjPetals_Move

	@checksub:
		moveq	#7,d0
		lea	(sub2_x_pos-6)(a1),a1

	@findspawn:
		tst.b 	(v_victory).w
		beq.s	@cont
		rts
	@cont:
		addq.w	#6,a1
		tst.b	5(a1)
		beq.s	@spawn
		dbf	d0,@findspawn
		rts

	@spawn:
		jsr RandomNumber
		andi.w	#$1FF,d0
		add.w	(v_screenposx).w,d0
		move.w	d0,(a1)+
		move.w	(v_screenposy).w,d0
		sub.w	#8,d0
		move.w	d0,(a1)+
		move.w	#1,(a1)
		addq.l	#4,sp

ObjPetals_Move:
		subq.b	#1,petalFrame(a0)
		bpl.s	@frame
		move.b	#7,petalFrame(a0)

	@frame:
		move.w	$3A(a0),a1
		bsr.s	@fallsub
		move.w	$3C(a0),a1
		bsr.s	@fallsub
	;	move.w	$3E(a0),a1
	;	bsr.s	@fallsub
		rts
		
	@fallsub:
		move.w	(v_screenposx).w,obX(a1)
		move.w	(v_screenposy).w,obY(a1)
		moveq	#7,d2
		lea	sub2_x_pos(a1),a2

	@fallloop:
		tst.b	5(a2)
		beq.w	@nochange
		add.w	#160,(a2)
		move.w	(a2),d0
		move.w	(v_screenposx).w,d1
		sub.w	d1,d0
		cmpi.w	#-8,d0
		blt.s	@increase
		cmpi.w	#320+8,d0
		ble.s	@onscreen

	@loopsub:
		sub.w	#320,d0
		ble.s	@loopsub
		bra.s	@onscreen

	@increase:
		add.w	#320,d0
		tst.w	d0
		blt.s	@increase

	@onscreen:
		add.w	d1,d0
		move.w	d0,(a2)+

		move.b 2(a2),d0
		move.b	d2,d1
		andi.b	#3,d1
		ror.b	#3,d1
		add.b	d1,d0
		bcc.s	@dontadd
		add.w	#1,(a2)

	@dontadd:
		move.b	d0,2(a2)
		add.w	#1,(a2)

		move.w	(a2),d0
		tst.b	(f_water).w
		beq.s	@nowater
		cmp.w	(v_waterpos1).w,d0
		bge.s	@delete

	@nowater:
		move.w	(v_screenposy).w,d1
		sub.w	d1,d0
		cmpi.w	#-8,d0
		ble.s	@ywrap
		cmpi.w	#224+8,d0
		blt.s	@onscreen2

	@delete:
		clr.l	(a2)
		clr.w	-(a2)
		bra.s	@nochange

	@ywrap:
		add.w	#224,d0
		tst.w	d0
		ble.s	@ywrap

	@onscreen2:
		add.w	d1,d0
		move.w	d0,(a2)
		subq.w	#2,a2
		move.b	5(a2),d0
		tst.b	petalFrame(a0)
		beq.s	@savemap
		subq.b	#1,d0

	@savemap:
		addi.b	#8,d0
		andi.b	#$F,d0
		addq.b	#1,d0
		move.b	d0,5(a2)


	@nochange:
		addq.w	#6,a2
		dbf	d2, @fallloop
		rts