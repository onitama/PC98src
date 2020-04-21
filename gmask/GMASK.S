;---------------------------------------------------
;
;	extend graphic system routines for turbo C++
;	for screen mask,get,put
;	    and 200line software sprite module
;
;			Started   1993/3  onitama
;			Separated 1993/12 onitama
;			Modified  1994/6  onitama
;
;---------------------------------------------------

	.MODEL small,C
	.186

	.CODE

copytype	dw	0

getxs	dw	0
getys	dw	0
tmpd0	dw	0
tmpd1	dw	0
tmpd2	dw	0
tmpd3	dw	0
msks	dw	0
tmpb0	db	0
tmpb1	db	0
tmpb2	db	0
tmpb3	db	0
tmpb4	db	0
tmpb5	db	0

	;----------------------------------------------------------------

ssp_clpx1	dw	0
ssp_clpy1	dw	0
ssp_clpx2	dw	80
ssp_clpy2	dw	200
ssp_vofs	dw	0
ssp_ovmx	dw	0
ssp_ovx		dw	0
ssp_ovy		dw	0

ssp_vdb		dw	0
ssp_vdr		dw	0
ssp_vdg		dw	0
ssp_vde		dw	0

ssp_page	dw	0
ssp_seg		dw	0
ssp_kazu	dw	0
ssp_wiptab	dw	66 dup(0)
ssp_work	dw	256 dup(0)

	;----------------------------------------------------------------

vram_b	equ 0A800H
vram_r	equ 0B000H
vram_g	equ 0B800H
vram_e	equ 0E000H

	;----------------------------------------------
	;	screen mask buffer make
	;----------------------------------------------

	PUBLIC	msk_make
msk_make	proc	wkseg:WORD,wkcol:WORD

	mov	ax,wkseg
	mov	cs:msks,ax
	mov	es,ax
	mov	ax,wkcol
	xor	dx,dx
	call	vtob
	ret
	endp


	;----------------------------------------------
	;	merge screen fast ( with mask buffer ) 
	;----------------------------------------------

	PUBLIC	msk_merge
msk_merge	proc	wkseg:WORD,wkcol:WORD

	push	ds
	push	si
	push	di
	;
	mov	ax,wkseg
	mov	es,ax
	mov	ax,wkcol
	xor	dx,dx
	call	vtob
	;
	mov	si,16000
	xor	bx,bx
	mov	ax,vram_b
	mov	ds,ax
msm1:
	mov	dx,es:[bx]		; read mask data
	inc	al
	out	0a6h,al			; set page 1
	dec	al
	;
	mov	cx,ds:[bx]
	and	cx,dx
	mov	cs:tmpd0,cx
	;
	mov	cx,ds:[bx+8000h]
	and	cx,dx
	mov	cs:tmpd1,cx
	;
	mov	ah,HIGH vram_g
	mov	ds,ax
	mov	cx,ds:[bx]
	and	cx,dx
	mov	cs:tmpd2,cx
	;
	mov	ah,HIGH vram_e
	mov	ds,ax
	mov	cx,ds:[bx]
	and	cx,dx
	;
	out	0a6h,al				; set page 0
	not	dx
	;
	mov	ax,ds:[bx]
	and	ax,dx
	or	ax,cx
	mov	ds:[bx],ax
	;
	mov	ax,vram_g
	mov	ds,ax
	mov	cx,ds:[bx]
	and	cx,dx
	or	cx,cs:tmpd2
	mov	ds:[bx],cx
	;
	mov	ah,HIGH vram_b
	mov	ds,ax
	mov	cx,ds:[bx+8000h]
	and	cx,dx
	or	cx,cs:tmpd1
	mov	ds:[bx+8000h],cx
	;
	mov	cx,ds:[bx]
	and	cx,dx
	or	cx,cs:tmpd0
	mov	ds:[bx],cx
	;
	inc	bx
	inc	bx
	dec	si
	or	si,si
	jnz	msm1
	;
	pop	di
	pop	si
	pop	ds
	ret
	endp


	;----------------------------------------------
	;	merge screen ( with mask buffer )
	;		mmode=0 (to page0),1 (to page1)
	;		wkcol=0-15 selected color
	;			( others to all screen)
	;----------------------------------------------

	PUBLIC	msk_merge2
msk_merge2	proc	wkseg:WORD,wkcol:WORD,mmode:WORD,vinc:WORD,wtime:WORD

	push	ds
	push	si
	push	di
	;
	xor	al,al
	out	0a6h,al			; set page 1
	;
	mov	dx,mmode
	or	dx,dx
	jz	mer1
	mov	dx,-1
mer1:
	xor	dx,-1
	;
	mov	ax,wkseg
	mov	es,ax
	mov	ax,wkcol
	call	vtob
	;
	mov	dx,mmode
	mov	ax,wtime
	mov	cs:tmpd3,ax
	mov	di,vinc
	or	di,1			; factor is odd
	mov	ax,vram_b
	mov	ds,ax
	call	vtrs
	mov	ax,vram_r
	mov	ds,ax
	call	vtrs
	mov	ax,vram_g
	mov	ds,ax
	call	vtrs
	mov	ax,vram_e
	mov	ds,ax
	call	vtrs
	;
	pop	di
	pop	si
	pop	ds
	ret
	endp


