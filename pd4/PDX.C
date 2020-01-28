	/*
	
	
	
	*/

	#include<stdio.h>
	#include<stdlib.h>
	#include<fcntl.h>
	#include<sys\stat.h>
	#include<dos.h>
	#include<conio.h>
	#include<string.h>

/*
	in 'gint.obj' functions ( also uses 'font.obj' )
*/
void	ginit( int Lines,int SPage,int Sswitch );
void	t_cls();
void	t_off();
void	t_on();
void	gcls();
void	gprt( int X,int Y,int Color,char *st );
void	xkd_pic( char X,char Y,char *st );
void	GraphicBoxf(int X1,int Y1,int X2,int Y2,int Color);

/*
	in 'pal.obj' functions
*/
void	pal_init();
void	pal_done();
void	pal_set( int Color , int Code );
void	pal_show( int Grade );
void	pal_fade( int Speed );
void	pal_wait();
void	vwait( int Speed );


extern char	_board16_set;
extern char	_gdc_clock;
extern char	_gc_set;
extern char	_egc_set;

	static	char	*v,*w,*x;
	static	char errf,sw_h,sw_p,sw_k,sw_c,a1,a2;
	static	unsigned char	bname[64],fname[64],sname[64];

main( int argc,char *argv[] )
{
	char	*buff;
	FILE *fp1;
	int b,c,fp;
	bname[0]=NULL;
	buff=malloc(32000);if (buff==NULL) { printf("Can't allocate enough memory.\n");return 1; }

	printf("pdx picture files viewer ver.B / XKD laboratory,onion software 1992\n");

	errf=0;sw_h=0;sw_p=0;sw_k=0;sw_c=0;


	if (argc > 1 ) {
		for (b=1;b<argc;b++) {
			a1=*argv[b];a2=tolower(*(argv[b]+1));
			if ( a1!='/'&&a1!='-' ) {
				strcpy(bname,argv[b]);	}
			else {
				switch (a2) {
				case 'c':
					sw_c=1;break;
				case 'p':
					sw_p=1;break;
				case 'h':
					sw_h=1;break;
				case 'k':
					sw_k=1;break;
				case '?':
					sw_h=1;break;
				default:
					errf=1;break;
				}
			}
		}
		}

		if (sw_c) { ginit(1,0,1);gcls(0);return 0; }
		if (sw_h) { usage2();usage1();return 0; }
		if ( errf||bname[0]==NULL ) { usage1();return 1; }

		v=strchr(bname,'.');if (v!=NULL) { v[0]=NULL; }
		strcat(bname,".PD4");

		fp1=fopen(bname,"r");
		if (fp1==NULL) { printf("\nError in reading a file.\n");return 1; }
		fclose(fp1);

	fp=open( bname,O_CREAT|O_RDWR|O_BINARY,S_IREAD|S_IWRITE);
	read(fp,buff,32000);
	close(fp);


	ginit(1,0,1);
	if (_gc_set==0||_board16_set==0)
		{ printf("No GRCG or 16color board on your PC98.\nCan't execute."); }
	else {
	gcls(0);

	if (sw_p) { xkd_pic( 0,0,buff );return 0; }

	t_off();

	pal_init();
	pal_set(0,0);
	pal_set(1,0xa);
	pal_set(2,0xa0);
	pal_set(3,0xaa);
	pal_set(4,0xa00);
	pal_set(5,0xa0a);
	pal_set(6,0xaa0);
	pal_set(7,0xaaa);
	pal_show( 0 );

	xkd_pic( 0,0,buff );

	pal_fade( 1 );pal_wait();
	if (sw_k) { getch();pal_fade( -1 );pal_wait(); }
	pal_done();
	t_on();

	}

	return 0;

}

usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	"usage: pdx [/option] [path-name]",
	"		  /p	no initalize palette",
	"		  /k	key wait switch",
	"		  /c	clear screen",
	"		  /h	help about pdx",
	NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "\n%s", p[i]);
	return;
}


usage2()
{
static 	char 	rec[1]= "", *p[] =
{
	"・pdx は…",
	rec,
	"拡張子PD4のデジタル8色グラフィック画像データファイルを展開します。",
	"このファイルは主にPC8801で使われており、onion software の100円ディスク",
	"を始めとしたソフトの画像をPC9801上で展開することが可能です。",
	"その際には、PC8801から何らかの方法でファイルを変換する必要があります。",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "\n%s", p[i]);
	return;
}

