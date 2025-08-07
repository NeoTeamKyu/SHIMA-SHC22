shield_LastLoadedDPLC = $33
shield_Art_Address = $38
shield_DPLC_Address = $3C

	rsreset
shID_Null:	rs.b 1
shID_Norm:	rs.b 1
shID_Fire:	rs.b 1
shID_Gold:	rs.b 1
shID_Elec:	rs.b 1
shID_Bubb:	rs.b 1
; ---------------------------------------------------------------------------
; Object 38 - Shield
; ---------------------------------------------------------------------------
ShieldItem: ; XREF: Obj_Index
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	ShieldItem_Index(pc,d0.w),d1
		jmp	ShieldItem_Index(pc,d1.w)
; ===========================================================================
; off_1D900:
ShieldItem_Index:
		dc.w ShieldItem_Init-ShieldItem_Index	; 0
		dc.w ShieldItem_Main-ShieldItem_Index	; 2
; ===========================================================================
; loc_1D904:
ShieldItem_Init:
		tst.b	(v_invinc).w
		bne.s	@nosparks
		move.l	#Art_LightningSparks,d1
		move.w	#vramShield*$20+$3E0,d2
		move.w	#$50,d3
		jsr     (QueueDMATransfer)
	@nosparks:
		moveq	#0,d0
		move.b	(v_shield).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	@mapLUT(pc,d0.w),obMap(a0)
		move.l	@plcLUT(pc,d0.w),shield_DPLC_Address(a0)
		move.l	@artLUT(pc,d0.w),shield_Art_Address(a0)
		bra.s	@doneLoading

	@mapLUT:
		dc.l	Map_Sonic, Map_Shield, Map_FireShield, Map_GoldShield, Map_LightningShield, Map_BubbleShield

	@plcLUT:
		dc.l	DPLC_Sonic, DPLC_Shield, DPLC_FireShield, DPLC_GoldShield, DPLC_LightningShield, DPLC_BubbleShield

	@artLUT:
		dc.l	Art_Sonic, Art_Shield, Art_FireShield, Art_GoldShield, Art_LightningShield, Art_BubbleShield

	@doneLoading:
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.w	#vramShield,obGfx(a0)
		btst	#7,(v_player+obGfx).w
		beq.s	loc_195F0S
		bset	#7,obGfx(a0)

loc_195F0S:
		move.w	#1,obAnim(a0)	; Clear anim and set prev_anim to 1
		move.b	#-1,shield_LastLoadedDPLC(a0)	; Reset LastLoadedDPLC (used by PLCLoad_Shields)
		addq.b	#2,obRoutine(a0) ; => ShieldItem_Main
; loc_1D92C:
ShieldItem_Main:
		lea	(v_player).w,a2 ; a2=character
		tst.b	(v_invinc).w
		bne.w	@ret
		cmpi.b	#id_Null,obAnim(a2)	; Is player in their 'blank' animation?
		beq.w	@ret	; If so, do not display and do not update variables
		tst.b	(v_shield).w
		beq.w	@del	; If not, change to Ins-- uhhh. Nothing.
		cmpi.b	#shID_Fire,(v_shield).w
		bne.s	@notFire
		jmp		FireShield_Main
	@notFire:
		cmpi.b	#shID_Elec,(v_shield).w
		bne.s	@notElec
		jmp		LightningShield_Main
	@notElec:
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		andi.w	#$7FFF,obGFX(a0)
		tst.w	obGFX(a2)
		bpl.s	@nothighpriority
		ori.w	#$8000,obGFX(a0)

	@nothighpriority:
		cmpi.b	#shID_Gold,(v_shield).w
		bne.s	@notGold
	@gold:
		cmpi.b	#charID_Sonic,(v_character).w
		bne.s	@notGold
		tst.b	(v_player+obDoubleJump).w				; Are we double jumping?
		beq.s	@notGold	; If not, branch and display
		move.b	#id_GoldShield_Trail,(v_stars).w	; This causes an issue, find somewhere else to put this
		move.w	a0,(v_stars+parent).w
	@notGold:
		moveq	#0,d0
		move.b	(v_shield).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	@aniLUT(pc,d0.w),a1
		bra.s	@done

	@aniLUT:
		dc.l	Ani_Sonic, Ani_Shield, Ani_19A02, Ani_GoldShield, Ani_19A2A, Ani_19A7A
	
	@done:
		jsr	(AnimateSprite).l
		jsr	(PLCLoad_Shields).l
		jmp	(DisplaySprite).l

	@del:
		clr.b	(v_shield).w		; remove shield

	@ret:
		rts

