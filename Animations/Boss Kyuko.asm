; ---------------------------------------------------------------------------
; Animation script - Boss Kyuko
; ---------------------------------------------------------------------------
Ani_BossKyuko:
	dc.w BKyuAni_Walk-Ani_BossKyuko
	dc.w BKyuAni_Run-Ani_BossKyuko
	dc.w BKyuAni_Roll-Ani_BossKyuko
	dc.w BKyuAni_Roll2-Ani_BossKyuko
	dc.w BKyuAni_Push-Ani_BossKyuko
	dc.w BKyuAni_Idle-Ani_BossKyuko
	dc.w BKyuAni_Balance-Ani_BossKyuko
	dc.w BKyuAni_Balance2-Ani_BossKyuko
	dc.w BKyuAni_LookUp-Ani_BossKyuko
	dc.w BKyuAni_Duck-Ani_BossKyuko
	dc.w BKyuAni_Stop-Ani_BossKyuko
	dc.w BKyuAni_Float1-Ani_BossKyuko
	dc.w BKyuAni_Float2-Ani_BossKyuko
	dc.w BKyuAni_Float3-Ani_BossKyuko
	dc.w BKyuAni_Float4-Ani_BossKyuko
	dc.w BKyuAni_Spring-Ani_BossKyuko
	dc.w BKyuAni_Hang-Ani_BossKyuko
	dc.w BKyuAni_GetAir-Ani_BossKyuko
	dc.w BKyuAni_Drown-Ani_BossKyuko
	dc.w BKyuAni_Death-Ani_BossKyuko
	dc.w BKyuAni_Hurt-Ani_BossKyuko
	dc.w BKyuAni_Null-Ani_BossKyuko
	dc.w BKyuAni_Victory-Ani_BossKyuko
	dc.w BKyuAni_Fall-Ani_BossKyuko

BKyuAni_Walk:	dc.b $FF, frBKyu_walk15, frBKyu_walk16,	frBKyu_walk17, frBKyu_walk18, frBKyu_walk11,	frBKyu_walk12,	frBKyu_walk13,	frBKyu_walk14, afEnd
		even
BKyuAni_Run:		dc.b $FF,  frBKyu_run11,  frBKyu_run12,  frBKyu_run13,  frBKyu_run14,     afEnd,		afEnd,		afEnd,		afEnd, afEnd
		even
BKyuAni_Roll:	dc.b $FE,  frBKyu_Roll1,  frBKyu_Roll2,  frBKyu_Roll3,  frBKyu_Roll4,  frBKyu_Roll5,     afEnd, afEnd
		even
BKyuAni_Roll2:	dc.b $FE,  frBKyu_Roll1,  frBKyu_Roll2,  frBKyu_Roll5,  frBKyu_Roll3,  frBKyu_Roll4,  frBKyu_Roll5, afEnd
		even
BKyuAni_Push:	dc.b $FD,  frBKyu_push1,  frBKyu_push2,  frBKyu_push3,  frBKyu_push4,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
BKyuAni_Idle:	dc.b 5, frBKyu_Idle1, frBKyu_Idle2, frBKyu_Idle3, frBKyu_Idle4, frBKyu_Idle5, frBKyu_Idle6, frBKyu_Idle7, frBKyu_Idle8, afEnd
		even
BKyuAni_Balance:	dc.b 5, frBKyu_balbnce1, frBKyu_balbnce2, frBKyu_balbnce3, afEnd
		even
BKyuAni_Balance2:dc.b 7, frBKyu_balance1, frBKyu_balance2, frBKyu_balance3, afEnd
        even
BKyuAni_LookUp:	dc.b 5, frBKyu_lookt, frBKyu_lookup, afBack, 1
		even
BKyuAni_Duck:	dc.b 5, frBKyu_duckt, frBKyu_duck, afBack, 1
		even
BKyuAni_Stop:	dc.b 3,	frBKyu_stop1, frBKyu_stop2, frBKyu_stop3, frBKyu_stop4, afChange, id_Walk
		even
BKyuAni_Float1:	dc.b 7,	frBKyu_float1, frBKyu_float1, afEnd
		even
BKyuAni_Float2:	dc.b 7,	frBKyu_float1, frBKyu_float2, frBKyu_float3, frBKyu_float4, frBKyu_float5, frBKyu_float6, frBKyu_float7, frBKyu_float8, afEnd
		even
