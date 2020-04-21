
	;
	;	ASKA format decompress routines for TC
	;			created  1992/1/27 shinwa takeuchi
	;			arranged 1993/5/5  onitama
	;			arranged 1995/7/20 onitama
	;


	.model	small
	.186

BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h

	;===================================================
	;展開ルーチン本体
	;	In <=	es 展開データセグメント
	;		al 重ね合わせ色 
	;		   -1でデータの値を採用
	;		   -2で重ね合わせをしない
	;===================================================

S_FRAME STRUC
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
	MOV AX,[BP+2].DATA1
	mov es,ax
	MOV AX,[BP+2].DATA2
	mov cs:vofs,ax

	push di
	push si
	mov	cs:TENKAI_SEG,es
	mov	al,-1
	mov	cs:KASANE_SPEC,al

	 pusha
	 push	ds
	 push	es
	call	HEADER_RESTORE
	call	HEADER_CHECK
	;
	mov	si,50h				; pix mode start offset
	cmp	ax,1
	jz	tenkx
	or	ax,ax
	jnz	tenkai_je
	;
	mov	si,30h				; normal_pd start offset
tenkx:
	;
	mov	ah,0ffh
	mov	al,cs:KASANE_SPEC
	cmp	al,-1
	jz	tenkai_j1
	cmp	al,-2
	jz	tenkai_j2
	mov	ah,al
tenkai_j2:
	mov	cs:KASANE_COLOR,ah
tenkai_j1:
	mov	ax,cs:TENKAI_SEG
	mov	ds,ax
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
	retn
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
	;
	mov	ax,0
	retn

HEADER_ERROR:
	;
	; PIX format check
	;
	lea	si,HEADER_WORD2
	mov	di,0
	mov	cx,3
h_check_l2:
	mov	al,cs:[si]
	cmp	es:[di],al
	jnz	HEADER_NG
	inc	si
	inc	di
	loop	h_check_l2
	mov	ax,1
	retn

HEADER_NG:
	;		ＰＤ６フォーマットで無いとき
	mov	ax,-1
	retn


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
	add	ax,cs:vofs
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
	
	lea	di,BUFF_B
	mov	ax,cs:SCREEN_XLEN
	mov	cs:XLEN_WORK,al
ten1_l2:
	mov	cx,cs:YLEN
ten1_l1:
	mov	al,ds:[si]
	inc	si
	mov	ah,al
	mov	bx,0
	and	ah,0f0h
	jz	ten1_j1
	mov	bx,0ffffh
	cmp	ah,10h
	jz	ten1_j1
	mov	bx,0aa55h
	cmp	ah,20h
	jz	ten1_j1
	mov	bx,55h
	cmp	ah,30h
	jz	ten1_j1
	mov	bx,0aah
	cmp	ah,40h
	jz	ten1_j1
	mov	bx,0ff55h
	cmp	ah,50h
	jz	ten1_j1
	mov	bx,0ffaah
	cmp	ah,60h
	jz	ten1_j1
	cmp	ah,80h			;不連続
	jz	ten1_j2
	cmp	ah,70h			;１バイトの連続
	jz	ten1_j3
	cmp	ah,90h			;２バイトの連続
	jz	ten1_j4
	cmp	ah,0a0h			;Ｂと同じ
	jz	ten1_j5
	cmp	ah,0b0h			;Ｂの反転
	jz	ten1_j6
	cmp	ah,0c0h			;Ｒと同じ
	jz	ten1_j7
	cmp	ah,0d0h			;Ｒの反転
	jz	ten1_j8
	cmp	ah,0e0h			;Ｇと同じ
	jz	ten1_ja
	cmp	ah,0f0h			;Ｇの反転
	jz	ten1_jb
	;
	;
	;
	;
ten1_j1:
	and	al,0fh
	jnz	ten1_j11
	mov	al,ds:[si]
	inc	si
	cmp	al,0fh
	jc	ten1_jc
ten1_j11:
	mov	ah,0
	 push	ax
	 push	cx
	mov	cx,ax
	mov	ax,bx
	shr	cx,1
	 pushf
	test	cx,cx
	jz	ten1_j11_j2
	rep	stosw
ten1_j11_j2:
	 popf
	jnc	ten1_j11_j1
	stosb
ten1_j11_j1:
	 pop	cx
	 pop	ax
	sub	cx,ax
	jmp	ten1_j9

