;--------------------------------------------------------------
;		graphic systems from C ( small model )
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

	.CODE

	GLOBAL	font12,font24,font32

;-------------------------------------------------
;	subroutines for small model
;-------------------------------------------------

	PUBLIC	segload

segload	proc fp:WORD,fseg:WORD,fsize:WORD
	;
	push	di
	push	si
	push	ds
	;
	mov	ax,fseg
	mov	ds,ax
	mov	ax,03f00h
	mov	bx,fp
	mov	cx,fsize
	mov	dx,0
	int	21h
	;
	pop	ds
	pop	si
	pop	di
	ret
	endp


	PUBLIC	segsave

segsave	proc fp:WORD,fseg:WORD,fsize:WORD
	;
	push	di
	push	si
	push	ds
	;
	mov	ax,fseg
	mov	ds,ax
	mov	ax,04000h
	mov	bx,fp
	mov	cx,fsize
	mov	dx,0
	int	21h
	;
	pop	ds
	pop	si
	pop	di
	ret
	endp


;-------------------------------------------------
;	subroutines for graphics screen
;-------------------------------------------------


	PUBLIC	ginit,gcls,gcls2,t_on,t_off,t_cls
	PUBLIC	gprt



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

	CLD
	MOV AX,0A000H
	MOV ES,AX
	MOV DI,0
	MOV CX,160*50
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
;  グラフィックチャージャ TCR TDW モード設定
;  void GrcgReadSet(void)
;-------------------------------------------------
GrcgReadSet	PROC
		mov	al,080h		; Grcg TCR TDW mode
		call	GrcgMode
		ret
GrcgReadSet	ENDP

;-------------------------------------------------
;  グラフィックチャージャ RMW モード設定
;  void GrcgSet(void)
;-------------------------------------------------
GrcgSet	PROC	
		mov	al,0C0h		; Grcg RMW mode
		call	GrcgMode
		ret
GrcgSet	ENDP

;---------- GRCG Set subroutine
GrcgMode:
		push	es
		push	0
		pop	es
		pushf
		cli
		out	7Ch,al
		mov	es:[0495h],al	; GRCG mode データ格納
		popf
		pop	es
		retn

;-------------------------------------------------
;  グラフィックチャージャ リセット
;  void GrcgReset(void)
;-------------------------------------------------
GrcgReset	PROC
		mov	al,0		; Grcg mode off
		call	GrcgMode
		ret
GrcgReset	ENDP

		
;-------------------------------------------------
; グラフィックチャージャタイルレジスタ設定		
;  void GrcgColor(int Color)
;  IN  : int Color タイルレジスタに設定する色番号
;-------------------------------------------------

GrcgColor	PROC Color : WORD	; Color = 0～15
		pushf
		cld
		push	di
		push	es
		mov	di,0496h	; Grcg Tile register 格納アドレス
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	ax,Color
		pushf
		cli
	REPT 4
		ror	al,1
		cbw			; bit = 1 のとき ah = FFh
		xchg	ah,al		; bit = 0 のとき ah = 0 となる
		out	07Eh,al		; Tile register にデータセット
		stosb			; システムワークへデータ格納
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


;---------- グラフィックシステムデータ格納
GSys		PROC
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	al,es:[054Ch]	; GRCG 有無
		and	al,02h
		shl	al,1
		mov	[_gc_set],al	; GRCG グラフィックチャージャー
					; 0 = 無し, 1 =	有り
		mov	al,es:[054Ch]	; 16色ボード 有無
		and	al,04h
		mov	cl,2
		shr	al,cl
		mov	[_board16_set],al
		mov	al,es:[054Dh]
		mov	dl,al
		and	al,40h		; EGC 有無
		mov	cl,6
		shr	al,cl
		mov	[_egc_set],al	; EGC エンハンストGRCG
					; 0 = 無し, 1 =	有り
		and	dl,04h
		mov	cl,2
		shr	dl,cl		; GDCクロックを得る
		mov	[_gdc_clock],dl	; GDC クロック
					; 0 = 2.5MHz, 1	= 5MHz
		ret
GSys		ENDP


;---------- グラフィック縦ライン設定
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


;---------- デジタル／アナログカラーモード設定
;    int ColorMode : 0 = Degital, 1 = Analog

GraphicColorMode PROC ColorMode : WORD
		mov	ax,ColorMode
		out	06Ah,al
		ret
GraphicColorMode ENDP


	;
	;	32x12(24) font put routine
	;		al-chr no.  di-vram adr.
	;
