; ---------------------------------------------------------------------------
; Animation script - Tails
; ---------------------------------------------------------------------------
TailsAniData:
		dc.w TailsAni_Walk-TailsAniData	;  0 ;   0
		dc.w TailsAni_Run-TailsAniData		;  1 ;   1
		dc.w TailsAni_Roll-TailsAniData	;  2 ;   2
		dc.w TailsAni_Roll2-TailsAniData	;  3 ;   3
		dc.w TailsAni_Push-TailsAniData	;  4 ;   4
		dc.w TailsAni_Wait-TailsAniData	;  5 ;   5
		dc.w TailsAni_Balance-TailsAniData	;  6 ;   6
		dc.w TailsAni_LookUp-TailsAniData	;  7 ;   7
		dc.w TailsAni_Duck-TailsAniData	;  8 ;   8
		dc.w TailsAni_Spindash-TailsAniData	;  9 ;   9
		dc.w TailsAni_Fall-TailsAniData	; 10 ;  $A
		dc.w TailsAni_Balance2-TailsAniData	; 11 ;  $B
		dc.w TailsAni_Blank-TailsAniData	; 12 ;  $C
		dc.w TailsAni_Stop-TailsAniData	; 13 ;  $D
		dc.w TailsAni_Float-TailsAniData	; 14 ;  $E
		dc.w TailsAni_Float2-TailsAniData	; 15 ;  $F
		dc.w TailsAni_Spring-TailsAniData	; 16 ; $10
		dc.w TailsAni_Hang-TailsAniData	; 17 ; $11
		dc.w TailsAni_Blink-TailsAniData	; 18 ; $12
		dc.w TailsAni_Blink2-TailsAniData	; 19 ; $13
		dc.w TailsAni_Blank-TailsAniData	; 20 ; $14
		dc.w TailsAni_Bubble-TailsAniData	; 21 ; $15
		dc.w TailsAni_DeathBW-TailsAniData	; 22 ; $16
		dc.w TailsAni_Drown-TailsAniData	; 23 ; $17
		dc.w TailsAni_Death-TailsAniData	; 24 ; $18
		dc.w TailsAni_Hurt-TailsAniData	; 25 ; $19
		dc.w TailsAni_Hurt-TailsAniData	; 26 ; $1A
		dc.w TailsAni_Slide-TailsAniData	; 27 ; $1B
		dc.w TailsAni_Blank-TailsAniData	; 28 ; $1C
		dc.w TailsAni_Float3-TailsAniData	; 29 ; $1D
		dc.w TailsAni_Float4-TailsAniData	; 30 ; $1E
		dc.w TailsAni_HaulAss-TailsAniData	; 31 ; $1F
		dc.w TailsAni_FlyFast-TailsAniData	; 32 ; $20
		dc.w TailsAni_Fly-TailsAniData		; 33 ; $21
		dc.w TailsAni_FlyTired-TailsAniData	; 34 ; $22
		dc.w TailsAni_Swim-TailsAniData	; 35 ; $23
		dc.w TailsAni_SwimTired-TailsAniData	; 36 ; $24
		dc.w TailsAni_Swim2-TailsAniData	; 37 ; $25
		dc.w TailsAni_Victory-TailsAniData	; 38 ; $26
		dc.w TailsAni_Transform-TailsAniData; 39 ; $27

TailsAni_Walk:	dc.b $FF,frT_walk13,frT_walk14,frT_walk15,frT_walk16,frT_walk17,frT_walk18, frT_walk11, frT_walk12,afEnd
		even
TailsAni_Run:	dc.b $FF,frT_run11,frT_run12,frT_run13,frT_run14,afEnd,afEnd,afEnd,afEnd,afEnd
		even
TailsAni_Roll:	dc.b   1,frT_roll3,frT_roll2,frT_roll1,afEnd
		even
TailsAni_Roll2:	dc.b   1,frT_roll3,frT_roll2,frT_roll1,afEnd
		even
TailsAni_Push:	dc.b $FD,frT_push1,frT_push2,frT_push3,frT_push4,afEnd,afEnd,afEnd,afEnd,afEnd
		even
TailsAni_Wait:	dc.b   7,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Wait2,  frT_Wait1,  frT_Stand,  frT_Stand,  frT_Stand
		dc.b   frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Wait2,  frT_Wait1,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Stand,  frT_Wait3
		dc.b   frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3,  frT_Wait3
		dc.b   frT_Wait4,  frT_Wait5,  frT_Wait6,  frT_Wait5,  frT_Wait6,  frT_Wait5,  frT_Wait6,  frT_Wait5,  frT_Wait6,  frT_Wait5,  frT_Wait6,  frT_Wait4,afBack,$1C
		even
TailsAni_Balance:	dc.b   9,frT_BalanceA1,frT_BalanceA2,frT_BalanceA3,frT_BalanceA4,afEnd
		even
TailsAni_LookUp:	dc.b 5, frT_Look1, frT_Look2, afBack, 1
		even
TailsAni_Duck:	dc.b 5, frT_Duck1, frT_Duck2, afBack, 1
		even
