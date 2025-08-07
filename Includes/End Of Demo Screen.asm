; ============================================================================================
; Splash Screen code (original code by Hitaxas and ported to Sonic 1 by ProjectFM)
; ============================================================================================
GM_EndOfDemo:
;		music	mus_Stop
		jsr PaletteFadeOut.w ; fade palettes out
		jsr	ClearScreen	
		; load art, mappings and the palette
		lea (v_128x128).l,a1 ; load dump location
		lea Map_EOD.l,a0 ; load compressed mappings address
		move.w #320,d0 ; prepare pattern index value to patch to mappings
		jsr EniDec.w ; decompress and dump
		lea (v_128x128).l,a1
		move.l #$60000003,d0
		moveq #39,d1
		moveq #30,d2
		jsr TilemapToVRAM.w ; flush mappings to VRAM
		move.l #$68000000,($FFC00004).l ; set vdp loc
		lea Nem_EOD.l,a0 ; load background art
		jsr NemDec ; run NemDec to decompress art for display

EODScreen_PalLoop1:		
		move.l	d0,(a1)+
		dbf		d1,EODScreen_PalLoop1 ; fill palette with black
		moveq	#palid_EOD,d0	; load EOD's palette
		jsr	PalLoad1	; load EOD's palette

EODScreen_PalLoop2:
		move.l (a0)+,(a1)+ ; copy colours to buffer
		move.l (a0)+,(a1)+ ; ''
		dbf d0,EODScreen_PalLoop2 ; repeat until done
		jsr PaletteFadeIn ; fade palette in

waitStartSplashScreen:
        jsr    ReadJoypads
        andi.b    #$80,(v_jpadpress1).w ; is    Start button pressed?
        beq.s    waitStartSplashScreen        ; if not, branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts ; return
		
Map_EOD:	incbin		"Tilemaps/End Of Demo.bin"
					even
	
Nem_EOD:	incbin		"art/nemesis/End Of Demo.bin"
					even
					
Pal_EOD:	incbin		"palette/End Of Demo.bin"
					even					