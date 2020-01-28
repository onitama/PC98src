
/*	in 'gstring.obj' functions 	*/

void		gs_init( int data_segment, char sepchr1, char sepchr2 );
int		gs_info( int info_num );
int		gs_getl( char *l_string );
int		gs_getp( char *l_string, char *l_bufstr );
unsigned char	*gs_getw( char *l_string, char *l_bufstr, int *wtype, char *nextw );
int		gs_wtoi( char *l_string, int *wval );
int		gs_stbuf( char *l_str, int send_seg, int send_ofs );
int		gs_cdbuf( int str_seg, int str_size, int send_seg, int send_ofs );