TailsAni_Spindash:	dc.b   0,frT_Spindash1,frT_Spindash2,frT_Spindash1,frT_Spindash3,frT_Spindash1,frT_Spindash4,frT_Spindash1,frT_Spindash5,frT_Spindash1,frT_Spindash6,afEnd
		even
TailsAni_Fall:	dc.b 2, frT_FallT, frT_Fall1, frT_Fall2, afBack, 2
		even
TailsAni_Balance2:	dc.b	9,frT_BalanceB1,frT_BalanceB2,frT_BalanceB3,afEnd
		even
TailsAni_Stop:		dc.b   7,frT_Skid1,frT_Skid2,frT_Skid1,frT_Skid2,frT_SkidT1, frT_SkidT2, afBack, 1
		even
TailsAni_Float:		dc.b   9,frT_FloatAlt1,frT_FloatAlt2,afEnd
		even
TailsAni_Float2:	dc.b   4,frT_Float1, frT_Float2, frT_Float3, frT_Float4, frT_Float5, frT_Float6, frT_Float7, frT_Float8, frT_Float9, frT_FloatA,afEnd
		even
TailsAni_Spring:	dc.b   3,frT_Spring1,frT_Spring2, afEnd
		even
TailsAni_Hang:		dc.b   5,frT_Hang1,frT_Hang2,afEnd
		even
TailsAni_Blink:		dc.b  $F,  frT_Stand,  frT_Wait1,  frT_Wait2,afBack,  1
		even
TailsAni_Blink2:	dc.b  $F,  frT_Stand,  frT_Wait1,afBack,  1
		even
TailsAni_Bubble:	dc.b  $B,frT_Bubble,frT_Bubble,frT_Walk15,frT_Walk16,afChange,  0
		even
TailsAni_DeathBW:	dc.b $20,frT_Toasty,afEnd
		even
TailsAni_Drown:		dc.b $2F,frT_Drown,afEnd
		even
TailsAni_Death:		dc.b   $20,frT_Dead,afChange,$1B
		even
TailsAni_Hurt:		dc.b   3,frT_Hurt,afEnd
		even
TailsAni_Slide:		dc.b   9,frT_Slide,frT_Hurt,afEnd
		even
TailsAni_Blank:		dc.b $77,  frT_Null,afEnd
		even
TailsAni_Float3:	dc.b   2,frT_Float1, frT_Float2, frT_Float3, frT_Float4, frT_Float5, frT_Float6, frT_Float7, frT_Float8, frT_Float9, frT_FloatA,afEnd
		even
TailsAni_Float4:	dc.b   5,frT_Float1,afChange, 0
		even
TailsAni_HaulAss:	dc.b $FF,frT_Mach11,frT_Mach12,frT_Mach13, frT_Mach14,afEnd,afEnd,afEnd,afEnd,afEnd
		even
TailsAni_FlyFast:		dc.b   1,frT_Fly,afEnd
		even
TailsAni_Fly:		dc.b   1,frT_Fly,afEnd
		even
TailsAni_FlyTired:	dc.b	$16,frT_FlyTired1,frT_FlyTired2,afEnd
		even
TailsAni_Swim:	dc.b	7,	frT_Swim1,	frT_Swim2,	frT_Swim3,	frT_Swim4,	frT_Swim5,	afEnd
		even
TailsAni_SwimTired:	dc.b	$B,	frT_SwimTired1,	frT_SwimTired2,	frT_SwimTired3,	afEnd
		even
TailsAni_Swim2:	dc.b	3,	frT_Swim1,	frT_Swim2,	frT_Swim3,	frT_Swim4,	frT_Swim5,	afEnd
		even
TailsAni_Victory:	dc.b	4, frT_Victory1, frT_Victory2, frT_Victory3, frT_Victory4, frT_Victory5, frT_Victory6, frT_Victory7, frT_Victory8, afBack, 1
		even
TailsAni_Transform:	dc.b	2, frT_Tran1,	frT_Tran1, frT_Tran2, frT_Tran3, frT_Tran2, frT_Tran3, frT_Tran2, frT_Tran3, frT_Tran2,	frT_Tran3, frT_Tran2, frT_Tran3, afChange,   id_Walk
		even

; Tails frame IDs
	rsreset
frT_Null:	rs.b 1

frT_Stand:	rs.b 1
frT_Wait1:	rs.b 1
frT_Wait2:	rs.b 1
frT_Wait3:	rs.b 1
frT_Wait4:	rs.b 1
frT_Wait5:	rs.b 1
frT_Wait6:	rs.b 1

frT_Look1:	rs.b 1
frT_Look2:	rs.b 1

