; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:

ptr_PLC_Main:		dc.w PLC_Main-ArtLoadCues
ptr_PLC_Main2:		dc.w PLC_Main2-ArtLoadCues
ptr_PLC_Explode:	dc.w PLC_Explode-ArtLoadCues
ptr_PLC_GameOver:	dc.w PLC_GameOver-ArtLoadCues
PLC_Levels:
ptr_PLC_BGZ:		dc.w PLC_BGZ-ArtLoadCues
ptr_PLC_BGZ2:		dc.w PLC_BGZ2-ArtLoadCues
ptr_PLC_LZ:		dc.w PLC_LZ-ArtLoadCues
ptr_PLC_LZ2:		dc.w PLC_LZ2-ArtLoadCues
ptr_PLC_MZ:		dc.w PLC_MZ-ArtLoadCues
ptr_PLC_MZ2:		dc.w PLC_MZ2-ArtLoadCues
ptr_PLC_SLZ:		dc.w PLC_SLZ-ArtLoadCues
ptr_PLC_SLZ2:		dc.w PLC_SLZ2-ArtLoadCues
ptr_PLC_SYZ:		dc.w PLC_SYZ-ArtLoadCues
ptr_PLC_SYZ2:		dc.w PLC_SYZ2-ArtLoadCues
ptr_PLC_SBZ:		dc.w PLC_SBZ-ArtLoadCues
ptr_PLC_SBZ2:		dc.w PLC_SBZ2-ArtLoadCues
ptr_PLC_MHZ:		dc.w PLC_MHZ-ArtLoadCues
ptr_PLC_MHZ2:		dc.w PLC_MHZ2-ArtLoadCues
ptr_PLC_HPZ:		dc.w PLC_HPZ-ArtLoadCues
ptr_PLC_HPZ2:		dc.w PLC_HPZ2-ArtLoadCues
ptr_PLC_TMZ:		dc.w PLC_TMZ-ArtLoadCues
ptr_PLC_TMZ2:		dc.w PLC_TMZ2-ArtLoadCues
			zonewarning PLC_Levels,4
ptr_PLC_LBGZ:		dc.w PLC_LBGZ-ArtLoadCues
ptr_PLC_LBGZ2:		dc.w PLC_LBGZ2-ArtLoadCues
ptr_PLC_TitleCard:	dc.w PLC_TitleCard-ArtLoadCues
ptr_PLC_Boss:		dc.w PLC_Boss-ArtLoadCues
ptr_PLC_SLZBoss:	dc.w PLC_SLZBoss-ArtLoadCues
ptr_PLC_Capsule:	dc.w PLC_Capsule-ArtLoadCues
ptr_PLC_LevelEnd:	dc.w PLC_LevelEnd-ArtLoadCues
ptr_PLC_SpecialStage:	dc.w PLC_SpecialStage-ArtLoadCues
PLC_Animals:
ptr_PLC_BGZAnimals:	dc.w PLC_BGZAnimals-ArtLoadCues
ptr_PLC_LZAnimals:	dc.w PLC_LZAnimals-ArtLoadCues
ptr_PLC_MZAnimals:	dc.w PLC_MZAnimals-ArtLoadCues
ptr_PLC_SLZAnimals:	dc.w PLC_SLZAnimals-ArtLoadCues
ptr_PLC_SYZAnimals:	dc.w PLC_SYZAnimals-ArtLoadCues
ptr_PLC_SBZAnimals:	dc.w PLC_SBZAnimals-ArtLoadCues
ptr_PLC_MHZAnimals: dc.w PLC_MHZAnimals-ArtLoadCues
ptr_PLC_HPZAnimals: dc.w PLC_HPZAnimals-ArtLoadCues
ptr_PLC_TMZAnimals: dc.w PLC_TMZAnimals-ArtLoadCues
			zonewarning PLC_Animals,2
ptr_PLC_GHZAnimals:	dc.w PLC_GHZAnimals-ArtLoadCues
ptr_PLC_SSResult:	dc.w PLC_SSResult-ArtLoadCues
ptr_PLC_Ending:		dc.w PLC_Ending-ArtLoadCues
ptr_PLC_TryAgain:	dc.w PLC_TryAgain-ArtLoadCues
ptr_PLC_EggmanSBZ2:	dc.w PLC_EggmanSBZ2-ArtLoadCues
ptr_PLC_FZBoss:		dc.w PLC_FZBoss-ArtLoadCues

