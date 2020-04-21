	/*
			RTOM.EXE
				onion software 1993,94(c)
	*/

	#include <stdio.h>
	#include <sys\stat.h>
	#include <fcntl.h>
	#include <dos.h>

	#include "gstring.h"
	#include "mgint.h"
	#include "mgint.inc"

	static	int a,b,c,d,e,m,n,fsize;
	static	int conmode,qlev,vlev,gthos,meas;
	static	int defst,defgt,defot,defvs,vsdiv,gtdiv;
	static	int mlfcv,mlfch,mlfcnt,mlfmt;
	static	char a1,a2;

	static	unsigned char d1,d2,d3,d4;
	static	unsigned char t1,t2,t3,t4;
	static	unsigned char s1[255];
	static	unsigned char s2[255];
	static	unsigned char s3[255];
	static	unsigned char fm1[255];
	static	unsigned char fm2[255];
	static	unsigned char fm3[255];
	static	unsigned char fname[40];
	static	unsigned char sname[40];
	static	unsigned char mml[60];
	static	unsigned char stst[32];
	static	unsigned char gtst[192];
	static	unsigned char *s0;
	static	unsigned char *v1,*v2,*v3;
	static	unsigned char far *datbuf;
	static	unsigned char far *trkbuf;
	static	unsigned int datseg;
	static	unsigned int dval[6]={ 0,0xf0,0xf8,0xfc,0xff };
	static	unsigned int fmoct[4];
	static	unsigned int fmuse[4];

	static	FILE *fp;


main( int argc,char *argv[] )
{
	printf("RCP to Music LALF converter version.A / cpr.(c)1994 onion software\n");

	/*	buffer allocate 	*/

	a=allocmem( 0x1000 , &datseg );
	if (a!=-1) { printf("メインメモリの容量が足りません。\n");return 1; }
	datbuf=MK_FP( datseg,0 );

	/*	reset value	*/

	conmode=0;gthos=1;mlfcv=1;
	qlev=0;vlev=0;

	/*	check command line	*/

	if (argc < 2 ) { usage1();return 0; }
	for (b=1;b<argc;b++) {

	s0=argv[b];d1=s0[0];d2=tolower(s0[1]);
	if ((d1=='/')||(d1=='-')) {
		if ((d2=='h')||(d2=='?')) { usage2();usage1();return 1; }
		if (d2=='n') gthos=0;
		if (d2=='c') conmode=1;
		if (d2=='q') qlev=atoi(s0+2);
		if (d2=='v') vlev=atoi(s0+2);
		if (d2=='t') mlfcv=atoi(s0+2);
		} else ucpy( fname,s0 );
	}

	/*	RCP data load		*/

	gs_cut( fname,'.' );gs_cpy( sname,fname );
	gs_cat( fname,".RCP" );gs_cat( sname,".MLF" );
	if (conmode) gs_cpy( sname,"con" );

	c=seg_load( fname,datseg,0xfff0 );if (c>0) {
		printf("ファイル %s を変換中。( %dbytes )\n",fname,c );
		fsize=c;
	}
	else {
		printf( "ファイル %s がありません。\n",fname );
		return 1;
	}

	/*	convert to Annex MIDI		*/

	fp=fopen( sname,"wt" );
	a=anxcnv();
	if (a==0) {
		printf( "%s にセーブしました。\n",sname );
	}
	else {
		if (a==1) printf("RCP HEADER error");
		printf("/ 変換に失敗しました。\n");
	}

	fputc( 0x1a,fp );fclose(fp);
	return 0;
}


