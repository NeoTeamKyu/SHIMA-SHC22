; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

DEBUG = 0 ; Debug compile flag. Enables a few safety checks that decrease performance 

Z80_Space =	$80C			; The amount of space reserved for Z80 driver. The compressor tool may ask you to increase the size...

; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:		equ $C00008

psg_input:		equ $C00011

; Z80 addresses
z80_ram:		equ $A00000	; start of Z80 RAM
z80_ram_end:		equ $A02000	; end of non-reserved Z80 RAM
z80_version:		equ $A10001
z80_port_1_data:	equ $A10002
z80_port_1_control:	equ $A10008
z80_port_2_control:	equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:	equ $A11100
z80_reset:		equ $A11200
ym2612_a0:		equ $A04000
ym2612_d0:		equ $A04001
ym2612_a1:		equ $A04002
ym2612_d1:		equ $A04003

security_addr:		equ $A14000

; VRAM data
vram_fg:	equ $C000	; foreground namespace
vram_bg:	equ $E000	; background namespace
vram_bg2:	equ $8000	; background namespace
vram_sonic:	equ $F000	; Sonic graphics
vram_sprites:	equ $F800	; sprite table
vram_hscroll:	equ $FC00	; horizontal scroll table

; Game modes
id_Sega:	equ ptr_GM_Sega-GameModeArray	; $00
id_Title:	equ ptr_GM_Title-GameModeArray	; $04
id_Demo:	equ ptr_GM_Demo-GameModeArray	; $08
id_Level:	equ ptr_GM_Level-GameModeArray	; $0C
id_Special:	equ ptr_GM_Special-GameModeArray; $10
id_Continue:equ ptr_GM_Cont-GameModeArray	; $14
id_Ending:	equ ptr_GM_Ending-GameModeArray	; $18
id_Credits:	equ ptr_GM_Credits-GameModeArray; $1C
id_LevelSelect: equ ptr_GM_LevelSelect-GameModeArray
id_SoundTest: equ ptr_GM_SoundTest-GameModeArray
	if DemoMode=1
id_EndOfDemoScreen: equ ptr_GM_EODSplash-GameModeArray
	endc

; Levels
id_BGZ:		equ 0
id_LZ:		equ 1
id_MZ:		equ 2
id_SLZ:		equ 3
id_SYZ:		equ 4
id_SBZ:		equ 5
id_MHZ:		equ 6
id_HPZ:		equ 7
id_TMZ:		equ 8
id_EndZ:	equ 9
id_SS:		equ $A ; 10

; Colours
cBlack:		equ $000		; colour black
cWhite:		equ $EEE		; colour white
cBlue:		equ $E00		; colour blue
cGreen:		equ $0E0		; colour green
cRed:		equ $00E		; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
; NOTE: if you're super into S2 hacking, "bitX" is the same as "button_X", while "btnX" is the same as "button_X_mask".
btnStart:	equ %10000000 ; Start button	($80)
btnA:		equ %01000000 ; A		   ($40)
btnC:		equ %00100000 ; C		   ($20)
btnB:		equ %00010000 ; B		   ($10)
btnR:		equ %00001000 ; Right	   ($08)
btnL:		equ %00000100 ; Left		($04)
btnDn:		equ %00000010 ; Down		($02)
btnUp:		equ %00000001 ; Up		  ($01)
btnDir:		equ %00001111 ; Any direction   ($0F)
btnABC:		equ %01110000 ; A, B or C	   ($70)
btnBC:		equ %00110000 ; B or C	  ($30)
btnAB:		equ %01010000 ; A or B	  ($50)
btnAC:		equ %01100000 ; A or C	  ($50)
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

; v_miscOptions bitfield
		rsreset
bitMusic:   rs.b 1  ; 0, music
bitSFX:     rs.b 1  ; 1, sounds
bitLives:   rs.b 1  ; 2, lives
bitGodMode: rs.b 1  ; 3, god mode
bitSupChall:rs.b 1  ; 4, super challenge

