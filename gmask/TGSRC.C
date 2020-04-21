	/*
	
	
	
	*/

	#define	picseg	0x4400		// 64K picture data buffer
	#define	objkaz	13		// number of total object
	#define	myskaz	12		// player mark No.
	#define	miskaz	12		// missile No.
	#define	enekaz	8		// enemy No.

	#include <stdio.h>
	#include <conio.h>
	#include <fcntl.h>
	#include <sys\stat.h>
	#include <dos.h>

	//#include "ANA.H"
	#include "PLAY.H"
	#include "DRIVEB.H"
	#include "gint.h"
	#include "gint.inc"
	#include "gmask.h"

	static	int a,b,c,d,p,m,x,y,z;
	static	int gdccl_save,aniofs,stage,pport,midien;
	static	int key_start,key_end,key_range,key_scale;
	static	int ene_level,gspeed,bar_yy,col_cnt,col_px;
	static	int jport,jwait,energy,life,power,cdown;
	static	unsigned char midich,mode;
	static	unsigned char d1,d2,d3;
	static	unsigned int far *an;
	static	unsigned int picbuf, anibuf, chrbuf;
	static	unsigned char mes[64];
	static	unsigned char *mbf;

	static	int fl[objkaz],wt[objkaz],xx[objkaz],yy[objkaz];
	static	int chr[objkaz],px[objkaz],py[objkaz];

	static char buffer[ 32000 ];



static void read_obj( char *filename , int bufofs )
{
	FILE *fp;

	fp = fopen( filename, "rb" );
	if ( fp == NULL ) {
		printf( "Can't open '%s'\n", filename );
		exit( 2 );
	}
	fread( buffer+bufofs , sizeof( char ), sizeof( buffer ), fp );
	fclose( fp );
}


