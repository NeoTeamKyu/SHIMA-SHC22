; ---------------------------------------------------------------------------
; Sonic start location array
; ---------------------------------------------------------------------------

		incbin	"Level Data/Start Positions/bgz1.bin"
		incbin	"Level Data/Start Positions/bgz2.bin"
		incbin	"Level Data/Start Positions/bgz3.bin"
		incbin	"Level Data/Start Positions/lbgz.bin"

		incbin	"Level Data/Start Positions/lz1.bin"
		incbin	"Level Data/Start Positions/lz2.bin"
		incbin	"Level Data/Start Positions/lz3.bin"
		incbin	"Level Data/Start Positions/sbz3.bin"

		incbin	"Level Data/Start Positions/mz1.bin"
		incbin	"Level Data/Start Positions/mz2.bin"
		incbin	"Level Data/Start Positions/mz3.bin"
		dc.w	$80,$A8

		incbin	"Level Data/Start Positions/slz1.bin"
		incbin	"Level Data/Start Positions/slz2.bin"
		incbin	"Level Data/Start Positions/slz3.bin"
		dc.w	$80,$A8

		incbin	"Level Data/Start Positions/syz1.bin"
		incbin	"Level Data/Start Positions/syz2.bin"
		incbin	"Level Data/Start Positions/syz3.bin"
		dc.w	$80,$A8

		incbin	"Level Data/Start Positions/sbz1.bin"
		incbin	"Level Data/Start Positions/sbz2.bin"
		incbin	"Level Data/Start Positions/fz.bin"
		dc.w	$80,$A8

        incbin  "Level Data/Start Positions/mhz1.bin"
        incbin  "Level Data/Start Positions/mhz2.bin"
        incbin  "Level Data/Start Positions/mhz3.bin"
		dc.w	$80,$A8

        incbin  "Level Data/Start Positions/hpz1.bin"
        incbin  "Level Data/Start Positions/hpz2.bin"
        incbin  "Level Data/Start Positions/hpz3.bin"
		dc.w	$80,$A8

        incbin  "Level Data/Start Positions/tmz1.bin"
        incbin  "Level Data/Start Positions/tmz2.bin"
        incbin  "Level Data/Start Positions/tmz3.bin"
		dc.w	$80,$A8

		zonewarning StartLocArray,$10

		incbin	"Level Data/Start Positions/end1.bin"
		incbin	"Level Data/Start Positions/end2.bin"
		dc.w	$80,$A8
		dc.w	$80,$A8

		even
