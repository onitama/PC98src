
	;
	;	mgl.s			1993/5 onitama
	;

	.MODEL small,C
	.186
	.CODE

vram_b	equ	0a800h
vram_r	equ	0b000h
vram_g	equ	0b800h
vram_e	equ	0e000h

rat	equ	0200h

	;----------------------------------------------

flgseg		dw	0
datseg		dw	0
h_ofs		dw	0
p_ofs		dw	0
r_buf		dw	0
p_vram		dw	0
size_x		dw	0
size_x2		dw	0
size_x3		dw	0
size_y		dw	0

buf_skip	db	02h
buf_lim		db	01fh
max_x		dw	640
max_y		dw	400
skip_x		dw	0

copytype	dw	0

flgbuf		db	80 dup(0)


flg_ofsdata	dw	0	;0 (no use)
		dw	2	;1
		dw	4	;2
		dw	8	;3
		dw	rat+0	;4
		dw	rat+2	;5
		dw	rat*2+0	;6
		dw	rat*2+2	;7
		dw	rat*2+4	;8
		dw	rat*4+0	;9
		dw	rat*4+2	;10
		dw	rat*4+4	;11
		dw	rat*8+0	;12
		dw	rat*8+2	;13
		dw	rat*8+4	;14
		dw	rat*16	;15

flg_ofsmake1	dw	0,2,4,8
		dw	0,2,0,2
		dw	4,0,2,4
		dw	0,2,4,0

flg_ofsmake2	dw	0,0,0,0
		dw	1,1,2,2
		dw	2,4,4,4
		dw	8,8,8,16


	;----------------------------------------------

	PUBLIC	mgl_open
mgl_open	proc	arg01:WORD , arg02:WORD , arg03:WORD

	mov	ax,arg01
	mov	cs:datseg,ax
	mov	ax,arg02
	mov	cs:flgseg,ax
	mov	ax,arg03
	mov	cs:p_vram,ax

	push	ds
	push	es
	push	di
	push	si
	push	bp

	call	open_head
	mov	ax,cs:h_ofs
	cmp	ax,-1
	jnz	mgl_go
	jmp	mgl_3

mgl_go:
	mov	cx,cs:size_y
mgl_0:
	push	cx
	call	open_flg

	;	pixel data extract
	;		es:si/vram  ds:di/pixel
	;		data cs:bx/flag buffer offset (flg.dl)
	;

	push	di
	push	si

	mov	ax,cs:flgseg
	mov	es,ax
	mov	di,cs:p_ofs
	mov	si,cs:r_buf
	push	si

	;	pixel data get
	;
	mov	cx,cs:size_x2
	call	get_flg

	mov	cx,cs:skip_x
	or	cx,cx
	jz	mgl_4
	;
	call	skip_flg
mgl_4:
	mov	cs:p_ofs,di

	;	pixel write to vram
	;

	pop	bx
	mov	ax,bx
	add	ah,cs:buf_skip
	and	ah,cs:buf_lim
	mov	cs:r_buf,ax

	mov	ax,cs:p_vram
	mov	si,ax
	add	ax,80
	mov	cs:p_vram,ax

	mov	bp,cs:size_x
mgl_2:
	call	put_pix
	dec	bp
	jnz	mgl_2

	pop	si
	pop	di
	pop	cx
	loop	mgl_0

mgl_3:
	pop	bp
	pop	si
	pop	di
	pop	es
	pop	ds

	mov	ax,cs:h_ofs
	ret
	endp


	;----------------------------------------------


	PUBLIC	mgl_pbuf
mgl_pbuf	proc	arg01:WORD , arg02:WORD

	mov	ax,arg01
	mov	cs:datseg,ax
	mov	ax,arg02
	mov	cs:flgseg,ax

	push	ds
	push	es
	push	di
	push	si
	push	bp

	call	open_head
	mov	ax,cs:h_ofs
	cmp	ax,-1
	jnz	pmgl_go
	jmp	pmgl_3

pmgl_go:
	mov	cx,cs:size_y
