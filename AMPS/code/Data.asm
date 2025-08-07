; ===========================================================================
; ---------------------------------------------------------------------------
; Flags section. None of this is required, but I added it here to
; make it easier to debug built ROMS! If you would like easier
; assistance from Natsumi, please keep this section intact!
; ---------------------------------------------------------------------------
	dc.b "AMPS-v2.1"		; ident str

	if safe
		dc.b "s"		; safe mode enabled

	else
		dc.b " "		; safe mode disabled
	endif

	if FEATURE_FM6
		dc.b "F6"		; FM6 enabled
	endif

	if FEATURE_SFX_MASTERVOL
		dc.b "SM"		; sfx ignore master volume
	endif

	if FEATURE_UNDERWATER
		dc.b "UW"		; underwater mode enabled
	endif

	if FEATURE_MODULATION
		dc.b "MO"		; modulation enabled
	endif

	if FEATURE_DACFMVOLENV
		dc.b "VE"		; FM & DAC volume envelope enabled
	endif

	if FEATURE_MODENV
		dc.b "ME"		; modulation envelope enabled
	endif

	if FEATURE_PORTAMENTO
		dc.b "PM"		; portamento enabled
	endif

	if FEATURE_BACKUP
		dc.b "BA"		; backup enabled
	endif

	if FEATURE_SOUNDTEST
		dc.b "ST"		; soundtest enabled
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Define music and SFX
; ---------------------------------------------------------------------------

	opt oz-				; disable zero-offset optimization
	if safe=0
		nolist			; if in safe mode, list data section.
	endif

__mus =		MusOff

MusicIndex:
; Zone music
			;Act 1,				$20, Act 2,				$20, Act 3,			$20, Boss theme,	$20, Extra, $20	; Zone Name
	ptrMusic BGZ1,				$20, BGZ2,				$20, BGZ3,			$20, BadApplePC98,	$20, EHZ,	$20	; Blossom Gardens Zone
	ptrMusic Icescape,			$20, ICESCAPE_ACT_2,	$20, LunateElf,		$20, Cirno,			$20				; Melting Heights Zone
	ptrMusic MZ,				$20,											ImmortalSmoke,	$20				; Ashen Temple Zone
	ptrMusic ChineseBicycle,	$20, BCA2,				$20														; Bumper City Zone
	ptrMusic Beep,				$20, LZ,				$20														; Sunken Relic Zone
	ptrMusic SpaceQueens,		$20, SLZ,				$20														; Hoshi Metro Zone
	ptrMusic SBZ,				$20, FZ,				$20														; Badnik Blitz Zone
	if DemoMode=0
	ptrMusic MCZ2P,				$20																				; Hidden Palace Zone
	ptrMusic FBZ1,				$20		; The Magnet Zone
	endc	
; Invincibility themes
	ptrMusic Invincibility,	$20
; Super themes
	ptrMusic SuperTheme,	$20
; Others
	ptrMusic SS,				$20, Drowning,		$00, Boss,			$20
	ptrMusic Title,				$00, MM8StageSelect,	$00, GotThroughAct,	$00, Emerald,		$00
	ptrMusic ExtraLife, 		$00, GameOver,			$00, Continue,		$00, Ending,		$00
	ptrMusic Credits,			$00, Pichuun,			$00, Backup,		$00, SonicMyName,	$00
MusCount =	__mus-MusOff		; number of installed music tracks
SFXoff =	__mus			; first SFX ID
__sfx =		SFXoff
; ---------------------------------------------------------------------------

SoundIndex:
	ptrSFX	$01, RingRight
	ptrSFX	0, RingLeft, RingLoss, Splash, Break, Jump, Roll
	ptrSFX	0, Skid, Bubble, Drown, SpikeHit, Death, AirDing
	ptrSFX	0, Register, Bonus, Shield, Dash, BossHit, Switch
	ptrSFX	0, Signpost, Lamppost, BigRing, Bumper, Spring
	ptrSFX	0, Collapse, Smash, Basaran, BuzzExplode, Explode
	ptrSFX	0, Electricity, Flame, LavaBall, SpikeMove, Rumble
	ptrSFX	0, Door, Stomp, Chain, Saw, Lava, Checkpoint

	ptrSFX	0, EnterSS, Goal, ActionBlock, Diamonds, Continue

	ptrSFX	0, Spindash, DoubleJump, DropDash, DropCancel, Fly, FlyTired    ; S&T
	ptrSFX	0, Grab, GlideLand, GroundSlide ; K
	ptrSFX  0, CDJump, CDSkid, Charge, ChargeRelease, ChargeStop; MS
	ptrSFX  0, BubbleAttack, BubbleShield, ElectricAttack, ElectricShield, FireAttack, FireKick, FireShield, GoldShield, PogoSpring ; Shields
	ptrSFX	0, Transform, Projectile, ArrowStick, ProjectileReflect, SpringShoes, BallDeflect, DoorOpen, Error
	ptrSFX	0, SpindashS2, TubeLauncher, InstaAttack, Piko, Balloon, MagicBlock, Springboard, 10Rings, 25Rings
	ptrSFX	0, UnknownRevving, AirRoll, GlassShatter, ScoreTally
	ptrSFX	0, Choose, Select, Cancel, StartGame, Warning, Countdown	; Ported from Battle Network 6.
; SFX with special features
	ptrSFX	$80, PushBlock, Waterfall

; unused SFX
	ptrSFX	0, UnkA2, UnkAB, UnkB8

SFXcount =	__sfx-SFXoff		; number of intalled sound effects
SFXlast =	__sfx
; ===========================================================================
; ---------------------------------------------------------------------------
; Define samples
; ---------------------------------------------------------------------------

; DeltaWooloo - from what I notice, if you go above the DAC index of $E0
; the game with just crash if you just use the DACs...

