;--------------------------------------------------------------
;		graphic systems ( mini system ) 
;				from C ( small model )
;
;  ginit(Lines,SPage,Sswitch);	screen initalize and get status
;  gcls(Color);			screen clear
;  t_off();			text screen off
;  t_on();			text screen on
;  t_cls();			text screen clear
;
;--------------------------------------------------------------

	.MODEL small,C
	.186

;-------------------------------------------------
;
;	graphic system routines ( mini version )
;			Started 1992/6 onitama
;				1993/4 onitama
;
;-------------------------------------------------

	.CODE

;-------------------------------------------------
;	subroutines for small model
;-------------------------------------------------

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


;-------------------------------------------------
;	subroutines for graphics screen
;-------------------------------------------------


	PUBLIC	ginit,gcls,gcls2,t_on,t_off,t_cls


gcls2	proc
	pushf

	MOV AL,0
	OUT 07CH,AL
	CLD

	MOV AX,0A800H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0B000H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0B800H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	MOV AX,0E000H
	MOV ES,AX
	MOV DI,0
	MOV CX,16384
	MOV AX,0
	REP STOSW

	popf
	ret

	endp


t_cls	proc

	pushf

	MOV AX,0A000H
	MOV ES,AX
	MOV DI,0
	MOV CX,120*25
	MOV AX,0
	REP STOSW

	popf
	ret

	endp



t_off	proc
	pushf
	mov	ah,0DH
	int	018H
	popf
	ret
	endp