pmgl_0:
	push	cx
	call	open_flg

	;	pixel data extract
	;		es:si/vram  ds:di/pixel
	;		data cs:bx/flag buffer offset (flg.dl)
	;

	push	di
	push	si

	mov	ax,cs:flgseg
	mov	es,ax
	mov	di,cs:p_ofs
	mov	si,cs:r_buf
	push	si

	;	pixel data get
	;
	mov	cx,cs:size_x2
	call	get_flg

	mov	cx,cs:skip_x
	or	cx,cx
	jz	pmgl_4
	;
	call	skip_flg
pmgl_4:
	mov	cs:p_ofs,di

	;	pixel write to vram
	;

	pop	bx
	mov	ax,bx
	add	ah,cs:buf_skip
	and	ah,cs:buf_lim
	mov	cs:r_buf,ax

	pop	si
	pop	di
	pop	cx
	loop	pmgl_0

pmgl_3:
	pop	bp
	pop	si
	pop	di
	pop	es
	pop	ds

	mov	ax,cs:h_ofs
	ret
	endp


	;----------------------------------------------


	PUBLIC	mgl_set
mgl_set	proc	arg01:WORD , arg02:WORD , arg03:WORD , arg04:WORD

	mov	ax,arg01
	inc	ax
	mov	cs:max_x,ax
	mov	ax,arg02
	inc	ax
	mov	cs:max_y,ax
	mov	ax,arg03
	mov	cs:buf_skip,ah
	mov	ax,arg04
	dec	ax
	mov	cs:buf_lim,ah
	;
	mov	cx,16
	lea	si,flg_ofsmake1
	lea	di,flg_ofsmake2
	lea	bx,flg_ofsdata
mgls:
	xor	al,al
	mov	ah,cs:buf_skip
	mov	dx,cs:[di]
	imul	dx
	add	ax,cs:[si]
	mov	cs:[bx],ax
	inc	bx
	inc	bx
	inc	si
	inc	si
	inc	di
	inc	di
	loop	mgls
	;
	ret
	endp


	;----------------------------------------------



put_pix		proc near

	;	read from r_buffer
	;
	mov	ax,cs:flgseg
	mov	es,ax
	mov	ax,es:[bx]
	inc	bx
	inc	bx

	;	pixel data (ax/1)
	;
	shl	al,1
	rcl	dh,1	; E
	shl	al,1
	rcl	dl,1	; G
	shl	al,1
	rcl	ch,1	; R
	shl	al,1
	rcl	cl,1	; B
	;
	shl	al,1
	rcl	dh,1	; E
	shl	al,1
	rcl	dl,1	; G
	shl	al,1
	rcl	ch,1	; R
	shl	al,1
	rcl	cl,1	; B
	;
	shl	ah,1
	rcl	dh,1	; E
	shl	ah,1
	rcl	dl,1	; G
	shl	ah,1
	rcl	ch,1	; R
	shl	ah,1
	rcl	cl,1	; B
	;
	shl	ah,1
	rcl	dh,1	; E
	shl	ah,1
	rcl	dl,1	; G
	shl	ah,1
	rcl	ch,1	; R
	shl	ah,1
	rcl	cl,1	; B
	;

	mov	ax,es:[bx]
	inc	bx
	inc	bx

	;	pixel data (ax/2)
	;
	shl	al,1
	rcl	dh,1	; E
	shl	al,1
	rcl	dl,1	; G
	shl	al,1
	rcl	ch,1	; R
	shl	al,1
	rcl	cl,1	; B
	;
	shl	al,1
	rcl	dh,1	; E
	shl	al,1
	rcl	dl,1	; G
	shl	al,1
	rcl	ch,1	; R
	shl	al,1
	rcl	cl,1	; B
	;
	shl	ah,1
	rcl	dh,1	; E
	shl	ah,1
	rcl	dl,1	; G
	shl	ah,1
	rcl	ch,1	; R
	shl	ah,1
	rcl	cl,1	; B
	;
	shl	ah,1
	rcl	dh,1	; E
	shl	ah,1
	rcl	dl,1	; G
	shl	ah,1
	rcl	ch,1	; R
	shl	ah,1
	rcl	cl,1	; B

	;
	mov	ax,vram_b
	mov	es,ax
	mov	es:[si],cl
	mov	es:[si+8000h],ch
	mov	ah,HIGH vram_g
	mov	es,ax
	mov	es:[si],dl
	mov	ah,HIGH vram_e
	mov	es,ax
	mov	es:[si],dh
	inc	si
	ret
	endp


