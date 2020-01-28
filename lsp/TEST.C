	/*
	
	
	
	*/

	#define lbmax	49		// 50 labels/pvals
	#define srmax	15		// 16 nests/subroutine

	static int emflg;

	#include <stdio.h>
	#include <stdlib.h>
	#include <process.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <dos.h>
	#include "gint.h"		// use graphics interface
	#include "gint.inc"
	#include "mgl.h"		// use mag loader
	#include "mgl.inc"
	#include "qdcore.h"		// use qdcore
	#include "gstring.h"		// use glc string function
	#include "ana.h"
	#include "play.h"		// use annex MIDI
	#include "emiob.h"		// use exe file manager
	#include "driveb.h"
	#include "gmask.h"
	#include "mlfp.h"
	#include "mos.h"

	static	unsigned int picbuf,srcbuf,anihed,anibuf,mskbuf;
	static	unsigned int prgbuf,musbuf,mosbuf,rgbbuf;
	static	unsigned int aniseg,picseg,prgseg,musseg;
	static	unsigned char bname[32],fname[32],ename[32];
	static	unsigned char clname[32],clopt1[32],clopt2[32];
	static	unsigned char s1[256],s2[256],s3[256],s4[256],v2[256];
	static	unsigned char *v1,*v3,v4,v5;
	static	int pval[lbmax],lb_ofs[lbmax],lb_lin[lbmax];
	static	int sr_ofs[srmax],sr_lin[srmax],sr_hofs[srmax];

	static	int a,b,l,p,x,y,mval,mflg,err,midien;
	static	int p1,p2,p3,p4,p5,p6,p7,p8,p9,p10;
	static	int w_op,w_kw,w_tp;
	static	int sc_p1,sc_p2,sc_p3,sym_p1,sym_p2,sym_p3,sym_p4;
	static	int pg1,pg2,mumode,qpmode,qpofs,defsp,defstp;
	static	int wp1,wp2,wp3,wp4;
	static	int rp_ofs,rp_lin,sr_nest,nxt_prg,brk_prg;
	static	int conx,cony1,cony2,csrx,csry,bgcol,mscb;
	static	int looptime,conpy,csrgy;
	static	unsigned int c,d,ssize;
	static	unsigned int far *an;
	static	unsigned int far *wbf;
	static	unsigned int far *pbf;
	static	unsigned char far *rgbf;
	static	unsigned char far *pokebf;
	static	int far *sqt;
	static	int far *mdt;
	static	unsigned char a1,a2,w_nx,stlen;
	static	int rmode,rval,rstat,emode;

	static	char buffer[ 16384 ];

static read_obj( char *filename )
{
	FILE *fp;

	fp = fopen( filename, "rb" );
	if ( fp == NULL ) {
		printf( "Can't open '%s'\n", filename );
		return -1;
	}
	fread( buffer, sizeof( char ), sizeof( buffer ), fp );
	fclose( fp );
	return 0;
}


main( int argc,char *argv[] )
{
	emode=0;rmode=0;emflg=0;midien=0;

	aniseg=0x1000;		// 64K buffer
	picseg=0x1000;		// 64K buffer
	prgseg=0x400;		// 16K buffer
	musseg=0x200;		//  8K buffer

	//	check command line

	if (argc > 1 ) {
	for (b=1;b<argc;b++) {
		a1=*argv[b];a2=tolower(*(argv[b]+1));
		if ( a1!='/' ) { gs_cpy(fname,argv[b]);gs_cut(fname,'.'); }
		else if (a2=='h') rmode=1;
		else if (a2=='e') emode=1;
		else if (a2=='b') { gs_wtoi( argv[b]+2,&a);aniseg=a<<6; }
		else if (a2=='m') { gs_wtoi( argv[b]+2,&a);musseg=a<<6; }
		else if (a2=='p') { gs_wtoi( argv[b]+2,&a);prgseg=a<<6; }
		else if (a2=='a') midien=1;
		else if (a2=='n') midien=-1;
		}
	}

	if (emode==0) {
		printf("\x1B[36mlight SOUP processor\x1B[m Ver.Ax / copyright 1994(c) onion software\n");
		if (midien==-1) {
			printf("内部の音楽演奏機能は使用しません。\n");
			}
		if (midien>0) {
			a=mpu_board();
			if (a==0) printf("RS-MIDIによる音楽演奏をします。\n");
			else printf("MIDI I/Fによる音楽演奏をします。\n");
			}
	}

	if (argc < 2 ) { usage1();return 0; }
	if (rmode==1) { usage2();return 0; }

	//	memory allocate

	a=allocmem( 0x200 , &mosbuf );
	if (a==-1) a=allocmem( musseg , &musbuf );
	if (a==-1) a=allocmem( prgseg , &prgbuf );
	if (a==-1) a=allocmem( aniseg , &anihed );
	if (a==-1) a=allocmem( picseg , &picbuf );
	if (a!=-1) { printf("メモリの確保ができません。実行できませんでした。");
		     ginit(1,0,0);t_on();getch();exit(1); }

	rgbbuf=mosbuf+0x180;
	rgbf=MK_FP( rgbbuf,0 );
	mdt=MK_FP( musbuf,0 );

	anibuf=anihed+8;
	srcbuf=anihed;
	mskbuf=anihed+aniseg-0x800;
	an=MK_FP( anihed,0 );
	pokebf=MK_FP( srcbuf,0 );

	//	em mode check

	gs_cpy( bname,fname );
	gs_cat( bname,".ES" );
	a=_open( bname ,O_RDONLY );
		if (a<0) { }
		else {
		_close(a);
		emflg=1;em_init(bname);
		}

	//	screen inital

	randomize();
	ginit(1,0,0);
	if (_gc_set==0||_board16_set==0)
		{ printf("No GRCG or 16color board on your PC98.\nCan't execute.\n");
			return 1; }

	if (midien==0) { mlfp_initial();mlfp_setcue(0); }
	if (midien==1) play_init();

	brk_prg=0;nxt_prg=1;ename[0]=0;
	mumode=0;bgcol=0;mscb=0;
	csrx=0;csry=0;csrgy=0;conx=0;cony1=0;cony2=24;

	pal_init();
	for(a=0;a<16;a++) { pal_set( a,a*0x111 ); }
	pal_show(16);
	ms_init( mosbuf );ms_wipe();
	ms_cinit( rgbbuf,32 );

	while(nxt_prg>0) {
		dscp( fname );
		nxt_prg--;
		}

	if (brk_prg==0) { ginit(1,0,0);t_on();pal_show(0); }

	if (midien==0) mlfp_stop();
	if (midien==1) { play_stop();play_done(); }
	pal_done();
	ms_done();

	do { b=joyin(); } while (b&32);
	jinit();

	a=pval[0];

	freemem( picbuf );
	freemem( anihed );
	freemem( prgbuf );
	freemem( musbuf );
	freemem( mosbuf );

	if (emflg) { em_done(); }
	if (ename[0]!=0) { execl( ename,ename,NULL ); }

	if (emode) return a;
return 0; }


usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: lsp [options] [filename]",
	"		  /bxxx	set main buffer size",
	"		  /mxxx	set music buffer size",
	"		  /pxxx	set source buffer size",
	"		  /a	use ANNEX MIDI music data",
	"		  /n	no use music interrupt",
	"		  /h	help about lsp",
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
	rec,"・lsp とは…",
	rec,
	"　　画像表示、音楽、ディスクアクセスなどを統合して管理するための",
	"　　インタプリタ言語です。オートデモや簡易アニメーション表示、",
	"　　ＣＧ集や簡単なアドベンチャーゲーム作りなどに利用できます。",
	"    使用する時は、プログラムファイル（.DS）を指定して実行して下さい。",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}


static dscp( char *fspec )
{

	//	load program text file

	gs_cpy( bname,fspec );
	gs_cut( bname,'.' );
	gs_cat( bname,".DS" );
	a=seg_load2( bname,prgbuf,0x800 );
		if (a!=0) { printf("No such file.\n");return -1; }

	//	initalize default parameters

	sc_p1=1;sc_p2=0;sc_p3=1;
	sym_p1=15;sym_p2=1;sym_p3=0;sym_p4=0;
	pg1=0;pg2=0;qpmode=0;qpofs=0;defsp=3;defstp=1;
	wp1=0;wp2=0;wp3=0;wp4=0;sr_nest=0;

	//	check label location

	for(a=0;a<lbmax;a++) { lb_lin[a]=0; }
	gs_init( prgbuf,';',':' );
	err=0;
	while(1) {
		a=gs_getp( s2,s1 );if (a) break;
		v1=s2;if (v1[0]=='*') {
				if (gs_wtoi(v1+1,&p1)!=0) { err=10;mkerr();return 0; }
				if (p1>lbmax) { err=10;mkerr();return 0; }
				if (lb_lin[p1]!=0) { err=11;mkerr();return 0; }
				gs_pget( &lb_ofs[p1],&lb_lin[p1],&p2 );
				}
	}

	//	program execute

	gs_init( prgbuf,';',':' );

	while(1) {
		a=gs_getp( s2,s1 );if (a) break;
		v1=s2;err=wchk();
		if (err!=0) { if (err>0) { mkerr(); } return 0; }

		if (defstp==2) {			// esc check
			b=joyin();if (b&32) { err=99;mkerr();return 0; }
			}
	}

return 0; }


static mkerr()
{
	//	error messages

	if ((err==99)&&(emode)) return 0;

	printf("%s (%d)\t: ",fname,gs_info(3) );
	if (err==1) printf("わからない命令が出ました [%s]",s3);
	if (err==2) printf("パラメータの指定が間違ってます [%s]",s3);
	if (err==3) printf("パラメータが規定範囲を越えました [%s]",s4);
	if (err==4) printf("パラメータの個数が違います [%s]",s3);
	if (err==5) printf("ファイルが見つかりません [%s]",bname);
	if (err==6) printf("アニメーションデータが正しくロードされていません");
	if (err==7) printf("音楽データが正しくロードされていません");
	if (err==8) printf("演算子の表現が違います");
	if (err==9) printf("ジャンプ先のラベルが存在しません");
	if (err==10) printf("ラベルの指定が間違ってます");
	if (err==11) printf("すでに存在するラベルを定義しました");
	if (err==12) printf("サブルーチンを深く呼び出しすぎています");
	if (err==13) printf("サブルーチンでないのにRETURNが出ました");
	if (err==14) printf("指定された音楽モードと違います");
	if (err==99) printf("ユーザーに中断されました");
	printf("\nError detected.Program abort.\n");

return 0; }


