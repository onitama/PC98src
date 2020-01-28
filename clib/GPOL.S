q_y	equ	30
mae	equ	50
;------------------------------------------------------------------------------
;
;	ÇgÅDÇ`ÅDÇhÅDÇìÇôÇìÇîÇÖÇçÅ@É|ÉäÉSÉìÉâÉCÉuÉâÉäÅ[Ç»ÇÃÇ≈Ç∑ÅB
;						By FoZon(TOOX)
;
;						Ver 1.0  04:05:28
;
;	pol_set_c();				/*âÊñ ÇÃê›íËä÷åWÇ≈Ç∑ÅB*/
;	pol_g_set();				/*âÊñ ÇÃÉTÉCÉYÇê›íËÇµÇ‹Ç∑*/
;	pol_set();				/*É|ÉäÉSÉìâÊñ ÇÃèâä˙ê›íËÇ≈Ç∑*/
;	pol_start();				/*É|ÉäÉSÉìDATAÇÃèâä˙Ç©
;	pol_map(sg);				/*É|ÉäÉSÉìDATAåvéZèIóπ*/
;	pol_add(my_x,my_y,my_z,cos a,sin a,sg);	/*É|ÉäÉSÉìDATAÇÃåvéZ*/
;	pol_end(my_x,my_y,my_z,cos a,sin a,sg);	/*É|ÉäÉSÉìDATAÇÃåvéZ*/
;	pol(sg);				/*É|ÉäÉSÉìÇÇfÇnÇfÇnÇ∑ÇÈÇÒÇæ*/
;------------------------------------------------------------------------------

.MODEL	SMALL

ARGS	STRUC

arg_01		dw	?
arg_02		dw	?
arg_03		dw	?
arg_04		dw	?
arg_05		dw	?
arg_06		dw	?
arg_07		dw	?

ARGS	ENDS

;------------------------------------------------------------------------------
;	ÇcÇ`ÇsÇ`Å@ÇrÇdÇfÇlÇdÇmÇs
;------------------------------------------------------------------------------

DGROUP	GROUP	_DATA
_DATA	segment	word public 'DATA'

set_01		dw	?
set_02		dw	?
set_03		dw	?
set_04		dw	?
set_05		dw	?
set_06		dw	?
set_07		dw	?

TAI11		dw		?
TAI12		dw		?
TAICX		dw		?

MYXX		dw		0
MYYY		dw		0
MYZZ		dw		0


MAPK		dw		?
MAPDATA1	db		20*500 DUP(?)
MAPDATA2	db		20*500 DUP(?)

POINT_X1	dw		?		;POINT1z
POINT_Y1	dw		?
POINT_Z1	dw		?
POINT_X2	dw		?		;POINT2
POINT_Y2	dw		?
POINT_Z2	dw		?
POINT_X3	dw		?		;POINT3
POINT_Y3	dw		?
POINT_Z3	dw		?

PO_X1		dw		?		;PO1
PO_Y1		dw		?
PO_X2		dw		?		;PO2
PO_Y2		dw		?
PO_X3		dw		?		;PO3
PO_Y3		dw		?

KATA1		dw		?
KATA2		dw		?
KATA3		dw		?
TA_X1		dw		?
TA_X2		dw		?

YYTT		db		0

PO1		dw		?		;ÇoÇnÇhÇmÇsÇPÇÃÇwç¿ïW
PO2		dw		?		;ÇoÇnÇhÇmÇsÇQÇÃÇwç¿ïW
POYY		dw		?
POC		db		0

PO1A		db		?		;ÉâÉCÉìåvéZópÉoÉbÉtÉ@
PO1B		db		?
PO2A		db		?
PO2B		db		?
POX		db		?
POY		db		?		;ÇoÇnÇhÇmÇsÅ@Çxç¿ïW
POB1		db		010101010B
POB2		db		011111111B
PO		db		0

ppp		db		0

PO_DATA1	db		011111111B	;0
		db		001111111B	;1
		db		000111111B	;2
		db		000011111B	;3
		db		000001111B	;4
		db		000000111B	;5
		db		000000011B	;6
		db		000000001B	;7
		
PO_DATA2	db		010000000B	;0
		db		011000000B	;1
		db		011100000B	;2
		db		011110000B	;3
		db		011111000B	;4
		db		011111100B	;5
		db		011111110B	;6
		db		011111111B	;7

COLOR_DATA1	DW	00000H				;COLOR0
COLOR_DATA2	DW	00000H
		DB	0FFH,000H,000H,000H		;COLOR1
		DB	000H,0FFH,000H,000H		;COLOR2
		DB	0FFH,0FFH,000H,000H		;COLOR3
		DB	000H,000H,0FFH,000H		;COLOR4
		DB	0FFH,000H,0FFH,000H		;COLOR5
		DB	000H,0FFH,0FFH,000H		;COLOR6
		DB	0FFH,0FFH,0FFH,000H		;COLOR7
		DB	000H,000H,000H,0FFH		;COLOR8
		DB	0FFH,000H,000H,0FFH		;COLOR9
		DB	000H,0FFH,000H,0FFH		;COLOR10
		DB	0FFH,0FFH,000H,0FFH		;COLOR11
		DB	000H,000H,0FFH,0FFH		;COLOR12
		DB	0FFH,000H,0FFH,0FFH		;COLOR13
		DB	000H,0FFH,0FFH,0FFH		;COLOR14
		DB	0FFH,0FFH,0FFH,0FFH		;COLOR15

iti_xx		dw	?

x_set		dw	310
y_set		dw	200
xxp_set		dw	160*16
xx_set		dw	160*16
yy_set		dw	100
set		dw	0

_DATA		ENDS

;------------------------------------------------------------------------------
;	ÇbÇnÇcÇdÅ@ÇrÇdÇfÇlÇdÇmÇs
;------------------------------------------------------------------------------

sub_program	segment byte public 'CODE'
		assume	cs:sub_program,ds:DGROUP

	PUBLIC	_pol_set
	PUBLIC	_pol_g_set

	PUBLIC	_pol_start
	PUBLIC	_pol_map
	PUBLIC	_pol_add
	PUBLIC	_pol_end
	PUBLIC	_pol

	PUBLIC	_pol_set_c

;------------------------------------------------------------------------------
;
;	É|ÉäÉSÉìêßå‰ä÷êîÇ≈Ç∑Ç™Ç»Ç±ÇÍÇ™ÅI
;
;	pol(sg1,ad)
;
;	sg1	:É|ÉäÉSÉìÇÃÇRéüå≥DATAÇ™ì¸Ç¡ÇƒÇ¢ÇÈÉZÉOÉÅÉìÉg
;		 ó·Å@énÇﬂÇÃÇPÉrÉbÉgÇÕDATAÇÃêîÇåªÇ∑
;			K,c0,x01,y01,x02,y02,x03,y03
;			  c1,x11,y11,x12,y12,x13,z13
;			  .........
;				K		:É|ÉäÉSÉìÇÃêî (dw [2] byte)
;				c0		:êF(0-15)     (db [1] byte)
;				x01,y01		:ì_ÇÃ2Dç¿ïW   (dw [2] byte)
;	ad	:ï\é¶à íuÇÃê›íËÇçsÇ¡ÇƒÇ¢Ç‹Ç∑
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol	proc	far
	push	bp
	mov	bp,sp
	mov	ax,[bp+6].arg_01
	mov	set_01,ax
	mov	ax,[bp+6].arg_02
	mov	iti_xx,ax
	mov	sp,bp
	pop	bp

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm

	call	pol_01

	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm

	ret

pol_01:	mov	ax,set_01
	mov	es,ax
	mov	si,0
	mov	cx,es:[si]
	inc	si
	inc	si
	cmp	cx,0
	jnz	pol_99
	retn
pol_99:
	MOV	AL,011000000B		;ÇfÇqÇbÇfÅ@ÇnÇm
	OUT	07CH,AL
pol_ne:	
	mov	al,es:[si]		;color set
	mov	POC,al
	mov	ax,es:[si+1]		;point1_x
	mov	PO_X1,ax
	mov	ax,es:[si+3]		;point1_y
	mov	PO_Y1,ax
	mov	ax,es:[si+5]		;point2_x
	mov	PO_X2,ax
	mov	ax,es:[si+7]		;point2_y
	mov	PO_Y2,ax
	mov	ax,es:[si+9]		;point3_x
	mov	PO_X3,ax
	mov	ax,es:[si+11]		;point3_y
	mov	PO_Y3,ax
	add	si,13
	mov	TAI11,cx		;push	cx
	mov	TAI12,es		;push	es
	call	car			;é¿ç€ÇÃï\é¶ä÷åWÇÃÉvÉçÉOÉâÉÄ
	mov	es,TAI12		;pop	es
	mov	cx,TAI11		;pop	cx
	loop	pol_ne

	xor	al,al
	out	07CH,al
	
	retn

;//////////////////////////////////////////////////////////////////////////////
;	PO_X1,PO_Y1<=(POINT1)
;	PO_X2,PO_Y2<=(POINT2)
;	PO_X3,PO_Y3<=(POINT3)
;//////////////////////////////////////////////////////////////////////////////
car:	mov	ax,PO_Y1
	mov	bx,PO_Y2
	cmp	ax,bx
	jge	CARA_P1			;if (PO_Y1 > PO_Y2) then 
	
	mov	PO_Y1,bx
	mov	PO_Y2,ax
	mov	ax,PO_X1
	mov	bx,PO_X2
	mov	PO_X2,ax
	mov	PO_X1,bx
CARA_P1:mov	ax,PO_Y2
	mov	bx,PO_Y3
	cmp	ax,bx
	jge	CARA_P2			;if (PO_Y2 > PO_Y3) then
	mov	PO_Y3,ax
	mov	PO_Y2,bx
	mov	ax,PO_X2
	mov	bx,PO_X3
	mov	PO_X3,ax
	mov	PO_X2,bx
CARA_P2:mov	ax,PO_Y1
	mov	bx,PO_Y2
	cmp	ax,bx
	jge	CARA_P3			;if (PO_Y1 > PO_Y2) then
	mov	PO_Y1,bx
	mov	PO_Y2,ax
	MOV	AX,BX
	mov	cx,PO_X1
	mov	bx,PO_X2
	mov	PO_X2,cx
	mov	PO_X1,bx
CARA_P3:
	AND	AX,AX
	JG	CARA_UU1
	RETN
CARA_UU1:
	MOV	AX,PO_Y3
	CMP	AX,y_set
	JL	CARA_UU
	retn
CARA_UU:
;	MOV	AL,011000000B		;ÇfÇqÇbÇfÅ@ÇnÇm
;	OUT	07CH,AL
	
	MOV	BL,POC			;êFÇÃê›íË
	XOR	BH,BH
	ADD	BX,BX
	ADD	BX,BX
	MOV	AX,COLOR_DATA1[BX]
	OUT	7EH,AL
	XCHG	AL,AH
	OUT	7EH,AL
	MOV	AX,COLOR_DATA2[BX]
	OUT	7EH,AL
	XCHG	AL,AH
	OUT	7EH,AL

	mov	ax,PO_Y1
	cmp	ax,PO_Y2
	jne	CARA_A2
	jmp	CARA_K1
CARA_A2:mov	ax,PO_Y2
	cmp	ax,PO_Y3
	jne	CARA_A1
	jmp	CARA_H1
	
CARA_A1:mov	bx,PO_Y1		;ï\é¶åvéZäJénÇP(Y1>Y2>Y3)
	sub	bx,PO_Y2
	mov	ax,PO_X2
	sub	ax,PO_X1
	cwd
	idiv	bx
	mov	KATA1,ax
	mov	bx,PO_Y1
	sub	bx,PO_Y3
	mov	ax,PO_X3
	sub	ax,PO_X1
	cwd
	idiv	bx
	mov	KATA2,ax
	
	mov	bx,PO_Y2
	sub	bx,PO_Y3
	mov	ax,PO_X3
	sub	ax,PO_X2
	cwd
	idiv	bx
	mov	KATA3,ax
	
	mov	bx,PO_X1
	mov	TA_X1,bx
	mov	dx,PO_X1
	mov	TA_X2,dx
	mov	cx,PO_Y1
	mov	POYY,cx
	mov	ax,PO_Y2
	sub	cx,ax
CAR_L1:	mov	TAICX,cx		;push	cx
	call	LINE
	dec	POYY
	mov	bx,TA_X1
	add	bx,KATA1
	mov	TA_X1,bx
	mov	dx,TA_X2
	add	dx,KATA2
	mov	TA_X2,dx
	mov	cx,TAICX		;pop cx
	loop	CAR_L1
	
	mov	cx,PO_Y2
	mov	ax,PO_Y3
	mov	bx,PO_X2
	mov	TA_X1,bx
	sub	cx,ax
CAR_L2:	mov	TAICX,cx		;push	cx
	call	LINE
	dec	POYY
	mov	bx,TA_X1
	add	bx,KATA3
	mov	TA_X1,bx
	mov	dx,TA_X2
	add	dx,KATA2
	mov	TA_X2,dx
	mov	cx,TAICX		;pop	cx
	loop	CAR_L2
	
;	xor	al,al
;	out	07CH,al
	retn

CARA_K1:mov	ax,PO_Y2
	cmp	ax,PO_Y3
	jne	CARA_KNE
;	xor	al,al
;	out	07CH,al
	retn
	
CARA_KNE:				;ï\é¶åvéZäJénÇQÅiÇxÇPÅÅÇxÇQÅj
	mov	bx,PO_Y1
	sub	bx,PO_Y3
	mov	ax,PO_X3
	sub	ax,PO_X1
	cwd
	idiv	bx
	mov	KATA1,ax
	
	mov	bx,PO_Y2
	sub	bx,PO_Y3
	mov	ax,PO_X3
	sub	ax,PO_X2
	cwd
	idiv	bx
	mov	KATA2,ax

	mov	bx,PO_X1
	mov	TA_X1,bx
	mov	dx,PO_X2
	mov	TA_X2,dx
	mov	cx,PO_Y1
	mov	POYY,cx
	mov	ax,PO_Y3
	sub	cx,ax
CAR_KL1:mov	TAICX,cx		;push	cx
	call	LINE
	dec	POYY
	mov	bx,TA_X1
	add	bx,KATA1
	mov	TA_X1,bx
	mov	dx,TA_X2
	add	dx,KATA2
	mov	TA_X2,dx
	mov	cx,TAICX		;pop	cx
	loop	CAR_KL1
;	xor	al,al
;	out	07CH,al
	retn
	
CARA_H1:				;ï\é¶åvéZäJénÇRÅiÇxÇQÅÅÇxÇRÅj
	mov	bx,PO_Y1
	sub	bx,PO_Y2
	mov	ax,PO_X2
	sub	ax,PO_X1
	cwd
	idiv	bx
	mov	KATA1,ax
	
	mov	bx,PO_Y1
	sub	bx,PO_Y3
	mov	ax,PO_X3
	sub	ax,PO_X1
	cwd
	idiv	bx
	mov	KATA2,ax

	mov	bx,PO_X1
	mov	TA_X1,bx
	mov	dx,PO_X1
	mov	TA_X2,dx
	mov	cx,PO_Y1
	mov	POYY,cx
	
	mov	ax,PO_Y3
	sub	cx,ax
CAR_HL1:mov	TAICX,cx		;push	cx
	call	LINE
	dec	POYY
	mov	bx,TA_X1
	add	bx,KATA1
	mov	TA_X1,bx
	mov	dx,TA_X2
	add	dx,KATA2
	mov	TA_X2,dx
	mov	cx,TAICX		;pop	cx
	loop	CAR_HL1
;	xor	al,al
;	out	07CH,al
	
	retn

;//////////////////////////////////////////////////////////////////////////////
;	ÉâÉCÉìÇà¯Ç≠ÉãÅ[É`ÉìÇ≈Ç∑ÇÃÇ≈
;		PO1	<=Çwç¿ïWÇÃÇPå¬ñ⁄
;		PO2	<=Çwç¿ïWÇÃÇQå¬ñ⁄
;		POY	<-Çxç¿ïW
;	       (POC	<=êFÇ≈Ç∑Ç™ÇbÇcÇfÇÃï˚Ç≈ê›íËÇµÇƒÇ†ÇËÇ‹Ç∑ÅB)
;//////////////////////////////////////////////////////////////////////////////