;-------------------------------------------------------------------------------
; Regular object SSTs. These are basically used by everything.
;-------------------------------------------------------------------------------
; Object variables
obID:		equ 0	; The object's ID. (Hopefully not numeric... that'd cause problems later.)
obRender:	equ 1	; bitfield for x/y flip, display mode
obGfx:		equ 2	; palette line & VRAM setting (2 bytes)
obMap:		equ 4	; mappings address (4 bytes)
obX:		equ 8	; x-axis position (2-4 bytes)
obChild_dx:	equ $A
obChild_dy:	equ $B
obY:		equ $C	; y-axis position (2-4 bytes)
obSubY:		equ $E	; Lower word of the y-axis position
obVelX:		equ $10	; x-axis velocity (2 bytes)
obVelY:		equ $12	; y-axis velocity (2 bytes)
obRespawnNo:	equ $14	; respawn list index number (2 bytes)
obHeight:	equ $16	; height/2
obWidth:	equ $17	; width/2
obPriority:	equ $18	; sprite stack priority -- 0 is front
obFrame:	equ $1A	; current frame displayed
obAniFrame:	equ $1B	; current frame in animation script
obAnim:		equ $1C	; current animation
obNextAni:	equ $1D	; next animation
obTimeFrame:	equ $1E	; time to next frame
obDelayAni:	equ $1F	; time to delay animation
obColType:	equ $20	; collision response type
obInertia:	equ $20	; potential speed (2 bytes)
obColProp:	equ $21	; collision extra property
obStatus:	equ $22	; orientation or mode
obActWid:	equ $23	; action width
obRoutine:	equ $24	; routine number
ob2ndRout:	equ $25	; secondary routine number
obAngle:	equ $26	; angle
obSubtype:	equ $28	; object subtype
obFinalEasingPos: equ $2A
obShieldDeflect:	equ $2B

ChildCollsionFlags = $29
;---------------------------------------------------------------------------
; SSTs only used by players.
;---------------------------------------------------------------------------
; It seems everything between $29 and $3D are free(?) for regular use in objects.


; Object variables used by the player
obDoubleJump:	equ $2E	; Double jump flag.
obDoubleJump_property:	equ $2F ; Double jump property, used for timers and counters mostly, like in the drop dash or Tails' flight
obParentNextAni:	equ $30	; Used for Tails's tails.

flashtime:	equ $30	; time between flashes after getting hit
invtime:	equ $31	; time left for invincibility
shoetime:	equ $32	; time left for speed shoes
obInteract:	 equ $34 ; 2 bytes

obNextTilt:	equ $36
obTilt:		equ $37
obStickToConvex: equ $38
obSpindash: equ $39
obSpindashCounter:	equ $3A
obJumping:	equ	$3C
; Used to be labelled "unused", but it's been labelled since in s1disasm
; EDIT: NEVER FUCKING MIND, WE DON'T EVEN USE IT ANYMORE.
;obStandOnObject:	equ $3D ; Object the player is standing on.
obPinball:	equ obSpindash
;------------------------------------------------------------------------------
; Child object SSTs.
;------------------------------------------------------------------------------
obParent:	equ $3A	; word ; the original
obParent3:	equ $3C ; word ; what the fuck
obParent2:	equ $3E	; word ; Why the S3K disassembly calls the last one parent2 is beyond me.
obPointer:	equ $30	; ; 4 bytes for saved stuff
; Object variables (Sonic 2 disassembly nomenclature)
;---------------------------------------------------------------------------
; SSTs used by smashable objects
;---------------------------------------------------------------------------
obsmashGrav:   equ obRespawnNo ; gravitation of smashed shard (2 bytes)

;----------------------------------------------------------------
;  ssts that are busy with things that they cannot be used in a custom way
; tho x and y vel can be used in a custom way if you are not using SpeeToPos or object fall
; idk about inertia  and x_sub build sprites doesnt use it anymore but you can use it in a custom way ig
;-------------------------------------------------------------
id:		equ obID
render_flags:	equ obRender	; bit feild that tells the game what form of sprite building for an object (4 is normal,2 is world cordnate ,6 is subsprites and multy draw)
art_tile:	equ obGfx	; palette line & VRAM setting (2 bytes)
mappings:	equ obMap	; mappings address (4 bytes)
x_pos:		equ obX	; x-axis position (2-4 bytes)
x_sub:	  equ obChild_dx
y_sub:		equ obChild_dy
y_pos:		equ obY	; y-axis position (2-4 bytes)
x_vel:		equ obVelX	; x-axis velocity (2 bytes)
y_vel:		equ obVelY	; y-axis velocity (2 bytes)
inertia:	equ obInertia
y_radius:	equ obHeight	; height/2
x_radius:	equ obWidth	; width/2
priority:	equ obPriority	; sprite stack priority -- 0 is front
width_pixels:	equ obActWid	; action width
;----------------------------------------------------------------------------
; SSts that can be used however on whatever when you know what you are doing in the right time
; example angle is a byte but can be used as a word in EggManRotatingThings
;-----------------------------------------------------------------------------
mapping_frame:	equ obFrame	; current frame displayed ; pretty sure from here and byte 1d is unused if no  animation
anim_frame:	equ obAniFrame	; current frame in animation script ; if an object doesnt animate at all 1b,1c,1d ,1e are unused
anim:		equ obAnim	; current animation
next_anim:	equ obNextAni	; next animation
anim_frame_duration: equ obTimeFrame ; time to next frame
collision_flags: equ obColType ; collision response type  i dont think you can customize these
collision_property: equ obColProp ; collision extra property
status:		equ obStatus	; orientation or mode
respawn_index:	equ obRespawnNo	; respawn list index number ; if the object doesnt remember state this is unused
routine:	equ obRoutine	; routine number
routine_secondary: equ ob2ndRout ; secondary routine number   ; if an object doesnt use 2 routine bytes this is unused
angle:		equ obAngle	; angle
subtype:	equ obSubtype	; object subtype  ; if an object doesnt use subtypes in level layout or code this is unsed