put32	proc
	push	di
	lea	si,font32
	xor	ah,ah
	push	ax
	sub	al,'@'
	mov	bx,48
	mul	bx
	add	si,ax
	;
	mov	ax,0a800h
	mov	es,ax
	;
	mov	cx,12
lp1:
	push	di
	mov	bx,cs:[si]
	mov	es:[di],bx
	inc	si
	inc	si
	inc	di
	inc	di
	mov	ax,cs:[si]
	mov	es:[di],ax
	inc	si
	inc	si
	pop	di
	add	di,80
	push	di
	;
	mov	es:[di],bx
	inc	di
	inc	di
	mov	es:[di],ax
	pop	di
	add	di,80
	loop	lp1
	;
	pop	ax
	pop	di
	cmp	al,'I'
	je	gpn2
	;
	add	di,4
	ret
gpn2:
	add	di,2
	ret
	endp


	;
	;	24x24 font put routine
	;		al-chr no.  di-vram adr.
	;
put24	proc
	push	di
	lea	si,font24
	xor	ah,ah
	sub	al,'0'
	mov	bx,72*2
	mul	bx
	add	si,ax
	;
	push	di
	mov	ax,0a800h
	call	wow24
	pop	di
	mov	ax,0b000h
	call	wow24
	pop	di
	add	di,3
	ret
	;
wow24:
	mov	es,ax
	mov	cx,24
lp3:
	mov	bx,cs:[si]
	mov	es:[di],bx
	inc	si
	inc	si
	inc	di
	inc	di
	mov	al,cs:[si]
	mov	es:[di],al
	inc	si
	add	di,78
	loop	lp3
	;
	retn

	endp


	;
	;	8x12(24) font put routine
	;		al-chr no.  di-vram adr.
	;
put12	proc
	push	di
	lea	si,font12
	xor	ah,ah
	sub	al,020h
	mov	bx,12
	mul	bx
	add	si,ax
	;
	mov	ax,0a800h
	mov	es,ax
	;
	mov	cx,12
lp2:
	mov	al,cs:[si]		;
	mov	es:[di],al
	inc	si
	add	di,80
	loop	lp2
	;
	pop	di
	inc	di
	ret
	endp


;-----------------------------------------------------
;
;	graphics font print routine main
;
;-----------------------------------------------------

gprt	proc axisX:WORD,axisY:WORD,Color:WORD,stadr:PTR WORD
	;
	push	di
	push	si
	push	ds
	;
	mov	al,011000000B		; grcg on
	out	07CH,al
	;
	mov	ax,Color
	push	ax
	call	GrcgColor
	add	sp,2
	;
	mov	di,axisX
	mov	ax,axisY
	mov	dx,80
	mul	dx
	add	di,ax
	mov	si,offset stadr
	mov	ax,0
	mov	PUTAD,ax

gp_0:
	mov	al,[si]
	or	al,al
	je	gp_1
	inc	si
	cmp	al,'*'
	jne	gp_3
	;
	mov	al,[si]
	or	al,al
	je	gp_1
	inc	si
	mov	dl,al
	sub	al,48
	cmp	al,3
	jnc	gp_4
	xor	ah,ah
	mov	PUTAD,ax
	jmp	gp_0
	;
gp_4:
	mov	al,dl
gp_3:
	push	si
	mov	dx,PUTAD
	or	dl,dl
	je	selgt0
	cmp	dl,1
	je	selgt1
selgt2:
	call	put32
	jmp	gp_2
selgt1:
	mov	dl,al
	xor	al,al
	out	07CH,al
	mov	al,dl
	;
	call	put24
	;
	mov	al,011000000B
	out	07CH,al
	jmp	gp_2
selgt0:
	call	put12
gp_2:
	pop	si
	jmp	gp_0
gp_1:
	;
	xor	al,al
	out	07CH,al			; grcg off
	;
	pop	ds
	pop	si
	pop	di
	ret

	endp



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
;  グラフィック画面消去
;  void	gcls(int Color)
;  IN  : int Color 画面を消去する色番号
;-----------------------------------------------------
		
gcls		PROC Color : WORD
		push	di

		mov	ah,41h
		int	18h

		cld
		call	GrcgReadSet 	; TDW モードセット
		mov	ax,Color
		push	ax
		call	GrcgColor
		add	sp,2
		sub	di,di		; di = 0
		mov	ax,0A800h	; Plane 0 セグメント
		mov	es,ax
		mov	cx,80 * 400 / 2	; Plane 0 VRAM のバイト数 / 2
	rep	stosw			; cx ワード画面に書き込む axは不定
		call	GrcgReset	; GRCG リセット

		mov	ah,40h
		int	18h

		pop	di
		ret
