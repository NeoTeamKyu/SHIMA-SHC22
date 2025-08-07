; ---------------------------------------------------------------------------
; Object 4A - Snow Tulipon enemy from Melting Heights Zone
; ---------------------------------------------------------------------------
; Holy shit. What a mess. How does he work like this?
SnowTulipon:
		bset	#2,render_flags(a0)
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	off_86D84(pc,d0.w),d1
		jsr		off_86D84(pc,d1.w)
		jmp		(RememberState).l ; uh no need for Sprite_CheckDeleteTouch bc we dont hav addcollsion to response list
; ---------------------------------------------------------------------------
off_86D84:
		dc.w	loc_86D8A-off_86D84 ;0
		dc.w	loc_86DA2-off_86D84 ;2
		dc.w	loc_86DC6-off_86D84 ;4
		; ball
		dc.w	loc_86D4A-off_86D84  ;6
		dc.w	loc_86D5E-off_86D84  ;8
; ---------------------------------------------------------------------------

loc_86D8A:
		lea		ObjDat3_86E12(pc),a1
		jsr		SetUp_ObjAttributes(pc)
		move.l	#loc_86DAE,SavedPointer(a0)
		move.w	#$1F,WaitObjectVar(a0)
locret_86DA0:
		rts
; ---------------------------------------------------------------------------

loc_86DA2:
		tst.b	render_flags(a0) ; is the object on scree
		bpl.w	locret_86DA0     ; branch
		jmp		(Obj_Wait).l      ; wait if we are on screen
; ---------------------------------------------------------------------------

loc_86DAE:
		move.b	#4,routine(a0)
		move.l	#byte_86E42,Pointer(a0) ; this is fordata i g
		move.l	#loc_86DFC,SavedPointer(a0)  ; save a pointer here
		rts
; ---------------------------------------------------------------------------

loc_86DC6:
		jsr		(Animate_RawMultiDelay).l   ; this runs macros that get what was saved in loc_86DAE in $34
		beq.s	locret_86DA0
		cmpi.b	#6,d0       ; idk what is this
		beq.s	loc_86DD8
		cmpi.b	#$E,d0
		bne.s	locret_86DA0

loc_86DD8:
		sfx		sfx_Dash
		lea		(ChildObjDat_86E2A).l,a2 ; make balls
		jsr		(CreateChild2_Complex).l
		bne.s	locret_86DFA
		addq.b	#1,$39(a0) ; custom status thing idk
		btst	#0,$39(a0)
		beq.s	locret_86DFA
		neg.w	x_vel(a1)  ; change the throw thing

locret_86DFA:
		rts
; ---------------------------------------------------------------------------

loc_86DFC:
		move.b	#2,routine(a0) ; reset
		move.w	#$78,WaitObjectVar(a0)    ; waiting time
		move.l	#loc_86DAE,SavedPointer(a0)
		rts
loc_86D4A:
		movea.l	Pointer2(a0),a1   ;  get the ball data
		jsr		SetUp_ObjAttributes    ; give the object a routine incressment
		bset	#0,obShieldDeflect(a0)	; Allow it to be deflected.

loc_86D5E:
		movea.l	SavedPointer(a0),a1 ; uhhh move the sprite
		jsr		(a1)	; get addr
		jmp		RememberState	;(Sprite_CheckDeleteTouchXY).l  ; ig s1 doesnt have y and x delete
; hopefully i got the labeling right and didnt dizzy out due to stress
Animate_RawMultiDelay:
		movea.l	Pointer(a0),a1
; End of function Animate_RawMultiDelay


; =============== S U B R O U T I N E =======================================