static	wchk()
{
	//	word analysis

	rstat=0;
	v1=gs_getw( s3,v1,&w_tp,&w_nx );
	if (w_tp==0) return 0;

	if (w_tp==1) {
		if (gs_cmp(s3,"mess")) cc_mess(); else
		if (gs_cmp(s3,"page")) cc_page(); else
		if (gs_cmp(s3,"gprt")) cc_gprt(); else
		if (gs_cmp(s3,"aanime")) cc_anime(); else
		if (gs_cmp(s3,"put")) cc_put(); else
		if (gs_cmp(s3,"color")) cc_color(); else
		if (gs_cmp(s3,"if")) cc_if(); else
		if (gs_cmp(s3,"goto")) cc_goto(); else
		if (gs_cmp(s3,"gosub")) cc_gosub(); else
		if (gs_cmp(s3,"mswait")) cc_mswait(); else
		if (gs_cmp(s3,"locate")) cc_locate(); else
		if (gs_cmp(s3,"repeat")) cc_repeat(); else
		if (gs_cmp(s3,"loop")) cc_loop(); else
		if (gs_cmp(s3,"mcopy")) cc_mcopy(); else
		if (gs_cmp(s3,"pcopy")) cc_pcopy(); else
		if (gs_cmp(s3,"gcopy")) cc_gcopy(); else
		if (gs_cmp(s3,"rnd")) cc_rnd(); else
		if (gs_cmp(s3,"lput")) cc_lput(); else
		if (gs_cmp(s3,"mput")) cc_mput(); else
		if (gs_cmp(s3,"poke")) cc_poke(); else
		if (gs_cmp(s3,"peek")) cc_peek(); else
		if (gs_cmp(s3,"mask")) cc_mask(); else
		if (gs_cmp(s3,"boxf")) cc_boxf(); else
		if (gs_cmp(s3,"msset")) cc_msset(); else
		if (gs_cmp(s3,"msbox")) cc_msbox(); else
		if (gs_cmp(s3,"hdbl")) hdbl(); else
		if (gs_cmp(s3,"mplay")) cc_mplay(); else
		if (gs_cmp(s3,"mstop")) cc_mstop(); else
		if (gs_cmp(s3,"print")) cc_print(); else
		if (gs_cmp(s3,"return")) cc_return(); else
		if (gs_cmp(s3,"cls")) cc_cls(); else
		if (gs_cmp(s3,"lget")) cc_lget(); else
		if (gs_cmp(s3,"get")) cc_get(); else
		if (gs_cmp(s3,"mschr")) cc_mschr(); else
		if (gs_cmp(s3,"mag")) cc_mag(); else
		if (gs_cmp(s3,"rgb")) cc_rgb(); else
		if (gs_cmp(s3,"aska")) cc_aska(); else
		if (gs_cmp(s3,"midi")) cc_midi(); else
		if (gs_cmp(s3,"music")) cc_music(); else
		if (gs_cmp(s3,"bload")) cc_bload(); else
		if (gs_cmp(s3,"console")) cc_console(); else
		if (gs_cmp(s3,"msarea")) cc_msarea(); else
		if (gs_cmp(s3,"mono")) cc_mono(); else
		if (gs_cmp(s3,"qp")) cc_qp(); else
		if (gs_cmp(s3,"scroll")) cc_scroll(); else
		if (gs_cmp(s3,"pause")) cc_pause(); else
		if (gs_cmp(s3,"palette")) cc_palette(); else
		if (gs_cmp(s3,"contrast")) cc_contrast(); else
		if (gs_cmp(s3,"screen")) cc_screen(); else
		if (gs_cmp(s3,"escape")) cc_escape(); else
		if (gs_cmp(s3,"keywait")) cc_keywait(); else
		if (gs_cmp(s3,"palwait")) cc_palwait(); else
		if (gs_cmp(s3,"inkey")) cc_inkey(); else
		if (gs_cmp(s3,"mtick")) cc_mtick(); else
		if (gs_cmp(s3,"exec")) cc_exec(); else
		if (gs_cmp(s3,"child")) cc_child(); else
		if (gs_cmp(s3,"run")) cc_run(); else
		if (gs_cmp(s3,"bsave")) cc_bsave(); else
		if (gs_cmp(s3,"break")) { rstat=-1;brk_prg=1; } else
		if (gs_cmp(s3,"end")) rstat=-1;
		else rstat=1;
	}

	if (w_tp==2) {
		v4=s3[0];
		if (v4=='%') {
				skipp();if (w_tp!=3) { rstat=2; }
				if (w_nx!='=') { rstat=2; }
				if (gs_wtoi(s4,&p1)!=0) { rstat=2; }
				if (rstat!=0) { return rstat; }
				skipp();p2=getprm(-1,0,0);
				if (rstat!=0) { return rstat; }
				pval[p1]=p2;
				return 0; }
		if (v4=='*') {	return 0; }
		if (v4=='?') {	cc_print();return rstat; }

	rstat=1;
	}

return rstat; }


static skipp()
{
	v1=gs_getw( s4,v1,&w_tp,&w_nx );
return; }