main( int argc,char *argv[] )
{
	/*---------------------------------------------------------------
				initalize procedure
	---------------------------------------------------------------*/

	printf("midi tacoragael version.A / onion software (c)1993\n");
	midien=1;if (argc>1)
			if (strcmp(argv[2],"/N")) midien=0;
	if (midien==0) printf("MIDIによる音楽演奏はしません。\n");
	else {
		a=mpu_board();
		if (a==0) printf("RS-MIDIによる音楽演奏をします。\n");
		else {  midien=2;
			printf("MIDI I/Fによる音楽演奏をします。\n"); }
	}

	srand( (unsigned)time() );		// for randomize

	//	memory allocate

	a=allocmem( picseg , &picbuf );
	if (a!=-1) { printf("メインメモリの容量が足りません。\n");
			return 1; }
	an=MK_FP( picbuf,0 );
	chrbuf=picbuf;
	anibuf=picbuf+8;

	//	screen inital

	ginit(1,0,0);
	if (_gc_set==0||_board16_set==0)
		{ printf("No GRCG or 16color board on your PC98.\nCan't execute.\n");
			return 1; }
	set_page(0,0);gcls(0);
	_setcursortype( _NOCURSOR );

	//	palette inital

	mbf=mpu_buffer();
	play_init();
	read_obj( "BOXEX_MT.AXT",0 );
	read_obj( "KK1.AXT",5000 );
	read_obj( "GO032_MT.AXT",10000 );
	read_obj( "OI3_MT.AXT",15000 );

	//	palette inital

	pal_init();

	//	system inital

	midich=7;stage=1;
	gdccl_save=gdc_clock(0);
	key_start=36;key_end=97;
	key_range=key_end-key_start;
	key_scale=7680/key_range;



	/*---------------------------------------------------------------
				demo sequence
	---------------------------------------------------------------*/

opdemo:
	mode=0;
	music_go( buffer );

	//	opening
	//
	l200init();
	kkini( 29,12 );
	tkprt( "昭和４３年　東京・銀座" );
	vepause(200);if (mode) goto abr_demo;


	//	morph phase
	//
	seg_load2( "KAMI.QP",picbuf,picseg );
	ask_aniini(6410);
	ask_anime(1);
	pal_on();
	kkini( 40,6 );
	tkprt( "神たま：" );
	tkprt( "「やぁ、みんな。がいーーん。」" );
	vepause(120);if (mode) goto abr_demo;
	y++;x=x+2;
	tkprt( "夜の銀座で人気者だった神たま。" );
	tkprt( "しかし、その正体は…｡" );
	vepause(120);if (mode) goto abr_demo;
	ask_anime(-1);
	y++;tkprt( "クレクレタコラだったのです｡" );
	vepause(120);if (mode) goto abr_demo;
	x=x-2;y++;
	tkprt( "タコラ：" );
	tkprt( "「クレクレ～！" );
	tkprt( "　ぼくの好きなおやつを" );
	tkprt( "　持ってきてクリャリンコ～。」" );
	vepause(120);if (mode) goto abr_demo;
	x=x+2;y++;tkprt( "町は大騒ぎです。" );
	vepause(150);if (mode) goto abr_demo;
	pal_clr();


	//	ginza scene
	//
	l200init();
	ask_pic("gokbg.ask",picbuf,4);
	pal_off();
	kkini( 17,10 );
	tkprt( "　突然、おやつを求め狂暴化したクレクレタコラは、" );y++;
	tkprt( "自分の星から UFO を呼び町を破壊し始めたのです。" );y++;
	tkprt( "事態を重く見た政府は、アルガーマンに助けを求める" );y++;
	tkprt( "こととなるのですが…。" );y++;
	vwait(0);
	for(a=0;a<16;a++) {
		b=a-3;if (b<0) b=0;
		pal_set(a,b*0x10);pal_show();
		vepause(20);if (mode) goto abr_demo;
	}
	vepause(300);if (mode) goto abr_demo;
	pal_clr();


	//	argar the man
	//
	seg_load2( "ARUS.QP",picbuf,picseg );
	ask_aniini(9640);
	ask_anime(1);
	pal_on();
	kkini( 6,9 );
	tkprt( "アルガーマン：" );
	tkprt( "「大変なことになった。" );
	tkprt( "　ああなっては、さすがの私も" );
	tkprt( "　手をだすことができない。」" );
	y++;
	tkprt( "「私が彼の希望通りに、" );
	tkprt( "　おやつを用意するから、" );
	tkprt( "　その間にタコラが呼んだUFOを" );
	tkprt( "　撃破してくれ。たのんだぞ。」" );
	ask_anime(0);
	if (mode) goto abr_demo;
	pal_clr();
	jport=0;


	/*---------------------------------------------------------------
				   title main
	---------------------------------------------------------------*/

abr_demo:
	play_stop();
	if (jport&32) goto prgbye;

	set_page(0,0);p=0;
	pal_off();t_cls();clrscr();
	ginit(1,0,1);
	ask_pic("tgtitle.ask",picbuf,0);
	hdbl();vdbl();
	kkini( 260,216 );
	kkprt( "onion software 1993(c)" );
	kkini( 202,378 );
	kkprt( "PRESS SPACE KEY TO START TACORAGAEL" );
	kkini( 202,388 );
	kkprt( "PRESS RETURN KEY TO KEYBOARD CONFIG" );
	pal_on();
	music_go( buffer+10000 );

	mbufclr();
	mode=0;b=600;
	while(1) {
		mpu_proc2();
		if (mbf!=mpu_endptr()) break;
		jport=joyin();
		if (jport&256) { mode=2;break; }
		if (jport&32) { mode=1;break; }
		if (jport&16) break;
		vwait(1);
		b--;if (b==0) { mode=3;break; }
	}

	play_stop();
	if (mode==1) goto prgbye;

	pal_clr();
	if (mode==3) goto opdemo;
	if (mode==2) {
		if (keycnf()) goto prgbye;
		goto abr_demo;
		}

	/*---------------------------------------------------------------
				main procedure
	---------------------------------------------------------------*/

gmain:
	l200init();
	ask_pic("gokbg.ask",picbuf,4);
	pal_set(0,0);
	seg_load( "TGCHR.BIN",chrbuf,0xfff0 );

	mbufclr();

	kkini( 32,12 );
	switch( stage ) {
		case 1:tkprt( "昭和４３年１２月" );break;
		case 2:tkprt( "昭和４４年１月" );break;
		case 3:tkprt( "昭和４４年２月" );break;
		case 4:tkprt( "昭和４４年３月" );break;
		case 5:tkprt( "昭和４４年４月" );break;
		}
	vepause(60);
	clrscr();

	x=320;y=64;z=8;
	ssp_init( chrbuf,objkaz );
	ssp_ext( chrbuf );
	ene_init();
	my_init();

	ene_level=1+stage*2;gspeed=2;col_cnt=0;
	cdown=0;mode=0;pal_on();
	music_go( buffer+5000 );

	while(1) {
		if (col_cnt>0) {
			col_cnt=col_cnt+col_px;
			if (col_cnt==15) col_px=-col_px;
			pal_set(0,col_cnt<<4);pal_show();
		}
		ssp_exec();vwait(gspeed);ssp_exec2();
		jport=joyin();
		ene_move();
		my_move();
		if (cdown>0) {
			cdown--;if (cdown==0) break;
		}
		if (jport&32) break;
		}

	play_stop();
	if (mode==0) goto prgbye;
	if (mode==2) {
		pal_rclr();vpause(100);goto abr_demo;
	}

	clrscr();pal_clr();


	/*---------------------------------------------------------------
				stage clear demo
	---------------------------------------------------------------*/

stclr:

	l200init();
	kkini( 32,12 );
	tkprt( "おやつの時間" );
	vpause(60);

	mode=0;
	ask_aniini(0);
	strcpy(mes,"ITEM0.ASK");mes[4]=mes[4]+stage;
	ask_pic(mes,picbuf,9290);
	pal_on();
	music_go( buffer+10000 );

	kkini( 40,8 );
	tkprt( "アルガーマン：" );

	if ( stage==5 ) {
		tkprt( "「タコラくん、それじゃあ" );
		tkprt( "　これはどうだい。」" );
	}
	else {
		tkprt( "「タコラくん、きみの為に" );
		tkprt( "　おやつを用意してあげたよ。」" );
	}
	vpause(200);

	switch( stage ) {

	case 1:
		tkprt( "「牛乳とパイゲンＣのセットだ。」" );y++;
		vpause(200);
		tkprt( "タコラ：" );
		tkprt( "「牛乳はキライだコラ。」" );
		tkprt( "「もっと、おやつを持ってこい。」" );
		break;

	case 2:
		tkprt( "「パンチサワーのセットだ。」" );y++;
		vpause(200);
		tkprt( "タコラ：" );
		tkprt( "「パンチサワーは甘すぎだコラ。」" );
		tkprt( "「もっと、おやつを持ってこい。」" );
		break;

	case 3:
		tkprt( "「デラックスアイスクリームと" );
		tkprt( "　ヤングクイーンのセットだ。」" );
		y++;
		vpause(200);
		tkprt( "タコラ：" );
		tkprt( "「おなかが冷えたよ。」" );
		tkprt( "「もっと、おやつを持ってこい。" );
		tkprt( "　　　イヤなら人類、みな殺し。」" );
		break;

	case 4:
		tkprt( "「バターとチーズのセットだ。」" );
		y++;
		vpause(200);
		tkprt( "タコラ：" );
		tkprt( "「なんなのこれは。」" );
		tkprt( "「もっと、おやつを持ってこい。」" );
		break;

	case 5:
		tkprt( "「明治スカット。」" );
		y++;
		vpause(200);
		tkprt( "タコラ：" );
		tkprt( "「クレクレ～～～～。」" );
		vpause(100);
		tkprt( "「ぼくが待っていたのは、" );
		tkprt( "　これだったんだ。明治スカット。」" );
		vpause(100);
		tkprt( "「とっても爽やか、明治スカット。」" );
		break;

	}

	vepause(450);pal_clr();
	play_stop();
	stage++;
	if (stage<6) goto gmain;


	/*---------------------------------------------------------------
				ending demo
	---------------------------------------------------------------*/

eddemo:

	//		ginza scene
	//
	ask_aniini(0);
	ask_pic("gokbg.ask",picbuf,4);
	vdbl();
	for(a=0;a<14;a++) {
		b=a-3;if (b<0) b=0;
		pal_set(a,b*0x10);
	}
	pal_set( 15,0xfff );pal_set( 14,0x888 );

	kkini( 220,230 );d=14;
	kkprt( "こうして、タコラはもとの姿に戻りました。" );
	kkprt( "ＵＦＯも星に帰り、町に平和が戻ってきたのです。" );
	kkprt( "だれも、神たまがタコラだと疑う者はいません。" );
	kkprt( "何しろ彼は、夜の銀座の人気者なのですから。" );

	pal_on();
	music_go( buffer+15000 );
	vepause(1500);
	pal_clr();


	//		credit screen
	//
	ask_aniini(0);
	kkini( 228,144 );
	kkprt( "DIRECTED AND PROGRAMMED BY" );
	kkprt( "        おにたま" );
	kkfade(-1);
	kkini( 228,144 );
	kkprt( "BACKGROUND MUSIC SCORE BY" );
	kkprt( "      ＯＸＹＧＥＮ" );y=y-16;
	kkprt( "        ＧＯＯＤ" );y=y-16;
	kkprt( "        おにたま" );
	kkfade(-1);
	kkini( 228,144 );
	kkprt( "  PROGRAM COOPERATED BY" );
	kkprt( "      T.ANAZAWA" );y=y-16;
	kkprt( "      XKD laboratory.");
	kkfade(-1);
	kkini( 228,144 );
	kkprt( "   SPECIAL THANKS TO" );
	kkprt( "       ＧＯＯＤ" );y=y-16;
	kkprt( "       ARGAR MAN");
	kkfade(-1);
	kkini( 228,144 );
	kkprt( "   COPYRIGHT (C)1993" );y=y-16;
	kkprt( "    ONION software" );
	kkfade(-1);
	vpause(50);

	//		aruga room scene
	//
	//ask_aniini(0);
	//ask_pic("AROOM_C.ASK",picbuf,6410);
	//pal_on();

	//kkini( 48,9 );
	//tkprt( "…というわけだったのさ。" );
	//y++;vpause( 300 );
	//tkprt( "どうだい楽しかったかい？" );
	//tkprt( "俺の２０年前の話は。" );
	//y++;vpause( 300 );
	//tkprt( "あっ…おい、どこに行くんだよ。" );
	//tkprt( "…ちぇっ。" );
	//tkprt( "これだから若いもんは…。" );
	//vepause(550);pal_clr();
	play_stop();
	stage=1;
	goto abr_demo;


	/*---------------------------------------------------------------
				exit procedure
	---------------------------------------------------------------*/

prgbye:
	ginit(1,0,0);
	clrscr();t_on();
	gdc_ymul(0);
	gdc_clock( gdccl_save );
	play_stop();
	play_done();

	freemem( chrbuf );
	freemem( picbuf );
	pal_done();

	while(1) { if (joyin()==0) break; }
	_setcursortype( _LINECURSOR );
	jinit();
	printf("midi tacoragael version.A / onion software (c)1993\n");

return 0; }



	/*---------------------------------------------------------------
				basic sub routines
	---------------------------------------------------------------*/

