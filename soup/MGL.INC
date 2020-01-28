/*
	some useful functions for 'mgl.obj'
*/

int	magload( char *name , int buff1 , int buff2 , int xx , int yy )
{
	int i,j;
	unsigned int k;
	unsigned char far *buf;

	buf=MK_FP( buff1,0 );
	if ( seg_load2( name , buff1 , 0xfff )>0 )
				{ return 1; }		// file not found

	mgl_set( 639,399,512,0x2000 );
	k=yy*80+(xx>>3);
	i=mgl_open( buff1 , buff2 , k );
	if ( i==-1) { return 2; }			// file type error

	/*	set palette status	*/

	i=i+32;for(j=0;j<16;j++) {
		//k=(buf[i]>>5)*256+(buf[i+1]>>5)*16+(buf[i+2]>>5);
		k=(buf[i]>>4)*256+(buf[i+1]>>4)*16+(buf[i+2]>>4);
		pal_set( j,k );i=i+3;
		}

	return 0;
}