LINE:	
	MOV	AX,POYY			;Çxç¿ïWê›íË
	CMP	AX,y_set		;200◊≤›ópÇÃåvéZÇæÇÊ
	JC	YY1_01
	retn
YY1_01:
	shl	ax,1			;DI=AX*80
	mov	cx,ax
	shl	ax,1
	shl	ax,1
	add	ax,cx
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,iti_xx
	MOV	DI,AX

	CMP	DX,BX			;ÇoÇnÇPÅÉÇoÇnÇQÇ…ê›íË
	JL	PO1_11
	XCHG	DX,BX
PO1_11:
	MOV	AX,DX			;ÇoÇnÇhÇmÇsÇPÇÃåvéZÇÇµÇ‹Ç∑ÅB
	shr	AX,1
	shr	AX,1
	shr	AX,1
	shr	AX,1
	CMP	AX,x_set
	JC	LI_P2
	CMP	AX,0800H
	JC	LO_P11
	XOR	AX,AX
	JMP	LI_P2
LO_P11:	RETN
LI_P2:	
	MOV	PO1B,AL
	AND	PO1B,0111B
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	MOV	PO1A,AL
	
	MOV	AX,BX			;ÇoÇnÇhÇmÇsÇQÇÃåvéZÇçsÇ¢Ç‹Ç∑ÅB
	shr	AX,1
	shr	AX,1
	shr	AX,1
	shr	AX,1
	CMP	AX,x_set
	JC	LINE_OK
	CMP	AX,0800H
	JC	LI_P21
	RETN
