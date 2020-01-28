

extern	int  near bopen(  char far * file_name, int fh );
extern	long near bload(  int fh, void far * buff, long size );
extern	long near bsave(  int fh, void far * buff, long size );
extern	void near bclose( int fh );
extern	long near bseek(  int fh, long ptr );
extern	long near get_cur_ptr( int fh );