static getprm( int defval, int maxval, int nexflg )
{
	//	get parameter from buffer
	//			defval  = 0～32767 ( default value )
	//				 -1 ( no default )
	//				 -2 ( strings -> v2 )
	//			maxval	= 0 ( max value is none )
	//				  1～32767 ( max value )
	//			nexflg  = 0 ( no more parameters )
	//				  1 ( more parameters with ',' )

	if (rstat!=0) { return 0; }

	mval=0;v4='+';
reget:
	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	if (w_tp==3) goto valpar;

	v4=s4[0];
	if (w_tp==4) { if (defval!=-2) { rstat=2;return 0; }
			gs_cpy(v2,s4+1);stlen=gs_cut(v2,0x22);
			}
	else if (v4=='-') goto reget;
	else if (v4=='%') { v5='+';goto valpar3; }
	else if ((v4==',')&&(defval>=0)&&(nexflg==1)) { return defval; }
	else if ((w_tp==0)&&(defval>=0)) { return defval; }
	else { rstat=2;return 0; }

	goto valpar2;

valpar:
	//	dec value (base)

	if (gs_wtoi(s4,&b)!=0) { rstat=2;return 0; }
valpar1:
	if (v4=='+') mval=mval+b; else
	if (v4=='-') mval=mval-b; else
	if (v4=='*') mval=mval*b; else
	if (v4=='/') mval=mval/b; else
	if (v4=='=') mval=mval==b; else
	if (v4=='<') mval=mval<b; else
	if (v4=='>') mval=mval>b; else
	if (v4=='!') mval=mval!=b; else
	if (v4=='&') mval=mval&b; else
	if (v4=='|') mval=mval|b; else
	if (v4=='^') mval=mval^b; else
	if (v4=='%') { b=pval[b];v4=v5;goto valpar1; }
	else { rstat=8;return 0; }

	if (w_nx==','||w_nx==0) { b=mval;goto valpar2; }

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	if (w_nx==','||w_nx==0) { rstat=8;return 0; }
	v4=s4[0];
	if (w_nx=='%') {v1=gs_getw( s4,v1,&w_tp,&w_nx );
			v5=v4;v4='%';
			}
valpar3:
	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	goto valpar;

valpar2:
	//	dec value over check

	if (maxval>0&&b>maxval) { rstat=3;return 0; }

	//	next parameter check

	if (nexflg==0) {
		if (w_nx!=0) { rstat=4;return 0; }
		return b; }
	if (w_nx==',') { v1++; }

return b; }

/*----------------------------------------------------------------------*/

static cc_print()
{
	//	print "str"

	if (w_nx==0) { printf("\n");return; }
	getprm( -2,0,1 );
	if (rstat!=0) return;
	if (w_nx==0) { printf("%s\n",v2);return; }
	printf("%s",v2);
	p1=getprm( -1,0,0);
	if (rstat!=0) return;
	printf("%d\n",p1);
return; }


static cc_cls()
{
	//	cls spec(1),color(0)
	p1=getprm( 1,3,1 );
	p2=getprm( 0,15,0 );
	if (rstat!=0) return;

	bgcol=p2;
	if (p1==0) { jinit();t_on(); } else
	if (p1==1) { clrscr(); } else
	if (p1==2) {
			gcls(p2);
			cbreset();
	} else
	if (p1==3) { 	t_off();
			set_page(1,0);gcls(p2);
			set_page(0,0);gcls(p2);
			cbreset();
			}
return; }


static cc_screen()
{
	//	screen lines(*),page(*),switch(*)  *=1,0,1(default)

	p1=getprm( sc_p1,1,1 );
	p2=getprm( sc_p2,1,1 );
	p3=getprm( sc_p3,1,0 );
	if (rstat!=0) return;

	sc_p1=p1;sc_p2=p2;sc_p3=p3;
	pg1=p2;pg2=p2;
	ginit(1,0,0);gcls(0);
	set_page(1,1);gcls(0);
	ginit(p1,p2,p3);
	cbreset();
return; }


static cc_locate()
{
	//	locate x(0),y(0)

	p1=getprm( 0,79,1 );
	p2=getprm( 0,24,0 );
	if (rstat!=0) return;

	csrx=p1;csry=p2;csrgy=p2<<4;
	//gotoxy(p1+1,p2+1);
return; }


static cc_keywait()
{
	//	keywait

	do { b=joyin(); } while ((b&16)||(ms_key&0xe0));
	while(1) {
		vwait(1);b=joyin();
		if ((b&16)||(ms_key&0xe0)) break;
		if (defstp) {			// esc check
			if (b&32) { rstat=99;return; }
			}
		}

return; }


static cc_color()
{
	//	color col(15),style(1),mode(0),exmode(0)

	p1=getprm( sym_p1,15,1 );
	p2=getprm( sym_p2,7,1 );
	p3=getprm( sym_p3,2,1 );
	p4=getprm( sym_p4,255,0 );
	if (rstat!=0) return;

	sym_p1=p1;sym_p2=p2;sym_p3=p3;sym_p4=p4;
return; }


static cc_mess()
{
	//	mess "str",flag(0),boxcol(99)

	getprm( -2,0,1 );
	p3=getprm( 0,0,1 );
	p4=getprm( 99,15,0 );
	if (rstat!=0) return;

	if (csrgy>(cony2<<4)) {
		csry=cony2;csrgy-=conpy;
		if (cony1!=cony2) {
			a=cony1<<4;
			g_copy3( 0,a,640,csrgy-a,conpy );
		}
		GraphicBoxf( 0,csrgy,639,csrgy+conpy-1,bgcol );
	}

	p1=csrx<<3;p2=csrgy;gpsub2();
	csrgy+=conpy;csrx=conx;

return; }


static cc_gprt()
{
	//	gprt x,y,"str",flag(0),boxcol(99)

	p1=getprm( -1,639,1 );
	p2=getprm( -1,399,1 );
	getprm( -2,0,1 );
	p3=getprm( 0,0,1 );
	p4=getprm( 99,15,0 );
	if (rstat!=0) return;

	gpsub2();

return; }