__samp =	$80
SampleList:
	sample $0000, Stop, Stop			; 80 - Stop sample (DO NOT EDIT)
	sample $0100, Kick, Stop			; 81 - Kick
	sample $0100, Snare, Stop			; 82 - Snare
	sample $0100, Clap, Stop			; 83 - Clap
;	sample $0100, Scratch, Stop			; 84 - Scratch
	sample $0100, SnareS1, Stop			; 82 - S1 Snare

	sample $0100, Timpani, Stop, HiTimpani		; 85 - High Timpani
	sample $00EE, Timpani, Stop, MidTimpani		; 86 - Mid Timpani
	sample $00D4, Timpani, Stop			; 87 - Mid Timpani
	sample $00D0, Timpani, Stop, LowTimpani		; 88 - Low Timpani
	sample $00CC, Timpani, Stop, FloorTimpani	; 89 - Floor Timpani

	sample $0180, TomS2, Stop, HiTomS2		; 8A - High Tom
	sample $0140, TomS2, Stop, MidTomS2		; 8B - Mid Tom
	sample $0100, TomS2, Stop, LowTomS2		; 8C - Low Tom
	sample $00E0, TomS2, Stop, FloorTomS2		; 8D - Floor Tom

	sample $0100, Bongo, Stop, HiBongo		; 8E - High Bongo
	sample $00D0, Bongo, Stop, MidBongo		; 8F - Mid Bongo
	sample $00A0, Bongo, Stop, LowBongo		; 90 - Low Bongo
	sample $0080, Bongo, Stop, FloorBongo		; 91 - Floor Bongo

	sample $0100, SnareS3, Stop			; 92 - Snare
	sample $0100, Tom, Stop, HighTom		; 93 - High Tom
	sample $00CD, Tom, Stop, MidTom			; 94 - Mid Tom
	sample $00AB, Tom, Stop, LowTom			; 95 - Low Tom
	sample $0093, Tom, Stop, LowerTom		; 96 - Lower Tom

	sample $0100, KickS3, Stop			; 97 - Kick
;	sample $0100, KickSnare, Stop			; 98 - Kick Snare
	sample $0100, CrashCymbal, Stop			; 99 - Crash Cymbal
	sample $0100, RideCymbal, Stop			; 9A - Ride Cymbal
;	sample $0100, MetalBlock, Stop, HighMetalBlock	; 9B - High Metal Hit
;	sample $00D0, MetalBlock, Stop, LowMetalBlock	; 9C - Low Metal Hit
	sample $0100, MutedWood, Stop			; 9D - Muted Wood Block
	sample $0100, CowBell, Stop, HighCowBell	; 9E - High Cow Bell
	sample $00C7, CowBell, Stop, LowCowBell		; 9F - Low Cow Bell

	sample $0100, ElecTom, Stop, HighElecTom	; A0 - High Electric Tom
	sample $00C5, ElecTom, Stop, MidElecTom		; A1 - Mid Electric Tom
	sample $00A8, ElecTom, Stop, LowElecTom		; A2 - Low Electric Tom
	sample $008C, ElecTom, Stop, LowerElecTom	; A3 - Lower Electric Tom

	sample $0100, HeavyTom, Stop, HighHeavyTom	; A4 - High Heavy Tom
	sample $00CD, HeavyTom, Stop, MidHeavyTom	; A5 - Mid Heavy Tom
	sample $00B3, HeavyTom, Stop, LowHeavyTom	; A6 - Low Heavy Tom
	sample $0093, HeavyTom, Stop, LowerHeavyTom	; A7 - Lower Heavy Tom

;	sample $0100, TimpaniS3, Stop, HighTimpani	; A8 - High Timpani
;	sample $00BA, TimpaniS3, Stop, S3MidTimpani	; A9 - Mid Timpani
;	sample $00A9, TimpaniS3, Stop, S3LowTimpani	; AA - Low Timpani
	sample $0100, LooseSnare, Stop			; AB - Loose Snare
;	sample $0100, VocalClick, Stop			; AC - Vocal Click
;	sample $0100, VocalKick, Stop			; AD - Vocal Kick

;	sample $0100, VocalSnare, Stop			; AE - Vocal Snare
;	sample $0100, JamHit, Stop			; AF - Jam! Hit
	sample $0100, SideStick, Stop			; B0 - SIDE STICK
	sample $0100, GlassKick, Stop			; B1 - Glass Kick
;	sample $0100, GlassSmash, Stop			; B2 - Glass Smash

	sample $0100, DanceSnare, Stop			; B3 - Dance Kick Snare
	sample $0100, DanceKick, Stop			; B4 - Dance Kick
;	sample $0100, ComeOn, Stop			; B5 - Come On
	sample $0100, HeavySnare, Stop			; B6 - Heavy Snare
;	sample $0100, HeavyKick, Stop			; B6 - Heavy Kick
	sample $0100, LowKick, Stop			; B7 - Low Kick
;	sample $0100, LowKickShort, Stop		; B8 - Short Low Kick
	sample $0100, Whoo, Stop			; B9 - Whoo
	sample $0100, Go, Stop				; BA - Go
;	sample $0100, SnareGo, Stop			; BB - Go with a Snare
;	sample $0100, PowerTom, Stop			; BC - Power Tom

	sample $0100, Wood, Stop, HighWood		; BD - High Wood Block
	sample $00C4, Wood, Stop, LowWood		; BE - Low Wood Block
	sample $0100, Congo, Stop, HighCongo		; BF - High Congo Drum
	sample $00AE, Congo, Stop, LowCongo		; C0 - Low Congo Drum

	sample $0100, EchoClap, Stop, HighEchoClap	; C2 - High Echoed Clap
	sample $00C3, EchoClap, Stop, LowEchoClap	; C3 - Low Echoed Clap

