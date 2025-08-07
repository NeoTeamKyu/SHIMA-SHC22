SonicMap:
SonicMap_0: 	dc.w SonicMap_8-SonicMap
SonicMap_2: 	dc.w SonicMap_13-SonicMap
SonicMap_4: 	dc.w SonicMap_23-SonicMap
SonicMap_6: 	dc.w SonicMap_33-SonicMap
SonicMap_8: 	dc.b $2
	dc.b $FE, $0, $40, $0, $F0
	dc.b $FE, $8, $60, $1, $F8
SonicMap_13: 	dc.b $3
	dc.b $FE, $0, $40, $0, $F0
	dc.b $0, $4, $60, $4, $F8
	dc.b $8, $4, $60, $6, $0
SonicMap_23: 	dc.b $3
	dc.b $FE, $0, $40, $0, $F0
	dc.b $FC, $4, $60, $8, $F8
	dc.b $F4, $4, $60, $A, $0
SonicMap_33: 	dc.b $2
	dc.b $FE, $0, $48, $0, $8
	dc.b $FE, $8, $68, $1, $F0
	even