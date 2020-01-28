
/*	in 'selbl.obj' functions 	*/

void	sl_init( int data_segment );
int	sl_make( char *l_name, int l_code, int l_typ );
int	sl_find( char *l_name, int *l_code, int *l_typ );
void	sl_getnam( char *label_name, int lcode );
int	sl_lblset( int objseg, int lblseg );

