Explosion_Map:
Explosion_Map_0: 	dc.w Explosion_Map_A-Explosion_Map
Explosion_Map_2: 	dc.w Explosion_Map_1F-Explosion_Map
Explosion_Map_4: 	dc.w Explosion_Map_25-Explosion_Map
Explosion_Map_6: 	dc.w Explosion_Map_2B-Explosion_Map
Explosion_Map_8: 	dc.w Explosion_Map_40-Explosion_Map
Explosion_Map_A: 	dc.b $4
	dc.b $F8, $1, $20, $0, $F8
	dc.b $FC, $0, $20, $2, $F0
	dc.b $F8, $1, $28, $0, $0
	dc.b $FC, $0, $28, $2, $8
Explosion_Map_1F: 	dc.b $1
	dc.b $F0, $F, $20, $3, $F0
Explosion_Map_25: 	dc.b $1
	dc.b $F0, $F, $20, $13, $F0
Explosion_Map_2B: 	dc.b $4
	dc.b $EC, $A, $20, $23, $EC
	dc.b $EC, $5, $20, $2C, $4
	dc.b $4, $5, $38, $2C, $EC
	dc.b $FC, $A, $38, $23, $FC
Explosion_Map_40: 	dc.b $4
	dc.b $EC, $A, $20, $30, $EC
	dc.b $EC, $5, $20, $39, $4
	dc.b $4, $5, $38, $39, $EC
	dc.b $FC, $A, $38, $30, $FC
	even