; ---------------------------------------------------------------------------
; Object 1D - flower "cannon" (BGZ)
; Reverted by Gem because the new one doesn't work as well :(
; ---------------------------------------------------------------------------
CannonBits = $30  ; Long word? I think? What the fuck, Lava.
SolidRoutines = $34	; Byte, used to be word.
Cannon_prevFrame = $35

fcwidth = $10
fcheight = $10

FlowerCannon:
 		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	FlowerCannonIndex(pc,d0.w),d1
		jmp	FlowerCannonIndex(pc,d1.w)
;---------------------------------------------------------------------------
FlowerCannonIndex:
		dc.w	GetFlowerCannonSprites-FlowerCannonIndex
		dc.w	FlowerCannonRunRoutinesAndbits-FlowerCannonIndex
;---------------------------------------------------------------------------
GetFlowerCannonSprites:
		move.l	#Map_FlowerCannon,obMap(a0)
		move.w	#vramCannonBGZ,obGfx(a0)
		move.b	#-1,Cannon_prevFrame(a0)
		ori.b	#4,obRender(a0)
		move.w	#$280,obPriority(a0)
		move.b	#$24,obActWid(a0)
		move.b	#2,SolidRoutines(a0)   ; set the cannon solid
		move.b	#2,obRoutine(a0)

FlowerCannonRunRoutinesAndbits:
		lea		(v_player).w,a1
		bsr.s	RunSolidObjectsRoutines
		lea		CannonBits(a0),a2
		move.w	(v_jpadhold2).w,d1	; reverted from v_jpadpress2 because i'm retarded and forgot that's an odd address lol
		bsr.w	FC_Capture
		lea		(Ani_FlowerCannon).l,a1
		jsr		(AnimateSprite).l
		bsr.w	FC_HandleDPLC
		jmp		(RememberState).l

; =============== S U B R O U T I N E =======================================


RunSolidObjectsRoutines:
		moveq	#0,d6
		move.b	SolidRoutines(a0),d0    ; get $34 whatever it is in solids
		bne.s	InsideCannonBranches
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		cmpi.w	#fcwidth,d0
		bgt.s	@outofrange
		cmpi.w	#-fcwidth,d0
		blt.s	@outofrange
		cmpi.w	#fcheight,d1
		bgt.s	@outofrange
		cmpi.w	#-fcheight,d1
		blt.s	@outofrange
		moveq	#1,d6

	@outofrange:
		rts

; ---------------------------------------------------------------------------

InsideCannonBranches:
		subq.w	#1,d0
		bne.s	MakeTheLaunchingObj
		rts
; ---------------------------------------------------------------------------

MakeTheLaunchingObj:
		subq.w	#1,d0
		bne.s	ResetSolidRoutine
		subq.w	#1,$36(a0)
		bpl.s	MoveTheObjectsUp
		move.b	#3,SolidRoutines(a0)  ; set the cannon to not solid

MoveTheObjectsUp:
		move.b	(v_framebyte).w,d0
		andi.b	#3,d0
		bne.s	@DontMakeObject
		jsr		(FindNextFreeObj).l
		bne.w	@DontMakeObject
		move.b	#id_FireShield_Dissipate,(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		subi.w	#$18,obY(a1)
		move.w	#-$600,obVelY(a1)

@DontMakeObject:
		rts
; ---------------------------------------------------------------------------

ResetSolidRoutine:
		clr.b	SolidRoutines(a0)   ; set the cannon solid
		rts

; =============== S U B R O U T I N E =======================================
; subroutine from s3k cannon