vtrs	proc near

	push	dx
	xor	bx,bx
	xor	ax,ax
	mov	si,8000h
	or	dx,dx
	jnz	vtrs2
	;
msm0:
	;	vram(1)->vram(0)
	;
	mov	dl,es:[bx]		; read mask data
	inc	al
	out	0a6h,al			; set page 1
	dec	al
	;
	mov	ch,ds:[bx]
	and	ch,dl
	;
	out	0a6h,al			; set page 0
	xor	dl,0ffh
	;
	mov	cl,ds:[bx]
	and	cl,dl
	or	cl,ch
	mov	ds:[bx],cl
	;
	mov	cx,cs:tmpd3
	or	cx,cx
	jz	msm2
msm3:
	inc	dx
	loop	msm3
msm2:
	add	bx,di
	and	bx,07fffh
	dec	si
	or	si,si
	jnz	msm0
	;
	pop	dx
	ret

vtrs2:
	;	vram(0)->vram(1)
	;
	mov	ax,1
	out	0a6h,al			; set page 1
	dec	al

msm4:
	mov	dl,es:[bx]		; read mask data
	;
	mov	ch,ds:[bx]
	and	ch,dl
	;
	out	0a6h,al			; set page 0
	xor	dl,0ffh
	;
	mov	cl,ds:[bx]
	and	cl,dl
	or	cl,ch
	;
	inc	al
	out	0a6h,al			; set page 1
	dec	al
	;
	mov	ds:[bx],cl
	;
	mov	cx,cs:tmpd3
	or	cx,cx
	jz	msm5
msm6:
	inc	dx
	loop	msm6
msm5:
	add	bx,di
	and	bx,07fffh
	dec	si
	or	si,si
	jnz	msm4
	;
	pop	dx
	ret
	endp


	;----------------------------------------------
	;	vram selected color transfer to buffer 
	;		sel color/ al  buffer/ es,0
	;		     ( al>15 : all buffer sel )
	;----------------------------------------------

vtob	proc near

	cmp	al,16
	jnc	bufall
	;
	push	ax
	call	grcgon
	pop	ax
	call	grcgcolor
	;
	push	ds
	mov	ax,vram_b
	mov	ds,ax
	xor	bx,bx
	mov	cx,16000		; 80x400/2
vtol:
	mov	ax,ds:[bx]
	mov	es:[bx],ax
	inc	bx
	inc	bx
	loop	vtol
	;
	pop	ds
	call	grcgoff
	ret

bufall:
	mov	cx,16000		; 80x400/2
bfful:
	mov	es:[bx],dx
	inc	bx
	inc	bx
	loop	bfful
	;
	ret
	endp


	;----------------------------------------------
	;	vram data transfer to buffer
	;----------------------------------------------

	PUBLIC	msk_get
msk_get	proc	prm1:WORD,prm2:WORD,prm3:WORD,prm4:WORD

	push	ds
	push	di
	push	si
	;
	mov	ax,prm1		; write seg.
	mov	es,ax
	mov	bx,prm2		; vram offset
	mov	si,0
	mov	ax,prm3		; x size
	shr	ax,4
	mov	cs:getxs,ax
	mov	ax,prm4		; y size
	mov	cs:getys,ax
	;
	mov	cx,cs:getys
mg1:
	push	cx
	push	bx
	mov	cx,cs:getxs
mg2:
	mov	ax,cs:msks
	mov	ds,ax
	mov	ax,ds:[bx]
	mov	es:[si],ax
	inc	si
	inc	si
	mov	ax,vram_b
	mov	ds,ax
	mov	ax,ds:[bx]
	mov	es:[si],ax
	inc	si
	inc	si
	mov	ax,ds:[bx+8000h]
	mov	es:[si],ax
	inc	si
	inc	si
	;
	mov	ax,vram_g
	mov	ds,ax
	mov	ax,ds:[bx]
	mov	es:[si],ax
	inc	si
	inc	si
	;
	mov	ax,vram_e
	mov	ds,ax
	mov	ax,ds:[bx]
	mov	es:[si],ax
	inc	si
	inc	si
	;
	inc	bx
	inc	bx
	loop	mg2
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	mg1
	;
	pop	si
	pop	di
	pop	ds
	;
	ret
	endp


	;----------------------------------------------
	;	buffer transfer to vram (on screen)
	;----------------------------------------------

	PUBLIC	msk_put
msk_put	proc	prm1:WORD,prm2:WORD,prm3:WORD,prm4:WORD

	push	ds
	push	di
	push	si
	;
	mov	ax,prm1		; write seg.
	mov	es,ax
	mov	bx,prm2		; vram offset
	mov	si,0
	mov	ax,prm3		; x size
	shr	ax,4
	mov	cs:getxs,ax
	mov	ax,prm4		; y size
	mov	cs:getys,ax
	;
	push	bp
	;
	mov	cx,cs:getys
mg5:
	push	cx
	push	bx
	mov	di,cs:getxs
