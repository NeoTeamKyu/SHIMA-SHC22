; ---------------------------------------------------------------------------
; Animation script - Amy
; ---------------------------------------------------------------------------
Ani_Amy:
		dc.w AmyAni_Walk-Ani_Amy
		dc.w AmyAni_Run-Ani_Amy
		dc.w AmyAni_Roll-Ani_Amy
		dc.w AmyAni_Roll2-Ani_Amy
		dc.w AmyAni_Push-Ani_Amy
		dc.w AmyAni_Wait-Ani_Amy
		dc.w AmyAni_Balance-Ani_Amy
		dc.w AmyAni_LookUp-Ani_Amy
		dc.w AmyAni_Duck-Ani_Amy
		dc.w AmyAni_Null-Ani_Amy
		dc.w AmyAni_Fall-Ani_Amy
		dc.w AmyAni_Null-Ani_Amy
		dc.w AmyAni_Null-Ani_Amy
		dc.w AmyAni_Stop-Ani_Amy
		dc.w AmyAni_Float1-Ani_Amy
		dc.w AmyAni_Float2-Ani_Amy
		dc.w AmyAni_Spring-Ani_Amy
		dc.w AmyAni_LZHang-Ani_Amy
		dc.w AmyAni_Leap1-Ani_Amy
		dc.w AmyAni_Leap2-Ani_Amy
		dc.w AmyAni_Surf-Ani_Amy
		dc.w AmyAni_Bubble-Ani_Amy
		dc.w AmyAni_Burnt-Ani_Amy
		dc.w AmyAni_Drown-Ani_Amy
		dc.w AmyAni_Death-Ani_Amy
		dc.w AmyAni_Shrink-Ani_Amy
		dc.w AmyAni_Hurt-Ani_Amy
		dc.w AmyAni_LZSlide-Ani_Amy
		dc.w AmyAni_Null-Ani_Amy
		dc.w AmyAni_Float3-Ani_Amy
		dc.w AmyAni_Float4-Ani_Amy
		dc.w AmyAni_Hammer2-Ani_Amy	;1F
		dc.w AmyAni_HammerSpin-Ani_Amy     ;20
		dc.w AmyAni_Null-Ani_Amy		;21
		dc.w AmyAni_HammerJump-Ani_Amy  	;22
		dc.w AmyAni_HighJump-Ani_Amy	;23
		dc.w AmyAni_Leap-Ani_Amy		;24
		dc.w AmyAni_Hammer1-Ani_Amy	;25
		dc.w AmyAni_SpinDash-Ani_Amy	;26
		dc.w AmyAni_Null-Ani_Amy		;27
		dc.w AmyAni_Pratfall1-Ani_Amy	;$28
		dc.w AmyAni_Pratfall2-Ani_Amy	;$29
		dc.w AmyAni_Pratfall3-Ani_Amy	;$2A
		dc.w AmyAni_Victory-Ani_Amy	;$2B
		dc.w AmyAni_Transform-Ani_Amy	;$2C

AmyAni_Walk:	dc.b $FF, frA_Walk13, frA_Walk14,	frA_Walk15, frA_Walk16,	frA_Walk11, frA_Walk12, afEnd
		even
AmyAni_Run:		dc.b $FF, frA_Run11, frA_Run12, frA_Run13, frA_Run14, afEnd, afEnd,	afEnd
		even
AmyAni_Roll:	dc.b $FE, frA_Roll1, frA_Roll2, frA_Roll3, frA_Roll4, frA_Roll5, afEnd,	afEnd
		even
AmyAni_Roll2:	dc.b $FE, frA_Roll1, frA_Roll2, frA_Roll5, frA_Roll3, frA_Roll4, frA_Roll5,	afEnd
		even
AmyAni_Push:	dc.b $FD, frA_Push1, frA_Push2, frA_Push3, frA_Push4, afEnd, afEnd,	afEnd
		even
AmyAni_Wait:	dc.b $17, frA_Stand, frA_Stand,	frA_Stand, frA_Stand, frA_Stand, frA_Stand, frA_Stand, frA_Stand, frA_Stand, frA_Stand,	frA_Stand, frA_Stand, frA_Wait2, frA_Wait1, frA_Wait2, frA_Wait3, afBack, 4, 0
		even
AmyAni_Balance:	dc.b 3, $3A, $3A, $3A, $3A, $58, $3B, $58, afEnd
		even
AmyAni_LookUp:	dc.b $3F, frA_LookUp, afEnd, 0
		even
AmyAni_Duck:	dc.b $3F, frA_Duck, afEnd, 0
		even
AmyAni_Stop:	dc.b 7,	$37, $38, afEnd
		even
