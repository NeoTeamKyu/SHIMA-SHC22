; ---------------------------------------------------------------------------
; Animation script - Metal
; ---------------------------------------------------------------------------
Ani_Metal:
	dc.w MetAni_Walk-Ani_Metal
	dc.w MetAni_Run-Ani_Metal
	dc.w MetAni_Roll-Ani_Metal
	dc.w MetAni_Roll2-Ani_Metal
	dc.w MetAni_Push-Ani_Metal
	dc.w MetAni_Wait-Ani_Metal
	dc.w MetAni_Balance-Ani_Metal
	dc.w MetAni_LookUp-Ani_Metal
	dc.w MetAni_Duck-Ani_Metal
	dc.w MetAni_Spindash-Ani_Metal
	dc.w MetAni_Fall-Ani_Metal
	dc.w MetAni_Balance2-Ani_Metal
	dc.w MetAni_Charge-Ani_Metal
	dc.w MetAni_Stop-Ani_Metal
	dc.w MetAni_Float1-Ani_Metal
	dc.w MetAni_Float2-Ani_Metal
	dc.w MetAni_Spring-Ani_Metal
	dc.w MetAni_Hang-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_GetAir-Ani_Metal
	dc.w MetAni_Burnt-Ani_Metal
	dc.w MetAni_Drown-Ani_Metal
	dc.w MetAni_Death-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Hurt-Ani_Metal
	dc.w MetAni_WaterSlide-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Float3-Ani_Metal
	dc.w MetAni_Float4-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_Null-Ani_Metal
	dc.w MetAni_MachSpeed-Ani_Metal
	dc.w MetAni_Victory-Ani_Metal
	dc.w MetAni_Transform-Ani_Metal

MetAni_Walk:		dc.b $FF,	frM_Walk13,	frM_Walk14,	frM_Walk15,	frM_Walk16,	frM_Walk17,	frM_Walk18,	frM_Walk11,	frM_Walk12,	afEnd
		even
MetAni_Run:			dc.b $FF,	frM_Run11,	frM_Run12,	frM_Run11,	frM_Run13,	frM_Run11,	frM_Run14,		afEnd,		afEnd,	afEnd
		even
MetAni_Roll:		dc.b $FE,	frM_Roll1,	frM_Roll2,	frM_Roll3,	frM_Roll4,	frM_Roll5,		afEnd,		afEnd,		afEnd,	afEnd
		even
MetAni_Roll2:		dc.b $FE,	frM_Roll1,	frM_Roll2,	frM_Roll5,	frM_Roll3,	frM_Roll4,	frM_Roll5,		afEnd,		afEnd,	afEnd
		even
MetAni_Push:		dc.b $FD,	frM_Push1,	frM_Push2,	frM_Push3,	frM_Push4,		afEnd,		afEnd,		afEnd,		afEnd,	afEnd
		even
MetAni_MachSpeed:	dc.b $FF,	frM_Mach11,	frM_Mach12,	frM_Mach11,	frM_Mach13,	frM_Mach11,	frM_Mach14,		afEnd,		afEnd,	afEnd
		even
MetAni_Wait:		dc.b $17,	frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Wait1, frM_Wait2, frM_Wait2, frM_Wait2
					dc.b		frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait3, frM_Wait2, frM_Wait2, frM_Wait2, frM_Wait2, frM_Wait1
					dc.b		frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Stand, frM_Wait1, frM_Wait4, frM_Wait4, frM_Wait4
					dc.b		frM_Wait5, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait7, frM_Wait6, frM_Wait5, frM_Wait4, frM_Wait4, frM_Wait4, frM_Wait4, frM_Wait1
					dc.b afEnd
		even
MetAni_Balance:		dc.b $F, frM_BalanceA1, frM_BalanceA2, frM_BalanceA3, frM_BalanceA4, afEnd
		even
MetAni_LookUp:		dc.b 5, frM_Look1, frM_Look2, afBack, 1
		even
MetAni_Duck:		dc.b 5, frM_Duck1, frM_Duck2, afBack, 1
		even
MetAni_Spindash:	dc.b 0, frM_SpDsh1, frM_SpDsh2, frM_SpDsh1, frM_SpDsh3, frM_SpDsh1, frM_SpDsh4, frM_SpDsh1, frM_SpDsh5, frM_SpDsh1, frM_SpDsh6, afEnd
		even
MetAni_Fall:		dc.b 3,	frM_Fall, afEnd
		even
MetAni_Balance2:	dc.b $F, frM_BalanceB1, frM_BalanceB2, frM_BalanceB3, frM_BalanceB4, afEnd
		even
MetAni_Charge:		dc.b 0, frM_Charge1, frM_Charge1, frM_Charge1, frM_Charge1, frM_Charge1, frM_Charge1, frM_Charge1, frM_Charge1
					dc.b	frM_Charge2, frM_Charge1, frM_Charge2, frM_Charge1, frM_Charge2, frM_Charge1, frM_Charge2, frM_Charge1
					dc.b	frM_Charge2, frM_Charge3, frM_Charge2, frM_Charge3, frM_Charge2, frM_Charge3, frM_Charge2, frM_Charge3
					dc.b	frM_Charge4, frM_Charge3, afBack, 2
		even
MetAni_Stop:		dc.b 7,	frM_Stop, afEnd
		even
MetAni_Float1:		dc.b 7,	frM_Float1, frM_FloatB, afEnd
		even
MetAni_Float2:		dc.b 7,	frM_Float1, frM_Float2, frM_Float3, frM_Float4, frM_Float5, frM_Float6, afEnd
		even
MetAni_Spring:		dc.b 3, frM_Spring, afEnd
		even
MetAni_Hang:		dc.b 4,	frM_Hang1, frM_Hang2, afEnd
		even
