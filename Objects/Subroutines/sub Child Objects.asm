capsule_Child_dx = $2C
capsule_Child_dy = $2D  ; ObjOFF
Child_Distance = $30
Child_Speed = $2E
CreateChild1_Normal:
		moveq	#0,d2				; Includes positional offset data
		move.w	(a2)+,d6

loc_84064:
		jsr	(FindNextFreeObj).l
		bne.s	locret_840AE
		move.w	a0,obParent3(a1)			; Parent RAM address into $46
		move.l  mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)		; Mappings and VRAM offset copied from parent object
		move.b	(a2)+,0(a1)			; Object address
		move.b	(a2)+,routine(a1)  ; i added that line so we dont use object id space
		move.b	d2,subtype(a1)			; Index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1			; X Positional offset
		move.b	d1,parent(a1)			; $42 has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)			; Apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1			; Same as above for Y
		move.b	d1,capsule_Child_dy(a1)			; $43 has the Y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)			; Apply offset
		addq.w	#2,d2				; Add 2 to index
		dbf	d6,loc_84064			; Loop
		moveq	#0,d0

locret_840AE:
		rts
; End of function CreateChild1_Normal
Refresh_ChildPosition:
		movea.w	obParent3(a0),a1
		move.w	x_pos(a1),d0
		move.b	capsule_Child_dx(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	capsule_Child_dy(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts
; End of function Refresh_ChildPosition 
Check_PlayerInRange:
		moveq	#0,d0
		lea	(v_ball).w,a2
		move.w	x_pos(a2),d1 ;tails Cpausle X  (his Pos)
		move.w	y_pos(a2),d2 ; tails Capsule y
		move.w	x_pos(a0),d3 ; load capsule x
		move.w	y_pos(a0),d4 ; load capsule y
		add.w	(a1)+,d3
		move.w	d3,d5
		add.w	(a1)+,d5
		add.w	(a1)+,d4
		move.w	d4,d6
		add.w	(a1)+,d6
		bsr.w	sub_8592C
		swap	d0
		lea	(v_player).w,a2
		move.w	x_pos(a2),d1  ; sonic x
		move.w	y_pos(a2),d2   ; sonic y
; End of function Check_PlayerInRange
sub_8592C:
		cmp.w	d3,d1
		blo.s	locret_8593E
		cmp.w	d5,d1
		bhs.s	locret_8593E
		cmp.w	d4,d2
		blo.s	locret_8593E
		cmp.w	d6,d2
		bhs.s	locret_8593E
		move.w	a2,d0

locret_8593E:
		rts
Child_Draw_Sprite:
		movea.w	obParent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		jmp	(DisplaySprite).l
Go_Delete_Sprite:
	;	move.l	#Delete_Current_Sprite,(a0)
                jsr     DeleteObject
		bset	#7,status(a0)
		rts
Set_IndexedVelocity:
		moveq	#0,d1
		move.b	subtype(a0),d1
		add.w	d1,d1
		add.w	d1,d0
		lea	Obj_VelocityIndex(pc,d0.w),a1
		move.w	(a1)+,x_vel(a0)
		move.w	(a1)+,y_vel(a0)
		btst	#0,render_flags(a0)
		beq.s	locret_852F2
		neg.w	x_vel(a0)

locret_852F2:
		rts
; End of function Set_IndexedVelocity
Obj_VelocityIndex:	dc.w  $FF00, $FF00
		dc.w   $100, $FF00
		dc.w  $FE00, $FE00
		dc.w   $200, $FE00
		dc.w  $FD00, $FE00
		dc.w   $300, $FE00
		dc.w  $FE00, $FE00
		dc.w      0, $FE00
		dc.w  $FC00, $FD00
		dc.w   $400, $FD00
		dc.w   $300, $FD00
		dc.w  $FC00, $FD00
		dc.w   $400, $FD00
		dc.w  $FE00, $FE00
		dc.w   $200, $FE00
		dc.w      0, $FF00
		dc.w  $FFC0, $F900
		dc.w  $FF80, $F900
		dc.w  $FE80, $F900
		dc.w  $FF00, $F900
		dc.w  $FE00, $F900
		dc.w  $FD80, $F900
		dc.w  $FD00, $F900
		dc.w      0, $FF00
		dc.w  $FF00, $FF00
		dc.w   $100, $FF00
		dc.w  $FE00, $FF00
		dc.w   $200, $FF00
		dc.w  $FE00, $FE00
		dc.w   $200, $FE00
		dc.w  $FD00, $FE00
		dc.w   $300, $FE00
		dc.w  $FD00, $FD00
		dc.w   $300, $FD00
		dc.w  $FC00, $FD00
		dc.w   $400, $FD00
		dc.w  $FE00, $FD00
		dc.w   $200, $FD00
CreateChild6_Simple:
		moveq	#0,d2				; Simple child creation routine, merely creates x number of the same object at the parent's position
		move.w	(a2)+,d6

loc_84224:
		jsr	(FindNextFreeObj).l
		bne.s	locret_84256
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.b	(a2)+,0(a1)
                move.b	(a2)+,routine(a1)  ; i added that line so we dont use object id space
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2
		dbf	d6,loc_84224
		moveq	#0,d0


locret_84256:
		rts
; End of function CreateChild6_Simple

Refresh_ChildPositionAdjusted:
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d0
		move.b	capsule_Child_dx(a0),d1
		ext.w	d1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	loc_843D2
		neg.w	d1
		bset	#0,render_flags(a0)

loc_843D2:
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	capsule_Child_dy(a0),d1
		ext.w	d1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	loc_843F8
		neg.w	d1
		bset	#1,render_flags(a0)

loc_843F8:
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts
; End of function Refresh_ChildPositionAdjusted
MoveSprite_Circular:
		move.b	Child_Distance(a0),d0
		jsr	(CalcSine).l
		move.w	Child_Speed(a0),d2
		move.w	d2,d3
		muls.w	d0,d2
		swap	d2
		muls.w	d1,d3
		swap	d3
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d0
		add.w	d2,d0
		move.b	capsule_Child_dx(a0),d4
		ext.w	d4
		add.w	d4,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d1
		add.w	d3,d1
		move.b	capsule_Child_dy(a0),d4
		ext.w	d4
		add.w	d4,d1
		move.w	d1,y_pos(a0)
		rts
MoveSprite_CircularSimple:
		move.b	Child_Distance(a0),d0
		jsr	(CalcSine).l
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	d2,d0
		asr.l	d2,d1
		movea.w	parent3(a0),a1
		move.l	x_pos(a1),d2
		move.l	y_pos(a1),d3
		add.l	d0,d2
		add.l	d1,d3
		move.l	d2,x_pos(a0)
		move.l	d3,y_pos(a0)
		rts