t_on	proc
	pushf
	mov	ah,0CH
	int	018H
	popf
	ret
	endp


	PUBLIC GrcgReadSet,GrcgSet
	PUBLIC GrcgReset,GrcgColor

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� TCR TDW ���[�h�ݒ�
;  void GrcgReadSet(void)
;-------------------------------------------------
GrcgReadSet	PROC
		mov	al,080h		; Grcg TCR TDW mode
		call	GrcgMode
		ret
GrcgReadSet	ENDP

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� RMW ���[�h�ݒ�
;  void GrcgSet(void)
;-------------------------------------------------
GrcgSet	PROC	
		mov	al,0C0h		; Grcg RMW mode
		call	GrcgMode
		ret
GrcgSet	ENDP

;---------- GRCG Set subroutine
GrcgMode:
		push	es
		push	0
		pop	es
		pushf
		cli
		out	7Ch,al
		mov	es:[0495h],al	; GRCG mode �f�[�^�i�[
		popf
		pop	es
		retn

;-------------------------------------------------
;  �O���t�B�b�N�`���[�W�� ���Z�b�g
;  void GrcgReset(void)
;-------------------------------------------------
GrcgReset	PROC
		mov	al,0		; Grcg mode off
		call	GrcgMode
		ret
GrcgReset	ENDP

		
;-------------------------------------------------
; �O���t�B�b�N�`���[�W���^�C�����W�X�^�ݒ�		
;  void GrcgColor(int Color)
;  IN  : int Color �^�C�����W�X�^�ɐݒ肷��F�ԍ�
;-------------------------------------------------

GrcgColor	PROC Color : WORD	; Color = 0�`15
		pushf
		cld
		push	di
		push	es
		mov	di,0496h	; Grcg Tile register �i�[�A�h���X
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	ax,Color
		pushf
		cli
	REPT 4
		ror	al,1
		cbw			; bit = 1 �̂Ƃ� ah = FFh
		xchg	ah,al		; bit = 0 �̂Ƃ� ah = 0 �ƂȂ�
		out	07Eh,al		; Tile register �Ƀf�[�^�Z�b�g
		stosb			; �V�X�e�����[�N�փf�[�^�i�[
		xchg	ah,al
	ENDM
		popf
		pop	es
		pop	di
		popf
		ret
GrcgColor	ENDP



;-------------------------------------------------
;		graphics chip status 
;-------------------------------------------------

	PUBLIC	_gc_set,_egc_set,_board16_set,_gdc_clock


;---------- �O���t�B�b�N�V�X�e���f�[�^�i�[
GSys		PROC
		sub	ax,ax		; ax = 0
		mov	es,ax		; es = 0
		mov	al,es:[054Ch]	; GRCG �L��
		and	al,02h
		shl	al,1
		mov	[_gc_set],al	; GRCG �O���t�B�b�N�`���[�W���[
					; 0 = ����, 1 =	�L��
		mov	al,es:[054Ch]	; 16�F�{�[�h �L��
		and	al,04h
		mov	cl,2
		shr	al,cl
		mov	[_board16_set],al
		mov	al,es:[054Dh]
		mov	dl,al
		and	al,40h		; EGC �L��
		mov	cl,6
		shr	al,cl
		mov	[_egc_set],al	; EGC �G���n���X�gGRCG
					; 0 = ����, 1 =	�L��
		and	dl,04h
		mov	cl,2
		shr	dl,cl		; GDC�N���b�N�𓾂�
		mov	[_gdc_clock],dl	; GDC �N���b�N
					; 0 = 2.5MHz, 1	= 5MHz
		ret
GSys		ENDP


;---------- �O���t�B�b�N�c���C���ݒ�
;    int Line :	0 = 200lines, 1	= 400lines

GraphicLineSet	PROC Line : WORD
		mov	ax,Line
		cmp	ax,0
		jz	lines200
		cmp	ax,1
		jz	lines400
		jmp	SHORT lines_exit

lines200:
		mov	ch,10000000b		; LOWER	COLOR BANK0
		jmp	SHORT lines_go
lines400:
		mov	ch,11000000b		; ALL	COLOR BANK0
lines_go:
		mov	ah,42h
		int	18h			; Graphic BIOS
lines_exit:
		ret
GraphicLineSet	ENDP


;---------- �f�W�^���^�A�i���O�J���[���[�h�ݒ�
;    int ColorMode : 0 = Degital, 1 = Analog

GraphicColorMode PROC ColorMode : WORD
		mov	ax,ColorMode
		out	06Ah,al
		ret
GraphicColorMode ENDP



;-----------------------------------------------------
;	graphics screen initalize
;
;  ginit( int Lines, int SPage , int Sswitch );
;
;  	int Lines      0 = 200 lines	1 = 400 lines
;	int SPage      0 = page 0	1 = page 1
;	int Sswitch    0 = screen off   1 = screen on
;
;-----------------------------------------------------

ginit	PROC Lines:WORD,SPage:WORD,Sswitch:WORD
	pushf
	;
	cli
	call	Gsys
	mov	ax,Lines
	push	ax
	call	GraphicLineSet
	add	sp,2
	;
	mov	ax,1
	push	ax
	call	GraphicColorMode
	add	sp,2
	;
	mov	ax,SPage
	out	0a4h,al
	out	0a6h,al
	;
	mov	cx,4100h
	;
	mov	ax,Sswitch
	cmp	ax,0
	jz	fran
	mov	cx,4000h
fran:
	mov	ax,cx
	int	18h
	;
	popf
	ret

ginit	endp


;-----------------------------------------------------
;  �O���t�B�b�N��ʏ���
;  void	gcls(int Color)
;  IN  : int Color ��ʂ���������F�ԍ�
;-----------------------------------------------------
		
gcls		PROC Color : WORD
		push	di

		mov	ah,41h
		int	18h

		cld
		call	GrcgReadSet 	; TDW ���[�h�Z�b�g
		mov	ax,Color
		push	ax
		call	GrcgColor
		add	sp,2
		sub	di,di		; di = 0
		mov	ax,0A800h	; Plane 0 �Z�O�����g
		mov	es,ax
		mov	cx,80 * 400 / 2	; Plane 0 VRAM �̃o�C�g�� / 2
	rep	stosw			; cx ���[�h��ʂɏ������� ax�͕s��
		call	GrcgReset	; GRCG ���Z�b�g

		mov	ah,40h
		int	18h

		pop	di
		ret
gcls		ENDP




;---------- �{�b�N�X�t�B���T�u���[�`��
;  IN : di = �擪VRAM �A�h���X, cx = �c���C����

BoxFill		PROC
		mov	ax,0A800h
		mov	es,ax
		mov	ax,[lndx]
		or	ax,ax
		js	boxf_1			; ����1word
		jz	boxf_2			; ����2word
;---------- ����3word�ȏ�
boxf_0:		
		mov	bx,[xpats]	;
		mov	dx,[xpate]
		mov	ax,0FFFFh
boxf_01:		
		push	cx
		push	di
		mov	cx,[lndx]
		mov	es:[di],bx
		add	di,2
	rep	stosw
		mov	es:[di],dx
		pop	di
		add	di,80
		pop	cx
		loop	boxf_01
boxf_exit:		
		ret

;---------- ����1word
boxf_1:
		mov	ax,[xpats]
		and	ax,[xpate]
boxf_11:	mov	es:[di],ax
		add	di,80
		loop	boxf_11
		jmp	boxf_exit	

;---------- ����2word
boxf_2:
		mov	ax,[xpats]
		mov	dx,[xpate]
boxf_21:		
		stosw
		mov	es:[di],dx
		add	di,80 - 2
		loop	boxf_21
		jmp	boxf_exit	
BoxFill		ENDP




;---------------------------------------------------------
;  �O���t�B�b�N�{�b�N�X�t�B��
;  void GraphicBoxf(int X1,int Y1,int X2,int Y2,int Color)
;  IN  : int X1,Y1 �{�b�N�X����[���W
;        int X2,Y2 �{�b�N�X�E���[���W
;	 int Color �h��ׂ��F�ԍ�
;----------------------------------------------------------



		PUBLIC GraphicBoxf
GraphicBoxf	PROC X1:WORD,Y1:WORD,X2:WORD,Y2:WORD,Color:WORD
		push	di
		cld
		call	GrcgSet		; RMW ���[�h�ݒ�
		mov	ax,Color
		push	ax
		call	GrcgColor		; GRCG �^�C�����W�X�^�ݒ�
		add	sp,2
		mov	bx,X1			; bx = x1
		mov	dx,X2			; dx = x2
		mov	ax,639
		cmp	bx,ax
		jbe	gboxf_1
		mov	bx,ax
gboxf_1:
		cmp	dx,ax
		jbe	gboxf_2
		mov	dx,ax
gboxf_2:
		cmp	bx,dx
		jbe	not_xchg
		xchg	bx,dx			; X1 > X2 �Ȃ�X1,X2�����ւ���
not_xchg:
		mov	cx,bx
		and	cx,00Fh
		mov	ax,0FFFFh
		shr	ax,cl	
		xchg	ah,al
		mov	[xpats],ax		; ���[�̃r�b�g�f�[�^
		mov	cx,dx
		and	cx,000Fh	
		sub	cx,000Fh
		neg	cx
		mov	ax,0FFFFh
		shl	ax,cl
		xchg	ah,al
		mov	[xpate],ax		; �E�[�̃r�b�g�f�[�^
		shr	bx,4			; bx = x1
		mov	di,bx
		shr	dx,4			; dx = x2
		sub	dx,di
		dec	dx
		mov	[lndx],dx
		shl	di,1
		mov	ax,Y1
		mov	cx,Y2
		mov	dx,399
		cmp	ax,dx
		jbe	gboxf_3
		mov	ax,dx
gboxf_3:
		cmp	cx,dx
		jbe	gboxf_4
		mov	cx,dx
gboxf_4:
		cmp	ax,cx
		jbe	not_ychg
		xchg	ax,cx			; Y1 > Y2 �Ȃ�Y1,Y2�����ւ���
not_ychg:
		sub	cx,ax
		inc	cx
		mov	dx,80
		mul	dx
		add	di,ax			; di = �擪VRAM�A�h���X
		call	BoxFill
		call	GrcgReset		; GRCG ���Z�b�g
		pop	di
		ret
GraphicBoxf	ENDP



;-------------------------------------------------
;	realtime key input lib.
;	int joyin(),void jinit(),int kinp( int )
;
;-------------------------------------------------

	PUBLIC	joyin,jinit,kinp


kinp	proc	k_matrix:word

	push	di

	mov	ax,0000			;�j�d�x�@�o�b�t�@���O�ɂ���B
	mov	es,ax
	mov	di,0528H
	mov	al,0
	mov	es:[di],al

	mov	ax,k_matrix
	mov	ah,04
	int	18h
	mov	al,ah
	mov	ah,0

	pop	di
	ret

	endp


jinit	proc
	;
	mov	ah,03H
	int	18H
	;mov	ah,0CH
	;int	18H
	ret
	;
	endp


;-------------------------------------------------
;	realtime key input routine
;	for ( 2,4,6,8,[x],[space],[z] )
;-------------------------------------------------


joyin	proc
	push	di

	mov	ax,0000			;�j�d�x�@�o�b�t�@���O�ɂ���B
	mov	es,ax
	mov	di,0528H
	mov	al,0
	mov	es:[di],al
	mov	dx,0
	;
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
	
BB6:	mov	ax,00406H	;"SAPCE"
	int	18H
	and	ah,000010000B
	je	BB7
	;
	or	dl,16

BB7:	mov	ax,00400H	;"ESC"
	int	18H
	and	ah,01B
	je	TT2W
	;
	or	dl,32

TT2W:
	retn

	endp



;-------------------------------------------------------------
;  void KanjiGputc(unsigned int KANJI,int XP,int YP,int COLOR)
;  unsigned int KANJI : �����V�t�gJIS�R�[�h
;           int XP    : �\�� �����W 0�`639-16
;           int YP    : �\�� �c���W 0�`400-16
;           int COLOR : �\���J���[ 
;                       bit4 = 0 : ���ʕ��� 
;                            = 1 : ������ 
;			bit5 = 1 : ���ꕶ��(8dot/adr) type1
;			bit6 = 1 : ���ꕶ��(8dot/adr) type2
;--------------------------------------------------------------  
		PUBLIC	KanjiGputc
KANJI_H		equ	16
shift_cnt	db	3,3,3,3,2,2,2,2,1,1,1,1,0,0,0,0
shift_cnt2	db	7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0


View16		PROC
		imul	di,cx,80
		mov	ax,bx
		shr	ax,3
		add	di,ax
		call	GrcgSet
		push	dx
		and	dx,0Fh
		push	dx
		call	GrcgColor
		add	sp,2
		mov	ax,0A800h
		mov	es,ax
		mov	cx,KANJI_H
		;
		pop	dx
		cmp	dx,32
		jc	normal_mode
		cmp	dx,64
		jc	spec_type1

spec_type2:
		lea	bx,shift_cnt2
shift_spc2:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cl,cs:[bx]
		inc	bx
		cmp	cl,0
		jz	no_shift3
shift_loop3:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop3
no_shift3:
		mov	es:[di+82],dl
		mov	es:[di+81],al
		mov	es:[di],ah
		add	di,80
		pop	cx
		loop	shift_spc2
		jmp	SHORT view16_exit


spec_type1:
		lea	bx,shift_cnt
shift_spc:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cl,cs:[bx]
		inc	bx
		cmp	cl,0
		jz	no_shift2
shift_loop2:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop2
no_shift2:
		mov	es:[di+2],dl
		xchg	ah,al
		mov	es:[di],ax
		add	di,80
		pop	cx
		loop	shift_spc
		jmp	SHORT view16_exit


normal_mode:
		and	bx,7
		jz	not_shift
shift_data:
		push	cx
		sub	dx,dx
		lodsw
		xchg	ah,al
		mov	cx,bx
shift_loop:
		shr	ax,1
		rcr	dl,1
		loop	shift_loop
		mov	es:[di+2],dl
		xchg	ah,al
		mov	es:[di],ax
		add	di,80
		pop	cx
		loop	shift_data
		jmp	SHORT view16_exit
not_shift:
		lodsw
		mov	es:[di],ax
		add	di,80
		loop	not_shift
view16_exit:
		call	GrcgReset
		ret

View16		ENDP



KanjiGputc	PROC USES si di,KANJI:WORD,XP:WORD,YP:WORD,COLOR:WORD
		cld
		mov	al,0Bh		;�r�b�g�}�b�v���[�h
		out	68h,al		;kanji access control
		mov	ax,KANJI
	        ;--- �V�t�gJIS��JIS�ϊ�
	        xchg	ah,al
	        shl     ah,1
	        sub     al,1fh
      	  	js      kgput_1
        	cmp     al,061h
        	adc     al,0deh
kgput_1:
        	add     ax,1fa1h
        	and     ax,07f7fh
		sub	ah,20h
					; ax = Kanji JIS code
		out	0A1h,al
		xchg	ah,al
		out	0A3h,al
		sub	ax,ax		; ax = 0
		mov	es,ax
		test	BYTE PTR es:[054Dh],01000000b
		mov	ax,ds
		mov	es,ax
		mov	di,OFFSET DGROUP:kanji_data
		jz	io_read	
cgw_read:
		push	ds
		mov	cx,16
		mov	ax,0A400h
		mov	ds,ax	
		sub	si,si		; si = 0	
	rep	movsw
		pop	ds
		jmp	SHORT kgput_2	
io_read:		
		mov	cx,0
ior_1:		
		mov	ax,cx
		or	al,020h	
		out	0A5h,al
		in	al,0A9h
		stosb
		mov	ax,cx
		out	0A5h,al
		in	al,0A9h
		stosb
		inc	cx
		cmp	cx,KANJI_H
		jnz	ior_1
kgput_2:
		mov	al,0Ah		; �R�[�h�A�N�Z�X���[�h
		out	68h,al		;kanji access control
		test	COLOR,010h
		jnz	kgput_4
		jmp	kgput_3
		;--- �������f�[�^����
kgput_4:
		mov	si,OFFSET DGROUP:kanji_data
		mov	di,si
	REPT KANJI_H
		lodsw
		mov	dx,ax
		rol	dx,1
		or	ax,dx
		stosw	
	ENDM
kgput_3:
		mov	bx,XP
		mov	cx,YP
		mov	dx,COLOR
		mov	si,OFFSET DGROUP:kanji_data
		call	View16
		ret
KanjiGputc	ENDP




;---------------------------------------------------------
;
;	print routine main �i�����S�p�C���p�T�|�[�g�Ȃ��j
;
;---------------------------------------------------------

	PUBLIC	kprt

kprt	proc axisX:WORD,axisY:WORD,Color:WORD,stadr:PTR WORD
	;
	push	si
	push	di
	mov	bx,axisX
	mov	cx,axisY
	mov	dx,Color
	;
	mov	si,offset stadr
kp1:
	mov	al,[si]
	or	al,al
	jz	kp2
	inc	si
	cmp	al,0e0h
	jnc	kp4
	cmp	al,0a0h
	jnc	kp3
	cmp	al,080h
	jnc	kp4
	cmp	al,20h
	jnc	kp3
	cmp	al,09h
	jz	kp5
	;
	jmp	kp1
	;
kp4:
	mov	ah,[si]
	or	ah,ah
	jz	kp2
	inc	si
	;
	push	dx
	push	cx
	push	bx
	push	ax
	call	KanjiGputc
	pop	ax
	pop	bx
	pop	cx
	pop	dx
	add	bx,16
	;
	jmp	kp1
kp5:
	add	bx,8*8
	and	bx,0ffffh-63
	jmp	kp1

kp3:
	push	cx
	add	cx,2
	add	bx,8
	;
	jmp	kp1

kp2:
	pop	di
	pop	si
	ret

	endp



;-----------------------------------------------------
;
;	screen H-double routine ( for 200 lines )
;
;-----------------------------------------------------

	PUBLIC	hdbl

hdbl	proc
	push	di
	;
	mov	bx,39		; read start idx.
	mov	di,78		; write start idx.
	mov	cx,200		; lines
hdb3:
	push	cx
	push	bx
	push	di
	mov	cx,40
hdb0:
	push	cx
	mov	ax,vram0
	call	hdb2
	mov	ax,vram1
	call	hdb2
	mov	ax,vram2
	call	hdb2
	mov	ax,vram3
	call	hdb2
	dec	di
	dec	di
	dec	bx
	pop	cx
	loop	hdb0
	;
	pop	di
	pop	bx
	add	di,80
	add	bx,80
	pop	cx
	loop	hdb3
	;
	pop	di
	ret

hdb2:
	mov	es,ax
	mov	dl,es:[bx]
	mov	cx,8
hdb1:
	shr	dl,1
	pushf
	rcr	ax,1
	popf
	rcr	ax,1
	loop	hdb1
	;
	mov	es:[di],ah
	inc	di
	mov	es:[di],al
	dec	di
	retn

	endp




;-----------------------------------------------------
;
;	screen V-double routine ( for 400 lines )
;
;-----------------------------------------------------

	PUBLIC	vdbl

vdbl	proc
	push	di
	;
	mov	bx,80*199	; read start idx.
	mov	di,80*398	; write start idx.
	mov	cx,200		; lines
vdb3:
	push	cx
	push	bx
	push	di
	mov	ax,vram0
	call	vdb2
	mov	ax,vram1
	call	vdb2
	mov	ax,vram2
	call	vdb2
	mov	ax,vram3
	call	vdb2
	;
	pop	di
	pop	bx
	sub	di,160
	sub	bx,80
	pop	cx
	loop	vdb3
	;
	pop	di
	ret

vdb2:
	push	di
	push	bx
	push	bx
	;
	mov	es,ax
	mov	cx,80
vdb1:
	mov	al,es:[bx]
	mov	es:[di],al
	inc	bx
	inc	di
	loop	vdb1
	;
	pop	bx
	mov	cx,80
vdb4:
	mov	al,es:[bx]
	mov	es:[di],al
	inc	bx
	inc	di
	loop	vdb4
	;
	pop	bx
	pop	di
	retn

	endp



;-----------------------------------------------------
;
;	xkd scrud,scrdup area for 400line
;
;-----------------------------------------------------

VRAM0		EQU 0A800H
VRAM1		EQU 0B000H
VRAM2		EQU 0B800H
VRAM3		EQU 0E000H

BANK_B	equ	0a800h
BANK_R	equ	0b000h
BANK_G	equ	0b800h
BANK_E	equ	0e000h

GDC_STAT	equ	0a0h
GDC_POUT	equ	0a0h
GDC_COUT	equ	0a2h



	;
	;	void gscroll( int sc_dir,int sc_len,int sc_step );
	;		sc_dir : 0=up 1=down 2=trans other=recover
	;		sc_len : lines ( max 400 )
	;		sc_step: scroll step ( 1�`8 )
	;

gscroll	proc SC_DIR:word,SC_LEN:word,SC_STEP:word
public gscroll

	push	si
	push	di
	mov	ax,SC_DIR
	cmp	ax,2
	jz	sc_trans
	cmp	ax,3
	jnc	sc_recov
	;
	mov	SCROLL_DIRECTION,ax
	mov	ax,SC_LEN
	mov	SCROLL_LENGTH,ax
	mov	ax,SC_STEP
	mov	SCROLL_STEP,ax
	;
	call	main
	jmp	sc_over
sc_trans:
	call	TRANS
	jmp	sc_over
sc_recov:
	call	RECOVER
sc_over:
	pop	di
	pop	si
	ret


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
	retn
	
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
	retn
	

	;
	;�f�c�b�R�}���h���o
	;		al = COMMAND
GDC_COM_OUT:
	mov	ah,al
gdc_com_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_com_l1
	mov	al,ah
	out	GDC_COUT,al
	retn
	;
	;�f�c�b�p�����[�^���o�i�o�C�g�j
	;		al = PARAM (BYTE)
GDC_PARA_OUT:
	mov	ah,al
gdc_out_l1:
	in	al,GDC_STAT
	and	al,2
	jnz	gdc_out_l1
	mov	al,ah
	out	GDC_POUT,al
	retn
	;
	;�f�c�b�p�����[�^���o�i���[�h�j
	;		ax = PARAM (WORD)
GDC_PARAW_OUT:
	 push	ax
	call	GDC_PARA_OUT
	 pop	ax
	mov	al,ah
	call	GDC_PARA_OUT
	retn

VWAIT:
vwait_l1:
	in	al,0a0h
	test	al,00100000b
	jnz	vwait_l1
vwait_l2:
	in	al,0a0h
	test	al,00100000b
	jz	vwait_l2
	retn

main:
	;mov	ax,cs
	;mov	ds,ax
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
	retn
	
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
	retn
	
TRANS_SCREEN_TO_BUFFER:
	 push	ds
	mov	si,dx
	mov	ds,ax
	mov	bx,cs
	mov	es,bx
	mov	cx,40
	rep	movsw
	 pop	ds
	retn
	
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
	retn
to_screen_j1:		;��ʂ��܂�����
	mov	cx,24
	rep	movsw
	mov	di,0
	mov	cx,16
	rep	movsw
	 pop	ds
	retn
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
	retn
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
	retn
	
ACCESS_PAGE0:
	mov	al,0
	jmp	ACCESS_PAGE_j1
ACCESS_PAGE1:
	mov	al,1
ACCESS_PAGE_j1:
	out	0a6h,al
	retn
	
	;
	;�\���𒼂�
	;
RECOVER:
	;mov	ax,cs
	;mov	ds,ax
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
	retn

	;
	;�\��ʂ��痠��ʂ֓]������
	;
TRANS:
	;mov	ax,cs
	;mov	ds,ax
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
	retn

BUFFER			db	320 dup (0)

gscroll	endp


	;
	;	void	set_page( int apage, int dpage );
	;
set_page	proc apage:word,dpage:word
public set_page
	;
	MOV	AL,0
	OUT	07CH,AL
	mov	ax,dpage
	out	0a4h,al
	mov	ax,apage
	out	0a6h,al
	;
	ret
set_page	endp



;============================================================================
		PUBLIC	pset
;============================================================================
pset		proc	set_01:WORD,set_02:WORD,set_03:WORD

		irp	reg,<bx,cx,dx,si,di,ds,es>
		push	reg
		endm

		call	g_pset_01

		irp	reg,<es,ds,di,si,dx,cx,bx>
		pop	reg
		endm
		ret
g_pset_01:
		call	Grcg_on
		mov	ax,set_03
		push	ax
		call	GrcgColor
		pop	ax

		mov	ax,0A800h
		mov	es,ax
		mov	ax,set_02
		shl	ax,1
		shl	ax,1
		shl	ax,1
		shl	ax,1
		mov	cx,ax
		shl	ax,1
		shl	ax,1
		add	cx,ax
		mov	ax,set_01
		shr	ax,1
		shr	ax,1
		shr	ax,1
		add	cx,ax
		mov	ax,set_01
		and	ax,7
		mov	bx,offset POINT_ITI
		add	bx,ax
		mov	ah,cs:[bx]
		mov	di,cx
		mov	es:[di],ah
		call	Grcg_off
		retn


Grcg_on:
		mov	al,011000000b		;�f�q�b�f�@�n�m
		out	07ch,al
		retn

Grcg_off:
		xor	al,al
		out	07CH,al
		retn

POINT_ITI	DB	010000000b		;0
		DB	001000000b		;1
		DB	000100000b		;2
		DB	000010000b		;3
		DB	000001000b		;4
		DB	000000100b		;5
		DB	000000010b		;6
		DB	000000001b		;7

pset		endp


;============================================================================
		PUBLIC	point
;============================================================================
point	proc	set_01:WORD,set_02:WORD
		irp	reg,<bx,cx,dx,si,di,ds,es>
		push	reg
		endm

		call	g_point_01

		irp	reg,<es,ds,di,si,dx,cx,bx>
		pop	reg
		endm
		ret

paddr		dw	0

g_point_01:
		mov	ax,set_01	;�w���W�̐ݒ���s���Ă��܂��B
		mov	cl,3
		shr	ax,cl
		mov	cs:paddr,ax		;set_04=X/8
		mov	ax,set_01
		AND 	al,00000111B
		mov	cl,al
		mov	al,010000000B
		CMP	cl,0
		JZ	g_point_02
		shr	al,cl
g_point_02:
		mov	bh,al
		
		mov	ax,set_02	;ITI=X+Y*80
		mov	cl,4
		shl	ax,cl
		mov	cx,ax
		shl	ax,1
		shl	ax,1
		add	ax,cx
		mov	dx,cs:paddr
		add	ax,dx
		mov	di,ax

		mov	bl,0
		mov	ax,0a800h
		mov	es,ax
		mov	al,es:[di]
		and	al,bh
		je	g_point_03
		mov	bl,1
g_point_03:
		mov	ax,0b000h
		mov	es,ax
		mov	al,es:[di]
		and	al,bh
		je	g_point_04
		add	bl,2
g_point_04:
		mov	ax,0b800h
		mov	es,ax
		mov	al,es:[di]
		and	al,bh
		je	g_point_05
		add	bl,4
g_point_05:
		mov	ax,0e000h
		mov	es,ax
		mov	al,es:[di]
		and	al,bh
		je	g_point_06
		add	bl,8
g_point_06:
		mov	ah,0
		mov	al,bl
		retn
point	endp




;--------------------------------------------
;
;---------- �A�i���O�p���b�g�ݒ� ------------
;    CX=color no.  AX=�F�R�[�h
;--------------------------------------------

	PUBLIC	set_palet
set_palet	proc	pal:WORD,col:WORD

		mov	cx,pal
		mov	ax,col

		push	ax
		;
		mov	al,cl
		out	0A8h,al		; �p���b�g���W�X�^No.�ݒ�
		;
		pop	ax
		mov	dx,ax
		xchg	ah,al
		out	0AAh,al		; �p���b�gGreen
		and	ah,0F0h
		mov	cl,4
		shr	ah,cl
		xchg	ah,al
		out	0ACh,al		; �p���b�gRed
		mov	ax,dx
		and	ax,0Fh
		out	0AEh,al		; �p���b�gBlue

		ret
set_palet	endp


;--------------------------------------------
;	graphic screen copy
;--------------------------------------------

	PUBLIC	gcopy
gcopy	proc	xx:WORD,yy:WORD,sx:WORD,sy:WORD,tx:WORD,ty:WORD

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
	mov	ax,vram0
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
	mov	ah,HIGH vram0
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram1
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram2
	mov	es,ax
	mov	bl,es:[si]
	mov	es:[di],bl
	mov	ah,HIGH vram3
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

gcopy	endp


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


_TEXT	ends


;-------------------------------------------------
;	data segment
;-------------------------------------------------


DGROUP	GROUP	_DATA
_DATA	segment	word public 'DATA'

SCROLL_STEP		dw	1		;�P��̃X�N���[����
SCROLL_LENGTH		dw	400		;�X�N���[����
SCROLL_DIRECTION	dw	0		;0 = UP ,other = DOWN
SCREEN_LINE_COUNTER	dw	0
SCREEN_GDC_ADDR		dw	0

PUTAD		DW 0
TILE_TOP	DW 0
FILE_END	DW 0
LOOK_AD		DW 0
NULL_COLOR	DB 0
WIDECT		DB 0
LINECT		DB 0
WIDEOF		DB 0	;���ʒu�I�t�Z�b�g�@�O�|�i�v�h�c�d�b�s�|�P�j
LINEOF		DB 0	;�c
GRCT		DB 0
TILE_AD		DW 0
POKE_AD		DW 0
BASE_AD		DW 0
CSRX		DB 1	;�����p�w���W
CSRY		DB 1	;�@�@�@�x���W

TEMPP		DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

TILE_BUF	DW 0
DUMY		DB 0,255,255,0,255,255
GRW0		DB 0
GRW1		DB 0
GRW2		DB 0
MASK_BIT	DB 0
		;
xpats		dw	?			; ���[�r�b�g�f�[�^
xpate		dw	?			; �E�[�r�b�g�f�[�^
lndx		dw	?			; ���o�C�g��

_gc_set		db	?		; GRCG �O���t�B�b�N�`���[�W���[
					; 0 = ����, 1 =	�L��
_egc_set	db	?		; EGC �G���n���X�gGRCG
					; 0 = ����, 1 =	�L��
_board16_set	db	?		; 16�F�{�[�h
					; 0 = ����, 1 =	�L��
_gdc_clock	db	?		; GDC �N���b�N
					; 0 = 2.5MHz, 1	= 5MHz
kanji_data	dw	KANJI_H dup (?)


_DATA		ENDS


;-------------------------------------------------
;	end of line
;-------------------------------------------------

	END


