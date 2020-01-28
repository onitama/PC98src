
/*	'map.obj' functions		*/


	typedef struct {
	unsigned char e_flg;
	unsigned char e_xx;
	unsigned char e_yy;
	unsigned char e_chr;
	} obj;

void	set_map( int MAP_SEG , int MAP_SX , int MAP_SY );
void	set_pat( int PAT_SEG , int BG_OFS , int FG_OFS );
void	set_disp( int DISP_X , int DISP_Y , int DISP_SX , int DISP_SY );
void	redraw( int MAP_X , int MAP_Y );
void	update( int MAP_X , int MAP_Y );
void	putfg( int FG_X , int FG_Y , int CHAR_CODE );
void	putfg2( int FG_X , int FG_Y , int CHAR_CODE );
void	wipfg2( int FG_X , int FG_Y );
void	clrfg( int CHAR_CODE );
void	emove( int MAP_X,int MAP_Y,int EKAZZ,obj *ENEMY );
int	getfg( int FG_X , int FG_Y );
int	getbg( int BG_X , int BG_Y );
void	putbg( int BG_X , int BG_Y , int CHAR_CODE );
void	putbg2( int BG_X , int BG_Y , int CHAR_CODE );
void	dputbg( int SCREEN_X , int SCREEN_Y , int CHAR_CODE );