;	sample $0100, KickUh, Stop			; C6 - Kick Uh
	sample $0100, ElecKick, Stop			; C7 - Eletric Kick
;	sample $0100, SynthHit, Stop			; C8 - Synth Hit
;	sample $0100, SynthHit, Stop, SynthHit2		; C9 - Synth Hit 2
	sample $0100, ReverseCrash, Stop		; CA - Reverse Fading Wind

	sample $0120, F97DL, Stop, FIFA			; CB - Lower Kick (Sonic 3D)
	sample $0100, DHSlap, Stop			; CC - Orchestra Hit (Sonic 3D)

	sample $0100, kcKick, Stop			; CD - Kick (Knuckles Chaotix)
	sample $0100, kcLowKick, Stop			; CE - Low Kick (Knuckles Chaotix)
	sample $0100, Timbale, Stop			; CF - Timbale (Knuckles Chaotix)
	sample $0100, kcClap, Stop			; D0 - Clap (Knuckles Chaotix)
	sample $0100, kcSnare, Stop			; D1 - Snare (Knuckles Chaotix)

	sample $0100, SplashCymbal, Stop		; D2 - Splash Cymbal (Knuckles Chaotix)
	sample $0100, HighCymbal, Stop			; D3 - High Cymbal (Knuckles Chaotix)
	sample $0100, kcCrashCymbal, Stop		; D4 - Crash Cymbal (Knuckles Chaotix)

	sample $0100, Clink, Stop			; D5 - Clink (Knuckles Chaotix)
	sample $0100, Gong, Stop			; D6 - Gong (Knuckles Chaotix)

	sample $0100, kcTom, Stop, kcHighTom		; D7 - High Tom
	sample $00CD, kcTom, Stop, kcMidTom		; D8 - Mid Tom
	sample $00AB, kcTom, Stop, kcLowTom		; D9 - Low Tom
	sample $0093, kcTom, Stop, kcLowerTom		; DA - Lower Tom

	sample $0100, PedalHiHat, Stop	; DB - Pedal Hi-hat
	sample $0100, ClosedHiHat, Stop		; DC - Closed Hi-hat
	sample $0100, OpenHiHat, Stop		; DD - Open Hi-hat

	sample $0100, MM8Kick, Stop		; DE - Mega Man 8's Kick
	sample $0100, MM8Snare, Stop		; DF - Mega Man 8's Snare

	sample $0100, Pichuun, Stop			; E0 - Pichuun~
	sample $0100, SonicMyName, Stop			; E1 - Sonic's My Name ~ Speed's My Game
	
	sample $0104, Choir1, Choir1		; Bass and Mellotron Choir B-D-F#
	sample $0104, Choir2, Choir2		; Bass and Mellotron Choir B-D-G
	sample $0104, Choir3, Choir3		; Bass and Mellotron Choir B-D-G#
	sample $0104, Choir4, Choir4		; Bass and Mellotron Choir G#-B-D-A
	sample $0104, Choir5, Choir5		; Bass and Mellotron Choir E-B-D-F#
	sample $0104, Choir6, Choir6		; Bass and Mellotron Choir E-B-A
	sample $0104, Choir7, Choir7		; Bass and Mellotron Choir G-D-B
	sample $0104, Choir8, Choir8		; Bass and Mellotron Choir A-E-G-B
	sample $0104, Choir9, Choir9		; Bass and Mellotron Choir B
	sample $0104, ChoirA, ChoirA		; Bass and Mellotron Choir G-D
	sample $0104, ChoirB, ChoirB		; Bass and Mellotron Choir A-G-D
	sample $0104, ChoirC, ChoirC		; Bass and Mellotron Choir G-D-A
	sample $0104, ChoirD, ChoirD		; Bass and Mellotron Choir A-G-D
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------

vNone =		$00
__venv =	$01

VolEnvs:
	volenv 01, 02, 03, 04, 05, 06, 07, 08
	volenv 09, S301, S302, S303, S304, S305, S306, S307
	volenv S308, S309, 0A, 0B, 0C, 0D, 0E, 0F
	volenv 10, 11, 12, 13, 14, 15, 16, 17
	volenv 18, 19, 1A, 1B, 1C, 1D, 1E, 1F
	volenv 20, 21, 22, 23, 24, 25, 26, 27
	volenv 28, 29
	volenv Kc02, kc04, kc06, Kc05, Kc08, Kc0C
	volenv Ristar02, Ristar07, Ristar10, Ristar18, Ristar1D, DyHe03, DW1, DW2	
VolEnvs_End:
; ---------------------------------------------------------------------------

vd01:		dc.b $00, $00, $00, $08, $08, $08, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28
		dc.b $28, $28, $30, $30, $30, $38, eHold

vd02:		dc.b $00, $10, $20, $30, $40, $7F, eHold

vd03:		dc.b $00, $00, $08, $08, $10, $10, $18, $18
		dc.b $20, $20, $28, $28, $30, $30, $38, $38
		dc.b eHold

vd04:		dc.b $00, $00, $10, $18, $20, $20, $28, $28
		dc.b $28, $30, eHold

vd05:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $08, $08, $08, $08
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $18, $18, $18, $18, $18, $18, $18, $18
		dc.b $20, eHold

vd06:		dc.b $18, $18, $18, $10, $10, $10, $10, $08
		dc.b $08, $08, $00, $00, $00, $00, eHold

vd07:		dc.b $00, $00, $00, $00, $00, $00, $08, $08
		dc.b $08, $08, $08, $10, $10, $10, $10, $10
		dc.b $18, $18, $18, $20, $20, $20, $28, $28
		dc.b $28, $30, $38, eHold

