;---------------------------------------------------------------
;	mouse operating system from C ( small model )
;	started 1994/1 onitama cooperated with Ana.
;
;	void	ms_init( int vseg );
;	void	ms_area( int winsx, int winsy, int winex, int winey );
;	void	ms_clip( int clpsx, int clpsy, int clpex, int clpey );
;	void	ms_reset( int xx, int yy );
;	void	ms_locate( int xx, int yy );
;	void	ms_ctrl( int flag );
;	void	ms_chr( int code );
;	void	ms_proc();
;	void	ms_wipe();
;	void	ms_kill();
;	void	ms_done();
;
;	void	ms_cinit( int cb_seg, int cb_kazz );
;	void	ms_cset( int cbno, int cbflg, int cbxx, int cbyy, int cblx, int cbly );
;	void	ms_cget( int cbno );
;	int	ms_cbox();
;
;---------------------------------------------------------------

	.MODEL small,C
	.186
	.CODE


noent		equ	0f000h		; no entry flag code
csr_h		equ	24		; cursor character high
csr_sx		equ	3		; size X (dot/8)
csr_sy		equ	24		; size Y (dot)
vbsize		equ	384
vbuff0		equ	0
vbuff1		equ	vbsize
mchrsize	equ	480
cbsize		equ	10

	;-------------------------------------------------
	;	work area on code segment
	;-------------------------------------------------

orghook		dd	0		; INT6 original vector
intds		dw	0		; INT6 use DS
intflag		dw	0		; INT6 use flag ( 0=off )
int6cou		dw	0		; INT6 main counter
keyflag		dw	0		; use key flag ( 0=off )

vb_seg		dw	0		; mchr tmp buffer
vb_seg2		dw	0		; mchr main buffer
vb_seg3		dw	0		; check box system work
curax		dw	noent		; current cursor ax
curcx		dw	0		; current cursor cx
dbgax		dw	0		; debug status

cbkazz		dw	25		; check box buff max ( default 32 )

vt_sx		dw	0		; for character transfer area check
vt_sy		dw	0
vt_cx		dw	0
vt_cy		dw	0

clp_wx		dw	0		; clipping work x
clp_wy		dw	0		; clipping work y
clp_sx		dw	0		; clipping area sx (dot/8)
clp_sy		dw	0		; clipping area sy
clp_ex		dw	80		; clipping area ex (dot/8)
clp_ey		dw	400		; clipping area ey

vbtmp1		db	384 dup (?)	; chcracter transfer temp1
vbtmp2		db	384 dup (?)	; chcracter transfer temp2
					;	B,R,G,E x 4 x csr_h


	;-------------------------------------------------
	;	extra segment uses
	;-------------------------------------------------

	; 0000-0EFF	character tmp buffer (480x8)
	; 0F00-0FFF	check box system work (8x32)
	; 1000-????	character data area (4x24x4plane)

	;----------------------------------------------
	;	mouse system routines
	;----------------------------------------------


	;
	;	initalize system
	;

	public	ms_init
ms_init	PROC	VSG:word

		push	ds
		push	si
		push	di

		xor	ax,ax
		mov	MWIN_SX,ax
		mov	MWIN_SY,ax
		mov	ms_xx,ax
		mov	ms_yy,ax
		mov	cs:clp_sx,ax
		mov	cs:clp_sy,ax
		mov	ax,639
		mov	MWIN_EX,ax
		inc	ax
		shr	ax,3
		mov	cs:clp_ex,ax
		mov	ax,399
		mov	MWIN_EY,ax
		inc	ax
		mov	cs:clp_ey,ax
		;
		mov	ax,VSG
		mov	cs:vb_seg,ax
		add	ax,0f0h
		mov	cs:vb_seg3,ax
		add	ax,10h
		mov	cs:vb_seg2,ax
		mov	ax,32
		mov	cs:cbkazz,ax
		;
		mov	ax,ds
		mov	cs:intds,ax
		;
		call	sysclr
		;
		mov	ax,3515h
		int	21h			; DOS Services  ah=function 35h
		mov	word ptr orghook,bx	; 	int offset
		mov	word ptr orghook+2,es	; 	int segment
		;
		mov	ax,cs
		mov	ds,ax
		;
		cli
		mov	dx,offset int15h_entry
		mov	ax,2515h
		int	21h			; DOS Services  ah=function 25h
		call	intcnt
		sti
		;
		mov	ax,cs:intds
		mov	ds,ax
		mov	ax,1
		mov	ms_hx,ax
		mov	ms_hy,ax
		mov	ax,-1
		call	mchmk
		;
		call	ms_proc
		;
		mov	ax,1
		mov	cs:intflag,ax
		mov	cs:keyflag,ax
		xor	ax,ax
		;
		pop	di
		pop	si
		pop	ds
		;
		ret
	ENDP


		;
		;	INT6 enable
		;