ten1_j2:
	mov	ah,0
	and	al,0fh
	jnz	ten1_j21
	mov	al,ds:[si]
	inc	si
	test	al,al
	jnz	ten1_j21
	mov	cx,cs:YLEN
	rep	movsb
	jmp	ten1_j9
ten1_j21:
	 push	cx
	mov	cx,ax
	rep	movsb
	 pop	cx
	sub	cx,ax
	jmp	ten1_j9
ten1_j3:
	and	al,0fh
	jnz	ten1_j31
	mov	al,ds:[si]
	inc	si
ten1_j31:
	mov	bl,ds:[si]
	inc	si
	mov	bh,bl
	jmp	ten1_j11
ten1_j4:
	and	al,0fh
	jnz	ten1_j41
	mov	al,ds:[si]
	inc	si
ten1_j41:
	mov	bx,ds:[si]
	add	si,2
	jmp	ten1_j11
ten1_j5:
	lea	bx,BUFF_B
	and	al,0fh
	jnz	ten1_j51
	mov	al,ds:[si]
	inc	si
ten1_j51:
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_j6:
	lea	bx,BUFF_B
	and	al,0fh
	jnz	ten1_j61
	mov	al,ds:[si]
	inc	si
ten1_j61:
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
ten1_j7:
	lea	bx,BUFF_R
	and	al,0fh
	jnz	ten1_j71
	mov	al,ds:[si]
	inc	si
ten1_j71:
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_j8:
	lea	bx,BUFF_R
	and	al,0fh
	jnz	ten1_j81
	mov	al,ds:[si]
	inc	si
ten1_j81:
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
ten1_ja:
	lea	bx,BUFF_G
	and	al,0fh
	jnz	ten1_ja1
	mov	al,ds:[si]
	inc	si
ten1_ja1:
	mov	ah,al
	mov	dl,0
	jmp	ten1_j51_l1
ten1_jb:
	lea	bx,BUFF_G
	and	al,0fh
	jnz	ten1_jb1
	mov	al,ds:[si]
	inc	si
ten1_jb1:
	mov	ah,al
	mov	dl,0ffh
	jmp	ten1_j51_l1
	
ten1_j51_l1:
	 push	di
	sub	di,bx
ten1_j51_l3:
	sub	di,400
	jc	ten1_j52
	jmp	ten1_j51_l3
ten1_j52:
	add	di,400
	add	bx,di
	 pop	di
	test	dl,dl
	jz	ten1_j51_l4
ten1_j51_l2:
	mov	dh,dl
	xor	dh,cs:[bx]
	mov	cs:[di],dh
	inc	di
	inc	bx
	dec	ah
	jnz	ten1_j51_l2
	sub	cx,ax
	jmp	ten1_j9
ten1_j51_l4:
	 push	si
	 push	cx
	 push	ds
	 push	cs
	 pop	ds
	mov	si,bx
	mov	cl,ah
	mov	ch,0
	rep	movsb
	 pop	ds
	 pop	cx
	 pop	si
	mov	ah,0
	sub	cx,ax
	jmp	ten1_j9
	;ｎバイトの連続
ten1_jc:
	mov	ah,al
	mov	al,ds:[si]
	mov	bl,ds:[si+1]
	mov	bh,0
	add	si,2
	 push	ax
	 push	cx
	 push	bx
	mov	cx,ax
	mov	cs:ten1_work1,si
	mov	ah,bl
ten1_jc_l1:
	mov	al,ds:[si]
	mov	cs:[di],al
	inc	si
	inc	di
	dec	ah
	jnz	ten1_jc_j2
	mov	ah,bl
	mov	si,cs:ten1_work1
ten1_jc_j2:
	loop	ten1_jc_l1
	 pop	bx
	mov	si,cs:ten1_work1
	add	si,bx
	 pop	cx
	 pop	ax
	sub	cx,ax
	jmp	ten1_j9
ten1_work1	dw	0
ten1_j9:
	jc	ten1_j999		;念のため
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
	call	TRANS_GRAM
	
	mov	ax,cs
	mov	es,ax
	mov	cs:PLANE_WORK,0
	inc	cs:GRAM_ADDRESS
	lea	di,BUFF_B
	dec	cs:XLEN_WORK
	jnz	ten1_l2
	retn
ten1_j91_R:
	lea	di,BUFF_R
	jmp	ten1_l2
ten1_j91_G:
	lea	di,BUFF_G
	jmp	ten1_l2
ten1_j91_E:
	lea	di,BUFF_E
	jmp	ten1_l2