mg6:
	mov	dx,es:[si]
	mov	bp,dx
	not	dx
	or	dx,dx
	jz	mg7
	inc	si
	inc	si
	;
	mov	ax,vram_b
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx+8000h]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx+8000h],ax
	inc	si
	inc	si
	mov	ax,vram_g
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	ax,vram_e
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
mg8:
	inc	bx
	inc	bx
	dec	di
	or	di,di
	jnz	mg6
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	mg5
	;
	pop	bp
	pop	si
	pop	di
	pop	ds
	;
	ret
mg7:
	add	si,10
	jmp	short mg8
	endp


	;----------------------------------------------
	;	buffer transfer to vram (mask accept)
	;----------------------------------------------

	PUBLIC	msk_mput
msk_mput	proc	prm1:WORD,prm2:WORD,prm3:WORD,prm4:WORD

	push	ds
	push	di
	push	si
	;
	mov	ax,prm1		; write seg.
	mov	es,ax
	mov	bx,prm2		; vram offset
	mov	si,0
	mov	ax,prm3		; x size
	shr	ax,4
	mov	cs:getxs,ax
	mov	ax,prm4		; y size
	mov	cs:getys,ax
	;
	push	bp
	;
	mov	cx,cs:getys
mg3:
	push	cx
	push	bx
	mov	di,cs:getxs
mg4:
	mov	ax,cs:msks
	mov	ds,ax
	mov	dx,ds:[bx]
	or	dx,dx
	jz	mg9
	mov	bp,dx
	not	bp
	inc	si
	inc	si
	;
	mov	ax,vram_b
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx+8000h]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx+8000h],ax
	inc	si
	inc	si
	mov	ax,vram_g
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	ax,vram_e
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
mg10:
	inc	bx
	inc	bx
	dec	di
	or	di,di
	jnz	mg4
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	mg3
	;
	pop	bp
	pop	si
	pop	di
	pop	ds
	;
	ret

mg9:
	add	si,10
	jmp	short mg10
	endp


	;-----------------------------------------------
	; liner vram data transfer to buffer ( no mask )
	;-----------------------------------------------

	PUBLIC	msk_lget
msk_lget	proc	prm1:WORD,prm2:WORD,prm3:WORD,prm4:WORD,prm5:WORD

	push	ds
	push	di
	push	si
	;
	mov	ax,prm1		; write seg.
	mov	es,ax
	mov	bx,prm2		; vram offset
	mov	si,0
	mov	ax,prm3		; x size
	shr	ax,4
	mov	cs:getxs,ax
	mov	ax,prm4		; y size
	mov	cs:getys,ax
	mov	dx,prm5		; plane mask
	;
	shr	dl,1
	jnc	psk5
	mov	ax,vram_b
	mov	ds,ax
	call	li_get
psk5:
	shr	dl,1
	jnc	psk6
	mov	ax,vram_r
	mov	ds,ax
	call	li_get
psk6:
	shr	dl,1
	jnc	psk7
	mov	ax,vram_g
	mov	ds,ax
	call	li_get
psk7:
	shr	dl,1
	jnc	psk8
	mov	ax,vram_e
	mov	ds,ax
	call	li_get
psk8:
	;
	pop	si
	pop	di
	pop	ds
	;
	ret
	endp

li_get	proc near
	push	bx
	mov	cx,cs:getys
lg1:
	push	cx
	push	bx
	mov	cx,cs:getxs
lg2:
	mov	ax,ds:[bx]
	mov	es:[si],ax
	inc	si
	inc	si
	inc	bx
	inc	bx
	loop	lg2
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	lg1
	;
	mov	cx,si				; segment adjust
	shr	cx,4
	mov	ax,es
	add	ax,cx
	mov	es,ax
	and	si,15
	;
	pop	bx
	ret
	endp


	;-----------------------------------------------
	; liner buffer data transfer to vram ( no mask )
	;-----------------------------------------------

	PUBLIC	msk_lput
msk_lput	proc	prm1:WORD,prm2:WORD,prm3:WORD,prm4:WORD,prm5:WORD

	push	ds
	push	di
	push	si
	;
	mov	ax,prm1		; write seg.
	mov	es,ax
	mov	bx,prm2		; vram offset
	mov	si,0
	mov	ax,prm3		; x size
	shr	ax,4
	mov	cs:getxs,ax
	mov	ax,prm4		; y size
	mov	cs:getys,ax
	mov	dx,prm5		; plane mask
	;
	shr	dl,1
	jnc	psk1
	mov	ax,vram_b
	mov	ds,ax
	call	li_put
psk1:
	shr	dl,1
	jnc	psk2
	mov	ax,vram_r
	mov	ds,ax
	call	li_put
psk2:
	shr	dl,1
	jnc	psk3
	mov	ax,vram_g
	mov	ds,ax
	call	li_put
psk3:
	shr	dl,1
	jnc	psk4
	mov	ax,vram_e
	mov	ds,ax
	call	li_put
psk4:
	;
	pop	si
	pop	di
	pop	ds
	;
	ret
	endp


li_put	proc near
	push	bx
	mov	cx,cs:getys
lg3:
	push	cx
	push	bx
	mov	cx,cs:getxs
