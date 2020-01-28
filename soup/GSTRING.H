
/*	in 'gstring.obj' functions 	*/

void		gs_init( int data_segment, char sepchr1, char sepchr2 );
int		gs_info( int info_num );
int		gs_getl( char *l_string );
int		gs_getp( char *l_string, char *l_bufstr );
unsigned char	*gs_getw( char *l_string, char *l_bufstr, int *wtype, char *nextw );
int		gs_wtoi( char *l_string, int *wval );

int		gs_cpy( char *dst_str, char *src_str );
int		gs_cat( char *tar_str, char *cat_str );
int		gs_cmp( char *src_str, char *cmp_str );
int		gs_sch( char *tar_str, char sch_chr );
int		gs_cut( char *tar_str, char sch_chr );

void		gs_pget( int *ofsinf, int *lineinf, int *hofsinf );
void		gs_pput( int ofsinf, int lineinf, int hofsinf );