ten1_j91_s1:
	mov	es,ax
	mov	di,GRAM_ADDRESS
	mov	cx,SCREEN_YLEN
ten1_j91_s1_l1:
	movsb
	add	di,79
	loop	ten1_j91_s1_l1
	retn
TRANS_GRAM:
	cmp	cs:KASANE_COLOR,0ffh
	jnz	trans_j1
	 push	si
	 push	ds
	mov	ax,cs
	mov	ds,ax
	mov	ax,BANK_B
	lea	si,BUFF_B
	call	ten1_j91_s1
	mov	ax,BANK_R
	lea	si,BUFF_R
	call	ten1_j91_s1
	mov	ax,BANK_G
	lea	si,BUFF_G
	call	ten1_j91_s1
	mov	ax,BANK_E
	lea	si,BUFF_E
	call	ten1_j91_s1
	 pop	ds
	 pop	si
	retn
trans_j1:
	 push	si
	mov	di,cs:GRAM_ADDRESS
	mov	cx,cs:SCREEN_YLEN
	lea	si,BUFF_B
trans_s1_l1:
	mov	ah,cs:KASANE_COLOR
	mov	bl,0ffh
	mov	al,cs:[si]
	test	ah,1
	call	trans_s1
	mov	al,cs:[si+400]
	test	ah,2
	call	trans_s1
	mov	al,cs:[si+800]
	test	ah,4
	call	trans_s1
	mov	al,cs:[si+1200]
	test	ah,8
	call	trans_s1
	mov	bh,bl
	xor	bh,0ffh
	mov	dx,bx
	test	dh,dh
	jz	trans_j2
	test	dl,dl
	jz	trans_j3
	
	mov	ax,BANK_B
	mov	bx,0
	call	trans_s2
	mov	ax,BANK_R
	mov	bx,400
	call	trans_s2
	mov	ax,BANK_G
	mov	bx,800
	call	trans_s2
	mov	ax,BANK_E
	mov	bx,1200
	call	trans_s2
	jmp	trans_j2
trans_j3:
	mov	ax,BANK_B
	mov	bx,0
	call	trans_s3
	mov	ax,BANK_R
	mov	bx,400
	call	trans_s3
	mov	ax,BANK_G
	mov	bx,800
	call	trans_s3
	mov	ax,BANK_E
	mov	bx,1200
	call	trans_s3
trans_j2:
	inc	si
	add	di,80
	loop	trans_s1_l1
	 pop	si
	retn
trans_s1:
	jnz	trans_s1_je
	xor	al,0ffh
trans_s1_je:
	and	bl,al
	retn
trans_s2:
	mov	es,ax
	mov	al,es:[di]
	and	al,dl
	mov	ah,cs:[si+bx]
	and	ah,dh
	or	al,ah
	mov	es:[di],al
	retn
trans_s3:
	mov	es,ax
	mov	al,cs:[si+bx]
	mov	es:[di],al
	retn


vofs		dw	0

PLANE_WORK	db	0
GRAM_ADDRESS	dw	0

XLEN_WORK	db	0
;DATA_ADR_BAK	dw	0
;DATA_ADR_BAK2	dw	0
TENKAI_SEG	dw	0

;DATA_ADR_TOP1	dw	0

;LENGTH_B	dw	0
;LENGTH_R	dw	0
;LENGTH_G	dw	0
;COUNT_FLAG	db	0
;KASANE_SPEC	db	0ffh
OFFSET_POSI_X	dw	0
OFFSET_POSI_Y	dw	0
SCREEN_XLEN	dw	0
SCREEN_YLEN	dw	0
;ACCESS_SCREEN	db	0
KASANE_SPEC	db	0

PLANE_B_SEG	dw	0a800h
PLANE_R_SEG	dw	0b000h
PLANE_G_SEG	dw	0b800h
PLANE_E_SEG	dw	0e000h

WORK:
		db	2000 dup (0)

BUFF1		equ	WORK
BUFF_B		equ	WORK+400
BUFF_R		equ	WORK+800
BUFF_G		equ	WORK+1200
BUFF_E		equ	WORK+1600

HEADER_WORD	db	'-PD'
HEADER_WORD2	db	'-PX'

HEADER		db	'-PD6-'
XLEN		db	80
YLEN		dw	400
KASANE_COLOR	db	0ffh
DATA_END_ADR	dw	0
DATA_END_SEG	db	0
		db	4	dup (0)

_ask_open	endp

