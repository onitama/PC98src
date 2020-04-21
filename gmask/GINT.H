
/*	in 'gint.obj' functions ( also uses 'font.obj' )	*/

void	ginit( int Lines,int SPage,int Sswitch );
void	t_cls();
void	t_off();
void	t_on();
void	gcls( int Color );
void	gprt( int X,int Y,int Color,char *st );
void	kprt( int X,int Y,int Color,char *st );
void	GraphicBoxf( int X1,int Y1,int X2,int Y2,int Color );
void	KanjiGputc( int KANJI,int XP,int YP,int Color );
void	xkd_pic( char X,char Y,char *st );
int	kinp( int matrix );
int	joyin();
void	jinit();
void	hdbl();
void	gscroll( int sc_dir,int sc_len,int sc_step );
void	set_page( int apage, int dpage );

extern char	_board16_set;
extern char	_gdc_clock;
extern char	_gc_set;
extern char	_egc_set;

/*	in 'pal2.obj' functions		*/

void	pal_init();
void	pal_done();
void	pal_set( int Color , int Code );
void	pal_show();
void	vwait( int Speed );

/*	in 'aska.obj' functions		*/

void	ask_open( int adr , int vofs );

