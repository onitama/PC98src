;--------------------------------------------------------------
;		graphic systems from C
;
;  ginit(Lines,SPage,Sswitch);	screen initalize and get status
;  gcls(Color);			screen clear
;  t_off();			text screen off
;  t_on();			text screen on
;  t_cls();			text screen clear
;  gprt(X,Y,Color,*st);		graphics font print out
;
;--------------------------------------------------------------

	.MODEL small,C
	.186

;-------------------------------------------------
;
;	graphic system routines for PC98
;			Started 1992/6 onitama
;
;-------------------------------------------------

	PUBLIC	ginit,gcls,gcls2,t_on,t_off,t_cls

	.CODE


;-------------------------------------------------
;	subroutines for graphics screen
;-------------------------------------------------


gcls2	proc
	pushf

	MOV AL,0
	OUT 07CH,AL
	CLD

	MOV AX,0A800H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0B000H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0B800H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0E000H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	popf
	ret

	endp


t_cls	proc

	pushf

	MOV AX,0A000H
	MOV ES,AX
	MOV DI,0
	MOV CX,120*25
	MOV AX,0
	REP STOSW

	popf
	ret

	endp



t_off	proc
	pushf
	mov	ah,0DH
	int	018H
	popf
	ret
	endp

t_on	proc
	pushf
	mov	ah,0CH
	int	018H
	popf
	ret
	endp


	PUBLIC GrcgReadSet,GrcgSet
	PUBLIC GrcgReset,GrcgColor

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� TCR TDW ���[�h�ݒ�
;  void GrcgReadSet(void)
;-------------------------------------------------
GrcgReadSet	PROC
		mov	al,080h		; Grcg TCR TDW mode
		jmp	SHORT GrcgMode
GrcgReadSet	ENDP

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� RMW ���[�h�ݒ�
;  void GrcgSet(void)
;-------------------------------------------------
GrcgSet	PROC	
		mov	al,0C0h		; Grcg RMW mode
GrcgSet	ENDP

;---------- GRCG Set subroutine
GrcgMode:
		push	es
		push	0
		pop	es
		pushf
		cli
		out	7Ch,al
		mov	es:[0495h],al	; GRCG mode �f�[�^�i�[
		popf
		pop	es
		ret

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� ���Z�b�g
;  void GrcgReset(void)
;-------------------------------------------------
GrcgReset	PROC
		mov	al,0		; Grcg mode off
		jmp	SHORT GrcgMode
GrcgReset	ENDP

		
;-------------------------------------------------
; �O���t�B�b�N�`���[�W���^�C�����W�X�^�ݒ�		
;  void GrcgColor(int Color)
;  IN  : int Color �^�C�����W�X�^�ɐݒ肷��F�ԍ�
;-------------------------------------------------

GrcgColor	PROC Color : WORD	; Color = 0�`15
		pushf
		cld
		push	di
		push	es
		mov	di,0496h	; Grcg Tile register �i�[�A�h���X
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	ax,Color
		pushf
		cli
	REPT 4
		ror	al,1
		cbw			; bit = 1 �̂Ƃ� ah = FFh
		xchg	ah,al		; bit = 0 �̂Ƃ� ah = 0 �ƂȂ�
		out	07Eh,al		; Tile register �Ƀf�[�^�Z�b�g
		stosb			; �V�X�e�����[�N�փf�[�^�i�[
		xchg	ah,al
	ENDM
		popf
		pop	es
		pop	di
		popf
		ret
GrcgColor	ENDP



;-------------------------------------------------
;		graphics chip status 
;-------------------------------------------------

	PUBLIC	_gc_set,_egc_set,_board16_set,_gdc_clock


;---------- �O���t�B�b�N�V�X�e���f�[�^�i�[
GSys		PROC
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	al,es:[054Ch]	; GRCG �L��
		and	al,02h
		shl	al,1
		mov	[_gc_set],al	; GRCG �O���t�B�b�N�`���[�W���[
					; 0 = ����, 1 =	�L��
		mov	al,es:[054Ch]	; 16�F�{�[�h �L��
		and	al,04h
		mov	cl,2
		shr	al,cl
		mov	[_board16_set],al
		mov	al,es:[054Dh]
		mov	dl,al
		and	al,40h		; EGC �L��
		mov	cl,6
		shr	al,cl
		mov	[_egc_set],al	; EGC �G���n���X�gGRCG
					; 0 = ����, 1 =	�L��
		and	dl,04h
		mov	cl,2
		shr	dl,cl		; GDC�N���b�N�𓾂�
		mov	[_gdc_clock],dl	; GDC �N���b�N
					; 0 = 2.5MHz, 1	= 5MHz
		ret
GSys		ENDP


;---------- �O���t�B�b�N�c���C���ݒ�
;    int Line :	0 = 200lines, 1	= 400lines

GraphicLineSet	PROC Line : WORD
		mov	ax,Line
		cmp	ax,0
		jz	lines200
		cmp	ax,1
		jz	lines400
		jmp	SHORT lines_exit

lines200:
		mov	ch,10000000b		; LOWER	COLOR BANK0
		jmp	SHORT lines_go
lines400:
		mov	ch,11000000b		; ALL	COLOR BANK0
lines_go:
		mov	ah,42h
		int	18h			; Graphic BIOS
lines_exit:
		ret
GraphicLineSet	ENDP


;---------- �f�W�^���^�A�i���O�J���[���[�h�ݒ�
;    int ColorMode : 0 = Degital, 1 = Analog

GraphicColorMode PROC ColorMode : WORD
		mov	ax,ColorMode
		out	06Ah,al
		ret
GraphicColorMode ENDP


;-----------------------------------------------------
;	graphics screen initalize
;
;  ginit( int Lines, int SPage , int Sswitch );
;
;  	int Lines      0 = 200 lines	1 = 400 lines
;	int SPage      0 = page 0	1 = page 1
;	int Sswitch    0 = screen off   1 = screen on
;
;-----------------------------------------------------

ginit	PROC Lines:WORD,SPage:WORD,Sswitch:WORD
	pushf
	;
	cli
	call	Gsys
	mov	ax,Lines
	push	ax
	call	GraphicLineSet
	add	sp,2
	;
	mov	ax,1
	push	ax
	call	GraphicColorMode
	add	sp,2
	;
	mov	ax,SPage
	out	0a4h,al
	out	0a6h,al
	;
	mov	cx,4100h
	;
	mov	ax,Sswitch
	cmp	ax,0
	jz	fran
	mov	cx,4000h
fran:
	mov	ax,cx
	int	18h
	;
	popf
	ret

ginit	endp


;-----------------------------------------------------
;  �O���t�B�b�N��ʏ���
;  void	gcls(int Color)
;  IN  : int Color ��ʂ���������F�ԍ�
;-----------------------------------------------------
		
gcls		PROC Color : WORD
		push	di

		mov	ah,41h
		int	18h

		cld
		call	GrcgReadSet 	; TDW ���[�h�Z�b�g
		mov	ax,Color
		push	ax
		call	GrcgColor
		add	sp,2
		sub	di,di		; di = 0
		mov	ax,0A800h	; Plane 0 �Z�O�����g
		mov	es,ax
		mov	cx,80 * 400 / 2	; Plane 0 VRAM �̃o�C�g�� / 2
	rep	stosw			; cx ���[�h��ʂɏ������� ax�͕s��
		call	GrcgReset	; GRCG ���Z�b�g

		mov	ah,40h
		int	18h

		pop	di
		ret
gcls		ENDP




;---------- �{�b�N�X�t�B���T�u���[�`��
;  IN : di = �擪VRAM �A�h���X, cx = �c���C����

BoxFill		PROC
		mov	ax,0A800h
		mov	es,ax
		mov	ax,[lndx]
		or	ax,ax
		js	boxf_1			; ����1word
		jz	boxf_2			; ����2word
;---------- ����3word�ȏ�
boxf_0:		
		mov	bx,[xpats]	;
		mov	dx,[xpate]
		mov	ax,0FFFFh
boxf_01:		
		push	cx
		push	di
		mov	cx,[lndx]
		mov	es:[di],bx
		add	di,2
	rep	stosw
		mov	es:[di],dx
		pop	di
		add	di,80
		pop	cx
		loop	boxf_01
boxf_exit:		
		ret

;---------- ����1word
boxf_1:
		mov	ax,[xpats]
		and	ax,[xpate]
boxf_11:	mov	es:[di],ax
		add	di,80
		loop	boxf_11
		jmp	boxf_exit	

;---------- ����2word
boxf_2:
		mov	ax,[xpats]
		mov	dx,[xpate]
boxf_21:		
		stosw
		mov	es:[di],dx
		add	di,80 - 2
		loop	boxf_21
		jmp	boxf_exit	
BoxFill		ENDP




;---------------------------------------------------------
;  �O���t�B�b�N�{�b�N�X�t�B��
;  void GraphicBoxf(int X1,int Y1,int X2,int Y2,int Color)
;  IN  : int X1,Y1 �{�b�N�X����[���W
;        int X2,Y2 �{�b�N�X�E���[���W
;	 int Color �h��ׂ��F�ԍ�
;----------------------------------------------------------



		PUBLIC GraphicBoxf
GraphicBoxf	PROC X1:WORD,Y1:WORD,X2:WORD,Y2:WORD,Color:WORD
		push	di
		cld
		call	GrcgSet		; RMW ���[�h�ݒ�
		mov	ax,Color
		push	ax
		call	GrcgColor		; GRCG �^�C�����W�X�^�ݒ�
		add	sp,2
		mov	bx,X1			; bx = x1
		mov	dx,X2			; dx = x2
		mov	ax,639
		cmp	bx,ax
		jbe	gboxf_1
		mov	bx,ax
gboxf_1:
		cmp	dx,ax
		jbe	gboxf_2
		mov	dx,ax
gboxf_2:
		cmp	bx,dx
		jbe	not_xchg
		xchg	bx,dx			; X1 > X2 �Ȃ�X1,X2�����ւ���
not_xchg:
		mov	cx,bx
		and	cx,00Fh
		mov	ax,0FFFFh
		shr	ax,cl	
		xchg	ah,al
		mov	[xpats],ax		; ���[�̃r�b�g�f�[�^
		mov	cx,dx
		and	cx,000Fh	
		sub	cx,000Fh
		neg	cx
		mov	ax,0FFFFh
		shl	ax,cl
		xchg	ah,al
		mov	[xpate],ax		; �E�[�̃r�b�g�f�[�^
		shr	bx,4			; bx = x1
		mov	di,bx
		shr	dx,4			; dx = x2
		sub	dx,di
		dec	dx
		mov	[lndx],dx
		shl	di,1
		mov	ax,Y1
		mov	cx,Y2
		mov	dx,399
		cmp	ax,dx
		jbe	gboxf_3
		mov	ax,dx
gboxf_3:
		cmp	cx,dx
		jbe	gboxf_4
		mov	cx,dx
gboxf_4:
		cmp	ax,cx
		jbe	not_ychg
		xchg	ax,cx			; Y1 > Y2 �Ȃ�Y1,Y2�����ւ���
not_ychg:
		sub	cx,ax
		inc	cx
		mov	dx,80
		mul	dx
		add	di,ax			; di = �擪VRAM�A�h���X
		call	BoxFill
		call	GrcgReset		; GRCG ���Z�b�g
		pop	di
		ret
GraphicBoxf	ENDP



;-------------------------------------------------
;	xkd format unpack routine
;-------------------------------------------------

WSEG		EQU 5768H
VRAM0		EQU 0A800H
VRAM1		EQU 0B000H
VRAM2		EQU 0B800H
BIT_ON		EQU BYTE PTR 0FFH
BIT_OFF		EQU BYTE PTR 0


	;
	;

	PUBLIC	xkd_pic

xkd_pic	proc	axis_x:byte,axis_y:byte,datadr:ptr word
	push	si
	push	di
	;
	mov	al,axis_x
	mov	csrx,al
	mov	al,axis_y
	mov	csry,al
	;
	call	grput
	pop	di
	pop	si
	ret

KADDRES:
	MOV AH,0
	MOV AL,CSRY
	MOV DL,5
	MUL DL
	MOV AH,AL
	MOV AL,CSRX
	MOV PUTAD,AX
	RETN

GRPUT:
	IN AL,0A0H	; CRCT WAIT
	TEST AL,04H
	JE GRPUT
	PUSH AX
	PUSH AX
	POP AX
	POP AX
VWAITGR:
	IN AL,0A0H
	TEST AL,08H
	JNE VWAITGR

	MOV DI,datadr
	MOV AX,[DI]+3
	ADD AX,DI
	MOV TILE_TOP,AX   ;�^�C���f�[�^�擪
	MOV AX,[DI]+5
	ADD AX,DI
	MOV FILE_END,AX   ;�I���A�h���X
	MOV AL,[DI]+09H
	MOV NULL_COLOR,AL ;�����F
	MOV AL,[DI]+1
	MOV WIDECT,AL	;���o�C�g��
	MOV AL,[DI]+2
	SHR AL,1	;/2
	MOV LINECT,AL	;�c���C����

	MOV AX,datadr
	ADD AX,10H
	MOV LOOK_AD,AX	;�Q�ƃA�h���X
	CALL KADDRES

	MOV AX,PUTAD
	;MOV AX,0
	MOV POKE_AD,AX	;�������ރA�h���X
	MOV BASE_AD,AX
	MOV AX,0
	MOV LINEOF,AL
	MOV WIDEOF,AL



	JMP GRLOOP

eogr:
	ret

GRLOOP:	
	MOV BX,LOOK_AD
	MOV AL,[BX]
	
	CMP BX,FILE_END
	JZ EOGR
	
	INC BX
	
	CMP BX,FILE_END
	JZ EOGR

	;jmp	noarc

	
	TEST AL,80H
	JZ NOARC
	;ARC
	AND AL,7FH
	MOV GRCT,AL
	MOV AL,[BX]
	INC BX
	MOV LOOK_AD,BX
	
	MOV AH,0

	ADD AX,AX ;*2
	MOV CX,AX
	ADD AX,AX ;*4
	ADD AX,CX
	
	ADD AX,TILE_TOP
	MOV TILE_BUF,AX
GRLOOP2:
	MOV AX,TILE_BUF
	MOV TILE_AD,AX
	CALL GRSUB
	JC EOGR
	DEC GRCT
	JNZ GRLOOP2
	JMP GRLOOP
NOARC:
	MOV GRCT,AL
	MOV TILE_AD,BX
GRLOOP3:
	CALL GRSUB
	JC EOGR
	DEC GRCT
	JNZ GRLOOP3
	
	MOV AX,TILE_AD
	MOV LOOK_AD,AX	
	JMP GRLOOP



NULL_CC:
	MOV AL,0
	JMP NULL_FK
GRPART:
	
	;TILE_AD POKE_AD
	;���C�g

	MOV AL,NULL_COLOR
	CMP AL,0FFH	;�����F�Ȃ��i�O�e�e�g�j
	JZ NULL_CC

	TEST AL,1	;VRAM0
	JZ GR1
	MOV AH,BIT_ON
	JMP GR2
GR1:
	MOV AH,BIT_OFF
GR2:
	MOV GRW0,AH
	TEST AL,2	;VRAM1
	JZ GR3
	MOV AH,BIT_ON
	JMP GR4
GR3:
	MOV AH,BIT_OFF
GR4:
	MOV GRW1,AH
	TEST AL,4	;VRAM2
	JZ GR5
	MOV AH,BIT_ON
	JMP GR6
GR5:
	MOV AH,BIT_OFF
GR6:
	MOV GRW2,AH
	
	
	MOV DI,TILE_AD
	MOV AH,[DI]
	XOR GRW0,AH
	
	MOV AH,[DI]+1
	XOR GRW1,AH
	
	MOV AH,[DI]+2
	XOR GRW2,AH
	
	MOV AL,GRW2
	OR AL,GRW1
	OR AL,GRW0
	NOT AL
NULL_FK:
	MOV DI,POKE_AD
	MOV MASK_BIT,AL ;MASK=1 / NO MASK=0
	MOV GRW0,AL
	MOV GRW1,AL
	MOV GRW2,AL
	
	MOV DX,VRAM0
	MOV ES,DX
	MOV AH,ES:[DI]
	AND GRW0,AH	; MASK AND GRPHIC
	;�̂����O���t�C�b�N
	MOV DX,VRAM1
	MOV ES,DX
	MOV AH,ES:[DI]
	AND GRW1,AH
	
	MOV DX,VRAM2
	MOV ES,DX
	MOV AH,ES:[DI]
	AND GRW2,AH
	
	MOV DX,DS
	MOV ES,DX
	
	MOV AL,MASK_BIT
	NOT AL
	MOV BL,AL	
	;MASK AND GRAM OR /MASK AND GRAM ->GRAM
	
	MOV SI,TILE_AD
	MOV AH,DS:[SI]
	INC SI
	AND AL,AH
	OR AL,GRW0
	MOV DX,VRAM0	;VRAM0
	MOV ES,DX
	MOV ES:[DI],AL
	MOV ES:[DI]+80,AL
	
	MOV AL,BL
	MOV AH,[SI]
	INC SI
	AND AL,AH
	OR AL,GRW1
	MOV DX,VRAM1
	MOV ES,DX
	MOV ES:[DI],AL
	MOV ES:[DI]+80,AL
	
	MOV AL,BL
	MOV AH,[SI]
	INC SI
	AND AL,AH
	OR AL,GRW2
	MOV DX,VRAM2
	MOV ES,DX
	MOV ES:[DI],AL
	MOV ES:[DI]+80,AL
	
	MOV DX,DS
	MOV ES,DX
	MOV TILE_AD,SI
	RETN
GRSUB:
	CLC
	CALL GRPART
	MOV AX,POKE_AD
	ADD AX,160
	MOV POKE_AD,AX
	CALL GRPART
	MOV AX,POKE_AD
	ADD AX,160
	MOV POKE_AD,AX
	;�c�h�m�b
	MOV AL,LINEOF
	INC AL
	CMP AL,LINECT
	JNZ UN_OVER
	MOV AL,0
	MOV LINEOF,AL	;TATE OVER
	;�A�h���X�h�m�b
	MOV AX,BASE_AD
	INC AX
	MOV BASE_AD,AX
	MOV POKE_AD,AX
		
	MOV AL,WIDEOF
	INC AL
	CMP AL,WIDECT
	JNZ UN_OVER2
	STC
	RETN
UN_OVER:
	MOV LINEOF,AL
	CLC
	RETN
UN_OVER2:
	MOV WIDEOF,AL
	CLC
	RETN

	endp



;-------------------------------------------------
;	data segment
;-------------------------------------------------

	.DATA


PUTAD		DW 0
TILE_TOP	DW 0
FILE_END	DW 0
LOOK_AD		DW 0
NULL_COLOR	DB 0
WIDECT		DB 0
LINECT		DB 0
WIDEOF		DB 0	;���ʒu�I�t�Z�b�g�@�O�|�i�v�h�c�d�b�s�|�P�j
LINEOF		DB 0	;�c
GRCT		DB 0
TILE_AD		DW 0
POKE_AD		DW 0
BASE_AD		DW 0
CSRX		DB 1	;�����p�w���W
CSRY		DB 1	;�@�@�@�x���W

TEMPP		DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TILE_BUF	DW 0
DUMY		DB 0,255,255,0,255,255
GRW0		DB 0
GRW1		DB 0
GRW2		DB 0
MASK_BIT	DB 0

xpats		dw	?			; ���[�r�b�g�f�[�^
xpate		dw	?			; �E�[�r�b�g�f�[�^
lndx		dw	?			; ���o�C�g��

_gc_set		db	?		; GRCG �O���t�B�b�N�`���[�W���[
					; 0 = ����, 1 =	�L��
_egc_set	db	?		; EGC �G���n���X�gGRCG
					; 0 = ����, 1 =	�L��
_board16_set	db	?		; 16�F�{�[�h
					; 0 = ����, 1 =	�L��
_gdc_clock	db	?		; GDC �N���b�N
					; 0 = 2.5MHz, 1	= 5MHz


;-------------------------------------------------
;	end of line
;-------------------------------------------------

	END