vd08:		dc.b $00, $00, $00, $00, $00, $08, $08, $08
		dc.b $08, $08, $10, $10, $10, $10, $10, $10
		dc.b $18, $18, $18, $18, $18, $20, $20, $20
		dc.b $20, $20, $28, $28, $28, $28, $28, $30
		dc.b $30, $30, $30, $30, $38, $38, $38, eHold

vd09:		dc.b $00, $08, $10, $18, $20, $28, $30, $38
		dc.b $40, $48, $50, $58, $60, $68, $70, $78
		dc.b eHold

vd0E:
vdS301:		dc.b $10, eStop

vd0F:
vdS302:		dc.b $00, $10, $20, $30, $40, $7F, eStop

vdS303:		dc.b $10, $08, $00, $00, $08, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $10, $10
		dc.b $10, $18, $18, $18, $20, $20, $20, $28
		dc.b eHold

vdS304:		dc.b $00, $00, $10, $18, $20, $20, $28, $28
		dc.b $28, $30, $30, eHold

vdS305:		dc.b $18, $00, $08, $08, $08, $10, $18, $20
		dc.b $20, $28, eHold

vdS306:		dc.b $00, $00, $08, $08, $10, $18, $20, $28
		dc.b $28, $30, $40, $38, $38, $30, eHold

vdS307:		dc.b $01, $0C, $03, $0F, $02, $07, $03, $0F, eReset

vdS308:		dc.b $00, $00, $00, $10, $18, $18, $20, $28
		dc.b $30, $38, $40, $48, $50, $58, $60, $7F
		dc.b eStop

vd16:
vdS309:		dc.b $18, $10, $08, $08, $00, $00, $08, $10
		dc.b $18, $20, eHold

vd0A:		dc.b $08, $00, $00, $00, $00, $08, $08, $08
		dc.b $10, $10, $10, $18, $18, $18, $18, $20
		dc.b $20, $20, $28, $28, eHold

vd0B:		dc.b $10, $20, $30, $40, $30, $20, $10, $00
		dc.b $F0, eReset

vd0C:		dc.b $00, $00, $08, $08, $18, $18, $20, $28
		dc.b eStop

vd0D:		dc.b $00, eHold

vd10:		dc.b $08, $08, $08, $00, $00, $00, eHold

vd11:		dc.b $08, $08, $08, $00, $00, $00, eHold

vd12:		dc.b $18, $00, $08, $08, $08, $10, $08, $20
		dc.b $20, $28, eHold

vd13:		dc.b $00, $00, $08, $08, $10, $18, $20, $28
		dc.b $28, $30, $40, $38, $38, $30, eHold

vd14:		dc.b $50, $28, $00, $20, $40, eStop

vd15:		dc.b $00, $00, $00, $10, $18, $18, $20, $28
		dc.b $30, $38, $40, $48, $50, $58, $60, $78
		dc.b eStop

vd17:		dc.b $08, $00, $00, $00, $00, $08, $08, $08
		dc.b $10, $10, $10, $10, $18, $18, $18, $20
		dc.b $20, $20, $28, $28, eHold

vd18:		dc.b $10, $20, $30, $40, $30, $20, $10, $00
		dc.b eReset

vd19:		dc.b $00, $00, $08, $08, $18, $18, $20, $28
		dc.b eStop

vd1A:		dc.b $00, $02, $04, $06, $08, $16, eStop

vd1B:		dc.b $00, $00, $08, $08, $18, $18, $20, $28
		dc.b eStop

vd1C:		dc.b $20, $20, $20, $20, $18, $18, $18, $18
		dc.b $10, $10, $10, $10, $08, $08, $08, $08
		dc.b eStop

vd1D:		dc.b $00, $00, $00, $00, $08, $08, $08, $08
		dc.b $10, $10, $10, $10, $18, $18, $18, $18
		dc.b $20, $20, $20, $20, $28, $28, $28, $28
		dc.b $30, $30, $30, $30, $38, $38, $38, $38
		dc.b $40, $40, $40, $40, $48, $48, $48, $48
		dc.b $50, $50, $50, $50, eHold

vd1E:		dc.b $00, $50, eStop

vd1F:		dc.b $00, $10, $20, eHold

vd20:		dc.b $30, $20, $10, $00, $00, $00, $00, $00
		dc.b $08, $10, $20, $30, eHold

vd21:		dc.b $00, $20, $20, $20, $20, $20, $20, $20
		dc.b $20, $20, $20, $30, $30, $30, $40, $40
		dc.b $50, eStop

vd22:		dc.b $00, $10, $18, $20, $30, $38, eHold

vd23:		dc.b $10, $08, $00, $00, $00, $10, $20, $38
		dc.b eHold

vd24:		dc.b $78, $08, $28, eStop

vd25:		dc.b $40, $30, $10, $18, $20, $28, $30, $38
		dc.b $40, $48, $50, $58, $60, $68, $78, $78
		dc.b $7F, eStop

vd26:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $10, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $18, $18
		dc.b $18, $18, $18, $18, $18, $18, $18, $18
		dc.b $20, $20, $20, $20, $20, $20, $20, $20
		dc.b $20, $20, $28, $28, $28, $28, $28, $28
		dc.b $28, $28, $28, $28, $30, $30, $30, $30
		dc.b $30, $30, $30, $30, $30, $30, $38, $38
		dc.b $38, $38, $38, $38, $38, $38, $38, $38
		dc.b $40, $40, $40, $40, $40, $40, $40, $40
		dc.b $40, $40, $48, $48, $48, $48, $48, $48
		dc.b $48, $48, eStop

vd27:		dc.b $00, $10, $10, $10, $18, $18, $18, $20
		dc.b $20, $20, $28, $28, eStop

vd28:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $08, $08, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $08, $08, $08, $08
		dc.b $10, eHold

vd29:		dc.b $28, $20, $18, $10, $08, $00, eStop

