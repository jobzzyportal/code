%{
/*
 * calc.l  —  LEX/Flex tokenizer for arithmetic evaluator
 * Compile steps at bottom of calc.y
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "calc.tab.h"
%}

%%

[ \t]+                  ;                        /* skip spaces/tabs        */
\n                      { return '\n'; }          /* newline ends expression  */

[0-9]+\.[0-9]+          { yylval.dval = atof(yytext); return NUMBER; }
[0-9]+                  { yylval.dval = atof(yytext); return NUMBER; }

"sin"                   { return SIN;  }
"cos"                   { return COS;  }
"tan"                   { return TAN;  }
"sqrt"                  { return SQRT; }
"log"                   { return LOG;  }
"exp"                   { return EXP;  }
"abs"                   { return ABS;  }
"pow"                   { return POW;  }

[a-zA-Z][a-zA-Z0-9_]*  { yylval.sval = strdup(yytext); return VAR; }

"**"                    { return POWER; }
"+"|"-"|"*"|"/"|"("|")"|"="|","   { return yytext[0]; }

.                       { printf("  [Lexer] Unknown char: %s\n", yytext); }

%%

int yywrap() { return 1; }
