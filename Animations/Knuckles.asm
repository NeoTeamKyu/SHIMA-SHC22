; ---------------------------------------------------------------------------
; Animation script - Knuckles
; ---------------------------------------------------------------------------
KnucklesAniData:
		dc.w KnucklesAni_Walk-KnucklesAniData; 0	; $0
		dc.w KnucklesAni_Run-KnucklesAniData; 1	; $1
		dc.w KnucklesAni_Roll-KnucklesAniData; 2	; $2
		dc.w KnucklesAni_Roll2-KnucklesAniData;	3	; $3
		dc.w KnucklesAni_Push-KnucklesAniData; 4	; $4
		dc.w KnucklesAni_Wait-KnucklesAniData; 5	; $5
		dc.w KnucklesAni_Balance-KnucklesAniData; 6	; $6
		dc.w KnucklesAni_LookUp-KnucklesAniData; 7	; $7
		dc.w KnucklesAni_Duck-KnucklesAniData; 8	; $8
		dc.w KnucklesAni_Spindash-KnucklesAniData; 9; $9
		dc.w KnucklesAni_Fall-KnucklesAniData; 10	; $A
		dc.w KnucklesAni_Balance2-KnucklesAniData; 11	; $B
		dc.w KnucklesAni_Blank-KnucklesAniData; 12;$C
		dc.w KnucklesAni_Stop-KnucklesAniData; 13	; $D
		dc.w KnucklesAni_Float-KnucklesAniData;	14	; $E
		dc.w KnucklesAni_Float2-KnucklesAniData; 15	; $F
		dc.w KnucklesAni_Spring-KnucklesAniData; 16	; $10
		dc.w KnucklesAni_Hang-KnucklesAniData; 17	; $11
		dc.w KnucklesAni_Blank-KnucklesAniData; 18	; $12
		dc.w KnucklesAni_Blank-KnucklesAniData; 19	; $13
		dc.w KnucklesAni_Blank-KnucklesAniData; 20	; $14
		dc.w KnucklesAni_Bubble-KnucklesAniData; 21	; $15
		dc.w KnucklesAni_DeathBW-KnucklesAniData; 22; $16
		dc.w KnucklesAni_Drown-KnucklesAniData;	23	; $17
		dc.w KnucklesAni_Death-KnucklesAniData;	24	; $18
		dc.w KnucklesAni_WaterSlide-KnucklesAniData; 25	; $19
		dc.w KnucklesAni_Hurt-KnucklesAniData; 26	; $1A
		dc.w KnucklesAni_WaterSlide-KnucklesAniData; 27 ; $1B
		dc.w KnucklesAni_Blank-KnucklesAniData;	28	; $1C
		dc.w KnucklesAni_Float3-KnucklesAniData; 29	; $1D
		dc.w KnucklesAni_Blank-KnucklesAniData; 30	; $1E
		dc.w KnucklesAni_Transform-KnucklesAniData; 31; $1F
		dc.w KnucklesAni_Gliding-KnucklesAniData; 32; $20
		dc.w KnucklesAni_FallFromGlide-KnucklesAniData;	33;	$21
		dc.w KnucklesAni_GetUp-KnucklesAniData;	34	; $22
		dc.w KnucklesAni_HardFall-KnucklesAniData; 35 ; $23
		dc.w KnucklesAni_MachSpd-KnucklesAniData ; 36	; $24
		dc.w KnucklesAni_Victory-KnucklesAniData ; 37	; $25
		dc.w KnucklesAni_GlidingSet-KnucklesAniData; 38; $26

KnucklesAni_Walk:	dc.b	$FF,frK_Walk17,frK_Walk18,frK_Walk11,frK_Walk12,frK_Walk13,frK_Walk14,frK_Walk15,frK_Walk16,afEnd
		even
KnucklesAni_Run:	dc.b	$FF,frK_Run11,frK_Run12,frK_Run13,frK_Run14,afEnd,afEnd,afEnd,afEnd,afEnd
		even
KnucklesAni_Roll:	dc.b	$FE,frK_Roll5,frK_Roll1,frK_Roll5,frK_Roll2,frK_Roll5,frK_Roll3,frK_Roll5,frK_Roll4,afEnd
		even
KnucklesAni_Roll2:	dc.b	$FE,frK_Roll5,frK_Roll1,frK_Roll5,frK_Roll2,frK_Roll5,frK_Roll3,frK_Roll5,frK_Roll4,afEnd
		even
