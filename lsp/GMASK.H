
/*		for gmask.obj functions		*/

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

void	g_copy3( int xx, int yy, int sx, int sy, int py );
