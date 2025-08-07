; ---------------------------------------------------------------------------
; Animation script - Kyuko
; ---------------------------------------------------------------------------
Ani_Kyuko:
		dc.w KyuAni_Walk-Ani_Kyuko
		dc.w KyuAni_Run-Ani_Kyuko
		dc.w KyuAni_Roll-Ani_Kyuko
		dc.w KyuAni_Roll2-Ani_Kyuko
		dc.w KyuAni_Push-Ani_Kyuko
		dc.w KyuAni_Idle-Ani_Kyuko
		dc.w KyuAni_Balance-Ani_Kyuko
		dc.w KyuAni_LookUp-Ani_Kyuko
		dc.w KyuAni_Duck-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Fall-Ani_Kyuko
		dc.w KyuAni_Balance2-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Stop-Ani_Kyuko
		dc.w KyuAni_Float1-Ani_Kyuko
		dc.w KyuAni_Float2-Ani_Kyuko
		dc.w KyuAni_Spring-Ani_Kyuko
		dc.w KyuAni_Hang-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_GetAir-Ani_Kyuko
		dc.w KyuAni_Burnt-Ani_Kyuko
		dc.w KyuAni_Drown-Ani_Kyuko
		dc.w KyuAni_Death-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Hurt-Ani_Kyuko
		dc.w KyuAni_WaterSlide-Ani_Kyuko
		dc.w KyuAni_Null-Ani_Kyuko
		dc.w KyuAni_Float3-Ani_Kyuko
		dc.w KyuAni_Float4-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko
		dc.w KyuAni_MachSpeed-Ani_Kyuko
		dc.w KyuAni_Victory-Ani_Kyuko
		dc.w KyuAni_Debut-Ani_Kyuko

KyuAni_Walk:	dc.b $FF, frKyu_Walk13, frKyu_Walk14,	frKyu_Walk15, frKyu_Walk16, frKyu_Walk17, frKyu_Walk18, frKyu_Walk11, frKyu_Walk12, afEnd
		even
KyuAni_Run:		dc.b $FF,  frKyu_Run11,  frKyu_Run12,  frKyu_Run13,  frKyu_Run14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
KyuAni_Roll:	dc.b $FE,  frKyu_Roll1,  frKyu_Roll2,  frKyu_Roll3,  frKyu_Roll4,  frKyu_Roll5,     afEnd, afEnd
		even
KyuAni_Roll2:	dc.b $FE,  frKyu_Roll1,  frKyu_Roll2,  frKyu_Roll5,  frKyu_Roll3,  frKyu_Roll4,  frKyu_Roll5, afEnd
		even
KyuAni_Push:	dc.b $FD,  frKyu_push1,  frKyu_push2,  frKyu_push3,  frKyu_push4,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
KyuAni_Idle:	dc.b 5, frKyu_Idle1, frKyu_Idle2, frKyu_Idle3, frKyu_Idle4, frKyu_Idle5, frKyu_Idle6, frKyu_Idle7, frKyu_Idle8, afEnd
		even
KyuAni_Balance:	dc.b 7, frKyu_BalanceA1, frKyu_BalanceA2, frKyu_BalanceA3, afEnd
		even
KyuAni_LookUp:	dc.b 5, frKyu_Look1, frKyu_Look2, afBack, 1
		even
KyuAni_Duck:	dc.b 5, frKyu_Duck1, frKyu_Duck2, afBack, 1
		even
KyuAni_Fall:	dc.b 3,	frKyu_Fall1, frKyu_Fall2, afBack, 1
		even
KyuAni_Balance2:dc.b 8, frKyu_BalanceB1, frKyu_BalanceB2, frKyu_BalanceB3, frKyu_BalanceB2, afEnd
		even
KyuAni_Stop:	dc.b 7,	frKyu_Stop1, frKyu_Stop2, frKyu_Stop3, frKyu_StopTurn, afBack, 1
		even
