; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_Sonic:
ptr_Walk:	dc.w SonAni_Walk-Ani_Sonic
ptr_Run:	dc.w SonAni_Run-Ani_Sonic
ptr_Roll:	dc.w SonAni_Roll-Ani_Sonic
ptr_Roll2:	dc.w SonAni_Roll2-Ani_Sonic
ptr_Push:	dc.w SonAni_Push-Ani_Sonic
ptr_Wait:	dc.w SonAni_Wait-Ani_Sonic
ptr_Balance:	dc.w SonAni_Balance-Ani_Sonic
ptr_LookUp:	dc.w SonAni_LookUp-Ani_Sonic
ptr_Duck:	dc.w SonAni_Duck-Ani_Sonic
ptr_Spindash:	dc.w SonAni_Spindash-Ani_Sonic
ptr_Fall:	dc.w SonAni_Fall-Ani_Sonic
ptr_Balance2:	dc.w SonAni_Balance2-Ani_Sonic
ptr_MariJump1:	dc.w SonAni_Debut-Ani_Sonic
ptr_Stop:	dc.w SonAni_Stop-Ani_Sonic
ptr_Float1:	dc.w SonAni_Float1-Ani_Sonic
ptr_Float2:	dc.w SonAni_Float2-Ani_Sonic
ptr_Spring:	dc.w SonAni_Spring-Ani_Sonic
ptr_Hang:	dc.w SonAni_Hang-Ani_Sonic
ptr_Leap1:	dc.w SonAni_Debut-Ani_Sonic
ptr_Leap2:	dc.w SonAni_Debut-Ani_Sonic
ptr_MariJump2:	dc.w SonAni_Debut-Ani_Sonic
ptr_GetAir:	dc.w SonAni_GetAir-Ani_Sonic
ptr_Burnt:	dc.w SonAni_Burnt-Ani_Sonic
ptr_Drown:	dc.w SonAni_Drown-Ani_Sonic
ptr_Death:	dc.w SonAni_Death-Ani_Sonic
ptr_Shrink:	dc.w SonAni_Debut-Ani_Sonic
ptr_Hurt:	dc.w SonAni_Hurt-Ani_Sonic
ptr_WaterSlide:	dc.w SonAni_WaterSlide-Ani_Sonic
ptr_Null:	dc.w SonAni_Null-Ani_Sonic
ptr_Float3:	dc.w SonAni_Float3-Ani_Sonic
ptr_Float4:	dc.w SonAni_Float4-Ani_Sonic
ptr_HurtMad:dc.w SonAni_Debut-Ani_Sonic
ptr_SlideMad:dc.w SonAni_Debut-Ani_Sonic
ptr_DieMad:	dc.w SonAni_Debut-Ani_Sonic
ptr_DropDash:	dc.w	SonAni_DropDash-Ani_Sonic
ptr_Debut:	dc.w	SonAni_Debut-Ani_Sonic
ptr_MachSpeed:	dc.w	SonAni_MachSpeed-Ani_Sonic
ptr_Victory:	dc.w	SonAni_Victory-Ani_Sonic
ptr_Transform:	dc.w	SonAni_Transform-Ani_Sonic

SonAni_Walk:	dc.b $FF, frS_Walk17, frS_Walk18, frS_Walk11, frS_Walk12, frS_Walk13, frS_Walk14,	frS_Walk15, frS_Walk16, afEnd
		even
SonAni_Run:	dc.b $FF,  frS_Run11,  frS_Run12,  frS_Run13,  frS_Run14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Roll:	dc.b $FE,  frS_Roll1,  frS_Roll2,  frS_Roll3,  frS_Roll4,  frS_Roll5,     afEnd, afEnd
		even
SonAni_Roll2:	dc.b $FE,  frS_Roll1,  frS_Roll2,  frS_Roll5,  frS_Roll3,  frS_Roll4,  frS_Roll5, afEnd
		even
SonAni_Push:	dc.b $FD,  frS_push1,  frS_push2,  frS_push3,  frS_push4,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Wait:	dc.b   5,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand
				dc.b   frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Stand,  frS_Wait1
				dc.b   frS_Wait2,	frS_Wait3,  frS_Wait3,  frS_Wait3,  frS_Wait3,  frS_Wait3,  frS_Wait4,  frS_Wait4,  frS_Wait4,  frS_Wait5,  frS_Wait5,  frS_Wait5, afBack, 6
		even
SonAni_Balance:	dc.b 7, frS_BalanceA1, frS_BalanceA2, frS_BalanceA3, afEnd
		even
SonAni_LookUp:	dc.b 5, frS_Look1, frS_Look2, afBack, 1
		even
SonAni_Duck:	dc.b 5, frS_Duck1, frS_Duck2, afBack, 1
		even