AmyAni_Float1:	dc.b 7,	$3C, $3F, afEnd
		even
AmyAni_Float2:	dc.b 7,	$3C, $3D, $53, $3E, $54, afEnd, 0
		even
AmyAni_Spring:	dc.b $2F, $40, afEnd	; Doesn't matter. afBack, 0 is bad shit.
		even
AmyAni_LZHang:	dc.b 4,	$41, $42, afEnd
		even
AmyAni_Leap1:	dc.b $F, $43, $43, $43,	afBack, 1
		even
AmyAni_Leap2:	dc.b $F, $43, $44, afBack,	1, 0
		even
AmyAni_Surf:	dc.b $3F, $49, afEnd, 0
		even
AmyAni_Bubble:	dc.b $B, $56, $56, $A, $B, afChange,	0, 0
		even
AmyAni_Burnt:	dc.b $20, $4B, afEnd, 0
		even
AmyAni_Drown:	dc.b $2F, $4C, afEnd, 0
		even
AmyAni_Death:	dc.b $20,	$4D, afChange, id_WaterSlide
		even
AmyAni_Shrink:	dc.b 3,	$4E, $4F, $50, $51, $52, 0, afBack, 1, 0
		even
AmyAni_Hurt:	dc.b 3,	$55, afEnd, 0
		even
AmyAni_LZSlide:	dc.b 7, $55, $57, afEnd
		even
AmyAni_Null:	dc.b $77, frA_Null, afEnd
		even
AmyAni_Float3:	dc.b 3,	$3C, $3D, $53, $3E, $54, afEnd, 0
		even
AmyAni_Float4:	dc.b 3,	$3C, afEnd
		even
AmyAni_Hammer2:  dc.b 1, $60, $61, $62, $63, $64, $65, $66, $67, afChange, 0
		even
AmyAni_HammerSpin: dc.b 2, $68, $69, $6A, $6B, $6C, $6D, afEnd
		even
AmyAni_Fall:    dc.b 3, $6E, $6F, $70, afBack, 1
		even
AmyAni_HammerJump: dc.b 2, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, afChange, id_Fall
		even
AmyAni_HighJump: dc.b 1, $60, $60, $7C, $7D, $7E, $7F, $80, $81, $82, $83, afBack, 7, 0
		even
AmyAni_Leap: dc.b 1, $8A, afBack, 1
		even
AmyAni_Hammer1:  dc.b 1, $59, $5A, $5B, $5C, $5D, $5E, $5F, afChange, $1F
		even
AmyAni_SpinDash:	dc.b 0, $1E, $1F, $20, $21, afEnd, afEnd,	afEnd
		even
AmyAni_Pratfall1: dc.b 1, $86, afBack, 1
		even
AmyAni_Pratfall2: dc.b 1, $85, $86, afEnd	; This animation was unnecessarily long.
		even
AmyAni_Pratfall3: dc.b 3, $87, $88, $87, $88, $89, afChange, 5
		even
AmyAni_Victory: dc.b 5, $8B, $8C, $8D, $8E, afBack, 1
		even
AmyAni_Transform:	dc.b   2,$8F,$8F,$90,$90,$91,$92,$92,$92,$92,$92,$92,$92,$92,afChange,  0
		even

; Amy frame IDs
    rsreset
frA_Null:	rs.b 1
frA_Stand:	rs.b 1
frA_Wait1:	rs.b 1
frA_Wait2:	rs.b 1
frA_Wait3:	rs.b 1
frA_LookUp:	rs.b 1
frA_Walk11:	rs.b 1
frA_Walk12:	rs.b 1
frA_Walk13:	rs.b 1
frA_Walk14:	rs.b 1
frA_Walk15:	rs.b 1
frA_Walk16:	rs.b 1
frA_Walk21:	rs.b 1
frA_Walk22:	rs.b 1
frA_Walk23:	rs.b 1
frA_Walk24:	rs.b 1
frA_Walk25:	rs.b 1
frA_Walk26:	rs.b 1
frA_Walk31:	rs.b 1
frA_Walk32:	rs.b 1
frA_Walk33:	rs.b 1
frA_Walk34:	rs.b 1
frA_Walk35:	rs.b 1
frA_Walk36:	rs.b 1
frA_Walk41:	rs.b 1
frA_Walk42:	rs.b 1
frA_Walk43:	rs.b 1
frA_Walk44:	rs.b 1
frA_Walk45:	rs.b 1
frA_Walk46:	rs.b 1
frA_Run11:	rs.b 1
frA_Run12:	rs.b 1
frA_Run13:	rs.b 1
frA_Run14:	rs.b 1
frA_Run21:	rs.b 1
frA_Run22:	rs.b 1
frA_Run23:	rs.b 1
frA_Run24:	rs.b 1
frA_Run31:	rs.b 1
frA_Run32:	rs.b 1
frA_Run33:	rs.b 1
frA_Run34:	rs.b 1
frA_Run41:	rs.b 1
frA_Run42:	rs.b 1
frA_Run43:	rs.b 1
frA_Run44:	rs.b 1
frA_Roll1:	rs.b 1
frA_Roll2:	rs.b 1
frA_Roll3:	rs.b 1
frA_Roll4:	rs.b 1
frA_Roll5:	rs.b 1