Animate_RawNoSSTMultiDelay:
		subq.b	#1,anim_frame_duration(a0)
		bpl.s	loc_845C8
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	loc_845CC
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_duration(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_845C8:
		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------

loc_845CC:
		neg.b	d1
		jsr		loc_845D2+2(pc,d1.w) ; + skips the rts and reads from loc_845F2 with the jumptable or whatever

loc_845D2:
		clr.b	anim_frame(a0)  ; clear anim
		rts
; End of function Animate_RawNoSSTMultiDelay

; ---------------------------------------------------------------------------
		bra.w	loc_845F2
; ---------------------------------------------------------------------------
		bra.w	loc_845E4
; ---------------------------------------------------------------------------
		bra.w	loc_84600
; ---------------------------------------------------------------------------

loc_845E4:
		move.b	1(a1,d0.w),d1
		ext.w	d1
		lea		(a1,d1.w),a1
		move.l	a1,Pointer(a0)  ; get a1 data ?

loc_845F2:
		move.b	(a1),mapping_frame(a0)
		move.b	1(a1),anim_frame_duration(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_84600:
		clr.b	anim_frame_duration(a0)
		movea.l	SavedPointer(a0),a1  ; yeah thats where the objects like tulpon wait and stuff or get a pointer
		jsr		(a1)
		moveq	#-1,d2
		rts

CreateChild2_Complex:
		moveq	#0,d2				; Includes positional offset data and velocity and CHECKLATER
		move.w	(a2)+,d6

loc_840B4:
		jsr		(FindNextFreeObj).l
		bne.s	BranchCustomRoutine
		move.w	a0,parent(a1)	; normal parent bc i need $3C to be the pointer
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)		; Mappings and VRAM offset copied from parent object
		move.b	(a2)+,(a1)      ; get id
		move.b	(a2)+,routine(a1) ; yeahhhhhhhhhhhhhhhh  ; get id routines
		move.l	(a2)+,Pointer2(a1)
		move.l	(a2)+,Pointer(a1) ; idk if this is the pointer i think it is
		move.l	(a2)+,SavedPointer(a1) ; same thing goes here if this is the waiting pointer that was saved
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,capsule_Child_dx(a1)			; See offset information above
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,capsule_Child_dy(a1)			; See offset information above
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		move.w	(a2)+,x_vel(a1)		; X Velocity
		move.w	(a2)+,y_vel(a1)		; Y Velocity
		addq.w	#2,d2
		dbf		d6,loc_840B4
		moveq	#0,d0

BranchCustomRoutine:
		rts
; End of function CreateChild2_Complex

SetUp_ObjAttributes:
		move.l	(a1)+,mappings(a0)		; Mappings location

SetUp_ObjAttributes2:
		move.w	(a1)+,art_tile(a0)		; VRAM offset

SetUp_ObjAttributes3:
		move.w	(a1)+,priority(a0)			; Priority
		move.b	(a1)+,width_pixels(a0)			; Width
		move.b	(a1)+,mapping_frame(a0)		; Mappings frame
		move.b	(a1)+,collision_flags(a0)		; Collision Number
		bset	#2,render_flags(a0)			; Object uses world coordinates
		addq.b	#2,routine(a0)			; Increase routine counter
		rts
		
ObjDat3_86E12:
		dc.l	Map_SnowTulipon
		dc.w	vramTuliponMHZ
		dc.w	$200
		dc.b	$C
		dc.b	0
		dc.b	$23
		even

ObjDat3_86E1E:
		dc.l	Map_Snowrex ; map
		dc.w	vramSnowrexMHZ ;  v ram
		dc.w	$280 ; prio
		dc.b	8   ;wdth
		dc.b	4   ; frame
		dc.b	$87 ;  ; collsion
		even

ChildObjDat_86E2A:
		dc.w	0	; load 1 ball
		dc.b	id_SnowTulipon ; get current obj id
		dc.b	$6  ; get balls routine
		dc.l	ObjDat3_86E1E ; kind of stupid
		dc.l	0
		dc.l	Snow_BallMove
		dc.b	0
		dc.b	$F0
		dc.w	$100    ; ig x and y vel
		dc.w	$FB00                     
byte_86E42:
		dc.b	0,	7 ; animating thing
		dc.b	1,	9
		dc.b	2,	4
		dc.b	3,	4
		dc.b	0,	9
		dc.b	1,	9
		dc.b	2,	4
		dc.b	3,	4
		dc.b	0,	0
		dc.b	$F4,0
		even

Snow_BallMove:	; FUCK
                moveq   #0,d6
 SkippedflagsetForBallMove:
		bsr.w	ObjectFall
		bsr.w	DisplaySprite
		move.w	(v_limitbtm2).w,d0  ; the value for the screen bottm boundry my gusse
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has object moved below the level boundary?
		bcs.s	@delete		; if yes, branch
		tst.w  d6    ; is this snow flake dust obj ?
		bne.s  @return   ; if yes then do not expload
		jsr		ObjFloorDist
		tst.w	d1
		bpl.w	@return
		add.w	d1,y_pos(a0)
		move.b	#$27,0(a0)
		move.b	#2,obRoutine(a0)
		bra.w	DisplaySprite

	@delete:
		bra.w	DeleteObject

	@return:
		rts