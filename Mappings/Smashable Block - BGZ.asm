Map_Break:
Map_Break_0: 	dc.w Map_Break_6-Map_Break
Map_Break_2: 	dc.w Map_Break_1B-Map_Break
Map_Break_4: 	dc.w Map_Break_30-Map_Break
Map_Break_6: 	dc.b $4
	dc.b $F0, $5, $0, $26, $F0
	dc.b $F0, $5, $0, $2A, $0
	dc.b $0, $5, $0, $2E, $F0
	dc.b $0, $5, $0, $2E, $0
Map_Break_1B: 	dc.b $4
	dc.b $F0, $5, $0, $2E, $F0
	dc.b $F0, $5, $0, $2E, $0
	dc.b $0, $5, $0, $2E, $F0
	dc.b $0, $5, $0, $2E, $0
Map_Break_30: 	dc.b $6
	dc.b $F0, $5, $0, $72, $F0
	dc.b $F0, $5, $0, $72, $0
	dc.b $0, $1, $0, $76, $F0
	dc.b $0, $1, $18, $76, $8
	dc.b $0, $4, $8, $76, $F8
	dc.b $8, $4, $10, $76, $F8
	even