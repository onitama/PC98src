	/*
		"CUTY" 構造体を使ったファイル操作の練習
						1992/6 onitama
								*/

	#include <stdio.h>
	#include <dir.h>
	#include <dos.h>

	#define	fmax 100
	#define	tmax 20
	#define fnmax 13

	static	unsigned char	bname[64],fname[64],sname[64];

main( int argc,char *argv[] )
{
	typedef struct {
	char nams[ 32 ];
	char cmds[ 40 ];
	int kazz;
	} target;

	typedef struct {
	char name[ fnmax ];
	int ttype;
	int attr;
	int flag;
	long size;
	} dirs;

	struct ffblk	fb;
	char cmdline[128];
	char wildcard[96]="*.";

	target tdata[ tmax ];
	dirs fdata[ fmax ];

	int found;
	int a,b,c;
	int dmax,td,tdmax,tkazz;
	char errf,sw_h,sw_k,sw_p,a1,a2;

	printf("'Cuty' picture files auto viewer ver.B / onion software 1992");

	strcpy(tdata[0].nams,"*.mag");strcpy(tdata[0].cmds,"mag -k ");
	strcpy(tdata[1].nams,"*.mki");strcpy(tdata[1].cmds,"maki -k ");
	strcpy(tdata[2].nams,"*.jpg");strcpy(tdata[2].cmds,"jld -W ");
	strcpy(tdata[3].nams,"*.q4");strcpy(tdata[3].cmds,"hsx /k ");
	strcpy(tdata[4].nams,"*.pi");strcpy(tdata[4].cmds,"pi98 /k ");
	strcpy(tdata[5].nams,"*.pic");strcpy(tdata[5].cmds,"picwl ");
	strcpy(tdata[6].nams,"*.anm");strcpy(tdata[6].cmds,"xview ");
	strcpy(tdata[7].nams,"*.msa");strcpy(tdata[7].cmds,"misav /k ");
	strcpy(tdata[8].nams,"*.q0");strcpy(tdata[8].cmds,"q0wl ");
	strcpy(tdata[9].nams,"*.zim");strcpy(tdata[9].cmds,"zeus ");
	strcpy(tdata[10].nams,"*.pd6");strcpy(tdata[10].cmds,"ask6 ");
	strcpy(tdata[11].nams,"*.pd4");strcpy(tdata[11].cmds,"pdx /k ");
	strcpy(tdata[12].nams,"*.ask");strcpy(tdata[12].cmds,"aska -K ");
	tdmax=13;

	errf=0;sw_h=0;sw_k=0;sw_p=0;

	if (argc > 1 ) {
		for (b=1;b<argc;b++) {
			a1=*argv[b];a2=tolower(*(argv[b]+1));
			if ( a1!='/'&&a1!='-' ) {
				strcpy(bname,argv[b]);	}
			else {
				switch (a2) {
				case 'k':
					sw_k=1;break;
				case 'p':
					sw_p=1;break;
				case 'h':
					sw_h=1;break;
				case '?':
					sw_h=1;break;
				default:
					errf=1;break;
				}
			}
		}
		}
		if (sw_h) { usage2();usage1();return 0; }
		if (errf) { usage1();return 1; }

	td=0;dmax=0;a=0;

	/*	get directory data	*/

	for ( td=0;td<tdmax;td++ ) {
		strcpy( wildcard,bname );
		strcat( wildcard,tdata[td].nams );
		found=!findfirst( wildcard,&fb,0x11);
		tkazz=0;

		while (found) {
			if (a>fmax) { break; }
			strcpy(fdata[a].name,fb.ff_name);
			fdata[a].attr=fb.ff_attrib;
			fdata[a].ttype=td;
			fdata[a].flag=0;
			fdata[a].size=fb.ff_fsize;
			tkazz++;a++;
			found=!findnext(&fb);
			}
		tdata[td].kazz=tkazz;
	}
	dmax=a;

	if (dmax==0) { printf("\nNo picture files around. Abortred.  ( HELP = cuty /h )");return 1; }
	if (sw_p) {

	/*	show result	*/

	printf("\n\nResult:\n");
	for (a=0;a<tdmax;a++) {
		b=tdata[a].kazz;
		if (b!=0) {
			printf("%s(%d)\t",tdata[a].nams,b);
			}
		}

	printf("\n+---------------------------------------------------------------------+\n");

	/*	show directory data	*/

	for (a=0;a<dmax;a++) {
		if ((fdata[a].attr & FA_DIREC)==0)
			{
			printf("%-16.12s",fdata[a].name);
			printf("%8.ld",fdata[a].size);
			b=fdata[a].ttype;
			strcpy( cmdline , tdata[b].cmds );
			strcat( cmdline , bname );
			strcat( cmdline , fdata[a].name );
			printf("\t>%s\n",cmdline);
			}
	}

	printf("\nFound %d picture files.\n",dmax);
	}

	else {

	/*	send command to MS-DOS	*/

	printf("\nFound %d picture files.\n",dmax);
	for (a=0;a<dmax;a++) {
		if ((fdata[a].attr & FA_DIREC)==0)
			{
			b=fdata[a].ttype;
			strcpy( cmdline , tdata[b].cmds );
			strcat( cmdline , bname );
			strcat( cmdline , fdata[a].name );
			if (system( cmdline )) { return 1; }
			}
		}
	}


return 0; }



usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: cuty [/option] [path-name]",
	"		  /p	result print out",
	"		  /k	key wait option",
	"		  /h	help about Cuty",
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
	rec,"・Cuty とは…",
	rec,
	"カレントディレクトリにあるファイルの拡張子から絵のファイルを判断して、",
	"それに応じたローダーで表示させるためのプログラムです。",
	"現在対応している拡張子は、以下の通りです。それぞれのローダーが、PATH に",
	"存在している必要があります。",rec,
	"  mag.exe (.MAG) / maki.exe (.MKI) / jld.exe (.JPG) / picwl.exe (.PIC)",
	"  hsx.com (.Q4)  / pi98.exe (.PI)  / ask6.exe (.PD6) / xview.exe (.ANM)",
	"  q0wl.exe (.Q0) / zeus.exe (.ZIM) / misav.exe (.MSA) / pdx.exe (.PD4)",
	"  aska.com (.ASK) ",
	rec,NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "\n%s", p[i]);
	return;
}

