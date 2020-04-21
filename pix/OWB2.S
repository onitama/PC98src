;---------------------------------------------------------------
;	advanced window logic and pix control
;	with pc98 hardware bios routines for TC : 'OWB2'
;	created 1993-1995 onion software/onitama/XKD/Ana.
;---------------------------------------------------------------

	.MODEL small,C
	.186
	.CODE


vram_b		equ	0a800h
vram_r		equ	0b000h
vram_g		equ	0b800h
vram_e		equ	0e000h

GDC_STAT	equ	0a0h
GDC_POUT	equ	0a0h
GDC_COUT	equ	0a2h


;-------------------------------------------------
;	work area on code segment
;-------------------------------------------------

owb_seg		dw	0		; window BG buffer (128K)
pix_seg		dw	0		; PIX mode segment
pix_mode	dw	0		; type of mask mode
pix_data	dw	16 dup(0)	; PIX mode index data

pix_col1	dw	0		; dark color
pix_col2	dw	0		; light color
pix_cpc1	dw	0		; color compare value1
pix_cpc2	dw	0		; color compare value2

padr		dw	0		; work temp
psx		db	0
psy		db	0
pmos1		dw	0		; mosaic value1
pmos2		dw	0


SCROLL_STEP		dw	1		;１回のスクロール幅
SCROLL_LENGTH		dw	400		;スクロール幅
SCROLL_DIRECTION	dw	0		;0 = UP ,other = DOWN
SCREEN_LINE_COUNTER	dw	0
SCREEN_GDC_ADDR		dw	0

BUFFER			db	320 dup (0)

xpats		dw	?			; 左端ビットデータ
xpate		dw	?			; 右端ビットデータ
lndx		dw	?			; 横バイト数


;-------------------------------------------------
;	code segment
;-------------------------------------------------

;---------------------------------------------------------------
;
;	window logic bios from C ( small model )
;	started 1994/2 onitama
;
;	void	owb_init( int owb_work_seg );
;	void	owb_wipe( int wsx, int wsy, int wex, int wey );
;	void	owb_redraw();
;
;---------------------------------------------------------------

	;
	;	initalize
	;	send vram to owb buffer
	;
	public	owb_init
owb_init	PROC	arg1:word

		mov	ax,arg1
		mov	cs:owb_seg,ax
		;
		push	ds
		push	si
		push	di
		;
		mov	ax,cs:owb_seg
		mov	bx,vram_b
		call	sendbf
		mov	bx,vram_r
		call	sendbf
		mov	bx,vram_g
		call	sendbf
		mov	bx,vram_e
		call	sendbf
		;
		pop	di
		pop	si
		pop	ds
		ret

sendbf:
		xor	si,si
		xor	di,di
		push	ax
		mov	es,ax
		mov	ax,bx
		mov	ds,ax
		;
		cld
		mov	cx,04000h
		rep	movsw
		;
		pop	ax
		add	ax,0800h
		retn
	ENDP



	;
	;	window BG redraw ( all )
	;
	public	owb_redraw
owb_redraw	PROC

		push	ds
		push	si
		push	di
		;
		mov	ax,cs:owb_seg
		mov	bx,vram_b
		call	sendfb
		mov	bx,vram_r
		call	sendfb
		mov	bx,vram_g
		call	sendfb
		mov	bx,vram_e
		call	sendfb
		;
		pop	di
		pop	si
		pop	ds
		ret

sendfb:
		xor	si,si
		xor	di,di
		push	ax
		mov	ds,ax
		mov	ax,bx
		mov	es,ax
		;
		cld
		mov	cx,04000h
		rep	movsw
		;
		pop	ax
		add	ax,0800h
		retn
	ENDP



	;
	;	window BG redraw at selected area
	;
	public	owb_wipe
owb_wipe	PROC	sx:word, sy:word, ex:word, ey:word

		mov	ax,ey
		sub	ax,sy
		jc	no_wipe
		inc	ax
		mov	dx,ax
		;
		mov	bx,sx
		and	bx,0fff0h
		mov	ax,ex
		sub	ax,bx
		jc	no_wipe
		shr	ax,4			; /16 (word)
		inc	ax
		mov	cx,ax
		;
		push	ds
		push	si
		push	di
		;
		mov	ax,sy
		shl	ax,4
		mov	bx,ax
		shl	ax,2
		add	bx,ax			; y x80
		;
		mov	ax,sx
		shr	ax,3
		add	bx,ax			; +x
		;
		mov	ax,cs:owb_seg
		mov	ds,ax
		;
		mov	ax,vram_b
		call	wipexe
		mov	ax,vram_r
		call	wipexe
		mov	ax,vram_g
		call	wipexe
		mov	ax,vram_e
		call	wipexe
		;
		pop	di
		pop	si
		pop	ds