skip_flg	proc near

	;	flag data skip (4bit)
	;			times / cx
	;
sgf_0:
	mov	al,cs:[bx]
	or	dl,dl
	jnz	sgf_1
	;
	shr	al,4
	inc	dl
	jmp	sgf_2
sgf_1:
	and	al,15
	dec	dl
	inc	bx
sgf_2:
	;	write to r_buffer
	;
	or	al,al
	jnz	sgf_3
	;
	inc	di
	inc	di
sgf_3:
	loop	sgf_0
	ret
	endp



get_flg		proc near

	;	flag data read (4bit)
	;			times / cx
	;
gf_0:
	mov	al,cs:[bx]
	or	dl,dl
	jnz	gf_1
	;
	shr	al,4
	inc	dl
	jmp	gf_2
gf_1:
	and	al,15
	dec	dl
	inc	bx
gf_2:
	;	write to r_buffer
	;
	or	al,al
	jnz	pp_2
	;
	mov	ax,ds:[di]
	inc	di
	inc	di
	jmp	pp_3
pp_2:
	xor	ah,ah
	and	al,15
	shl	al,1
	lea	bp,flg_ofsdata
	add	bp,ax
	mov	ax,si
	sub	ax,cs:[bp]
	and	ah,cs:buf_lim
	mov	bp,ax
	mov	ax,es:[bp]
pp_3:
	mov	es:[si],ax
	inc	si
	inc	si

	loop	gf_0
	ret
	endp


open_head	proc near

	;	header read
	;
	mov	bx,0
	mov	cs:r_buf,bx
	mov	cs:skip_x,bx

	mov	ax,cs:datseg
	mov	ds,ax

	mov	ax,ds:[bx+4]
	cmp	ax,03230h
	jz	oh_1

	mov	ax,-1
	mov	cs:h_ofs,ax
	mov	cs:datseg,ax
	ret
oh_1:
	inc	bx
	mov	al,ds:[bx]
	or	al,al
	jnz	oh_1

	mov	cs:h_ofs,bx

	mov	ax,ds:[bx+12]		; flag_a
	add	ax,cs:h_ofs
	mov	si,ax
	mov	ax,ds:[bx+16]		; flag_b
	add	ax,cs:h_ofs
	mov	di,ax
	mov	ax,ds:[bx+24]		; pixel data
	add	ax,cs:h_ofs
	mov	cs:p_ofs,ax

	mov	ax,ds:[bx+8]		; EX
	inc	ax
	sub	ax,ds:[bx+4]		; SX
	mov	cx,ax
	mov	dx,cs:max_x
	cmp	ax,dx
	jc	ok_maxx
	;
	sub	ax,dx
	shr	ax,2
	mov	cs:skip_x,ax
	mov	ax,cs:max_x
ok_maxx:
	shr	ax,2
	mov	cs:size_x2,ax
	shr	ax,1
	mov	cs:size_x,ax

	mov	ax,cx
	shr	ax,6
	mov	cs:size_x3,ax

	mov	ax,ds:[bx+10]		; EY
	inc	ax
	sub	ax,ds:[bx+6]		; SY
	mov	dx,cs:max_y
	cmp	ax,dx
	jc	ok_maxy
	mov	ax,dx
ok_maxy:
	mov	cs:size_y,ax

	mov	cx,40
	mov	bx,WORD PTR flgbuf
	xor	ax,ax
oh_2:
	mov	cs:[bx],ax
	inc	bx
	inc	bx
	loop	oh_2

	ret
	endp


open_flg	proc near

	;	flag data extract
	;		ds:si/flag_a  ds:di/flag_b  cs:bx/flag buffer offset
	;
	mov	bx,WORD PTR flgbuf
	mov	cx,cs:size_x3
of_0:
	push	cx
	mov	cx,8
	mov	dl,ds:[si]
	inc	si
of_1:
	shl	dl,1
	jnc	of_2
	;
	mov	al,ds:[di]
	inc	di
	xor	al,cs:[bx]
	mov	cs:[bx],al