intcnt		proc	near
		mov	dx,0BFDBh
		mov	al,1
		out	dx,al			; port 0BFDBh
		jmp	short $+2		; delay for I/O
		mov	dx,7FDDh
		mov	al,0
		out	dx,al			; port 7FDDh
		mov	dx,7FDFh
		mov	al,93h
		out	dx,al			; for VM series
		jmp	short $+2		; delay for I/O
		mov	dx,7FDFh
		mov	al,0Fh
		out	dx,al			; port 7FDFh
		jmp	short $+2		; delay for I/O
		mov	dx,7FDFh
		mov	al,8
		out	dx,al			; port 7FDFh
		push	ax
		in	al,0Ah
		and	al,0DFh
		out	0Ah,al
		pop	ax
		retn
		endp


		;
		;	INT6 ( mouse timer ) ENTRY
		;
int15h_entry	PROC	FAR

		push	ax

		;	INT RESET
		;
		mov	al,20h
		out	8,al
		mov	al,0Bh
		out	8,al
		jmp	short $+2		; delay for I/O
		in	al,8
		or	al,al
		jnz	loc_ex
		mov	al,20h
		out	0,al			; port 0
loc_ex:

		cmp	cs:intflag,0
		jz	no15_entry
		;
		dec	cs:intflag		; Ä“ü–hŽ~
		inc	cs:int6cou		; counter inc
		;
		push	ds
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		;
		mov	ax,cs:intds
		mov	ds,ax
		call	getms
		;
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		;
		cli
		inc	cs:intflag
no15_entry:
		pop	ax
		iret
		ENDP



	public	ms_clip
ms_clip	PROC	WSX:word, WSY:word, WEX:word, WEY:word

		push	si
		push	di
		;
		call	ms_wipe
		;
		mov	ax,WSX
		shr	ax,3
		mov	cs:clp_sx,ax
		mov	ax,WSY
		mov	cs:clp_sy,ax
		;
		mov	ax,WEX
		inc	ax
		shr	ax,3
		mov	cs:clp_ex,ax
		;
		mov	ax,WEY
		inc	ax
		mov	cs:clp_ey,ax
		;
		call	ms_proc
		;
		pop	di
		pop	si
		ret
	ENDP



	public	ms_area
ms_area	PROC	WSX:word, WSY:word, WEX:word, WEY:word

		push	ds
		push	si
		push	di
		;
		call	ms_wipe
		;
		mov	ax,WSX
		mov	MWIN_SX,ax
		mov	ms_xx,ax
		mov	ax,WSY
		mov	MWIN_SY,ax
		mov	ms_yy,ax
		;
		mov	ax,WEX
		mov	MWIN_EX,ax
		;
		mov	ax,WEY
		mov	MWIN_EY,ax
		;
		call	sysclr			; ms system clear
		call	ms_proc
		;
		pop	di
		pop	si
		pop	ds
		;
		ret
	ENDP


sysclr	PROC NEAR

		mov	ax,cs:intds
		mov	ds,ax
		xor	ax,ax
		mov	cs:int6cou,ax
		mov	ms_jkey,ax
		mov	ms_key,ax
		mov	ms_trg,ax
		mov	ms_lmode,ax
		mov	ms_ktime,ax
		mov	ms_kspeed,ax
		;
		mov	ax,noent
		mov	cs:curax,ax
		;
		call	cbclr			; cb work clear
		;
		ret
	ENDP



	;
	;	cursor character change
	;

	public	ms_chr
ms_chr	PROC	arg1:word, arg2:word, arg3:word

		mov	ax,arg2
		mov	ms_hx,ax
		mov	ax,arg3
		mov	ms_hy,ax
		mov	ax,arg1
		;
		push	ds
		push	si
		push	di
		;
		call	mchmk
		;
		mov	ax,-1
		mov	cs:curcx,ax
		call	ms_proc
		;
		pop	di
		pop	si
		pop	ds
		;
		ret
	ENDP


	;
	;	cursor wipe
	;

	public	ms_wipe
ms_wipe	PROC

		push	ds
		push	si
		push	di
		;
		mov	di,cs:curax
		mov	ax,noent
		cmp	ax,di
		jz	no_wipe
		mov	cs:curax,ax
		lea	si,vbtmp2
		mov	ax,cs
		mov	ds,ax
		mov	bx,cs:vt_cx
		mov	cx,cs:vt_cy
		call	vput			; put buffer2 on current vram
		;
no_wipe:
		pop	di
		pop	si
		pop	ds
		;
		ret
	ENDP



	;
	;	cursor kill
	;

	public	ms_kill