LI_P21:	MOV	AX,x_set
	dec	AX
LINE_OK:
	MOV	PO2B,AL
	AND	PO2B,0111B
	SHR	AX,1
	SHR	AX,1
	SHR	AX,1
	MOV	PO2A,AL
	
	MOV	AX,0A800H
	MOV	ES,AX
	
	MOV	AL,PO1A			;ï\é¶ï™äÚÇP
	MOV	AH,PO2A
	CMP	AL,AH
	JE	LINE_04
LINE_01:				;ÇkÇhÇmÇdï\é¶ÇP
	SUB	AH,AL
	MOV	CL,AH
	XOR	AH,AH
	ADD	DI,AX
	MOV	BX,OFFSET PO_DATA1
	MOV	AL,PO1B
	xlat
	MOV	ES:[DI],AL
	INC	DI

	DEC	CL			;ï\é¶ï™äÚÇQ
	JE	LINE_03
LINE_02:				;ÇkÇhÇmÇdï\é¶ÇQ
	XOR	CH,CH
LINE_L:	MOV	AL,0FFH
	REP	STOSB
LINE_03:				;ÇkÇhÇmÇdï\é¶ÇR
	MOV	BX,OFFSET PO_DATA2
	MOV	AL,PO2B
	xlat
	MOV	ES:[DI],AL
	retn