SonAni_Spindash:	dc.b 0,frS_SpDsh1,frS_SpDsh2,frS_SpDsh1,frS_SpDsh3,frS_SpDsh1,frS_SpDsh4,frS_SpDsh1,frS_SpDsh5,frS_SpDsh1,frS_SpDsh6,afEnd
		even
SonAni_Fall:	dc.b 3,	frS_Fall1, frS_Fall2, afBack, 1
		even
SonAni_Balance2:dc.b 8, frS_BalanceB1, frS_BalanceB2, frS_BalanceB3, frS_BalanceB2, afEnd
		even
SonAni_Stop:	dc.b 7,	frS_Stop1, frS_Stop2, frS_Stop3, frS_StopTurn, afBack, 1
		even
SonAni_Float1:	dc.b 7,	frS_Float1, frS_FloatAlt, afEnd
		even
SonAni_Float2:	dc.b 3,	frS_Float1, frS_Float2, frS_Float3, frS_Float4, frS_Float5, frS_Float6, frS_Float7, frS_Float8, frS_Float9, frS_FloatA, afEnd
		even
SonAni_Spring:	dc.b $2F, frS_Spring, afEnd
		even
SonAni_Hang:	dc.b 4,	frS_Hang1, frS_Hang2, afEnd
		even
SonAni_GetAir:	dc.b $B, frS_GetAir, frS_GetAir, frS_Walk15, frS_Walk16, afChange, id_Walk
		even
SonAni_Burnt:	dc.b $20, frS_Burnt, afEnd
		even
SonAni_Drown:	dc.b $2F, frS_Drown, afEnd
		even
SonAni_Death:	dc.b $20,	frS_Death, afChange, id_WaterSlide
		even
SonAni_Hurt:	dc.b 3,	frS_Injury, afEnd
		even
SonAni_WaterSlide:
		dc.b 7, frS_Injury, frS_WaterSlide, afEnd
		even
SonAni_Null:	dc.b $77, frS_Null, afEnd
		even
SonAni_Float3:	dc.b 1,	frS_Float1, frS_Float2, frS_Float3, frS_Float4, frS_Float5, frS_Float6, frS_Float7, frS_Float8, frS_Float9, frS_FloatA, afEnd
		even
SonAni_Float4:	dc.b 3,	frS_Float1, afChange, id_Walk
		even
SonAni_DropDash:dc.b 0, frS_DropDash1, frS_DropDash2, frS_DropDash5, frS_DropDash3, frS_DropDash4, frS_DropDash5, afEnd
		even
SonAni_Debut:	dc.b $77, frS_Debut, afEnd
		even
SonAni_MachSpeed:	dc.b $FF,  frS_Mach11,  frS_Mach12,  frS_Mach13,  frS_Mach14,     afEnd,     afEnd, afEnd, afEnd, afEnd
		even
SonAni_Victory:	dc.b $7, frS_Victory1, frS_Victory2, afBack, 1
		even
SonAni_Transform:	dc.b 2, frS_Tran1, frS_Tran1, frS_Tran2, frS_Tran2, frS_Tran3, frS_Tran4, frS_Tran5, frS_Tran4, frS_Tran5, frS_Tran4, frS_Tran5, frS_Tran4, frS_Tran5, afChange,  id_Walk
		even

