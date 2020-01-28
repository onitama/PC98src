int	far play_initial( void );
void	far play_setup( void far * );
void	far play_go( void );
void	far play_stop( void );
void	far play_setvol( int master_vol );
void	far play_setbalance( int fmvolofs );
int	far play_getstat( void );
unsigned int	far play_gettick( void );
void	far play_inthandle( void far * );
void	far play_setcue( int cue_switch );