static gpsub2()
{
	a=(sym_p2<<4)+sym_p1;b=sym_p3&3;
	if (b==0) { gpsub(p1,p2); } else
	if (b==1) { if (stlen>0) gpsub(((80-stlen)<<2)+p1,p2); } else
	if (b==2) { if (stlen>0) gpsub(((80-stlen)<<3)+p1,p2); }
return; }


static gpsub( int tx,int ty )
{
	if (p4<16) {
		if (stlen>1) {
			l=tx;y=ty+1;x=tx+(stlen<<3);
			if ((l>=8)&&(x<632)) { l-=8;x+=8; }
			GraphicBoxf( l+5,y,x-5,y,p4 );
			GraphicBoxf( l+3,y+1,x-3,y+1,p4 );
			GraphicBoxf( l+2,y+2,x-2,y+2,p4 );
			GraphicBoxf( l+1,y+3,x-1,y+4,p4 );
			GraphicBoxf( l,y+4,x,y+8,p4 );
			GraphicBoxf( l+1,y+9,x-1,y+10,p4 );
			GraphicBoxf( l+2,y+11,x-2,y+11,p4 );
			GraphicBoxf( l+3,y+12,x-3,y+12,p4 );
			GraphicBoxf( l+5,y+13,x-5,y+13,p4 );
		}
	}

	if (p3>0) {
		if (p4<16) {
			ms_cset( mscb, p3, l, ty, x, ty+15 );
		}
		else {
			x=(stlen<<3)+tx;
			ms_cset( mscb, p3, tx, ty, x-1, ty+15 );
		}
		mscb++;if (mscb==64) mscb=63;
	}

	c=sym_p4&7;d=(((sym_p4)>>4)&15)+(a&0xf0);
	if (c==0) { kprt( tx,ty,a,v2 ); } else
	if (c==1) 	{
			kprt( tx+2,ty+1,d,v2 );
			kprt( tx,ty,a,v2 );
			} else
	if (c==2) 	{
			kprt( tx,ty-1,d,v2 );
			kprt( tx,ty+1,d,v2 );
			kprt( tx-2,ty,d,v2 );
			kprt( tx+2,ty,d,v2 );
			kprt( tx,ty,a|16,v2 );
			} else
	if (c==3)	{
			if ((a&15)==0) {
				for(l=15;l>=0;l--) {
				x=l+12;if (x>15) x=15;
				kprt( tx,ty-1,x,v2 );
				kprt( tx,ty+1,x,v2 );
				x=l+4;if (x>15) x=15;
				kprt( tx,ty,x,v2 );
				vwait(2);
				}
			return; }

			d=a&15;a=a&0xfff0;
			for(l=0;l<d;l++) {
				kprt( tx,ty,a+l,v2 );vwait(2);
				}
			}
return; }


static cc_mag()
{
	//	mag "file",x(0),y(0)

	getprm( -2,0,1 );
	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,0 );
	if (rstat!=0) return;

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".MAG" );
	a=magload( bname,anibuf+0x200,anibuf,p1,p2 );
	if (a!=0) { rstat=5;return; }
	qpmode=0;

return; }


static cc_palette()
{
	//	palette p_no(*),code(*),chgsw(0)

	p1=getprm( -1,15,1 );
	p2=getprm( -1,4095,1 );
	p3=getprm( 0,1,0 );
	if (rstat!=0) return;

	pal_set(p1,p2);
	if (p3==1) { pal_show(16); }
return; }


static cc_contrast()
{
	//	contrast grade(16),fadetime(0)

	p1=getprm( 16,16,1 );
	p2=getprm( 0,15,0 );
	if (rstat!=0) return;

	if (p2==0) { pal_show(p1);return; }
	if (p1==0) { pal_fade(0-p2);return; }
	if (p1==16) { pal_fade(p2);return; }

	rstat=2;
return; }


static cc_palwait()
{
	//	palwait

	while (1) {
		if (pal_stat()==0) break;
		vwait(1);b=joyin();
		if (defstp) {			// esc check
			if (b&32) { rstat=99;return; }
			}
	}

return; }


static cc_pause()
{
	//	pause times(100)

	p1=getprm( 100,9999,0 );
	if (rstat!=0) return;

	while (1) {
		vwait(1);b=joyin();
		if (defstp) {			// esc check
			if (b&32) { rstat=99;return; }
			}
		p1--;if (p1==0) break;
	}

return; }


static cc_aska()
{
	//	aska "file",x(0),y(0)

	getprm( -2,0,1 );
	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,0 );
	if (rstat!=0) return;

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".ASK" );
	a=ask_pic( bname,anibuf,p2*80+(p1>>3) );
	if (a!=0) { rstat=5;return; }
	qpmode=0;

return; }


static cc_page()
{
	//	page a_page,d_page

	pg1=getprm( pg1,1,1 );
	pg2=getprm( pg2,1,0 );
	if (rstat!=0) return;

	set_page( pg1,pg2 );
return; }


static cc_scroll()
{
	//	scroll dir(0),len(400),step(1)

	p1=getprm( 0,1,1 );
	p2=getprm( 400,400,1 );
	p3=getprm( 1,4,0 );if (p3==0||p2==0) { rstat=2; }
	if (rstat!=0) return;

	gscroll(p1,p2,p3);

return; }


static cc_qp()
{
	//	qp "file",x,y

	getprm( -2,0,1 );
	p1=getprm( 192,639,1 );
	p2=getprm( 116,399,0 );
	if (rstat!=0) return;

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".QP" );

	a=seg_load2( bname,anihed,aniseg );
	if (a!=0||an[63]!=0x5051) { rstat=5;return; }
	qpmode=1;qpofs=p2*80+(p1>>3);

