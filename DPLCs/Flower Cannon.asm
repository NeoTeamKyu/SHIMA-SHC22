FlowerCannon_PLC:
FlowerCannon_PLC_0: 	dc.w FlowerCannon_PLC_8-FlowerCannon_PLC
FlowerCannon_PLC_2: 	dc.w FlowerCannon_PLC_D-FlowerCannon_PLC
FlowerCannon_PLC_4: 	dc.w FlowerCannon_PLC_12-FlowerCannon_PLC
FlowerCannon_PLC_6: 	dc.w FlowerCannon_PLC_15-FlowerCannon_PLC
FlowerCannon_PLC_8: 	dc.b $2
	dc.b $F0, $0
	dc.b $0, $10
FlowerCannon_PLC_D: 	dc.b $2
	dc.b $F0, $11
	dc.b $20, $21
FlowerCannon_PLC_12: 	dc.b $1
	dc.b $F0, $24
FlowerCannon_PLC_15: 	dc.b $2
	dc.b $F0, $34
	dc.b $0, $44
	even