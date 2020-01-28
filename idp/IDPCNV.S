;---------------------------------------------------------------
;	data package system from C ( small model )
;	started 1994/5 onitama
;	enhance 1995/5 onitama
;
;	int	idp_init( int srcseg, int datseg, int wrtseg );
;	int	idp_make( int idxno, int datsize );
;
;---------------------------------------------------------------

	.MODEL small,C
	.186
	.CODE

packsize	equ	16
seginc		equ	1


;-------------------------------------------------
;	code segment
;-------------------------------------------------

	;
	;	system initalize
	;		idp_init( int srcseg, int datseg, int wrtseg );
	;
	public	idp_init
idp_init	proc	arg1:word, arg2:word, arg3:word

		mov	ax,arg1
		mov	cs:src_seg,ax
		mov	ax,arg2
		mov	cs:dat_seg,ax
		mov	ax,arg3
		mov	cs:wrt_seg,ax
		ret
	endp


	;
	;	pack execute
	;		idp_make( int idxno, int datsize );
	;
	public	idp_make
idp_make	proc	arg1:word, arg2:word

		;
		push	ds
		push	si
		push	di
		;
		mov	ax,arg1
		mov	cs:idxno,ax
		mov	ax,arg2
		mov	cs:datsize,ax
		;
		call	packmain
		;
		pop	di
		pop	si
		pop	ds
		ret
	endp

packmain	proc near

		;
		;	Index HEADER 書き込み
		;

		mov	ax,cs:wrt_seg
		mov	es,ax
		mov	bx,2
		mov	ax,es:[bx]			; last ptr.
		mov	cs:lastptr,ax

		mov	ax,es:[bx+2]			; last pck.
		mov	cs:lastpck,ax

		mov	ax,es:[bx+4]			; last idx no.
		mov	cs:lastidx,ax
		shl	ax,3				; x8
		mov	si,ax

		mov	ax,cs:idxno			; data header
		mov	es:[si],ax
		mov	ax,cs:lastptr
		mov	es:[si+2],ax
		mov	ax,cs:lastpck
		mov	es:[si+4],ax
		mov	ax,cs:datsize
		mov	es:[si+6],ax

		;
		;	データ作成
		;

		mov	ax,0
		mov	cs:newpck,ax
		mov	cs:startpck,ax
		mov	cs:pckzero,ax

		mov	di,cs:lastptr

		mov	ax,cs:dat_seg
		mov	ds,ax
		mov	cx,cs:datsize
idp_main1:
		push	cx
		call	idpchk
		call	mkidp
		pop	cx
		;
		mov	ax,ds
		add	ax,seginc
		mov	ds,ax
		;
		loop	idp_main1

		;
		;	データ作成終了
		;

		mov	dx,-2
		call	mkidp

		mov	ax,cs:wrt_seg
		mov	es,ax
		mov	bx,2
		mov	ax,di
		mov	es:[bx],ax

		mov	ax,cs:lastpck
		mov	es:[bx+2],ax
		mov	ax,es:[bx+4]
		inc	ax
		mov	es:[bx+4],ax

		mov	ax,cs:ttpck
		ret
	endp


idpchk		proc near

		;	src_seg内から同キャラを探す
		;
		mov	cx,cs:lastpck
		or	cx,cx
		jnz	idpsrch
		;
		mov	dx,0
		mov	ax,cs:src_seg
		mov	es,ax
		jmp	notsame
		;
idpsrch:
		mov	dx,0
		mov	ax,cs:src_seg
		mov	es,ax
chklop1:
		mov	bx,0
chklop2:
		mov	ax,ds:[bx]
		cmp	ax,es:[bx]
		jnz	chklop3
		inc	bl
		inc	bl
		cmp	bx,packsize
		jnz	chklop2

		;	同パケット発見
		;
		ret

chklop3:
		mov	ax,es
		add	ax,seginc
		mov	es,ax
		inc	dx
		;
		loop	chklop1

notsame:
		;	新規パケット
		;
		inc	cs:ttpck
		inc	dx
		mov	cs:lastpck,dx
		mov	cx,packsize/2
		mov	bx,0
chklop4:
		mov	ax,ds:[bx]
		mov	es:[bx],ax
		inc	bl
		inc	bl
		loop	chklop4
		;
		mov	dx,-1
		ret

	endp



mkidp		proc near

		;	IDPデータを書き込む
		;		dx=-1:new  0-16383:same as pck.
		;		   -2:new pck. check only
		;
		cmp	dx,-1
		jnz	mkidpx
		;
		jmp	samex0
mkidpx:
		;	新パケットチェック
		;
		mov	ax,cs:wrt_seg
		mov	es,ax
		mov	ax,cs:newpck
		or	ax,ax
		jz	nopck

		mov	es:[di],al
		inc	di
		mov	cs:newpck,0
		mov	cs:pckzero,0
nopck:
		cmp	dx,-2
		jnz	pckcode

		;	終了コード書き込み
		;
		xor	al,al
		mov	es:[di],al
		inc	di
		ret

pckcode:
		;	圧縮コード書き込み
		;
		mov	ax,dx
		sub	ax,cs:startpck

		or	ax,ax
		jnz	pcknots

		;	コード0ならrun length
		;
		mov	ax,cs:pckzero
		or	ax,ax
		jnz	pckrlen

		;	run lengthのコード
		;
		inc	ax
		mov	cs:pckzero,ax

		mov	al,128
		mov	es:[di],al
		inc	di
		mov	al,1
		mov	es:[di],al
		inc	di
		ret

pckrlen:
		;	run length inc
		;
		mov	ax,cs:pckzero
		inc	ax
		mov	cs:pckzero,ax
		dec	di
		mov	es:[di],al
		inc	di

		cmp	ax,255
		jnz	pckrlov

		mov	cs:pckzero,0
pckrlov:
		ret

pcknots:
		mov	cs:pckzero,0

		cmp	ax,128
		jnc	pcklarge

		;	1byte圧縮コード
		;
		or	al,128
		mov	es:[di],al
		inc	di
		ret
pcklarge:
		;	2byte圧縮コード
		;
		mov	ax,dx
		mov	cs:startpck,ax
		or	ah,64
		mov	es:[di],ah
		inc	di
		mov	es:[di],al
		inc	di
		ret

samex0:
		;	新パケットカウント
		;
		mov	ax,cs:newpck
		inc	ax
		cmp	ax,63
		jnz	samex1

		;	新パケットが63に達した時
		;
		mov	ax,cs:wrt_seg
		mov	es,ax
		mov	al,63
		mov	es:[di],al
		inc	di
		xor	ax,ax
		mov	cs:pckzero,0

samex1:
		mov	cs:newpck,ax
		ret
	endp



;-------------------------------------------------
;	work area on code segment
;-------------------------------------------------


src_seg		dw	0
wrt_seg		dw	0
dat_seg		dw	0

startpck	dw	0
lastpck		dw	0
lastidx		dw	0
lastptr		dw	0

idxno		dw	0
datsize		dw	0

newpck		dw	0
ttpck		dw	0

pckzero		dw	0
pckzcnt		dw	0

_TEXT	ends


;-------------------------------------------------
;	end of line
;-------------------------------------------------

	END