lg4:
	mov	ax,es:[si]
	mov	ds:[bx],ax
	inc	si
	inc	si
	inc	bx
	inc	bx
	loop	lg4
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	lg3
	;
	mov	cx,si				; segment adjust
	shr	cx,4
	mov	ax,es
	add	ax,cx
	mov	es,ax
	and	si,15
	;
	pop	bx
	ret
	endp



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
	mov	bx,si
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


	;----------------------------------------------------------------
	;	software sprite ( 48x24 16color ) module
	;----------------------------------------------------------------

spx	equ	48		; sprite size (dot)
spy	equ	24
spxh	equ	40		; hit size (dot)
spxh2	equ	32
spyh	equ	24
spyh2	equ	14

s_xx	equ	0
s_yy	equ	2
s_chr	equ	4
s_last	equ	6
s_kazz	equ	8
chrsize	equ	720

	;	sprite address get macro ( ax/sprite No.  result: bx )
	;
ssp_calq macro
	shl	ax,3		; x8
	lea	bx,ssp_work
	add	bx,ax
	endm



	;	sprite initalize and ( max sprite is now 64 )
	;	BG screen prepare
	;		ssp_init( int chrdat_seg, int ssp_kazu );
	;
	public	ssp_init
ssp_init proc	arg1:WORD , arg2:WORD

	xor	ax,ax
	mov	cs:ssp_page,ax
	mov	ax,arg1
	mov	cs:ssp_seg,ax
	mov	ax,arg2
	mov	cs:ssp_kazu,ax
	;
	or	ax,ax
	jz	spi1
	mov	cx,ax
	mov	dx,-1
	xor	ax,ax
	lea	bx,ssp_work
spi2:
	mov	cs:[bx+s_xx],dx
	mov	cs:[bx+s_yy],ax
	mov	cs:[bx+s_chr],ax
	mov	cs:[bx+s_last],ax
	add	bx,s_kazz
	loop	spi2
	;
spi1:
	;	BG screen prepare
	;
	xor	ax,ax
	out	0a6h,al
	;
	xor	dx,dx
	mov	ax,200
	push	ax
	push	dx
	push	ax
	mov	ax,640
	push	ax
	push	dx
	push	dx
	call	g_copy
	add	sp,12
	;
	xor	dx,dx
	push	dx
	push	dx
	push	dx
	mov	ax,400
	push	ax
	mov	ax,640
	push	ax
	push	dx
	push	dx
	call	g_copy2
	add	sp,14
	;
	xor	ax,ax
	out	0a4h,al
	out	0a6h,al
	;
	ret
	endp


	;	sprite data shift macro
	;
ssp_sf2 macro
	mov	ah,ds:[bx]
	mov	al,ds:[bx+1]
	mov	dh,ds:[bx+10]
	mov	dl,ds:[bx+11]
	mov	ch,ds:[bx+20]
	mov	cl,ds:[bx+21]
	shr	ax,1
	rcr	dx,1
	rcr	cx,1
	shr	ax,1
	rcr	dx,1
	rcr	cx,1
	or	ah,128+64
	mov	ds:[bx],ah
	mov	ds:[bx+1],al
	mov	ds:[bx+10],dh
	mov	ds:[bx+11],dl
	mov	ds:[bx+20],ch
	mov	ds:[bx+21],cl
	endm
ssp_sft macro
	mov	ah,ds:[bx]
	mov	al,ds:[bx+1]
	mov	dh,ds:[bx+10]
	mov	dl,ds:[bx+11]
	mov	ch,ds:[bx+20]
	mov	cl,ds:[bx+21]
	shr	ax,1
	rcr	dx,1
	rcr	cx,1
	shr	ax,1
	rcr	dx,1
	rcr	cx,1
	mov	ds:[bx],ah
	mov	ds:[bx+1],al
	mov	ds:[bx+10],dh
	mov	ds:[bx+11],dl
	mov	ds:[bx+20],ch
	mov	ds:[bx+21],cl
	endm


	;	character data buffer extend ( 45chr/32Kbytes x 4 buffer )
	;	for H2-dot sprite prepare
	;		ssp_ext( int chrdat_seg );
	;
	public	ssp_ext
ssp_ext proc	arg1:WORD
	;
	push	ds
	push	di
	push	si
	mov	ax,arg1
	mov	ds,ax
	;
	call	ext_chr		; 2dot
	call	ext_chr		; 4dot
	call	ext_chr		; 6dot
	;
	pop	si
	pop	di
	pop	ds
	ret

ext_chr:
	;	chr data move ( 32K -> 32K )
	;
	mov	cx,04000h
	xor	bx,bx
extc1:
	mov	ax,ds:[bx]
	mov	ds:[bx+8000h],ax
	inc	bx
	inc	bx
	loop	extc1
	;
	mov	ax,ds
	add	ax,0800h
	mov	ds,ax
	;
	;	chr data shift 48x24 ( -> )
	;
	mov	si,24*45
	xor	bx,bx
extc2:
	push	bx
	ssp_sf2
	inc	bx
	inc	bx
	ssp_sft
	inc	bx
	inc	bx
	ssp_sft
	inc	bx
	inc	bx
	ssp_sft
	inc	bx
	inc	bx
	ssp_sft
	pop	bx
	;
	add	bx,30
	dec	si
	jz	extc3
	jmp	extc2
