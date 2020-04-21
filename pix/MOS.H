
/*	in 'mos.obj' functions		*/

void	ms_init( int vbufseg );
void	ms_area( int winsx, int winsy, int winex, int winey );
void	ms_clip( int clpsx, int clpsy, int clpex, int clpey );
void	ms_ctrl( int iflag );
void	ms_reset( int xx, int yy );
void	ms_locate( int xx, int yy );
void	ms_chr( int code, int haj_x, int haj_y );
void	ms_proc();
void	ms_wipe();
int	ms_kill();
int	ms_joyin();
void	ms_done();

void	ms_cinit( int cb_seg, int cb_kazz );
void	ms_cset( int cbno, int cbflg, int cbxx, int cbyy, int cblx, int cbly );
int	ms_cget( int cbno );
int	ms_cbox();

extern	int ms_key;
extern	int ms_trg;
extern	int ms_xx;
extern	int ms_yy;
extern	int ms_px;
extern	int ms_py;
extern	int ms_hx;
extern	int ms_hy;
extern	int ms_ox;
extern	int ms_oy;