id_Walk:	equ (ptr_Walk-Ani_Sonic)/2	; 0
id_Run:		equ (ptr_Run-Ani_Sonic)/2	; 1
id_Roll:	equ (ptr_Roll-Ani_Sonic)/2	; 2
id_Roll2:	equ (ptr_Roll2-Ani_Sonic)/2	; 3
id_Push:	equ (ptr_Push-Ani_Sonic)/2	; 4
id_Wait:	equ (ptr_Wait-Ani_Sonic)/2	; 5
id_Balance:	equ (ptr_Balance-Ani_Sonic)/2	; 6
id_LookUp:	equ (ptr_LookUp-Ani_Sonic)/2	; 7
id_Duck:	equ (ptr_Duck-Ani_Sonic)/2	; 8
id_Spindash:	equ (ptr_Spindash-Ani_Sonic)/2	; 9
id_Fall:	equ (ptr_Fall-Ani_Sonic)/2	; $A
id_Balance2:	equ (ptr_Balance2-Ani_Sonic)/2	; $B
id_MariJump1:	equ (ptr_MariJump1-Ani_Sonic)/2	; $C
id_Stop:	equ (ptr_Stop-Ani_Sonic)/2	; $D
id_Float1:	equ (ptr_Float1-Ani_Sonic)/2	; $E
id_Float2:	equ (ptr_Float2-Ani_Sonic)/2	; $F
id_Spring:	equ (ptr_Spring-Ani_Sonic)/2	; $10
id_Hang:	equ (ptr_Hang-Ani_Sonic)/2	; $11
id_Leap1:	equ (ptr_Leap1-Ani_Sonic)/2	; $12
id_Leap2:	equ (ptr_Leap2-Ani_Sonic)/2	; $13
id_MariJump2:	equ (ptr_MariJump2-Ani_Sonic)/2	; $14
id_GetAir:	equ (ptr_GetAir-Ani_Sonic)/2	; $15
id_Burnt:	equ (ptr_Burnt-Ani_Sonic)/2	; $16
id_Drown:	equ (ptr_Drown-Ani_Sonic)/2	; $17
id_Death:	equ (ptr_Death-Ani_Sonic)/2	; $18
id_Shrink:	equ (ptr_Shrink-Ani_Sonic)/2	; $19
id_Hurt:	equ (ptr_Hurt-Ani_Sonic)/2	; $1A
id_WaterSlide:	equ (ptr_WaterSlide-Ani_Sonic)/2 ; $1B
id_Null:	equ (ptr_Null-Ani_Sonic)/2	; $1C
id_Float3:	equ (ptr_Float3-Ani_Sonic)/2	; $1D
id_Float4:	equ (ptr_Float4-Ani_Sonic)/2	; $1E
id_HurtMad: equ (ptr_HurtMad-Ani_Sonic)/2	; $1F
id_SlideMad:equ (ptr_SlideMad-Ani_Sonic)/2	; $20
id_DieMad:	equ (ptr_DieMad-Ani_Sonic)/2	; $21
id_DropDash:equ (ptr_DropDash-Ani_Sonic)/2	; $22
id_Debut:	equ (ptr_Debut-Ani_Sonic)/2		; $23
id_MachSpeed:	equ	(ptr_MachSpeed-Ani_Sonic)/2	; $24
id_Victory:	equ (ptr_Victory-Ani_Sonic)/2	; $25
id_Transform:	equ (ptr_Transform-Ani_Sonic)/2

; ---------------------------------------------------------------------------
; Animation script - Super Sonic
; ---------------------------------------------------------------------------
Ani_SuperSonic:
	dc.w SonAni_Walk-Ani_SuperSonic
	dc.w SonAni_Run-Ani_SuperSonic
	dc.w SonAni_Roll-Ani_SuperSonic
	dc.w SonAni_Roll2-Ani_SuperSonic
	dc.w SonAni_Push-Ani_SuperSonic
	dc.w SupSonAni_Wait-Ani_SuperSonic
	dc.w SonAni_Balance-Ani_SuperSonic
	dc.w SonAni_LookUp-Ani_SuperSonic
	dc.w SonAni_Duck-Ani_SuperSonic
	dc.w SonAni_Spindash-Ani_SuperSonic
	dc.w SonAni_Fall-Ani_SuperSonic
	dc.w SonAni_Balance2-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Stop-Ani_SuperSonic
	dc.w SonAni_Float1-Ani_SuperSonic
	dc.w SonAni_Float2-Ani_SuperSonic
	dc.w SonAni_Spring-Ani_SuperSonic
	dc.w SonAni_Hang-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_GetAir-Ani_SuperSonic
	dc.w SonAni_Burnt-Ani_SuperSonic
	dc.w SonAni_Drown-Ani_SuperSonic
	dc.w SonAni_Death-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Hurt-Ani_SuperSonic
	dc.w SonAni_WaterSlide-Ani_SuperSonic
	dc.w SonAni_Null-Ani_SuperSonic
	dc.w SonAni_Float3-Ani_SuperSonic
	dc.w SonAni_Float4-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_DropDash-Ani_SuperSonic
	dc.w SonAni_Debut-Ani_SuperSonic
	dc.w SonAni_MachSpeed-Ani_SuperSonic
	dc.w SonAni_Victory-Ani_SuperSonic
	dc.w SonAni_Transform-Ani_SuperSonic

SupSonAni_Wait:	dc.b   7,  frS_Stand,  frS_Wait1,  frS_Wait2,  frS_Wait1, afEnd
		even

; Sonic frame IDs
    rsreset