ms_kill	PROC

		mov	ax,cs:curax
		push	ax
		mov	ax,noent
		mov	cs:curax,ax
		;
		mov	ax,cs:vt_cx
		shl	ax,3
		mov	ms_ox,ax
		mov	ax,cs:vt_cy
		mov	ms_oy,ax
		;
		pop	ax
		;
		ret
	ENDP



	;
	;	special control for INT
	;

	public	ms_ctrl
ms_ctrl	PROC	arg1:word

		mov	dx,arg1
		mov	cx,1
		;
		cmp	dx,1
		jz	ctrl_1
		xor	cx,cx
ctrl_1:
		cmp	dx,2
		jc	ctrl_2
		mov	dx,1
ctrl_2:
		mov	cs:intflag,dx
		mov	cs:keyflag,cx
		ret
	ENDP



	;
	;	system shut down
	;

	public	ms_done
ms_done	PROC

		call	ms_wipe

		push	ds
		;
		mov	dx,7fddh
		mov	al,10h
		out	dx,al			; mouse int disable
		;
		lds	dx,cs:orghook
		mov	ax,2515h
		int	21h			; vector 15h resume
		;
		pop	ds
		ret
	ENDP


	;
	;	reset cursor position
	;

	public	ms_reset
ms_reset	PROC	XX:word, YY:word

		push	si
		push	di
		;
		mov	ax,XX
		mov	ms_xx,ax
		mov	ax,YY
		mov	ms_yy,ax
		;
		call	sysclr
		;
		mov	ax,noent
		mov	cs:curax,ax
		call	ms_proc
		;
		pop	di
		pop	si
		;
		ret
	ENDP



	;
	;	jump cursor position
	;

	public	ms_locate
ms_locate	PROC	XX:word, YY:word

		mov	ax,XX
		mov	ms_xx,ax
		mov	ax,YY
		mov	ms_yy,ax
		;
		call	ms_proc
		;
		ret
	ENDP



getms	PROC NEAR

		cli
		mov	di,7FDDh
		mov	si,7FD9h
		mov	al,80h
		mov	dx,di
		out	dx,al			; port 7FDDh
		mov	dx,si
		in	al,dx			; port 7FD9h
		and	al,0Fh
		mov	bl,al
		mov	al,0A0h
		mov	dx,di
		out	dx,al			; port 7FDDh
		mov	dx,si
		nop
		nop
		in	al,dx			; port 7FD9h
		shl	al,4			; Shift w/zeros fill
		or	al,bl
		cbw				; Convrt byte to word
		push	ax
		mov	al,0C0h
		mov	dx,di
		out	dx,al			; port 7FDDh
		mov	dx,si
		nop
		nop
		in	al,dx			; port 7FD9h
		and	al,0Fh
		mov	bl,al
		mov	al,0F0h
		mov	dx,di
		out	dx,al			; port 7FDDh
		mov	dx,si
		nop
		nop
		in	al,dx			; port 7FD9h
		xor	cx,cx
		test	al,20h
		jnz	nobut1
		or	cl,128
nobut1:
		test	al,80h
		jnz	nobut2
		or	cl,64
nobut2:
		mov	ms_key,cx		; for button check

		shl	al,4			; Shift w/zeros fill
		or	al,bl
		cbw				; Convrt byte to word
		mov	cx,ax
		mov	al,0
		mov	dx,di
		out	dx,al			; port 7FDDh
		pop	bx
		sti

		mov	ms_px,bx
		mov	ms_py,cx

movems:
		;
		;	move cursor position
		;

		or	bx,bx
		jz	w_chk3
		cmp	bx,08000h
		jnc	w_chk2
w_chk1:
		;	check ->
		;
		mov	ax,ms_xx
		add	ax,bx
		cmp	ax,MWIN_EX
		jc	ms_ham2
		jz	ms_ham2
		mov	ax,MWIN_EX
ms_ham2:
		mov	ms_xx,ax
		jmp	short w_chk3
w_chk2:
		;	check <-
		;
		mov	ax,ms_xx
		add	ax,bx
		cmp	ax,08000h
		jnc	ms_ham0
		cmp	ax,MWIN_SX
		jnc	ms_ham1
ms_ham0:
		mov	ax,MWIN_SX
ms_ham1:
		mov	ms_xx,ax


w_chk3:
		or	cx,cx
		jz	w_chk6
		cmp	cx,08000h
		jnc	w_chk4
w_chk5:
		;	check down
		;
		mov	ax,ms_yy
		add	ax,cx
		cmp	ax,MWIN_EY
		jc	ms_ham4
		jz	ms_ham4
		mov	ax,MWIN_EY