frT_walk11:	rs.b 1
frT_walk12:	rs.b 1
frT_walk13:	rs.b 1
frT_walk14:	rs.b 1
frT_walk15:	rs.b 1
frT_walk16:	rs.b 1
frT_walk17:	rs.b 1
frT_walk18:	rs.b 1
frT_walk21:	rs.b 1
frT_walk22:	rs.b 1
frT_walk23:	rs.b 1
frT_walk24:	rs.b 1
frT_walk25:	rs.b 1
frT_walk26:	rs.b 1
frT_walk27:	rs.b 1
frT_walk28:	rs.b 1
frT_walk31:	rs.b 1
frT_walk32:	rs.b 1
frT_walk33:	rs.b 1
frT_walk34:	rs.b 1
frT_walk35:	rs.b 1
frT_walk36:	rs.b 1
frT_walk37:	rs.b 1
frT_walk38:	rs.b 1
frT_walk41:	rs.b 1
frT_walk42:	rs.b 1
frT_walk43:	rs.b 1
frT_walk44:	rs.b 1
frT_walk45:	rs.b 1
frT_walk46:	rs.b 1
frT_walk47:	rs.b 1
frT_walk48:	rs.b 1

frT_run11:	rs.b 1
frT_run12:	rs.b 1
frT_run13:	rs.b 1
frT_run14:	rs.b 1
frT_run21:	rs.b 1
frT_run22:	rs.b 1
frT_run23:	rs.b 1
frT_run24:	rs.b 1
frT_run31:	rs.b 1
frT_run32:	rs.b 1
frT_run33:	rs.b 1
frT_run34:	rs.b 1
frT_run41:	rs.b 1
frT_run42:	rs.b 1
frT_run43:	rs.b 1
frT_run44:	rs.b 1

frT_mach11:	rs.b 1
frT_mach12:	rs.b 1
frT_mach13:	rs.b 1
frT_mach14:	rs.b 1
frT_mach21:	rs.b 1
frT_mach22:	rs.b 1
frT_mach23:	rs.b 1
frT_mach24:	rs.b 1
frT_mach31:	rs.b 1
frT_mach32:	rs.b 1
frT_mach33:	rs.b 1
frT_mach34:	rs.b 1
frT_mach41:	rs.b 1
frT_mach42:	rs.b 1
frT_mach43:	rs.b 1
frT_mach44:	rs.b 1

frT_Roll1:	rs.b 1
frT_Roll2:	rs.b 1
frT_Roll3:	rs.b 1
frT_Roll4:	rs.b 1

frT_Spring1:rs.b 1
frT_Spring2:rs.b 1
frT_FallT:	rs.b 1
frT_Fall1:	rs.b 1
frT_Fall2:	rs.b 1

frT_Duck1:	rs.b 1
frT_Duck2:	rs.b 1

frT_Hurt:	rs.b 1
frT_Slide:	rs.b 1

frT_Dead:	rs.b 1
frT_Toasty:	rs.b 1
frT_Drown:	rs.b 1

frT_Spindash1:	rs.b 1
frT_Spindash2:	rs.b 1
frT_Spindash3:	rs.b 1
frT_Spindash4:	rs.b 1
frT_Spindash5:	rs.b 1
frT_Spindash6:	rs.b 1

frT_Push1:	rs.b 1
frT_Push2:	rs.b 1
frT_Push3:	rs.b 1
frT_Push4:	rs.b 1

frT_Skid1:	rs.b 1
frT_Skid2:	rs.b 1
frT_SkidT1:	rs.b 1
frT_SkidT2:	rs.b 1

frT_BalanceA1:	rs.b 1
frT_BalanceA2:	rs.b 1
frT_BalanceA3:	rs.b 1
frT_BalanceA4:	rs.b 1
frT_BalanceB1:	rs.b 1
frT_BalanceB2:	rs.b 1
frT_BalanceB3:	rs.b 1

frT_Hang1:	rs.b 1
frT_Hang2:	rs.b 1

frT_Float1:	rs.b 1
frT_Float2:	rs.b 1
frT_Float3:	rs.b 1
frT_Float4:	rs.b 1
frT_Float5:	rs.b 1
frT_Float6:	rs.b 1
frT_Float7:	rs.b 1
frT_Float8:	rs.b 1
frT_Float9:	rs.b 1
frT_FloatA:	rs.b 1
frT_FloatAlt1:	rs.b 1
frT_FloatAlt2:	rs.b 1

frT_Bubble:	rs.b 1

frT_Fly:	rs.b 1
frT_FlyTired1:	rs.b 1
frT_FlyTired2:	rs.b 1
frT_Swim1:	rs.b 1
frT_Swim2:	rs.b 1
frT_Swim3:	rs.b 1
frT_Swim4:	rs.b 1
frT_Swim5:	rs.b 1
frT_SwimTired1:	rs.b 1
frT_SwimTired2:	rs.b 1
frT_SwimTired3:	rs.b 1

frT_Victory1:	rs.b 1
frT_Victory2:	rs.b 1
frT_Victory3:	rs.b 1
frT_Victory4:	rs.b 1
frT_Victory5:	rs.b 1
frT_Victory6:	rs.b 1
frT_Victory7:	rs.b 1
frT_Victory8:	rs.b 1

frT_Corkscrew1:	rs.b 1
frT_CorkShit:	rs.b 11

frT_Zipline1:	rs.b 1
frT_Zipline2:	rs.b 1
frT_Zipline3:	rs.b 1

frT_Tran1:		rs.b 1
frT_Tran2:		rs.b 1
frT_Tran3:		rs.b 1