frS_Null:	rs.b 1
frS_Stand:	rs.b 1
frS_Wait1:	rs.b 1
frS_Wait2:	rs.b 1
frS_Wait3:	rs.b 1
frS_Wait4:	rs.b 1
frS_Wait5:	rs.b 1
frS_Look1:	rs.b 1
frS_Look2:	rs.b 1
frS_Walk11:	rs.b 1
frS_Walk12:	rs.b 1
frS_Walk13:	rs.b 1
frS_Walk14:	rs.b 1
frS_Walk15:	rs.b 1
frS_Walk16:	rs.b 1
frS_Walk17:	rs.b 1
frS_Walk18:	rs.b 1
frS_Walk21:	rs.b 1
frS_Walk22:	rs.b 1
frS_Walk23:	rs.b 1
frS_Walk24:	rs.b 1
frS_Walk25:	rs.b 1
frS_Walk26:	rs.b 1
frS_Walk27:	rs.b 1
frS_Walk28:	rs.b 1
frS_Walk31:	rs.b 1
frS_Walk32:	rs.b 1
frS_Walk33:	rs.b 1
frS_Walk34:	rs.b 1
frS_Walk35:	rs.b 1
frS_Walk36:	rs.b 1
frS_Walk37:	rs.b 1
frS_Walk38:	rs.b 1
frS_Walk41:	rs.b 1
frS_Walk42:	rs.b 1
frS_Walk43:	rs.b 1
frS_Walk44:	rs.b 1
frS_Walk45:	rs.b 1
frS_Walk46:	rs.b 1
frS_Walk47:	rs.b 1
frS_Walk48:	rs.b 1
frS_Run11:	rs.b 1
frS_Run12:	rs.b 1
frS_Run13:	rs.b 1
frS_Run14:	rs.b 1
frS_Run21:	rs.b 1
frS_Run22:	rs.b 1
frS_Run23:	rs.b 1
frS_Run24:	rs.b 1
frS_Run31:	rs.b 1
frS_Run32:	rs.b 1
frS_Run33:	rs.b 1
frS_Run34:	rs.b 1
frS_Run41:	rs.b 1
frS_Run42:	rs.b 1
frS_Run43:	rs.b 1
frS_Run44:	rs.b 1
frS_Roll1:	rs.b 1
frS_Roll2:	rs.b 1
frS_Roll3:	rs.b 1
frS_Roll4:	rs.b 1
frS_Roll5:	rs.b 1
frS_Stop1:	rs.b 1
frS_Stop2:	rs.b 1
frS_Stop3:	rs.b 1
frS_StopTurn:	rs.b 1
frS_Duck1:	rs.b 1
frS_Duck2:	rs.b 1
frS_BalanceA1:	rs.b 1
frS_BalanceA2:	rs.b 1
frS_BalanceA3:	rs.b 1
frS_BalanceB1:	rs.b 1
frS_BalanceB2:	rs.b 1
frS_BalanceB3:	rs.b 1
frS_Float1:	rs.b 1
frS_Float2:	rs.b 1
frS_Float3:	rs.b 1
frS_Float4:	rs.b 1
frS_Float5:	rs.b 1
frS_Float6:	rs.b 1
frS_Float7:	rs.b 1
frS_Float8:	rs.b 1
frS_Float9:	rs.b 1
frS_FloatA:	rs.b 1
frS_FloatAlt:	rs.b 1
frS_Spring:	rs.b 1
frS_Fall1:	rs.b 1
frS_Fall2:	rs.b 1
frS_Hang1:	rs.b 1
frS_Hang2:	rs.b 1
frS_Push1:	rs.b 1
frS_Push2:	rs.b 1
frS_Push3:	rs.b 1
frS_Push4:	rs.b 1
frS_Burnt:	rs.b 1
frS_Drown:	rs.b 1
frS_Death:	rs.b 1
frS_Injury:	rs.b 1
frS_WaterSlide:	rs.b 1
frS_GetAir:	rs.b 1
frS_SpDsh1:	rs.b 1
frS_SpDsh2:	rs.b 1
frS_SpDsh3:	rs.b 1
frS_SpDsh4:	rs.b 1
frS_SpDsh5:	rs.b 1
frS_SpDsh6:	rs.b 1
frS_DropDash1:	rs.b 1
frS_DropDash2:	rs.b 1
frS_DropDash3:	rs.b 1
frS_DropDash4:	rs.b 1
frS_DropDash5:	rs.b 1
frS_Debut:	rs.b 1
frS_Mach11:	rs.b 1
frS_Mach12:	rs.b 1
frS_Mach13:	rs.b 1
frS_Mach14:	rs.b 1
frS_Mach21:	rs.b 1
frS_Mach22:	rs.b 1
frS_Mach23:	rs.b 1
frS_Mach24:	rs.b 1
frS_Mach31:	rs.b 1
frS_Mach32:	rs.b 1
frS_Mach33:	rs.b 1
frS_Mach34:	rs.b 1
frS_Mach41:	rs.b 1
frS_Mach42:	rs.b 1
frS_Mach43:	rs.b 1
frS_Mach44:	rs.b 1
frS_Victory1:rs.b 1
frS_Victory2:rs.b 1
frS_Corkscrew1:	rs.b 1
frS_CorkShit: rs.b 11
frS_Zipline1: rs.b 1
frS_Zipline2: rs.b 1
frS_Zipline3: rs.b 1
frS_Tran1:	rs.b 1
frS_Tran2:	rs.b 1
frS_Tran3:	rs.b 1
frS_Tran4:	rs.b 1
frS_Tran5:	rs.b 1