gcls		ENDP




;---------- ボックスフィルサブルーチン
;  IN : di = 先頭VRAM アドレス, cx = 縦ライン数

BoxFill		PROC
		mov	ax,0A800h
		mov	es,ax
		mov	ax,[lndx]
		or	ax,ax
		js	boxf_1			; 横幅1word
		jz	boxf_2			; 横幅2word
;---------- 横幅3word以上
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

;---------- 横幅1word
boxf_1:
		mov	ax,[xpats]
		and	ax,[xpate]
boxf_11:	mov	es:[di],ax
		add	di,80
		loop	boxf_11
		jmp	boxf_exit	

;---------- 横幅2word
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
;  グラフィックボックスフィル
;  void GraphicBoxf(int X1,int Y1,int X2,int Y2,int Color)
;  IN  : int X1,Y1 ボックス左上端座標
;        int X2,Y2 ボックス右下端座標
;	 int Color 塗り潰す色番号
;----------------------------------------------------------



		PUBLIC GraphicBoxf
GraphicBoxf	PROC X1:WORD,Y1:WORD,X2:WORD,Y2:WORD,Color:WORD
		push	di
		cld
		call	GrcgSet		; RMW モード設定
		mov	ax,Color
		push	ax
		call	GrcgColor		; GRCG タイルレジスタ設定
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
		xchg	bx,dx			; X1 > X2 ならX1,X2を入れ替える
not_xchg:
		mov	cx,bx
		and	cx,00Fh
		mov	ax,0FFFFh
		shr	ax,cl	
		xchg	ah,al
		mov	[xpats],ax		; 左端のビットデータ
		mov	cx,dx
		and	cx,000Fh	
		sub	cx,000Fh
		neg	cx
		mov	ax,0FFFFh
		shl	ax,cl
		xchg	ah,al
		mov	[xpate],ax		; 右端のビットデータ
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
		xchg	ax,cx			; Y1 > Y2 ならY1,Y2を入れ替える
not_ychg:
		sub	cx,ax
		inc	cx
		mov	dx,80
		mul	dx
		add	di,ax			; di = 先頭VRAMアドレス
		call	BoxFill
		call	GrcgReset		; GRCG リセット
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
VRAM3		EQU 0E000H
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

	MOV DI,offset datadr
	MOV AX,[DI]+3
	ADD AX,DI
	MOV TILE_TOP,AX   ;タイルデータ先頭
	MOV AX,[DI]+5
	ADD AX,DI
	MOV FILE_END,AX   ;終了アドレス
	MOV AL,[DI]+09H
	MOV NULL_COLOR,AL ;透明色
	MOV AL,[DI]+1
	MOV WIDECT,AL	;横バイト数
	MOV AL,[DI]+2
	SHR AL,1	;/2
	MOV LINECT,AL	;縦ライン数

	MOV AX,offset datadr
	ADD AX,10H
	MOV LOOK_AD,AX	;参照アドレス
	CALL KADDRES

	MOV AX,PUTAD
	;MOV AX,0
	MOV POKE_AD,AX	;書き込むアドレス
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
	;ライト

	MOV AL,NULL_COLOR
	CMP AL,0FFH	;透明色なし（０ＦＦＨ）
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
	;のこすグラフイック
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
	;縦ＩＮＣ
	MOV AL,LINEOF
	INC AL
	CMP AL,LINECT
	JNZ UN_OVER
	MOV AL,0
	MOV LINEOF,AL	;TATE OVER
	;アドレスＩＮＣ
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
;	realtime key input lib.
;	int joyin(),void jinit(),int kinp( int )
;
;-------------------------------------------------

	PUBLIC	joyin,joyin2,jinit,kinp


kinp	proc	k_matrix:word

	push	di

	mov	ax,0000			;ＫＥＹ　バッファを０にする。
	mov	es,ax
	mov	di,0528H
	mov	al,0
	mov	es:[di],al

	mov	ax,k_matrix
	mov	ah,04
	int	18h
	mov	al,ah
	mov	ah,0

	pop	di
	ret

	endp


jinit	proc
	;
	mov	ah,03H
	int	18H
	;mov	ah,0CH
	;int	18H
	ret
	;
	endp