static anxcnv()
{
	for(a=0;a<8;a++) { s1[a]=datbuf[a]; } s1[a]=0;
	if (gs_cmp( s1,"RCM-PC98" )==0) return 1;

	gs_cpy( mml,"c___c+__d___d+__e___f___f+__g___g+__a___a+__b___b+__" );
	for(a=0;a<52;a++) {
		d1=mml[a];if (d1=='_') mml[a]=0;
	}

	fprintf( fp,"\n//    MML convert data of %s : by RtoM / onion software 1994\n",fname );
	for(a=0;a<64;a++) { s1[a]=datbuf[0x20+a]; } s1[a]=0;
	fprintf( fp,"//    %s\n\nA t%d\n\n",s1,datbuf[0x1c1] );

	trkbuf=datbuf+0x586;n=1;

	while(1) {

		/*	track header	*/

		m=(trkbuf[1]<<8)+trkbuf[0];
		t1=trkbuf[4];t2=trkbuf[3];
		for(a=0;a<36;a++) { s2[a]=trkbuf[8+a]; } s2[a]=0;

		if (n==mlfcv) {
			defot=4;defst=24;defgt=0;defvs=0x70;
			vsdiv=dval[vlev];gtdiv=dval[qlev];

			fprintf( fp,"// track #%d  %s\n",n,s2 );

			b=44;prechk();
			if (defgt==0) gtdiv=0;
			if (gtdiv!=0) defgt&=gtdiv;
			if (vsdiv!=0) defvs&=vsdiv;
			defvs=120;
			sprintf( s1,"@13 l%d v%d o%d",192/defst,defvs/8,defot );
			fprintf( fp,"A %s\n",s1 );
			fprintf( fp,"B %s\n",s1 );
			fprintf( fp,"C %s\n",s1 );
			b=44;makemml();
			if (fm1[0]!=0) { mlfch=0;gs_cpy(s1,fm1);putline(); }
			if (fm2[0]!=0) { mlfch=1;gs_cpy(s1,fm2);putline(); }
			if (fm3[0]!=0) { mlfch=2;gs_cpy(s1,fm3);putline(); }
		}

		/*	next track	*/

		n++;
		fprintf( fp,"\n" );
		trkbuf+=m;
		if ((trkbuf-datbuf)>=fsize) break;

	}

	return 0;
}


static makemml()
{
	e=0;mlfch=0;
	for(a=0;a<3;a++) { fmoct[a]=defot;fmuse[a]=0; }
	fm1[0]=0;fm2[0]=0;fm3[0]=0;
	mlfmt=0;meas=192;

	while(1) {
		//	prepare FM ch.

		if (mlfch==0) gs_cpy(s1,fm1);
		else if (mlfch==1) gs_cpy(s1,fm2);
		else if (mlfch==2) gs_cpy(s1,fm3);
		defot=fmoct[mlfch];
		mlfcnt=fmuse[mlfch];

		//	check st length

		//printf("****%d , %d ch[%d]\n",e,mlfcnt,mlfch);

		if (mlfcnt>e) {
			mlfmt++;if (mlfmt<3) goto nxtbuf;
			printf("Warning : 3和音を越えてしまいました。\n");
			e=mlfcnt;
		}
		if (mlfcnt<e) {
			gs_cpy( s3,"r" );gs_cat( s1,s3 );
			a=e-mlfcnt;stlength();
			mlfcnt=e;
			gs_cat( s1," " );
		}

		//	convert sub

		d1=trkbuf[b];d2=trkbuf[b+1];d3=trkbuf[b+2];d4=trkbuf[b+3];b+=4;

		if (d1==0) {				// rest
			e+=d2;
		}
		else if ((d1<120)&&(d4==0)) {		// VS=0 (rest)
			e+=d2;
		}
		else if ((d1<120)&&(d3==0)) {		// GT=0 (rest)
			e+=d2;
		}
		else if (d1<120) {			// normal note
			tiechk();
			otval();
			vsval();
			gs_cpy( s3,mml+((d1%12)<<2) );
			gs_cat( s1,s3 );a=d3;stlength();
			//printf("tone [%s] time [%d] ch[%d]\n",s3,e,mlfch);
			e+=d2;mlfcnt+=d3;
		}
		else if (d1==0xf9) {			// loop start
			gs_cat( s1,"[" );
			gs_cat( s1," " );
		}
		else if (d1==0xf8) {			// loop end
			gs_cat( s1,"]" );
			if (d2==0) gs_cat( s1,"*" );
			else {
				itoa( d2,s2,10 );gs_cat( s1,s2 );
			}
			gs_cat( s1," " );
		}
		else if (d1<0xe0) {			// other command
			if (d2>0) {
				e+=d2;
			}
			gs_cat( s1," " );
		}

		if ((d1==0xfe)||(b>=m)) break;		// track end
		if (s1[70]!=0) putline();		// 70文字以上はNL

		//	put FM buffer

		if (mlfch==0) gs_cpy(fm1,s1);
		else if (mlfch==1) gs_cpy(fm2,s1);
		else if (mlfch==2) gs_cpy(fm3,s1);
		fmoct[mlfch]=defot;
		fmuse[mlfch]=mlfcnt;
		mlfmt=0;

		if (e>=meas) meas+=192;			// next meas
nxtbuf:
		mlfch++;if (mlfch==3) mlfch=0;

	}

	return 0;
}



static tiechk()
{
	//	タイのチェック

	if (meas<(mlfcnt+d3)) {
		a=b;
		while(1) {
			if (trkbuf[a]==d1) {
				d3+=trkbuf[a+2];
				trkbuf[a+2]=0;
				break;
			}
			a+=4;
			if (b>=m) {
				printf("タイの変換中にエラーが起きました。\n");
				break;
			}
		}
	}
	return 0;
}



