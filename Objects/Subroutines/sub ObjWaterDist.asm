; ---------------------------------------------------------------------------
; Subroutine to find the distance of an object to the floor
;
; output:
;	d1 = distance to the surface
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

ObjWaterDist:
		move.w	obY(a0),d1
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d1   ; y-position of object's bottom
        move.w  (v_waterpos1).w,d3
        sub.w  d3,d1
    ; d1 should now equal the distance.
		rts

; End of function ObjWaterDist