static music_go( char *mubuff )
{
	if (midien) {
		play_setup( mubuff );
		play_start();
	}
return;
}


static mbufclr()
{
	int dumm;
	for(dumm=0;dumm<4;dumm++) { mpu_proc2(); }
	mpu_start();
return;
}


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


static vepause( int pvwait )
{
	int pvcnt;
	mbufclr();
	vwait(0);pvcnt=0;
	while(1) {
		vwait(1);
		jport=joyin();if (jport&48) { mode=1;break; }
		pvcnt++;if (pvcnt>pvwait) break;
		mpu_proc2();
		if (mbf!=mpu_endptr()) { mode=1;break; }
	}
	mpu_start();
	return;
}


static ask_aniini( int scrofs )
{
	aniofs=scrofs;
	ginit(1,0,1);pal_off();
	t_cls();clrscr();
	set_page(1,0);gcls(0);
	set_page(0,0);gcls(0);
	p=0;m=an[0]-1;
	return;
}


static ask_anime( int anisw )
{
	//	ask anime execute.
	//		anisw =  0 : endless reverse loop
	//			-1 : 1shot animation
	//			1～: selected flame put

	b=1;c=1;d=0;
	if (anisw>0) b=anisw; else b=b+c;

	set_page( p^1,p );
	while(1) {
		ask_open( anibuf+an[b],aniofs );
		ask_pal( anibuf+an[b] );
		vwait(0);pal_show(1);vwait(1);
		p=p^1;set_page( p^1,p );
		vwait(1);

		if (anisw>0) break;

		if ((b==m)||(b==1)) {
			c=-c;if (anisw==-1) break;
			d++;if (d==8) break;
			}
		b=b+c;

		jport=joyin();
		if (anisw==0) {
			if (jport&48) { mode=1;break; }
			}
		}
return;
}