no_wipe:
		ret

wipexe:
		mov	es,ax
		;
		push	bx
		push	cx
		push	dx
		mov	ax,cx
wexe_1:
		cld
		mov	si,bx
		mov	di,bx
		mov	cx,ax
		rep	movsw
		;
		add	bx,80
		dec	dx
		jnz	wexe_1
		;
		pop	dx
		pop	cx
		pop	bx
		mov	ax,ds
		add	ax,0800h
		mov	ds,ax
		;
		retn

	ENDP



	public	pix_fput
pix_fput	PROC	scrx:word, scry:word, sizex:word, sizey:word, fcol:word, datseg:word

		push	ds
		push	si
		push	di
		;
		call	Grcgon
		mov	ax,fcol
		call	grcgcolor
		;
		mov	ax,scrx
		mov	dx,scry
		call	vcalq
		;
		mov	ax,datseg
		mov	ds,ax
		mov	ax,vram_b
		mov	es,ax
		xor	si,si
		mov	di,bx
		;
		mov	dx,sizey
		xor	cx,cx
		mov	ax,sizex
		shr	ax,4
		mov	dh,al
		;
pxfp1:
		mov	cl,dh
pxfp2:
		mov	ax,ds:[si]
		mov	es:[bx],ax
		inc	si
		inc	si
		inc	bx
		inc	bx
		loop	pxfp2
		;
		add	di,80
		mov	bx,di
		dec	dl
		jnz	pxfp1
		;
		call	Grcgoff
		pop	di
		pop	si
		pop	ds
		ret
	endp



	public	pix_icon
pix_icon	PROC	scrx:word, scry:word, icseg:word, icnum:word

		push	ds
		push	si
		;
		call	Grcgon
		mov	ax,cs:pix_col1
		call	grcgcolor
		;
		mov	ax,scrx
		mov	dx,scry
		call	vcalq
		;
		mov	ax,icnum
		mov	cx,24
		imul	cx
		add	ax,icseg
		mov	es,ax
		mov	ax,vram_b
		mov	ds,ax
		;
		push	bx
		mov	si,192
		call	putilp0
		;
		mov	ax,cs:pix_col2
		call	grcgcolor
		pop	bx
		xor	si,si
		call	putilp0
		;
		call	Grcgoff
		pop	si
		pop	ds
		ret

putilp0:
		mov	cx,32
putilp1:
		mov	ax,es:[si]
		mov	ds:[bx],ax
		inc	bx
		inc	bx
		inc	si
		inc	si
		mov	ax,es:[si]
		mov	ds:[bx],ax
		inc	bx
		inc	bx
		inc	si
		inc	si
		mov	ax,es:[si]
		mov	ds:[bx],ax
		add	bx,80-4
		inc	si
		inc	si
		loop	putilp1
		retn

	endp



	;
	;	PIX mode initalize
	;	send header info to buffer
	;
	public	pix_init
pix_init	PROC	arg1:word

		push	si
		mov	ax,arg1
		mov	pix_seg,ax
		mov	es,ax
		;
		mov	si,010h
		mov	bx,1
		mov	ax,es:[bx]
		cmp	ax,05850h
		jnz	pixiskip

		;	get PIX header
		;
		lea	bx,pix_data
		mov	cx,32
pixhst:
		mov	al,es:[si]
		mov	cs:[bx],al
		inc	bx
		inc	si
		loop	pixhst
		;
		jmp	short pixcolchk

pixiskip:
		;	PIX header clear
		;
		lea	bx,pix_data
		xor	ax,ax
		mov	cx,16
pixhst2:
		mov	cs:[bx],ax
		inc	bx
		inc	bx
		loop	pixhst2

pixcolchk:
		xor	ax,ax
		mov	cs:pmos1,ax
		mov	ax,1
		mov	cs:pmos2,ax
		;
		mov	cs:pix_col1,0
		mov	cs:pix_cpc1,0fffh
		mov	cs:pix_col2,15
		mov	cs:pix_cpc2,0
		mov	cx,0
