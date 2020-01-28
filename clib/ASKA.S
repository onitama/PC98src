
	;
	;ÇêÇÑÇUìWäJñ{ëÃ
	;
	;			ÇPÇXÇXÇQîNÇPåéÇQÇVì˙

	.model	small
	.186

testad	equ	0
BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h


S_FRAME STRUC
	BPSAVE	DW	?
	RETADD	DW	?
	DATA1	DW	?
	DATA2	DW	?
	DATA3	DW	?
	DATA4	DW	?
S_FRAME ENDS


_TEXT	segment	WORD public 'CODE'
	ASSUME	CS:_TEXT
	;
	PUBLIC	_ask_open


_ask_open	proc

	PUSH BP
	MOV BP,SP
	MOV AX,[BP].DATA2
	MOV CS:VRAM_OFS,AX
	MOV AX,[BP].DATA1

	push di
	push si

	mov es,ax
	mov	cs:TENKAI_SEG,es
	 pusha
	 push	ds
	 push	es

	call	HEADER_RESTORE
	call	HEADER_CHECK
	jc	tenkai_je

	mov	ax,cs:TENKAI_SEG
	mov	ds,ax
	mov	si,30h
	call	ten1
tenkai_je:
	 pop	es
	 pop	ds
	 popa

	pop	si
	pop	di
	pop	bp
	ret


HEADER_RESTORE:
	mov	ax,cs
	mov	es,ax
	mov	ax,cs:TENKAI_SEG
	mov	ds,ax
	lea	di,HEADER
	mov	si,0
	mov	cx,10h
	rep	movsb
	ret
HEADER_CHECK:
	mov	ax,cs
	mov	ds,ax
	mov	ax,cs:TENKAI_SEG
	mov	es,ax
	lea	si,HEADER_WORD
	mov	di,0
	mov	cx,3
h_check_l1:
	mov	al,cs:[si]
	cmp	es:[di],al
	jnz	HEADER_ERROR
	inc	si
	inc	di
	loop	h_check_l1
	ret
HEADER_ERROR:
		;ÇoÇcÇUÉtÉHÅ[É}ÉbÉgÇ≈ñ≥Ç¢Ç∆Ç´
	stc
	ret
	
ten1:
	mov	ax,cs
	mov	es,ax
	mov	cs:PLANE_WORK,0
	mov	ax,cs:OFFSET_POSI_Y
	shl	ax,4
	mov	bx,ax
	shl	ax,2
	add	ax,bx
	add	ax,cs:OFFSET_POSI_X
	add	ax,cs:VRAM_OFS
	mov	cs:GRAM_ADDRESS,ax
	
	mov	al,cs:XLEN
	mov	ah,0
	mov	cs:SCREEN_XLEN,ax
	add	ax,cs:OFFSET_POSI_X
	cmp	ax,80+1
	jc	ten1_j0_j1
	sub	ax,80
	sub	cs:SCREEN_XLEN,ax
ten1_j0_j1:
	mov	ax,cs:YLEN
	mov	cs:SCREEN_YLEN,ax
	add	ax,cs:OFFSET_POSI_Y
	cmp	ax,400+1
	jc	ten1_j0_j2
	sub	ax,400
	sub	cs:SCREEN_YLEN,ax
ten1_j0_j2:
	mov	ax,cs:SCREEN_XLEN
	mov	cs:XLEN_WORK,al
	mov	es,cs:PLANE_B_SEG
ten1_l2:
	mov	di,cs:GRAM_ADDRESS
	mov	cx,cs:YLEN
ten1_l1:
	mov	al,ds:[si]
	inc	si
	
	 push	ax
	mov	bh,0
	mov	bl,al
	shr	bl,3
	and	bl,0feh
	mov	bx,word ptr cs:[bx+JUMP_ADR]
	 pop	ax
	jmp	cs:bx
	
	
	
;ten1_j1_0000
;ten1_j1_FFFF
;ten1_j1_AA55
;ten1_j1_0055
;ten1_j1_00AA
;ten1_j1_FF55
;ten1_j1_FFAA
;ten1_j3			;ÇPÉoÉCÉgÇÃòAë±
;ten1_j2			;ïsòAë±
;ten1_j4			;ÇQÉoÉCÉgÇÃòAë±
;ten1_j5			;ÇaÇ∆ìØÇ∂
;ten1_j6			;ÇaÇÃîΩì]
;ten1_j7			;ÇqÇ∆ìØÇ∂
;ten1_j8			;ÇqÇÃîΩì]
;ten1_ja			;ÇfÇ∆ìØÇ∂
;ten1_jb			;ÇfÇÃîΩì]
	
	
JUMP_ADR:
	dw	ten1_j1_0000,ten1_j1_FFFF,ten1_j1_AA55,ten1_j1_0055
	dw	ten1_j1_00AA,ten1_j1_FF55,ten1_j1_FFAA,ten1_j3
	dw	ten1_j2,ten1_j4,ten1_j5,ten1_j6
	dw	ten1_j7,ten1_j8,ten1_ja,ten1_jb
	
	;
	;
	;
	;
ten1_j1_0000:
	mov	bx,0
	jmp	ten1_j1
ten1_j1_FFFF:
	mov	bx,0FFFFh
	jmp	ten1_j1
ten1_j1_AA55:
	mov	bx,0AA55h
	jmp	ten1_j1
ten1_j1_0055:
	mov	bx,0055h
	jmp	ten1_j1