static kkini( int kkx,int kky )
{
	x=kkx;y=kky;c=15;d=9;
return;
}


static kkprt( char *kkmes )
{
	set_page(1,p);
	kprt( x-2,y-1,d|16,kkmes );
	kprt( x+2,y+1,d|16,kkmes );
	kprt( x,y,c|16,kkmes );
	set_page(0,p);
	kprt( x+2,y+1,d|16,kkmes );
	kprt( x-2,y-1,d|16,kkmes );
	kprt( x,y,c|16,kkmes );
	y=y+32;
return;
}


static kkfade( int f_sw )
{
	if (f_sw==1) { for(a=0;a<15;a++) { kkgrade(a); }
		}
	else
	if (f_sw==0) { for(a=0;a<15;a++) { kkgrade(15-a); }
		}
	else
	if (f_sw==-1) {
		for(a=0;a<16;a++) { kkgrade(a); }
		vpause(170);
		for(a=0;a<16;a++) { kkgrade(15-a); }
		set_page(0,0);gcls(0);
		vpause(70);
		}
return;
}


static kkgrade( int grade )
{
	b=grade-8;if (b<0) b=0;
	pal_set(15,grade*0x111);pal_set(9,b*0x111);
	vwait(0);pal_show();vwait(3);
return;
}


