
	/*
	
		source program of
		IDP / integrated data package linker
				onion software 1994/5
	
	*/

	#define	srcseg	0x5000
	#define	datseg	0x1000
	#define	wrtseg	0x1000
	#define pck	4		// packet size 2^xx
	#define pckx	1		// packet segment x value

	#include <stdlib.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <dos.h>
	#include <string.h>
	#include "idpcnv.h"
	#include "mgint.h"		// use graphics interface
	#include "mgint.inc"

	static unsigned int far *info;
	static unsigned int srcbuf;
	static unsigned int wrtbuf;
	static unsigned int datbuf;
	static unsigned int datbuf2;
	static unsigned char sname[32];
	static unsigned char fname[32];
	static unsigned char xname[32];

	static int p,l,rmode,id,rate,maxid;
	static unsigned int a,b,c,x,y,ffres;
	static unsigned int ua,fsize,divmode,divsize;
	static unsigned char a1,a2;

main( int argc,char *argv[] )
{
	printf("IDP : integrated data package linker V.Cz / cpr.1994(c) onitama/zener works\n");
	maxid=0x200;id=-1;rmode=0;divmode=0;fname[0]=0;
	strcpy(sname,"idpdat");

	//	check command line

	if (argc < 2 ) { usage1();return 0; }
	for (b=1;b<argc;b++) {

		a1=*argv[b];a2=tolower(*(argv[b]+1));
		if ( a1!='/' ) { strcpy(fname,argv[b]); }
		else if (a2=='h') { rmode=-1; }
		else if (a2=='n') { rmode=1; }
		else if (a2=='c') { rmode=2; }
		else if (a2=='b') maxid=atoi( argv[b]+2 )*8;
		else if (a2=='v') divmode=atoi( argv[b]+2 );
		else if (a2=='s') strcpy( sname,argv[b]+2 );
		else if (a2=='i') id=atoi( argv[b]+2 );
	}

	if (rmode==-1) { usage2();usage1();return 0; }
	if (fname[0]==0) { printf("No filename selected.\n");return 1; }

	strcpy( xname,sname );
	strcat( sname,".idp" );
	strcat( xname,".pck" );

	/*	buffer allocate 	*/

	p=allocmem( datseg , &datbuf );
	if (p==-1) a=allocmem( wrtseg , &wrtbuf );
	if (p==-1) a=allocmem( srcseg , &srcbuf );
	if (p!=-1) { printf("No free area on MS-DOS.\nCan't execute.\n");return 1; }

	info=MK_FP( wrtbuf,0 );
	idp_init( srcbuf, datbuf, wrtbuf );

	if (rmode==2) {
		catalog();return 0;
	}

	/*	load IDP,PCK file	*/

	a=seg_load( sname,wrtbuf,0x8000 );
	if (a==0) rmode=1;
	a=seg_load2( xname,srcbuf,srcseg );
	if (a!=0) rmode=1;
	if (rmode==0) {
		printf( "Read current data file [%s] and [%s].\n",sname,xname );
	}

	/*	new header info.	*/

	if (rmode==1) {
		printf( "Make new data file.\n" );
		for(a=0;a<256;a++) { info[a]=0; }
		info[0]=0x5044;					// 'DP' code
		info[1]=maxid;
		info[2]=0;
		info[3]=1;
	}

	/*	convert main	*/

	ua=seg_load( fname,datbuf,0xfff0 );fsize=ua>>pck;
	if (ua==0) { printf("No file.\n");return 1; }
	if (divmode) {
		divsize=fsize/divmode;datbuf2=datbuf;
		printf( "Divide filemode [%x] x %d\n",divsize,divmode );
	}
	if (id==-1) id=info[3];
	ffres=fsize;

cvmain:
	x=info[1];
	if (divmode) fsize=divsize;
	printf( "Making data [%d]....",fsize );
	a=idp_make( id,fsize );
	x=info[1]-x;
	printf( "completed.\n" );
	rate=fsize/100;if (rate>0) {
		printf( "loader chr [%d]  packed chr [%d] (%d%%)\n",fsize,a,a/(fsize/100) );
		printf( "last adr [$%x] (%d)   lastpck [$%x]   last idx [%d]\n",x,info[1],info[2],info[3] );
	}
	b=(a<<pck)+x;
	c=ffres<<pck;a=c/100;if (a==0) a=1;
	printf( "source size [%d]   packed size [%d]   reduce ratio [%d%%]\n",c,b,b/a );

	if (divmode) {
		datbuf2+=divsize;id++;
		idp_init( srcbuf, datbuf2, wrtbuf );
		divmode--;if (divmode>0) goto cvmain;
	}

	/*	save to file	*/

	a=seg_save( sname,wrtbuf,info[1]+2 );
	if (a==0) { printf("Error happened in IDP file writing.\n");return 1; }
	printf( "[%s] saved. (%d bytes)\n",sname,info[1]+2 );

	a=seg_save2( xname,srcbuf,info[2]*pckx );
	if (a!=0) { printf("Error happened in PCK file writing.\n");return 1; }
	printf( "[%s] saved. ($%x0 bytes)\n",xname,info[2]*pckx );

	return 0;
}


static catalog()
{
	/*	see catalog	*/

	strcat( fname,".idp" );
	a=seg_load( fname,wrtbuf,0x8000 );
	if (a==0) {
		printf( "file [%s] is not exist.\n",fname );return 1;
	}

	a=info[3];b=4;c=0;
	printf( "Catalog of file [%s] ( in %d files ) :\n",fname,a-1 );
	printf( ":------------------------------------------------------\n" );
	while(1) {
		if ((a==1)||(info[b]==0)) break;
		printf( ":ID %d\tsize [%d]\tpck $%04x\tdata $%04x\n",
		info[b],info[b+3],info[b+2],info[b+1] );
		c+=info[b+3];
		a--;b+=4;
	}

	a=c*pckx;
	b=(info[1]>>4)+(info[2]*pckx);
	x=b/(a/100);

	printf( "\ntotal original size [$%x0]\npacked size [$%x0]\npacked ratio [%d%%]\n",
		a,b,x );
	return 0;
}




usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: idp [options] [source file]",
	"		  /sxxx	set idp filename to xxx",
	"		  /ixxx	set id number to xxx",
	"		  /vxxx	divide file pack mode",
	"		  /bxxx	max ID header space",
	"		  /c	see catalog of IDP",
	"		  /n	create new data",
	"		  /h	help about IDP",
	NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}

usage2()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"・idp は…",
	rec,
	"    パケット単位のデータの重複を調査し、最適なデータ再配置を行なうことで",
	"    データを圧縮する統合メモリマップ配置ツールです。",
	"    複数のデータファイルに重複して存在するデータをパケット単位で再配置します。",
	"    データを効率よく圧縮、また高速に参照する能力を持っています。",
	"    詳しい使用法は IDP.DOC を参照して下さい。",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}