ten1_j1_00AA:
	mov	bx,00AAh
	jmp	ten1_j1
ten1_j1_FF55:
	mov	bx,0FF55h
	jmp	ten1_j1
ten1_j1_FFAA:
	mov	bx,0FFAAh
	jmp	ten1_j1
	
ten1_j1:
	call	LENGTH_GET
ten1_j11:
	mov	ah,0
	 push	ax
	 push	cx
	mov	cx,ax
	mov	ax,bx
ten1_j11_l1:
	stosb
	add	di,79
	loop	ten1_j11_l2
	jmp	ten1_j11_j1
ten1_j11_l2:
	mov	es:[di],ah
	add	di,80
	loop	ten1_j11_l1
ten1_j11_j1:
	 pop	cx
	 pop	ax
	sub	cx,ax
	jmp	ten1_j9
ten1_j2:
	mov	ah,0
	call	LENGTH_GET
	test	al,al
	jnz	ten1_j21
	mov	cx,cs:YLEN
ten1_j2_l1:
	movsb
	add	di,79
	loop	ten1_j2_l1
	jmp	ten1_j9
ten1_j21:
	 push	cx
	mov	cx,ax
ten1_j21_l1:
	movsb
	add	di,79
	loop	ten1_j21_l1
	 pop	cx
	sub	cx,ax
	jmp	ten1_j9
ten1_j3:
	call	LENGTH_GET
	mov	bl,ds:[si]
	inc	si
	mov	bh,bl
	jmp	ten1_j11
ten1_j4:
	call	LENGTH_GET
	mov	bx,ds:[si]
	add	si,2
	jmp	ten1_j11
ten1_j5:
	mov	bx,cs:PLANE_B_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_j6:
	mov	bx,cs:PLANE_B_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
ten1_j7:
	mov	bx,cs:PLANE_R_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_j8:
	mov	bx,cs:PLANE_R_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
ten1_ja:
	mov	bx,cs:PLANE_G_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_jb:
	mov	bx,cs:PLANE_G_SEG
	call	LENGTH_GET
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
	
ten1_j51_l1:
	 push	ds
	mov	ds,bx
ten1_j51_l3:
	test	dl,dl
	jz	ten1_j51_l4
ten1_j51_l2:
	mov	dh,dl
	xor	dh,ds:[di]
	mov	es:[di],dh
	add	di,80
	dec	ah
	jnz	ten1_j51_l2
	sub	cx,ax
	 pop	ds
	jmp	ten1_j9
ten1_j51_l4:
	mov	dh,ds:[di]
	mov	es:[di],dh
	add	di,80
	dec	ah
	jnz	ten1_j51_l4
	sub	cx,ax
	 pop	ds
	jmp	ten1_j9
ten1_j9:
	jc	ten1_j999		;îOÇÃÇΩÇﬂ
	test	cx,cx
	jnz	ten1_l1
	jmp	ten1_j999
ten1_j999:
	cmp	si,0c000h
	jc	ten1_j91
	mov	ax,ds
	add	ax,0800h
	mov	ds,ax
	sub	si,8000h
ten1_j91:
	inc	cs:PLANE_WORK
	mov	al,cs:PLANE_WORK
	cmp	al,1
	jz	ten1_j91_R
	cmp	al,2
	jz	ten1_j91_G
	cmp	al,3
	jz	ten1_j91_E
	
	mov	cs:PLANE_WORK,0
	inc	cs:GRAM_ADDRESS
	dec	cs:XLEN_WORK
	mov	es,cs:PLANE_B_SEG
	jnz	ten1_l2
	ret
ten1_j91_R:
	mov	es,cs:PLANE_R_SEG
	jmp	ten1_l2
ten1_j91_G:
	mov	es,cs:PLANE_G_SEG
	jmp	ten1_l2
ten1_j91_E:
	mov	es,cs:PLANE_E_SEG
	jmp	ten1_l2

LENGTH_GET:
	and	al,0fh
	jnz	len_get_j1
	mov	al,ds:[si]		;í∑Ç≥
	inc	si
len_get_j1:
	ret


VRAM_OFS	dw	0

PLANE_WORK	db	0
GRAM_ADDRESS	dw	0

XLEN_WORK	db	0
TENKAI_SEG	dw	0

OFFSET_POSI_X	dw	0
OFFSET_POSI_Y	dw	0
SCREEN_XLEN	dw	0
SCREEN_YLEN	dw	0

PLANE_B_SEG	dw	0a800h
PLANE_R_SEG	dw	0b000h
PLANE_G_SEG	dw	0b800h
PLANE_E_SEG	dw	0e000h

HEADER_WORD	db	'-PD'

HEADER		db	'-PD6-'
XLEN		db	80
YLEN		dw	400
KASANE_COLOR	db	0ffh
DATA_END_ADR	dw	0
DATA_END_SEG	db	0
		db	4	dup (0)


	;
	;ÉpÉåÉbÉgê›íË
	;
PALETTE_SET:
	mov	si,10h
PALETTE_SET2:
	mov	cx,16
	mov	bl,0
pal_set_l1:
	mov	al,bl
	out	0a8h,al
	mov	al,es:[si]
	out	0aah,al
	mov	al,es:[si+1]
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	out	0ach,al
	mov	al,es:[si+1]
	and	al,0fh
	out	0aeh,al
	add	si,2
	inc	bl
	loop	pal_set_l1
	ret


_ask_open	endp


_TEXT	ends

	END