return; }


static cc_anime()
{
	//	anime start(1),end(def),times(3),adpls(0)

	if (qpmode==0) { rstat=6;return; }
	p1=getprm( 1,63,1 );
	p2=getprm( an[0],63,1 );if (p1==0||p2==0) { rstat=2; }
	p3=getprm( defsp,15,1 );
	p4=getprm( 0,0,0 );
	if (rstat!=0) return;

	b=1;l=p1;p=pg2^1;vwait(1);
	if (p2<l) { b=-1; }
	set_page(p^1,p);p=p^1;

	while(1) {
		ask_open( anibuf+an[l],qpofs );
		set_page(p^1,p);p=p^1;
		if (p3>0) { vwait( p3 ); }
		if (l==p2) { break; }
		l=l+b;
		qpofs=qpofs+p4;
	}

return; }


static cc_escape()
{
	//	escape flag(1)

	defstp=getprm( 1,1,0 );
	if (rstat!=0) return;
return; }


static cc_pcopy()
{
	//	pcopy srcpage(0),size_x(640),size_y(400)

	p1=getprm( 0,1,1 );
	p2=getprm( 640,640,1 );
	p3=getprm( 400,400,0 );
	if (rstat!=0) return;
	g_copy2( 0,0,p2,p3,0,0,p1 );
	set_page( pg1,pg2 );
return; }


static cc_gcopy()
{
	//	gcopy srcpage(0),x1(0),y1(0),x2(640),y2(200),dstpage(0),tx(0),ty(200)

	p1=getprm( 0,1,1 );
	p2=getprm( 0,639,1 );
	p3=getprm( 0,399,1 );
	x=getprm( 640,640,1 );
	y=getprm( 200,400,1 );
	p6=getprm( 0,1,1 );
	p7=getprm( 0,639,1 );
	p8=getprm( 200,399,0 );
	if (x==0||y==0) rstat=2;
	if (rstat!=0) return;

	if (p1!=p6) {
		if (x<16) x=16;
		g_copy2( p2,p3,x,y,p7,p8,p1 );
		}
	else {
		if (x<8) x=8;
		set_page( p1,pg2 );
		g_copy( p2,p3,x,y,p7,p8 );
		}

	set_page( pg1,pg2 );

return; }


static cc_mplay()
{
	//	mplay musofs(0)

	if (mumode==0) { rstat=7;return; }
	p1=getprm( 0,musseg<<4,0 );
	if (rstat!=0) return;

	p1=p1>>1;

	if (midien==0) {
		mlfp_setup( mdt+p1 );
		mlfp_go();
		}

	if (midien==1) {
		play_setup( buffer );
		play_start();
		}


return; }


static cc_mstop()
{
	//	mstop speed(0)

	if (mumode==0) { rstat=7;return; }
	p1=getprm( 0,15,0 );
	if (rstat!=0) return;

	if (midien==0) {
		if (p1>0) {
			for (b=0;b<128;b=b+p1)
			{ mlfp_setvol( b );vwait( 1 ); }
			}
		mlfp_stop();
		}
	if (midien==1) play_stop();

return; }


static cc_midi()
{
	//	midi "file",musofs(0)

	getprm( -2,0,1 );
	p2=getprm( 0,musseg<<4,0 );
	if (rstat!=0) return;
	if (midien!=1) { rstat=14;return; }

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".AXT" );
	a=read_obj( bname );
	if (a!=0) { rstat=5;return; }

	mumode=1;

return; }


static cc_music()
{
	//	music "file",musofs(0)

	getprm( -2,0,1 );
	p2=getprm( 0,musseg<<4,0 );
	if (rstat!=0) return;
	if (midien!=0) { rstat=14;return; }

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".MLO" );
	b=p2>>4;
	a=seg_load2( bname,musbuf+b,musseg<<5 );
	if (a!=0) { rstat=5;return; }
	mumode=1;

return; }


static cc_mcopy()
{
	//	mcopy wrtpage(0),fadetype(0),sel color(0)

	p1=getprm( 0,0,1 );
	p2=getprm( 0,0,1 );
	p3=getprm( 0,0,0 );
	if (rstat!=0) return;
	if (p2==0) { msk_merge( picbuf,p3 ); }
		else {
		msk_merge2( picbuf,p3,p1,p2,16 );
		}
	set_page( pg1,pg2 );
return; }


static cc_mask()
{
	//	mask sel color(0)

	p1=getprm( 0,0,0 );
	if (rstat!=0) return;
	msk_make( mskbuf,p1 );
return; }


static cc_get()
{
	//	get xx(0),yy(0),sx(640),sy(100),srcbuf(0)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 640,640,1 );
	p4=getprm( 100,400,1 );
	p5=getprm( 0,aniseg,0 );
	if (rstat!=0) return;
	msk_get( srcbuf+p5,p2*80+(p1>>3),p3,p4 );
return; }


static cc_put()
{
	//	put xx(0),yy(0),sx(640),sy(100),srcbuf(0)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 640,640,1 );
	p4=getprm( 100,400,1 );
	p5=getprm( 0,aniseg,0 );
	if (rstat!=0) return;
	msk_put( srcbuf+p5,p2*80+(p1>>3),p3,p4 );
return; }


static cc_mput()
{
	//	mput xx(0),yy(0),sx(640),sy(100),srcbuf(0)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 640,640,1 );
	p4=getprm( 100,400,1 );
	p5=getprm( 0,aniseg,0 );
	if (rstat!=0) return;
	msk_mput( srcbuf+p5,p2*80+(p1>>3),p3,p4 );
return; }


