	;
	;	crtv interrput use
	;	palette control routine and wait device routine
	;	( for assemble from optasm 'optasm -mx pal.s' )
	;	for use from Turbo C++
	;
	;					created / Ana
	;					arranged/ onitama
	;
	.MODEL	small

BASIC	EQU	0



	INCLUDE IFTHEN.MAC


	PUBLIC _pal_init, _pal_set, _pal_show
	PUBLIC _pal_fade, _pal_wait, _pal_done
	PUBLIC _pal_stat, _vwait


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


WAIT_CNT	DW 0
PAL_INIT	DB 0
PAL_MODE	DW -1


V0A_OFS		DW 0
V0A_SEG		DW 0
PAL_CNT0	DW 0
PAL_CNT		DW 0
PAL_GRADE	DB 0
PAL_AREA	DB 3 * 16 DUP( 0 )



CAL_PALETTE PROC
;
;	DS = CS Ç≈Ç†ÇÈÇ±Ç∆ÅB
;
	MUL [PAL_GRADE]
	ADD AL,8
	SHR AL,1
	SHR AL,1
	SHR AL,1
	SHR AL,1
	RET
CAL_PALETTE ENDP


SET_PALETTE PROC
;
;	DS = CS Ç≈Ç†ÇÈÇ±Ç∆ÅB
;
	MOV BX, OFFSET PAL_AREA
	MOV CX,16
	XOR DL,DL
	@DO
		MOV AL,DL
		INC DL
		OUT 0A8H,AL
		
		MOV AL,[BX]
		INC BX
		CALL CAL_PALETTE
		OUT 0AEH,AL
		
		MOV AL,[BX]
		INC BX
		CALL CAL_PALETTE
		OUT 0ACH,AL
		
		MOV AL,[BX]
		INC BX
		CALL CAL_PALETTE
		OUT 0AAH,AL
	@LOOP LOOP
	RET
SET_PALETTE ENDP




PAL_ENTRY PROC
	PUSH DS
	PUSH AX

	MOV AX,CS
	MOV DS,AX

	inc [WAIT_CNT]		; for vwait routine

	mov ax,[PAL_MODE]
	or ax,ax
	jz #PE4

	DEC [PAL_CNT]
	@IF Z
		MOV AX,[PAL_CNT0]
		CMP AX,0
		JL #PE1
			MOV [PAL_CNT],AX
			INC [PAL_GRADE]
			JMP #PE2
#PE1:
			NEG AX
			MOV [PAL_CNT],AX
			DEC [PAL_GRADE]
#PE2:
		PUSH BX
		PUSH CX
		PUSH DX
		CALL SET_PALETTE
		POP DX
		POP CX
		POP BX
	@ENDIF
	MOV AL,[PAL_GRADE]
	OR AL,AL
	JZ #PE3
	CMP AL,16
	JAE #PE3
		JMP #PE4
#PE3:
		MOV [PAL_MODE],0
#PE4:
	CLI
	MOV AL,20H
	OUT 00H,AL	; PIC Ç… EOI Çí ím
	OUT 64H,AL	; CRTV äÑÇËçûÇ›ãñâ¬
	POP AX
	POP DS
	STI
	IRET
PAL_ENTRY ENDP




_pal_init PROC

	push ds
	mov ax,cs
	mov ds,ax

	MOV AL,1
	OUT 06AH,AL
	MOV [PAL_MODE],0

	XOR AX,AX
	MOV ES,AX
	MOV BX,0AH * 4
	CLI
	IN AL,02H
	AND AL,NOT 04H
	CMP [PAL_INIT],0
	@IF Z
		MOV DX,ES:[BX]
		MOV [V0A_OFS],DX
		MOV DX,ES:2[BX]
		MOV [V0A_SEG],DX	; Save original vector
		MOV [PAL_INIT],1
	@ENDIF
	MOV DX,OFFSET PAL_ENTRY
	MOV ES:[BX],DX
	MOV DX,CS
	MOV ES:2[BX],DX
	OUT 02H,AL
	STI
	OUT 64H,AL

	pop ds
	RET

_pal_init ENDP



_pal_done PROC

	push ds
	mov ax,cs
	mov ds,ax

	MOV [PAL_MODE],-1
	CMP [PAL_INIT],0
	@IF NZ
		CLI
		XOR AX,AX
		MOV ES,AX
		MOV BX,0AH * 4
		MOV AX,[V0A_OFS]
		MOV ES:[BX],AX
		MOV AX,[V0A_SEG]
		MOV ES:2[BX],AX		; Restore original vector
		MOV [PAL_INIT],0
		STI
	@ENDIF

	pop ds
	RET

_pal_done ENDP



_pal_set PROC
	IF BASIC
		LES SI,4[BX]
		MOV CX,ES:[SI]
		LES SI,[BX]
		MOV DX,ES:[SI]
	ELSE
		PUSH BP
		MOV BP,SP
		MOV CX,[BP].DATA1
		MOV DX,[BP].DATA2
	ENDIF
	PUSH DS
	MOV AX,CS
	MOV DS,AX
	
	MOV AX,CX
	ADD AX,AX
	ADD AX,CX
	ADD AX,OFFSET PAL_AREA
	MOV BX,AX
	MOV AL,DL
	AND DL,0FH
	MOV [BX],DL
	INC BX
	SHR AL,1
	SHR AL,1
	SHR AL,1
	SHR AL,1
	MOV [BX],AL
	INC BX
	AND DH,0FH
	MOV [BX],DH
	
	POP DS
	IF BASIC
		IRET
	ELSE
		POP BP
		RET
	ENDIF
_pal_set ENDP




_pal_show PROC
	IF BASIC
		LES SI,[BX]
		MOV AX,ES:[SI]
	ELSE
		PUSH BP
		MOV BP,SP
		MOV AX,[BP].DATA1
	ENDIF
	PUSH DS
	MOV DX,CS
	MOV DS,DX
	CMP AL,16
	@IF A
		MOV AL,16
	@ENDIF
	MOV [PAL_GRADE],AL
	CALL SET_PALETTE
	POP DS
	IF BASIC
		IRET
	ELSE
		POP BP
		RET
	ENDIF
_pal_show ENDP



_pal_fade PROC
	IF BASIC
		LES SI,[BX]
		MOV AX,ES:[SI]
	ELSE
		PUSH BP
		MOV BP,SP
		MOV AX,[BP].DATA1
	ENDIF
	PUSH DS
	MOV DX,CS
	MOV DS,DX
	MOV [PAL_CNT0],AX
	MOV [PAL_CNT],1
	MOV [PAL_MODE],1

	
	POP DS
	IF BASIC
		IRET
	ELSE
		POP BP
		RET
	ENDIF
_pal_fade ENDP



_pal_wait PROC

	push ds

	mov ax,cs
	mov ds,ax
fwait:
	MOV AX,[PAL_MODE]
	test al,1
	jnz fwait

	pop ds
	RET

_pal_wait ENDP



_pal_stat PROC

	push ds

	mov ax,cs
	mov ds,ax
	MOV AX,[PAL_MODE]

	pop ds
	RET

_pal_stat ENDP



_vwait PROC

	PUSH BP
	MOV BP,SP
	MOV AX,[BP].DATA1
	PUSH DS
	mov cx,ax
	MOV DX,CS
	MOV DS,DX
vw:
	mov ax,[WAIT_CNT]
	cmp ax,cx
	jc vw

	xor ax,ax
	mov [WAIT_CNT],ax

	POP DS
	POP BP
	RET


_vwait ENDP







_TEXT	ends



	END