schcol1:
		mov	ax,es:[si]
		mov	dl,ah
		shr	dl,4
		and	ah,15
		add	al,ah
		add	al,dl
		xor	ah,ah
		cmp	ax,cs:pix_cpc1
		jnc	schcol2
		;
		mov	cs:pix_cpc1,ax
		mov	cs:pix_col1,cx
schcol2:
		cmp	ax,cs:pix_cpc2
		jc	schcol3
		;
		mov	cs:pix_cpc2,ax
		mov	cs:pix_col2,cx
schcol3:
		;
		inc	si
		inc	si
		inc	cx
		cmp	cx,16
		jnz	schcol1
		;
		pop	si
		ret
	ENDP


	;
	;	PIX color info get
	;
	public	pix_getcol1
pix_getcol1	PROC
		mov	ax,cs:pix_col1
		ret
	ENDP


	;
	;	PIX color info get
	;
	public	pix_getcol2
pix_getcol2	PROC
		mov	ax,cs:pix_col2
		ret
	ENDP


	;
	;	PIX mode change
	;
	public	pix_setmode
pix_setmode	PROC	arg1:word

		mov	ax,cs:pix_mode
		mov	dx,arg1
		mov	cs:pix_mode,dx
		ret
	ENDP


	;
	;	get PIX mask mode info.
	;
	public	pix_getmode
pix_getmode	PROC

		lea	si,pix_data
		mov	cx,16
		xor	ax,ax
pixgetlp:
		add	ax,cs:[si]
		inc	si
		inc	si
		loop	pixgetlp
		;
		or	ax,ax
		jz	nopixmd
		;
		mov	ax,cs:pix_mode
		ret
nopixmd:
		mov	ax,-1
		ret
	ENDP


	public	pix_mosinc
pix_mosinc	PROC

		mov	ax,cs:pmos1
		add	ax,80
		cmp	ax,320
		jc	pix_mpr3
		;
		mov	ax,cs:pmos2
		inc	ax
		cmp	al,5
		jc	pix_mpr4
		mov	ax,1
pix_mpr4:
		mov	cs:pmos2,ax
		xor	ax,ax
pix_mpr3:
		mov	cs:pmos1,ax
		;
		ret
	ENDP


	;
	;	PIX mode mask execute
	;	**set index info before execute
	;
	public	pix_exec
pix_exec	PROC

		push	ds
		push	si
		push	di
		;
		mov	cx,4
		lea	si,pix_data
pix_sel:
		mov	ax,cs:[si]
		or	ax,ax
		jz	pix_selov
		;
		push	cx
		push	si
		;
		mov	ax,cs:pix_mode
		cmp	ax,1
		jz	pix_exe1
		cmp	ax,2
		jz	pix_exe2
		cmp	ax,3
		jz	pix_exe3
		;
		call	pix_mosa
		jmp	short pix_exeov
pix_exe3:
		call	pix_beta
		jmp	short pix_exeov
pix_exe2:
		call	pix_efc
		jmp	short pix_exeov
pix_exe1:
		call	pix_ami
pix_exeov:
		pop	si
		pop	cx
pix_selov:
		add	si,8
		loop	pix_sel
		;
		pop	di
		pop	si
		pop	ds
		ret
	ENDP


pix_mosa	PROC	near
		;					execute mosaic mask
		call	maskpre
		;
		mov	si,cs:pmos1
		;
		mov	di,cs:owb_seg
		mov	ax,vram_b
		mov	es,ax
		call	pix_msend
		mov	ax,vram_r
		mov	es,ax
		call	pix_msend
		mov	ax,vram_g
		mov	es,ax
		call	pix_msend
		mov	ax,vram_e
		mov	es,ax
		call	pix_msend
		;
		ret
pix_msend:
		mov	ax,di
		mov	ds,ax
		add	di,0800h
		;
		mov	cx,cs:pmos2
		mov	dh,cs:psy
		mov	bx,cs:padr
pix_mlp1:
		mov	ch,cs:psx
		push	bx