LINE_04:				;ÇkÇhÇmÇdï\é¶ÇS
	XOR	AH,AH
	ADD	DI,AX
	MOV	BX,OFFSET PO_DATA1
	MOV	AL,PO1B
	xlat
	mov	cl,al
	MOV	BX,OFFSET PO_DATA2
	MOV	AL,PO2B
	ADD	BX,AX
	AND	CL,[BX]
	MOV	ES:[DI],CL
	retn

_pol	endp

;------------------------------------------------------------------------------
;
;	É|ÉäÉSÉìêßå‰ä÷êîÇ≈Ç∑Ç™Ç»Ç±ÇÍÇ™ÅI
;
;	pol_end(my_x,my_y,my_z,cos a,sin a,sg1)
;
;	my_x,my_y,my_z			:é©ï™ÇÃÇ¢ÇÈà íuÇÃç¿ïW
;	cos a,sin a			:é©ï™ÇÃÇ¢ÇÈà íuÇ©ÇÁÇwÅ|Çyï˚å¸ÇÃâÒì]
;	sg1				:3DÇÃå≥Ç…Ç»ÇÈDATA
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol_end	proc	far
	push	bp
	mov	bp,sp
	mov	ax,[bp+6].arg_01
	mov	MYXX,ax
	mov	ax,[bp+6].arg_02
	mov	MYYY,ax
	mov	ax,[bp+6].arg_03
	mov	MYZZ,ax
	mov	ax,[bp+6].arg_04
	mov	set_04,ax
	mov	ax,[bp+6].arg_05
	mov	set_05,ax
	mov	ax,[bp+6].arg_06
	mov	set_06,ax
	
	mov	sp,bp
	pop	bp

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm

	call	pol_c_01

	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm
	ret
	