; Knuckles Chaotix 04
vdKc04:
		dc.b $20, $18, $10, $08, $00, $00, $08, $08
		dc.b $10, $10, $10, eHold

; Knuckles Chaotix 06
vdKc06:
		dc.b $00, $00, $00, $08, $08, $08, $08, $08
		dc.b $08, $10, $10, $10, $10, $10, $10, $10
		dc.b $18, $18, $18, $18, $20, $20, $20, $20
		dc.b $28, $28, $28, $30, $30, $30, $38, $40
		dc.b $50, $60, $70, $7F, eStop

; Knuckles Chaotix 08
vdKc08:		dc.b $10, $08, $00, $00, $08, $08, $10, eHold

; Knuckles Chaotix 05
vdKc05: 	dc.b $18, $00, $08, $08, $08, $10, $18, $20
		dc.b $20, $28, eHold

; Ristar 07
vdRistar07:	dc.b $18, $10, $08, $00, $00, $08, $08, $10, eHold

; Knuckles Chaotix 02
vdKc02:		dc.b $00, $00		; continue to volenv below

; Knuckles Chaotix 0C
vdKc0C: 	dc.b $00, $00, $01, $01, $03, $03, $04, $05, eHold

; Ristar 02
vdRistar02:	dc.b $00, $10, $20, $30, $40, $7F, eStop

; Ristar 1D
vdRistar1D:	dc.b $00, $00, $00, $00, $08, $08, $08, $08
		dc.b $08, $10, $10, $18, $18, $20, $20, $20
		dc.b $20, $18, $18, $10, $10, $08, eHold

; Ristar 10
vdRistar10:	dc.b $00, $00, $00, $10, $18, $18, $20, $28
		dc.b $30, $38, $40, $48, $50, $48, $60, $68, eStop

vdRistar18:	dc.b $00, $18, $30, $48, eStop

vdDyHe03:	dc.b $00, $00, $08, $08, $18, $18, $20, $28, eStop


vdDW1:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $10, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $18, $18
		dc.b $18, $18, $18, $18, $18, $18, $18, $18
		dc.b $20, $20, $20, $20, $20, $20, $20, $20
		dc.b $20, $20, $28, $28, $28, $28, $28, $28
		dc.b $28, $28, $28, $28, $30, $30, $30, $30
		dc.b $30, $30, $30, $30, $30, $30, $38, $38
		dc.b $38, $38, $38, $38, $38, $38, $38, $38
		dc.b $40, $40, $40, $40, $40, $40, $40, $40
		dc.b $40, $40, $48, $48, $48, $48, $48, $48
		dc.b $48, $48, eStop

vdDW2:		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $00, $00, $00, $00, $00, $00
		dc.b $00, $00, $08, $08, $08, $08, $08, $08
		dc.b $08, $08, $08, $08, $10, $10, $10, $10
		dc.b $10, $10, $10, $10, $10, $10, $18, $18
		dc.b $18, $18, $18, $18, $18, $18, $18, $18
		dc.b $20, $20, $20, $20, $20, $20, $20, $20
		dc.b $20, $20, $28, $28, $28, $28, $28, $28
		dc.b $28, $28, $28, $28, $30, $30, $30, $30
		dc.b $30, $30, $30, $30, $30, $30, $38, $38
		dc.b $38, $38, $38, $38, $38, $38, $38, $38
		dc.b $40, $40, $40, $40, $40, $40, $40, $40
		dc.b $40, $40, $48, $48, $48, $48, $48, $48
		dc.b $48, $48, eStop		
; ===========================================================================
; ---------------------------------------------------------------------------
; Define volume envelopes and their data
; ---------------------------------------------------------------------------
	even				

mNone =		$00
__menv =	$01

ModEnvs:
	modenv 01, 02, 03, 04, 05, 06, 07, 08
ModEnvs_End:
; ---------------------------------------------------------------------------

	if FEATURE_MODENV
md02:		dc.b  $00

md01:		dc.b  $01, $02, $01, $00,-$01,-$02,-$03,-$04
		dc.b -$03,-$02,-$01, eHold

md03:		dc.b  $00, $00, $00, $00, $13, $26, $39, $4C
		dc.b  $5F, $72, $7F, $72, eHold

md04:		dc.b  $01, $02, $03, $02, $01, $00,-$01,-$02
		dc.b -$03,-$02,-$01, $00, eLoop, $00

md05:		dc.b  $00, $00, $01, $03, $01, $00,-$01,-$03
		dc.b -$01, $00, eLoop, $02

md06:		dc.b  $00, $00, $00, $00, $00, $0A, $14, $1E
		dc.b  $14, $0A, $00,-$0A,-$14,-$1E,-$14,-$0A
		dc.b eLoop, $04

md07:		dc.b  $00, $00, $00, $00, $16, $2C, $42, $2C
		dc.b  $16, $00,-$16,-$2C,-$42,-$2C,-$16
		dc.b eLoop,  $03

md08:		dc.b  $01, $02, $03, $04, $03, $02, $01, $00
		dc.b -$01,-$02,-$03,-$04,-$03,-$02,-$01, $00
		dc.b eLoop, $01
	even
	endif
; ===========================================================================
; ---------------------------------------------------------------------------
; Include music, sound effects and voice bank
; ---------------------------------------------------------------------------

	include "AMPS/Voices.s2a"	; include universal voice bank
	opt ae-				; disable automatic evens
; ---------------------------------------------------------------------------

sfxaddr	incSFX				; include all sfx
musaddr	incMus				; include all music
musend
	even

	if FEATURE_SOUNDTEST