ms_ham4:
		mov	ms_yy,ax
		jmp	short w_chk6
w_chk4:
		;	check up
		;
		mov	ax,ms_yy
		add	ax,cx
		cmp	ax,08000h
		jnc	ms_ham5
		cmp	ax,MWIN_SY
		jnc	ms_ham3
ms_ham5:
		mov	ax,MWIN_SY
ms_ham3:
		mov	ms_yy,ax
w_chk6:
		;	end of window check
		;
		ret
	ENDP



	;
	;	ms main procedure
	;
	public	ms_proc
ms_proc	PROC

		push	ds
		push	si
		push	di
		;
		mov	ax,cs:INTDS
		mov	ds,ax
		;
		mov	ax,ms_jkey
		push	ax
		call	joyin
		or	ax,ms_key
		mov	ms_key,ax
		mov	ms_jkey,ax
		;
		cmp	cs:keyflag,0
		jz	invkey
		;
		call	joyms			; another input support
		call	movems
		;
invkey:
		pop	dx
		mov	ax,ms_jkey
		xor	dx,ax
		and	dx,ax
		mov	ms_trg,dx
		;
		call	cuput
		;
		pop	di
		pop	si
		pop	ds
		ret
	ENDP



	;
	;	for debug
	;
	public	ms_dbg
ms_dbg	PROC
		mov	ax,cs:dbgax
	ENDP



	;
	;	another input scan
	;
	;	input /
	;		ax : key code
	;	result /
	;		bx/cx : vector progress
	;
joyms	proc near

	xor	bx,bx
	xor	cx,cx
	inc	ms_count
	;
	mov	si,ms_lmode
	mov	dx,ax
	and	dx,0fh
	mov	ms_lmode,dx
	;
	or	dx,dx
	jz	mskres
	cmp	dx,si
	jnz	mskres
	;
	inc	ms_ktime
	mov	dx,ms_ktime
	cmp	dx,80
	jc	mskyx
	mov	ms_kspeed,4
	jmp	mskyx
	;
mskres:
	mov	ms_ktime,0
	mov	ms_kspeed,2
mskyx:
	mov	dx,ms_kspeed
	test	al,16
	jz	msky0
	mov	dx,6
	jmp	mskmain
msky0:
	shr	dx,1
	or	dx,dx
	jnz	mskmain
	;
	mov	dx,ms_count
	and	dx,1
	jz	msky4
	;
mskmain:
	test	al,1
	jz	msky1
	add	cx,dx
msky1:
	test	al,2
	jz	msky2
	sub	cx,dx
msky2:
	test	al,4
	jz	msky3
	sub	bx,dx
msky3:
	test	al,8
	jz	msky4
	add	bx,dx
msky4:
	ret
	endp




	;	cursor mark put ( after BG get )
	;
cuput	PROC NEAR

		mov	bx,ms_xx
		mov	cx,ms_yy
		;
		sub	bx,ms_hx		; adjust cursor pointer
		sub	cx,ms_hy		; x,y
		;
		mov	ax,bx
		shr	ax,3
		cmp	bx,8000h
		jc	nohos
		or	ax,0ff00h
nohos:

		mov	cs:vt_sx,ax
		mov	cs:vt_sy,cx
		push	ax
		push	cx
		;
		call	vcalc
		;
		cmp	ax,cs:curax
		jnz	go_put
		cmp	cx,cs:curcx
		jz	no_put
go_put:
		push	ax
		push	cx
		;
		mov	si,ax
		lea	di,vbtmp1
		mov	ax,cs
		mov	es,ax
		call	vget			; get current vram
		;
		mov	ax,cs
		mov	ds,ax
		mov	di,cs:curax
		cmp	di,noent
		jz	notmp
		lea	si,vbtmp2
		call	tmpput			; temp2 put on vram & temp1
		;
notmp:
		pop	cx
		mov	cs:curcx,cx
		;
		mov	ax,cs
		mov	ds,ax
		mov	es,ax
		;
		call	mchput
		;
		pop	ax
		mov	cs:curax,ax
		mov	di,ax
		lea	si,vbtmp1
		mov	ax,cs
		mov	ds,ax
		pop	cx
		pop	bx
		mov	cs:vt_cx,bx
		mov	cs:vt_cy,cx
		;
		call	vput			; put buffer1 on current vram
		;
		ret
no_put:
		pop	cx
		pop	bx
		mov	cs:vt_cx,bx
		mov	cs:vt_cy,cx
		;
		ret
	ENDP



	;----------------------------------------------
	;	some useful routines for VRAM
	;----------------------------------------------

vram_b		equ	0a800h
vram_r		equ	0b000h
vram_g		equ	0b800h
vram_e		equ	0e000h


	;
	;	vram address calc.
	;		in  : bx,cx / x,y axis
	;		out : ax,cx / vram, x and 7
	;