pol_c_01:
	mov	ax,set_06
	mov	es,ax

	mov	MAPK,0			;ÉãÅ[ÉvÇê›íËÇµÇƒÇ¢Ç‹Ç∑

	mov	si,OFFSET MAPDATA2
	inc	si
	inc	si

	mov	di,OFFSET MAPDATA1
	mov	cx,[di]
	inc	di
	inc	di
	cmp	cx,0
	jnz	NEXT_D
	retn
NEXT_D:	
	mov	TAI12,cx		;push	cx
	
	mov	ax,[di+1]
	add	ax,MYXX
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+5]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	add	dx,mae
	mov	POINT_Z1,dx
	sub	dx,q_y
	cmp	dx,3000
	jc	QQ1
	jmp	NND1
QQ1:	
	mov	ax,[di+7]
	add	ax,MYXX
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+11]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	add	dx,mae
	mov	POINT_Z2,dx
	sub	dx,q_y
	cmp	dx,3000
	jc	QQ2
	jmp	NND1
QQ2:	
	mov	ax,[di+13]
	add	ax,MYXX
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+17]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	add	dx,mae
	mov	POINT_Z3,dx
	sub	dx,q_y
	cmp	dx,3000
	jc	QQ3
	jmp	NND1
QQ3:
	mov	al,[di]
	mov	POC,al

	mov	ax,[di+1]
	add	ax,MYXX
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+5]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	mov	POINT_X1,bx
	
	mov	ax,[di+7]
	add	ax,MYXX
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+11]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	mov	POINT_X2,bx

	mov	ax,[di+13]
	add	ax,MYXX
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,[di+17]
	add	ax,MYZZ
	sub	ax,mae
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	mov	POINT_X3,bx

	mov	ax,[di+3]
	add	ax,MYYY
	mov	POINT_Y1,ax
	mov	ax,[di+9]
	add	ax,MYYY
	mov	POINT_Y2,ax
	mov	ax,[di+15]
	add	ax,MYYY
	mov	POINT_Y3,ax
	
	mov	TAI11,di		;pop	di
	call	pol_c_02		;É|ÉäÉSÉìÅ@ÇfÇnÅ@Ç¥ÇÒÇ∑
	mov	di,TAI11		;pop	di
