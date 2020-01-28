
/*	in 'mgint.obj' functions 	*/

void	ginit( int Lines,int SPage,int Sswitch );
void	t_cls();
void	t_off();
void	t_on();
void	gcls( int Color );
void	kprt( int X,int Y,int Color,char *st );
void	GraphicBoxf( int X1,int Y1,int X2,int Y2,int Color );
void	KanjiGputc( int KANJI,int XP,int YP,int Color );
int	kinp( int matrix );
int	joyin();
void	jinit();
void	hdbl();
void	gscroll( int sc_dir,int sc_len,int sc_step );
void	set_page( int apage, int dpage );
void	pset( int X,int Y,int Color );
int	point( int X,int Y );
void	set_palet( int Color,int Code );
void	gcopy( int X,int Y,int size_X,int size_Y,int dist_X,int dist_Y  );

extern char	_board16_set;
extern char	_gdc_clock;
extern char	_gc_set;
extern char	_egc_set;