FireShield_Main:	; Duplicate code before this point has been trimmed out.
		btst	#6,obStatus(a2)	; Is player underwater?
		bne.s	@delUW	; If so, branch
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		tst.b	obAnim(a0)	; Is shield in its 'dashing' state?
		bne.s	@nothighpriority	; If so, do not update orientation or allow changing of the priority art_tile bit
		move.b	obStatus(a2),obStatus(a0)	; Inherit status
		andi.b	#1,obStatus(a0)	; Limit inheritance to 'orientation' bit
		andi.w	#$7FFF,obGFX(a0)
		tst.w	obGFX(a2)
		bpl.s	@nothighpriority
		ori.w	#$8000,obGFX(a0)

	@nothighpriority:
		lea	(Ani_19A02).l,a1
		jsr	(AnimateSprite).l
		move.w	#$80,obPriority(a0)	; Layer shield over player sprite
		cmpi.b	#$F,mapping_frame(a0)	; Are these the frames that display in front of the player?
		blo.s	@overplayer	; If so, branch
		move.w	#$180,obPriority(a0)	; If not, layer shield behind player sprite

	@overplayer:
		bsr.w	PLCLoad_Shields
		jmp	(DisplaySprite).l

	@delUW:
		jsr	(FindFreeObj).l		; Make Smoke Puff Sprite when fire shield in water
		bne.w	@del
		move.b	#id_FireShield_Dissipate,(a1)
		move.w	obX(a0),obX(a1)	; Put it at shields' x_pos
		move.w	obY(a0),obY(a1)	; Put it at shields' y_pos

	@del:
		clr.b	(v_shield).w		; remove shield

	@ret:
		rts

LightningShield_Main:
		btst	#6,status(a2)	; Is player underwater?
		bne.s	Obj_Lightning_Shield_FlashWater	; If so, branch
		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		andi.w	#$7FFF,obGFX(a0)
		tst.w	obGFX(a2)
		bpl.s	@nothighpriority
		ori.w	#$8000,obGFX(a0)

	@nothighpriority:
		tst.b	obAnim(a0)	; Is shield in its 'double jump' state?
		beq.s	@display	; Is not, branch and display
		bsr.w	Obj_Lightning_Shield_Create_Spark	; Create sparks
		clr.b	obAnim(a0)	; Once done, return to non-'double jump' state

	@display:
		lea	(Ani_19A2A).l,a1
		jsr	(AnimateSprite).l
		move.w	#$80,obPriority(a0)	; Layer shield over player sprite
		cmpi.b	#$E,obFrame(a0)	; Are these the frames that display in front of the player?
		blo.s	@overplayer	; If so, branch
		move.w	#$180,obPriority(a0)	; If not, layer shield behind player sprite

	@overplayer:
		bsr.w	PLCLoad_Shields
		jmp	(DisplaySprite).l

	@del:
		clr.b	(v_shield).w		; remove shield

	@ret:
		rts
; ---------------------------------------------------------------------------

Obj_Lightning_Shield_FlashWater:
		addq.b	#2,obRoutine(a0)
		clr.b	(v_shield).w	; remove shield
		clr.b	(v_oshield).w	; okay ACTUALLY remove the shield because otherwise we crash

;	Flashes the underwater palette white
		lea	(v_pal_water).w,a1
		lea	(v_pal_water_dup).w,a2
		move.w	#($80/4)-1,d0	; Size of Water_palette/4-1

	@loop:
		move.l	(a1),(a2)+	; Backup palette entries
		move.l	#$0EEE0EEE,(a1)+	; Overwrite palette entries with white
		dbf	d0,@loop	; Loop until entire thing is overwritten

		move.b	#3,obTimeFrame(a0)
		rts

; =============== S U B R O U T I N E =======================================


Obj_Lightning_Shield_Create_Spark:
		moveq	#1,d2

Obj_Lightning_Shield_Create_Spark_Part2:
		lea	(SparkVelocities).l,a2
		moveq	#3,d1

