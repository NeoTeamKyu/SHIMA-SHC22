; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

palp:	macro paladdress,ramaddress,colors
	dc.l paladdress
	dc.w ramaddress, (colors>>1)-1
	endm

PalPointers:

; palette address, RAM address, colors

ptr_Pal_NTKLogo:		palp	Pal_NTKLogo,v_pal_dry,$20

ptr_Pal_Sonic:			palp	Pal_Sonic,v_pal_dry,$10
ptr_Pal_Tails:			palp	Pal_Tails,v_pal_dry,$10
ptr_Pal_Knuckles:		palp	Pal_Knuckles,v_pal_dry,$10
ptr_Pal_Kyuko:			palp	Pal_Kyuko,v_pal_dry,$10
ptr_Pal_Metal:			palp	Pal_Metal,v_pal_dry,$10
ptr_Pal_Mighty:			palp	Pal_Mighty,v_pal_dry,$10
ptr_Pal_Amy:			palp	Pal_Amy,v_pal_dry,$10
ptr_Pal_LegacySonic:	palp	Pal_LegacySonic,v_pal_dry,$10

Pal_Levels:
; BGZ
ptr_Pal_BGZ1:			palp	Pal_BGZ1,v_pal_dry+$20,$30
ptr_Pal_BGZ2:			palp	Pal_BGZ2,v_pal_dry+$20,$30
ptr_Pal_BGZ3:			palp	Pal_BGZ3,v_pal_dry+$20,$30
ptr_Pal_LBGZ:			palp	Pal_LBGZ,v_pal_dry+$20,$30
; SRZ
ptr_Pal_LZ1:			palp	Pal_LZ,v_pal_dry+$20,$30
ptr_Pal_LZ2:			palp	Pal_LZ,v_pal_dry+$20,$30
ptr_Pal_LZ3:			palp	Pal_LZ,v_pal_dry+$20,$30
ptr_Pal_SBZ3:			palp	Pal_SBZ3,v_pal_dry+$20,$30
; ATZ
ptr_Pal_MZ1:			palp	Pal_MZ,v_pal_dry+$20,$30
ptr_Pal_MZ2:			palp	Pal_MZ,v_pal_dry+$20,$30
ptr_Pal_MZ3:			palp	Pal_MZ,v_pal_dry+$20,$30
ptr_Pal_MZ4:			palp	Pal_MZ,v_pal_dry+$20,$30
; HMZ
ptr_Pal_SLZ1:			palp	Pal_SLZ,v_pal_dry+$20,$30
ptr_Pal_SLZ2:			palp	Pal_SLZ,v_pal_dry+$20,$30
ptr_Pal_SLZ3:			palp	Pal_SLZ,v_pal_dry+$20,$30
ptr_Pal_SLZ4:			palp	Pal_SLZ,v_pal_dry+$20,$30
; BCZ
ptr_Pal_SYZ1:			palp	Pal_SYZ,v_pal_dry+$20,$30
ptr_Pal_SYZ2:			palp	Pal_SYZ,v_pal_dry+$20,$30
ptr_Pal_SYZ3:			palp	Pal_SYZ,v_pal_dry+$20,$30
ptr_Pal_SYZ4:			palp	Pal_SYZ,v_pal_dry+$20,$30
; BBZ
ptr_Pal_SBZ1:			palp	Pal_SBZ1,v_pal_dry+$20,$30
ptr_Pal_SBZ2:			palp	Pal_SBZ2,v_pal_dry+$20,$30
ptr_Pal_FZ:				palp	Pal_SBZ2,v_pal_dry+$20,$30
ptr_Pal_SBZ4:			palp	Pal_SBZ1,v_pal_dry+$20,$30
; MHZ
ptr_Pal_MHZ1:			palp	Pal_MHZ,v_pal_dry+$20,$30
ptr_Pal_MHZ2:			palp	Pal_MHZ,v_pal_dry+$20,$30
ptr_Pal_MHZ3:			palp	Pal_MHZ,v_pal_dry+$20,$30
ptr_Pal_MHZ4:			palp	Pal_MHZ,v_pal_dry+$20,$30
; HPZ
ptr_Pal_HPZ1:			palp	Pal_HPZ,v_pal_dry+$20,$30
ptr_Pal_HPZ2:			palp	Pal_HPZ,v_pal_dry+$20,$30
ptr_Pal_HPZ3:			palp	Pal_HPZ,v_pal_dry+$20,$30
ptr_Pal_HPZ4:			palp	Pal_HPZ,v_pal_dry+$20,$30
; TMZ
ptr_Pal_TMZ1:			palp	Pal_TMZ,v_pal_dry+$20,$30
ptr_Pal_TMZ2:			palp	Pal_TMZ,v_pal_dry+$20,$30
ptr_Pal_TMZ3:			palp	Pal_TMZ,v_pal_dry+$20,$30
ptr_Pal_TMZ4:			palp	Pal_TMZ,v_pal_dry+$20,$30
			zonewarning Pal_Levels,8*4
ptr_Pal_BGZBoss:		palp	Pal_BGZBoss,v_pal_dry+$20,$10
ptr_Pal_MHZBoss:		palp	Pal_MHZBoss,v_pal_dry+$20,$10

ptr_Pal_SSResult:		palp	Pal_SSResult,v_pal_dry,$40
ptr_Pal_Continue:		palp	Pal_Continue,v_pal_dry,$20
ptr_Pal_Ending:			palp	Pal_Ending,v_pal_dry,$40
ptr_Pal_Credits:		palp	Pal_Credits,v_pal_dry,$40
ptr_Pal_Menu:			palp	Pal_Menu,v_pal_dry+$20,$30