extc3:
	retn
	endp



	;	sprite clipping area set
	;		ssp_clip( x1,y1,x2,y2,vram offset );
	;
	PUBLIC	ssp_clip
ssp_clip proc	x1:word, y1:word, x2:word, y2:word, vofs:word

	mov	ax,x1
	shr	ax,3
	mov	cs:ssp_clpx1,ax
	mov	ax,x2
	shr	ax,3
	inc	ax
	mov	cs:ssp_clpx2,ax
	;
	mov	ax,y1
	shr	ax,1				; virtual 400line mode
	mov	cs:ssp_clpy1,ax
	mov	ax,y2
	shr	ax,1				; virtual 400line mode
	inc	ax
	mov	cs:ssp_clpy2,ax
	;
	mov	ax,vofs
	mov	cs:ssp_vofs,ax
	ret
	endp



	;	sprite work set ( set xx=-2 to erase )
	;		ssp_set( int sp_no, int xx, int yy, int chr_no );
	;
	public	ssp_set
ssp_set	proc	arg1:WORD , arg2:WORD , arg3:WORD , arg4:WORD
	;
	mov	ax,arg1
	ssp_calq
	mov	dx,cs:[bx+s_xx]
	;
	mov	ax,arg2
	mov	cs:[bx+s_xx],ax
	mov	ax,arg3
	mov	cs:[bx+s_yy],ax
	mov	ax,arg4
	mov	cs:[bx+s_chr],ax
	;
	cmp	dx,-1
	jnz	sset1
	;
	mov	cs:[bx+s_last],dx
sset1:
	ret
	endp



	;	software sprite execute ( pass-1 )
	;		ssp_exec();
	;
	public	ssp_exec
ssp_exec proc
	push	si
	push	di
	push	bp
	push	ds
	;
	mov	ax,cs:ssp_seg
	mov	es,ax
	;
	;	wipe sprite table make
	;
	mov	cx,cs:ssp_kazu
	lea	di,ssp_work
	lea	si,ssp_wiptab
sexe3:
	push	cx
	push	di
	mov	dx,cs:[di]
	cmp	dx,-1
	jz	sexe4
	;
	mov	bx,cs:[di+s_last]
	cmp	bx,-1
	jz	sexe4
	;
	mov	cs:[si],bx
	inc	si
	inc	si
	;
	cmp	dx,-2
	jnz	sexe4
	;
	mov	ax,-1
	mov	cs:[di],ax
sexe4:
	pop	di
	pop	cx
	add	di,s_kazz
	loop	sexe3
	;
	mov	ax,-1
	mov	cs:[si],ax			; wipe table end code

	;	put sprites on vram
	;
	mov	ax,cs:ssp_page
	xor	al,1
	out	0a6h,al

	mov	cx,cs:ssp_kazu
	lea	di,ssp_work
sexe1:
	push	cx
	push	di
	mov	ax,cs:[di]		; x axis
	cmp	ax,-1
	jz	sexe2
	;
	mov	dx,ax
	and	dl,6
	shl	dl,2
	mov	dh,dl
	xor	dl,dl
	add	dx,cs:ssp_seg		; H2-dot bit adjust
	mov	es,dx
	;
	mov	dx,cs:[di+s_yy]
	shr	dx,1			; virtual 400line mode
	call	vcalq2			; address calq & axis check
	mov	cs:[di+s_last],si
	;
	mov	ax,cs:[di+s_chr]
	mov	cx,chrsize
	mul	cx			; x chr data block size
	mov	dx,bx
	mov	bx,si
	mov	si,ax
	;
	or	dx,dx
	jz	sexe7
	;
	call	sprput2			; when sprite over the screen
	jmp	short sexe2
sexe7:
	call	sprput
sexe2:
	pop	di
	pop	cx
	add	di,s_kazz
	loop	sexe1
	;
	pop	ds
	pop	bp
	pop	di
	pop	si
	ret
	endp



	;	software sprite execute ( pass-2 )
	;		ssp_exec2();
	;
	public	ssp_exec2
ssp_exec2 proc
	push	si
	push	di
	push	ds
	;
	mov	ax,cs:ssp_page
	out	0a6h,al
	xor	al,1
	out	0a4h,al
	;
	;	wipe sprites of last entry ( from wipe table )
	;
	mov	cx,cs:ssp_kazu
	lea	di,ssp_wiptab
sexe5:
	mov	bx,cs:[di]
	cmp	bx,-1
	jz	sexe6
	;
	call	sprwip
	inc	di
	inc	di
	jmp	short sexe5
sexe6:
	;	page entry change
	;
	mov	ax,cs:ssp_page
	xor	ax,1
	out	0a6h,al
	mov	cs:ssp_page,ax

	pop	ds
	pop	di
	pop	si
	ret
	endp



	;	software sprite wipe ( for MOS routine )
	;		ssp_wipe( int wipe_adr );
	;
	public	ssp_wipe
ssp_wipe	proc	arg1:WORD

	push	si
	push	di
	push	ds
	;
	mov	ax,cs:ssp_page
	out	0a6h,al
	;
	mov	bx,arg1
	cmp	bx,-1
	jz	nosspwip
	call	sprwip