vcalc	PROC NEAR

		cmp	cx,8000h
		jc	vcal_0
		;
		neg	cx
		shl	cx,4
		mov	ax,cx
		shl	cx,2
		add	ax,cx			; x80
		neg	ax
		jmp	short vcal_1

vcal_0:
		shl	cx,4
		mov	ax,cx
		shl	cx,2
		add	ax,cx			; x80

vcal_1:
		mov	cx,bx
		and	cx,7
		cmp	bx,8000h
		jnc	vcal_2
		shr	bx,3			; /8
		add	ax,bx
		ret
vcal_2:
		shr	bx,3
		or	bx,0ff00h
		add	ax,bx
		ret

	ENDP



	;
	;	make masked cursor characters ( slided )
	;	input : AX ( base character code )
	;	mschr(ds:si) -> mschr(es:di)
	;		data format : mask,B,R,G,E x csr_h ( each 4bytes )
	;
pskip	equ	96
mchmk	PROC NEAR

		cmp	ax,-1
		jnz	mkjoin1

		mov	ax,cs:intds
		mov	ds,ax
		lea	si,defchr
		jmp	short mkjoin2
mkjoin1:
		shl	ax,7
		mov	si,ax
		shl	ax,1
		add	si,ax
		;
		mov	ax,cs:vb_seg2
		mov	ds,ax
mkjoin2:
		mov	ax,cs:vb_seg
		mov	es,ax
		;
		mov	di,0
		mov	cx,0
mkloop1:
		push	cx
		push	si
		;
		push	di
		push	cx
		;
		mov	cx,csr_h
		;
mkmchl:
		cld
		push	si
		mov	bx,di
		add	di,4
		mov	ax,ds:[si]
		mov	dx,ds:[si+2]
		mov	es:[bx],ax
		mov	es:[bx+2],dx
		stosw
		mov	ax,dx
		stosw
		add	si,pskip
		;
		mov	ax,ds:[si]
		mov	dx,ds:[si+2]
		or	es:[bx],ax
		or	es:[bx+2],dx
		stosw
		mov	ax,dx
		stosw
		add	si,pskip
		;
		mov	ax,ds:[si]
		mov	dx,ds:[si+2]
		or	es:[bx],ax
		or	es:[bx+2],dx
		stosw
		mov	ax,dx
		stosw
		add	si,pskip
		;
		mov	ax,ds:[si]
		mov	dx,ds:[si+2]
		or	es:[bx],ax
		or	es:[bx+2],dx
		stosw
		mov	ax,dx
		stosw
		;
		pop	si
		add	si,4
		loop	mkmchl
		;
		pop	cx
		pop	bx
		call	dslide
		;
		pop	si
		pop	cx
		inc	cx
		cmp	cx,8
		jz	mkover
		jmp	mkloop1
mkover:
		ret

dslide:
		or	cx,cx
		jz	dsl_2
		;
		push	si
		mov	si,csr_h*5
dsl_0:
		mov	ax,es:[bx]
		mov	dx,es:[bx+2]
		xchg	ah,al
		xchg	dh,dl
		mov	ch,cl
dsl_1:
		shr	ax,1
		rcr	dx,1
		dec	ch
		jnz	dsl_1
		;
		xchg	ah,al
		xchg	dh,dl
		mov	es:[bx],ax
		mov	es:[bx+2],dx
		add	bx,4
		;
		dec	si
		jnz	dsl_0
		pop	si
dsl_2:
		ret

	ENDP



	;
	;	temp put to vram and temp ( with area check )
	;	mschr(ds:si) bgtmp(cs:di) -> puttmp(es:di)
	;	cx / shift counter
	;
mchput	PROC NEAR

		push	bp

		mov	ax,mchrsize
		mul	cx
		mov	si,ax
		lea	di,vbtmp2

		cld
		mov	ax,cs:vb_seg
		mov	ds,ax
		mov	ax,cs
		sub	ax,384/16
		mov	es,ax
		mov	cx,csr_h
mcl_1:
		lodsw
		not	ax
		mov	dx,ax
		lodsw
		not	ax
		mov	bp,ax

		;	plane B
		;
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,dx
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,bp
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si

		;	plane R
		;
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,dx
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,bp
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si

		;	plane G
		;
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,dx
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,bp
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si

		;	plane E
		;
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,dx
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si
		mov	ax,es:[di]
		mov	cs:[di],ax
		and	ax,bp
		or	ax,ds:[si]
		stosw
		inc	si
		inc	si

		loop	mcl_1
		;
		pop	bp
		ret
	ENDP



	;
	;	temp put to vram and temp ( with area check )
	;	mem(ds:bx) -> vram(es:di) or mem(ds:si)
	;			cutoff area ( vt_sx,sy,ex,ey )
	;
