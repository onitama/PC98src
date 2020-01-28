	/*

		Advanced SOUP compiler ver.A
					started.1993/6 onitama
					restart.1995/6 onitama
	*/

	#define	lbl_size	4096	// 64K label search buffer
	#define	src_size	4096	// 64K source text buffer
	#define	cgb_size	4096	// 64K code generate buffer
	#define	stb_size	4096	// 64K string data buffer
	#define	lbb_size	512	//  8K label info buffer ( 2048lbl )

	#include <alloc.h>
	#include <stdio.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <string.h>
	#include <dos.h>
	#include "gstring.h"
	#include "gstring.inc"
	#include "selbl.h"

	static	unsigned char	errf,sw_d,sw_h;
	static	unsigned char	bname[64],fname[64],sname[64];
	static	unsigned char	s1[256],s2[256],s3[256],s4[64];
	static	unsigned int	lblbuf,srcbuf,cgbbuf,stbbuf,lbbbuf,hedbuf;
	static	unsigned char	*v1,*v2,*v3;

	static	unsigned char	far *cgb;
	static	unsigned int	far *lbl;
	static	unsigned int	far *lbf;
	static	unsigned int	far *hdr;

	static	int	en[20],el[20];
	static	int	skp[20];
	static	int	error,anmode,anlast,pinf,llmax;
	static	int	skl,rp_flag,rp_brk,rp_ptr,locmod,lfflg,lfwpt;

	static	unsigned int	cgpt;
	static	unsigned int	stpt;
	static	unsigned int	newv;
	static	unsigned int	newv2;
	static	unsigned int	newl;
	static	unsigned int	lflbl;

	static	int	a,b,c,w_op,w_kw,w_tp;
	static	char	a1,a2,a3,w_nx;


main( int argc,char *argv[] )
{
	//	check command line

	strcpy(bname,"none");
	errf=0;sw_d=0;sw_h=0;

	printf("Advanced SOUP compiler ver.A1\n");
	if (argc < 2 ) {
		usage1();return -1;
	}

	for (b=1;b<argc;b++) {
		a1=*argv[b];a2=tolower(*(argv[b]+1));
		if ( a1!='/' ) {
			strcpy(bname,argv[b]);	}
		else {
			switch (a2) {
			case 'h':
				sw_h=1;break;
			case 'd':
				sw_d=tolower(*(argv[b]+2));break;
			default:
				errf=1;break;
			}
		}
	}
	if (sw_h) { usage2();return 0; }
	if (errf) { printf("\nIllegal switch selected.");return 1; }

	if (strcmp(bname,"none")) {
		strcpy(fname,bname);strcat(fname,".as");
		if (sw_d==0) { strcpy(sname,bname);strcat(sname,".ax"); }
			else { strcpy(sname,"g:");sname[0]=sw_d;
			       strcat(sname,bname);strcat(sname,".ax"); }
	}

	//	prepare buffer

	a=allocmem( src_size,&srcbuf );
	a=allocmem( lbl_size,&lblbuf );
	a=allocmem( cgb_size,&cgbbuf );
	a=allocmem( stb_size,&stbbuf );
	a=allocmem( lbb_size,&lbbbuf );
	if (a!=-1) { printf("MS-DOSのメモリが足りないのでだめです。\n");return -1; }

	hedbuf=cgbbuf;cgbbuf+=2;
	hdr=MK_FP( hedbuf,0 );
	cgb=MK_FP( cgbbuf,0 );
	lbl=MK_FP( lbbbuf,0 );
	lbf=MK_FP( lbbbuf+(lbb_size>>1),0 );
	a=seg_load( fname,srcbuf,0xffff );
	if ( a==1 ) { printf("指定されたファイルがみつかりません。[%s]\n",fname);return -1; }

	gs_init( srcbuf,';',':' );
	sl_init( lblbuf );
	set_preinf();

	comp_main();

	if (error==0) printf("No error detected.\n");
	else if (error>0) {
		errprt();
		if (error==20) printf("Too many errors.\n");
		 else printf("%d error(s) detected.\n",error);
		return -1;
	}

	//	make header information

	for(a=0;a<0x10;a++) { hdr[a]=0; }
	hdr[0]=0x7341; hdr[1]=0x6f70;
	hdr[3]=cgpt;
	hdr[4]=newv;
	hdr[5]=newv2;

	//	save object file

	cgpt=gs_cdbuf( stbbuf,stpt,cgbbuf,cgpt );
	seg_save( sname,hedbuf,cgpt+0x20 );

	return 0;
}


usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: glc [options] [filename]",
	"		  /d*	set output drive to *",
	"		  /h	help about GLC",
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
	rec,"・Advanced SOUP compiler は…",
	rec,
	"　　中小規模のツール作成，ゲームプログラム作成に威力を発揮する",
	"　　BASICライクなPC98ｼﾘｰｽﾞ用のインタプリタ言語のコンパイラです。",
	"　　覚えやすく簡単に使えて、コンパイル速度も快適な Advanced SOUP は、",
	"　　あなたに新たな環境を提供することでしょう。",
	"　　ASC.COM はテキストファイルを中間コードに翻訳して AXファイルに",
	"　　出力します。さらに詳しい説明は、ドキュメントをご覧ください。",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}

mkerr( int a )
{
	//	error sequence

	if (error==20) { return 1; }
	en[error]=a;el[error]=gs_info(3);
	error++;

	return 0;
}

errprt()
{
	//	print error message

	int i;
	if (error==0) { return 0; }
	for (i=0;i<error;i++) {
		printf("  %s (%d)\t: ",fname,el[i]);
		errmes(en[i]);printf("\n");
	}
	return 0;
}

errmes( int a )
{
	if ( a==1 ) { printf("");return 0; }
	if ( a==2 ) { printf("1行が255文字を越えた");return 0; }
	if ( a==3 ) { printf("使用できない文字が含まれている");return 0; }
	if ( a==4 ) { printf("ラベルに使用できない単語");return 0; }
	if ( a==5 ) { printf("数値の指定が違う");return 0; }
	if ( a==6 ) { printf("ラベルが重複している");return 0; }
	if ( a==7 ) { printf("elseの位置がおかしい");return 0; }
	if ( a==8 ) { printf("repeatが重複している");return 0; }
	if ( a==9 ) { printf("breakがループ内にない");return 0; }
	if ( a==10 ) { printf("breakが重複している");return 0; }
	if ( a==11 ) { printf("loopの位置がおかしい");return 0; }
	if ( a==12 ) { printf("repeatに対応するloopがない");return 0; }
	if ( a==13 ) { printf("define命令の書式が違う");return 0; }

	printf("??すごすぎる");return 1;
}


set_preinf()
{
	//	reserved word set

static 	char 	rec[1]= "", *p[] =
{
	rec,
	"if,12,0",
	"else,13,0",
	"end,0,$8f",
	"goto,0,$b1",
	"gosub,0,$b2",
	"local,0,$b3",
	"getstr,0,$b4",
	"repeat,0,$b8",
	"break,0,$b9",
	"loop,0,$ba",
	"define,0,$bb",

	"int,0,$c0",
	"var,0,$c0",
	"data,0,$c0",
	"print,0,$c1",
	"openw,0,$c2",
	"mess,0,$c3",
	"closew,0,$c4",
	"aska,0,$c5",
	"scinit,0,$c6",
	"scwait,0,$c7",
	"scron,0,$c8",
	"scroff,0,$c9",
	"scfix,0,$ca",
	"icon,0,$d0",
	NULL
};
	int i;
	for(i=1; p[i]; i++)
		{
		v1=p[i];
		v1=gs_getw( s1,v1,&b,&a1 );
			if (b!=1) { printf("予約語の名称エラー[%s]\n",s1);return 1; }
			if (a1!=',') { printf("予約語設定項目数エラー[1]\n");return 2; }
			v1++;
		v1=gs_getw( s2,v1,&b,&a1 );
			if (b!=3) { printf("予約語の設定TYPEエラー[%s]\n",s2);return 3; }
			if (a1!=',') { printf("予約語設定項目数エラー[1]\n");return 4; }
			v1++;
		v1=gs_getw( s3,v1,&b,&a1 );
			if (b!=3) { printf("予約語の設定OPTIONエラー[%s]\n",s3);return 5; }

		a=gs_wtoi( s2,&b )|gs_wtoi( s3,&c );
			if (a) { printf("予約語設定値エラー[%s][%s]\n",s2,s3);return 6; }

		sl_make( s1,c,b );
		//printf( "regist [%s] ... type[%d][%d]\n",s1,b,c );
		}
	return 0;
}