NND1:	
	add	di,19
NND2:	
	mov	cx,TAI12		;pop	cx
	loop	NND4

NND3:	jmp	pol_end_01

NND4:	jmp	NEXT_D
	
;//////////////////////////////////////////////////////////////////////////////
;	ëÂÇ´Ç≥ÇÃî‰ärÇÇµÇ‹Ç∑ÅB
;	POINT_X1,POINT_Y1,POINT_Z1		PO_X1,PO_Y1
;	POINT_X2,POINT_Y2,POINT_Z2	=>	PO_X2,PO_Y2
;	POINT_X3,POINT_Y3,POINT_Z3		PO_X3,PO_Y3
;//////////////////////////////////////////////////////////////////////////////

pol_c_02:
	mov	ax,POINT_Z1			;ãóó£ÇäÑÇËèoÇ∑
	add	ax,POINT_Z2
	shr	ax,1
	add	ax,POINT_Z3
	shr	ax,1
	mov	[si],ax
	
	mov	bx,POINT_Z1

	mov	ax,POINT_X1
	cwd
	mov	DL,ah		;DX:AX<=AX*256
	mov	ah,al
	mov	al,0
	idiv	bx		;POINT_X1*256/POINT_Z1
	mov	dx,ax
	cmp	dx,1000
	jl	car_01
	retn
car_01:	shl	ax,1		;DX:AX<<4
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,xx_set
	mov	[si+3],ax
	
	mov	set,0
	cmp	ax,xxp_set
	jc	cc_01
	mov	set,1
	
cc_01:	mov	ax,POINT_Y1
	cwd
	mov	DL,ah
	mov	ah,al
	mov	al,0
	idiv	bx
	mov	bx,yy_set
	sub	bx,ax
	mov	[si+5],bx
	
	mov	bx,POINT_Z2
	
	mov	ax,POINT_X2
	cwd
	mov	DL,ah
	mov	ah,al
	mov	al,0
	idiv	bx
	mov	dx,ax
	cmp	dx,1000
	jl	car_02
	retn
car_02:	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,xx_set
	mov	[si+7],ax
	cmp	ax,xxp_set
	jc	cc_02
	inc	set
	
cc_02:	mov	ax,POINT_Y2
	cwd
	mov	DL,ah
	mov	ah,al
	mov	al,0
	idiv	bx
	mov	bx,yy_set
	sub	bx,ax
	mov	[si+9],bx
	
	mov	bx,POINT_Z3
	
	mov	ax,POINT_X3
	cwd
	mov	DL,ah
	mov	ah,al
	mov	al,0
	idiv	bx
	mov	dx,ax
	cmp	dx,1000
	jl	car_03
	retn
car_03:	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	ax,xx_set
	mov	[si+11],ax
	cmp	ax,xxp_set
	jc	cc_03
	inc	set
	
cc_03:	mov	ax,POINT_Y3
	cwd
	mov	DL,ah
	mov	ah,al
	mov	al,0
	idiv	bx
	mov	bx,yy_set
	sub	bx,ax
	mov	[si+13],bx
	
	mov	al,POC
	mov	[si+2],al

	cmp	set,3
	jz	cc_04
	
	add	si,15
	inc	MAPK
	
cc_04:	retn

;//////////////////////////////////////////////////////////////////////////////
;	ÉÅÉÇÉäÇÃì]ëóÇçsÇ¢Ç‹Ç∑ÅB
;//////////////////////////////////////////////////////////////////////////////

pol_end_01:
	mov	ax,set_06
	mov	es,ax
	mov	si,0
	mov	cx,MAPK
	mov	es:[si],cx
	cmp	cx,0
	jnz	pol_xx
	retn
pol_xx:	
	mov	si,2
po_nex1:push	cx
	mov	di,offset MAPDATA2
	inc	di
	inc	di

	mov	bx,0
	mov	cx,MAPK
