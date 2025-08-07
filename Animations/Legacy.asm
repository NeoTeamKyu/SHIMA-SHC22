; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_Legacy:
		dc.w LegAni_Walk-Ani_Legacy;0
		dc.w LegAni_Run-Ani_Legacy;1
		dc.w LegAni_Roll-Ani_Legacy;2
		dc.w LegAni_Roll2-Ani_Legacy;3
		dc.w LegAni_Push-Ani_Legacy;4
		dc.w LegAni_Wait-Ani_Legacy;5
		dc.w LegAni_Balance-Ani_Legacy;6
		dc.w LegAni_LookUp-Ani_Legacy;7
		dc.w LegAni_Duck-Ani_Legacy;8
		dc.w LegAni_Spindash-Ani_Legacy;9
		dc.w LegAni_Falling-Ani_Legacy	;A
		dc.w LegAni_Balance2-Ani_Legacy;B
		dc.w LegAni_DashCharge-Ani_Legacy	;C
		dc.w LegAni_Stop-Ani_Legacy;D
		dc.w LegAni_Float1-Ani_Legacy;E
		dc.w LegAni_Float2-Ani_Legacy;F
		dc.w LegAni_Spring-Ani_Legacy;10
		dc.w LegAni_LZHang-Ani_Legacy;11
		dc.w LegAni_Blank-Ani_Legacy;12
		dc.w LegAni_Blank-Ani_Legacy;13
		dc.w LegAni_Blank-Ani_Legacy;14
		dc.w LegAni_Bubble-Ani_Legacy;15
		dc.w LegAni_Death-Ani_Legacy;16
		dc.w LegAni_Drown-Ani_Legacy;17
		dc.w LegAni_Death-Ani_Legacy;18
		dc.w LegAni_Blank-Ani_Legacy;19
		dc.w LegAni_Hurt-Ani_Legacy;1A
		dc.w LegAni_LZSlide-Ani_Legacy;1B
		dc.w LegAni_Blank-Ani_Legacy;1C
		dc.w LegAni_Float3-Ani_Legacy;1D
		dc.w LegAni_Float4-Ani_Legacy;1E
		dc.w LegAni_3rdRun-Ani_Legacy 	;1F
		dc.w LegAni_AirRoll-Ani_Legacy	;20
		dc.w LegAni_FwdKick-Ani_Legacy	;21
		dc.w LegAni_DiagKick-Ani_Legacy		;22
		dc.w LegAni_DarkTrans-Ani_Legacy	;23
		dc.w LegAni_Blank-Ani_Legacy	;24
		dc.w LegAni_Victory-Ani_Legacy	;25
		
LegAni_Walk:	dc.b $FF,   frL_Walk17,	  frL_Walk18,   frL_Walk11,   frL_Walk12,	 frL_Walk13,   frL_Walk14,   frL_Walk15,	frL_Walk16, afEnd
		even
LegAni_Run:		dc.b $FF, frL_Run11,	frL_Run12, frL_Run13, frL_Run14, afEnd, afEnd, afEnd, afEnd, afEnd
		even
LegAni_Roll:	dc.b $FE, frL_Roll1,  frL_Roll2, frL_Roll3, frL_Roll4, frL_Roll5, afEnd, afEnd, afEnd, afEnd
		even
LegAni_Roll2:	dc.b $FE, frL_Roll1,  frL_Roll2, frL_Roll3, frL_Roll4, frL_Roll5, afEnd, afEnd, afEnd, afEnd
		even
LegAni_Push:	dc.b $FD, frL_Push1,	frL_Push2, frL_Push3, frL_Push4, afEnd, afEnd, afEnd, afEnd, afEnd
		even
LegAni_Wait:	dc.b    5, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand
		dc.b  frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand
		dc.b  frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Stand, frL_Wait1, frL_Wait2, frL_Wait2, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3
		dc.b  frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3
		dc.b  frL_Wait4, frL_Wait4, frL_Wait3, frL_Wait3, frL_Wait4, frL_Wait4, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait7, frL_Wait8
		dc.b  frL_Wait8, frL_Wait8, frL_Wait8, frL_Wait8, frL_Wait8, frL_Wait7, frL_Wait7, afBack, $35
		even
LegAni_Balance:	dc.b	5, frL_BalanceA1, frL_BalanceA2, frL_BalanceA3, afEnd
		even
LegAni_Balance2:	dc.b	7, frL_BalanceB1, frL_BalanceB2, frL_BalanceB3, afEnd
		even		
LegAni_LookUp:	dc.b	5, frL_Look1,	frL_Look2, afBack,   1
		even
