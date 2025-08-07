; shitty fucking flickermove ass bullshit that takes up a whole ass object slot fuck you lava
Obj_FlickerMove:
		jsr	(ObjectFall).l
		out_of_range_resp	Go_Delete_Sprite_3
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below the level boundary?
		bcs.s	Go_Delete_Sprite_3	; if yes, branch
		bchg	#6,$38(a0)
		beq.w	locret_8405E
		jmp	(DisplaySprite).l
Go_Delete_Sprite_3:
	        bset	#7,status(a0)
		bset	#4,$38(a0)
;		sfx	sfx_Lamppost,0,0,0
NearJmptToTardedObject:
		jmp    DeleteObject

locret_8405E:
		rts

Sprite_CheckDelete:
          	out_of_range_resp	@fuck
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

	@fuck:
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	@whatamess		; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again

	@whatamess:
                move.b  #$14,routine(a0)
		bset	#7,status(a0)
                   rts

Improved_Sprite_DeleteFlicker: ; kiss my ass
		moveq	#0,d0
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	Destroyed_PoshBee
		jmp	(Sprite_CheckDelete).l
Destroyed_PoshBee:
               	bset	#7,status(a0)
		move.b	#$F,0(a0)
		clr.b	collision_flags(a0)
		jsr	(Set_IndexedVelocity).l
		jmp	(DisplaySprite).l