ptr_PLC_SonicLife:	dc.w PLC_SonicLife-ArtLoadCues
ptr_PLC_TailsLife:	dc.w PLC_TailsLife-ArtLoadCues
ptr_PLC_KnucklesLife:	dc.w PLC_KnucklesLife-ArtLoadCues
ptr_PLC_KyukoLife:	dc.w PLC_KyukoLife-ArtLoadCues
ptr_PLC_MetalLife:  dc.w PLC_MetalLife-ArtLoadCues
ptr_PLC_MightyLife:	dc.w PLC_MightyLife-ArtLoadCues
ptr_PLC_AmyLife:	dc.w PLC_AmyLife-ArtLoadCues
ptr_PLC_LegacyLife:	dc.w PLC_LegacyLife-ArtLoadCues
ptr_PLC_NoLife:		dc.w PLC_NoLife-ArtLoadCues

ptr_PLC_EndingSonic:dc.w PLC_EndingSonic-ArtLoadCues
ptr_PLC_EndingTails:dc.w PLC_EndingTails-ArtLoadCues
ptr_PLC_EndingKnuckles:dc.w PLC_EndingKnuckles-ArtLoadCues

plcm:	macro gfx,vram
	dc.l gfx
	dc.w vram
	endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Mainend-PLC_Main-2)/6)-1
		plcm	Nem_Lamp, vramLamp*$20		; lamppost
		plcm	Nem_Hud, vramHUD*$20		; HUD
		plcm	Nem_Points, vramPoints*$20	; the triumphant return because lol the art file's smaller now :3
		plcm	Nem_Ring, vramRing*$20 	; rings
	PLC_Mainend:
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2end-PLC_Main2-2)/6)-1
		plcm	Nem_Hearts, vramHearts*$20	; hearts
		plcm	Nem_BubbleGen, vramBubbleGen*$20; Bubble generator, now a global object due to funny shit with VRAM
	PLC_Main2end:
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explodeend-PLC_Explode-2)/6)-1
		plcm	Nem_Explode, vramExplode*$20	; explosion
		plcm	Nem_Monitors, vramMonitors*$20	; monitors
	PLC_Explodeend:
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOverend-PLC_GameOver-2)/6)-1
		plcm	Nem_GameOver, vramGameOver*$20	; game/time over
	PLC_GameOverend:
; ---------------------------------------------------------------------------
; Pattern load cues - Blossom Gardens
; ---------------------------------------------------------------------------
PLC_BGZ:	dc.w ((PLC_BGZ2-PLC_BGZ-2)/6)-1
		plcm	Nem_BGZBlock,		vramBlockBGZ*$20
		plcm	Nem_Bubbles,		vramBubblesBGZ*$20	; bubbles and numbers
		plcm	Nem_Motobug,		vramMotobugBGZ*$20	; motobug enemy
		plcm	Nem_SpringD,		vramDSpringBGZ*$20
		plcm	Nem_Mosqui,			vramMosquiBGZ*$20
		plcm	Nem_BGZStatues,		vramStatueBGZ*$20	; statues
		plcm	Nem_CDFlapdoor,		vramFlapBGZ*$20
		plcm	Nem_ExplodeLant, 	vramExpLanBGZ*$20	; lantern explosion
		plcm	Nem_BGZLantern,		vramLantenBGZ*$20
		plcm	Nem_BambooBoard,	vramSprBrdBGZ*$20

PLC_BGZ2:	dc.w ((PLC_BGZ2end-PLC_BGZ2-2)/6)-1
		plcm	Nem_BambSpikes,		vramSpikesBGZ*$20	; bamboo spikes
		plcm	Nem_Spring,			vramSpringBGZ*$20	; spring
		plcm	Nem_Petals,			vramPetalsBGZ*$20	; petals
		plcm	Nem_Gameroid,		vramGameroidBGZ*$20	; Gameroid enemy
		plcm	Nem_GenWater,		vramWtrSurBGZ*$20	; water	surface
	PLC_BGZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Legacy Blossom Gardens
; ---------------------------------------------------------------------------
PLC_LBGZ:	dc.w ((PLC_LBGZ2-PLC_LBGZ-2)/6)-1
		plcm	Nem_LBGZPlat, vramPlatLBGZ*$20	; Floating platforms
		plcm	Nem_LBGZLedge,vramLedgeLBGZ*$20	; Collapsing ledge
		plcm	Nem_Stalk, vramStalkLBGZ*$20	; flower stalk
		plcm	Nem_Swing, vramSwingLBGZ*$20	; swinging platform
		plcm	Nem_LBGZBridge, vramBridgeLBGZ*$20	; bridge