comp_main()
{
	//	compiler main

	cgpt=0;stpt=0;newv=0;newv2=0;newl=0;llmax=0;
	error=0;skl=0;rp_flag=0;rp_brk=0;

	while(1) {
		pinf=gs_getp( s2,s1 );v1=s2;
		if (pinf==1) break;
		if (pinf>1) mkerr(a);
		//printf( "analysis [%s]\n",s2 );
		wchk();
		if (pinf==-1) if (skl) fixskl();
	}

	if (rp_flag) mkerr(12);

	cgb[cgpt++]=0x8f;				// end of prg.code

	b=0;
	if (newl>0) {
		for(a=0;a<newl;a++) {
			c=lbl[a];
			//if (c>=0) printf("label%d=[%x]\n",a,c);
			if (c==-2) {
				if (b==0) printf("undefined label(s):\n");
				sl_getnam(s1,lbf[a]);printf( "\t%s",s1 );
				b++;
			}
		}
		if (b>0) printf( "\n%d label(s) missing.\n",b );
	}

	if ((error==0)&&(b==0)) sl_lblset( cgbbuf,lbbbuf );

	return 0;
}

static	wchk()
{
	//	word analysis

	anmode=0;anlast=cgpt;locmod=0;

	while(1) {
		v1=gs_getw( s3,v1,&w_tp,&w_nx );
		if (w_tp==0) break;
		//printf( "\tstr(%d) [%s]\n",w_tp,s3 );

		// ラベルgenerate
		if (w_tp==1) lblgen();

		// 数値generate
		else if (w_tp==3) numgen();

		// 記号generate
		else if (w_tp==2) kiggen();

		// 文字列generate
		else if (w_tp==4) {
			//printf("文字列ptr=[%d]\n",stpt);
			if (w_nx=='+') {
				v1++;stpt--;
				stpt=gs_stbuf( s3,stbbuf,stpt );
			} else {
				cgb[cgpt++]=0xfd;		// str ptr.
				cgb[cgpt++]=stpt&0xff;
				cgb[cgpt++]=stpt>>8;
				stpt=gs_stbuf( s3,stbbuf,stpt );
			}
		}

	if (anmode>=0) anmode++;
	}

	if (anlast!=cgpt) cgb[cgpt++]=0x80;
	if (rp_flag==1) { rp_flag++;rp_ptr=cgpt; }
	return 0;
}


static lblgen()
{
	c=sl_find( s3,&w_op,&w_kw );

	// found label

	if (c>=0) {
		//printf( "\tlabel[%d]\n",w_op );

		if (anmode==-1) {
			a1=w_kw&15;a=lbl[w_op];
			if (a1!=4) { mkerr(4);return; }
			if (a!=-2) { mkerr(6);return; }
			cgpt--;lbl[w_op]=cgpt;
			return;
			}
		if (w_kw==0) {
			cgb[cgpt++]=w_op&0xff;
			if (w_op<0xb8) {
				if (w_op==0xb3) locmod++; else anmode=-2;
				return;			// jump系 command
				}
			if (w_op<0xc0) {
				spccom();return;	// special command
				}
			}
		else {
			a1=w_kw&15;
			if (a1==13) { elskl();return; }	// elseの処理
			cgb[cgpt++]=0xf0+a1;
			if (a1==12) skp[skl++]=cgpt;	// ifのskip先check
			cgb[cgpt++]=w_op&0xff;
			cgb[cgpt++]=w_op>>8;
			}
		return;
	}

	// when not found

	if (anmode==-1) {
		cgpt--;lbl[newl]=cgpt;
		sl_make( s3,newl,4 );newl++;
		return;
	}
	if (anmode<0) {
		a1=0x14;c=newl;
		a=sl_make( s3,c,a1 );
		cgb[cgpt++]=0xf0+(a1&15);
		cgb[cgpt++]=c&0xff;
		cgb[cgpt++]=c>>8;
		lbl[newl]=-2;lbf[newl]=a;newl++;
		}
	else  {
		if (locmod) { a1=0x16;c=newv2;newv2++; }	// local val
			else { a1=0x13;c=newv;newv++; }		// norm val
		sl_make( s3,c,a1 );
		cgb[cgpt++]=0xf0+(a1&15);
		cgb[cgpt++]=c&0xff;
		cgb[cgpt++]=c>>8;
		}

	return;
}


