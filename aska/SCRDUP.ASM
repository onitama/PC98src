	;
	;
	;重ね合わせルーチン
	;
	;
	;		１９９２年２月２８日
	;
	;ＣＯＭ形式

	.8086
	
;=========================================================================
; 定数
;=========================================================================

; ファンクションコール関係
MS_DOS		equ	21h	; ＭＳ＿ＤＯＳコールの為の割り込み番号
FC_fmake	equ	3ch
FC_fopen	equ	3dh
FC_fclose	equ	3eh
FC_fread	equ	3fh
FC_fwrite	equ	40h
FC_mopen	equ	48h

;=========================================================================
	

BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h
	
	
code	segment
	assume	cs:code,ds:code
	
	org	0
	
START:
	JMP	main
	
DRAW_SCREEN	db	0		;アクセスページ (0 or 1)
LENGTH_X	db	80		;Ｘ座標の長さ (1~80)
LENGTH_Y	db	200		;Ｙ座標の長さ (1~200)
START_X		db	0		;Ｘ座標先頭値 (0~79)
START_Y		db	0		;Ｙ座標先頭値 (0~199)
DRAW_X		db	0		;描画Ｘ座標 (0~79)
DRAW_Y		db	0		;描画Ｙ座標 (0~199)
DRAW_POSI	db	1		;描画位置 (0 or 1)

main:
	mov	ax,cs
	mov	ds,ax
	
	mov	al,DRAW_SCREEN
	and	al,1
	mov	DRAW_SCREEN,al
	out	0a6h,al
	
	
	mov	al,DRAW_Y
	mov	ah,0
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	di,ax
	shl	ax,1
	shl	ax,1
	add	di,ax
	mov	ah,0
	mov	al,DRAW_X
	add	di,ax
	cmp	DRAW_POSI,0
	jz	kasane_j0
	add	di,80*200
kasane_j0:
	mov	DRAW_ADR,di
	
	mov	al,START_Y
	mov	ah,0
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	mov	di,ax
	shl	ax,1
	shl	ax,1
	add	di,ax
	mov	ah,0
	mov	al,START_X
	add	di,ax
	
	
	mov	ch,0
	mov	cl,LENGTH_Y
kasane_l2:
	 push	cx
	 push	di
	lea	si,DATA_BUFF
	mov	ch,0
	mov	cl,LENGTH_X
	or	cl,1
	shr	cl,1
kasane_l1:
	mov	ax,BANK_B
	mov	es,ax
	mov	bx,es:[di]
	or	bx,es:[di+8000h]
	mov	ax,BANK_G
	mov	es,ax
	or	bx,es:[di]
	mov	ax,BANK_E
	mov	es,ax
	or	bx,es:[di]
	mov	dx,bx
	xor	dx,0ffffh
	jz	kasane_j3		;スキップ
	xchg	dx,bx
	test	dx,dx
	jz	kasane_j1		;ベタ転送
	
	
	mov	ax,BANK_B
	mov	es,ax
	mov	ax,bx
	and	ax,es:[di+80*200]
	mov	[si],ax
	mov	ax,dx
	and	ax,es:[di]
	or	[si],ax
	
	mov	ax,bx
	and	ax,es:[di+80*200+8000h]
	mov	[si+80],ax
	mov	ax,dx
	and	ax,es:[di+8000h]
	or	[si+80],ax
	
	mov	ax,BANK_G
	mov	es,ax
	mov	ax,bx
	and	ax,es:[di+80*200]
	mov	[si+80*2],ax
	mov	ax,dx
	and	ax,es:[di]
	or	[si+80*2],ax
	
	
	mov	ax,BANK_E
	mov	es,ax
	mov	ax,bx
	and	ax,es:[di+80*200]
	mov	[si+80*3],ax
	mov	ax,dx
	and	ax,es:[di]
	or	[si+80*3],ax
	
	jmp	kasane_j2
kasane_j1:
	mov	ax,BANK_B
	mov	es,ax
	mov	ax,es:[di+80*200]
	mov	[si],ax
	mov	ax,es:[di+8000h+80*200]
	mov	[si+80],ax
	mov	ax,BANK_G
	mov	es,ax
	mov	ax,es:[di+80*200]
	mov	[si+80*2],ax
	mov	ax,BANK_E
	mov	es,ax
	mov	ax,es:[di+80*200]
	mov	[si+80*3],ax
	jmp	kasane_j2
kasane_j3:
	mov	ax,BANK_B
	mov	es,ax
	mov	ax,es:[di]
	mov	[si],ax
	mov	ax,es:[di+8000h]
	mov	[si+80],ax
	mov	ax,BANK_G
	mov	es,ax
	mov	ax,es:[di]
	mov	[si+80*2],ax
	mov	ax,BANK_E
	mov	es,ax
	mov	ax,es:[di]
	mov	[si+80*3],ax
	jmp	kasane_j2
kasane_j2:
	add	di,2
	add	si,2
	loop	kasane_l1
	 pop	di
	 push	di
	mov	al,DRAW_SCREEN
	xor	al,1
	out	0a6h,al
	
	mov	di,DRAW_ADR
	lea	si,DATA_BUFF
	mov	ax,BANK_B
	call	kasane_s1
	mov	ax,BANK_R
	call	kasane_s1
	mov	ax,BANK_G
	call	kasane_s1
	mov	ax,BANK_E
	call	kasane_s1
	add	DRAW_ADR,80
	 pop	di
	
	mov	al,DRAW_SCREEN
	out	0a6h,al
	
	add	di,80
	 pop	cx
	
	loop	kasane_l2

	iret					;EXIT TO BASIC
	
kasane_s1:
	 push	di
	mov	es,ax
	mov	cl,LENGTH_X
	mov	ch,0
	 push	cx
	rep	movsb
	 pop	cx
	add	si,80
	sub	si,cx
	
	 pop	di
	ret
	
DRAW_ADR	dw	0
	
DATA_BUFF:
	
PROGRAM_END:

code	ends
	
	end	START