; GHZ spiked pole would go here but fuck that noise
		plcm	Nem_Ball, vramBallLBGZ*$20		; giant	ball
		plcm	Nem_LBGZRock, vramRockLBGZ*$20	; purple rock

PLC_LBGZ2:	dc.w ((PLC_LBGZ2end-PLC_LBGZ2-2)/6)-1
		plcm	Nem_Crabmeat, vramCrabmeatLBGZ*$20	; crabmeat enemy
		plcm	Nem_Buzz, vramBuzzLBGZ*$20		; buzz bomber enemy
		plcm	Nem_Chopper, vramChopperLBGZ*$20	; chopper enemy
		plcm	Nem_Newtron, vramNewtronLBGZ*$20	; newtron enemy
		plcm	Nem_Motobug, vramMotobugLBGZ*$20	; motobug enemy
		plcm	Nem_GHZSmaWall, vramSmaWallLBGZ*$20	; breakable wall
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
	PLC_LBGZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Sunken Relic
; ---------------------------------------------------------------------------
PLC_LZ:		dc.w ((PLC_LZ2-PLC_LZ-2)/6)-1
		plcm	Nem_LzBlock1, $3C00	; block
		plcm	Nem_LzBlock2, $3E00	; blocks
		plcm	Nem_Splash, $4B20	; waterfalls and splash
		plcm	Nem_Gargoyle, $5D20	; gargoyle head
		plcm	Nem_Water, $6000	; water	surface
		plcm	Nem_LzSpikeBall, $6200	; spiked ball
		plcm	Nem_FlapDoor, $6500	; flapping door
		plcm	Nem_Bubbles, $6CE0	; bubbles and numbers
		plcm	Nem_LzBlock3, $7780	; block
		plcm	Nem_LzDoor1, $7880	; vertical door
		plcm	Nem_Harpoon, $7980	; harpoon

PLC_LZ2:	dc.w ((PLC_LZ2end-PLC_LZ2-2)/6)-1
		plcm	Nem_LzPole, $7BC0	; pole that breaks
		plcm	Nem_LzDoor2, $7CC0	; large	horizontal door
		plcm	Nem_LzWheel, $7EC0	; wheel
		plcm	Nem_LzPlatfm, $89E0	; rising platform
		plcm	Nem_Orbinaut, $8CE0	; orbinaut enemy
		plcm	Nem_Jaws, $90C0		; jaws enemy
		plcm	Nem_Burrobot, $94C0	; burrobot enemy
		plcm	Nem_Cork, $A000		; cork block
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
	PLC_LZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Ashen Temple
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w ((PLC_MZ2-PLC_MZ-2)/6)-1
		plcm	Nem_MzMetal, $6000	; metal	blocks
		plcm	Nem_MzFire, $68A0	; fireballs
		plcm	Nem_Swing, $7000	; swinging platform
		plcm	Nem_MzGlass, $71C0	; green	glassy block
		plcm	Nem_Lava, $7500		; lava
		plcm	Nem_Buzz, vramBuzzLBGZ*$20		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Basaran, $9700	; basaran enemy
		plcm	Nem_Cater, $9FE0	; caterkiller enemy

PLC_MZ2:	dc.w ((PLC_MZ2end-PLC_MZ2-2)/6)-1
		plcm	Nem_MzSwitch, $A260	; switch
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
		plcm	Nem_MzBlock, $5700	; green	stone block
	PLC_MZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Hoshi Metro
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w ((PLC_SLZ2-PLC_SLZ-2)/6)-1
		plcm	Nem_Bomb, $8000		; bomb enemy
		plcm	Nem_Orbinaut, $8520	; orbinaut enemy
		plcm	Nem_MzFire, $9000	; fireballs
		plcm	Nem_SlzBlock, $9C00	; block
		plcm	Nem_SlzWall, vramSmaWallLBGZ*$20	; breakable wall
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring

PLC_SLZ2:	dc.w ((PLC_SLZ2end-PLC_SLZ2-2)/6)-1
		plcm	Nem_Seesaw, $6E80	; seesaw
		plcm	Nem_Fan, $7400		; fan
		plcm	Nem_Pylon, $7980	; foreground pylon
		plcm	Nem_SlzSwing, $7B80	; swinging platform
		plcm	Nem_SlzCannon, $9B00	; fireball launcher
		plcm	Nem_SlzSpike, $9E00	; spikeball
	PLC_SLZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Bumper City
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w ((PLC_SYZ2-PLC_SYZ-2)/6)-1
		plcm	Nem_Crabmeat, vramCrabmeatLBGZ*$20	; crabmeat enemy
		plcm	Nem_Buzz, vramBuzzLBGZ*$20		; buzz bomber enemy
		plcm	Nem_Yadrin, $8F60	; yadrin enemy
		plcm	Nem_Roller, $9700	; roller enemy

PLC_SYZ2:	dc.w ((PLC_SYZ2end-PLC_SYZ2-2)/6)-1
		plcm	Nem_Bumper, $7000	; bumper
		plcm	Nem_SyzSpike1, $72C0	; large	spikeball
		plcm	Nem_SyzSpike2, $7740	; small	spikeball
;		plcm	Nem_Cater, $9FE0	; caterkiller enemy
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
	PLC_SYZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Badnik Blitz
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w ((PLC_SBZ2-PLC_SBZ-2)/6)-1
		plcm	Nem_Stomper, $5800	; moving platform and stomper
		plcm	Nem_SbzDoor1, $5D00	; door
		plcm	Nem_Girder, $5E00	; girder
		plcm	Nem_BallHog, $6040	; ball hog enemy
		plcm	Nem_SbzWheel1, $6880	; spot on large	wheel
		plcm	Nem_SbzWheel2, $6900	; wheel	that grabs Sonic
		plcm	Nem_SyzSpike1, $7220	; large	spikeball
		plcm	Nem_Cutter, $76A0	; pizza	cutter
		plcm	Nem_FlamePipe, $7B20	; flaming pipe
		plcm	Nem_SbzFloor, $7EA0	; collapsing floor
		plcm	Nem_SbzBlock, $9860	; vanishing block

PLC_SBZ2:	dc.w ((PLC_SBZ2end-PLC_SBZ2-2)/6)-1
		plcm	Nem_Cater, $5600	; caterkiller enemy
		plcm	Nem_Bomb, $8000		; bomb enemy
		plcm	Nem_Orbinaut, $8520	; orbinaut enemy
		plcm	Nem_SlideFloor, $8C00	; floor	that slides away
		plcm	Nem_SbzDoor2, $8DE0	; horizontal door
		plcm	Nem_Electric, $8FC0	; electric orb
		plcm	Nem_TrapDoor, $9240	; trapdoor
		plcm	Nem_SbzFloor, $7F20	; collapsing floor
		plcm	Nem_SpinPform, $9BE0	; small	spinning platform
		plcm	Nem_LzSwitch, $A1E0	; switch
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
	PLC_SBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Melting Heights
; ---------------------------------------------------------------------------
PLC_MHZ:	dc.w ((PLC_MHZ2-PLC_MHZ-2)/6)-1
		plcm	Nem_MzFire,		vramFireMHZ*$20		; fireballs
		plcm	Nem_Bubbles,	vramBubblesMHZ*$20	; bubbles and numbers
		plcm	Nem_MHZDeco,	vramDecorMHZ*$20	; decorations
		plcm	Nem_SpringD,	vramDSpringBGZ*$20	; Diagonal spring
		plcm	Nem_Snowrex,	vramSnowrexMHZ*$20	; snowrex enemy
		plcm	Nem_SnowTulipon,vramTuliponMHZ*$20	; snow tulipon
		plcm	Nem_GenWater,	vramWtrSurBGZ*$20	; water	surface

PLC_MHZ2:	dc.w ((PLC_MHZ2end-PLC_MHZ2-2)/6)-1
		plcm	Nem_MHZBlocks,	vramBlocksMHZ*$20	; Ice blocks
		plcm	Nem_MHZSmaWall,	vramSmaWallMHZ*$20	; smashable wall
		plcm	Nem_IceSpikes,	vramSpikesBGZ*$20	; ice spikes
		plcm	Nem_Spring,		vramSpringBGZ*$20	; spring
		plcm	Nem_Snow,		vramSnowMHZ*$20		; snowflakes
	PLC_MHZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Hidden Palace
; ---------------------------------------------------------------------------
PLC_HPZ:	dc.w ((PLC_HPZ2-PLC_HPZ-2)/6)-1
		plcm	Nem_HPZBlock,	vramBlockBGZ*$20
		plcm	Nem_Bubbles,	vramBubblesBGZ*$20	; bubbles and numbers
		plcm	Nem_SpringD,	vramDSpringBGZ*$20	; Diagonal spring