of_2:
	inc	bx
	loop	of_1
	pop	cx
	loop	of_0

	mov	bx,WORD PTR flgbuf
	mov	dx,0
	ret

	endp

	;--------------------------------------------------------------
	;	some useful routines for picture screen access
	;--------------------------------------------------------------


	;--------------------------------------------
	;	graphic screen copy
	;--------------------------------------------

	PUBLIC	g_copy
g_copy	proc	xx:WORD,yy:WORD,sx:WORD,sy:WORD,tx:WORD,ty:WORD

	push	es
	push	si
	push	di

	mov	ax,tx
	mov	dx,ty
	call	vcalq
	mov	di,si
	;
	mov	ax,xx
	mov	dx,yy
	call	vcalq
	;
	mov	ax,vram_b
	mov	es,ax
	mov	ax,sx
	shr	ax,3
	mov	dx,ax
	mov	cx,sy
	xor	ax,ax
gcc1:
	push	cx
	push	di
	push	si
	mov	cx,dx
gcc2:
	mov	ah,HIGH vram_b
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram_r
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram_g
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram_e
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	inc	si
	inc	di
	loop	gcc2
	;
	pop	si
	pop	di
	add	si,80
	add	di,80
	pop	cx
	loop	gcc1

	pop	di
	pop	si
	pop	es
	ret
	endp


	;--------------------------------------------
	;	graphic screen copy
	;--------------------------------------------

	PUBLIC	g_copy2
g_copy2	proc	xx:WORD,yy:WORD,sx:WORD,sy:WORD,tx:WORD,ty:WORD,ptyp:WORD

	push	es
	push	si
	push	di

	mov	ax,ptyp
	mov	cs:copytype,ax

	mov	ax,tx
	mov	dx,ty
	call	vcalq
	mov	di,si
	;
	mov	ax,xx
	mov	dx,yy
	call	vcalq
	mov	bx,di
	;
	mov	ax,sx
	shr	ax,4			; word transfer
	mov	si,ax

	mov	ax,vram_b
	mov	es,ax

	push	bx
	push	di
	mov	cx,sy
	call	cpsub
	pop	di
	pop	bx

	mov	ax,vram_r
	mov	es,ax

	push	bx
	push	di
	mov	cx,sy
	call	cpsub
	pop	di
	pop	bx

	mov	ax,vram_g
	mov	es,ax

	push	bx
	push	di
	mov	cx,sy
	call	cpsub
	pop	di
	pop	bx

	mov	ax,vram_e
	mov	es,ax
	mov	cx,sy
	call	cpsub

	pop	di
	pop	si
	pop	es
	ret
	endp


	;	graphics copy sub
	;
cpsub	proc	near

	mov	ax,cs:copytype
	or	al,al
	jz	gcc5

gcc3:
	push	cx
	push	di
	push	bx
	mov	cx,si
	xor	al,al
gcc4:
	inc	al
	out	0a6h,al
	mov	dx,es:[bx]
	dec	al
	out	0a6h,al
	mov	es:[di],dx
	inc	bx
	inc	bx
	inc	di
	inc	di
	loop	gcc4
	;
	pop	bx
	pop	di
	add	bx,80
	add	di,80
	pop	cx
	loop	gcc3
	ret

gcc5:
	push	cx
	push	di
	push	bx
	mov	cx,si
	xor	al,al
gcc6:
	out	0a6h,al
	mov	dx,es:[bx]
	inc	al
	out	0a6h,al
	dec	al
	mov	es:[di],dx
	inc	bx
	inc	bx
	inc	di
	inc	di
	loop	gcc6
	;
	pop	bx
	pop	di
	add	bx,80
	add	di,80
	pop	cx
	loop	gcc5
	ret
	endp




	;--------------------------------------------
	;	vram adr. calq
	;		ax( x/0-639 ),dx( y/0-399 ) -> si (x&7=cx)
	;--------------------------------------------

vcalq	proc near
	mov	cx,ax
	and	cx,7
	shr	ax,3
	mov	si,ax
	shl	dx,4
	add	si,dx
	shl	dx,2
	add	si,dx
	ret
	endp


	end

