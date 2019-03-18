%{
	#define alloca malloc
	#include <Windows.h>
	#define alloca malloc
	#define SIZE 32
	
	char cVariable = -1;
	
	struct express
	{ 
		int  iNumber;
		int  iCoeffArr[SIZE];
	};
	
	void debugOutput(struct express exp, int N)
	{
		printf("%i:\t", N);
		/*printf("%c;\t", cVariable);
		printf("%i;\t", exp.iNumber);*/
		for(int i = 0; i < 7; i++)
		{
			printf("%i\t", exp.iCoeffArr[i]);
		}
		printf("\n");
	}
%}

%union { int iNum; struct express stExpr; char cVar; }

%start res

%token <iNum>   DIGIT
%token <cVar>   VARIABLE
%type  <iNum>   number
%type  <stExpr> expr
%type  <iNum>   res

%left '+' '-'
%left '*'
%left '^'
%left UMINUS

%%

res		:	expr
			{
				int ifFirst = 1;
				for (int i = 0; i < SIZE; i++)
				{
					if (yyvsp[0].stExpr.iCoeffArr[i] != 0)
					{
						if (yyvsp[0].stExpr.iCoeffArr[i] > 0 && !ifFirst)
						{
							printf("+");
						}
						if (i == 0 || yyvsp[0].stExpr.iCoeffArr[i] > 1 || yyvsp[0].stExpr.iCoeffArr[i] < -1)
						{
							printf("%i", yyvsp[0].stExpr.iCoeffArr[i]);
						}
						if (i > 0 && yyvsp[0].stExpr.iCoeffArr[i] > 1)
						{
							printf("*");
						}
						if (i > 0)
						{
							printf("%c", cVariable);
							if (i > 1)
							{
								printf("^%i", i);
							}
						}
						ifFirst = 0;
					}
				}
				printf("\n");
			}
			;
			
expr	:	expr '+' expr 													/*1*/
			{
				ZeroMemory($$.iCoeffArr, SIZE);
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = $1.iCoeffArr[i] + $3.iCoeffArr[i];
				}
				debugOutput($$, 1);
			}
		|	expr '-' expr 													/*2*/
			{
				ZeroMemory($$.iCoeffArr, SIZE);
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = $1.iCoeffArr[i] - $3.iCoeffArr[i];
				}
				debugOutput($$, 2);
			}
		|	expr '*' expr 													/*3*/
			{
				ZeroMemory($$.iCoeffArr, SIZE);
				for(int i = 0; i < SIZE; i++)
				{
					for(int j = 0; j < SIZE; j++)
					{
						$$.iCoeffArr[i + j] += $1.iCoeffArr[i] * $3.iCoeffArr[j];
					}
				}
				debugOutput($$, 3);
			}
		|	'(' expr ')' 													/*4*/
			{
				ZeroMemory($$.iCoeffArr, SIZE);
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = $2.iCoeffArr[i];
				}
				debugOutput($$, 4);
			}
		|	'-' '(' expr ')' 					%prec UMINUS				/*5*/
			{
				ZeroMemory($$.iCoeffArr, SIZE);
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = -1 * $3.iCoeffArr[i];
				}
				debugOutput($$, 5);
			}
		|	number 															/*6*/
			{
				$$.iCoeffArr[0] = $1;
				debugOutput($$, 6);
			}
		|	'-' number 							%prec UMINUS 				/*7*/
			{
				$$.iCoeffArr[0] = -1 * $2;
				debugOutput($$, 7);
			}
		|	number '*' expr 												/*8*/
			{
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = $3.iCoeffArr[i] * $1;
				}
				debugOutput($$, 8);
			}
		|	'-' number '*' expr 			    %prec UMINUS 				/*9*/
			{
				for(int i = 0; i < SIZE; i++)
				{
					$$.iCoeffArr[i] = -1 * $4.iCoeffArr[i] * $2;
				}
				debugOutput($$, 9);
			}
		|	VARIABLE 														/*10*/
			{
				$$.iCoeffArr[1] = 1;
				cVariable = $1;
				debugOutput($$, 10);
			}
		|	'-' VARIABLE 													/*11*/
			{
				$$.iCoeffArr[1] = -1;
				cVariable = $2;
				debugOutput($$, 11);
			}
		|	VARIABLE '^' number 											/*12*/
			{
				$$.iCoeffArr[$3] = 1;
				cVariable = $1;
				debugOutput($$, 12);
			}
		|	'(' '-' VARIABLE ')' '^' number 	%prec UMINUS 				/*13*/
			{
				if ($6 % 2 == 0)
				{
					$$.iCoeffArr[$3] = 1;
				}
				else
				{
					$$.iCoeffArr[$3] = -1;
				}
				cVariable = $3;
				debugOutput($$, 13);
			}
		;

number	:	DIGIT
			{
				$$ = $1;
			}
		|	number DIGIT
			{
				$$ = $1 * 10 + $2;
			}
		;