po_nex2:mov	ax,[di]
	cmp	ax,bx
	jc	popo
	mov	bx,ax
	mov	dx,di
popo:	add	di,15
	loop	po_nex2

	mov	di,dx
	xor	ax,ax
	mov	ds:[di],ax
	mov	al,ds:[di+ 2]
	mov	es:[si   ],al
	mov	ax,ds:[di+ 3]
	mov	es:[si+ 1],ax
	mov	ax,ds:[di+ 5]
	mov	es:[si+ 3],ax
	mov	ax,ds:[di+ 7]
	mov	es:[si+ 5],ax
	mov	ax,ds:[di+ 9]
	mov	es:[si+ 7],ax
	mov	ax,ds:[di+11]
	mov	es:[si+ 9],ax
	mov	ax,ds:[di+13]
	mov	es:[si+11],ax
	add	si,13

	pop	cx
	loop	po_nex1
	retn

_pol_end	endp

;------------------------------------------------------------------------------
;
;	É|ÉäÉSÉìêßå‰ä÷êîÇ≈Ç∑Ç™Ç»Ç±ÇÍÇ™ÅI
;
;	pol_map(sg1)
;
;	sg1				:3DÇÃå≥Ç…Ç»ÇÈDATA
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol_map	proc	far
	push	bp
	mov	bp,sp
	mov	ax,[bp+6].arg_01
	mov	set_01,ax
	
	mov	sp,bp
	pop	bp

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm

	call	pol_map_01

	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm
	ret

pol_map_01:
	mov	ax,set_01
	mov	es,ax
	
	mov	di,offset MAPDATA1
	mov	ax,[di]
	mov	bx,ax		;ax*19
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,bx
	add	ax,bx
	add	ax,bx
	
	mov	si,0
	mov	cx,es:[si]
	mov	si,2
	add	bx,cx
	
	mov	[di],bx
	add	di,ax
	inc	di
	inc	di
	
pol_map_loop1:
	push	cx
	mov	al,es:[si]
	mov	[di],al
	inc	si
	inc	di
	mov	cx,9
pol_map_loop2:
	mov	ax,es:[si]
	mov	[di],ax
	inc	si
	inc	si
	inc	di
	inc	di
	loop	pol_map_loop2
	pop	cx
	loop	pol_map_loop1
	retn

_pol_map	endp
;------------------------------------------------------------------------------
;
;	É|ÉäÉSÉìêßå‰ä÷êîÇ≈Ç∑Ç™Ç»Ç±ÇÍÇ™ÅI
;
;	pol_add(my_x,my_y,my_z,cos a,sin a,sg1)
;
;	my_x,my_y,my_z			:é©ï™ÇÃÇ¢ÇÈà íuÇÃç¿ïW
;	cos a,sin a			:é©ï™ÇÃÇ¢ÇÈà íuÇ©ÇÁÇwÅ|Çyï˚å¸ÇÃâÒì]
;	sg1				:3DÇÃå≥Ç…Ç»ÇÈDATA
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol_add	proc	far
	push	bp
	mov	bp,sp
	mov	ax,[bp+6].arg_01
	mov	MYXX,ax
	mov	ax,[bp+6].arg_02
	mov	MYYY,ax
	mov	ax,[bp+6].arg_03
	mov	MYZZ,ax
	mov	ax,[bp+6].arg_04
	mov	set_04,ax
	mov	ax,[bp+6].arg_05
	mov	set_05,ax
	mov	ax,[bp+6].arg_06
	mov	set_06,ax
	
	mov	sp,bp
	pop	bp

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm

	call	pol_add_01

	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm
	ret
	
pol_add_01:
	mov	ax,set_06
	mov	es,ax

	mov	si,OFFSET MAPDATA1
	mov	ax,[si]
	mov	bx,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,ax
	add	ax,bx
	add	ax,bx
	add	ax,bx

	mov	di,0
	mov	cx,es:[di]
	add	bx,cx
	mov	[si],bx
	inc	di
	inc	di

	add	si,ax
	inc	si
	inc	si
	cmp	cx,0
	jnz	NEXT_DD
	retn