KyuAni_Float1:	dc.b 7,	frKyu_Float1, frKyu_FloatAlt, afEnd
		even
KyuAni_Float2:	dc.b 3,	frKyu_Float1, frKyu_Float2, frKyu_Float3, frKyu_Float4, frKyu_Float5, frKyu_Float6, frKyu_Float7, frKyu_Float8, frKyu_Float9, frKyu_FloatA, afEnd
		even
KyuAni_Spring:	dc.b $2F, frKyu_Spring, afEnd
		even
KyuAni_Hang:	dc.b 4,	frKyu_Hang1, frKyu_Hang2, afEnd
		even
KyuAni_GetAir:	dc.b $B, frKyu_GetAir, frKyu_GetAir, frKyu_Walk15, frKyu_Walk16, afChange, id_Walk
		even
KyuAni_Burnt:	dc.b $20, frKyu_Burnt, afEnd
		even
KyuAni_Drown:	dc.b $2F, frKyu_Drown, afEnd
		even
KyuAni_Death:	dc.b $20,	frKyu_Death, afChange, id_WaterSlide
		even
KyuAni_Hurt:	dc.b 3,	frKyu_Injury, afEnd
		even
KyuAni_WaterSlide:
				dc.b 7, frKyu_Injury, frKyu_WaterSlide, afEnd
		even
KyuAni_Null:	dc.b $77, frKyu_Null, afEnd
		even
KyuAni_Float3:	dc.b 1,	frKyu_Float1, frKyu_Float2, frKyu_Float3, frKyu_Float4, frKyu_Float5, frKyu_Float6, frKyu_Float7, frKyu_Float8, frKyu_Float9, frKyu_FloatA, afEnd
		even
KyuAni_Float4:	dc.b 3,	frKyu_Float1, afChange, id_Walk
		even
KyuAni_Debut:	dc.b $77, frKyu_Debut, afEnd
		even
KyuAni_MachSpeed:
				dc.b $FF,  frKyu_Mach11,  frKyu_Mach12,  frKyu_Mach13,  frKyu_Mach14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
KyuAni_Victory:	dc.b $7, frKyu_Victory1, frKyu_Victory2, afBack, 1
		even

; Kyuko frame IDs
    rsreset