dSoundNames:
;	allnames			; include all sound names in an array (the easy way)
; ---------------------------------------------------------------------------
; Music names
; ---------------------------------------------------------------------------
; Zones:	Act 1,				Act 2,				Act 3,				Boss,					Act 4 (where applicable)
	dc.l	_musnm_BGZ1,		_musnm_BGZ2,		_musnm_BGZ3,		_musnm_BadApplePC98,	_musnm_EHZ
	dc.l	_musnm_Icescape,	_musnm_Icescape2,	_musnm_LunateElf,	_musnm_Cirno
	dc.l	_musnm_MZ,													_musnm_ImmortalSmoke
	dc.l	_musnm_CBicycle,	_musnm_BCA2		
	dc.l	_musnm_Beep,		_musnm_LZ
	dc.l	_musnm_SpaceQueens,	_musnm_SLZ
	dc.l	_musnm_SBZ,			_musnm_FZ
	if DemoMode=0	
	dc.l	_musnm_MCZ2P
	dc.l	_musnm_FBZ1
	endc
; Invincibility
	dc.l	_musnm_Invinc

; Super forms
	dc.l	_musnm_SuperTheme

; Others
	dc.l	_musnm_SpecStag,	_musnm_Drowning,		_musnm_Boss
	dc.l	_musnm_Title,		_musnm_MM8StgSel,	_musnm_ActClear,	_musnm_Emerald,			_musnm_ExtraLife
	dc.l	_musnm_GameOver,	_musnm_Continue,	_musnm_Ending,	_musnm_Credits,	_musnm_Pichuun,	_musnm_Backup, _musnm_SonicMyName


; ---------------------------------------------------------------------------
; Sound names
; ---------------------------------------------------------------------------
	dc.l	_sndnm_RingRight, _sndnm_RingLeft, _sndnm_RingLoss
	dc.l	_sndnm_Splash, _sndnm_Break, _sndnm_Jump, _sndnm_Roll
	dc.l	_sndnm_Skid, _sndnm_Bubble, _sndnm_Drown, _sndnm_SpikeHit
	dc.l	_sndnm_Death, _sndnm_AirDing, _sndnm_Register, _sndnm_Bonus
	dc.l	_sndnm_Shield, _sndnm_Dash, _sndnm_BossHit, _sndnm_Switch
	dc.l	_sndnm_Signpost, _sndnm_Lamppost, _sndnm_BigRing, _sndnm_Bumper
	dc.l	_sndnm_Spring, _sndnm_Collapse, _sndnm_Smash, _sndnm_Basaran
	dc.l	_sndnm_BuzzExplode, _sndnm_Explode, _sndnm_Electricity
	dc.l	_sndnm_Flame, _sndnm_LavaBall, _sndnm_SpikeMove, _sndnm_Rumble
	dc.l	_sndnm_Door, _sndnm_Stomp, _sndnm_Chain, _sndnm_Saw, _sndnm_Lava, _sndnm_Checkpoint
	dc.l	_sndnm_EnterSS, _sndnm_Goal, _sndnm_ActionBlock, _sndnm_Diamonds
	dc.l	_sndnm_Continue, _sndnm_Spindash, _sndnm_DoubleJump, _sndnm_DropDash
	dc.l	_sndnm_DropCancel, _sndnm_Fly, _sndnm_FlyTired, _sndnm_Grab
	dc.l	_sndnm_GlideLand, _sndnm_GroundSlide, _sndnm_CDJump, _sndnm_CDSkid
	dc.l	_sndnm_Charge, _sndnm_ChargeRelease, _sndnm_ChargeStop
	dc.l	_sndnm_BubbleAttack, _sndnm_BubbleShield, _sndnm_ElectricAttack, _sndnm_ElectricShield
	dc.l	_sndnm_FireAttack, _sndnm_FireKick, _sndnm_FireShield, _sndnm_GoldShield, _sndnm_PogoSpring
	dc.l	_sndnm_Transform, _sndnm_Projectile, _sndnm_ArrowStick, _sndnm_ProjectileReflct
	dc.l	_sndnm_SpringShoes, _sndnm_BallDeflect, _sndnm_DoorOpen, _sndnm_Error
	dc.l	_sndnm_SpindashS2, _sndnm_TubeLauncher, _sndnm_InstaAttack, _sndnm_Piko, _sndnm_Balloon
	dc.l	_sndnm_MagicBlock, _sndnm_SpringBoard, _sndnm_10Rings, _sndnm_25Rings, _sndnm_UnknownRevving
	dc.l	_sndnm_AirRoll, _sndnm_GlassShatter,  _sndnm_ScoreTally, _sndnm_Choose, _sndnm_Select, _sndnm_Cancel, _sndnm_StartGame
	dc.l	_sndnm_Warning, _sndnm_Countdown, _sndnm_PushBlock, _sndnm_Waterfall, _sndnm_UnkA2, _sndnm_UnkAB, _sndnm_UnkB8

; ---------------------------------------------------------------------------
; Name definitions
; ---------------------------------------------------------------------------
; Max 27 characters.	dtext 1, "---------------------------"
; Blossom Gardens
_musnm_BGZ1:			dtext 1, "Blossom Gardens Zone 1"
_musnm_BGZ2:			dtext 1, "Blossom Gardens Zone 2"
_musnm_BGZ3:			dtext 1, "Blossom Gardens Zone 3"
_musnm_BadApplePC98:	dtext 1, "Bad Apple - PC-98 ver"
_musnm_EHZ:				dtext 1, "Emerald Hill Zone"

; Melting Heights
_musnm_Icescape:		dtext 1, "Melting Heights Zone 1"
_musnm_Icescape2:		dtext 1, "Melting Heights Zone 2"
_musnm_LunateElf:		dtext 1, "Lunate Elf"
_musnm_Cirno:			dtext 1, "Beloved Tomboyish Girl"

; Ashen Temple
_musnm_MZ:				dtext 1, "Marble Zone"
_musnm_ImmortalSmoke:	dtext 1, "Immortal Smoke"

