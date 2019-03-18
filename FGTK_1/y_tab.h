#define SIZE 32
struct express
{
    int  iNumber;
    int  iCoeffArr[SIZE];
};

typedef union 
{ 
    int iNum;
    struct express stExpr;
    char cVar;
} YYSTYPE;
#define	DIGIT	258
#define	VARIABLE	259
#define	UMINUS	260


extern YYSTYPE yylval;
