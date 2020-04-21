	/*
	
	
	
	*/

	#define	picseg	0x2000		// 64K picture data buffer
	#define	objkaz	33		// number of total object

	#include <stdio.h>
	#include <conio.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <dos.h>

	#include "gint.h"
	#include "gint.inc"
	#include "gmask.h"
	#include "mos.h"

	static	int a,b,c,d,p,m,x,y,z;
	static	int gdccl_save,aniofs,stage,pport,midien;
	static	int key_start,key_end,key_range,key_scale;
	static	int ene_level,gspeed,bar_yy,col_cnt,col_px;
	static	int jport,jwait,energy,life,power,cdown;
	static	unsigned char midich,mode;
	static	unsigned char d1,d2,d3;
	static	unsigned int far *an;
	static	unsigned int picbuf, mosbuf, chrbuf;
	static	unsigned char mes[64];
	static	unsigned char *mbf;

	static	int fl[objkaz],wt[objkaz],xx[objkaz],yy[objkaz];
	static	int chr[objkaz],px[objkaz],py[objkaz];



main()
{
	/*---------------------------------------------------------------
				initalize procedure
	---------------------------------------------------------------*/

	srand( (unsigned)time() );		// for randomize

	//	memory allocate

	a=allocmem(  0x200 , &mosbuf );
	a=allocmem( picseg , &picbuf );
	if (a!=-1) { printf("ÉÅÉCÉìÉÅÉÇÉäÇÃóeó Ç™ë´ÇËÇ‹ÇπÇÒÅB\n");
			return 1; }
	an=MK_FP( picbuf,0 );
	chrbuf=picbuf;

	//	screen inital

	ginit(1,0,0);
	if (_gc_set==0||_board16_set==0)
		{ printf("No GRCG or 16color board on your PC98.\nCan't execute.\n");
			return 1; }
	set_page(0,0);gcls(0);
	_setcursortype( _NOCURSOR );

	//	mouse inital

	ms_init( mosbuf );
	ms_wipe();

	//	palette inital

	pal_init();

	//	system inital

	gdccl_save=gdc_clock(0);


	/*---------------------------------------------------------------
				main procedure
	---------------------------------------------------------------*/


	l200init();
	for(a=0;a<13;a++) {
		c=5;if (a==6) c=8;
		b=32*a;GraphicBoxf( b,0,b,191,c );
		b=16*a;GraphicBoxf( 0,b,384,b,c );
	}

	seg_load( "TGCHR.BIN",chrbuf,0xfff0 );

	ssp_init( chrbuf,objkaz );
	ssp_ext( chrbuf );
	ssp_clip( 64,0,383+64,383,72 );

	for(a=0;a<16;a++) { pal_set(a,a*0x111); }
	pal_on();

	gotoxy( 50,1 );cprintf( "Sprite Animator ver.A" );
	gotoxy( 50,2 );cprintf( "	onion software 1994" );

	x=0;

	while(1) {

		ssp_set( objkaz-1,ms_xx,ms_yy,1 );
		ssp_set( 0,x,50,1 );
		x+=1;if (x==480) x=0;

		ssp_exec();vwait(1);ssp_exec2();
		jport=joyin();
		if (jport&32) break;
	}


	/*---------------------------------------------------------------
				exit procedure
	---------------------------------------------------------------*/

prgbye:
	ginit(1,0,0);
	clrscr();t_on();
	gdc_ymul(0);
	gdc_clock( gdccl_save );

	freemem( picbuf );
	pal_done();
	ms_done();

	while(1) { if (joyin()==0) break; }
	_setcursortype( _LINECURSOR );
	jinit();

return 0; }


	/*---------------------------------------------------------------
				subroutines
	---------------------------------------------------------------*/


static l200init()
{
	pal_off();t_cls();clrscr();
	ginit(1,0,1);gdc_ymul(1);
	set_page(0,0);gcls(0);
return;
}


static pal_clr()
{
	vwait(0);
	clrscr();
	for(a=0;a<16;a++) {
		pal_set(15-a,0);pal_show();vwait(2);
	}
return;
}


static pal_rclr()
{
	vwait(0);
	clrscr();
	for(a=0;a<16;a++) {
		pal_set(a,0xa0);pal_show();vwait(3);
	}
return;
}


static pal_off()
{
	for(a=0;a<16;a++) { pal_set(a,0); }
	pal_on();
	clrscr();
return;
}


static pal_on()
{
	vwait(0);pal_show();vwait(1);
return;
}


static vpause( int pvwait )
{
	vwait(0);vwait( pvwait );
	return;
}