KnucklesAni_Push:	dc.b	afChange,frK_Push1,frK_Push2,frK_Push3,frK_Push4,afEnd,afEnd,afEnd,afEnd,afEnd
		even
KnucklesAni_Wait:	dc.b	5,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand; 13
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand; 26
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Wait1; 39
			dc.b	frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1; 52
			dc.b	frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1; 65
			dc.b	frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2; 78
			dc.b	frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2,frK_Wait2,frK_Wait1,frK_Wait1,frK_Wait1,frK_Wait2,frK_Wait2; 91
			dc.b	frK_Wait2,frK_Wait3,frK_Wait3,frK_Wait3,frK_Wait3,frK_Wait3,frK_Wait4,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6; 104
			dc.b	frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7; 117
			dc.b	frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8; 130
			dc.b	frK_Wait9,frK_WaitA,frK_Wait9,frK_WaitA,frK_WaitB,frK_WaitB,frK_Wait5,frK_Wait4;,afEnd; 143
	
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand; 13
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand; 26
			dc.b	frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_Stand,frK_WaitC
			dc.b	frK_WaitC,frK_WaitC,frK_WaitC,frK_WaitC,frK_WaitD,frK_WaitD,frK_WaitE1,frK_WaitE2,frK_WaitE3,frK_WaitE4,afBack,4
		even
KnucklesAni_Balance:	dc.b	3,frK_BalA1,frK_BalA2,frK_BalA3,frK_BalA4,afEnd		  ; 39
		even
KnucklesAni_LookUp:	dc.b	5,frK_Look1,frK_Look2,afBack,  1
		even
KnucklesAni_Duck:	dc.b	5,frK_Duck1,frK_Duck2,afBack,	1
		even
KnucklesAni_Spindash:	dc.b	0,frK_Spindash1,frK_Spindash2,frK_Spindash1,frK_Spindash3,frK_Spindash1,frK_Spindash4,frK_Spindash1,frK_Spindash5,frK_Spindash1,frK_Spindash6,afEnd
		even
KnucklesAni_Fall:	dc.b	5, frK_Fall1, frK_Fall2, afBack, 1
		even
KnucklesAni_Balance2:	dc.b	$F,frK_BalB1,frK_BalB2,frK_BalB3,afEnd
		even
KnucklesAni_Stop:	dc.b	5,frK_Skid1,frK_Skid2,frK_Skid3,frK_SkidT,afChange,	0  	; skid
		even
KnucklesAni_Float:	dc.b	7,frK_Glide1,afEnd		    	; fwd...?
		even
KnucklesAni_Float2:	dc.b	7,frK_Glide1, frK_Glide2, frK_Glide3, frK_Glide4, frK_Glide5, frK_Glide6, frK_Glide7, frK_Glide8, frK_Glide9, frK_GlideA, afEnd	; spin
		even
KnucklesAni_Spring:	dc.b	$2F,frK_Spring, afEnd
		even
KnucklesAni_Hang:	dc.b	1,frK_Hang1,frK_Hang2,afEnd		   	; cling to pole, horizontal
		even
KnucklesAni_Bubble:	dc.b	$B,frK_Bubble,frK_Bubble,  frK_Walk13,  frK_Walk14,afChange,  0
		even
KnucklesAni_DeathBW:	dc.b	$20,frK_Burnt,afEnd
		even
KnucklesAni_Drown:	dc.b	$20,frK_Drown,afEnd
		even
KnucklesAni_Death:	dc.b	$20,frK_Die,afChange,$1B
		even
KnucklesAni_WaterSlide:	dc.b	7,frK_Hurt,frK_Slide,afEnd		       	; flume
		even
KnucklesAni_Hurt:	dc.b	$40,frK_Hurt,afEnd
		even
KnucklesAni_Blank:	dc.b	$77,frK_Null,afEnd
		even
KnucklesAni_Float3:	dc.b	3,frK_Glide1, frK_Glide2, frK_Glide3, frK_Glide4, frK_Glide5, frK_Glide6, frK_Glide7, frK_Glide8, frK_Glide9, frK_GlideA, afEnd	; spin
		even
KnucklesAni_Transform:	dc.b	2,frK_Transform1, frK_Transform2, frK_Transform3, frK_Transform4,afBack, 2
		even
