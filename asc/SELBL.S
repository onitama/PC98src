
	;
	;	selbl.s (high speed label manager)
	;				1993/6 onitama
	;

	.MODEL small,C
	.186
	.CODE


lblmax	equ	4096


	;----------------------------------------------
	;	work area
	;----------------------------------------------

sl_seg	dw	0
sl_idx	dw	0

	;----------------------------------------------
	;	initalize buffer
	;		sl_init( int data_segment )
	;----------------------------------------------

	public	sl_init
sl_init		proc	arg1:word

	push	di
	push	es
	;
	mov	ax,arg1
	mov	cs:sl_seg,ax
	mov	es,ax
	mov	di,0
	mov	dx,16
	mov	cx,lblmax
	xor	ax,ax
sl_1:
	mov	es:[di],ax
	add	di,dx
	loop	sl_1
	;
	pop	es
	pop	di
	ret
	endp


	;----------------------------------------------
	;	regist label
	;		sl_make( *label_name, int code, int type )
	;			    -1 : no more label
	;			0x80?? : error ( ??=type )
	;			0-4095 : regist no.
	;----------------------------------------------

	public	sl_make
sl_make		proc	lname:PTR WORD,code:WORD,ltyp:word

	push	es
	push	si
	push	di
	;
	mov	ax,cs:sl_seg
	mov	es,ax
	;
	mov	si,lname
	call	sl_cmp
	;
	cmp	ax,-2
	jz	sl_noreg
	cmp	ax,-1
	jz	sl_reg
	;
	mov	al,es:[di+15]
	mov	ah,080h
	jmp	slm_ov
	;
sl_noreg:
	mov	ax,-1
	jmp	slm_ov
sl_reg:
	mov	ax,di
	shr	ax,4
	push	ax
	;
	mov	ax,code
	mov	es:[di+13],ax
	mov	ax,ltyp
	mov	es:[di+15],al
	xor	al,al
	mov	es:[di+12],al
	mov	si,lname
	mov	cx,6
sl_l1:
	mov	ax,ds:[si]
	mov	es:[di],ax
	inc	si
	inc	si
	inc	di
	inc	di
	loop	sl_l1
	;
	pop	ax
slm_ov:
	pop	di
	pop	si
	pop	es
	ret
	endp


	;----------------------------------------------
	;	search label
	;		sl_find( *label_name, int &code, int &typ );
	;			-1,-2  : not found
	;			0-4095 : regist no.
	;----------------------------------------------

	public	sl_find
sl_find		proc	lname:PTR WORD,code:PTR WORD,ltyp:PTR WORD

	push	es
	push	si
	push	di
	;
	mov	ax,cs:sl_seg
	mov	es,ax
	mov	si,lname
	call	sl_cmp
	;
	cmp	ax,08000h
	jnc	sl_nx
	;
	push	ax
	mov	ax,es:[di+13]
	mov	si,code
	mov	ds:[si],ax
	mov	al,es:[di+15]
	xor	ah,ah
	mov	si,ltyp
	mov	ds:[si],ax
	and	ax,15
	mov	es:[di+15],al
	pop	ax
sl_nx:
	pop	di
	pop	si
	pop	es
	ret
	endp


sl_cmp	proc near

	;	string compare (ds:si)->(es:di)
	;			result/ ax-code ( -1:error )
	;

	;	calc idx code
	;

	push	si
	mov	cx,11
	xor	ax,ax
cp_1:
	mov	al,ds:[si]
	inc	si
	or	al,al
	jz	cp_2
	mov	ah,al
	loop	cp_1
cp_2:
	mov	cx,6
	xor	bx,bx
cp_3:
	mov	ds:[si],bx
	inc	si
	inc	si
	loop	cp_3
	;
	pop	si
	;
	mov	dh,ds:[si]
	mov	dl,ds:[si+1]
	add	dl,ah
	mov	cs:sl_idx,dx
	shr	dx,1
	shl	dx,4
	mov	di,dx

	;	compare prepare ( self program rewrite )

	push	di
	push	si
	lea	di,sec01
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	inc	si
	inc	si
	lea	di,sec02
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	inc	si
	inc	si
	lea	di,sec03
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	inc	si
	inc	si
	lea	di,sec04
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	inc	si
	inc	si
	lea	di,sec05
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	inc	si
	inc	si
	lea	di,sec06
	mov	ax,ds:[si]
	mov	cs:[di+1],ax
	pop	si
	pop	di

	jmp	safer1				; for 486 cache
safer1:

	;	compare string
	;		ds:[si] = ? es:[di]

secmain:
	;
	mov	ax,es:[di]
	or	ax,ax
	jz	sec_fl
	;
sec01:	cmp	ax,0
	jnz	sec_ov
	mov	ax,es:[di+2]
sec02:	cmp	ax,0
	jnz	sec_ov
	mov	ax,es:[di+4]
sec03:	cmp	ax,0
	jnz	sec_ov
	mov	ax,es:[di+6]
sec04:	cmp	ax,0
	jnz	sec_ov
	mov	ax,es:[di+8]
sec05:	cmp	ax,0
	jnz	sec_ov
	mov	ax,es:[di+10]
sec06:	cmp	ax,0
	jnz	sec_ov
	;
	mov	ax,di
	shr	ax,4
	ret
sec_ov:
	add	di,16
	cmp	di,dx
	jnz	secmain
	;
	mov	ax,-2
	ret
sec_fl:
	mov	ax,-1
	ret
	endp


	;----------------------------------------------
	;	get label name
	;		sl_getnam( str &label_name, int lcode )
	;----------------------------------------------

	public	sl_getnam
sl_getnam	proc	lname:PTR WORD,lcode:WORD

	push	si
	push	di
	mov	ax,cs:sl_seg
	add	ax,lcode
	mov	es,ax
	;
	mov	cx,7
	mov	bx,lname
	mov	si,0
gtnm1:
	mov	ax,es:[si]
	mov	ds:[bx],ax
	inc	si
	inc	si
	inc	bx
	inc	bx
	loop	gtnm1
	;
	pop	di
	pop	si
	ret
	endp


	;--------------------------------------------------
	;	2-pass label replace ( for SOUP )
	;		sl_lblset( int objseg, int lblseg )
	;--------------------------------------------------

	public	sl_lblset
sl_lblset	proc	arg1:word, arg2:word

	push	ds
	push	si
	push	di
	;
	mov	bx,0
	mov	ax,arg1
	mov	ds,ax
	mov	ax,arg2
	mov	es,ax
	mov	dl,08fh					; end code
	mov	dh,0f0h
	mov	cl,0f1h
	mov	ch,080h
lbst1:
	mov	al,ds:[bx]
	inc	bx
	cmp	al,ch
	jc	lbst3
	cmp	al,dl
	jz	lbst2
	cmp	al,dh
	jc	lbst1
	cmp	al,cl
	jz	lbst3
	cmp	al,0f4h
	jz	lbst4
	;
	inc	bx
lbst3:
	inc	bx
	jmp	lbst1
lbst4:
	;						store PC pointer
	mov	si,ds:[bx]
	shl	si,1
	mov	ax,es:[si]
	mov	ds:[bx],ax
	dec	bx
	mov	al,0f5h
	mov	ds:[bx],al
	inc	bx
	inc	bx
	inc	bx
	jmp	lbst1

lbst2:
	;
	pop	di
	pop	si
	pop	ds
	ret
	endp


	end