FC_Capture:
		tst.b	(v_springshoes).w ; if player has pogo spring, don't even bother with this routine
		bne.s	@ret
		tst.b	(v_debuguse).l		; Or if they're in debug mode!
		bne.s	@ret
		cmpi.b	#6,(v_player+obRoutine).w	; Don't touch if you're dead.
		beq.s	@ret
		cmpi.b	#8,(v_player+obRoutine).w	; Don't touch if you're drowning, either.
		beq.s	@ret
		move.b	(a2),d0
		bne.s	FC_Inside
		tst.b	d6
		beq.s	@ret
		move.w	obX(a0),obX(a1)
		move.w	#$380,obPriority(a1)
		move.w	#0,obVelX(a1)
		move.w	#0,obVelY(a1)
		move.w	#0,obInertia(a1)
		move.b	#0,obDoubleJump(a1)			; clear the drop dash
		move.b	#-$7F,(f_lockmulti).w
		bset	#2,obStatus(a1)
		bset	#1,obStatus(a1)
		move.b	#$E,obHeight(a1)
		move.b	#7,obWidth(a1)
		move.b	#id_Roll,obAnim(a1)
		move.b	#1,(a2)

	@ret:
		rts
; ---------------------------------------------------------------------------

FC_Inside:
		subq.b	#1,d0
		bne.s	FC_PrepLaunch
		move.w	obY(a0),d0
		subq.w	#8,d0
		move.w	d0,obY(a1)
		move.b	#1,obAnim(a0)
		move.b	#id_Null,obAnim(a1)			; Set player's animation to "null"
		move.b	#2,(a2)

locret_31A7A:
		rts
; ---------------------------------------------------------------------------

FC_PrepLaunch:
		subq.b	#1,d0
		bne.w	FC_Reset
 		cmpi.b	#2,SolidRoutines(a0)		; is the cannon not solid ?
		beq.s	FC_Launch					; launch sonic
		cmpi.w	#$200,CannonBits(a0)
		beq.s	loc_31A9A
		cmpi.w	#$202,CannonBits(a0)
		bne.s	FC_ButtonCheck

loc_31A9A:
		move.b	#1,SolidRoutines(a0)

FC_ButtonCheck:
		andi.w	#btnABC,d1	; #$70,d1. these are button checks, i think (Gem)
		beq.s	locret_31B04

FC_Launch:		; gonna assume a1 is sonic (Lava)	; you'd be correct (Gem)
		sfx		sfx_TubeLauncher
		move.b	#2,obAnim(a0)
		move.w	#-$A00,obVelY(a1)
		btst	#6,obStatus(a1)
		beq.s	@above
		asr.w	obVelY(a1)
	@above:
		move.w	obY(a0),obY(a1)
		subi.w	#$18,obY(a1)
		move.b	#0,(f_lockmulti).w			; unfreeze player's controls
		bset	#1,obStatus(a1)
		clr.b	jumping(a1)
		move.b	#id_Roll,obAnim(a1)
		move.b	#2,SolidRoutines(a0)		; not solid flag
		move.w	#$F,$36(a0)
		move.b	#3,(a2)
		move.b	#8,2(a2)

locret_31B04:
		rts
; ---------------------------------------------------------------------------

FC_Reset:
		subq.b	#1,2(a2)
		bne.s	locret_31B16
		move.w	#$100,obPriority(a1)
		move.b	#0,(a2)					; go back to 0

locret_31B16:
		rts
; End of function FC_Capture

FC_HandleDPLC:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	Cannon_prevFrame(a0),d0
		beq.s	@nochange
		move.b	d0,Cannon_prevFrame(a0)
		lea		(DPLC_FlowerCannon).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@nochange
		move.w	obGfx(a0),d4			; get art tile
		andi.w	#$7FF,d4				; clear art flags
		lsl.w	#5,d4					; get VRAM address
		move.l	#Art_FlowerCann,d6

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
		dbf	d5,@readentry				; repeat for number of entries

	@nochange:
		rts

Ani_FlowerCannon:
		dc.w	@idle-Ani_FlowerCannon
		dc.w	@close-Ani_FlowerCannon
		dc.w	@fire-Ani_FlowerCannon

	@idle:	dc.b	$7F,@fr_open,	afEnd
	@close:	dc.b	3,	@fr_squish,	@fr_hold,	afBack,	1
	@fire:	dc.b	2,	@fr_squish,	@fr_hold,	@fr_fire,	@fr_fire,	@fr_hold,	@fr_fire,	@fr_hold,	afChange,	0
		even
	
	rsreset
	@fr_open:	rs.b	1
	@fr_hold:	rs.b	1
	@fr_squish:	rs.b	1
	@fr_fire:	rs.b	1