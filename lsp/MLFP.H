int	far mlfp_initial( void );
void	far mlfp_setup( void far * );
void	far mlfp_go( void );
void	far mlfp_stop( void );
void	far mlfp_setvol( int master_vol );
void	far mlfp_setbalance( int fmvolofs );
int	far mlfp_getstat( void );
unsigned int	far mlfp_gettick( void );
void	far mlfp_inthandle( void far * );
void	far mlfp_setcue( int cue_switch );