static numgen()
{
	if ( gs_wtoi(s3,&a)!=0 ) { mkerr(5);return; }

	if (anmode==-1) {
		cgpt--;
		lflbl=cgpt;
		//printf("CON=(%d)\n",lflbl);
		if (lfflg>0) {				// local forward fix
			cgb[lfwpt++]=lflbl&0xff;
			cgb[lfwpt++]=lflbl>>8;
			lfflg=0;
			}
		return;
	}
	if (anmode==-2) {				// local label check
		if (a>0) { lfflg++;lfwpt=cgpt+1;lflbl=0; }
		cgb[cgpt++]=0xf5;
		cgb[cgpt++]=lflbl&0xff;
		cgb[cgpt++]=lflbl>>8;
		return;
	}


	//printf("数値=[%d]\n",a);
	if (a<0) {
		cgb[cgpt++]=0xff;	// full code
		cgb[cgpt++]=a&0xff;
		cgb[cgpt++]=a>>8;
		} else {
		cgb[cgpt++]=a>>8;	// norm code
		cgb[cgpt++]=a&0xff;
		}
	return;
}


static fixskl()
{
	a1=cgpt&0xff;a2=cgpt>>8;
	for(a=0;a<skl;a++) {
		b=skp[a];cgb[b]=a1;cgb[b+1]=a2;
	}
	skl=0;
	return;
}

static elskl()
{
	if (skl==0) { mkerr(7);return; }
	a=skp[skl-1];if (cgb[a-1]!=0xfc) { mkerr(7);return; }
		cgb[cgpt++]=0x80;
		cgb[cgpt++]=0xf5;
		skp[skl-1]=cgpt;cgpt+=2;

		a1=cgpt&0xff;a2=cgpt>>8;
		cgb[a]=a1;cgb[a+1]=a2;
	return;
}

static spccom()
{
	if (w_op==0xb8) {
		if (rp_flag) { mkerr(8);return; }
		rp_flag=1;rp_brk=0;
		return; }
	if (w_op==0xb9) {
		if (rp_flag==0) { mkerr(9);return; }
		if (rp_brk) { mkerr(10);return; }
		cgb[cgpt-1]=0xb1;
		cgb[cgpt++]=0xf5;
		rp_brk=cgpt;cgpt+=2;
		return; }
	if (w_op==0xba) {
		if (rp_flag==0) { mkerr(11);return; }
		rp_flag=0;a1=rp_ptr&0xff;a2=rp_ptr>>8;
		cgb[cgpt++]=0xf5;
		cgb[cgpt++]=a1;cgb[cgpt++]=a2;
		if (rp_brk) {
			a1=cgpt&0xff;a2=cgpt>>8;
			cgb[rp_brk]=a1;cgb[rp_brk+1]=a2;
		}
		return; }
	if (w_op==0xbb) {
		v1=gs_getw( s3,v1,&w_tp,&w_nx );
		if (w_tp!=1) { mkerr(13);return; }
		c=sl_find( s3,&w_op,&w_kw );
		if (c>=0) { mkerr(13);return; }
		strcpy(s4,s3);

		v1=gs_getw( s3,v1,&w_tp,&w_nx );
		if (w_tp!=3) { mkerr(13);return; }
		if ( gs_wtoi(s3,&a)!=0 ) { mkerr(13);return; }

		a1=0x13;				// define val ptr.
		sl_make( s4,a,a1 );
		cgpt--;
	}

	return;
}


static kiggen()
{
	if (anmode<0) return;

	a1=s3[0];
	if (a1==0x2a) if (anmode==0) anmode=-1;		// label mode
	if (a1==0x5c) if (anmode==0) anmode=-2;		// gosub mode
	cgb[cgpt++]=a1+0x70;				// short code
	//printf("記号=[%d]\n",a1);
	return;
}