frKyu_Null:	rs.b 1
frKyu_Idle1:	rs.b 1
frKyu_Idle2:	rs.b 1
frKyu_Idle3:	rs.b 1
frKyu_Idle4:	rs.b 1
frKyu_Idle5:	rs.b 1
frKyu_Idle6:	rs.b 1
frKyu_Idle7:	rs.b 1
frKyu_Idle8:	rs.b 1
frKyu_Look1:	rs.b 1
frKyu_Look2:	rs.b 1
frKyu_Walk11:	rs.b 1
frKyu_Walk12:	rs.b 1
frKyu_Walk13:	rs.b 1
frKyu_Walk14:	rs.b 1
frKyu_Walk15:	rs.b 1
frKyu_Walk16:	rs.b 1
frKyu_Walk17:	rs.b 1
frKyu_Walk18:	rs.b 1
frKyu_Walk21:	rs.b 1
frKyu_Walk22:	rs.b 1
frKyu_Walk23:	rs.b 1
frKyu_Walk24:	rs.b 1
frKyu_Walk25:	rs.b 1
frKyu_Walk26:	rs.b 1
frKyu_Walk27:	rs.b 1
frKyu_Walk28:	rs.b 1
frKyu_Walk31:	rs.b 1
frKyu_Walk32:	rs.b 1
frKyu_Walk33:	rs.b 1
frKyu_Walk34:	rs.b 1
frKyu_Walk35:	rs.b 1
frKyu_Walk36:	rs.b 1
frKyu_Walk37:	rs.b 1
frKyu_Walk38:	rs.b 1
frKyu_Walk41:	rs.b 1
frKyu_Walk42:	rs.b 1
frKyu_Walk43:	rs.b 1
frKyu_Walk44:	rs.b 1
frKyu_Walk45:	rs.b 1
frKyu_Walk46:	rs.b 1
frKyu_Walk47:	rs.b 1
frKyu_Walk48:	rs.b 1
frKyu_Run11:	rs.b 1
frKyu_Run12:	rs.b 1
frKyu_Run13:	rs.b 1
frKyu_Run14:	rs.b 1
frKyu_Run21:	rs.b 1
frKyu_Run22:	rs.b 1
frKyu_Run23:	rs.b 1
frKyu_Run24:	rs.b 1
frKyu_Run31:	rs.b 1
frKyu_Run32:	rs.b 1
frKyu_Run33:	rs.b 1
frKyu_Run34:	rs.b 1
frKyu_Run41:	rs.b 1
frKyu_Run42:	rs.b 1
frKyu_Run43:	rs.b 1
frKyu_Run44:	rs.b 1
frKyu_Roll1:	rs.b 1
frKyu_Roll2:	rs.b 1
frKyu_Roll3:	rs.b 1
frKyu_Roll4:	rs.b 1
frKyu_Roll5:	rs.b 1
frKyu_Stop1:	rs.b 1
frKyu_Stop2:	rs.b 1
frKyu_Stop3:	rs.b 1
frKyu_StopTurn:	rs.b 1
frKyu_Duck1:	rs.b 1
frKyu_Duck2:	rs.b 1
frKyu_BalanceA1:	rs.b 1
frKyu_BalanceA2:	rs.b 1
frKyu_BalanceA3:	rs.b 1
frKyu_BalanceB1:	rs.b 1
frKyu_BalanceB2:	rs.b 1
frKyu_BalanceB3:	rs.b 1
frKyu_Float1:	rs.b 1
frKyu_Float2:	rs.b 1
frKyu_Float3:	rs.b 1
frKyu_Float4:	rs.b 1
frKyu_Float5:	rs.b 1
frKyu_Float6:	rs.b 1
frKyu_Float7:	rs.b 1
frKyu_Float8:	rs.b 1
frKyu_Float9:	rs.b 1
frKyu_FloatA:	rs.b 1
frKyu_FloatAlt:	rs.b 1
frKyu_Spring:	rs.b 1
frKyu_Fall1:	rs.b 1
frKyu_Fall2:	rs.b 1
frKyu_Hang1:	rs.b 1
frKyu_Hang2:	rs.b 1
frKyu_Push1:	rs.b 1
frKyu_Push2:	rs.b 1
frKyu_Push3:	rs.b 1
frKyu_Push4:	rs.b 1
frKyu_Burnt:	rs.b 1
frKyu_Drown:	rs.b 1
frKyu_Death:	rs.b 1
frKyu_Injury:	rs.b 1
frKyu_WaterSlide:	rs.b 1
frKyu_GetAir:	rs.b 1
frKyu_Debut:	rs.b 1
frKyu_Mach11:	rs.b 1
frKyu_Mach12:	rs.b 1
frKyu_Mach13:	rs.b 1
frKyu_Mach14:	rs.b 1
frKyu_Mach21:	rs.b 1
frKyu_Mach22:	rs.b 1
frKyu_Mach23:	rs.b 1
frKyu_Mach24:	rs.b 1
frKyu_Mach31:	rs.b 1
frKyu_Mach32:	rs.b 1
frKyu_Mach33:	rs.b 1
frKyu_Mach34:	rs.b 1
frKyu_Mach41:	rs.b 1
frKyu_Mach42:	rs.b 1
frKyu_Mach43:	rs.b 1
frKyu_Mach44:	rs.b 1
frKyu_Victory1:rs.b 1
frKyu_Victory2:rs.b 1
frKyu_Corkscrew1:	rs.b 1
frKyu_CorkShit: rs.b 11
frKyu_Zipline1: rs.b 1
frKyu_Zipline2: rs.b 1
frKyu_Zipline3: rs.b 1