; Bumper City
_musnm_CBicycle:	dtext 1, "Chinese Bicycle"
_musnm_BCA2:		dtext 1, "Bumper City Act 2"

; Sunken Relic
_musnm_Beep:			dtext 1, "Sunken Relic Zone 1"
_musnm_FieldMotavia:	dtext 1, "Field Motavia"
_musnm_LZ:				dtext 1, "Labyrinth Zone"

; Hoshi Metro
_musnm_SpaceQueens:		dtext 1, "Space Queens"
_musnm_SLZ:				dtext 1, "Star Light Zone"

; Badnik Blitz
_musnm_SBZ:				dtext 1, "Scrap Brain Zone"
_musnm_FZ:				dtext 1, "Final Zone"

; Hidden Palace
_musnm_MCZ2P:			dtext 1, "Mystic Cave 2-Player"

; The Magnet
_musnm_FBZ1:		dtext 1, "Flying Battery Zone Act 1"

; Invincibility
_musnm_Invinc:			dtext 1, "Invincibility"

; Super forms
_musnm_SuperTheme:			dtext 1, "Super Theme"

; Other themes
_musnm_SpecStag:		dtext 1, "Special Stage"
_musnm_Drowning:		dtext 1, "Drowning"
_musnm_Boss:			dtext 1, "Boss"
_musnm_Title:			dtext 1, "Title Screen"
_musnm_MM8StgSel:		dtext 1, "Mega Man 8 Stage Select"
_musnm_ActClear:		dtext 1, "Act Clear"
_musnm_Emerald:			dtext 1, "Krizonus Pearl Collected"
_musnm_ExtraLife:		dtext 1, "Extra Life"
_musnm_GameOver:		dtext 1, "Game Over"
_musnm_Continue:		dtext 1, "Continue Screen"
_musnm_Ending:			dtext 1, "Ending"
_musnm_Credits:			dtext 1, "Credits"
_musnm_Pichuun:			dtext 1, "Pichuun"
_musnm_Backup:			dtext 1, "Backup"
_musnm_SonicMyName:			dtext 1, "Sonics My Name"

; Max 27 characters.	dtext 0, "---------------------------"
_sndnm_RingRight:		dtext 0, "Ring - Right Channel"
_sndnm_RingLeft:		dtext 0, "Ring - Left Channel"
_sndnm_RingLoss:		dtext 0, "Ring Loss"
_sndnm_Splash:			dtext 0, "Water Splash"
_sndnm_Break:			dtext 0, "Break"
_sndnm_Jump:			dtext 0, "Jump"
_sndnm_Roll:			dtext 0, "Roll"
_sndnm_Skid:			dtext 0, "Skid"
_sndnm_Bubble:			dtext 0, "Bubble"
_sndnm_Drown:			dtext 0, "Drown"
_sndnm_SpikeHit:		dtext 0, "Spike Hit"
_sndnm_Death:			dtext 0, "Death"
_sndnm_AirDing:			dtext 0, "Thinking about air"
_sndnm_Register:		dtext 0, "Cash Register"
_sndnm_Bonus:			dtext 0, "Hidden Bonus"
_sndnm_Shield:			dtext 0, "Normal Shield"
_sndnm_Dash:			dtext 0, "Dash"
_sndnm_BossHit:			dtext 0, "Boss Hit"
_sndnm_Switch:			dtext 0, "Switch"
_sndnm_Signpost:		dtext 0, "Signpost"
_sndnm_Lamppost:		dtext 0, "Checkpoint"
_sndnm_BigRing:			dtext 0, "Big Ring"
_sndnm_Bumper:			dtext 0, "Bumper Bounce"
_sndnm_Spring:			dtext 0, "Spring Bounce"
_sndnm_Collapse:		dtext 0, "Collapsing Platform"
_sndnm_Smash:			dtext 0, "Smash"
_sndnm_Basaran:			dtext 0, "Basaran Wing Flap"
_sndnm_BuzzExplode:		dtext 0, "Buzz Bomber Explosion"
_sndnm_Explode:			dtext 0, "Explosion"
_sndnm_Electricity:		dtext 0, "Electricity Arcing"
_sndnm_Flame:			dtext 0, "Flame"
_sndnm_LavaBall:		dtext 0, "Lava Ball"
_sndnm_SpikeMove:		dtext 0, "Spike Move"
_sndnm_Rumble:			dtext 0, "Rumbling"
_sndnm_Door:			dtext 0, "Door"
_sndnm_Stomp:			dtext 0, "Stomp"
_sndnm_Chain:			dtext 0, "Chain"
_sndnm_Saw:				dtext 0, "Saw"
_sndnm_Lava:			dtext 0, "Lava"
_sndnm_Checkpoint:		dtext 0, "Checkpoint Lit"
_sndnm_EnterSS:			dtext 0, "Special Stage Entry"
_sndnm_Goal:			dtext 0, "Special Stage Goal"
_sndnm_ActionBlock:		dtext 0, "Special Stage Block Action"
_sndnm_Diamonds:		dtext 0, "Special Stage Diamond"
_sndnm_Continue:		dtext 0, "Got Continue"
_sndnm_Spindash:		dtext 0, "Spin Dash Charge"
_sndnm_DoubleJump:		dtext 0, "Double Jump"
_sndnm_DropDash:		dtext 0, "Drop Dash Charge"
_sndnm_DropCancel:		dtext 0, "Drop Dash Cancel"
_sndnm_Fly:				dtext 0, "Flight"
_sndnm_FlyTired:		dtext 0, "Tired Flight"
_sndnm_Grab:			dtext 0, "Grab"
_sndnm_GlideLand:		dtext 0, "Heavy Landing"
_sndnm_GroundSlide:		dtext 0, "Sliding on Ground"
_sndnm_CDJump:			dtext 0, "Sonic CD Jump"
_sndnm_CDSkid:			dtext 0, "Sonic CD Skid"
_sndnm_Charge:			dtext 0, "Peelout Charge"
_sndnm_ChargeRelease:	dtext 0, "Peelout Release"
_sndnm_ChargeStop:		dtext 0, "Peelout Cancel"
_sndnm_BubbleAttack:	dtext 0, "Bubble Shield Attack"
_sndnm_BubbleShield:	dtext 0, "Bubble Shield"
_sndnm_ElectricAttack:	dtext 0, "Lightning Shield Attack"
_sndnm_ElectricShield:	dtext 0, "Lightning Shield"
_sndnm_FireAttack:		dtext 0, "Fire Shield Attack"
_sndnm_FireKick:		dtext 0, "Fire Shield Kick"
_sndnm_FireShield:		dtext 0, "Fire Shield"
_sndnm_GoldShield:		dtext 0, "Gold Shield"
_sndnm_PogoSpring:		dtext 0, "Pogo Spring"
_sndnm_Transform:		dtext 0, "Super Transformation"
_sndnm_Projectile:		dtext 0, "Projectile"
_sndnm_ArrowStick:		dtext 0, "Arrow Stab"
_sndnm_ProjectileReflct:dtext 0, "Projectile Reflect"
_sndnm_SpringShoes:		dtext 0, "Light Spring Bounce"
_sndnm_BallDeflect:		dtext 0, "Ball Deflect"
_sndnm_DoorOpen:		dtext 0, "Door Opening"
_sndnm_Error:			dtext 0, "Error"
_sndnm_SpindashS2:		dtext 0, "Sonic 2 Spin Dash"
_sndnm_TubeLauncher:	dtext 0, "Flower Cannon Launch"
_sndnm_InstaAttack:		dtext 0, "Insta-Shield - Twin Spin"
_sndnm_Piko:			dtext 0, "Piko-Piko Hammer"
_sndnm_Balloon:			dtext 0, "Lantern Pop"
_sndnm_MagicBlock:		dtext 0, "Yoku Block Appear"
_sndnm_SpringBoard:		dtext 0, "Springboard"
_sndnm_10Rings:			dtext 0, "Super Ring Monitor"
_sndnm_25Rings:			dtext 0, "Silver Ring Monitor"
_sndnm_UnknownRevving:	dtext 0, "Moto Bug Speed Up"
_sndnm_AirRoll:			dtext 0, "Air Roll"
_sndnm_GlassShatter:	dtext 0, "Glass Shattering"
_sndnm_ScoreTally:		dtext 0, "Score Tallying"
_sndnm_Choose:			dtext 0, "Menu - Movement"
_sndnm_Select:			dtext 0, "Menu - Option Selected"
_sndnm_Cancel:			dtext 0, "Menu - Cancel"
_sndnm_StartGame:		dtext 0, "Menu - Start Game"
_sndnm_Warning:			dtext 0, "CD Drowning Warning"
_sndnm_Countdown:			dtext 0, "Drowning Countdown"
_sndnm_PushBlock:		dtext 0, "Pushing Block"
_sndnm_Waterfall:		dtext 0, "Waterfall"
_sndnm_UnkA2:			dtext 0, "Unknown Sound - A2"
_sndnm_UnkAB:			dtext 0, "Unknown Sound - AB"
_sndnm_UnkB8:			dtext 0, "Unknown Sound - B8"
	endc
