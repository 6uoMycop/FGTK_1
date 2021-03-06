#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "y_tab.h"

FILE *yyin = NULL;

int yyerror(char *str)
{
    printf("Error: \"%s\"\n", str);
    return 0;
}

int yylex()
{
    char c;
    c = fgetc(yyin);

    if (isdigit(c))
    {
        yylval.iNum = c - '0';
        return (DIGIT);
    }
    if (c == 'x')
    {
        yylval.cVar = c;
        return (VARIABLE);
    }

    return (c);
}

int main()
{
    yyin = fopen("input.txt", "r");
    if (yyin == NULL)
    {
        yyerror("file was not opened");
        return 0;
    }
    yyparse();
    fclose(yyin);
    //system("pause");
    return 0;
}