static cc_lget()
{
	//	lget xx(0),yy(0),sx(640),sy(400),srcbuf(0),plane(15)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 640,640,1 );
	p4=getprm( 400,400,1 );
	p5=getprm( 0,aniseg,1 );
	p6=getprm( 15,15,0 );
	if (rstat!=0) return;
	msk_lget( srcbuf+p5,p2*80+(p1>>3),p3,p4,p6 );
return; }


static cc_lput()
{
	//	lput xx(0),yy(0),sx(640),sy(400),srcbuf(0),plane(15)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 640,640,1 );
	p4=getprm( 400,400,1 );
	p5=getprm( 0,aniseg,1 );
	p6=getprm( 15,15,0 );
	if (rstat!=0) return;
	msk_lput( srcbuf+p5,p2*80+(p1>>3),p3,p4,p6 );
return; }


static cc_if()
{
	//	if prm ( if prm is true,execute current line )

	p1=getprm( -1,0,0 );
	if (rstat!=0) return;

	if (p1==0) { gs_pget(&p1,&p2,&p3);gs_pput(p1,p2,0); }	// if false skip current line
return; }


static cc_inkey()
{
	//	inkey minnum,maxnum,realtimeflg  ( keyvalue returns to pval[0] )

	p1=getprm( 0x31,255,1 );
	p2=getprm( 0x33,255,1 );
	p3=getprm( 0,1,0 );
	if (rstat!=0) return;

	if (p3) { pval[0]=joyin();return; }
	while(1) { p3=getch();
		   if (p3==27) {
		   		if (defstp) rstat=99;
		   		p1=0;p3=-1;break; }
		   if ((p3>=p1)&&(p3<=p2)) break; }
	pval[0]=p3-p1;
return; }


static cc_exec()
{
	//	exec "filename"

	getprm( -2,0,0 );
	if (rstat!=0) return;
	gs_cpy(ename,v2);rstat=-1;
return; }


static cc_child()
{
	//	child "filename" [,"prm1","prm2"]

	getprm( -2,0,1 );
	if (rstat!=0) return;
	gs_cpy(clname,v2);
	p1=0;

	getprm( -2,0,1 );
	if (rstat==0) {
		p1++;gs_cpy(clopt1,v2);
		}

	getprm( -2,0,0 );
	if (rstat==0) {
		p1++;gs_cpy(clopt2,v2);
		}

	//	一時的にメモリ開放
	//
	freemem( picbuf );
	freemem( anihed );

	rstat=0;if (p1==0) a=spawnl( P_WAIT,clname,clname );
	else	if (p1==1) a=spawnl( P_WAIT,clname,clname,clopt1 );
	else	if (p1==2) a=spawnl( P_WAIT,clname,clname,clopt1,clopt2 );

	pval[0]=a;

	//	ふたたび確保
	//
	a=allocmem( aniseg , &anihed );
	if (a==-1) a=allocmem( picseg , &picbuf );
	if (a!=-1) { printf("親プロセスのメモリの確保ができません。実行を中止します。");
		     ginit(1,0,0);t_on();getch();exit(1); }

return; }


static cc_repeat()
{
	//	repeat

	p1=getprm( 0,0,0 );
	if (rstat!=0) return;
	looptime=p1;

	gs_pget( &rp_ofs,&rp_lin,&p1 );
return; }


static cc_loop()
{
	//	loop

	if (rp_lin==0) { rstat=9;return; }
	if (looptime>0) {
		looptime--;
		if (looptime==0) return;
	}
	gs_pput( rp_ofs,rp_lin,0 );
return; }


static cc_goto()
{
	//	goto *label

	if (w_nx!='*') { rstat=10;return; }
	skipp();p1=getprm( -1,lbmax,0 );
	if (rstat!=0) return;
	p2=lb_ofs[p1];
	if (p2==0) { rstat=9;return; }
	gs_pput( p2,lb_lin[p1],0 );
return; }


static cc_gosub()
{
	//	gosub *label

	if (w_nx!='*') { rstat=10;return; }
	skipp();p1=getprm( -1,lbmax,0 );
	if (rstat!=0) return;
	p2=lb_ofs[p1];
	if (p2==0) { rstat=9;return; }
	if (sr_nest>srmax) { rstat=11;return; }
	p3=sr_nest;sr_nest++;
	gs_pget( &sr_ofs[p3],&sr_lin[p3],&sr_hofs[p3] );
	gs_pput( p2,lb_lin[p1],0 );
return; }


static cc_return()
{
	//	return

	if (sr_nest==0) { rstat=12;return; }
	sr_nest--;p3=sr_nest;
	gs_pput( sr_ofs[p3],sr_lin[p3],sr_hofs[p3] );
return; }


static cc_run()
{
	//	run "filename"

	getprm( -2,0,0 );
	if (rstat!=0) return;
	gs_cpy(fname,v2);rstat=-1;nxt_prg++;
return; }


static cc_mono()
{
	//	mono

	for(a=0;a<16;a++) { pal_set( a,a*0x111 ); }
return; }


static cc_rgb()
{
	//	rgb "file"

	getprm( -2,0,1 );
	if (rstat!=0) return;

	gs_cpy( bname,v2 );gs_cut( bname,'.' );
	gs_cat( bname,".RGB" );
	a=seg_load2( bname,rgbbuf,48>>4 );
	if (a!=0) { rstat=5;return; }
	b=0;for(a=0;a<16;a++) {
			 pal_set( a,(rgbf[b+1]<<8)+(rgbf[b]<<4)+rgbf[b+2] );
			 b=b+3;
			 }
return; }