static tkprt( char *tkmes )
{
	gotoxy(x,y);cprintf("%s",tkmes );
	y++;
return;
}


	/*---------------------------------------------------------------
			sub routines ( for game )
	---------------------------------------------------------------*/


static ene_init()
{
	energy=300+stage*100;life=5;
	for(a=0;a<enekaz;a++) {	fl[a]=0; }

	gotoxy(7,2);
	textcolor(11);cprintf("                              ");
	textcolor(9);cprintf("                    ");
	tpole(6,1,0x87,50,2);
	gotoxy(64,2);
	textcolor(10);
	cprintf("■■■■■");
	earrow(1);
return;
}


static ene_new()
{
	fl[a]=(rand()&15)+6;
	chr[a]=1;wt[a]=(rand()&7)+10;
	b=32;c=(rand()&31)*2+ene_level;
	x=(rand()&3)*2;y=(rand()%5)-2;if (x==0) x=1;
	if (rand()&1) { b=568;x=-x; }
	xx[a]=b;yy[a]=c;
	px[a]=x;py[a]=y;
	ssp_set( a,b,c,chr[a] );
return;
}


static ene_chdir()
{
	fl[a]=(rand()&7)+12;
	wt[a]=(rand()&7)+10;
	x=(rand()&3)*2;y=(rand()%5)-2;if (x==0) x=1;
	if (px[a]<0) { x=-x; }
	if ((rand()&63)<ene_level) { x=x/2;y=4;fl[a]=199; }
	px[a]=x;py[a]=y;
return;
}



static ene_move()
{
	for(a=0;a<enekaz;a++) {
		if (fl[a]==0) {
			if ( (rand()&255)<ene_level ) ene_new();
		}
		else if ( fl[a]>500 ) {
			ssp_set( a,xx[a],yy[a],8+wt[a] );
			wt[a]++;if (wt[a]==8) {
				fl[a]=0;ssp_set( a,-2,0,0 );
				}
		}
		else {
			b=wt[a];if (b>0) { b--;wt[a]=b; }
			else {
				b=xx[a]+px[a];c=yy[a]+py[a];
				if ((b<32)||(b>568)||(c<0)||(c>352)) {
					fl[a]=0;xx[a]=-2;
					if (c>352) { invade(); }
				}
				else {
					xx[a]=b;yy[a]=c;
					fl[a]--;if (fl[a]==1) ene_chdir();
				}
			}
			ssp_set( a,xx[a],yy[a],chr[a] );
		}
	}
return;
}


static invade()
{
	if (life>0) {
		col_cnt=1;col_px=1;
		life--;
		gotoxy(64+life*2,2);
		cprintf("  ");
		if (life==0) {
			cdown=10;mode=2;
		}
	}
return;
}


static bar_put( int chrcode )
{
	tpole( 0,bar_yy>>4,chrcode,4,2 );
	tpole( 76,bar_yy>>4,chrcode,4,2 );
return;
}


static my_init()
{
	bar_yy=64;jwait=0;
	for(a=enekaz;a<miskaz;a++) { fl[a]=0; }
	a=myskaz;
	xx[a]=308;yy[a]=336;chr[a]=0;
	ssp_set( a,xx[a],yy[a],chr[a] );
	bar_put( 0x87 );
return;
}


