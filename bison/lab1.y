%{
    #define alloca malloc
    #include <Windows.h>
    #define alloca malloc
    #define SIZE 64
    
    char cVariable = -1;
    
    struct express
    { 
        int  iNumber;
        int  iCoeffArr[SIZE];
    };
    
    void debugOutput(struct express exp, int N)
    {
#ifdef _DEBUG
        printf("%i:\t", N);
        for(int i = 0; i < 7; i++)
        {
            printf("%i\t", exp.iCoeffArr[i]);
        }
        printf("\n");
#endif
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

res     :   expr
            {
				int ifZero = 1;
				for(int i = 0; i < SIZE; i++)
				{
					if($1.iCoeffArr[i] != 0)
					{
						ifZero = 0;
						break;
					}
				}
				if(ifZero == 1)
				{
					printf("0");
				}
				else
				{
					int ifFirst = 1;
					for (int i = 0; i < SIZE; i++)
					{
						if ($1.iCoeffArr[i] != 0)
						{
							if ($1.iCoeffArr[i] > 0 && !ifFirst)
							{
								printf("+");
							}
							if (i == 0 || $1.iCoeffArr[i] > 1 || $1.iCoeffArr[i] < -1)
							{
								printf("%i", $1.iCoeffArr[i]);
							}
							if (i > 0)
							{
								if ($1.iCoeffArr[i] > 1 || $1.iCoeffArr[i] < -1)
								{
									printf("*");
								}
								else if ($1.iCoeffArr[i] == -1)
								{
									printf("-");
								}
								printf("%c", cVariable);
								if (i > 1)
								{
									printf("^%i", i);
								}
							}
							ifFirst = 0;
						}
					}
				}
                printf("\n");
            }
            ;
            
expr    :   expr '+' expr                                                     /*1*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = $1.iCoeffArr[i] + $3.iCoeffArr[i];
                }
                debugOutput($$, 1);
            }
        |   expr '-' expr                                                     /*2*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = $1.iCoeffArr[i] - $3.iCoeffArr[i];
                }
                debugOutput($$, 2);
            }
        |   expr '*' expr                                                     /*3*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
                for(int i = 0; i < SIZE / 2; i++)
                {
                    for(int j = 0; j < SIZE / 2; j++)
                    {
                        $$.iCoeffArr[i + j] += $1.iCoeffArr[i] * $3.iCoeffArr[j];
                    }
                }
                debugOutput($$, 3);
            }
        |   '(' expr ')'                                                     /*4*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = $2.iCoeffArr[i];
                }
                debugOutput($$, 4);
            }
        |   '-' '(' expr ')'                                 %prec UMINUS    /*5*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = -1 * $3.iCoeffArr[i];
                }
                debugOutput($$, 5);
            }
        |   number                                                           /*6*/
            {
                $$.iCoeffArr[0] = $1;
                debugOutput($$, 6);
            }
        |    '-' number                                      %prec UMINUS    /*7*/
            {
                $$.iCoeffArr[0] = -1 * $2;
                debugOutput($$, 7);
            }
        |   number '*' expr                                                  /*8*/
            {
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = $3.iCoeffArr[i] * $1;
                }
                debugOutput($$, 8);
            }
        |   '-' number '*' expr                              %prec UMINUS    /*9*/
            {
                for(int i = 0; i < SIZE; i++)
                {
                    $$.iCoeffArr[i] = -1 * $4.iCoeffArr[i] * $2;
                }
                debugOutput($$, 9);
            }
        |   VARIABLE                                                         /*10*/
            {
                $$.iCoeffArr[1] = 1;
                cVariable = $1;
                debugOutput($$, 10);
            }
        |   '-' VARIABLE                                     %prec UMINUS    /*11*/
            {
                $$.iCoeffArr[1] = -1;
                cVariable = $2;
                debugOutput($$, 11);
            }
        |   VARIABLE '^' number                                              /*12*/
            {
                $$.iCoeffArr[$3] = 1;
                cVariable = $1;
                debugOutput($$, 12);
            }
        |   '(' '-' VARIABLE ')' '^' number                  %prec UMINUS    /*13*/
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
        |   '-' VARIABLE '^' number                          %prec UMINUS    /*14*/
            {
                $$.iCoeffArr[$4] = -1;
                cVariable = $2;
                debugOutput($$, 14);
            }
		/*NEW*/
        |   number '^' number                                                /*15*/
            {
				if($3 == 0)
				{
					$$.iCoeffArr[0] = 1;
				}
				else
				{
					$$.iCoeffArr[0] = $1;
					for(int i = 0; i < $3 - 1; i++)
					{
						$$.iCoeffArr[0] *= $1;
					}
				}
                debugOutput($$, 15);
            }
        |   '-' number '^' number                            %prec UMINUS    /*16*/
            {
				if($4 == 0)
				{
					$$.iCoeffArr[0] = -1;
				}
				else
				{
					$$.iCoeffArr[0] = -1 * $2;
					for(int i = 0; i < $4 - 1; i++)
					{
						$$.iCoeffArr[0] *= $2;
					}
				}
                debugOutput($$, 16);
            }
        |   '(' '-' number ')' '^' number                    %prec UMINUS    /*17*/
            {
				if($6 == 0)
				{
					$$.iCoeffArr[0] = 1;
				}
				else
				{
					if ($6 % 2 == 0)
					{
						$$.iCoeffArr[0] = $3;
						for(int i = 0; i < $6 - 1; i++)
						{
							$$.iCoeffArr[0] *= $3;
						}
					}
					else
					{
						$$.iCoeffArr[0] = -1 * $3;
						for(int i = 0; i < $6 - 1; i++)
						{
							$$.iCoeffArr[0] *= $3;
						}
					}
				}
                debugOutput($$, 17);
            }
        |   '(' expr ')' '^' number                                          /*18*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
				int iTmp[SIZE] = { 0 };
				if($5 == 0)
				{
					$$.iCoeffArr[0] = 1;
				}
				else
				{
					for(int i = 0; i < SIZE; i++)
					{
						$$.iCoeffArr[i] = $2.iCoeffArr[i];
					}
					for(int n = 0; n < $5 - 1; n++)
					{
						for(int i = 0; i < SIZE; i++)
						{
							iTmp[i] = $$.iCoeffArr[i];
							$$.iCoeffArr[i] = 0;
						}
						for(int i = 0; i < SIZE / 2; i++)
						{
							for(int j = 0; j < SIZE / 2; j++)
							{
								$$.iCoeffArr[i + j] += iTmp[i] * $2.iCoeffArr[j];
							}
						}
					}
				}
                debugOutput($$, 18);
            }
        |   '-' '(' expr ')' '^' number                      %prec UMINUS    /*19*/
            {
                ZeroMemory($$.iCoeffArr, SIZE);
				int iTmp[SIZE] = { 0 };
				if($6 == 0)
				{
					$$.iCoeffArr[0] = -1;
				}
				else
				{
					for(int i = 0; i < SIZE; i++)
					{
						$$.iCoeffArr[i] = $3.iCoeffArr[i];
					}
					for(int n = 0; n < $6 - 1; n++)
					{
						for(int i = 0; i < SIZE; i++)
						{
							iTmp[i] = $$.iCoeffArr[i];
							$$.iCoeffArr[i] = 0;
						}
						for(int i = 0; i < SIZE / 2; i++)
						{
							for(int j = 0; j < SIZE / 2; j++)
							{
								$$.iCoeffArr[i + j] += iTmp[i] * $3.iCoeffArr[j];
							}
						}
					}
					for(int i = 0; i < SIZE; i++)
					{
						$$.iCoeffArr[i] *= -1;
					}
				}
                debugOutput($$, 19);
            }
        ;

number  :   DIGIT
            {
                $$ = $1;
            }
        |    number DIGIT
            {
                $$ = $1 * 10 + $2;
            }
        ;
