; Output:
; d0: distance
; a1: object
FindClosestTargetInFront:
        lea	(v_objspace).w,a2 ; a2=object
        moveq	#(v_objspace_end-v_objspace)/object_size-1,d6 ; run the first $80 objects out of levels
        move.l	#$FFFFFFFF,d5 ; d5 = smallest distance
        move.l	#0,a1 ; a1 = closest obj

FindClosestTargetInFront_Loop:
        bsr.s	FindClosestTargetInFront_Iterate
        lea	next_object(a2),a2 ; load obj address
        dbf	d6,FindClosestTargetInFront_Loop
        moveq	#0,d0
        move.l	d5,d0
        rts

FindClosestTargetInFront_Iterate:
        tst.l	id(a2)	; get the object's ID
        beq.s	@skip	; if it's obj00, skip it

        move.b	collision_flags(a2),d1
        beq.s	@skip
        andi.b	#$C0,d1			; is touch response $40 or higher?
        beq.w	FindClosestTargetInFront_FoundNew		; if yes, branch

        cmpi.b	#$C0,d1			; is touch response $C0 or higher?
        beq.w	@skip		; if yes, branch
        tst.b	d1			; is touch response $80-$BF ?
        bmi.w	@skip		; if yes, branch

        move.b	collision_flags(a2),d1
        andi.b	#$3F,d1
        cmpi.b	#6,d1			; is touch response $46 ?
        beq.s	FindClosestTargetInFront_FoundNew		; if yes, branch
    @skip:
        rts

FindClosestTargetInFront_FoundNew:
        moveq	#0,d1
        move.w	x_pos(a2),d1

        btst	#0,status(a0)		; is Sonic facing left?
        beq.s	.facingright				; if not, branch
        cmp.w	x_pos(a0),d1	; is obj in front of Sonic?
        blt.s	.cont			; if so, continue
        rts

  .facingright:
        cmp.w	x_pos(a0),d1	; is obj in front of Sonic?
        bge.s	.cont			; if so, continue
        rts

  .cont:
        ; Pythagorean theorem to get distance
        ; a
        sub.w	x_pos(a0),d1

        ; b
        moveq	#0,d2
        move.w	y_pos(a2),d2
        sub.w	y_pos(a0),d2

        jsr		CalcAngle

        ; Angle limits (right)
        cmpi.b	#224,d0
        bge.s	@next
        cmpi.b	#32,d0
        ble.s	@next

        ; Angle limits (left)
        cmpi.b	#96,d0
        blt.s	@return
        cmpi.b	#160,d0
        bgt.s	@return
    @next:

        ; a and b squared...
        muls.w	d1,d1
        muls.w	d2,d2

        ; add em up...
        add.l	d2,d1

        ; and we're gonna skip square rooting em cause we don't need to!

        ; is the distance less than prev?
        cmp.l	d1,d5
        bge.s	@return	; leave if not

        cmpi.l	#180*180,d1 ; is dist greater than cap?
        bge.s	@return	; leave if is

        ; store current obj and distance
        move.l	a2,a1
        move.l	d1,d5
    @return:
        rts