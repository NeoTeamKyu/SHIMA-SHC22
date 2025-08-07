Trail_Object:
	moveq	#0,d0
	move.b  obRoutine(a0), d0
	move.w  Trail_Index(pc,d0),d1
	jmp	 Trail_Index(pc,d1)
; ===========================================================================
Trail_Index:		dc.w	Obj_Super_Trail_Init-Trail_Index ; 0
		dc.w	Obj_Super_Trail_Main-Trail_Index ; 2
; ===========================================================================
Obj_Super_Trail_Init:
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		addq.b  #2,obRoutine(a0)

Obj_Super_Trail_Main:
		movea.w	parent(a0),a2
		tst.b	(v_super).w	; Are we in non-super/hyper state?
		beq.s	@Check_SpeedShoes		; If so, branch and delete
		bra.s	@Obj_Super_Trail_Main_Continued
	@Check_SpeedShoes:
		tst.b	(v_shoes).w	; Are we with Speed Shoes?	
		beq.s	@Check_HammerDropM	; If not, check for the hammer drop
		bra.s	@Obj_Super_Trail_Main_Continued

	@Check_HammerDropM:
		cmpi.b	#charID_Mighity,(v_character).w
		bne.w	@jmptoDeleteObject	;	@Check_BoostMode
		cmpi.b	#1,obDoubleJump(a2)
		bne.w	@jmptoDeleteObject	; If so, branch and delete
;		bra.s	@Obj_Super_Trail_Main_Continued

;	@Check_BoostMode:
;		cmpi.b	#charID_Sonic,(v_character).w
;		beq.w	@Check_BM_Cont
;		cmpi.b	#charID_Metal,(v_character).w
;		bne.w	@jmptoDeleteObject
;	@Check_BM_Cont:
;		cmpi.b	#1,obBoostMode(a2)
;		bne.w	@jmptoDeleteObject	; If so, branch and delete

	@Obj_Super_Trail_Main_Continued:
		moveq	#$C,d1				; This will be subtracted from Sonic_Pos_Record_Index, giving the object an older entry
		btst	#0,(v_framecount+1).w	; Even frame? (Think of it as 'every other number' logic)
		beq.s	@evenframe			; If so, branch
		moveq	#$14,d1				; On every other frame, use a different number to subtract, giving the object an even older entry

	@evenframe:
		move.w	(v_trackpos).w,d0
		lea	(v_trackPlayer).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,x_pos(a0)			; Use previous player x_pos
		move.w	(a1)+,y_pos(a0)			; Use previous player y_pos
		lea	(v_trackbyte).w,a1
;		move.b	3(a1,d0.w),obGfx(a0)
		move.l	obMap(a2),obMap(a0)	; Load mappings
		move.w	obGfx(a2),obGfx(a0)
		move.b	obFrame(a2),obFrame(a0)	; Use current mapping_frame
		move.b	obRender(a2),obRender(a0)	; Use current render_flags
		move.w	obPriority(a2),obPriority(a0)		; Use current priority
		jsr		(DisplaySprite).l
		cmpi.b	#charID_Tails,(v_character).w
		bne.s	@nottails
		tst.b	(v_trails2).w
		bne.s	@nottails
		move.b	#id_Trail,(v_trails2).w ; load Obj7E (super sonic stars object) at $FFFFD040
		move.w	#v_followobject,(v_trails2+parent).w

	@nottails:
		rts

	@jmptoDeleteObject:
		jmp	(DeleteObject).l		; If so, branch and delete