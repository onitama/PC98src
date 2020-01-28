;---------------------------------------------------
;
;	extend graphic system routines for turbo C++
;	for screen mask,get,put
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
	;	graphic screen copy ( scroll )
	;--------------------------------------------

	PUBLIC	g_copy3
g_copy3	proc	xx:WORD,yy:WORD,sx:WORD,sy:WORD,py:WORD

	push	si
	push	di
	;
	mov	ax,xx
	mov	dx,yy
	call	vcalq
	;
	mov	ax,py
	mov	dx,80
	mul	dx
	mov	di,ax
	;
	mov	ax,sx
	shr	ax,4
	mov	dx,ax
	mov	cx,sy
	;
	mov	ax,vram_b
	mov	es,ax
	;
	push	cx
	push	dx
	call	scsub
	pop	dx
	pop	cx
	;
	mov	ax,vram_r
	mov	es,ax
	;
	push	cx
	push	dx
	call	scsub
	pop	dx
	pop	cx
	;
	mov	ax,vram_g
	mov	es,ax
	;
	push	cx
	push	dx
	call	scsub
	pop	dx
	pop	cx
	;
	mov	ax,vram_e
	mov	es,ax
	call	scsub
	;
	pop	di
	pop	si
	ret


scsub:
	mov	bx,si
gcc1:
	push	cx
	push	bx
	mov	cx,dx
gcc2:
	mov	ax,es:[bx+di]
	mov	es:[bx],ax
	inc	bx
	inc	bx
	loop	gcc2
	;
	pop	bx
	pop	cx
	add	bx,80
	loop	gcc1
	retn
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
	mov	es:[0495h],al	; GRCG mode ÉfÅ[É^äiî[
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
		mov	di,0496h	; Grcg Tile register äiî[ÉAÉhÉåÉX
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

	END