BKyuAni_Float3:	dc.b 3,	frBKyu_float1, frBKyu_float2, frBKyu_float3, frBKyu_float4, frBKyu_float5, frBKyu_float6, frBKyu_float7, frBKyu_float8, afEnd
		even
BKyuAni_Float4:	dc.b 3,	frBKyu_float1, afChange, id_Walk
		even
BKyuAni_Spring:	dc.b $2F, frBKyu_spring, afChange, id_Walk
		even
BKyuAni_Hang:	dc.b 4,	frBKyu_hang1, frBKyu_hang2, afEnd
		even
BKyuAni_GetAir:	dc.b $B, frBKyu_getair, frBKyu_getair, frBKyu_walk17, frBKyu_walk18, afChange, id_Walk
		even
BKyuAni_Drown:	dc.b $2F, frBKyu_drown, afEnd
		even
BKyuAni_Death:	dc.b 3,	frBKyu_death, afEnd
		even
BKyuAni_Hurt:	dc.b 3,	frBKyu_injury, afEnd
		even
BKyuAni_Null:	dc.b $77, frBKyu_null, afChange, id_Walk
		even
BKyuAni_Victory:	dc.b 5, frBKyu_victory1, frBKyu_victory2, frBKyu_victory2, frBKyu_victory2, frBKyu_victory3, frBKyu_victory3, frBKyu_victory4, frBKyu_victory4, frBKyu_victory3, frBKyu_victory3, afBack, 7
		even
BKyuAni_Fall:	dc.b 3,	frBKyu_stop1, frBKyu_stop2, afEnd
		even

; BossKyuko frame IDs
	rsreset
frBKyu_Null:		rs.b 1
frBKyu_Idle1:	rs.b 1
frBKyu_Idle2:	rs.b 1
frBKyu_Idle3:	rs.b 1
frBKyu_Idle4:	rs.b 1
frBKyu_Idle5:	rs.b 1
frBKyu_Idle6:	rs.b 1
frBKyu_Idle7:	rs.b 1
frBKyu_Idle8:	rs.b 1
frBKyu_LookT:	rs.b 1
frBKyu_LookUp:	rs.b 1
frBKyu_Walk11:	rs.b 1
frBKyu_Walk12:	rs.b 1
frBKyu_Walk13:	rs.b 1
frBKyu_Walk14:	rs.b 1
frBKyu_Walk15:	rs.b 1
frBKyu_Walk16:	rs.b 1
frBKyu_Walk17:	rs.b 1
frBKyu_Walk18:	rs.b 1
frBKyu_Run11:	rs.b 1
frBKyu_Run12:	rs.b 1
frBKyu_Run13:	rs.b 1
frBKyu_Run14:	rs.b 1
frBKyu_Roll1:	rs.b 1
frBKyu_Roll2:	rs.b 1
frBKyu_Roll3:	rs.b 1
frBKyu_Roll4:	rs.b 1
frBKyu_Roll5:	rs.b 1
frBKyu_Stop1:	rs.b 1
frBKyu_Stop2:	rs.b 1
frBKyu_Stop3:	rs.b 1
frBKyu_Stop4:	rs.b 1
frBKyu_DuckT:	rs.b 1
frBKyu_Duck:		rs.b 1
frBKyu_Balance1:	rs.b 1
frBKyu_Balance2:	rs.b 1
frBKyu_Balance3:	rs.b 1
frBKyu_Balbnce1:	rs.b 1
frBKyu_Balbnce2:	rs.b 1
frBKyu_Balbnce3:	rs.b 1
frBKyu_Float1:	rs.b 1
frBKyu_Float2:	rs.b 1
frBKyu_Float3:	rs.b 1
frBKyu_Float4:	rs.b 1
frBKyu_Float5:	rs.b 1
frBKyu_Float6:	rs.b 1
frBKyu_Float7:	rs.b 1
frBKyu_Float8:	rs.b 1
frBKyu_Spring:	rs.b 1
frBKyu_Hang1:	rs.b 1
frBKyu_Hang2:	rs.b 1
frBKyu_Push1:	rs.b 1
frBKyu_Push2:	rs.b 1
frBKyu_Push3:	rs.b 1
frBKyu_Push4:	rs.b 1
frBKyu_Drown:	rs.b 1
frBKyu_Death:	rs.b 1
frBKyu_Injury:	rs.b 1
frBKyu_GetAir:	rs.b 1
frBKyu_Victory1:	rs.b 1
frBKyu_Victory2:	rs.b 1
frBKyu_Victory3:	rs.b 1
frBKyu_Victory4:	rs.b 1