;-------------------------------------------------
;	realtime key input routine
;	for ( 2,4,6,8,[x],[space],[z] )
;         + ( cursor key , [ret] )
;-------------------------------------------------


joyin2	proc
	push	di

	mov	ax,0000			;ＫＥＹ　バッファを０にする。
	mov	es,ax
	mov	di,0528H
	mov	al,0
	mov	es:[di],al
	mov	dx,0
	;
	call	joysub
	call	joysub2
	push	dx

		mov	cx,140H
wtloop2:	out	005FH,al
		loop	wtloop2

	call	joysub
	call	joysub2
	pop	ax
	or	ax,dx
	pop	di
	ret
	endp


;-------------------------------------------------
;	realtime key input routine
;	for ( 2,4,6,8,[x],[space],[z] )
;-------------------------------------------------


joyin	proc
	push	di

	mov	ax,0000			;ＫＥＹ　バッファを０にする。
	mov	es,ax
	mov	di,0528H
	mov	al,0
	mov	es:[di],al
	mov	dx,0
	;
	call	joysub
	push	dx

		mov	cx,200H
waitloop:	out	005FH,al
		loop	waitloop

	call	joysub
	pop	ax
	or	ax,dx
	pop	di
	ret
	endp


joysub	proc near
	mov	ax,00405H	;"Z"
	int	18H
	;
	and	ah,000000010B
	je	BB1
	;
	or	dl,128

BB1:	mov	ax,00405H	;"X"
	int	18H
	and	ah,000000100B
	je	BB2
	;
	or	dl,64

BB2:	mov	ax,00409H	;"2"
	int	18H
	and	ah,000001000B
	je	BB3
	;
	or	dl,1
	
BB3:	mov	ax,00408H	;"8"
	int	18H
	and	ah,000001000B
	je	BB4
	;
	or	dl,2

BB4:	mov	ax,00408H	;"4"
	int	18H
	and	ah,001000000B
	je	BB5
	;
	or	dl,4
	
BB5:	mov	ax,00409H	;"6"
	int	18H
	and	ah,0000000001B
	je	BB6
	;
	or	dl,8
	
BB6:	mov	ax,00406H	;"SAPCE"
	int	18H
	and	ah,000010000B
	je	BB7
	;
	or	dl,16

BB7:	mov	ax,00400H	;"ESC"
	int	18H
	and	ah,01B
	je	TT2W
	;
	or	dl,32
TT2W:
	retn
	endp


joysub2	proc near

	;	for cursor key
	;
	mov	ax,00403H	;"SHIFT"
	int	18H
	and	ah,000010000B
	je	BB8
	;
	or	dl,16
BB8:
	mov	ax,00407H
	int	18H
	test	ah,00100000B	;"2"
	je	BB9
	;
	or	dl,1
	
BB9:
	test	ah,00000100B	;"8"
	je	BB10
	;
	or	dl,2

BB10:
	test	ah,00001000B	;"4"
	je	BB11
	;
	or	dl,4
	
BB11:
	test	ah,00010000B	;"6"
	je	TT3W
	;
	or	dl,8
TT3W:
	retn
	endp



;-------------------------------------------------------------
;  void KanjiGputc(unsigned int KANJI,int XP,int YP,int COLOR)
;  unsigned int KANJI : 漢字シフトJISコード
;           int XP    : 表示 横座標 0～639-16
;           int YP    : 表示 縦座標 0～400-16
;           int COLOR : 表示カラー 
;                       bit4 = 0 : 普通文字 
;                            = 1 : 太文字 
;			bit5 = 1 : 特殊文字(8dot/adr) type1
;			bit6 = 1 : 特殊文字(8dot/adr) type2
;--------------------------------------------------------------  
		PUBLIC	KanjiGputc
KANJI_H		equ	16
shift_cnt	db	3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
shift_cnt2	db	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0


View16		PROC
		imul	di,cx,80
		mov	ax,bx
		shr	ax,3
		add	di,ax
		call	GrcgSet
		push	dx
		and	dx,0Fh
		push	dx
		call	GrcgColor
		add	sp,2
		mov	ax,0A800h
		mov	es,ax
		mov	cx,KANJI_H
		;
		pop	dx
		cmp	dx,32
		jc	normal_mode
		cmp	dx,64
		jc	spec_type1

spec_type2:
		lea	bx,shift_cnt2
shift_spc2:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cl,cs:[bx]
		inc	bx
		cmp	cl,0
		jz	no_shift3