nosspwip:
	pop	ds
	pop	di
	pop	si
	ret
	endp



	;	sprite collision check
	;		ssp_hit( int chk_no, int start_no, int end_no );
	;
	public	ssp_hit
ssp_hit	proc	arg1:WORD , arg2:WORD , arg3:WORD
	;
	push	di
	push	si
	mov	di,-1
	mov	ax,arg1
	ssp_calq
	mov	cx,cs:[bx+s_xx]
	mov	dx,cs:[bx+s_yy]
	cmp	cx,-1
	jz	sphov
	add	cx,spxh
	add	dx,spyh
	;
	mov	ax,arg2
	push	ax
	ssp_calq
	pop	si
sphlp:
	mov	ax,cs:[bx]
	cmp	ax,-1
	jz	sphiv
	;
	cmp	ax,cx
	jnc	sphiv
	add	ax,spxh+spxh2
	cmp	ax,cx
	jc	sphiv
	;
	mov	ax,cs:[bx+s_yy]
	cmp	ax,dx
	jnc	sphiv
	add	ax,spyh+spyh2
	cmp	ax,dx
	jc	sphiv
	;
	mov	di,si
	jz	sphov
sphiv:
	cmp	si,arg3
	jz	sphov
	;
	add	bx,s_kazz
	inc	si
	jmp	short sphlp
	;
sphov:
	mov	ax,di
	pop	si
	pop	di
	ret
	endp



	;	sprite put on vram (linear)
	;		ssp_putv( int xx, int yy, int adr, int seg );
	;
	public	ssp_putv
ssp_putv proc	arg1:WORD , arg2:WORD , arg3:WORD , arg4:WORD
	push	si
	push	di
	push	bp
	push	ds
	;
	mov	ax,arg1
	mov	dx,arg2
	call	vcalq
	mov	bx,si
	;
	mov	si,arg3
	mov	ax,arg4
	mov	es,ax
	;
	call	sprput
	;
	pop	ds
	pop	bp
	pop	di
	pop	si
	ret
	endp


	;	put character macro
	;		 ( bx/vram adr(DS) si/data buffer(ES) )
	;
put48m	macro
	mov	dx,es:[si]
	mov	bp,dx
	not	dx
	inc	si
	inc	si
	;
	mov	ax,vram_b
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx+8000h]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx+8000h],ax
	inc	si
	inc	si
	mov	ax,vram_g
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	mov	ax,vram_e
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	ds:[bx],ax
	inc	si
	inc	si
	endm


	;	put character macro ( to buffer )
	;		 ( bx/vram adr(DS) si/data buffer(ES) )
	;
putbfm	macro
	mov	dx,es:[si]
	mov	bp,dx
	not	dx
	inc	si
	inc	si
	;
	mov	ax,vram_b
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	cs:ssp_vdb,ax
	inc	si
	inc	si
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx+8000h]
	and	ax,bp
	or	ax,cx
	mov	cs:ssp_vdr,ax
	inc	si
	inc	si
	mov	ax,vram_g
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	cs:ssp_vdg,ax
	inc	si
	inc	si
	mov	ax,vram_e
	mov	ds,ax
	mov	cx,es:[si]
	and	cx,dx
	mov	ax,ds:[bx]
	and	ax,bp
	or	ax,cx
	mov	cs:ssp_vde,ax
	inc	si
	inc	si
	endm


	;	put character macro ( 1st buffer )
	;		 ( bx/vram adr(DS) si/data buffer(ES) )
	;
put1st	macro
	mov	ax,vram_b
	mov	ds,ax
	mov	dx,cs:ssp_vdb
	mov	ds:[bx],dl
	mov	dx,cs:ssp_vdr
	mov	ds:[bx+8000h],dl
	mov	ah,high vram_g
	mov	ds,ax
	mov	dx,cs:ssp_vdg
	mov	ds:[bx],dl
	mov	ah,high vram_e
	mov	ds,ax
	mov	dx,cs:ssp_vde
	mov	ds:[bx],dl
	endm


	;	put character macro ( 2nd buffer )
	;		 ( bx/vram adr(DS) si/data buffer(ES) )
	;
put2nd	macro
	mov	ax,vram_b
	mov	ds,ax
	mov	dx,cs:ssp_vdb
	mov	ds:[bx],dh
	mov	dx,cs:ssp_vdr
	mov	ds:[bx+8000h],dh
	mov	ah,high vram_g
	mov	ds,ax
	mov	dx,cs:ssp_vdg
	mov	ds:[bx],dh
	mov	ah,high vram_e
	mov	ds,ax
	mov	dx,cs:ssp_vde
	mov	ds:[bx],dh
	endm



sprput	proc near

	mov	di,24
spulp:
	put48m
	inc	bx
	inc	bx
	put48m
	inc	bx
	inc	bx
	put48m
	;
	add	bx,80-4
	dec	di
	or	di,di
	jz	spued
	jmp	spulp
spued:
	ret
	endp



	;	put character
	;		 ( bx/vram adr(DS) si/data buffer(ES) )
	;		 ( current axis on cs:ssp_ovx,ssp_ovy )
	;