LegAni_Duck:	dc.b	5, frL_Duck1,	frL_Duck2, afBack,   1
		even
LegAni_SpinDash:	dc.b 0, frL_Spindash1, frL_Spindash2, frL_Spindash1, frL_Spindash3, frL_Spindash1, frL_Spindash4, frL_Spindash1, frL_Spindash5, frL_Spindash1, frL_Spindash6, afEnd
		even
LegAni_Falling:	dc.b 3, frL_Fall1, frL_Fall2, frL_Fall3, frL_Fall4, afBack, 2
		even
LegAni_Blank:	dc.b $77, frL_Null, afEnd
		even
LegAni_DashCharge:	dc.b 0,  frL_Peelout1, frL_Peelout1, frL_Peelout1, frL_Peelout1, frL_Peelout2, frL_Peelout2, frL_Peelout2, frL_Peelout2
		dc.b	frL_Peelout3, frL_Peelout3, frL_Peelout3, frL_Peelout3, frL_Peelout3, frL_Peelout3, frL_Peelout3, frL_Peelout3
		dc.b	frL_Peelout3,  frL_Peelout3,  frL_Peelout3,  frL_Peelout3, frL_Peelout3,  frL_Peelout3,  frL_Peelout3,  frL_Peelout4, afBack, 2
		even
LegAni_Stop:	dc.b 3,	frL_Skid1, frL_Skid2, frL_Skid3, frL_Skid4, afChange, id_Walk
		even
LegAni_Float1:	dc.b 7,	frL_Wind1, afEnd
		even
LegAni_Float2:	dc.b 7,	frL_Wind1, frL_Wind2, frL_Wind3, frL_Wind4, frL_Wind5, frL_Wind6, frL_Wind7, frL_Wind8, afEnd
		even
LegAni_Spring:	dc.b $3, frL_Fall1, frL_Spring, afBack, 1
		even
LegAni_LZHang:	dc.b 4,	frL_HangA1, frL_HangA2, afEnd
		even
LegAni_Bubble:	dc.b $B, frL_Bubble, frL_Bubble, frL_Walk11, frL_Walk12, afChange, id_Walk
		even
LegAni_Death:	dc.b $20, frL_Die, afChange, $1B	; You win this time, Delta...
		even
LegAni_Drown:	dc.b $2F, frL_Drown, afEnd
		even
LegAni_Hurt:	dc.b 3,	frL_Hurt, afEnd
		even
LegAni_LZSlide:	dc.b 7, frL_Slide, frL_Hurt, afEnd
		even
LegAni_Float3:	dc.b 3,	frL_Wind1, frL_Wind2, frL_Wind3, frL_Wind4, frL_Wind5, frL_Wind6, frL_Wind7, frL_Wind8, afEnd
		even
LegAni_Float4:	dc.b 3,	frL_Wind1, afChange, id_Walk
		even
LegAni_3rdRun:	dc.b  $FF, frL_MachSpeed11, frL_MachSpeed12, frL_MachSpeed13, frL_MachSpeed14, afEnd,afEnd,afEnd,afEnd,afEnd
		even
LegAni_AirRoll:	dc.b 2, frL_AirRoll1, frL_AirRoll2, frL_AirRoll2, frL_AirRoll3, frL_AirRoll4, frL_AirRoll5, afChange, id_Roll
		even
LegAni_DiagKick:	dc.b 6, frL_KickD1, frL_KickD2, afBack, 1
		even
LegAni_FwdKick:		dc.b 3, frL_KickF1, frL_KickF2, afBack, 1
		even
LegAni_DarkTrans:	dc.b 2, frL_Transform1, frL_Transform1, frL_Transform2, frL_Transform2, frL_Transform3, frL_Transform3, frL_Transform3, frL_Transform4, frL_Transform5, frL_Transform5, frL_Transform5, frL_Transform5, frL_Transform5, afChange,  id_Walk
		even
LegAni_Victory:		dc.b 2, frL_Victory1, frL_Victory2, frL_Victory3, frL_Victory4, frL_Victory5, frL_Victory4, frL_Victory4, frL_Victory4, frL_Victory5, frL_Victory5, frL_Victory6, frL_Victory7, frL_Victory8, frL_Victory7, afBack, 1
		even