shift_loop3:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop3
no_shift3:
		mov	es:[di+82],dl
		mov	es:[di+81],al
		mov	es:[di],ah
		add	di,80
		pop	cx
		loop	shift_spc2
		jmp	SHORT view16_exit


spec_type1:
		lea	bx,shift_cnt
shift_spc:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cl,cs:[bx]
		inc	bx
		cmp	cl,0
		jz	no_shift2
shift_loop2:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop2
no_shift2:
		mov	es:[di+2],dl
		xchg	ah,al
		mov	es:[di],ax
		add	di,80
		pop	cx
		loop	shift_spc
		jmp	SHORT view16_exit


normal_mode:
		and	bx,7
		jz	not_shift
shift_data:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cx,bx
shift_loop:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop
		mov	es:[di+2],dl
		xchg	ah,al
		mov	es:[di],ax
		add	di,80
		pop	cx
		loop	shift_data
		jmp	SHORT view16_exit
not_shift:
		lodsw
		mov	es:[di],ax
		add	di,80
		loop	not_shift
view16_exit:
		call	GrcgReset
		ret

View16		ENDP



KanjiGputc	PROC USES si di,KANJI:WORD,XP:WORD,YP:WORD,COLOR:WORD
		cld
		mov	al,0Bh		;ビットマップモード
		out	68h,al		;kanji access control
		mov	ax,KANJI
	        ;--- シフトJIS→JIS変換
	        xchg	ah,al
	        shl     ah,1
	        sub     al,1fh
      	  	js      kgput_1
        	cmp     al,061h
        	adc     al,0deh
kgput_1:
        	add     ax,1fa1h
        	and     ax,07f7fh
		sub	ah,20h
					; ax = Kanji JIS code
		out	0A1h,al
		xchg	ah,al
		out	0A3h,al
		sub	ax,ax		; ax = 0
		mov	es,ax
		test	BYTE PTR es:[054Dh],01000000b
		mov	ax,ds
		mov	es,ax
		mov	di,OFFSET DGROUP:kanji_data
		jz	io_read	
cgw_read:
		push	ds
		mov	cx,16
		mov	ax,0A400h
		mov	ds,ax	
		sub	si,si		; si = 0	
	rep	movsw
		pop	ds
		jmp	SHORT kgput_2	
io_read:		
		mov	cx,0
ior_1:		
		mov	ax,cx
		or	al,020h	
		out	0A5h,al
		in	al,0A9h
		stosb
		mov	ax,cx
		out	0A5h,al
		in	al,0A9h
		stosb
		inc	cx
		cmp	cx,KANJI_H
		jnz	ior_1
kgput_2:
		mov	al,0Ah		; コードアクセスモード
		out	68h,al		;kanji access control
		test	COLOR,010h
		jnz	kgput_4
		jmp	kgput_3
		;--- 太文字データ処理
kgput_4:
		mov	si,OFFSET DGROUP:kanji_data
		mov	di,si
	REPT KANJI_H
		lodsw
		mov	dx,ax
		rol	dx,1
		or	ax,dx
		stosw	
	ENDM
kgput_3:
		mov	bx,XP
		mov	cx,YP
		mov	dx,COLOR
		mov	si,OFFSET DGROUP:kanji_data
		call	View16
		ret
KanjiGputc	ENDP


hput	proc	USES SI,CODE:WORD,XP:WORD,YP:WORD,COLOR:WORD

		mov	ax,CODE
		push	ax
		mov	bx,XP
		mov	cx,YP
		mov	dx,COLOR
		and	dx,0Fh
		;
		imul	di,cx,80
		mov	ax,bx
		shr	ax,3
		add	di,ax
		call	GrcgSet
		push	dx
		call	GrcgColor
		add	sp,2
		;
		pop	ax
		call	put12
		call	GrcgReset
		;
		ret

hput	endp



;---------------------------------------------------------
;
;	print routine main （漢字全角，半角サポート）
;
;---------------------------------------------------------

	PUBLIC	hput,kprt

kprt	proc axisX:WORD,axisY:WORD,Color:WORD,stadr:PTR WORD
	;
	push	si
	push	di
	mov	bx,axisX
	mov	cx,axisY
	mov	dx,Color
	;
	mov	si,offset stadr