loc_19816:
; Sprite_1D8F2:
		jsr	(FindFreeObj).l	; Set up for a new object
		bne.s	locret_19862
		move.b	#id_LightningShieldSpark,(a1)		; Create Lightning Shield Spark
		move.w	obX(a0),obX(a1)	; (Spark) Inherit x_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	obY(a0),obY(a1)	; (Spark) Inherit y_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.l	obMap(a0),obMap(a1)	; (Spark) Inherit mappings from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	obGfx(a0),obGfx(a1)	; (Spark) Inherit art_tile from source object (Lightning Shield, Hyper Sonic Stars)
		move.b	#4,obRender(a1)
		move.w	#$80,obPriority(a1)
		move.b	#8,obActWid(a1)
		move.b	d2,obAnim(a1)
		move.w	(a2)+,obVelX(a1)	; (Spark) Give x_vel (unique to each of the four Sparks)
		move.w	(a2)+,obVelY(a1)	; (Spark) Give y_vel (unique to each of the four Sparks)
		dbf	d1,loc_19816

locret_19862:
		rts
; End of function Lightning_Shield_Create_Spark
; ---------------------------------------------------------------------------
SparkVelocities:dc.w  -$200, -$200
	dc.w   $200, -$200
	dc.w  -$200,  $200
	dc.w   $200,  $200
; ---------------------------------------------------------------------------
LightningShieldSpark:
		jsr	(SpeedToPos).l
		addi.w	#$18,obVelY(a0)
		lea	(Ani_19A2A).l,a1
		jsr	(AnimateSprite).l
		tst.b	obRoutine(a0)	; Changed by Animate_Sprite
		bne.s	Obj_Lightning_Shield_Spark_Delete
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

Obj_Lightning_Shield_Spark_Delete:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

Obj_Lightning_Shield_DestroyUnderwater2:
		subq.b	#1,obTimeFrame(a0)	; Is it time to end the white flash?
		bpl.s	locret_198BC	; If not, return
		clr.b	(v_shield).w	; remove shield
		lea	(v_pal_water_dup).w,a1
		lea	(v_pal_water).w,a2
		move.w	#($80/4)-1,d0	; Size of Water_palette/4-1

loc_198B6:
		move.l	(a1)+,(a2)+	; Restore backed-up underwater palette
		dbf	d0,loc_198B6	; Loop until entire thing is restored

locret_198BC:
		rts

GoldShield_Trail: ; General Afterimages for Gold Shield (Shorter version of the normal Super Trails. Made it a Separate object to make checks simpler and leave the other one exclusive to players
; This thing literally doesn't even need a routine counter, and that was causing issues anyway.
		moveq	#0,d0
; Initialize
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
; Main code
		movea.w	parent(a0),a2
		cmpi.b	#shID_Gold,(v_shield).w			; Does Player have a Gold Shield?
		bne.s	@jmptoDeleteObject	; If not, branch and delete
		tst.b	(v_player+obDoubleJump).w				; Are we double jumping?
		beq.s	@jmptoDeleteObject	; If not, branch and delete
		moveq	#$C,d1				; This will be subtracted from Pos_table_index, giving the object an older entry
		btst	#0,(v_framecount+1).w	; Even frame? (Think of it as 'every other number' logic)
		beq.s	@evenframe			; If so, branch
		moveq	#$14,d1				; On every other frame, use a different number to subtract, giving the object an even older entry

	@evenframe:
		move.w	(v_trackpos).w,d0
		lea	(v_trackPlayer).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)			; Use previous Shield x_pos
		move.w	(a1)+,obY(a0)			; Use previous Shield y_pos
		move.l	obMap(a2),obMap(a0)	; Load mappings
		move.w	obGfx(a2),obGfx(a0)
		move.b	obFrame(a2),obFrame(a0)	; Use current mapping_frame
		move.b	obRender(a2),obRender(a0)	; Use current render_flags
		move.w	obPriority(a2),obPriority(a0)		; Use current priority
		jmp	(DisplaySprite).l
	@jmptoDeleteObject:
		jmp	(DeleteObject).l		; If so, branch and delete

; ===========================================================================

PLCLoad_Shields:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	shield_LastLoadedDPLC(a0),d0
		beq.s	@ret
		move.b	d0,shield_LastLoadedDPLC(a0)
		move.l	shield_DPLC_Address(a0),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	@ret
		move.w	#vramShield*$20,d4	; There was absolutely no point in this being seperate.

; loc_1D1D2:
	@readEntry:
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
		add.l	shield_Art_Address(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,@readEntry	; repeat for number of entries

	@ret:
		rts
; End of function PLCLoad_Shields