; ===========================================================================
; ---------------------------------------------------------------------------
; Include samples and filters
; ---------------------------------------------------------------------------

		align	$8000		; must be aligned to bank. By the way, these are also used in Z80.asm. Be sure to check it out
fLog:		incbin "AMPS/filters/Logarithmic.dat"	; logarithmic filter (no filter)
;fLinear:	incbin "AMPS/filters/Linear.dat"	; linear filter (no filter)	; I tried this, and it sounds the exact damn same.

dacaddr		dcb.b Z80E_Read*(MaxPitch/$100),$00
SWF_Stop:	dcb.b $8000-(2*Z80E_Read*(MaxPitch/$100)),$80
SWFR_Stop:	dcb.b Z80E_Read*(MaxPitch/$100),$00
; ---------------------------------------------------------------------------
	incSWF	Snare, Timpani, Kick, Bongo, SnareS1
	incSWF	SnareS3, Tom, KickS3, KickSnare, CrashCymbal, RideCymbal, MetalBlock, MutedWood, Wood
	incSWF	CowBell, Clap, ElecTom, HeavyTom, TimpaniS3, LooseSnare, VocalClick, VocalKick, Pichuun
	incSWF	VocalSnare, JamHit, JamHitShort, GlassKick, GlassSmash, DanceSnare, DanceKick, Go
	incSWF	ComeOn, HeavySnare, LowKick, LowKickShort, Whoo, SnareGo, PowerTom, F97DL, TomS2
	incSWF	Congo, CrashHit, EchoClap, EchoClapS3, KickUh, ElecKick, SynthHit, ReverseCrash
	incSWF	SynthHit3, HeavyKick, WhooCrash, SideStick, KickOh, DHSlap, OrchHit, Scratch
	incSWF	ClosedHiHat, OpenHiHat, PedalHiHat, MM8Kick, MM8Snare
	incSWF	kcKick, kcLowKick, kcTom, kcSnare, kcCrashCymbal, kcClap, kcCowbell
	incSWF	SplashCymbal, SlowCongo, Timbale, Clink, HighCymbal, Weird, Bang, Bing, Gong, SonicMyName
	incSWF	Choir1, Choir2, Choir3, Choir4, Choir5, Choir6, Choir7, Choir8, Choir9, ChoirA, ChoirB, ChoirC, ChoirD
	even
	opt ae+				; enable automatic evens
	list				; continue source listing
; ---------------------------------------------------------------------------