pix_mlp2:
		mov	al,ds:[si+bx]
		mov	ah,al
		shr	al,cl
		rcr	dl,1
		sar	dl,3
		shl	ah,cl
		rcr	dl,1
		sar	dl,3
		mov	es:[bx],dl
		mov	es:[bx+050h],dl
		mov	es:[bx+0a0h],dl
		mov	es:[bx+0f0h],dl
		;
		inc	bx
		dec	ch
		jnz	pix_mlp2
		;
		pop	bx
		add	bx,320
		dec	dh
		jnz	pix_mlp1
		;
		retn
	ENDP


pix_beta	PROC	near
		;					execute beta mask
		call	maskpre
		;
		call	Grcgon
		mov	ax,cs:pix_col1
		call	grcgcolor
		;
		mov	ax,vram_b
		mov	es,ax
		;
		xor	ch,ch
		xor	dh,dh
		mov	dl,cs:psy
		shl	dx,2
		mov	si,cs:padr
		mov	al,-1
pix_blp1:
		mov	bx,si
		mov	cl,cs:psx
pix_blp2:
		mov	es:[bx],al
		inc	bx
		loop	pix_blp2
		;
		add	si,80
		dec	dx
		jnz	pix_blp1
		;
		call	Grcgoff
		ret
	ENDP


pix_ami		PROC	near
		;					execute mesh mask
		call	maskpre
		;
		call	Grcgon
		mov	ax,cs:pix_col2
		call	grcgcolor
		;
		mov	ax,vram_b
		mov	es,ax
		;
		xor	ch,ch
		mov	dl,cs:psy
		mov	si,cs:padr
		mov	al,0bbh
		mov	ah,0eeh
		mov	dh,0ffh
pix_alp1:
		mov	bx,si
		mov	cl,cs:psx
pix_alp2:
		mov	es:[bx],dh
		mov	es:[bx+80],al
		mov	es:[bx+160],dh
		mov	es:[bx+240],ah
		inc	bx
		loop	pix_alp2
		;
		add	si,320
		dec	dl
		jnz	pix_alp1
		;
		call	Grcgoff
		ret
	ENDP


pix_efc		PROC	near
		;					execute mask effect
		call	maskpre
		;
		mov	ax,cs:owb_seg
		mov	ds,ax
		mov	ax,vram_e
		mov	es,ax
		;
		xor	ch,ch
		mov	dl,cs:psy
		mov	dh,-1
		mov	si,cs:padr
pix_elp1:
		mov	bx,si
		mov	cl,cs:psx
pix_elp2:
		mov	al,ds:[bx+0f0h]
		not	al
		xor	al,0aah
		mov	es:[bx],al
		;
		mov	al,ds:[bx+0a0h]
		not	al
		xor	al,055h
		mov	es:[bx+80],al
		;
		mov	al,ds:[bx+050h]
		not	al
		xor	al,0aah
		mov	es:[bx+160],al
		;
		mov	al,ds:[bx]
		not	al
		xor	al,055h
		mov	es:[bx+240],al
		;
		inc	bx
		loop	pix_elp2
		;
		add	si,320
		dec	dl
		jnz	pix_elp1

		mov	ax,vram_b
		mov	es,ax
		mov	ax,vram_g
		mov	ds,ax
		;
		xor	ch,ch
		mov	dl,cs:psy
		shl	dx,2
		mov	dh,0
		mov	si,cs:padr
pix_elp3:
		mov	bx,si
		mov	cl,cs:psx
pix_elp4:
		mov	es:[bx],dh
		mov	es:[bx+8000h],dh
		mov	ds:[bx],dh
		inc	bx
		loop	pix_elp4
		;
		add	si,80
		dec	dl
		jnz	pix_elp3
		;
		ret
	ENDP



	;---------------------------------------------------------
	;	get axis info & set data
	;---------------------------------------------------------
maskpre		proc	near
		mov	ax,cs:[si]
		mov	dx,cs:[si+2]
		call	vcalq
		mov	cs:padr,bx
		;
		xor	dx,dx
		mov	ax,cs:[si+4]
		mov	cx,ax
		and	cx,7
		jz	pix_mpr1
		inc	dx
pix_mpr1:
		shr	ax,3
		add	ax,dx
		mov	cs:psx,al
		;
		xor	dx,dx
		mov	ax,cs:[si+6]
		mov	cx,ax
		and	cx,3
		jz	pix_mpr2
		inc	dx