Ani_DarkLegacy:
		dc.w LegAni_Walk-Ani_DarkLegacy;0
		dc.w LegAni_Run-Ani_DarkLegacy;1
		dc.w LegAni_Roll-Ani_DarkLegacy;2
		dc.w LegAni_Roll2-Ani_DarkLegacy;3
		dc.w LegAni_Push-Ani_DarkLegacy;4
		dc.w DLegAni_Wait-Ani_DarkLegacy;5
		dc.w LegAni_Balance-Ani_DarkLegacy;6
		dc.w LegAni_LookUp-Ani_DarkLegacy;7
		dc.w LegAni_Duck-Ani_DarkLegacy;8
		dc.w LegAni_Spindash-Ani_DarkLegacy;9
		dc.w LegAni_Falling-Ani_DarkLegacy	;A
		dc.w LegAni_Balance2-Ani_DarkLegacy;B
		dc.w LegAni_DashCharge-Ani_DarkLegacy	;C
		dc.w LegAni_Stop-Ani_DarkLegacy;D
		dc.w LegAni_Float1-Ani_DarkLegacy;E
		dc.w LegAni_Float2-Ani_DarkLegacy;F
		dc.w LegAni_Spring-Ani_DarkLegacy;10
		dc.w LegAni_LZHang-Ani_DarkLegacy;11
		dc.w LegAni_Blank-Ani_DarkLegacy;12
		dc.w LegAni_Blank-Ani_DarkLegacy;13
		dc.w LegAni_Blank-Ani_DarkLegacy;14
		dc.w LegAni_Bubble-Ani_DarkLegacy;15
		dc.w LegAni_Death-Ani_DarkLegacy;16
		dc.w LegAni_Drown-Ani_DarkLegacy;17
		dc.w LegAni_Death-Ani_DarkLegacy;18
		dc.w LegAni_Blank-Ani_DarkLegacy;19
		dc.w LegAni_Hurt-Ani_DarkLegacy;1A
		dc.w LegAni_LZSlide-Ani_DarkLegacy;1B
		dc.w LegAni_Blank-Ani_DarkLegacy;1C
		dc.w LegAni_Float3-Ani_DarkLegacy;1D
		dc.w LegAni_Float4-Ani_DarkLegacy;1E
		dc.w LegAni_3rdRun-Ani_DarkLegacy 	;1F
		dc.w LegAni_AirRoll-Ani_DarkLegacy	;20
		dc.w LegAni_FwdKick-Ani_DarkLegacy	;21
		dc.w LegAni_DiagKick-Ani_DarkLegacy		;22
		dc.w LegAni_DarkTrans-Ani_DarkLegacy	;23
		dc.w LegAni_Blank-Ani_DarkLegacy
		dc.w LegAni_Victory-Ani_DarkLegacy

DLegAni_Wait:	dc.b	5, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand
		dc.b	frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand
		dc.b	frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Stand, frL_Wait1, frL_Wait2
		dc.b	frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3
		dc.b	frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3
		dc.b	frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait4, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5
		dc.b	frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait5, frL_Wait3, frL_Wait4, frL_Wait3, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6
		dc.b	frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, frL_Wait6, afBack, $35
		even

; Legacy frame IDs
		rsreset
