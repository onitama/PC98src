/*
	advanced graphics interface / pol.s
				1992,1993 (c) fozon
*/

//	pol.s functions

void	far pol_set_c();
void	far pol_g_set();
void	far pol_set();
void	far pol_start();
void	far pol_map( int sg );
void	far pol_add( int my_x, int my_y, int my_z, int cos_a, int sin_a, int sg );
void	far pol_end( int my_x, int my_y, int my_z, int cos_a, int sin_a, int sg );
void	far pol( int sg, int vofs );

