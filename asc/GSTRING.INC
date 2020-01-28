/*
	some useful functions for 'gstring.obj'
*/

seg_load( char *fname, int load_seg , int load_size )
{
	int fp;
	fp=open( fname ,O_RDONLY );
		if (fp<0) { return 1; }
	segload( fp,load_seg,load_size );
	close(fp);
	return 0;
}


seg_save( char *fname, int load_seg , int load_size )
{
	int fp;
	unlink( fname );
	fp=open( fname ,O_CREAT|O_WRONLY|O_BINARY,S_IREAD|S_IWRITE );
		if (fp<0) { return 1; }
	segsave( fp,load_seg,load_size );
	close(fp);
	return 0;
}

