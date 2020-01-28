/*
	some useful functions for 'aska.obj'
*/

ask_pic( char *name , int buff , int vofs )
{
	int fp,efl;
	if ( seg_load2( name,buff,0x2000 )!=0 ) { return 1; }
	ask_pal( buff );
	ask_open( buff,vofs );
	return 0;
}

ask_pal( int buff )
{
	int a,b;
	char far *buff2;
	buff2=MK_FP( buff,0 );

	for(a=0;a<16;a++) {
		b=a*2+16;
		pal_set(a,buff2[b]*256+buff2[b+1]);
		}

	return 0;
}


int	seg_load2( char *fnstr, int load_seg, int max_seg )
	//	over 64K file read
{
	unsigned int pp,tp,fp,lseg,lptr;
	char far *emptr;

	if (emflg==1) {
		for(pp=0;pp<32;pp++) {
			tp=fnstr[pp];
			if (tp==0) break;
			fnstr[pp]=toupper(tp);
			}
		emptr=MK_FP( load_seg,0 );
		em_read( emptr,fnstr );
		return 0;
		}

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