static my_move()
{
	power=10;
	mpu_proc2();

	//	midi key
	//
	a=myskaz;
	if (mbf!=mpu_endptr()) {
		b=mbf[2];if ((b>=key_start)&&(b<key_end)&&(mbf[3]>0)) {
			b=(b-key_start)*key_scale;
			xx[a]=64+(b>>4);power=mbf[3]/2;
			if (power<20) power=20;
			jport=jport|16;jwait=0;
		}
		mpu_start();
	}

	//	midi pitch bend
	//
	d=bar_yy;
	c=mpu_pbend();if (c!=pport) {
		pport=c;c=(c>>7)-64;b=c/2;
		d=168-(c+b);
		}

	//	pc98 key move
	//
	a=myskaz;b=xx[a];c=4;
	if (jport&128) c=16;
	if (jport&8) b=b+c;
	if (jport&4) b=b-c;
	if (jport&2) if (d>64) d=d-c;
	if (jport&1) if (d<256) d=d+c;
	if ((b<64)||(b>508)) b=xx[a];
	xx[a]=b;
	ssp_set( a,xx[a],yy[a],chr[a] );
	if (bar_yy!=d) {
		bar_put( 0x20 );bar_yy=d;bar_put( 0x87 );
	}

	//	miss procedure

	if (jwait>0) jwait--;
	else if (jport&80) { mis_new();jwait=4; }

	for(a=enekaz;a<miskaz;a++) {
		if (fl[a]!=0) {
			if ( yy[a]<=py[a] ) {
				wt[a]++;if (wt[a]==8) {
					ssp_set( a,-2,0,0 );fl[a]=0;
					}
				else {
					ssp_set( a,xx[a],yy[a],8+wt[a] );
					b=ssp_hit( a,0,enekaz-1);
					if (b!=-1) {
						if (fl[b]<500) ene_dest();
					}
				}
			}
			else {
				yy[a]=yy[a]-16;
				ssp_set( a,xx[a],yy[a],chr[a] );
			}
		}
	}
return;
}


static ene_dest()
{
	fl[b]=999;wt[b]=0;
	earrow(0);
	energy=energy-px[a];
	if (energy<1) { mode=1;energy=0;cdown=10; }
	earrow(1);
return;
}

static earrow( int arrsw )
{
	textcolor(12);
	gotoxy(7+(energy>>4),3);
	if (arrsw==0) {
		cprintf("  ");
	}
	else {
		cprintf("▲");
	}
	textcolor(15);
return;
}


static mis_new()
{
	for(b=enekaz;b<miskaz;b++) {
		if (fl[b]==0) {
			fl[b]=1;wt[b]=0;chr[b]=2;
			xx[b]=xx[myskaz];yy[b]=yy[myskaz];
			py[b]=bar_yy;px[b]=power;
			break;
		}
	}
return;
}


	/*---------------------------------------------------------------
				   key config
	---------------------------------------------------------------*/

static keycnf()
{
	ask_aniini(0);
	ask_pic("gokbg.ask",picbuf,4);
	vdbl();
	for(a=0;a<14;a++) {
		b=a-3;if (b<0) b=0;
		pal_set(a,b*0x10);
	}
	pal_set( 15,0xfff );pal_set( 14,0x888 );
	pal_on();

	kkini( 248,100 );
	kkprt( "鍵盤スケール登録" );
	kkini( 108,156 );
	kkprt( "ＭＩＤＩ鍵盤の左端（一番低い音）のキーを押して下さい。" );
	mbufclr();
	mode=0;
	while(1) {
		mpu_proc();
		if (mbf!=mpu_endptr()) { key_start=mbf[2];break; }
		jport=joyin();if (jport&32) { mode=1;break; }
		vwait(1);
	}
	if (mode==1) return -1;

	kkini( 108,186 );
	kkprt( "ＭＩＤＩ鍵盤の右端（一番高い音）のキーを押して下さい。" );
	mbufclr();

	mode=0;
	while(1) {
		mpu_proc();
		if (mbf!=mpu_endptr()) { 
			key_end=mbf[2];
			if (key_start<key_end) break;
			mpu_start();
			}
		jport=joyin();if (jport&32) { mode=1;break; }
		vwait(1);
	}
	if (mode==1) return -1;

	key_end++;
	key_range=key_end-key_start;
	key_scale=7680/key_range;

	kkini( 180,228 );
	kkprt( "鍵盤スケールの登録が終了しました。" );
	vepause( 300 );

	pal_clr();
return 0;
}