tmpput	PROC NEAR

		push	bp
		mov	bp,csr_h
		mov	bx,si
tpl_1:
		mov	dx,cs:vt_cx
		mov	cx,4
tpl_2:
		mov	ax,cs:vt_cy
		sub	ax,cs:vt_sy
		cmp	ax,csr_h
		jnc	tpl_4
		mov	si,ax
		;
		mov	ax,dx
		sub	ax,cs:vt_sx
		cmp	ax,4
		jnc	tpl_4
		;
		shl	si,4
		add	si,ax
		add	si,offset vbtmp1
tpl_3:
		mov	al,ds:[bx]
		mov	ds:[si],al
		mov	al,ds:[bx+4]
		mov	ds:[si+4],al
		mov	al,ds:[bx+8]
		mov	ds:[si+8],al
		mov	al,ds:[bx+12]
		mov	ds:[si+12],al
		jmp	short tpl_5
tpl_4:
		cmp	di,32000
		jnc	tpl_5				; on screen?
		;
		mov	ax,vram_b
		mov	es,ax
		mov	al,ds:[bx]
		mov	es:[di],al
		mov	al,ds:[bx+4]
		mov	es:[di+8000h],al
		mov	ax,vram_g
		mov	es,ax
		mov	al,ds:[bx+8]
		mov	es:[di],al
		mov	ax,vram_e
		mov	es,ax
		mov	al,ds:[bx+12]
		mov	es:[di],al
tpl_5:
		inc	dx
		inc	di
		inc	bx
		loop	tpl_2
		;
		add	di,80-4
		add	bx,16-4
		inc	cs:vt_cy
		dec	bp
		jz	tpl_6
		jmp	tpl_1
tpl_6:
		;
		pop	bp
		ret
	ENDP



	;
	;	vram(ds:si) -> mem(es:di)
	;
vget	PROC NEAR

		mov	bx,si
		mov	cx,csr_h
		cld
vgl_1:
		cmp	bx,32000
		jc	vgl_2
		cmp	bx,-4
		jnc	vgl_4
		;
		add	di,16
		jmp	short vgl_3
vgl_2:
		mov	ax,vram_b
		mov	ds,ax
		mov	ax,ds:[bx]
		stosw
		mov	ax,ds:[bx+2]
		stosw
		mov	ax,ds:[bx+8000h]
		stosw
		mov	ax,ds:[bx+8002h]
		stosw
		;
		mov	ax,vram_g
		mov	ds,ax
		mov	ax,ds:[bx]
		stosw
		mov	ax,ds:[bx+2]
		stosw
		;
		mov	ax,vram_e
		mov	ds,ax
		mov	ax,ds:[bx]
		stosw
		mov	ax,ds:[bx+2]
		stosw
vgl_3:
		add	bx,80
		loop	vgl_1
		;
		ret

vgl_4:
		;	for misc case
		;

		mov	ax,vram_b
		mov	ds,ax
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		inc	bx
		stosw
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		sub	bx,3
		stosw
		;
		mov	ax,vram_r
		mov	ds,ax
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		inc	bx
		stosw
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		sub	bx,3
		stosw
		;
		mov	ax,vram_g
		mov	ds,ax
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		inc	bx
		stosw
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		sub	bx,3
		stosw
		;
		mov	ax,vram_e
		mov	ds,ax
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		inc	bx
		stosw
		mov	al,ds:[bx]
		inc	bx
		mov	ah,ds:[bx]
		sub	bx,3
		stosw
		;
		jmp	short vgl_3


	ENDP



	;
	;	vram put
	;	input : bx,cx / put axis
	;	mem(ds:si) -> vram(es:di)
	;
vput	PROC NEAR

		cmp	bx,cs:clp_sx
		jc	vputc
		mov	ax,cs:clp_ex
		sub	ax,csr_sx
		cmp	bx,ax
		jnc	vputc
		;
		cmp	cx,cs:clp_sy
		jc	vputc
		mov	ax,cs:clp_ey
		sub	ax,csr_sy
		cmp	cx,ax
		jnc	vputc

vputn:
		;	vput normal
		;

		mov	bx,di
		mov	cx,csr_h
		cld
vpl_1:
		mov	ax,vram_b
		mov	es,ax

		lodsw
		mov	es:[bx],ax
		lodsw
		mov	es:[bx+2],ax
		lodsw
		mov	es:[bx+8000h],ax
		lodsw
		mov	es:[bx+8002h],ax
		;
		mov	ax,vram_g
		mov	es,ax
		lodsw
		mov	es:[bx],ax
		lodsw
		mov	es:[bx+2],ax
		;
		mov	ax,vram_e
		mov	es,ax
		lodsw
		mov	es:[bx],ax
		lodsw
		mov	es:[bx+2],ax
		;
		add	bx,80
		loop	vpl_1
		;
		ret

