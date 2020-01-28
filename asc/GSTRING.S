
	;
	;	gstring.s (string manager)
	;				1993/6 onitama
	;

	.MODEL small,C
	.186
	.CODE

	;----------------------------------------------
	;	character equ
	;----------------------------------------------

c_tab		equ	09h
c_cr		equ	0dh
c_lf		equ	0ah
c_eof		equ	01ah
c_spc		equ	020h

c_strp1		equ	022h		; "
c_strp2		equ	027h		; '

	;----------------------------------------------
	;	work area
	;----------------------------------------------

gs_seg		dw	0	;	file buffer segment
gs_ofs		dw	0	;	line buffer search offset
gs_stat		dw	0	;	line buffer search status
gs_line		dw	0	;	current analysis line number
gs_hofs		dw	0	;	paragraph search offset
gs_sep1		db	0	;	comment chr
gs_sep2		db	0	;	separate chr

gs_pbuf		db	256 dup (0)	; paragraph analysis buffer


	;----------------------------------------------
	;	for binary file read/write
	;----------------------------------------------

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


	;-------------------------------------------------------------------
	;	initalize buffer get system
	;		gs_init( int data_segment, char spchr, char spchr2 )
	;-------------------------------------------------------------------

	public	gs_init
gs_init		proc	arg1:word,arg2:byte,arg3:byte

	mov	ax,arg1
	mov	cs:gs_seg,ax
	xor	ax,ax
	mov	cs:gs_ofs,ax
	mov	cs:gs_stat,ax
	mov	cs:gs_line,ax
	;
	mov	al,arg2
	mov	cs:gs_sep1,al
	mov	al,arg3
	mov	cs:gs_sep2,al
	;
	xor	ax,ax
	mov	cs:gs_hofs,ax
	;
	ret
	endp


	;----------------------------------------------
	;	check gstring information
	;			gs_info( int info# )
	;			result/int info
	;----------------------------------------------

	public	gs_info
gs_info		proc	arg1:word

	push	si
	lea	si,gs_seg
	mov	bx,arg1
	shl	bx,1
	add	si,bx
	mov	ax,cs:[si]
	pop	si
	ret
	endp


	;----------------------------------------------
	;    get 1line from buffer
	;	gs_getl( char *l_str )
	;			 3 : illegal data error
	;			 2 : over 256 column error
	;			 1 : end of data
	;			 0 : success
	;----------------------------------------------

	public	gs_getl
gs_getl		proc	arg1:ptr word

	push	es
	push	di
	push	si
	;
	mov	di,arg1
	call	getline
	;
	pop	si
	pop	di
	pop	es
	ret
	endp

getline		proc near

	mov	ax,cs:gs_stat
	or	ax,ax
	jz	gg_0
	jmp	gg_ov
	;
gg_0:
	inc	cs:gs_line
	mov	ax,cs:gs_seg
	mov	es,ax
	mov	si,cs:gs_ofs
	mov	dl,cs:gs_sep1
	xor	dh,dh
	mov	bx,-1
	mov	cx,0
	;
gg_1:
	mov	al,es:[si]
	inc	si
	cmp	al,20h
	jnc	gg_2
	cmp	al,c_tab
	jz	gg_2
	cmp	al,c_lf
	jz	gg_1
	cmp	al,c_eof
	jz	gg_4
	cmp	al,c_cr
	jz	gg_3
	;
	mov	ax,3
	jmp	gg_ov
gg_4:
	mov	ax,1
	jmp	gg_ov
gg_6:					; toggle "--" switch
	or	dh,dh
	jz	gg_6x
	cmp	al,dh
	jnz	gg_5
	xor	dh,dh
	jmp	gg_5
gg_6x:
	mov	dh,al
	jmp	gg_5


gg_2:
	cmp	al,c_strp1
	jz	gg_6
	cmp	al,c_strp2
	jz	gg_6
	;
	or	dh,dh			; skip "--"
	jnz	gg_5
	;
	cmp	al,dl
	jnz	gg_5
	mov	bx,di
gg_5:
	mov	ds:[di],al
	inc	di
	inc	cl
	or	cl,cl
	jnz	gg_1
	;
	mov	ax,2
	jmp	gg_ov
gg_3:
	mov	cs:gs_ofs,si
	xor	ax,ax
	mov	ds:[di],al
	cmp	bx,-1
	jz	gg_ov
	;
	mov	ds:[bx],al		; separate kill
gg_ov:
	mov	cs:gs_stat,ax
	ret
	endp


	;-------------------------------------------------
	;    get 1paragraph from buffer ( to l_str )
	;	gs_getp( char *l_str, char *l_str2 )
	;			 3 : illegal data error
	;			 2 : over 256 column error
	;			 1 : end of data
	;			 0 : success
	;-------------------------------------------------

	public	gs_getp
gs_getp		proc	arg1:ptr word,arg2:ptr word

	push	es
	push	di
	push	si
	;
gp_0:
	mov	si,cs:gs_hofs
	or	si,si
	jnz	gp_1
	;
	mov	di,arg2
	call	getline
	mov	si,arg2
	or	ax,ax
	jz	gp_1
	jmp	gp_ov
gp_1:
	;	get pbuf
	;
	lea	di,gs_pbuf
	mov	dl,cs:gs_sep2
	xor	dh,dh
gp_2:
	mov	al,ds:[si]
	inc	si
	or	al,al
	jz	gp_4
	;
	cmp	al,c_strp1
	jz	gp_6
	cmp	al,c_strp2
	jz	gp_6
	;
	or	dh,dh
	jnz	gp_5
gp_3:
	cmp	al,dl
	jz	gp_7
	;
gp_5:
	mov	cs:[di],al
	inc	di
	jmp	gp_2
gp_6:				; toggle "---"
	or	dh,dh
	jz	gp_6x
	cmp	dh,al
	jnz	gp_5
	xor	dh,dh
	jmp	gp_5
gp_6x:
	mov	dh,al
	jmp	gp_5
gp_4:
	mov	si,0		; hofs reset
gp_7:
	xor	ax,ax
	mov	cs:[di],al
	mov	cs:gs_hofs,si

	;	skip head trash
	;
	lea	si,gs_pbuf
	mov	di,arg1
gp_8:
	mov	al,cs:[si]
	or	al,al
	jz	gp_12
	cmp	al,c_tab
	jz	gp_9
	cmp	al,c_spc
	jz	gp_9
	jmp	gp_10
gp_9:
	inc	si
	jmp	gp_8
gp_12:
	jmp	gp_0
gp_10:
	;	write to string
	;
	mov	al,cs:[si]
	or	al,al
	jz	gp_11
	mov	ds:[di],al
	inc	di
	inc	si
	jmp	gp_10
gp_11:
	;	kill tail trash
	;
	dec	di
	mov	al,ds:[di]
	cmp	al,c_tab
	jz	gp_11
	cmp	al,c_spc
	jz	gp_11

	;	all done
	;
	xor	ax,ax
	inc	di
	mov	ds:[di],al

	mov	dx,cs:gs_hofs
	or	dx,dx
	jnz	gp_ov

	mov	ax,-1				; new line prepare flag
gp_ov:
	pop	si
	pop	di
	pop	es
	ret
	endp


	;----------------------------------------------------------
	;    get 1word from buffer ( to l_str )
	;	gs_getw( char *l_str, char *l_str2, int *wtype, char *next )
	;		result	 l_str2 next ptr
	;			-----------------------------------
	;		wtype	 0   : end of data
	;			 1   : label
	;			 2   : others
	;			 3   : num
	;			 4   : str
	;----------------------------------------------------------

	public	gs_getw
gs_getw		proc	arg1:ptr word,arg2:ptr word,arg3:ptr word,arg4:ptr word

	push	di
	push	si
	;
	xor	ah,ah
	mov	si,arg2
	mov	di,arg1
	jmp	gw_0
gw_00:
	inc	si
gw_0:
	;	head type check
	;
	mov	al,ds:[si]
	cmp	al,c_tab
	jz	gw_00
	cmp	al,c_spc
	jz	gw_00
	;
	cmp	al,c_strp1
	jz	gw_5
	cmp	al,c_strp2
	jz	gw_5
	
	;
	call	chkw
	mov	bx,dx
	or	dl,dl
	jz	gw_1
	cmp	dl,2
	jz	gw_3
gw_2:
	;	label or num
	;
	mov	al,ds:[si]
	call	chkw
	cmp	dl,3
	jz	gw_2x
	cmp	dl,1
	jnz	gw_4
gw_2x:
	inc	si
	mov	ds:[di],al
	inc	di
	jmp	gw_2
gw_4:
	mov	dx,bx
	jmp	gw_1

gw_5:
	;	"---" or '---'
	;
	mov	ds:[di],al
	inc	si
	inc	di
	mov	dx,4
	mov	bl,al
	cmp	al,c_strp1
	jz	gw_6
	mov	dl,3
gw_6:
	mov	al,ds:[si]
	or	al,al
	jz	gw_1
	inc	si
	mov	ds:[di],al
	inc	di
	cmp	al,bl
	jz	gw_1
	jmp	gw_6

gw_3:
	;	others
	;
	mov	ds:[di],al
	inc	si
	inc	di

gw_1:
	;	write l_str ( wtype=dx )
	;
	mov	bx,arg3
	mov	ds:[bx],dx
	xor	ax,ax
	mov	ds:[di],al
	;
	jmp	gw_7
gw_8:
	inc	si
gw_7:
	;	next word check
	;
	mov	al,ds:[si]
	cmp	al,c_tab
	jz	gw_8
	cmp	al,c_spc
	jz	gw_8
	;
	mov	bx,arg4
	mov	ds:[bx],al
	mov	ax,si
	;
	pop	si
	pop	di
	ret
	endp


	;-----------------------------------------------
	;	check word ( dl -> ax )
	;		result	 0   : end of data (err)
	;			 1   : label
	;			 2   : others
	;			 3   : num
	;-----------------------------------------------

chkw	proc near

	xor	dx,dx
	or	al,al
	jz	cw1
	cmp	al,c_strp2
	jz	cw_num
	cmp	al,24h
	jz	cw_num
	cmp	al,30h
	jc	cw_kig
	cmp	al,3ah
	jc	cw_num
	cmp	al,40h
	jc	cw_kig
	cmp	al,5bh
	jc	cw_lbl
	cmp	al,5fh
	jc	cw_kig
	cmp	al,7bh
	jc	cw_lbl
cw_kig:
	;			others
	mov	dl,2
	jmp	cw1
cw_lbl:
	;			label
	mov	dl,1
	jmp	cw1
cw_num:
	;			num
	mov	dl,3
cw1:
	;
	ret
	endp


	;----------------------------------------------------------
	;    word(num) -> int conversion
	;	gs_wtoi( char *l_str, int *value )
	;			result/ 0 : success
	;				1 : illegal num syntax
	;				2 : illegal num syntax (hex)
	;----------------------------------------------------------

	public	gs_wtoi
gs_wtoi		proc	arg1:ptr word,arg2:ptr word

	push	si
	push	di
	;
	mov	si,arg1
	mov	di,arg2
	mov	dx,0
	mov	ax,ds:[si]
	cmp	ax,05830h		; '0X'
	jz	wcv2
	cmp	ax,07830h		; '0x'
	jz	wcv2
	cmp	al,24h			; '$'
	jz	wcv3
	cmp	al,c_strp2
	jz	wcv7

	;	dec convert
	;
	xor	ah,ah
wcv1:
	mov	al,ds:[si]
	inc	si
	or	al,al
	jz	wcv_ov
	sub	al,30h
	cmp	al,10
	jnc	wcv_er
	;
	shl	dx,1
	mov	bx,dx
	shl	dx,2
	add	dx,bx			; x10
	add	dx,ax
	jmp	wcv1
wcv_er:
	mov	ax,1
	jmp	wcv_no

wcv2:
	inc	si
wcv3:
	;	hex convert
	;
	xor	ah,ah
	inc	si
wcv4:
	mov	al,ds:[si]
	inc	si
	or	al,al
	jz	wcv_ov
	cmp	al,67h			; 'f'
	jnc	wcv_er2
	cmp	al,61h			; 'a'
	jnc	wcv8
	cmp	al,47h			; 'F'
	jnc	wcv_er2
	cmp	al,41h			; 'A'
	jc	wcv5
	sub	al,41h-10
	jmp	wcv6
wcv8:
	sub	al,61h-10
	jmp	wcv6
wcv5:
	sub	al,30h
	cmp	al,10
	jnc	wcv_er2
wcv6:
	shl	dx,4			; x16
	add	dx,ax
	jmp	wcv4

wcv7:
	;	'--' convert
	;
	inc	si
	xor	dh,dh
	mov	dl,ds:[si]
	inc	si
	mov	al,ds:[si]
	inc	si
	cmp	al,c_strp2
	jz	wcv_ov
	or	al,al
	jz	wcv_ov
	mov	dh,dl
	mov	dl,al
	jmp	wcv_ov

wcv_er2:
	mov	ax,2
	jmp	wcv_no
	;
wcv_ov:
	mov	ds:[di],dx
	xor	ax,ax
wcv_no:
	pop	di
	pop	si
	ret
	endp


	;----------------------------------------------------------
	;    string -> string buffer send
	;	gs_stbuf( char *l_str, int send_seg, int send_ofs )
	;			result/ new send offset
	;----------------------------------------------------------

	public	gs_stbuf
gs_stbuf	proc	arg1:ptr word, arg2:word, arg3:word

	push	si
	push	di
	;
	mov	bx,arg1
	mov	ax,arg2
	mov	es,ax
	mov	di,arg3
	;
	mov	al,ds:[bx]
	cmp	al,022h
	jnz	wsd1
	inc	bx				; æ“ª‚Ì"($22)‚Í–³Ž‹‚³‚ê‚é
wsd1:
	mov	al,ds:[bx]
	inc	bx
	or	al,al
	jz	wsd2
	cmp	al,022h
	jz	wsd2
	;
	cmp	al,05ch				; '\'‚©?
	jnz	wsd3
	;
	mov	al,ds:[bx]
	inc	bx
	or	al,al
	jz	wsd2
	cmp	al,04eh
	jz	wsd4
	cmp	al,06eh
	jz	wsd4
	cmp	al,054h
	jz	wsd5
	cmp	al,074h
	jz	wsd5
	;
	jmp	wsd3
wsd4:
	mov	al,0dh				; '\n'‚Ícr/lf‚É
	mov	es:[di],al
	inc	di
	mov	al,0ah
	jmp	wsd3
wsd5:
	mov	al,9				; '\t'‚Ítab‚É
wsd3:
	mov	es:[di],al
	inc	di
	jmp	wsd1
wsd2:
	mov	al,0
	mov	es:[di],al
	inc	di
	mov	ax,di
	;
	pop	di
	pop	si
	ret
	endp


	;----------------------------------------------------------
	;    string buffer -> code buffer send
	;	gs_cdbuf( int str_seg, int str_size, int send_seg, int send_ofs )
	;			result/ total send offset
	;----------------------------------------------------------

	public	gs_cdbuf
gs_cdbuf	proc	arg1:ptr word, arg2:word, arg3:word, arg4:word

	push	ds
	push	di
	push	si
	;
	mov	ax,arg1
	mov	ds,ax
	mov	ax,arg3
	mov	es,ax
	;
	mov	bx,0
	mov	di,arg4
	mov	cx,arg2
	or	cx,cx
	jz	codsd2
codsd1:
	mov	al,ds:[bx]
	mov	es:[di],al
	inc	bx
	inc	di
	loop	codsd1
codsd2:
	mov	ax,di
	;
	pop	si
	pop	di
	pop	ds
	ret
	endp


	;	end of source
	;
	end

