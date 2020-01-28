	/*

		free format translator for ms-dos
			( ver.A for 65816 asm "A65" )
					onitama
					prg. started.1992/5/31
	*/

	#include <stdio.h>
	#include <string.h>

	static	unsigned char	errf,sw_n,sw_p,sw_h,sw_c,sw_t;
	static	unsigned char	bname[64],fname[64],sname[64];
	static	unsigned char	s1[256],s2[256],s3[256];
	static	unsigned int	lb[200],lp[200],en[20],el[20];

	static	int	lstart,lnum,value;
	static	int	line,error;
	static	char	*v,*w,*x;
	static	char	dem[4];


main( int argc,char *argv[] )
{


	int	a,b;
	char	a1,a2;

	strcpy(bname,"none");
	errf=0;sw_n=0;sw_p=0;sw_h=0;sw_c=0;sw_t=0;

	dem[0]=13;dem[1]=10;dem[2]=9;dem[3]=0;

	lnum=1;lstart=1;line=1;error=0;

	printf("free format translator FFT 65816 ver.A	copyright 1992 onitama/zener works");

	if (argc < 2 ) {
		usage1();
	}
	else {

		for (b=1;b<argc;b++) {
			a1=*argv[b];a2=tolower(*(argv[b]+1));
			if ( a1!='/' ) {
				strcpy(bname,argv[b]);	}
			else {
				switch (a2) {
				case 'n':
					sw_n=1;break;
				case 'c':
					sw_c=1;break;
				case 'p':
					sw_p=1;break;
				case 'h':
					sw_h=1;break;
				case 't':
					sw_t=1;break;
				default:
					errf=1;break;
				}
			}
		}
		if (sw_h) { usage2(); }
		if (errf) { printf("\nIllegal switch selected.");return 1; }

		if (strcmp(bname,"none")) {
			strcpy(fname,bname);strcat(fname,".f");
			strcpy(sname,bname);strcat(sname,".s");
			if (fft(fname,sname)==1)
				{ printf("error in reading a file.\n");return 1; }
			else	{
				if (error==0) {	printf("No error detected.\n"); }
				else { errprt();
				if (error==20) { printf("Too many errors."); }
				 else { printf("%d error(s) detected.\n",error); }
				return 1; }
				}
			}
	}
	return 0;
}

usage1()
{
static 	char 	rec[1]= "", *p[] =
{
	rec,"usage: fft [options] [filename]",
	"		  /n	no analysis for 65816",
	"		  /c	comment line translate",
	"		  /p	output screen",
	"		  /t	replace space to TAB",
	"		  /h	help about FFT",
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
	rec,"・free format translator とは…",
	rec,"　　セパーレーター ':' を使うことにより、複数行のアセンブラ命令を表記でき、",
	"　　より自由な書式を可能にするツールです。",
	"　　'filename.F' のファイルを、'filename.S'のソースファイルに変換します。",
	"　　また、65816用の使いやすい疑似命令も用意されています。",rec,
	NULL
};
	int i;
	for(i=0; p[i]; i++)
		printf( "\n%s", p[i]);
	return;
}

mkerr( int a )
{
	if (error==20) { return 1; }
	en[error]=a;el[error]=line;
	error++;

	return 0;
}

errprt()
{
	int i;
	if (error==0) { return 0; }
	for (i=0;i<error;i++) {
		printf("Error %d : at %d\n",en[i],el[i]);
	}
	return 0;

}

fft( char f1name[64],char f2name[64] )
{
	char a,b,c,a1,a2,sk;
	FILE *fp1,*fp2;

	printf("\ncompiling : %s\n",f1name);

	fp1=fopen(f1name,"r");
	if (fp1==NULL) { return 1; }
	fp2=fopen(f2name,"w");

	while(fgets(s1,255,fp1)!=NULL) {

	if (s1[0]!='\t') {

		/* no tab line (label) direct out */

		if (s1[0]!='@') {
			if ( s1[0]!=10 ) {
				fprintf(fp2,"%s",s1);lstart=1; }
			}

		/* local label make */

		else {
			value=atoi(s1+1);if (value<1000) {
				if (lbsear(value)||lstart>199) { mkerr(2); }
				else {
					fprintf(fp2,"Lb_%d:\n",lnum);
					lp[lstart]=lnum;lb[lstart]=value;
					lstart++;lnum++; }
				}
			else { mkerr(1); }
			}

		}

	/* normal line */

	c=0;sk=1;a1=0;a2=0;
	v=strchr(s1,'\t');
	if (v!=NULL) {
		v++;
		w=strchr(v,';');if (w!=NULL) { w[0]=NULL; }
		x=strtok(v,":");
		if (x==NULL) { trans(v); }
		else {
			while ( x!=NULL ) {
			trans(x);
			x=strtok(NULL,":");
			}
			trans(x);
		}
	}
	line++;

	}

	fclose(fp2);fclose(fp1);

	return 0;
}

lbsear( int a )
{
	int i;

	if (lstart==1) { return 0; }
	for(i=1;i<lstart;i++) {
		if (lb[i]==a) { return i; }
	}
	return 0;
}


trans( char *st )
{
	char *s1;
	s1=strtok(st,dem);if (s1==NULL) { s1=st; }
	printf("%s\n",s1);
	return 0;
}


