
/*	in 'owb2.obj' functions		*/

void	owb_init( int owb_work_seg );
void	owb_wipe( int wsx, int wsy, int wex, int wey );
void	pix_init( int src_seg );
void	pix_exec( void );
int	pix_setmode( int newmode );
int	pix_getcol1();
int	pix_getcol2();

/*	hardware bios functions		*/

int	ginit( int Lines,int SPage,int Sswitch );
void	t_cls();
void	t_off();
void	t_on();
void	gcls( int Color );
void	bfill( int X1,int Y1,int X2,int Y2,int Color );
void	kputc( int KANJI,int XP,int YP,int Color );
int	kinp( int matrix );
int	joyin();
void	jinit();
void	gscroll( int sc_dir,int sc_len,int sc_step );
void	set_page( int apage, int dpage );
void	set_palet( int Color,int Code );

int	segload( int fnptr, int fseg, int fsize );
int	segsave( int fnptr, int fseg, int fsize );