frA_Warp1:	rs.b 1
frA_Warp2:	rs.b 1
frA_Warp3:	rs.b 1
frA_Warp4:	rs.b 1

frA_Stop1:	rs.b 1
frA_Stop2:	rs.b 1
frA_Duck:	rs.b 1
frA_Balance1:	rs.b 1
frA_Balance2:	rs.b 1
frA_Float1:	rs.b 1
frA_Float2:	rs.b 1
frA_Float3:	rs.b 1
frA_Float4:	rs.b 1
frA_Spring:	rs.b 1
frA_Hang1:	rs.b 1
frA_Hang2:	rs.b 1

frA_Leap1:	rs.b 1
frA_Leap2:	rs.b 1

frA_Push1:	rs.b 1
frA_Push2:	rs.b 1
frA_Push3:	rs.b 1
frA_Push4:	rs.b 1

frA_Surf:	rs.b 1
frA_StandAir:	rs.b 1

frA_Burnt:	rs.b 1
frA_Drown:	rs.b 1
frA_Death:	rs.b 1

frA_Shrink1:	rs.b 1
frA_Shrink2:	rs.b 1
frA_Shrink3:	rs.b 1
frA_Shrink4:	rs.b 1
frA_Shrink5:	rs.b 1

frA_Float5:	rs.b 1
frA_Float6:	rs.b 1
frA_Injury:	rs.b 1
frA_GetAir:	rs.b 1
frA_WaterSlide:	rs.b 1
frA_Balance3:	rs.b 1
frA_HammerG1:	rs.b 1
frA_HammerG2:	rs.b 1
frA_HammerG3:	rs.b 1
frA_HammerG4:	rs.b 1
frA_HammerG5:	rs.b 1
frA_HammerG6:	rs.b 1
frA_HammerG7:	rs.b 1
frA_HammerG8:	rs.b 1
frA_HammerG9:	rs.b 1
frA_HammerGA:	rs.b 1
frA_HammerGB:	rs.b 1
frA_HammerGC:	rs.b 1
frA_HammerGD:	rs.b 1
frA_HammerGE:	rs.b 1
frA_HammerGF:	rs.b 1
frA_HammerSpin1:	rs.b 1
frA_HammerSpin2:	rs.b 1
frA_HammerSpin3:	rs.b 1
frA_HammerSpin4:	rs.b 1
frA_HammerSpin5:	rs.b 1
frA_HammerSpin6:	rs.b 1
frA_FallS1:	rs.b 1
frA_FallS2:	rs.b 1
frA_Fall:	rs.b 1
frA_HammerA1:	rs.b 1
frA_HammerA2:	rs.b 1
frA_HammerA3:	rs.b 1
frA_HammerA4:	rs.b 1
frA_HammerA5:	rs.b 1
frA_HammerA6:	rs.b 1
frA_HammerA7:	rs.b 1
frA_HammerA8:	rs.b 1
frA_HammerA9:	rs.b 1
frA_HammerAA:	rs.b 1
frA_HammerAB:	rs.b 1
frA_HighJump1:	rs.b 1
frA_HighJump2:	rs.b 1
frA_HighJump3:	rs.b 1
frA_HighJump4:	rs.b 1
frA_HighJump5:	rs.b 1
frA_HighJump6:	rs.b 1
frA_HighJump7:	rs.b 1
frA_HighJump8:	rs.b 1
frA_HighJump9:	rs.b 1
frA_Faceplant1:	rs.b 1
frA_Faceplant2:	rs.b 1
frA_GetUp1:	rs.b 1
frA_GetUp2:	rs.b 1
frA_GetUp3:	rs.b 1
frA_Lunge:	rs.b 1
frA_Victory1:	rs.b 1
frA_Victory2:	rs.b 1
frA_Victory3:	rs.b 1
frA_Victory4:	rs.b 1
frA_Transform1:	rs.b 1
frA_Transform2:	rs.b 1
frA_Transform3:	rs.b 1
frA_Transform4:	rs.b 1