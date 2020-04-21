

#define FALSE 0
#define TRUE (!FALSE)

typedef unsigned int u_int;
typedef unsigned char u_char;
typedef signed char s_char;
typedef	int	word;
typedef	unsigned char	byte;



//#define FP_OFF(fp)	((unsigned)(fp))
//#define FP_SEG(fp)	((unsigned)((unsigned long)(fp) >> 16))
#ifndef NULL
#   if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#   define      NULL    0
#   else
#   define      NULL    0L
#   endif
#endif

