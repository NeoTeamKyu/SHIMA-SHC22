; ---------------------------------------------------------------------------
; Object 21 - Broken monitor shards
; ---------------------------------------------------------------------------

MonitorShards:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	MonShard_Index(pc,d0.w),d1
		jmp		MonShard_Index(pc,d1.w)
; ===========================================================================
MonShard_Index:
		dc.w	MonShard_Init-MonShard_Index
		dc.w	MonShard_Main-MonShard_Index
		dc.w	MonShard_Shard-MonShard_Index
; ===========================================================================
MonShard_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_MonitorShard,obMap(a0)
		move.w	#vramExplode,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)
;		move.b	#10,obDelayAni(a0)

MonShard_Main:
		lea	(Mon_FragSpd).l,a4
		moveq	#3,d1		; load 4 fragments
		btst	#bitMusic,(v_miscOptions).w
		bne.s	@musOff
		move.b	#sfx_GlassShatter,d6
		bra.s	@cont
	@musOff:
	; The closest I can get to a "blank" sound...
	; but I'm gonna modify SmashObject to not play
	; anything if this is passed.
	; This will let the explosion object
	; play the sound on its own.
		move.b	#sfx_ChargeStop,d6
	@cont:
		bset	#7,obRender(a0)
		jmp		SmashObject

MonShard_Shard:
;		addq.l	#4,sp
		jsr		SpeedToPos
		move.w	#8,d0
		tst.w	obVelX(a0)
		bpl.s	@posvelx
		neg.w	d0
	@posvelx:
		sub.w	d0,obVelX(a0)
		move.w	obsmashGrav(a0),d0
		add.w	d0,obVelY(a0)
		tst.b	obRender(a0)
		bpl.s	MonShard_Delete
		tst.b   obTimeFrame(a0)
		beq.s   @skip
		subq.b  #1,obTimeFrame(a0)
		bra.s   @justdisplay
		
	@skip:
		move.b  #3,obTimeFrame(a0)
		addq.b  #1,obFrame(a0)
		cmpi.b  #4,obFrame(a0)
		bne.s   @justdisplay
		clr.b   obFrame(a0)
		
	@justdisplay:
		jmp		(DisplaySprite).l

MonShard_Delete:
		jmp		DeleteObject
; ===========================================================================
Mon_FragSpd:
		; x velocity, y velocity, gravity
		dc.w	-$200,	-$400,	$48	; left
		dc.w	-$100,	-$400,	$48	; middle-left
		dc.w	 $100,	-$400,	$48	; middle-right
		dc.w	 $200,	-$400,	$48	; right

Ani_MonShard:
		dc.w	MonShardAni_Hate-Ani_MonShard
		
MonShardAni_Hate:	dc.b	3, 0, 1, 2, 3, afEnd
		even