NEXT_DD:	
	mov	TAI12,cx		;push	cx

	mov	al,es:[di]
	mov	[si],al

	mov	ax,es:[di+1]
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+5]
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	sub	dx,MYXX
	mov	[si+1],dx

	mov	ax,es:[di+7]
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+11]
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	sub	dx,MYXX
	mov	[si+7],dx

	mov	ax,es:[di+13]
	mov	cx,set_05
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+17]
	mov	cx,set_04
	imul	cx
	mov	dh,dl
	mov	dl,ah
	add	dx,bx
	sub	dx,MYXX
	mov	[si+13],dx

	mov	ax,es:[di+1]
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+5]
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	add	bx,mae
	sub	bx,MYZZ
	mov	[si+5],bx
	
	mov	ax,es:[di+7]
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+11]
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	add	bx,mae
	sub	bx,MYZZ
	mov	[si+11],bx

	mov	ax,es:[di+13]
	mov	cx,set_04
	imul	cx
	mov	bh,dl
	mov	bl,ah
	mov	ax,es:[di+17]
	mov	cx,set_05
	imul	cx
	mov	dh,dl
	mov	dl,ah
	sub	bx,dx
	add	bx,mae
	sub	bx,MYZZ
	mov	[si+17],bx

	mov	ax,es:[di+3]
	sub	ax,MYYY
	mov	[si+3],ax
	mov	ax,es:[di+9]
	sub	ax,MYYY
	mov	[si+9],ax
	mov	ax,es:[di+15]
	sub	ax,MYYY
	mov	[si+15],ax
	
	add	si,19
	add	di,19

	mov	cx,TAI12		;pop	cx
	loop	NND5

	retn

NND5:	jmp	NEXT_DD
	

_pol_add	endp

;------------------------------------------------------------------------------
;
;	É|ÉäÉSÉìêßå‰ä÷êîÇ≈Ç∑Ç™Ç»Ç±ÇÍÇ™ÅI
;
;	pol_start()
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol_start	proc	far

	push	di
	mov	ax,0
	mov	di,OFFSET MAPDATA1
	mov	[di],ax
	pop	di
	
	ret
_pol_start	endp
	
;------------------------------------------------------------------------------
;
;	âÊñ ÇÃêÿÇËë÷Ç¶ä÷åWÇÃê›íËÇ≈Ç∑Ç™Ç»ÅB
;
;	pol_set()
;
;	ÇƒÇ»ä¥Ç∂Ç≈Ç∑Ç™Ç‚ÅI
;
;------------------------------------------------------------------------------

_pol_set	proc	far

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm
	
	mov	cl,PO
	cmp	cl,1
	je	TETE2

	mov	al,1
	out	0A4H,al
	mov	al,0
	out	0A6H,al
	mov	PO,1
	jmp	TETE1

TETE2:	mov	al,0
	out	0A4H,al
	mov	al,1
	out	0A6H,al
	mov	PO,0

TETE1:
	;mov	al,010000000B
	;out	07CH,al
	;mov	al,0H
	;out	07EH,al
	;out	07EH,al
	;out	07EH,al
	;out	07EH,al
	;
	;mov ax,0A800H
	;mov es,ax
	;mov di,0
	;mov cx,80*200
	;xor ax,ax
	;REP STOSW
	;
	;mov	al,0
	;out	07CH,al
	
	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm

	ret

_pol_set	endp

;------------------------------------------------------------------------------
;
;	âÊñ ÇÃêÿÇËë÷Ç¶ä÷åWÇÃê›íËÇ≈Ç∑Ç™Ç»ÅB
;
;
;------------------------------------------------------------------------------

_pol_set_c	proc	far

	irp	reg,<bx,cx,dx,si,di,ds,es>
	push	reg
	endm

	mov	al,8
	out	068H,al			;ÉOÉâÉtÉBÉbÉNï\é¶ê›íË
	mov	al,1
	out	06AH,al			;ÇPÇUêFÇlÇnÇcÇdê›íË
	
	mov	ah,040H			;ÉOÉâÉtÉBÉbÉNÇnÇm
	int	18H
	
	mov	ah,042H			;è„ÇQÇOÇOÉâÉCÉì
	mov	ch,080H
	int	18H

	mov	al,00FH
	out	0A2H,al
	mov	al,016H
	out	0A0H,al

	irp	reg,<es,ds,di,si,dx,cx,bx>
	pop	reg
	endm
	
	ret
_pol_set_c	endp



_pol_g_set	proc	far

	push	bp
	mov	bp,sp
	mov	ax,[bp+6].arg_01
	mov	x_set,ax
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	xxp_set,ax
	mov	ax,[bp+6].arg_02
	mov	y_set,ax
	mov	ax,[bp+6].arg_03
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	xx_set,ax
	mov	ax,[bp+6].arg_04
	mov	yy_set,ax
	mov	sp,bp
	pop	bp

	
	ret

_pol_g_set	endp

sub_program	ends
		END
