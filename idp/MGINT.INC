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


int	seg_load2( char *fnstr, int load_seg, int max_seg )
	//	over 64K file read
{
	unsigned int pp,tp,fp,lseg,lptr;

	fp=_open( fnstr ,O_RDONLY );
		if (fp<0) { return 1; }
	lseg=max_seg;lptr=load_seg;tp=0x800;
	while(1) {
		if (lseg<0x800) { tp=lseg; }
		pp=segload( fp,lptr,tp<<4 );
		if (pp<(tp<<4)) { break; }
		lptr=lptr+tp;lseg=lseg-tp;
		if (lseg==0) { break; }
	}
	_close(fp);
	return 0;
}


int	seg_save2( char *fname, int save_seg, int segsize )
	//	over 64K file write
{
	unsigned int pp,tp,fp,lseg,lptr;

	fp=open( fname ,O_CREAT|O_WRONLY|O_BINARY,S_IREAD|S_IWRITE );
		if (fp<0) { return 1; }

	lseg=segsize;lptr=save_seg;tp=0x800;
	while(1) {
		if (lseg<0x800) { tp=lseg; }
		segsave( fp,lptr,tp<<4 );
		lptr=lptr+tp;lseg=lseg-tp;
		if (lseg==0) { break; }
	}

	close(fp);
	return 0;
}