static otval()
{
	//	オクターブ合わせ

	a=d1/12;
	while(1) {
		if (a==defot) break;
		if (a<defot) {
			defot--;gs_cat( s1,"<" );
		} else {
			defot++;gs_cat( s1,">" );
		}
	}
	return 0;
}


static vsval()
{
	//	ベロシティ合わせ

	if (vsdiv!=0) {	
		if ((d4&vsdiv)!=(defvs&vsdiv)) {
			gs_cat( s1,"v" );
			itoa( d4/8,s2,10 );gs_cat( s1,s2 );
			defvs=d4;
		}
	}
	return 0;
}



static stlength()
{
	//	Aの音長を変換 ( timebaseは48固定 )

	while(1) {
		d=0;
		if (a==144) gs_cat( s1,"2." );
		else if (a==72)  gs_cat( s1,"4." );
		else if (a==36)  gs_cat( s1,"8." );
		else if (a==18)  gs_cat( s1,"16." );
		else if (a==9 )  gs_cat( s1,"32." );

		else if (a>=192){ gs_cat( s1,"1" );d=192; }
		else if (a>=96) { gs_cat( s1,"2" );d=96; }
		else if (a>=48) { gs_cat( s1,"4" );d=48; }
		else if (a>=24) { gs_cat( s1,"8" );d=24; }
		else if (a>=12) { gs_cat( s1,"16" );d=12; }
		else if (a>=6 ) { gs_cat( s1,"32" );d=6; }
		else if (a>=3 ) { gs_cat( s1,"64" );d=3; }
		else if (a==2) { gs_cat( s1,"96" );d=2; }
		else { gs_cat( s1,"192" );d++; }

		if (d==0) break;
		a-=d;if (a==0) break;
		if (s3[0]!='r') gs_cat( s1,"&" );
		gs_cat( s1,s3 );
	}
	return 0;
}



static putline()
{
	//	１行ファイルに書きだし

	fprintf( fp,"%c %s\n",65+mlfch,s1 );
	s1[0]=0;s1[70]=0;
	return 0;
}


static prechk()
{
	//	トラック変換準備

	e=0;
	for(a=0;a<192;a++) { gtst[a]=0; }		// ゲートタイム統計
	for(a=0;a<32;a++) { stst[a]=0; }		// 音長の統計

	while(1) {
		d1=trkbuf[b];d2=trkbuf[b+1];d3=trkbuf[b+2];d4=trkbuf[b+3];b+=4;

		if ((d1>0)&&(d1<120)) {			// normal note
			if (e==0) { defot=d1/12;defvs=d4;e++; }
			a=0;if ( d2==192 ) a=1;
			else if ( d2==96 ) a=2;
			else if ( d2==48 ) a=4;
			else if ( d2==24 ) a=8;
			else if ( d2==12 ) a=16;
			else if ( d2==6  ) a=32;
			if (a!=0) stst[a]++;
			a=d2-d3;
			if (a>=0&&a<192) gtst[a]++;
		}
		if ((d1==0xfe)||(b>=m)) break;
	}

	//	音長決定
	e=0;d=0;
	for(a=0;a<32;a++) {
		if (stst[a]>d) { e=a;d=stst[a]; }
	}
	if (e>0) defst=192/e;

	//	Gate time 決定
	e=0;d=0;
	for(a=0;a<192;a++) {
		if (gtst[a]>d) { e=a;d=gtst[a]; }
	}
	if (e>0) defgt=e;

	return 0;
}





usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: rtom [options] [filename]",
	"		  /t???	convert RCP track set",
	"		  /n	no adjust multi tone GT",
	"		  /c	console output mode",
	"		  /h	help about RtoM",
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
	rec,"・RtoM は…",
	rec,
	"    レコンポーザーVer.2のデータファイル(*.RCP)をMusic LALF用の",
	"    MMLソースリストに変換するツールです。",
	"    1トラック分のリアルタイムデータを3CHにふりわけながら変換",
	"    する以外の用途には使用できません。",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "%s\n", p[i]);
	return 0;
}



//	大文字にしながらstrcpy
ucpy( unsigned char *dst , unsigned char *src )
{
	char vl;
	int lp,dp;
	lp=0;while(1) {
		vl=src[lp];if ( vl==0 ) break;
		dst[lp]=toupper(vl);
		lp++;
	}
	dst[lp]=0;
	return 0;
}