vputc:
		;	vram put ( supports clipping )
		;

		push	bp
		mov	cs:clp_wx,bx
		mov	cs:clp_wy,cx

		mov	bx,di
		mov	bp,csr_h
vpl_2:
		mov	ax,cs:clp_wy
		cmp	ax,cs:clp_sy
		jc	vpl_6
		cmp	ax,cs:clp_ey
		jnc	vpl_6
		;cmp	bx,32000
		;jnc	vpl_6
		;
		mov	cx,4
		mov	di,cs:clp_wx
vpl_4:
		cmp	di,cs:clp_sx
		jc	vpl_5
		cmp	di,cs:clp_ex
		jnc	vpl_5
		;
		mov	ax,vram_b
		mov	es,ax
		;
		mov	al,ds:[si]
		mov	es:[bx],al
		mov	al,ds:[si+4]
		mov	es:[bx+8000h],al
		;
		mov	ax,vram_g
		mov	es,ax
		mov	al,ds:[si+8]
		mov	es:[bx],al
		;
		mov	ax,vram_e
		mov	es,ax
		mov	al,ds:[si+12]
		mov	es:[bx],al
vpl_5:
		inc	bx
		inc	si
		inc	di
		loop	vpl_4
		;
		add	bx,80-4
		add	si,16-4
vpl_3:
		inc	cs:clp_wy
		dec	bp
		jnz	vpl_2
		;
		pop	bp
		ret

vpl_6:
		add	bx,80
		add	si,16
		jmp	short vpl_3

	ENDP



	;----------------------------------------------
	;	check box system routines
	;----------------------------------------------


	;
	;	work clear
	;

	public	ms_cinit
ms_cinit	PROC	cbw_seg:word, cbw_kazz:word

		push	si
		push	di
		;
		mov	ax,cbw_kazz
		mov	cs:cbkazz,ax
		mov	ax,cbw_seg
		mov	cs:vb_seg3,ax
		;
		call	cbclr
		;
		pop	di
		pop	si
		;
		ret
	ENDP


cbcalc	PROC NEAR

		push	dx
		shl	ax,1
		mov	dx,ax
		shl	ax,2
		add	ax,dx			; x10 (cbsize)
		pop	dx
		ret
	ENDP


cbclr	PROC NEAR
		mov	ax,cs:vb_seg3
		mov	es,ax
		mov	ax,cs:cbkazz
		call	cbcalc
		mov	cx,ax
		cld
		xor	di,di
		mov	ax,-1
		rep	stosw
		ret
	ENDP



	;
	;	check box data set
	;

	public	ms_cset
ms_cset	PROC	cbno:word, cbflg:word, cbxx:word, cbyy:word, cblx:word, cbly:word

		mov	ax,cs:vb_seg3
		mov	es,ax
		mov	ax,cbno
		call	cbcalc
		mov	bx,ax
		;
		mov	ax,cbflg
		mov	es:[bx],ax
		mov	ax,cbxx
		mov	es:[bx+2],ax
		mov	ax,cbyy
		mov	es:[bx+4],ax
		mov	ax,cblx
		inc	ax
		mov	es:[bx+6],ax
		mov	ax,cbly
		inc	ax
		mov	es:[bx+8],ax
		;
		ret
	ENDP



	;
	;	check box collision check
	;

	public	ms_cbox
ms_cbox	PROC

		push	si
		push	di
		;
		mov	ax,cs:vb_seg3
		mov	es,ax
		;
		mov	bx,ms_xx
		mov	dx,ms_yy
		xor	cx,cx
		mov	si,cx
		mov	di,-1
		;
cchk_1:
		mov	ax,es:[si]
		cmp	ax,-1
		jz	cchk_2
		cmp	bx,es:[si+2]
		jc	cchk_2
		cmp	bx,es:[si+6]
		jnc	cchk_2
		cmp	dx,es:[si+4]
		jc	cchk_2
		cmp	dx,es:[si+8]
		jnc	cchk_2
		;
		mov	di,cx
cchk_2:
		add	si,cbsize
		inc	cx
		cmp	cx,cs:cbkazz
		jnz	cchk_1
		;
		mov	ax,di
		;
		pop	di
		pop	si
		;
		ret
	ENDP



	;
	;	check box flag data inf
	;

	public	ms_cget
