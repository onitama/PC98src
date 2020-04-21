/*
	some useful functions for 'mgint.obj'
*/

int	seg_load( char *fname, int load_seg , int load_size )
{
	int sz,fp;
	fp=_open( fname ,O_RDONLY );
		if (fp<0) { return 0; }
	sz=segload( fp,load_seg,load_size );
	_close(fp);
	return sz;
}


int	seg_save( char *fname, int load_seg , int load_size )
{
	int fp;
	fp=open( fname ,O_CREAT|O_WRONLY|O_BINARY,S_IREAD|S_IWRITE );
		if (fp<0) { return 0; }
	segsave( fp,load_seg,load_size );
	close(fp);
	return load_size;
}