frL_Null:	rs.b 1
frL_Stand:	rs.b 1
frL_Wait1:	rs.b 1
frL_Wait2:	rs.b 1
frL_Wait3:	rs.b 1
frL_Wait4:	rs.b 1
frL_Wait5:	rs.b 1
frL_Wait6:	rs.b 1
frL_Wait7:	rs.b 1
frL_Wait8:	rs.b 1
frL_Look1:	rs.b 1
frL_Look2:	rs.b 1
frL_Walk11:	rs.b 1
frL_Walk12:	rs.b 1
frL_Walk13:	rs.b 1
frL_Walk14:	rs.b 1
frL_Walk15:	rs.b 1
frL_Walk16:	rs.b 1
frL_Walk17:	rs.b 1
frL_Walk18:	rs.b 1
frL_Walk21:	rs.b 1
frL_Walk22:	rs.b 1
frL_Walk23:	rs.b 1
frL_Walk24:	rs.b 1
frL_Walk25:	rs.b 1
frL_Walk26:	rs.b 1
frL_Walk27:	rs.b 1
frL_Walk28:	rs.b 1
frL_Walk31:	rs.b 1
frL_Walk32:	rs.b 1
frL_Walk33:	rs.b 1
frL_Walk34:	rs.b 1
frL_Walk35:	rs.b 1
frL_Walk36:	rs.b 1
frL_Walk37:	rs.b 1
frL_Walk38:	rs.b 1
frL_Walk41:	rs.b 1
frL_Walk42:	rs.b 1
frL_Walk43:	rs.b 1
frL_Walk44:	rs.b 1
frL_Walk45:	rs.b 1
frL_Walk46:	rs.b 1
frL_Walk47:	rs.b 1
frL_Walk48:	rs.b 1
frL_Run11:	rs.b 1
frL_Run12:	rs.b 1
frL_Run13:	rs.b 1
frL_Run14:	rs.b 1
frL_Run21:	rs.b 1
frL_Run22:	rs.b 1
frL_Run23:	rs.b 1
frL_Run24:	rs.b 1
frL_Run31:	rs.b 1
frL_Run32:	rs.b 1
frL_Run33:	rs.b 1
frL_Run34:	rs.b 1
frL_Run41:	rs.b 1
frL_Run42:	rs.b 1
frL_Run43:	rs.b 1
frL_Run44:	rs.b 1
frL_Spindash1:	rs.b 1
frL_Spindash2:	rs.b 1
frL_Spindash3:	rs.b 1
frL_Spindash4:	rs.b 1
frL_Spindash5:	rs.b 1
frL_Spindash6:	rs.b 1
frL_Slide:	rs.b 1
frL_Hurt:	rs.b 1
frL_Roll1:	rs.b 1
frL_Roll2:	rs.b 1
frL_Roll3:	rs.b 1
frL_Roll4:	rs.b 1
frL_Roll5:	rs.b 1
frL_Duck1:	rs.b 1
frL_Duck2:	rs.b 1
frL_Skid1:	rs.b 1
frL_Skid2:	rs.b 1
frL_Skid3:	rs.b 1
frL_Skid4:	rs.b 1
frL_KickD1:	rs.b 1
frL_KickD2:	rs.b 1
frL_KickF1: rs.b 1
frL_KickF2: rs.b 1
frL_BalanceA1:	rs.b 1
frL_BalanceA2:	rs.b 1
frL_BalanceA3:	rs.b 1
frL_Die:	rs.b 1
frL_Drown:	rs.b 1
frL_HangA1:	rs.b 1
frL_HangA2:	rs.b 1
frL_Bubble:	rs.b 1
frL_Push1:	rs.b 1
frL_Push2:	rs.b 1
frL_Push3:	rs.b 1
frL_Push4:	rs.b 1
frL_Wind1:	rs.b 1
frL_Wind2:	rs.b 1
frL_Wind3:	rs.b 1
frL_Wind4:	rs.b 1
frL_Wind5:	rs.b 1
frL_Wind6:	rs.b 1
frL_Wind7:	rs.b 1
frL_Wind8:	rs.b 1
frL_Peelout1:	rs.b 1
frL_Peelout2:	rs.b 1
frL_Peelout3:	rs.b 1
frL_Peelout4:	rs.b 1
frL_Spring:	rs.b 1
frL_Fall1:	rs.b 1
frL_Fall2:	rs.b 1
frL_Fall3:	rs.b 1
frL_Fall4:	rs.b 1
frL_MachSpeed11:	rs.b 1
frL_MachSpeed12:	rs.b 1
frL_MachSpeed13:	rs.b 1
frL_MachSpeed14:	rs.b 1
frL_MachSpeed21:	rs.b 1
frL_MachSpeed22:	rs.b 1
frL_MachSpeed23:	rs.b 1
frL_MachSpeed24:	rs.b 1
frL_MachSpeed31:	rs.b 1
frL_MachSpeed32:	rs.b 1
frL_MachSpeed33:	rs.b 1
frL_MachSpeed34:	rs.b 1
frL_MachSpeed41:	rs.b 1
frL_MachSpeed42:	rs.b 1
frL_MachSpeed43:	rs.b 1
frL_MachSpeed44:	rs.b 1
frL_Transform1:	rs.b 1
frL_Transform2:	rs.b 1
frL_Transform3:	rs.b 1
frL_Transform4:	rs.b 1
frL_Transform5:	rs.b 1
frL_Victory1:	rs.b 1
frL_Victory2:	rs.b 1
frL_Victory3:	rs.b 1
frL_Victory4:	rs.b 1
frL_Victory5:	rs.b 1
frL_Victory6:	rs.b 1
frL_Victory7:	rs.b 1
frL_Victory8:	rs.b 1
frL_HangB:		rs.b 1
frL_Corkscrew1:	rs.b 1
frL_CorkscrewCrap:	rs.b 11
frL_AirRoll1:	rs.b 1
frL_AirRoll2:	rs.b 1
frL_AirRoll3:	rs.b 1
frL_AirRoll4:	rs.b 1
frL_AirRoll5:	rs.b 1
frL_BalanceB1:	rs.b 1
frL_BalanceB2:	rs.b 1
frL_BalanceB3:	rs.b 1