ms_cget	PROC	cbno:word

		mov	ax,cs:vb_seg3
		mov	es,ax
		mov	ax,cbno
		call	cbcalc
		mov	bx,ax
		;
		mov	ax,es:[bx]
		;
		ret
	ENDP



	;----------------------------------------------
	;	some useful routines for I/O port
	;----------------------------------------------


joyin	proc near
	push	di

	xor	ax,ax			; force key buffer enpty
	mov	es,ax
	mov	di,0528H
	mov	es:[di],al
	;
	xor	dx,dx
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


joysub:
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
	
BB6:	mov	ax,0040EH	;"SHIFT"
	int	18H
	and	ah,000000001B
	je	BB7
	;
	or	dl,16

BB7:	mov	ax,00400H	;"ESC"
	int	18H
	and	ah,01B
	je	BB8
	;
	or	dl,32

	;	for cursor key
	;
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
	je	TT2W
	;
	or	dl,8
TT2W:
	retn
	endp





_TEXT	ends


;-------------------------------------------------
;	data segment
;-------------------------------------------------


DGROUP	GROUP	_DATA
_DATA	segment	word public 'DATA'

MWIN_SX		dw	0
MWIN_SY		dw	0
MWIN_EX		dw	639
MWIN_EY		dw	399

		public	ms_key, ms_trg, ms_xx, ms_yy
		public	ms_px, ms_py, ms_hx, ms_hy
		public	ms_ox, ms_oy

ms_count	dw	0
ms_jkey		dw	0
ms_key		dw	0
ms_trg		dw	0
ms_lmode	dw	0
ms_ktime	dw	0
ms_kspeed	dw	0
ms_xx		dw	0
ms_yy		dw	0
ms_px		dw	0
ms_py		dw	0
ms_hx		dw	0
ms_hy		dw	0
ms_ox		dw	0
ms_oy		dw	0


		;
		;	default system character ( arrow )
		;
defchr	db 	0C0h,000h,000h,000h,0A0h,000h,000h,000h,0D0h,000h,000h,000h,0E8h,000h,000h,000h
	db 	0F4h,000h,000h,000h,0DAh,000h,000h,000h,0CDh,000h,000h,000h,0C6h,080h,000h,000h
	db 	0C3h,040h,000h,000h,0C1h,0A0h,000h,000h,0C0h,0D0h,000h,000h,0C1h,070h,000h,000h
	db 	0C0h,080h,000h,000h,0C1h,080h,000h,000h,0DDh,080h,000h,000h,0ECh,0C0h,000h,000h
	db 	0C6h,0C0h,000h,000h,006h,060h,000h,000h,003h,060h,000h,000h,003h,040h,000h,000h
	db 	001h,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db 	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,000h
	db 	040h,000h,000h,000h,060h,000h,000h,000h,070h,000h,000h,000h,078h,000h,000h,000h
	db 	07Ch,000h,000h,000h,07Eh,000h,000h,000h,07Fh,000h,000h,000h,07Eh,000h,000h,000h
	db 	07Eh,000h,000h,000h,07Eh,000h,000h,000h,066h,000h,000h,000h,047h,000h,000h,000h
	db 	003h,000h,000h,000h,003h,080h,000h,000h,001h,080h,000h,000h,001h,080h,000h,000h
	db 	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db 	000h,000h,000h,000h,040h,000h,000h,000h,060h,000h,000h,000h,070h,000h,000h,000h
	db 	078h,000h,000h,000h,07Ch,000h,000h,000h,07Eh,000h,000h,000h,07Fh,000h,000h,000h
	db 	07Fh,080h,000h,000h,07Fh,0C0h,000h,000h,07Fh,0E0h,000h,000h,07Fh,080h,000h,000h
	db 	07Fh,000h,000h,000h,07Fh,000h,000h,000h,067h,000h,000h,000h,047h,080h,000h,000h
	db 	003h,080h,000h,000h,003h,0C0h,000h,000h,001h,0C0h,000h,000h,001h,080h,000h,000h
	db 	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db 	000h,000h,000h,000h,040h,000h,000h,000h,060h,000h,000h,000h,070h,000h,000h,000h
	db 	078h,000h,000h,000h,07Ch,000h,000h,000h,07Eh,000h,000h,000h,07Fh,000h,000h,000h
	db 	07Fh,080h,000h,000h,07Fh,0C0h,000h,000h,07Fh,0E0h,000h,000h,07Fh,080h,000h,000h
	db 	07Fh,000h,000h,000h,07Fh,000h,000h,000h,067h,000h,000h,000h,047h,080h,000h,000h
	db 	003h,080h,000h,000h,003h,0C0h,000h,000h,001h,0C0h,000h,000h,001h,080h,000h,000h
	db 	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h


_DATA		ENDS



;-------------------------------------------------
;	end of line
;-------------------------------------------------

	END