pix_mpr2:
		shr	ax,2
		add	ax,dx
		mov	cs:psy,al
		;
		ret
	endp


	;---------------------------------------------------------
	;	vram adr. calculate
	;		ax( x/0-639 ),dx( y/0-399 ) -> bx (x&7=cx)
	;---------------------------------------------------------
vcalq	proc	near
		mov	cx,ax
		and	cx,7
		shr	ax,3
		mov	bx,ax
		shl	dx,4
		add	bx,dx
		shl	dx,2
		add	bx,dx
		ret
	endp


	;----------------------------------------------
	;	some useful routines for GRCG
	;----------------------------------------------

	;
	;  RMW mode on
	;
Grcgon	PROC	near
		mov	al,0C0h		; Grcg RMW mode
		call	GrcgMode
		ret
	ENDP


GrcgMode	proc	near
	push	es
	push	0
	pop	es
	pushf
	cli
	out	7Ch,al
	mov	es:[0495h],al	; GRCG mode データ格納
	popf
	pop	es
	ret
	endp

	;
	;  GRCG off
	;
Grcgoff	PROC	near
		xor	al,al
		call	GrcgMode
		ret
	ENDP

	;
	; set GRCG color tile register to color al(0-15)
	;
grcgcolor	PROC near
		xor	ah,ah
		and	al,00fh
		mov	dx,ax
		pushf
		cld
		push	di
		push	es
		mov	di,0496h	; Grcg Tile register 格納アドレス
		sub	ax,ax
		mov	es,ax
		mov	ax,dx
		pushf
		cli
	REPT 4
		ror	al,1
		cbw
		xchg	ah,al
		out	07Eh,al
		stosb
		xchg	ah,al
	ENDM
		popf
		pop	es
		pop	di
		popf
		ret
GrcgColor	ENDP



;---------------------------------------------------------
;  グラフィックボックスフィル
;  void gfill(int X1,int Y1,int X2,int Y2,int Color)
;  IN  : int X1,Y1 ボックス左上端座標
;        int X2,Y2 ボックス右下端座標
;	 int Color 塗り潰す色番号
;----------------------------------------------------------



;---------- ボックスフィルサブルーチン
;  IN : di = 先頭VRAM アドレス, cx = 縦ライン数

BoxFill		PROC near
		mov	ax,0A800h
		mov	es,ax
		mov	ax,[lndx]
		or	ax,ax
		js	boxf_1			; 横幅1word
		jz	boxf_2			; 横幅2word
;---------- 横幅3word以上

		mov	bx,cs:[xpats]	;
		mov	dx,cs:[xpate]
		mov	ax,0FFFFh
boxf_01:		
		push	cx
		push	di
		mov	cx,cs:[lndx]
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
		mov	ax,cs:[xpats]
		and	ax,cs:[xpate]
boxf_11:	mov	es:[di],ax
		add	di,80
		loop	boxf_11
		jmp	boxf_exit	

;---------- 横幅2word
boxf_2:
		mov	ax,cs:[xpats]
		mov	dx,cs:[xpate]
boxf_21:		
		stosw
		mov	es:[di],dx
		add	di,80 - 2
		loop	boxf_21
		jmp	boxf_exit	
BoxFill		ENDP


BoxFill2	PROC near
		mov	ax,0A800h
		mov	es,ax
		mov	ax,[lndx]
		or	ax,ax
		js	boxf_1			; 横幅1word
		jz	boxf_2			; 横幅2word

		mov	bx,cs:[xpats]
		mov	dx,cs:[xpate]
		mov	ax,0AAAAh		; for mesh
		jmp	short boxf_01
		ENDP



		PUBLIC bfill
bfill		PROC X1:WORD,Y1:WORD,X2:WORD,Y2:WORD,Color:WORD
		push	di
		cld
		call	Grcgon			; RMW モード設定
		mov	ax,Color
		call	Grcgcolor		; GRCG タイルレジスタ設定
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
		mov	cs:[xpats],ax		; 左端のビットデータ
		mov	cx,dx
		and	cx,000Fh	
		sub	cx,000Fh
		neg	cx
		mov	ax,0FFFFh
		shl	ax,cl
		xchg	ah,al
		mov	cs:[xpate],ax		; 右端のビットデータ
		shr	bx,4			; bx = x1
		mov	di,bx
		shr	dx,4			; dx = x2
		sub	dx,di
		dec	dx
		mov	cs:[lndx],dx
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
		call	Grcgoff			; GRCG リセット
		pop	di
		ret