sprput2	proc near

	mov	di,24
spulp2:
	mov	ax,cs:ssp_ovmx
	mov	cs:ssp_ovx,ax

	;	y-axis check
	;
	mov	ax,cs:ssp_ovy
	cmp	ax,cs:ssp_clpy1
	jnc	spulp3

	add	bx,80					; when over y-axis
	add	si,30
	jmp	nxtln
spulp3:
	cmp	ax,cs:ssp_clpy2
	jc	spulp4
	jmp	spued2


spulp4:
	;	1st byte put
	;
	putbfm
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo1
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo1
	;
	put1st
nxtgo1:
	inc	bx
	inc	cs:ssp_ovx

	;	2nd byte put
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo2
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo2
	;
	put2nd
nxtgo2:
	inc	bx
	inc	cs:ssp_ovx


	;	3rd byte put
	;
	putbfm
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo3
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo3
	;
	put1st
nxtgo3:
	inc	bx
	inc	cs:ssp_ovx

	;	4th byte put
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo4
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo4
	;
	put2nd
nxtgo4:
	inc	bx
	inc	cs:ssp_ovx


	;	5th byte put
	;
	putbfm
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo5
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo5
	;
	put1st
nxtgo5:
	inc	bx
	inc	cs:ssp_ovx

	;	6th byte put
	;
	mov	ax,cs:ssp_ovx
	cmp	ax,cs:ssp_clpx1
	jc	nxtgo6
	cmp	ax,cs:ssp_clpx2
	jnc	nxtgo6
	;
	put2nd
nxtgo6:
	;inc	bx
	;inc	cs:ssp_ovx

	add	bx,80-5

nxtln:
	;	next line
	;
	inc	cs:ssp_ovy
	dec	di
	or	di,di
	jz	spued2
	jmp	spulp2
spued2:
	ret
	endp



	;	wipe character
	;		 ( bx/vram adr. )
	;
sprwip	proc near

	cmp	bx,08000h
	jc	chkw1
chkw0:
	add	bx,80
	cmp	bx,08000h			; upper screen over check
	jnc	chkw0
	jmp	short chkw2
chkw1:
	cmp	bx,14160			; lower screen over check
	jc	chkw2
	sub	bx,80
	jmp	short chkw1
chkw2:
	mov	ax,vram_b
	mov	ds,ax
	push	bx
	call	wipsub
	pop	bx
	mov	ax,vram_r
	mov	ds,ax
	push	bx
	call	wipsub
	pop	bx
	mov	ax,vram_g
	mov	ds,ax
	push	bx
	call	wipsub
	pop	bx
	mov	ax,vram_e
	mov	ds,ax
	call	wipsub
	ret
wipsub:
	mov	cx,24
wiplp:
	mov	ax,ds:[bx+16000]
	mov	ds:[bx],ax
	inc	bx
	inc	bx
	mov	ax,ds:[bx+16000]
	mov	ds:[bx],ax
	inc	bx
	inc	bx
	mov	ax,ds:[bx+16000]
	mov	ds:[bx],ax
	add	bx,80-4
	loop	wiplp
	retn
	endp


	;----------------------------------------------------------------
	;
	;	text routines for mjp
	;
	;----------------------------------------------------------------

tvram	equ	0a000h

	;	text scroll ->
	;		troll( int xx, int yy, int sx, int sy );
	;
	public	troll
troll	proc	xx:word,yy:word,sx:word,sy:word
	push	ds
	push	si
	push	di
	;
	mov	ax,tvram
	mov	ds,ax
	;
	mov	ax,xx
	mov	dx,yy
	call	tcalq
	;
	mov	dx,sy
trl1:
	mov	si,bx
	mov	cx,sx
	dec	cx
trl2:
	mov	ax,ds:[bx+2]
	mov	ds:[bx],ax
	inc	bx
	inc	bx
	loop	trl2
	xor	ax,ax
	mov	ds:[bx],ax
	;
	mov	bx,si
	add	bx,160
	dec	dx
	or	dx,dx
	jnz	trl1
	;
	pop	di
	pop	si
	pop	ds
	ret
	endp


	;	text character get
	;		tget( int xx, int yy );
	;
	public	tget
tget	proc	xx:word,yy:word
	mov	ax,tvram
	mov	es,ax
	mov	ax,xx
	mov	dx,yy
	call	tcalq
	mov	ax,es:[bx]
	ret
	endp


	;	pole character on text
	;		tpole( int xx, int yy, int chr_no, int clen, int plus );
	;
	public	tpole
tpole	proc	xx:word,yy:word,cnum:word,clen:word,plus:word
	push	ds
	;
	mov	ax,tvram
	mov	ds,ax
	mov	ax,xx
	mov	dx,yy
	call	tcalq
	mov	ax,cnum
	mov	cx,clen
	mov	dx,plus
tpl1:
	mov	ds:[bx],ax
	add	bx,dx
	loop	tpl1
	;
	pop	ds
	ret
	endp


	;	set GDC y-dot counter
	;		gdc_ymul( int y_dot );
	;
	public	gdc_ymul
