LevelOrder:
		; Blossom Gardens Zone
		dc.b id_BGZ, 1	; Act 1
		dc.b id_BGZ, 2	; Act 2
		dc.b id_MHZ, 0	; Act 3
		dc.b 0, 0		; Legacy BGZ

		; Labyrinth Zone
		dc.b id_LZ, 1	; Act 1
		dc.b id_LZ, 2	; Act 2
		dc.b id_SYZ, 0	; Act 3
		dc.b id_SBZ, 2	; Scrap Brain Zone Act 3

		; Marble Zone
		dc.b id_MZ, 1	; Act 1
		dc.b id_MZ, 2	; Act 2
		dc.b id_LZ, 0	; Act 3
		dc.b 0, 0

		; Star Light Zone
		dc.b id_SLZ, 1	; Act 1
		dc.b id_SLZ, 2	; Act 2
		dc.b id_TMZ, 0	; Act 3
		dc.b 0, 0

		; Spring Yard Zone
		dc.b id_SYZ, 1	; Act 1
		dc.b id_SYZ, 2	; Act 2
		dc.b id_SLZ, 0	; Act 3
		dc.b 0, 0

		; Scrap Brain Zone
		dc.b id_SBZ, 1	; Act 1
		dc.b id_LZ, 3	; Act 2
		dc.b 0, 0		; Final Zone
		dc.b 0, 0

		; Melting Heights Zone
		dc.b id_MHZ, 1	; Act 1
		dc.b id_MHZ, 2	; Act 2
		dc.b id_MZ, 0	; Act 3
		dc.b 0, 0
		even

		; Hidden Palace Zone
		dc.b id_HPZ, 1	; Act 1
		dc.b id_HPZ, 2	; Act 2
		dc.b 0, 0		; Act 3
		dc.b 0, 0
		even

		; The Magnet Zone
		dc.b id_TMZ, 1
		dc.b id_TMZ, 2
		dc.b id_SBZ, 0
		dc.b 0, 0
		even

		zonewarning LevelOrder,8
