
	;
	;	base exe for emio
	;

	.MODEL small
	.CODE

start:
	mov	ax,cs
	mov	ds,ax
		;
		mov	ax,0900h
		mov	dx,offset mes1
		int	21h
		;
	mov	ax,4c00h
	int	21h

mes1	db	'このファイルは "SOUP.EXE" で使用します。実行できません。'
	db	13,10,'$'

		end

	.STACK



