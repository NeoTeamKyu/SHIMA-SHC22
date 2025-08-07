Obj_Wait:
        subq.w    #1,WaitObjectVar(a0)
        bmi.s    loc_84892
        rts
; ---------------------------------------------------------------------------

loc_84892:
        movea.l    objoff_34(a0),a1
        jmp    (a1)
; End of function Obj_Wait
Find_SonicTails:
		moveq	#0,d0			; d0 = 0 if Sonic/Tails is left of object, 2 if right of object
		moveq	#0,d1			; d1 = 0 if Sonic/Tails is above object, 2 if below object
		lea	(v_player).w,a1
		move.w	x_pos(a0),d2
		sub.w	x_pos(a1),d2
		bpl.s	loc_84B40
		neg.w	d2
		addq.w	#2,d0

loc_84B40:
		cmp.w	d3,d2
		bls.s	loc_84B4A
		movea.l	a2,a1
		move.w	d1,d0
		move.w	d3,d2

loc_84B4A:
		moveq	#0,d1
		move.w	y_pos(a0),d3
		sub.w	y_pos(a1),d3
		bpl.s	locret_84B5A
		neg.w	d3
		addq.w	#2,d1

locret_84B5A:
		rts
; End of function Find_SonicTails
DisplaySpriteEfficient:

        cmpi.b    #$7E,(a1)    ; is this part of the queue full?
        bcc.s    DrawSubsprite    ; if yes, branch
        addq.w    #2,(a1)        ; increment sprite count
        adda.w    (a1),a1        ; jump to empty position
        move.w    a0,(a1)        ; insert RAM address for object

DrawSubsprite:   rts
                ; unused code 
		cmpa.w	#v_spritequeue+($80*7),a1
		beq.s	locret_84B5A
		lea	$80(a1),a1
		bra.s	DisplaySpriteEfficient

; End of function DisplaySprite
Obj_Wait4:
        subq.w    #1,WaitObjectVar(a0)
        bmi.s    @BranchToAddrAfterDonewithCountdown
        rts
; ---------------------------------------------------------------------------

 @BranchToAddrAfterDonewithCountdown:
        movea.l    d0,a1
        jmp    (a1)
; End of function Obj_Wait
MoveObjectnosst:
               ext.l   d0
               lsl.l   #$8,d0
               add.l   d0,0(a1) ; ob X , objY ,OBcustom
               rts
ObjGetplayerPixelDistance:
           	moveq	#0,d0
		moveq	#0,d1
		lea	(v_player).w,a1
		move.w	x_pos(a0),d2
		sub.w	x_pos(a1),d2
		bpl.s	@return
		neg.w	d2
		addq.w	#2,d0
@return:
		rts
RememberState_2:
		out_of_range	@offscreen
		moveq  #0,d6
		rts

	@offscreen:
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.w	DeletSetFlags	; if it's zero, don't remember object
		movea.w	d0,a2	; load address into a2
		bclr	#7,(a2)	; clear respawn table entry, so object can be loaded again
		bra.w	DeletSetFlags
 DeletSetFlags:
                moveq  #1,d6
		jmp DeleteObject