;		plcm	Nem_Snowrex,	vramSnowrexMHZ*$20	; snowrex enemy
		plcm	Nem_Basaran,	$9700				; basaran enemy
		plcm	Nem_GenWater,	vramWtrSurBGZ*$20	; Water surface

PLC_HPZ2:	dc.w ((PLC_HPZ2end-PLC_HPZ2-2)/6)-1
		plcm	Nem_Spikes,		vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring,		vramSpringBGZ*$20	; spring
	PLC_HPZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - The Magnet
; ---------------------------------------------------------------------------
PLC_TMZ:	dc.w ((PLC_TMZ2-PLC_TMZ-2)/6)-1
		plcm	Nem_Bubbles,		vramBubblesBGZ*$20	; bubbles and numbers
		plcm	Nem_SpringD,	vramDSpringBGZ*$20	; Diagonal spring

PLC_TMZ2:	dc.w ((PLC_TMZ2end-PLC_TMZ2-2)/6)-1
		plcm	Nem_Spikes, vramSpikesBGZ*$20	; spikes
		plcm	Nem_Spring, vramSpringBGZ*$20	; spring
	PLC_TMZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - title card
; ---------------------------------------------------------------------------
PLC_TitleCard:	dc.w ((PLC_TitleCardend-PLC_TitleCard-2)/6)-1
		plcm	Nem_TitleCard, vramTitleCard*$20
	PLC_TitleCardend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Bossend-PLC_Boss-2)/6)-1
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Weapons, $8D80	; Eggman's weapons
		plcm	Nem_Prison, $93A0	; prison capsule
;		plcm	Nem_Bomb, $A300		; bomb enemy ((gets overwritten)
		plcm	Nem_SlzSpike, $A300	; spikeball ((SLZ boss)
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_Bossend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ act 3 boss
; ---------------------------------------------------------------------------
PLC_SLZBoss:	dc.w ((PLC_SLZBossend-PLC_SLZBoss-2)/6)-1
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Weapons, $8D80	; Eggman's weapons
		plcm	Nem_Prison, $93A0	; prison capsule
		plcm	Nem_Bomb, $A300		; bomb enemy ((gets overwritten)
		plcm	Nem_SlzSpike, $A300	; spikeball ((SLZ boss)
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_SLZBossend:
; ---------------------------------------------------------------------------
; Pattern load cues - Prison capsule, for non-Eggman bosses
; ---------------------------------------------------------------------------
PLC_Capsule:	dc.w ((PLC_Capsuleend-PLC_Capsule-2)/6)-1
		plcm	Nem_Prison, $93A0	; prison capsule
	PLC_Capsuleend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 end of level
; ---------------------------------------------------------------------------
PLC_LevelEnd:	dc.w ((PLC_LevelEndend-PLC_LevelEnd-2)/6)-1
		plcm	Nem_Bonus, $96C0	; hidden bonus points
	PLC_LevelEndend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	dc.w ((PLC_SpeStageend-PLC_SpecialStage-2)/6)-1
		plcm	Nem_SSBgCloud, 0	; bubble and cloud background
		plcm	Nem_SSBgFish, $A20	; bird and fish	background
		plcm	Nem_Bumper, $4760	; bumper
		plcm	Nem_SSGOAL, $4A20	; GOAL block
		plcm	Nem_SSUpDown, $4C60	; UP and DOWN blocks
		plcm	Nem_SSRBlock, $5E00	; R block
		plcm	Nem_SS1UpBlock, $6E00	; 1UP block
		plcm	Nem_SSEmStars, $7E00	; emerald collection stars
		plcm	Nem_SSRedWhite, $8E00	; red and white	block
		plcm	Nem_SSGhost, $9E00	; ghost	block
		plcm	Nem_SSWBlock, $AE00	; W block
		plcm	Nem_SSGlass, $BE00	; glass	block
		plcm	Nem_SSEmerald, $EE00	; emeralds
		plcm	Nem_SSZone1, $F2E0	; ZONE 1 block
		plcm	Nem_SSZone2, $F400	; ZONE 2 block
		plcm	Nem_SSZone3, $F520	; ZONE 3 block
	PLC_SpeStageend:
		plcm	Nem_SSZone4, $F2E0	; ZONE 4 block
		plcm	Nem_SSZone5, $F400	; ZONE 5 block
		plcm	Nem_SSZone6, $F520	; ZONE 6 block
; ---------------------------------------------------------------------------
; Pattern load cues - BGZ animals
; ---------------------------------------------------------------------------
PLC_BGZAnimals:	dc.w ((PLC_BGZAnimalsend-PLC_BGZAnimals-2)/6)-1
		plcm	Nem_Panda, vramAnimal1*$20	; Packy
		plcm	Nem_Dove, vramAnimal2*$20		; Vicky
	PLC_BGZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimalsend-PLC_GHZAnimals-2)/6)-1
		plcm	Nem_Rabbit, vramAnimal1*$20	; rabbit
		plcm	Nem_Flicky, vramAnimal2*$20	; flicky
	PLC_GHZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimalsend-PLC_LZAnimals-2)/6)-1
		plcm	Nem_BlackBird, vramAnimal1*$20	; blackbird
		plcm	Nem_Seal, vramAnimal2*$20		; seal
	PLC_LZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w ((PLC_MZAnimalsend-PLC_MZAnimals-2)/6)-1
		plcm	Nem_Squirrel, vramAnimal1*$20	; squirrel
		plcm	Nem_Seal, vramAnimal2*$20		; seal
	PLC_MZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w ((PLC_SLZAnimalsend-PLC_SLZAnimals-2)/6)-1
		plcm	Nem_Pig, vramAnimal1*$20		; pig
		plcm	Nem_Flicky, vramAnimal2*$20	; flicky
	PLC_SLZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w ((PLC_SYZAnimalsend-PLC_SYZAnimals-2)/6)-1
		plcm	Nem_Pig, vramAnimal1*$20		; pig
		plcm	Nem_Chicken, vramAnimal2*$20	; chicken
	PLC_SYZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w ((PLC_SBZAnimalsend-PLC_SBZAnimals-2)/6)-1
		plcm	Nem_Rabbit, vramAnimal1*$20		; rabbit
		plcm	Nem_Chicken, vramAnimal2*$20	; chicken
	PLC_SBZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - MHZ animals
