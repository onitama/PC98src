	/*

		PIX test ( X-rated picture manager )
					started.1995/7 onitama
	*/

	#define	src_size	0x2000	// 128K source obj buffer

	#include <alloc.h>
	#include <stdio.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <string.h>
	#include <dos.h>
	#include "owb2.h"
	#include "mos.h"
	#include "vtx.h"

	static	unsigned char	errf,sw_s,sw_c;
	static	unsigned char	bname[64],fname[64],sname[64];
	static	unsigned char	s1[256],s2[256],s3[256];
	static	unsigned int	srcbuf,msvbuf,strbuf,hedbuf;
	static	unsigned char	*v1,*v2,*v3;

	static	unsigned char	far *hdr;

	static	int	a,b,c,i,xx,yy,x2,y2,rmode,fsize,jport,jtrig;
	static	char	a1,a2,a3;

	#include "owb2.inc"


main( int argc,char *argv[] )
{
	//	check command line

	strcpy(bname,"none");
	errf=0;sw_s=0;sw_c=0;

	printf("PIX ver.A : XKD laboratory/onion software 1995(c)\n");
	if (argc < 2 ) { usage();return 0; }

	for (b=1;b<argc;b++) {
		a1=*argv[b];a2=tolower(*(argv[b]+1));
		if ( (a1=='/')||(a1=='-') ) {
			switch (a2) {
			case 'c' : sw_c=1;break;
			case 's' : sw_s=1;sw_c=1;break;
			default :  errf=1;break;
			}
		}
		else strcpy( bname,argv[b] );
	}
	if (errf) { printf("\nIllegal switch selected.");return -1; }
	if (strcmp(bname,"none")==0) {
		printf("No filename selected.\n");return -1;
	}

	strcpy(fname,bname);strcat(fname,".ask");
	strcpy(sname,bname);strcat(sname,".pix");

	//	prepare buffer

	a=allocmem( 0x200,&msvbuf );
	a=allocmem( src_size,&srcbuf );
	hedbuf=srcbuf;srcbuf+=2;
	hdr=MK_FP(hedbuf,0);
	if (a!=-1) { printf("MS-DOSのメモリが足りないのでだめです。\n");return -1; }

	if (sw_c==0) goto norm_load;

	//	convert to PIX

	pal_init();pal_show(0);
	ginit(1,0,1);gcls(0);
	if ( askload( fname,srcbuf,0 ) ) {
		printf("指定されたファイルがみつかりません。[%s]\n",fname);
		goto no_pic;
	}
	pal_show(15);
	ms_init( msvbuf );
	ms_area( 0,0,639,399 );
	ms_ctrl(1);

	fsize=binload( fname,srcbuf );
	printf("[%s] (%dbytes) is loaded.\n",fname,fsize);
	for(a=0;a<16;a++) { hdr[a]=hdr[a+32]; }
	for(a=0;a<32;a++) { hdr[a+16]=0; }
	hdr[2]='X';

	rmode=0;i=0;xx=0;yy=0;
	while(1) {
		ms_proc();
		if (ms_trg&64) set_axis();
		if (ms_trg&128) break;
		if (joyin()&32) { rmode=-1;break; }
		if (sw_s==1) break;
	}
	ms_wipe();
	ms_done();
	ginit(1,0,0);
	pal_done();
	if (rmode==-1) goto prg_bye;

norm_cnv:
	binsave( sname,hedbuf,fsize+32 );
	printf("converted.\n");
	goto prg_bye;

norm_load:
	//	load picture (PIX)

	pal_init();pal_show(0);
	set_page(0,0);gcls(0);
	ginit(1,0,0);
	if ( askload( sname,hedbuf,0 ) ) goto no_pic;
	pix_init( hedbuf );
	owb_init( hedbuf );
	pix_exec();

	ginit(1,0,1);
	pal_fade(1);
	i=0;
	while(1) {
		pix_exec();
		a=joyin();jtrig=(jport^a)&a;jport=a;
		if ( jtrig&0xc0 ) {
			i++;if (i>3) i=0;
			pix_setmode(i);
		}
		if ( a&0x30 ) break;
		vwait(3);
	}
no_pic:
	ginit(1,0,0);
	pal_done();

prg_bye:
	while(1) { if (joyin()==0) break; }
	jinit();

	return 0;
}


static set_axis()
{
	if ((xx==ms_xx)||(yy==ms_yy)) return;
	if ((i&1)==0) {	xx=(ms_xx>>3)*8;yy=(ms_yy>>2)*4; }
		else {
			x2=((ms_xx-xx)>>3)*8+7;y2=((ms_yy-yy)>>2)*4+3;
			if ((x2<=0)||(y2<=0)) return;
			bfill( xx,yy,xx+x2,yy+y2,0 );
			a=i*4+12;
			hdr[a++]=xx&0xff; hdr[a++]=xx>>8;
			hdr[a++]=yy&0xff; hdr[a++]=yy>>8;
			hdr[a++]=x2&0xff; hdr[a++]=x2>>8;
			hdr[a++]=y2&0xff; hdr[a++]=y2>>8;
			xx=0;yy=0;
		}
	i++;
	return;
}


usage()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: pix [options] [filename]",
	"	(none)	display PIX file",
	"	  /c	make PIX file from ASK",
	"	  /s	smart cnv ASK->PIX file",
	NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}

