; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

lhead:	macro plc1,lvlgfx,plc2,sixteen,twofivesix,music,pal
	dc.l (plc1<<24)+lvlgfx
	dc.l (plc2<<24)+sixteen
	dc.l twofivesix
	dc.b 0, music, pal, pal
	endm

; 1st PLC, level gfx (unused), 2nd PLC, 16x16 data, 128x128 data,
; music (unused), palette (unused), palette
;
;		1st PLC				2nd PLC				128x128 data			palette
;				level gfx*			16x16 data			music*
;
;	* music and level gfx are actually set elsewhere, so these values are useless

LevelHeaders:
	lhead	plcid_BGZ,	Kos_BGZ1,	plcid_BGZ2,	Blk16_BGZ1,	Blk128_BGZ1,mus_BGZ1,			palid_BGZ1	; Blossom Gardens
	lhead	plcid_LZ,	Kos_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	mus_Beep,			palid_LZ1	; Sunken Relic
	lhead	plcid_MZ,	Kos_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	mus_MZ,				palid_MZ1	; Ashen Temple
	lhead	plcid_SLZ,	Kos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	mus_SLZ,			palid_SLZ1	; Hoshi Metro
	lhead	plcid_SYZ,	Kos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	mus_ChineseBicycle,	palid_SYZ1	; Bumper City
	lhead	plcid_SBZ,	Kos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	mus_SBZ,			palid_SBZ1	; Badnik Blitz
	lhead	plcid_MHZ,	Kos_MHZ,	plcid_MHZ2,	Blk16_MHZ,	Blk128_MHZ,	mus_Icescape,		palid_MHZ1	; Melting Heights
	if DemoMode=0
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MCZ2P,			palid_HPZ1	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_FBZ1,			palid_TMZ1	; The Magnet
	else
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MZ,			palid_HPZ1	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_SBZ,			palid_TMZ1	; The Magnet
	endc	
	zonewarning LevelHeaders,$10
	lhead	0,			Kos_End,	0,			Blk16_End,	Blk128_End,	mus_SBZ,			palid_Ending; Ending
	even

LevelHeaders2:
	lhead	plcid_BGZ,	Kos_BGZ2,	plcid_BGZ2,	Blk16_BGZ2,	Blk128_BGZ2,mus_BGZ1,				palid_BGZ2	; Blossom Gardens
	lhead	plcid_LZ,	Kos_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	mus_Beep,				palid_LZ2	; Sunken Relic
	lhead	plcid_MZ,	Kos_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	mus_MZ,					palid_MZ2	; Ashen Temple
	lhead	plcid_SLZ,	Kos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	mus_SLZ,				palid_SLZ2	; Hoshi Metro
	lhead	plcid_SYZ,	Kos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	mus_ChineseBicycle,		palid_SYZ2	; Bumper City
	lhead	plcid_SBZ,	Kos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	mus_SBZ,				palid_SBZ2	; Badnik Blitz
	lhead	plcid_MHZ,	Kos_MHZ,	plcid_MHZ2,	Blk16_MHZ,	Blk128_MHZ,	mus_Icescape,			palid_MHZ2	; Melting Heights
	if DemoMode=0
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MCZ2P,				palid_HPZ2	; Hidden Palace	
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_FBZ1,				palid_TMZ2	; The Magnet
	else
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_LZ,				palid_HPZ2	; Hidden Palace	
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_SBZ,				palid_TMZ2	; The Magnet
	endc	
	zonewarning LevelHeaders2,$10
	lhead	0,			Kos_End,	0,			Blk16_End,	Blk128_End,	mus_SBZ,				palid_Ending; Ending
	even

LevelHeaders3:
	lhead	plcid_BGZ,	Kos_BGZ3,	plcid_BGZ2,	Blk16_BGZ3,	Blk128_BGZ3,mus_BGZ1,				palid_BGZ3	; Blossom Gardens
	lhead	plcid_LZ,	Kos_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	mus_Beep,				palid_LZ3	; Sunken Relic
	lhead	plcid_MZ,	Kos_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	mus_MZ,					palid_MZ3	; Ashen Temple
	lhead	plcid_SLZ,	Kos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	mus_SLZ,				palid_SLZ3	; Hoshi Metro
	lhead	plcid_SYZ,	Kos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	mus_ChineseBicycle,		palid_SYZ3	; Bumper City
	lhead	plcid_SBZ,	Kos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	mus_SBZ,				palid_SBZ2	; Badnik Blitz
	lhead	plcid_MHZ,	Kos_MHZ,	plcid_MHZ2,	Blk16_MHZ,	Blk128_MHZ,	mus_Icescape,			palid_MHZ3	; Melting Heights
	if DemoMode=0
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MCZ2P,				palid_HPZ3	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_FBZ1,				palid_TMZ3	; The Magnet
	else
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MZ,				palid_HPZ3	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_SBZ,				palid_TMZ3	; The Magnet
	endc	
	zonewarning LevelHeaders3,$10
	lhead	0,			Kos_End,	0,			Blk16_End,	Blk128_End,	mus_SBZ,				palid_Ending; Ending
	even

LevelHeaders4:
	lhead	plcid_LBGZ,	Kos_LBGZ,	plcid_LBGZ2,Blk16_LBGZ,	Blk128_LBGZ,mus_EHZ,				palid_LBGZ	; Blossom Gardens
	lhead	plcid_LZ,	Kos_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	mus_Beep,				palid_SBZ3	; Sunken Relic
	lhead	plcid_MZ,	Kos_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	mus_MZ,					palid_MZ4	; Ashen Temple
	lhead	plcid_SLZ,	Kos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	mus_SLZ,				palid_SLZ4	; Hoshi Metro
	lhead	plcid_SYZ,	Kos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	mus_ChineseBicycle,		palid_SYZ4	; Bumper City
	lhead	plcid_SBZ,	Kos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	mus_SBZ,				palid_SBZ4	; Badnik Blitz
	lhead	plcid_MHZ,	Kos_MHZ,	plcid_MHZ2,	Blk16_MHZ,	Blk128_MHZ,	mus_Icescape,			palid_MHZ4	; Melting Heights
	if DemoMode=0	
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MCZ2P,				palid_HPZ4	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_FBZ1,				palid_TMZ4	; The Magnet
	else
	lhead	plcid_HPZ,	Kos_HPZ,	plcid_HPZ2,	Blk16_HPZ,	Blk128_HPZ,	mus_MZ,				palid_HPZ4	; Hidden Palace
	lhead	plcid_TMZ,	Kos_TMZ,	plcid_TMZ2,	Blk16_TMZ,	Blk128_TMZ,	mus_SBZ,				palid_TMZ4	; The Magnet	
	endc
	zonewarning LevelHeaders4,$10
	lhead	0,			Kos_Title,	0,			Blk16_Title,Blk128_Title,mus_SBZ,				palid_BGZ1	; Title Screen
	even