static cc_rnd()
{
	//	rnd %val,val

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p1=getprm( -1,lbmax,1 );
	p2=getprm( 255,0,0 );
	if (rstat!=0) return;
	pval[p1]=rand()%p2;
return; }


static cc_bload()
{
	//	bload "file",srcbuf(0)

	getprm( -2,0,1 );
	p1=getprm( 0,aniseg,0 );
	if (rstat!=0) return;

	a=seg_load2( v2,srcbuf+p1,aniseg );
	if (a!=0) { rstat=5;return; }
return; }


static cc_bsave()
{
	//	bsave "file",srcbuf(0),length seg(*)

	getprm( -2,0,1 );
	p1=getprm( 0,aniseg,1 );
	p2=getprm( -1,aniseg,0 );
	if (rstat!=0) return;

	a=seg_save2( v2,srcbuf+p1,p2 );
	if (a!=0) { rstat=5;return; }
return; }


static cc_boxf()
{
	//	boxf sx(0),sy(0),ex(639),ey(399),color(15)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 639,639,1 );
	p4=getprm( 399,399,1 );
	p5=getprm( 15,15,0 );
	if (rstat!=0) return;
	GraphicBoxf( p1,p2,p3,p4,p5 );
return; }


static cc_poke()
{
	//	poke bufadr,value(byte)

	p1=getprm( -1,0,1);
	p2=getprm( -1,0,0);
	if (rstat!=0) return;
	pokebf[p1]=p2;
return; }


static cc_peek()
{
	//	peek %val,bufadr(byte)

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p1=getprm( -1,lbmax,1 );
	p2=getprm( -1,0,0 );
	if (rstat!=0) return;
	pval[p1]=pokebf[p2];
return; }


static cc_mtick()
{
	//	mtick %val

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p1=getprm( -1,lbmax,0 );
	if (rstat!=0) return;
	pval[p1]=mlfp_gettick();
return; }


static cc_console()
{
	//	console y1(0),y2(24),x(0),py(16)

	p1=getprm( cony1,23,1);
	p2=getprm( cony2,25,1);
	p3=getprm( conx,79,1);
	p4=getprm( 16,399,0);
	if (rstat!=0) return;

	if (p2>24) p2=24;
	if (p1>p2) { p3=p1;p1=p2;p2=p3; }
	cony1=p1;cony2=p2;conx=p3;
	csrx=p3;csry=p1;csrgy=p1<<4;conpy=p4;

	GraphicBoxf( 0,cony1<<4,639,(cony2<<4)+15,bgcol );
return; }


static cc_mswait()
{
	//	mswait %val1 , %val2 , %val3

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p1=getprm( -1,lbmax,1 );

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p2=getprm( -1,lbmax,1 );

	v1=gs_getw( s4,v1,&w_tp,&w_nx );
	v4=s4[0];if (v4!='%') { rstat=2;return; }
	p3=getprm( -1,lbmax,0 );

	if (rstat!=0) return;

	while(1) {
		ms_proc();vwait(1);
		a=ms_trg & 0xe0;
		if (a>0) {
			if (a&32) rstat=99;
			break;
		}
	}
	pval[0]=a>>6;
	a=ms_cbox();
	if (a==-1) a=0; else a=ms_cget(a);
	pval[p1]=a;
	pval[p2]=ms_xx;
	pval[p3]=ms_yy;
	ms_wipe();
return; }


static cc_msset()
{
	//	msset x(0),y(0)

	p1=getprm( 0,639,1);
	p2=getprm( 0,399,0);
	if (rstat!=0) return;

	ms_locate( p1,p2 );
return; }


static cbreset()
{
	ms_cinit( rgbbuf,64 );
	mscb=0;
	csrx=conx;csry=cony1;csrgy=cony1<<4;
return; }


static cc_msarea()
{
	//	msarea x1(0),y1(0),x2(639),y2(399)

	p1=getprm( 0,639,1);
	p2=getprm( 0,399,1);
	p3=getprm( 0,639,1);
	p4=getprm( 0,399,0);
	if (rstat!=0) return;

	ms_area( p1,p2,p3,p4 );
return; }


static cc_msbox()
{
	//	msbox x1(0),y1(0),x2(639),y2(399),flag(1),draw(99)

	p1=getprm( 0,639,1);
	p2=getprm( 0,399,1);
	p3=getprm( 0,639,1);
	p4=getprm( 0,399,1);
	p5=getprm( 1,0,1);
	p6=getprm( 99,15,0);
	if (rstat!=0) return;

	ms_cset( mscb, p5, p1, p2, p3, p4 );
	mscb++;if (mscb==64) mscb=63;
	if (p6<16) {
		GraphicBoxf( p1,p2,p3,p4,0 );
		GraphicBoxf( p1+2,p2+2,p3-2,p4-2,p6 );
	}

return; }


static cc_mschr()
{
	//	mschr xx(0),yy(0),hx(0),hy(0)

	p1=getprm( 0,639,1 );
	p2=getprm( 0,399,1 );
	p3=getprm( 0,23,1 );
	p4=getprm( 0,23,0 );
	if (rstat!=0) return;

	msk_lget( mosbuf+0x100,p2*80+(p1>>3),32,24,15 );
	ms_chr( 0,p3,p4 );
	ms_wipe();
return; }


