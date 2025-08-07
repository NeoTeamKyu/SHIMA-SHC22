Credits_MapLoad:
		lea	($FF0000).l,a1
		cmpi.w	#0,(v_creditsnum).w ; is credit id = 0?
		bne.s	EniCred1	 ; if not, branch
		lea	(EniCred_0).l,a0 ; load credits enigma mappings
EniCred1:
		cmpi.w	#1,(v_creditsnum).w ; is credit id = 1?
		bne.s	EniCred2	 ; if not, branch
		lea	(EniCred_1).l,a0 ; load credits enigma mappings
EniCred2:
		cmpi.w	#2,(v_creditsnum).w ; is credit id = 2?
		bne.s	EniCred3	 ; if not, branch
		lea	(EniCred_2).l,a0 ; load credits enigma mappings
EniCred3:
		cmpi.w	#3,(v_creditsnum).w ; is credit id = 3?
		bne.s	EniCred4	 ; if not, branch
		lea	(EniCred_3).l,a0 ; load credits enigma mappings
EniCred4:
		cmpi.w	#4,(v_creditsnum).w ; is credit id = 4?
		bne.s	EniCred5	 ; if not, branch
		lea	(EniCred_4).l,a0 ; load credits enigma mappings
EniCred5:
		cmpi.w	#5,(v_creditsnum).w ; is credit id = 5?
		bne.s	EniCred6	 ; if not, branch
		lea	(EniCred_5).l,a0 ; load credits enigma mappings
EniCred6:
		cmpi.w	#6,(v_creditsnum).w ; is credit id = 6?
		bne.s	EniCred7	 ; if not, branch
		lea	(EniCred_6).l,a0 ; load credits enigma mappings
EniCred7:
		cmpi.w	#7,(v_creditsnum).w ; is credit id = 7?
		bne.s	EniCred8	 ; if not, branch
		lea	(EniCred_7).l,a0 ; load credits enigma mappings
EniCred8:
		cmpi.w	#8,(v_creditsnum).w ; is credit id = 8?
		bne.s	EniCred9	 ; if not, branch
		lea	(EniCred_8).l,a0 ; load credits enigma mappings
EniCred9:
		cmpi.w	#9,(v_creditsnum).w ; is credit id = 9?
		bne.s	EniCredLoad	 ; if not, branch
		lea	(EniCred_9).l,a0 ; load credits enigma mappings
EniCredLoad:
		move.w	#0,d0
		jsr	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#39,d1		 ; X size = 40
		moveq	#27,d2		 ; Y size = 28
		jsr	TilemapToVRAM
EniCredEnd:
		rts