kp1:
	mov	al,[si]
	or	al,al
	jz	kp2
	inc	si
	cmp	al,0e0h
	jnc	kp4
	cmp	al,0a0h
	jnc	kp3
	cmp	al,080h
	jnc	kp4
	cmp	al,20h
	jnc	kp3
	cmp	al,09h
	jz	kp5
	;
	jmp	kp1
	;
kp4:
	mov	ah,[si]
	or	ah,ah
	jz	kp2
	inc	si
	;
	push	dx
	push	cx
	push	bx
	push	ax
	call	KanjiGputc
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	add	bx,16
	;
	jmp	kp1
kp5:
	add	bx,8*8
	and	bx,0ffffh-63
	jmp	kp1

kp3:
	push	cx
	add	cx,2
	push	dx
	push	cx
	push	bx
	push	ax
	call	hput
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	pop	cx
	add	bx,8
	;
	jmp	kp1

kp2:
	pop	di
	pop	si
	ret

	endp



;-----------------------------------------------------
;
;	screen H-double routine ( for 200 lines )
;
;-----------------------------------------------------

	PUBLIC	hdbl

hdbl	proc
	push	di
	;
	mov	bx,39		; read start idx.
	mov	di,78		; write start idx.
	mov	cx,200		; lines
hdb3:
	push	cx
	push	bx
	push	di
	mov	cx,40
hdb0:
	push	cx
	mov	ax,vram0
	call	hdb2
	mov	ax,vram1
	call	hdb2
	mov	ax,vram2
	call	hdb2
	mov	ax,vram3
	call	hdb2
	dec	di
	dec	di
	dec	bx
	pop	cx
	loop	hdb0
	;
	pop	di
	pop	bx
	add	di,80
	add	bx,80
	pop	cx
	loop	hdb3
	;
	pop	di
	ret

hdb2:
	mov	es,ax
	mov	dl,es:[bx]
	mov	cx,8
hdb1:
	shr	dl,1
	pushf
	rcr	ax,1
	popf
	rcr	ax,1
	loop	hdb1
	;
	mov	es:[di],ah
	inc	di
	mov	es:[di],al
	dec	di
	retn

	endp




;-----------------------------------------------------
;
;	screen V-double routine ( for 400 lines )
;
;-----------------------------------------------------

	PUBLIC	vdbl

vdbl	proc
	push	di
	;
	mov	bx,80*199	; read start idx.
	mov	di,80*398	; write start idx.
	mov	cx,200		; lines
vdb3:
	push	cx
	push	bx
	push	di
	mov	ax,vram0
	call	vdb2
	mov	ax,vram1
	call	vdb2
	mov	ax,vram2
	call	vdb2
	mov	ax,vram3
	call	vdb2
	;
	pop	di
	pop	bx
	sub	di,160
	sub	bx,80
	pop	cx
	loop	vdb3
	;
	pop	di
	ret

vdb2:
	push	di
	push	bx
	push	bx
	;
	mov	es,ax
	mov	cx,80
vdb1:
	mov	al,es:[bx]
	mov	es:[di],al
	inc	bx
	inc	di
	loop	vdb1
	;
	pop	bx
	mov	cx,80
vdb4:
	mov	al,es:[bx]
	mov	es:[di],al
	inc	bx
	inc	di
	loop	vdb4
	;
	pop	bx
	pop	di
	retn

	endp



;-----------------------------------------------------
;
;	xkd scrud,scrdup area for 400line
;
;-----------------------------------------------------


BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h

GDC_STAT	equ	0a0h
GDC_POUT	equ	0a0h
GDC_COUT	equ	0a2h



	;
	;	void gscroll( int sc_dir,int sc_len,int sc_step );
	;		sc_dir : 0=up 1=down 2=trans other=recover
	;		sc_len : lines ( max 400 )
	;		sc_step: scroll step ( 1～8 )
	;

gscroll	proc SC_DIR:word,SC_LEN:word,SC_STEP:word
public gscroll

	push	si
	push	di
	mov	ax,SC_DIR
	cmp	ax,2
	jz	sc_trans
	cmp	ax,3
	jnc	sc_recov
	;
	mov	SCROLL_DIRECTION,ax
	mov	ax,SC_LEN
	mov	SCROLL_LENGTH,ax
	mov	ax,SC_STEP
	mov	SCROLL_STEP,ax
	;
	call	main
	jmp	sc_over
sc_trans:
	call	TRANS
	jmp	sc_over
sc_recov:
	call	RECOVER
sc_over:
	pop	di
	pop	si
	ret