bfill		ENDP



		PUBLIC meshf
meshf		PROC X1:WORD,Y1:WORD,X2:WORD,Y2:WORD,Color:WORD
		push	di
		cld
		call	Grcgon			; RMW モード設定
		mov	ax,Color
		call	GrcgColor		; GRCG タイルレジスタ設定
		mov	bx,X1			; bx = x1
		mov	dx,X2			; dx = x2
		mov	ax,639
		cmp	bx,ax
		jbe	mboxf_1
		mov	bx,ax
mboxf_1:
		cmp	dx,ax
		jbe	mboxf_2
		mov	dx,ax
mboxf_2:
		cmp	bx,dx
		jbe	mnot_xchg
		xchg	bx,dx			; X1 > X2 ならX1,X2を入れ替える
mnot_xchg:
		mov	cx,bx
		and	cx,00Fh
		mov	ax,0FFFFh
		shr	ax,cl	
		xchg	ah,al
		and	ax,0AAAAH		; for mesh
		mov	cs:xpats,ax		; 左端のビットデータ
		mov	cx,dx
		and	cx,000Fh
		sub	cx,000Fh
		neg	cx
		mov	ax,0FFFFh
		shl	ax,cl
		xchg	ah,al
		and	ax,0AAAAH		; for mesh
		mov	cs:xpate,ax		; 右端のビットデータ
		shr	bx,4			; bx = x1
		mov	di,bx
		shr	dx,4			; dx = x2
		sub	dx,di
		dec	dx
		mov	cs:lndx,dx
		shl	di,1
		mov	ax,Y1
		mov	cx,Y2
		mov	dx,399
		cmp	ax,dx
		jbe	mboxf_3
		mov	ax,dx
mboxf_3:
		cmp	cx,dx
		jbe	mboxf_4
		mov	cx,dx
mboxf_4:
		cmp	ax,cx
		jbe	mnot_ychg
		xchg	ax,cx			; Y1 > Y2 ならY1,Y2を入れ替える
mnot_ychg:
		sub	cx,ax
		inc	cx
		mov	dx,80
		mul	dx
		add	di,ax			; di = 先頭VRAMアドレス
		call	BoxFill2
		call	Grcgoff			; GRCG リセット
		pop	di
		ret
		ENDP



;-------------------------------------------------
;	subroutines for binary file save/load
;-------------------------------------------------

	PUBLIC	segload
segload		proc fp:WORD,fseg:WORD,fsize:WORD
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
segsave		proc fp:WORD,fseg:WORD,fsize:WORD
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


;-----------------------------------------------------
;	graphics screen initalize
;
;  int	ginit( int Lines, int SPage , int Sswitch );
;
;  	int Lines      0 = 200 lines	1 = 400 lines
;	int SPage      0 = page 0	1 = page 1
;	int Sswitch    0 = screen off   1 = screen on
;
;	result : 0=Ok -1=Hardware failue
;
;-----------------------------------------------------

	public	ginit
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
		;
		xor	dx,dx
		mov	al,_gc_set
		or	al,al
		jz	fran3
		;
		mov	al,_board16_set
		or	al,al
		jz	fran3
fran2:
		xor	ax,ax
		ret
fran3:
		mov	ax,-1
		ret
ginit	endp



	;
	;	void	set_page( int apage, int dpage );
	;
	public set_page
set_page	proc apage:word,dpage:word
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


;---------- アナログパレット設定 ------------
;    CX=color no.  AX=色コード
;--------------------------------------------

	PUBLIC	set_palet
set_palet	proc	pal:WORD,col:WORD

		mov	cx,pal
		mov	ax,col

		push	ax
		;
		mov	al,cl
		out	0A8h,al		; パレットレジスタNo.設定
		;
		pop	ax
		mov	dx,ax
		xchg	ah,al
		out	0AAh,al		; パレットGreen
		and	ah,0F0h
		mov	cl,4
		shr	ah,cl
		xchg	ah,al
		out	0ACh,al		; パレットRed
		mov	ax,dx
		and	ax,0Fh
		out	0AEh,al		; パレットBlue

		ret
set_palet	endp


