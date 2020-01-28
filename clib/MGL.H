
/*	in 'mgl.obj' functions 	*/

int	mgl_open( int p_seg, int b_seg, int v_ofs );
int	mgl_pbuf( int p_seg, int b_seg );
void	mgl_set( int max_x, int max_y, int buf_skip, int buf_size );
void	g_copy( int xx, int yy, int sx, int sy, int tx, int ty );
void	g_copy2( int xx, int yy, int sx, int sy, int tx, int ty, int srcpage );

