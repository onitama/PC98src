
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

	/*	vram->vram copy routines	*/
void	g_copy( int xx, int yy, int sx, int sy, int tx, int ty );
void	g_copy2( int xx, int yy, int sx, int sy, int tx, int ty, int srcpage );

	/*	software sprite routines	*/
void	ssp_init( int chrdat_seg, int ssp_kazu );
void	ssp_ext( int chrdat_seg );
void	ssp_clip( int x1, int y1, int x2, int y2, int v_offset );
void	ssp_set( int sp_no, int xx, int yy, int chr_no );
int	ssp_exec();
int	ssp_exec2();
void	ssp_wipe();
int	ssp_hit( int chk_no, int start_no, int end_no );
void	ssp_putv( int xx, int yy, int data_adr, int data_seg );

	/*	special bios routines for GDC	*/

int	gdc_clock( int clock );
void	gdc_ymul( int y_dot );

	/*	special bios routines for text of MJP	*/

void	tpole( int xx, int yy, int chr_no, int length, int plus );
void	troll( int xx, int yy, int sx, int sy );
int	tget( int xx, int yy );
