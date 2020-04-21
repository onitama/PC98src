/*
	some useful functions for 'owb2.obj'
*/

int	binload( char *fname, int load_seg )
{
	int fp,pp;
	fp=_open( fname ,O_RDONLY );if (fp<0) return 0;
	pp=segload( fp,load_seg,0xffff );
	_close(fp);
	return pp;
}


int	binsave( char *fname, int save_seg , int save_size )
{
	int fp;
	fp=open( fname ,O_CREAT|O_WRONLY|O_BINARY,S_IREAD|S_IWRITE );
	if (fp<0) return -1;
	segsave( fp,save_seg,save_size );
	close(fp);
	return 0;
}


/*
	some useful functions for 'aska.obj'
*/


askload( char *fname , int load_seg , int vofs )
{
	int a,b;
	unsigned char far *buff2;

	buff2=MK_FP( load_seg,0 );
	a=binload( fname,load_seg );
	if ( a==0 ) { printf("ファイルがみつかりません。[%s]\n",fname);return -1; }

	b=0x10;if ( buff2[2]=='X' ) b=0x30;
	for(a=0;a<16;a++) {
		pal_set(a,buff2[b]*256+buff2[b+1]);
		//pal_set(a,a*0x111);
		b+=2;
	}

	ask_open( load_seg,vofs );
	return 0;
}