parent:	equ obParent	; word ; the original
parent3:	equ obParent3 ; word ; what the fuck
parent2:	equ obParent2	; word ; Why the S3K disassembly calls the last one parent2 is beyond me.
;-----------------------------------------------------------------------------------------
; ssts that are mostly used by players
;-----------------------------------------------------------------------------------------
double_jump_flag:	equ obDoubleJump
double_jump_property:	equ obDoubleJump_property
TailsTails_parent_next_anim: equ obParentNextAni
next_tilt:  equ obNextTilt
tilt:	   equ obTilt
stick_to_convex: equ obStickToConvex
spindash_flag: equ obSpindash
pinball_mode: equ obPinball
spindash_counter: equ obSpindashCounter
jumping =	obJumping
interact:	equ obInteract
move_lock:	equ $3E	; Remove this later.
;---------------------------------------------------------------------------------
; lava gaming objs varables
;---------------------------------------------------------------------------------

WaitObjectVar:   Equ $2E

WaitObjectVar2:   Equ $38   ; is usually skipped in every code (when its negative) ,and it branches over repeated codes when its set to postive values (used by dinobot to avoid getting stuck on shooting state)
WaitObjectVar3:   Equ $3A   ; used for like an extra time obj (for spawning stufff)
SData_parentSt:   Equ $24
Pointer:   equ  obPointer ;pointer varable ( points to code and skips some code) replacement for both routine 1 and routine 2
SavedPointer:	equ $34  ; used to restore code adresses when  WaitObjectVar is negative or 0
Pointer2:  equ  $3C ; used by 1 routine with tulipon ; and gamemodes im making

; various child sprite-related things
mainspr_mapframe	= $B
mainspr_width	= $E
mainspr_childsprites	 = $F	; amount of child sprites
mainspr_height	= $14
sub2_x_pos	= $10	;x_vel
sub2_y_pos	= $12	;y_vel
sub2_mapframe	= $15
sub3_x_pos	= $16	;y_radius
sub3_y_pos	= $18	;priority
sub3_mapframe	= $1B	;anim_frame
sub4_x_pos	= $1C	;anim
sub4_y_pos	= $1E	;anim_frame_duration
sub4_mapframe	= $21	;collision_property
sub5_x_pos	= $22	;status
sub5_y_pos	= $24	;routine
sub5_mapframe	= $27
sub6_x_pos	= $28	;subtype
sub6_y_pos	= $2A
sub6_mapframe	= $2D
sub7_x_pos	= $2E
sub7_y_pos	= $30
sub7_mapframe	= $33
sub8_x_pos	= $34
sub8_y_pos	= $36
sub8_mapframe	= $39
sub9_x_pos	= $3A
sub9_y_pos	= $3C
sub9_mapframe	= $3F
next_subspr	   = $6

; FUCK
objoff_34 = $34
objoff_36 = $36

; Animation flags
afEnd:		equ $FF	; return to beginning of animation
afBack:		equ $FE	; go back (specified number) bytes
afChange:	equ $FD	; run specified animation
afRoutine:	equ $FC	; increment routine counter
afReset:	equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

; Character IDs.
	rsreset
charID_Sonic:		rs.b	1
charID_Tails:		rs.b	1
charID_Knuckles:	rs.b	1
charID_Kyuko:		rs.b	1
charID_Metal:		rs.b	1
charID_Mighty:		rs.b	1
charID_Amy:			rs.b	1
charID_Legacy:		rs.b	1

charid_Mighity 	= 	charid_Mighty

; BGZ VRAM Management
		rsset 0