GDC_SCROLL:
	call	VWAIT
	mov	al,70h			;SCROLL COMMAND
	call	GDC_COM_OUT
	mov	cx,SCREEN_GDC_ADDR	;cx = SCREEN_LINE_COUNTER * 40
	add	cx,4000h
	mov	dx,400
	call	SCROLL_PARA_SET
	mov	cx,4000h
	mov	dx,1
	call	SCROLL_PARA_SET
	retn
	
SCROLL_PARA_SET:
	mov	ax,cx			;SCROLL START POINT
	call	GDC_PARAW_OUT
	mov	ax,dx			;SCROLL LENGTH
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	 push	ax
	in	al,31h
	test	al,80h
	 pop	ax
	jnz	para_set_j2
	or	ax,4000h
para_set_j2:
	call	GDC_PARAW_OUT
	retn
	

	;
	;ＧＤＣコマンド送出
	;		al = COMMAND
GDC_COM_OUT:
	mov	ah,al
gdc_com_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_com_l1
	mov	al,ah
	out	GDC_COUT,al
	retn
	;
	;ＧＤＣパラメータ送出（バイト）
	;		al = PARAM (BYTE)
GDC_PARA_OUT:
	mov	ah,al
gdc_out_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_out_l1
	mov	al,ah
	out	GDC_POUT,al
	retn
	;
	;ＧＤＣパラメータ送出（ワード）
	;		ax = PARAM (WORD)
GDC_PARAW_OUT:
	 push	ax
	call	GDC_PARA_OUT
	 pop	ax
	mov	al,ah
	call	GDC_PARA_OUT
	retn

VWAIT:
vwait_l1:
	in	al,0a0h
	test	al,00100000b
	jnz	vwait_l1
vwait_l2:
	in	al,0a0h
	test	al,00100000b
	jz	vwait_l2
	retn

main:
	;mov	ax,cs
	;mov	ds,ax
	call	ACCESS_PAGE0
	mov	al,0
	out	0a4h,al
	mov	SCREEN_LINE_COUNTER,0
	cmp	SCROLL_DIRECTION,0
	jnz	sc_down
SC_UP:
	mov	SCREEN_GDC_ADDR,0
sc_up_l2:
	call	GDC_SCROLL
	mov	cx,SCROLL_STEP
sc_up_j2_l1:
	mov	ax,SCREEN_LINE_COUNTER
	cmp	ax,SCROLL_LENGTH
	jnc	sc_up_j9
	inc	ax
	mov	SCREEN_LINE_COUNTER,ax
	mov	dx,SCREEN_GDC_ADDR
	add	dx,dx
	add	SCREEN_GDC_ADDR,40
	call	ACCESS_PAGE1
	call	TRANS_SCREEN_TO_BUFFER_P4
	add	dx,80*400
	and	dx,7fffh
	call	ACCESS_PAGE0
	call	TRANS_BUFFER_TO_SCREEN_P4
	loop	sc_up_j2_l1
	jmp	sc_up_l2
sc_up_j9:
	call	GDC_SCROLL
	retn
	
SC_DOWN:
	mov	SCREEN_LINE_COUNTER,400
	mov	SCREEN_GDC_ADDR,4000h
sc_down_l2:
	call	GDC_SCROLL
	mov	cx,SCROLL_STEP
sc_down_l1:
	mov	ax,SCREEN_LINE_COUNTER
	test	ax,ax
	jz	sc_down_j9
	sub	SCREEN_GDC_ADDR,40
	dec	ax
	mov	SCREEN_LINE_COUNTER,ax
	mov	dx,80
	mul	dx
	mov	dx,ax
	call	ACCESS_PAGE1
	call	TRANS_SCREEN_TO_BUFFER_P4
	mov	dx,SCREEN_GDC_ADDR
	add	dx,dx
	call	ACCESS_PAGE0
	call	TRANS_BUFFER_TO_SCREEN_P4
	loop	sc_down_l1
	jmp	sc_down_l2
sc_down_j9:
	call	GDC_SCROLL
	retn
	
TRANS_SCREEN_TO_BUFFER:
	 push	ds
	mov	si,dx
	mov	ds,ax
	mov	bx,cs
	mov	es,bx
	mov	cx,40
	rep	movsw
	 pop	ds
	retn
	
TRANS_BUFFER_TO_SCREEN:
	 push	ds
	mov	di,dx
	mov	es,ax
	mov	bx,cs
	mov	ds,bx
	cmp	di,80*409
	jz	to_screen_j1
	mov	cx,40
	rep	movsw
	 pop	ds
	retn
