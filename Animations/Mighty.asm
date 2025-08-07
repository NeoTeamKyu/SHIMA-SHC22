; ---------------------------------------------------------------------------
; Animation script - Mighty
; ---------------------------------------------------------------------------
Ani_Mighty:
	dc.w MtyAni_Walk-Ani_Mighty	; 0
	dc.w MtyAni_Run-Ani_Mighty	; 1
	dc.w MtyAni_Roll-Ani_Mighty	; 2
	dc.w MtyAni_Roll2-Ani_Mighty	; 3
	dc.w MtyAni_Push-Ani_Mighty	;4
	dc.w MtyAni_Wait-Ani_Mighty	; 5
	dc.w MtyAni_Balance-Ani_Mighty	; 6
	dc.w MtyAni_LookUp-Ani_Mighty	; 7
	dc.w MtyAni_Duck-Ani_Mighty	; 8
	dc.w MtyAni_Spindash-Ani_Mighty	; 9
	dc.w MtyAni_Fall-Ani_Mighty	; $A
	dc.w MtyAni_Balance2-Ani_Mighty	; $B
	dc.w MtyAni_WallJump-Ani_Mighty	; $C
	dc.w MtyAni_Stop-Ani_Mighty	; $D
	dc.w MtyAni_Float1-Ani_Mighty	; $E
	dc.w MtyAni_Float2-Ani_Mighty	; $F
	dc.w MtyAni_Spring-Ani_Mighty	; $10
	dc.w MtyAni_Hang-Ani_Mighty	; $11
	dc.w MtyAni_Uncurl-Ani_Mighty	; $12
	dc.w MtyAni_Null-Ani_Mighty	; $13
	dc.w MtyAni_Null-Ani_Mighty	; $14
	dc.w MtyAni_GetAir-Ani_Mighty	; $15
	dc.w MtyAni_Burnt-Ani_Mighty	; $16
	dc.w MtyAni_Drown-Ani_Mighty	; $17
	dc.w MtyAni_Death-Ani_Mighty	; $18
	dc.w MtyAni_Null-Ani_Mighty	; $19
	dc.w MtyAni_Hurt-Ani_Mighty	; $1A
	dc.w MtyAni_WaterSlide-Ani_Mighty	; $1B
	dc.w MtyAni_Null-Ani_Mighty	; $1C
	dc.w MtyAni_Float3-Ani_Mighty	; $1D
	dc.w MtyAni_Float4-Ani_Mighty	; $1E
	dc.w MtyAni_Null-Ani_Mighty	; $1F
	dc.w MtyAni_Null-Ani_Mighty	; $20
	dc.w MtyAni_Null-Ani_Mighty	; $21
	dc.w MtyAni_HammerDrop-Ani_Mighty	; $22
	dc.w MtyAni_Null-Ani_Mighty	; $23
	dc.w MtyAni_MachSpeed-Ani_Mighty ; $24
	dc.w MtyAni_Victory-Ani_Mighty ; $25
	dc.w MtyAni_Transform-Ani_Mighty

MtyAni_Walk:	dc.b $FF, $D, $E,	$F, $10, $B, $C, afEnd
		even
MtyAni_Run:		dc.b $FF,  $23,  $24,  $25,  $26,     afEnd,     afEnd, afEnd
		even
MtyAni_Roll:	dc.b $FE,  $33,  $34,  $35,  $36,  $37,  afEnd, afEnd
		even
MtyAni_Roll2:	dc.b $FE,  $33,  $34,  $37,  $35,  $36,    $37, afEnd
		even
MtyAni_Push:	dc.b $FD,  $55,  $56,  $57,  $58,     afEnd,     afEnd, afEnd
		even
MtyAni_Wait:	dc.b $B, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
				dc.b  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
				dc.b  1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 4, 5, 5
				dc.b  5, 5, 5, 5, 6, 6, 5, 5, 5, 5, 6, 6, 5, 5, 5, 5, 6, 6
				dc.b  5, 5, 5, 5, 6, 6, 4, 7, 8, 8, 4, afEnd
		even
MtyAni_Balance:	dc.b 5, $40, $41, $42, $43, $44, $45, afEnd
		even
MtyAni_LookUp:	dc.b 5, 9, $A, afBack, 1
		even
MtyAni_Duck:	dc.b 5, $3E, $3F, afBack, 1
		even
MtyAni_Spindash:	dc.b 0, $61, $62, $61, $63, $61, $64, $61, $65, $61, $66, afEnd
		even
MtyAni_Fall:	dc.b 3,	$81, $82, $83, afBack, 2
		even
MtyAni_Balance2:dc.b 5, $46, $47, $48, $49, $4A, $4B, $4C, afEnd
		even
MtyAni_WallJump:dc.b 3, $84, afEnd
		even
MtyAni_Stop:	dc.b 3,	$38, $39, $3A, $3B, $3C, $3D, afBack, 1
		even
MtyAni_Float1:	dc.b 7,	$4D, $50, afEnd
		even
MtyAni_Float2:	dc.b 7,	$4D, $4E, $5C, $4F, $5D, afEnd
		even
MtyAni_Spring:	dc.b 2, $51, $52, afEnd
		even
MtyAni_Hang:	dc.b 4,	$53, $54, afEnd
		even
MtyAni_Uncurl:	dc.b 3, $7F, $80, afChange, id_Fall
		even
MtyAni_GetAir:	dc.b $B, $60, $60, $F, $10, afChange, id_Walk
		even
MtyAni_Burnt:	dc.b $20, $59, afEnd
		even
MtyAni_Drown:	dc.b $2F, $5A, afEnd
		even
MtyAni_Death:	dc.b $20,	$5B, $FD, $1B
		even
MtyAni_Hurt:	dc.b 3,	$5E, afEnd
		even
MtyAni_WaterSlide:	dc.b 7, $5E, $5F, afEnd
		even
MtyAni_Null:	dc.b $77, 0, afEnd
		even
MtyAni_Float3:	dc.b 3,	$4D, $4E, $5C, $4F, $5D, afEnd
		even
MtyAni_Float4:	dc.b 3,	$4D, afChange, id_Walk
		even
MtyAni_HammerDrop:	dc.b 0, $37, $77, $78, $79, $7A, $7B, $7C, $7D, $7E, afBack, 4
		even
MtyAni_MachSpeed:	dc.b $FF,  $67,  $68,  $69,  $6A,     afEnd,     afEnd, afEnd
		even
MtyAni_Victory:	dc.b 5, $85, $86, $87, $88, $89, $89, $8A, $8B, $8C, $8D, $8E, $8F, afBack, 2
		even
MtyAni_Transform:	dc.b 2, $9E, $9E, $9F, $9F, $A0, $A1, $A2, $A1, $A2, $A1, $A2, $A1, $A2, afChange,  id_Walk
		even