vramBGZ:		rs.b $322
vramBlockBGZ:	rs.b $36
vramFlapBGZ:	rs.b 8
vramSprBrdBGZ:	rs.b $C
vramCannonBGZ:	rs.b 19	; Now has DPLCs.
vramBubblesBGZ:	rs.b $2A
vramExpLanBGZ:	rs.b $1A
vramGameroidBGZ:rs.b 21
vramKoiBGZ:		rs.b $20
vramWFallBGZ =	$3F8
 if __rs>vram_bg2/$20
		largeVRamBGZBG: equ __rs - vram_bg2/$20
		inform 3,"The BGZ VRAM arrangement conflicts with the underwater background by $\$largeVRamBGZBG tiles."
	endif
		rsset vram_bg2/$20
vramPlaneBG2	       rs.b $80
vramMotobugBGZ:	rs.b $20
vramMosquiBGZ:	rs.b $24
vramStatueBGZ:	rs.b 47
vramLantenBGZ:  rs.b 7
vramBubbleGen:  rs.b $C
vramWtrSurBGZ:  rs.b $10
vramSeaweedBGZ: rs.b 4
vramPetalsBGZ:	rs.b 4
 if __rs>($528)
		largeVRamBGZ: equ __rs - vramSpringBGZ
		inform 3,"The BGZ VRAM conflicts with the start of global VRAM by $\$largeVRamBGZ tiles."
	endif

			  rsset 0
vramLBGZ:             rs.b $296
vramLedgeLBGZ:        rs.b $6E
			  rsset $358
vramStalkLBGZ:        rs.b 4
vramAniArtLBGZ:       rs.b $24
vramPlatLBGZ:         rs.b $30
vramSwingLBGZ:        rs.b $E
vramBridgeLBGZ:       rs.b $A
vramBallLBGZ:         rs.b $26
vramRockLBGZ:         rs.b $18
vramCrabmeatLBGZ:     rs.b $40
vramBuzzLBGZ:         rs.b $32
vramChopperLBGZ:      rs.b $20
vramNewtronLBGZ:      rs.b $55
vramMotobugLBGZ:      rs.b $20
vramSmaWallLBGZ:      rs.b $C
 if __rs>($528)
		largeVRamBGZ: equ __rs - vramSpringBGZ
		inform 3,"The BGZ VRAM conflicts with the start of global VRAM by $\$largeVRamBGZ tiles."
	endif

			  rsset 0
vramMHZ:             rs.b $267
vramFireMHZ:         rs.b $2C
vramBubblesMHZ:      rs.b $2A
vramDecorMHZ:        rs.b $14
			  rsset $2EA
vramSnowrexMHZ:      rs.b $48
vramTuliponMHZ:      rs.b $1A
vramBlocksMHZ:       rs.b $20
vramSmaWallMHZ:      rs.b $C
vramSnowMHZ:         rs.b 6
 if __rs>($528)
		largeVRamBGZ: equ __rs - vramSpringBGZ
		inform 3,"The BGZ VRAM conflicts with the start of global VRAM by $\$largeVRamBGZ tiles."
	endif

			  rsset ($528)
; Global VRAM Management
vramSpringBGZ:       rs.b $14
vramAnimal1:         rs.b $12
vramAnimal2:         rs.b $12
vramExplode:         rs.b $60
vramBanner =		 vramExplode+4 ; $1C
vramTitleCard =		 vramBanner+$1C ; $80
vramMonitors:        rs.b $40
 if __rs>vram_fg/$20
		largeVRamFG: equ __rs - vram_fg/$20
		inform 3,"The VRAM conflicts with the foreground tilemap by $\$largeVRamFG tiles."
	endif
		rsset vram_fg/$20
vramPlaneFG:	     rs.b $80
vramDSpringBGZ:      rs.b $17
vramShield:          rs.b $29
vramLamp:            rs.b $A
vramHUD:             rs.b $22
vramPoints:          rs.b 5
vramSpikesBGZ:       rs.b 8
vramDrownCount:      rs.b 6
 if __rs>vram_bg/$20
		largeVRamBG: equ __rs - vram_bg/$20
		inform 3,"The VRAM conflicts with the background tilemap by $\$largeVRamBG tiles."
	endif
		rsset vram_bg/$20
vramPlaneBG:	       rs.b $80
vramCharacter:       rs.b $17
vramAbbey:           rs.b 6
vramDust:            rs.b $11 ; I think this and the ring are like, 1 tile apart at most. Crazy.
vramRing:            rs.b $E
vramHearts:          rs.b 4
 if __rs>($7C0)
		largeVRam: equ __rs - $7C0
		inform 3,"The VRAM conflicts with the end of VRAM by $\$largeVRam tiles."
	endif

vramGameOver:        equ $55E
