
/*		for wpd.obj functions		*/

void	wpd_init( int wpdbuf, int picbuf );

	/*
		wpdbuf	/ "cbuff.bin"のセグメント(2048bytes)
		picbuf	/ 表示用BUFFER(max64K)
	*/

void	wpd_set( int vofs, int size_x, int size_y );

	/*
		vofs	/ window表示位置 offset
		size_x	/ window size-X
		size_y	/ window size-Y
	*/

void	wpd_frame( int draw_x, int y_dot );

	/*
		draw_x	/ buffer size-X ( 128,256 )
		y_dot	/ y-dot size ( 1,2,4... )
	*/

void	wpd_cnv( int srcbuf );

	/*
		srcbuf	/ wpd2形式に変換するバッファ(64K)
	*/


void	wpd_bcls( int color );
	//	clear buffer (color)

void	wpd_qcls( );
	//	clear buffer (for quick draw)

void	wpd_rot( int xx, int yy, int px, int py, int srcbuf );
	//	rotate transfer (vector)

void	wpd_rot2( int xx, int yy, int angle, int zoom, int srcbuf );
	//	rotate transfer (angle)

void	wpd_hrot( int xx, int yy, int px, int py, int srcbuf );
	//	rotate wpd2 transfer (vector)

void	wpd_hrot2( int xx, int yy, int angle, int zoom, int srcbuf );
	//	rotate wpd2 transfer (angle)

void	wpd_prot( int xx, int yy, int angle, int zoom, int srcbuf );
	//	rotate transfer at CEL (angle)

void	wpd_cel( int xx, int yy, int sx, int sy, int angle, int zoom1, int zoom2, int srcbuf );
	//	part rotate transfer at CEL (angle)

void	wpd_hcel( int xx, int yy, int sx, int sy, int angle, int zoom1, int zoom2, int srcbuf );
	//	wpd2 part rotate transfer at CEL (angle)

void	wpd_hcel2( int xx, int yy, int sx, int sy, int angle, int zoom1, int zoom2, int srcbuf );
	//	wpd2 part rotate transfer at CEL dazzled (4/angle)

void	wpd_zrot( int xx, int yy, int srcbuf,int picbuf );
	//	z-through transfer


void	wpd_draw();
	//	display buffer (4bit-color)

void	wpd_draw2();
	//	display buffer (2bit-color)

void	wpd_bdraw( int picbuf );
	//	display buffer at 160x100 (4bit-color)

void	wpd_mbdraw( int picbuf, int mskbuf );
	//	display buffer at 160x100 (4bit-color/mask accept)

void	wpd_bqdraw( int picbuf );
	//	display buffer at 160x100 (4bit-color/skip code accept)

void	wpd_fdraw( int picbuf );
	//	display ex-buffer (2bit-color/byte)

void	wpd_wdraw( int picbuf );
	//	display ex-buffer (1bit-color/byte)

void	wpd_sfx( int value , int yplus , int type );
	//	special effect set

int	wpd_get( int getseg, int vofs, int xdot, int ydot );
	//	get vram -> wpd buffer

int	wpd_sin( int angle );
	//	get sin value

int	wpd_cos( int angle );
	//	get cos value

void	seq_init( int seqbuf , int skazz );
	//	initalize sequence data

void	seq_calq();
	//	calculate sequence data bufeer

void	seq_exec();
	//	execute sequence

void	seq_set( int objno, int func, int xx, int yy, int sx, int sy, int ang,
		 int zoomx, int zoomy, int chrseg );
	//	set object basic value

void	seq_prm( int sqtno, int prmno, int prm );
	//	set parameter value

void	seq_act( int objno, int prmno, int times, int px, int maxv, int bounce, int ppx );
	//	set object active value

void	seq_env( int objno, int prmno, int goval, int times, int envno );
	//	set object active value ( with move envelope )

	//	sequence codes are:		parameter numbers are:
	//
	//		 0/none				0/XX
	//		 1/hrot2			1/YY
	//		 2/hcel				2/SIZE X
	//		 3/hcel2			3/SIZE Y
	//		 4/cel				4/ANGLE
	//		 5/rot2				5/ZOOM X
	//		 6/rot				6/ZOOM Y
	//		 7/zrot	XX,YY,CS		7/CHR SEG
	//		 8/bcls XX
	//		 9/putv XX,YY,SX,SY,CS
	//		10/mput XX,YY,SX,SY,CS
	//		11/lput XX,YY,SX,SY,CS,ANG
	//		12/vcls XX

void	msk_make( int wkseg, int wkcol );
	//	make mask data
void	msk_merge( int wkseg, int wkcol );
	//	merge screen 1->0
void	msk_merge2( int wkseg, int wkcol, int mmode, int vinc, int wtime );
	//	merge screen (smooth)
void	msk_get( int wkseg, int vofs, int xx, int yy );
	//	vram -> buffer
void	msk_put( int wkseg, int vofs, int xx, int yy );
	//	buffer -> vram ( on the screen )
void	msk_mput( int wkseg, int vofs, int xx, int yy );
	//	buffer -> vram ( under the mask )
void	msk_lget( int wkseg, int vofs, int xx, int yy, int pmask );
	//	vram -> buffer ( no mask )
void	msk_lput( int wkseg, int vofs, int xx, int yy, int pmask );
	//	buffer -> vram ( no mask )