KnucklesAni_Gliding:	dc.b	$1F, frK_Glide1,afEnd
		even
KnucklesAni_FallFromGlide:	dc.b	7,frK_GlideF1,frK_GlideF2,afBack,	 1
		even
KnucklesAni_GetUp:	dc.b	$F,frK_GlideS2,afChange,  0
		even
KnucklesAni_HardFall:	dc.b	$F,frK_Duck2,afChange,	0
		even
KnucklesAni_Badass:	dc.b	5,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8
			dc.b	frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5; 13
			dc.b	frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait5,frK_Wait6,frK_Wait7,frK_Wait8,frK_Wait9,frK_WaitA,frK_Wait9,frK_WaitA,frK_WaitB,frK_WaitB; 26
			dc.b	afEnd			  ; 39
		even
KnucklesAni_MachSpd:		dc.b	$FF,frK_Mach11,frK_Mach12,frK_Mach13,frK_Mach14,afEnd,afEnd,afEnd,afEnd,afEnd
		even
KnucklesAni_Victory:	dc.b	$F, frK_Victory1, frK_Victory2, afBack, 1
		even
KnucklesAni_GlidingSet:	dc.b	3, frK_GlideT1, frK_GlideT2, afChange, $20 ; Startup to the glide
		even

; Knuckles animation frames
		rsreset