gdc_ymul	proc	y_dot:word
	mov	ax,04bh
	call	gdccom
	mov	ax,0c0h
	mov	cx,y_dot
	add	ax,cx
	call	gdcprm
	ret
	endp


	;	set GDC clock
	;		int gdc_clock( int clock );
	;			clock  : 0=2.5MHz / 1=5MHz
	;			result : old clock status
	;
	public	gdc_clock
gdc_clock	proc	arg1:word

		push	si
		push	di
		push	ds
		mov	ax,arg1
		xor	ah,ah
		or	al,al
		jz	gdcsel_ov
		mov	al,00100000b
gdcsel_ov:
		mov	dx,ax
		;
		xor	ax,ax
		mov	ds,ax
		mov	al,byte ptr ds:[054dh]
		push	ax
		push	dx
		or	al,00100000b
		mov	byte ptr ds:[054dh],al
		;
		mov	ah,42h
		mov	ch,01000000b
		int	18h			;200lineﾓｰﾄﾞ(2.5MHz)
		;
		pop	dx
		mov	al,byte ptr ds:[054dh]
		and	al,11011111b
		or	al,dl
		mov	byte ptr ds:[054dh],al
		;
		mov	ah,42h
		mov	ch,11000000b
		int	18h			;400lineﾓｰﾄﾞ(2.5MHz/5MHz)
		;
		pop	ax
		and	al,00100000b
		jz	gdcres_ov
		mov	al,1
gdcres_ov:
		;
		pop	ds
		pop	di
		pop	si
		ret
		endp


	;----------------------------------------------------------------
	;
	;	basic hardware subroutines
	;
	;----------------------------------------------------------------


	;-------------------------------------------------------------
	;	vram adr. calq2
	;		ax( x/0-639 ),dx( y/0-399 ) -> si (x&7=cx)
	;		スプライトが画面はみ出しをする可能性もチエック
	;		bx==0 : 通常	bx>0 : はみ出し
	;
	;-------------------------------------------------------------
vcalq2	proc near

	xor	bx,bx					; reset over flag

	mov	cx,ax
	and	cx,7
	shr	ax,3

	cmp	ax,cs:ssp_clpx1				; left over check
	jnc	vqov1
	jmp	short vqov5
vqov1:
	mov	si,cs:ssp_clpx2
	sub	si,6
	cmp	ax,si					; right over check
	jnc	vqov5
	cmp	dx,cs:ssp_clpy1				; upper over check
	jnc	vqov2
vqov5:
	inc	bx					; when over axis
	mov	cs:ssp_ovmx,ax
	mov	cs:ssp_ovx,ax
	mov	cs:ssp_ovy,dx
	jmp	short vqov4

vqov2:
	mov	si,cs:ssp_clpy2
	sub	si,24
	cmp	dx,si					; lower over check
	jnc	vqov5
vqov4:

	mov	si,ax
	shl	dx,4
	add	si,dx
	shl	dx,2
	add	si,dx
	add	si,cs:ssp_vofs
	ret
	endp


	;---------------------------------------------------------
	;	vram adr. calq
	;		ax( x/0-639 ),dx( y/0-399 ) -> si (x&7=cx)
	;---------------------------------------------------------
vcalq	proc near
	mov	cx,ax
	and	cx,7
	shr	ax,3
	mov	si,ax
	shl	dx,4
	add	si,dx
	shl	dx,2
	add	si,dx
	add	si,cs:ssp_vofs
	ret
	endp


	;----------------------------------------------
	;	text vram adr. calq
	;		ax( x/0-79 ),dx( y/0-24 ) -> bx
	;----------------------------------------------
tcalq	proc near
	shl	dx,5
	mov	bx,dx
	shl	dx,2
	add	bx,dx
	add	bx,ax
	add	bx,ax
	ret
	endp


GDC_STAT	equ	0a0h
GDC_POUT	equ	0a0h
GDC_COUT	equ	0a2h

	;
	;ＧＤＣコマンド送出
	;		al = COMMAND

GDCCOM	proc	near
	mov	ah,al
gdc_com_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_com_l1
	mov	al,ah
	out	GDC_COUT,al
	ret
	endp

	;
	;ＧＤＣパラメータ送出（バイト）
	;		al = PARAM (BYTE)

GDCPRM	proc	near
	mov	ah,al
gdc_out_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_out_l1
	mov	al,ah
	out	GDC_POUT,al
	ret
	endp

	;
	;ＧＤＣパラメータ送出（ワード）
	;		ax = PARAM (WORD)
GDCPRMW	proc	near
	push	ax
	call	GDCPRM
	pop	ax
	mov	al,ah
	call	GDCPRM
	ret
	endp


	;----------------------------------------------
	;	some useful routines for GRCG
	;----------------------------------------------


	;  TCR TDW mode on
	;
Grcgon	PROC	near
		mov	al,080h		; Grcg TCR TDW mode
		call	GrcgMode
		ret
	ENDP

	;  RMW mode on
	;
Grcgon2	PROC	near
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

	;  GRCG off
	;
Grcgoff	PROC	near
		xor	al,al
		call	GrcgMode
		ret
	ENDP

	; set GRCG color tile register to color al(0-15)
	;
grcgcolor	PROC near
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




	;----------------------------------------------------------------
	;96h,eah

	END