;-----------------------------------------------------
;  グラフィック画面消去
;  void	gcls(int Color)
;  IN  : int Color 画面を消去する色番号
;-----------------------------------------------------

	public	gcls
gcls		PROC Color : WORD
		push	di

		mov	ah,41h
		int	18h

		call	Grcgon
		mov	ax,Color
		call	grcgcolor

		sub	di,di		; di = 0
		mov	ax,0A800h	; Plane 0 セグメント
		mov	es,ax
		mov	cx,80 * 400 / 2	; Plane 0 VRAM のバイト数 / 2
		mov	ax,-1
		rep	stosw		; cx ワード画面に書き込む

		call	Grcgoff		; GRCG リセット

		mov	ah,40h
		int	18h

		pop	di
		ret
gcls		ENDP


;-------------------------------------------------
;		graphics chip status 
;-------------------------------------------------

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


;-------------------------------------------------
;	for text screen routines
;-------------------------------------------------

	public	t_cls,t_on,t_off

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


;-------------------------------------------------
;	realtime key input lib.
;	int joyin(),void jinit(),int kinp( int )
;-------------------------------------------------
	PUBLIC	joyin,jinit,kinp

kinp	proc	k_matrix:word

		push	di
		mov	ax,0000			;ＫＥＹ　バッファを０にする。
		mov	es,ax
		mov	di,0528H
		mov	al,0
		mov	es:[di],al
		;
		mov	ax,k_matrix
		mov	ah,04
		int	18h
		mov	al,ah
		mov	ah,0
		pop	di
		ret
	endp


jinit	proc
		mov	ah,03H
		int	18H
		;mov	ah,0CH
		;int	18H
		ret
	endp


;-------------------------------------------------
;	realtime key input routine
;	for ( 2,4,6,8,[x],[space],[z] )
;         + ( cursor key , [ret] )
;-------------------------------------------------


joyin	proc
		push	di
		;
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
		;
		mov	cx,140H
wtloop2:	out	005FH,al
		loop	wtloop2
		;
		call	joysub
		call	joysub2
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
;  void kputc(unsigned int KANJI,int XP,int YP,int COLOR)
;  unsigned int KANJI : 漢字シフトJISコード
;           int XP    : 表示 横座標 0～639-16
;           int YP    : 表示 縦座標 0～400-16
;           int COLOR : 表示カラー 
;                       bit4 = 0 : 普通文字 
;                            = 1 : 太文字 
;			bit5 = 1 : 特殊文字(8dot/adr) type1
;			bit6 = 1 : 特殊文字(8dot/adr) type2
;--------------------------------------------------------------  

KANJI_H		equ	16
shift_cnt	db	3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
shift_cnt2	db	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0


;-------------------------------------------------------------
;	kanji string print （全角のみ）
;	void kprt( int XP, int YP, unsigned char *str );
;-------------------------------------------------------------

	public	kprt
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
		call	kputc
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
		;					ignore ank code
		jmp	kp1
kp2:
		pop	di
		pop	si
		ret
	endp


View16		PROC
		imul	di,cx,80
		mov	ax,bx
		shr	ax,3
		add	di,ax

		call	Grcgon
		push	dx
		mov	ax,dx
		call	grcgcolor
		;
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
		call	Grcgoff
		ret

View16		ENDP


		PUBLIC	kputc
kputc	PROC USES si di,KANJI:WORD,XP:WORD,YP:WORD,COLOR:WORD
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
kputc	ENDP


	;
	;	void gscroll( int sc_dir,int sc_len,int sc_step );
	;		sc_dir : 0=up 1=down 2=trans other=recover
	;		sc_len : lines ( max 400 )
	;		sc_step: scroll step ( 1～8 )
	;

	public gscroll
gscroll	proc SC_DIR:word,SC_LEN:word,SC_STEP:word

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
	mov	ax,vram_b
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,vram_r
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,vram_g
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,vram_e
	call	TRANS_BUFFER_TO_SCREEN
	 pop	cx
	retn
TRANS_SCREEN_TO_BUFFER_P4:
	 push	cx
	lea	di,BUFFER
	mov	ax,vram_b
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,vram_r
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,vram_g
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,vram_e
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

gscroll	endp



_TEXT	ends


;-------------------------------------------------
;	data segment
;-------------------------------------------------


DGROUP	GROUP	_DATA
_DATA	segment	word public 'DATA'

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