frK_Null:	rs.b 1
frK_Stand:	rs.b 1
frK_Wait1:	rs.b 1
frK_Wait2:	rs.b 1
frK_Wait3:	rs.b 1
frK_Wait4:	rs.b 1
frK_Wait5:	rs.b 1
frK_Wait6:	rs.b 1
frK_Wait7:	rs.b 1
frK_Wait8:	rs.b 1
frK_Wait9:	rs.b 1
frK_WaitA:	rs.b 1
frK_WaitB:	rs.b 1
frK_WaitC:	rs.b 1
frK_WaitD:	rs.b 1
frK_WaitE1:	rs.b 1
frK_WaitE2:	rs.b 1
frK_WaitE3:	rs.b 1
frK_WaitE4:	rs.b 1
frK_Look1:	rs.b 1
frK_Look2:	rs.b 1
frK_Duck1:	rs.b 1
frK_Duck2:	rs.b 1
frK_Walk11:	rs.b 1
frK_Walk12:	rs.b 1
frK_Walk13:	rs.b 1
frK_Walk14:	rs.b 1
frK_Walk15:	rs.b 1
frK_Walk16:	rs.b 1
frK_Walk17:	rs.b 1
frK_Walk18:	rs.b 1
frK_Walk21:	rs.b 1
frK_Walk22:	rs.b 1
frK_Walk23:	rs.b 1
frK_Walk24:	rs.b 1
frK_Walk25:	rs.b 1
frK_Walk26:	rs.b 1
frK_Walk27:	rs.b 1
frK_Walk28:	rs.b 1
frK_Walk31:	rs.b 1
frK_Walk32:	rs.b 1
frK_Walk33:	rs.b 1
frK_Walk34:	rs.b 1
frK_Walk35:	rs.b 1
frK_Walk36:	rs.b 1
frK_Walk37:	rs.b 1
frK_Walk38:	rs.b 1
frK_Walk41:	rs.b 1
frK_Walk42:	rs.b 1
frK_Walk43:	rs.b 1
frK_Walk44:	rs.b 1
frK_Walk45:	rs.b 1
frK_Walk46:	rs.b 1
frK_Walk47:	rs.b 1
frK_Walk48:	rs.b 1
frK_Run11:	rs.b 1
frK_Run12:	rs.b 1
frK_Run13:	rs.b 1
frK_Run14:	rs.b 1
frK_Run21:	rs.b 1
frK_Run22:	rs.b 1
frK_Run23:	rs.b 1
frK_Run24:	rs.b 1
frK_Run31:	rs.b 1
frK_Run32:	rs.b 1
frK_Run33:	rs.b 1
frK_Run34:	rs.b 1
frK_Run41:	rs.b 1
frK_Run42:	rs.b 1
frK_Run43:	rs.b 1
frK_Run44:	rs.b 1
frK_Roll1:	rs.b 1
frK_Roll2:	rs.b 1
frK_Roll3:	rs.b 1
frK_Roll4:	rs.b 1
frK_Roll5:	rs.b 1
frK_Skid1:	rs.b 1
frK_Skid2:	rs.b 1
frK_Skid3:	rs.b 1
frK_SkidT:	rs.b 1
frK_BalA1:	rs.b 1
frK_BalA2:	rs.b 1
frK_BalA3:	rs.b 1
frK_BalA4:	rs.b 1
frK_BalB1:	rs.b 1;
frK_BalB2:	rs.b 1;
frK_BalB3:	rs.b 1;
frK_GlideT1:rs.b 1
frK_GlideT2:rs.b 1
frK_Glide1:	rs.b 1
frK_Glide2:	rs.b 1
frK_Glide3:	rs.b 1
frK_Glide4:	rs.b 1
frK_Glide5:	rs.b 1
frK_Glide6:	rs.b 1
frK_Glide7:	rs.b 1
frK_Glide8:	rs.b 1
frK_Glide9:	rs.b 1
frK_GlideA:	rs.b 1
frK_Spring:	rs.b 1
frK_Fall1:	rs.b 1
frK_Fall2:	rs.b 1
frK_Hang1:	rs.b 1
frK_Hang2:	rs.b 1
frK_Push1:	rs.b 1
frK_Push2:	rs.b 1
frK_Push3:	rs.b 1
frK_Push4:	rs.b 1
frK_Die:	rs.b 1
frK_Drown:	rs.b 1
frK_Burnt:	rs.b 1
frK_Hurt:	rs.b 1
frK_Slide:	rs.b 1
frK_Bubble:	rs.b 1
frK_Spindash1:	rs.b 1
frK_Spindash2:	rs.b 1
frK_Spindash3:	rs.b 1
frK_Spindash4:	rs.b 1
frK_Spindash5:	rs.b 1
frK_Spindash6:	rs.b 1
frK_GlideF1:	rs.b 1
frK_GlideF2:	rs.b 1
frK_GlideS1:	rs.b 1
frK_GlideS2:	rs.b 1
frK_Climb1:	rs.b 1
frK_Climb2:	rs.b 1
frK_Climb3:	rs.b 1
frK_Climb4:	rs.b 1
frK_Climb5:	rs.b 1
frK_Climb6:	rs.b 1
; Climb up
frK_Climb7:	rs.b 1
frK_Climb8:	rs.b 1
frK_Climb9:	rs.b 1
frK_Mach11:	rs.b 1
frK_Mach12:	rs.b 1
frK_Mach13:	rs.b 1
frK_Mach14:	rs.b 1
frK_Mach21:	rs.b 1
frK_Mach22:	rs.b 1
frK_Mach23:	rs.b 1
frK_Mach24:	rs.b 1
frK_Mach31:	rs.b 1
frK_Mach32:	rs.b 1
frK_Mach33:	rs.b 1
frK_Mach34:	rs.b 1
frK_Mach41:	rs.b 1
frK_Mach42:	rs.b 1
frK_Mach43:	rs.b 1
frK_Mach44:	rs.b 1
frK_Victory1:	rs.b 1
frK_Victory2:	rs.b 1
frK_Corkscrew1:	rs.b 1
frK_Corkscrew2:	rs.b 1
frK_Corkscrew3:	rs.b 1
frK_Corkscrew4:	rs.b 1
frK_Corkscrew5:	rs.b 1
frK_Corkscrew6:	rs.b 1
frK_Corkscrew7:	rs.b 1
frK_Corkscrew8:	rs.b 1
frK_Corkscrew9:	rs.b 1
frK_CorkscrewA:	rs.b 1
frK_CorkscrewB:	rs.b 1
frK_CorkscrewC:	rs.b 1
frK_Zipline1:	rs.b 1
frK_Zipline2:	rs.b 1
frK_Transform1:	rs.b 1
frK_Transform2:	rs.b 1
frK_Transform3:	rs.b 1
frK_Transform4:	rs.b 1
frK_ClimbD1:	rs.b 1
frK_ClimbD2:	rs.b 1
frK_ClimbDr1:	rs.b 1
frK_ClimbDr2:	rs.b 1
frK_ClimbDr3:	rs.b 1
frK_ClimbDr4:	rs.b 1
frK_ClimbI:	rs.b 1

idK_Gliding = $20
idK_FallFromGlide = $21
idK_GetUp = $22
idK_HardFall = $23