; ---------------------------------------------------------------------------
PLC_MHZAnimals:	dc.w ((PLC_MHZAnimalsend-PLC_MHZAnimals-2)/6)-1
		plcm	Nem_BlackBird, vramAnimal1*$20	; blackbird
		plcm	Nem_Seal, vramAnimal2*$20		; seal
	PLC_MHZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - HPZ animals
; ---------------------------------------------------------------------------
PLC_HPZAnimals:	dc.w ((PLC_HPZAnimalsend-PLC_HPZAnimals-2)/6)-1
		plcm	Nem_Mouse,	vramAnimal1*$20	; mouse
		plcm	Nem_Seal,	vramAnimal2*$20	; seal
	PLC_HPZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - TMZ animals
; ---------------------------------------------------------------------------
PLC_TMZAnimals:	dc.w ((PLC_TMZAnimalsend-PLC_TMZAnimals-2)/6)-1
		plcm	Nem_Rabbit, vramAnimal1*$20	; rabbit
		plcm	Nem_Flicky, vramAnimal2*$20	; flicky
	PLC_TMZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:dc.w ((PLC_SpeStResultend-PLC_SSResult-2)/6)-1
		plcm	Nem_ResultEm, $A820	; emeralds
		plcm	Nem_MiniSonic, $AA20	; mini Sonic
	PLC_SpeStResultend:
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w ((PLC_Endingend-PLC_Ending-2)/6)-1
		plcm	Nem_Stalk, $6B00	; flower stalk
		plcm	Nem_EndFlower, $7400	; flowers
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_Rabbit, $AA60	; rabbit
		plcm	Nem_Chicken, $ACA0	; chicken
		plcm	Nem_BlackBird, $AE60	; blackbird
		plcm	Nem_Seal, $B0A0		; seal
		plcm	Nem_Pig, $B260		; pig
		plcm	Nem_Flicky, $B4A0	; flicky
		plcm	Nem_Squirrel, $B660	; squirrel
		plcm	Nem_EndStH, $B8A0	; "SONIC THE HEDGEHOG"
	PLC_Endingend:
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w ((PLC_TryAgainend-PLC_TryAgain-2)/6)-1
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_TryAgain, $7C20	; Eggman
	PLC_TryAgainend:
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w ((PLC_EggmanSBZ2end-PLC_EggmanSBZ2-2)/6)-1
		plcm	Nem_SbzBlock, $A300	; block
		plcm	Nem_Sbz2Eggman, $8000	; Eggman
		plcm	Nem_LzSwitch, $9400	; switch
	PLC_EggmanSBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w ((PLC_FZBossend-PLC_FZBoss-2)/6)-1
		plcm	Nem_FzEggman, $7400	; Eggman after boss
		plcm	Nem_FzBoss, $6000	; FZ boss
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Sbz2Eggman, $8E00	; Eggman without ship
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_FZBossend:
; ---------------------------------------------------------------------------
; Pattern load cues - Life icons
; ---------------------------------------------------------------------------
PLC_SonicLife: dc.w ((PLC_SonicLifeend-PLC_SonicLife-2)/6)-1
		plcm	Nem_Lives, $FA80	; lives	counter
	PLC_SonicLifeend:

PLC_TailsLife: dc.w ((PLC_TailsLifeend-PLC_TailsLife-2)/6)-1
		plcm	Nem_LivesT, $FA80	; lives	counter
	PLC_TailsLifeend:

PLC_KnucklesLife: dc.w ((PLC_KnucklesLifeend-PLC_KnucklesLife-2)/6)-1
		plcm	Nem_LivesK, $FA80	; lives	counter
	PLC_KnucklesLifeend:

PLC_KyukoLife: dc.w ((PLC_KyukoLifeend-PLC_KyukoLife-2)/6)-1
		plcm	Nem_LivesKyu, $FA80	; lives	counter
	PLC_KyukoLifeend:

PLC_MetalLife: dc.w ((PLC_MetalLifeend-PLC_MetalLife-2)/6)-1
		plcm	Nem_LivesMS, $FA80	; lives	counter
	PLC_MetalLifeend:

PLC_MightyLife: dc.w ((PLC_MightyLifeend-PLC_MightyLife-2)/6)-1
		plcm	Nem_LivesM, $FA80	; lives	counter
	PLC_MightyLifeend:

PLC_AmyLife:	dc.w ((PLC_AmyLifeend-PLC_AmyLife-2)/6)-1
		plcm	Nem_LivesA, $FA80	; lives counter
	PLC_AmyLifeend:

PLC_LegacyLife:	dc.w ((PLC_LegacyLifeend-PLC_LegacyLife-2)/6)-1
		plcm	Nem_LivesLS, $FA80	; lives counter
	PLC_LegacyLifeend:

PLC_NoLife:	dc.w ((PLC_NoLifeend-PLC_NoLife-2)/6)-1
		plcm	Nem_LivesNone, $FA80	; lives counter
	PLC_NoLifeend:

; ---------------------------------------------------------------------------
; Pattern load cues - Ending characters
; ---------------------------------------------------------------------------
PLC_EndingSonic: dc.w ((PLC_EndingSonicend-PLC_EndingSonic-2)/6)-1
		plcm	Nem_EndSonic, $7C20	; Sonic
	PLC_EndingSonicend:

PLC_EndingTails: dc.w ((PLC_EndingTailsend-PLC_EndingTails-2)/6)-1
		plcm	Nem_EndTails, $7C20	; Tails
	PLC_EndingTailsend:

PLC_EndingKnuckles: dc.w ((PLC_EndingKnucklesend-PLC_EndingKnuckles-2)/6)-1
		plcm	Nem_EndKnuckles, $7C20	; Knuckles
	PLC_EndingKnucklesend:
		even

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:		equ (ptr_PLC_Main-ArtLoadCues)/2	; 0
plcid_Main2:	equ (ptr_PLC_Main2-ArtLoadCues)/2	; 1
plcid_Explode:	equ (ptr_PLC_Explode-ArtLoadCues)/2	; 2
plcid_GameOver:	equ (ptr_PLC_GameOver-ArtLoadCues)/2	; 3
plcid_BGZ:		equ (ptr_PLC_BGZ-ArtLoadCues)/2		; 4
plcid_BGZ2:		equ (ptr_PLC_BGZ2-ArtLoadCues)/2	; 5
plcid_LZ:		equ (ptr_PLC_LZ-ArtLoadCues)/2		; 6
plcid_LZ2:		equ (ptr_PLC_LZ2-ArtLoadCues)/2		; 7
plcid_MZ:		equ (ptr_PLC_MZ-ArtLoadCues)/2		; 8
plcid_MZ2:		equ (ptr_PLC_MZ2-ArtLoadCues)/2		; 9
plcid_SLZ:		equ (ptr_PLC_SLZ-ArtLoadCues)/2		; $A
plcid_SLZ2:		equ (ptr_PLC_SLZ2-ArtLoadCues)/2	; $B
plcid_SYZ:		equ (ptr_PLC_SYZ-ArtLoadCues)/2		; $C
plcid_SYZ2:		equ (ptr_PLC_SYZ2-ArtLoadCues)/2	; $D
plcid_SBZ:		equ (ptr_PLC_SBZ-ArtLoadCues)/2		; $E
plcid_SBZ2:		equ (ptr_PLC_SBZ2-ArtLoadCues)/2	; $F
plcid_MHZ:		equ (ptr_PLC_MHZ-ArtLoadCues)/2	; $10
plcid_MHZ2:		equ (ptr_PLC_MHZ2-ArtLoadCues)/2	; $11
plcid_HPZ:		equ (ptr_PLC_HPZ-ArtLoadCues)/2	; $10
plcid_HPZ2:		equ (ptr_PLC_HPZ2-ArtLoadCues)/2	; $11
plcid_TMZ:		equ (ptr_PLC_TMZ-ArtLoadCues)/2	; $10
plcid_TMZ2:		equ (ptr_PLC_TMZ2-ArtLoadCues)/2	; $11
plcid_LBGZ:		equ (ptr_PLC_LBGZ-ArtLoadCues)/2		; 4
plcid_LBGZ2:	equ (ptr_PLC_LBGZ2-ArtLoadCues)/2	; 5
plcid_TitleCard:	equ (ptr_PLC_TitleCard-ArtLoadCues)/2	; $12
plcid_Boss:		equ (ptr_PLC_Boss-ArtLoadCues)/2	; $14
plcid_SLZBoss:		equ (ptr_PLC_SLZBoss-ArtLoadCues)/2	; $14
plcid_Capsule:		equ (ptr_PLC_Capsule-ArtLoadCues)/2	; $14
plcid_LevelEnd:		equ (ptr_PLC_LevelEnd-ArtLoadCues)/2	; $15
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2 ; $16
plcid_BGZAnimals:	equ (ptr_PLC_BGZAnimals-ArtLoadCues)/2	; $17
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2	; $18
plcid_MZAnimals:	equ (ptr_PLC_MZAnimals-ArtLoadCues)/2	; $19
plcid_SLZAnimals:	equ (ptr_PLC_SLZAnimals-ArtLoadCues)/2	; $1A
plcid_SYZAnimals:	equ (ptr_PLC_SYZAnimals-ArtLoadCues)/2	; $1B
plcid_SBZAnimals:	equ (ptr_PLC_SBZAnimals-ArtLoadCues)/2	; $1C
plcid_MHZAnimals:	equ	(ptr_PLC-MHZAnimals-ArtLoadCues)/2
plcid_HPZAnimals:	equ	(ptr_PLC-HPZAnimals-ArtLoadCues)/2
plcid_TMZAnimals:	equ	(ptr_PLC-TMZAnimals-ArtLoadCues)/2
plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2	; $17
plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2	; $1D
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2	; $1E
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2	; $1F
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2	; $20
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2	; $21

plcid_SonicLife:	equ (ptr_PLC_SonicLife-ArtLoadCues)/2 ; $22
plcid_TailsLife:	equ (ptr_PLC_TailsLife-ArtLoadCues)/2 ; $23
plcid_KnucklesLife:	equ (ptr_PLC_KnucklesLife-ArtLoadCues)/2 ; $24
plcid_KyukoLife:	equ (ptr_PLC_KyukoLife-ArtLoadCues)/2 ; $25
plcid_MetalLife:	equ (ptr_PLC_MetalLife-ArtLoadCues)/2 ; $26
plcid_MightyLife:	equ (ptr_PLC_MightyLife-ArtLoadCues)/2 ; $27
plcid_AmyLife:		equ (ptr_PLC_AmyLife-ArtLoadCues)/2		; $28
plcid_LegacyLife:		equ (ptr_PLC_LegacyLife-ArtLoadCues)/2	; $29
plcid_NoLife:		equ (ptr_PLC_NoLife-ArtLoadCues)/2	; $2A

plcid_EndingSonic:	equ	(ptr_PLC_EndingSonic-ArtLoadCues)/2	; $2B
plcid_EndingTails:	equ	(ptr_PLC_EndingTails-ArtLoadCues)/2	; $2C
plcid_EndingKnuckles:	equ	(ptr_PLC_EndingKnuckles-ArtLoadCues)/2	; $2D