to_screen_j1:		;画面をまたぐ時
	mov	cx,24
	rep	movsw
	mov	di,0
	mov	cx,16
	rep	movsw
	 pop	ds
	retn
TRANS_BUFFER_TO_SCREEN_P4:
	 push	cx
	lea	si,BUFFER
	mov	ax,BANK_B
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_R
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_G
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_E
	call	TRANS_BUFFER_TO_SCREEN
	 pop	cx
	retn
TRANS_SCREEN_TO_BUFFER_P4:
	 push	cx
	lea	di,BUFFER
	mov	ax,BANK_B
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_R
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_G
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_E
	call	TRANS_SCREEN_TO_BUFFER
	 pop	cx
	retn
	
ACCESS_PAGE0:
	mov	al,0
	jmp	ACCESS_PAGE_j1
ACCESS_PAGE1:
	mov	al,1
ACCESS_PAGE_j1:
	out	0a6h,al
	retn
	
	;
	;表示を直す
	;
RECOVER:
	;mov	ax,cs
	;mov	ds,ax
	mov	SCREEN_GDC_ADDR,0
	call	GDC_SCROLL
	mov	al,1
	out	0a4h,al
	
	mov	dx,0
	mov	cx,400
recover_l1:
	call	ACCESS_PAGE1
	call	TRANS_SCREEN_TO_BUFFER_P4
	call	ACCESS_PAGE0
	call	TRANS_BUFFER_TO_SCREEN_P4
	add	dx,80
	loop	recover_l1
	mov	al,0
	out	0a4h,al
	retn

	;
	;表画面から裏画面へ転送する
	;
TRANS:
	;mov	ax,cs
	;mov	ds,ax
	mov	dx,0
	mov	cx,400
trans_l1:
	call	ACCESS_PAGE0
	call	TRANS_SCREEN_TO_BUFFER_P4
	call	ACCESS_PAGE1
	call	TRANS_BUFFER_TO_SCREEN_P4
	add	dx,80
	loop	trans_l1
	call	ACCESS_PAGE0
	retn

BUFFER			db	320 dup (0)

gscroll	endp


	;
	;	void	set_page( int apage, int dpage );
	;
set_page	proc apage:word,dpage:word
public set_page
	;
	MOV	AL,0
	OUT	07CH,AL
	mov	ax,dpage
	out	0a4h,al
	mov	ax,apage
	out	0a6h,al
	;
	ret
set_page	endp



_TEXT	ends


;-------------------------------------------------
;	data segment
;-------------------------------------------------


DGROUP	GROUP	_DATA
_DATA	segment	word public 'DATA'

SCROLL_STEP		dw	1		;１回のスクロール幅
SCROLL_LENGTH		dw	400		;スクロール幅
SCROLL_DIRECTION	dw	0		;0 = UP ,other = DOWN
SCREEN_LINE_COUNTER	dw	0
SCREEN_GDC_ADDR		dw	0

PUTAD		DW 0
TILE_TOP	DW 0
FILE_END	DW 0
LOOK_AD		DW 0
NULL_COLOR	DB 0
WIDECT		DB 0
LINECT		DB 0
WIDEOF		DB 0	;横位置オフセット　０－（ＷＩＤＥＣＴ－１）
LINEOF		DB 0	;縦
GRCT		DB 0
TILE_AD		DW 0
POKE_AD		DW 0
BASE_AD		DW 0
CSRX		DB 1	;内部用Ｘ座標
CSRY		DB 1	;　　　Ｙ座標

TEMPP		DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TILE_BUF	DW 0
DUMY		DB 0,255,255,0,255,255
GRW0		DB 0
GRW1		DB 0
GRW2		DB 0
MASK_BIT	DB 0
		;
xpats		dw	?			; 左端ビットデータ
xpate		dw	?			; 右端ビットデータ
lndx		dw	?			; 横バイト数

_gc_set		db	?		; GRCG グラフィックチャージャー
					; 0 = 無し, 1 =	有り
_egc_set	db	?		; EGC エンハンストGRCG
					; 0 = 無し, 1 =	有り
_board16_set	db	?		; 16色ボード
					; 0 = 無し, 1 =	有り
_gdc_clock	db	?		; GDC クロック
					; 0 = 2.5MHz, 1	= 5MHz
kanji_data	dw	KANJI_H dup (?)


_DATA		ENDS


;-------------------------------------------------
;	end of line
;-------------------------------------------------

	END


