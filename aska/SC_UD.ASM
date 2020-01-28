	;
	;
	;ＧＤＣスクロールプログラム
	;
	;
	;		１９９１年１２月２９日
	;
	;ＣＯＭ形式

	.8086
	
;=========================================================================
; 定数
;=========================================================================

BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h
	
	
code	segment
	assume	cs:code,ds:code
	
	org	100h
	
START:
	jmp	DOS_USE
	jmp	main
	jmp	RECOVER
	jmp	TRANS
	
SCROLL_STEP		dw	1		;１回のスクロール幅
SCROLL_LENGTH		dw	400		;スクロール幅
SCROLL_DIRECTION	dw	0		;0 = UP ,other = DOWN
SCREEN_LINE_COUNTER	dw	0
SCREEN_GDC_ADDR		dw	0
	
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
	ret
	
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
	ret
	


GDC_STAT	equ	0a0h
GDC_POUT	equ	0a0h
GDC_COUT	equ	0a2h
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
	ret
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
	ret
	;
	;ＧＤＣパラメータ送出（ワード）
	;		ax = PARAM (WORD)
GDC_PARAW_OUT:
	 push	ax
	call	GDC_PARA_OUT
	 pop	ax
	mov	al,ah
	call	GDC_PARA_OUT
	ret

VWAIT:
vwait_l1:
	in	al,0a0h
	test	al,00100000b
	jnz	vwait_l1
vwait_l2:
	in	al,0a0h
	test	al,00100000b
	jz	vwait_l2
	ret
	
DOS_USE:
	mov	ax,cs
	mov	ds,ax
	mov	ss,ax
	mov	sp,2000h
	call	main
	call	RECOVER
	mov	ax,4c00h
	int	21h
	
main:
	mov	ax,cs
	mov	ds,ax
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
	ret
	
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
	ret
	
TRANS_SCREEN_TO_BUFFER:
	 push	ds
	mov	si,dx
	mov	ds,ax
	mov	bx,cs
	mov	es,bx
	mov	cx,40
	rep	movsw
	 pop	ds
	ret
	
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
	ret
to_screen_j1:		;画面をまたぐ時
	mov	cx,24
	rep	movsw
	mov	di,0
	mov	cx,16
	rep	movsw
	 pop	ds
	ret
TRANS_BUFFER_TO_SCREEN_P4:
	 push	cx
	lea	si,BUFFER
	mov	ax,BANK_B
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_R
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_G
	call	TRANS_BUFFER_TO_SCREEN
	mov	ax,BANK_E
	call	TRANS_BUFFER_TO_SCREEN
	 pop	cx
	ret
TRANS_SCREEN_TO_BUFFER_P4:
	 push	cx
	lea	di,BUFFER
	mov	ax,BANK_B
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_R
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_G
	call	TRANS_SCREEN_TO_BUFFER
	mov	ax,BANK_E
	call	TRANS_SCREEN_TO_BUFFER
	 pop	cx
	ret
	
ACCESS_PAGE0:
	mov	al,0
	jmp	ACCESS_PAGE_j1
ACCESS_PAGE1:
	mov	al,1
ACCESS_PAGE_j1:
	out	0a6h,al
	ret
	
	;
	;表示を直す
	;
RECOVER:
	mov	ax,cs
	mov	ds,ax
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
	ret

	;
	;表画面から裏画面へ転送する
	;
TRANS:
	mov	ax,cs
	mov	ds,ax
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
	ret
	
BUFFER			db	0
;BUFFER			db	80*4 dup (?)

PROGRAM_END:

code	ends
	
	end	START
	
