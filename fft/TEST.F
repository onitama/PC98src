	;
	;	FFT sample source
	;

	;	this is comment line
	;		:warning for no comment:
	;
main:
	lda #0:sta <memory:lda [memory],y
	a=0	; produced by FFT
	x=5

@1:	;	@はローカルラベルを表わします。 ( @0 ~ @199 )
	;
	a=a+5
	y--:bne @1	; @をこのようにして使えます。

	rts
@2:

	d0=5
@3:
	#255,x=a
@4:
	tomem=a
@5:
	bra @2

subr:

@2:
	a8
@3:
	aaaaa
@4:
	d5d5d5d
@5:
	this is test program 'onitama:programmed' be sure. :last line


	bra @3

	