MetAni_GetAir:		dc.b $B, frM_GetAir, frM_GetAir, frM_Walk15, frM_Walk16, afChange, id_Walk
		even
MetAni_Burnt:		dc.b $20, frM_Burnt, afEnd
		even
MetAni_Drown:		dc.b $B,	frM_DeathEyes,	frM_Death1,	afEnd
		even
MetAni_Death:		dc.b $20,	frM_Death1,		frM_Death2,	afBack, 1
		even
MetAni_Hurt:		dc.b 3,	frM_Injury, afEnd
		even
MetAni_WaterSlide:	dc.b 3, frM_WaterSlide, afEnd
		even
MetAni_Null:		dc.b $77, frM_Null, afEnd
		even
MetAni_Float3:		dc.b 3,	frM_Float1, frM_Float2, frM_Float3, frM_Float4, frM_Float5, frM_Float6, afEnd
		even
MetAni_Float4:		dc.b 3,	frM_Float1, afChange, id_Walk
		even
MetAni_Victory:		dc.b $B, frM_Wait1, frM_Wait1, frM_Wait1, frM_Wait1, frM_Victory1, frM_Victory2, frM_Victory3, frM_Victory2, afBack, 4
		even
MetAni_Transform:	dc.b 2, frM_Tran1, frM_Tran1, frM_Tran2, frM_Tran2, frM_Tran3, frM_Tran4, frM_Tran4, frM_Tran4, frM_Tran4, frM_Tran4, frM_Tran4, frM_Tran4, frM_Tran4, afChange,  id_Walk
		even

; Metal Sonic frame IDs
	rsreset
frM_Null:	rs.b 1

frM_Stand:	rs.b 1
frM_Wait1:	rs.b 1
frM_Wait2:	rs.b 1
frM_Wait3:	rs.b 1
frM_Wait4:	rs.b 1
frM_Wait5:	rs.b 1
frM_Wait6:	rs.b 1
frM_Wait7:	rs.b 1

frM_Look1:	rs.b 1
frM_Look2:	rs.b 1

frM_Duck1:	rs.b 1
frM_Duck2:	rs.b 1

frM_Walk11:	rs.b 1
frM_Walk12:	rs.b 1
frM_Walk13:	rs.b 1
frM_Walk14:	rs.b 1
frM_Walk15:	rs.b 1
frM_Walk16:	rs.b 1
frM_Walk17:	rs.b 1
frM_Walk18:	rs.b 1
; Don't care.
frM_Walk2X:	rs.b 8
frM_Walk3X:	rs.b 8
frM_Walk4X:	rs.b 8
; Medium speed.
frM_Run11:	rs.b 1
frM_Run12:	rs.b 1
frM_Run13:	rs.b 1
frM_Run14:	rs.b 1
; Don't care.
frM_Run2X:	rs.b 4
frM_Run3X:	rs.b 4
frM_Run4X:	rs.b 4
; Speen.
frM_Roll1:	rs.b 1
frM_Roll2:	rs.b 1
frM_Roll3:	rs.b 1
frM_Roll4:	rs.b 1
frM_Roll5:	rs.b 1
; Charging peelout.
frM_Charge1:	rs.b 1
frM_Charge2:	rs.b 1
frM_Charge3:	rs.b 1
frM_Charge4:	rs.b 1
; Skidding.
frM_Stop:	rs.b 1
; Balancing.
frM_BalanceA1:	rs.b 1
frM_BalanceA2:	rs.b 1
frM_BalanceA3:	rs.b 1
frM_BalanceA4:	rs.b 1
frM_BalanceB1:	rs.b 1
frM_BalanceB2:	rs.b 1
frM_BalanceB3:	rs.b 1
frM_BalanceB4:	rs.b 1

frM_Float1:	rs.b 1
frM_Float2:	rs.b 1
frM_Float3:	rs.b 1
frM_Float4:	rs.b 1
frM_Float5:	rs.b 1
frM_Float6:	rs.b 1
frM_FloatB:	rs.b 1

frM_Spring:	rs.b 1
frM_Fall:	rs.b 1

frM_Hang1:	rs.b 1
frM_Hang2:	rs.b 1

frM_Push1:	rs.b 1
frM_Push2:	rs.b 1
frM_Push3:	rs.b 1
frM_Push4:	rs.b 1
; Dumb ways to die.
frM_Burnt:	rs.b 1	; Unused, still Sonic. Most likely will never be used.
frM_DeathEyes:	rs.b 1
frM_Death1:	rs.b 1
frM_Death2:	rs.b 1
; Ouch.
frM_Injury:	rs.b 1
; Water.
frM_WaterSlide:	rs.b 1
frM_GetAir:	rs.b 1
; Speen 2, baybee. Unused.
frM_SpDsh1:	rs.b 1
frM_SpDsh2:	rs.b 1
frM_SpDsh3:	rs.b 1
frM_SpDsh4:	rs.b 1
frM_SpDsh5:	rs.b 1
frM_SpDsh6:	rs.b 1
; Fest as fucc.
frM_Mach11:	rs.b 1
frM_Mach12:	rs.b 1
frM_Mach13:	rs.b 1
frM_Mach14:	rs.b 1
; Don't care.
frM_Mach2X:	rs.b 4
frM_Mach3X:	rs.b 4
frM_Mach4X:	rs.b 4

frM_Victory1:rs.b 1
frM_Victory2:rs.b 1
frM_Victory3:rs.b 1

frM_Corkscrew1:	rs.b 1
frM_CorkShit: rs.b 11

frM_Zipline: rs.b 1

frM_Tran1:	rs.b 1
frM_Tran2:	rs.b 1
frM_Tran3:	rs.b 1
frM_Tran4:	rs.b 1