ptr_Pal_SpecialStage:	palp	Pal_SpecialStage,v_pal_dry+$20,$30

ptr_Pal_Options:		palp	Pal_Options,v_pal_dry+$20,$30
	if DemoMode=1
ptr_Pal_EOD:		palp	Pal_EOD,v_pal_dry,$20
	endc
			even


palid_NTKLogo:			equ		(ptr_Pal_NTKLogo-PalPointers)/8

palid_Sonic:			equ		(ptr_Pal_Sonic-PalPointers)/8
palid_Tails:			equ		(ptr_Pal_Tails-PalPointers)/8
palid_Knuckles:			equ		(ptr_Pal_Knuckles-PalPointers)/8
palid_Kyuko:			equ		(ptr_Pal_Kyuko-PalPointers)/8
palid_Metal:			equ		(ptr_Pal_Metal-PalPointers)/8
palid_Mighty:			equ		(ptr_Pal_Mighty-PalPointers)/8
palid_Amy:				equ		(ptr_Pal_Amy-PalPointers)/8
palid_LegacySonic:		equ		(ptr_Pal_LegacySonic-PalPointers)/8

; BGZ
palid_BGZ1:				equ		(ptr_Pal_BGZ1-PalPointers)/8
palid_BGZ2:				equ		(ptr_Pal_BGZ2-PalPointers)/8
palid_BGZ3:				equ		(ptr_Pal_BGZ3-PalPointers)/8
palid_BGZBoss:			equ		(ptr_Pal_BGZBoss-PalPointers)/8
palid_LBGZ:				equ		(ptr_Pal_LBGZ-PalPointers)/8
; SRZ
palid_LZ1:				equ		(ptr_Pal_LZ1-PalPointers)/8
palid_LZ2:				equ		(ptr_Pal_LZ2-PalPointers)/8
palid_LZ3:				equ		(ptr_Pal_LZ3-PalPointers)/8
palid_SBZ3:				equ		(ptr_Pal_SBZ3-PalPointers)/8
; ATZ
palid_MZ1:				equ		(ptr_Pal_MZ1-PalPointers)/8
palid_MZ2:				equ		(ptr_Pal_MZ2-PalPointers)/8
palid_MZ3:				equ		(ptr_Pal_MZ3-PalPointers)/8
palid_MZ4:				equ		(ptr_Pal_MZ4-PalPointers)/8
; HMZ
palid_SLZ1:				equ		(ptr_Pal_SLZ1-PalPointers)/8
palid_SLZ2:				equ		(ptr_Pal_SLZ2-PalPointers)/8
palid_SLZ3:				equ		(ptr_Pal_SLZ3-PalPointers)/8
palid_SLZ4:				equ		(ptr_Pal_SLZ4-PalPointers)/8
; BCZ
palid_SYZ1:				equ		(ptr_Pal_SYZ1-PalPointers)/8
palid_SYZ2:				equ		(ptr_Pal_SYZ2-PalPointers)/8
palid_SYZ3:				equ		(ptr_Pal_SYZ3-PalPointers)/8
palid_SYZ4:				equ		(ptr_Pal_SYZ4-PalPointers)/8
; BBZ
palid_SBZ1:				equ		(ptr_Pal_SBZ1-PalPointers)/8
palid_SBZ2:				equ		(ptr_Pal_SBZ2-PalPointers)/8
palid_FZ:				equ		(ptr_Pal_FZ-PalPointers)/8
palid_SBZ4:				equ		(ptr_Pal_SBZ4-PalPointers)/8
; MHZ
palid_MHZ1:				equ		(ptr_Pal_MHZ1-PalPointers)/8
palid_MHZ2:				equ		(ptr_Pal_MHZ2-PalPointers)/8
palid_MHZ3:				equ		(ptr_Pal_MHZ3-PalPointers)/8
palid_MHZBoss:			equ		(ptr_Pal_MHZBoss-PalPointers)/8
palid_MHZ4:				equ		(ptr_Pal_MHZ4-PalPointers)/8
; HPZ
palid_HPZ1:				equ		(ptr_Pal_HPZ1-PalPointers)/8
palid_HPZ2:				equ		(ptr_Pal_HPZ2-PalPointers)/8
palid_HPZ3:				equ		(ptr_Pal_HPZ3-PalPointers)/8
palid_HPZ4:				equ		(ptr_Pal_HPZ4-PalPointers)/8
; TMZ
palid_TMZ1:				equ		(ptr_Pal_TMZ1-PalPointers)/8
palid_TMZ2:				equ		(ptr_Pal_TMZ2-PalPointers)/8
palid_TMZ3:				equ		(ptr_Pal_TMZ3-PalPointers)/8
palid_TMZ4:				equ		(ptr_Pal_TMZ4-PalPointers)/8

palid_Special:			equ		(ptr_Pal_Special-PalPointers)/8

palid_SSResult:			equ		(ptr_Pal_SSResult-PalPointers)/8
palid_Continue:			equ		(ptr_Pal_Continue-PalPointers)/8
palid_Ending:			equ		(ptr_Pal_Ending-PalPointers)/8
palid_Credits:			equ		(ptr_Pal_Credits-PalPointers)/8
palid_Menu:				equ		(ptr_Pal_Menu-PalPointers)/8

palid_SpecStag:			equ		(ptr_Pal_SpecialStage-PalPointers)/8
palid_Options:			equ		(ptr_Pal_Options-PalPointers)/8
palid_EOD:			equ		(ptr_Pal_EOD-PalPointers)/8