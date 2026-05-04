%{
/*
 * ============================================================
 *  calc.y  —  YACC/Bison grammar for arithmetic evaluator
 *
 *  HOW TO RUN:
 *    Step 1:  bison -d calc.y
 *    Step 2:  flex calc.l
 *    Step 3:  gcc -o calc calc.tab.c lex.yy.c -lm
 *    Step 4:  ./calc
 *
 *  WHAT IT SUPPORTS:
 *    Operators  : + - * / ** (power)  and unary minus (-)
 *    Functions  : sin, cos, tan, sqrt, log, exp, abs, pow(x,y)
 *    Variables  : x = 5   then use x in any expression
 *    Constants  : PI  and  E  are pre-loaded
 *    Errors     : division by zero, sqrt/log of bad input
 * ============================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* ============================================================
   SYMBOL / VARIABLE TABLE
   ============================================================ */
#define MAX_VARS 100

typedef struct {
    char   name[50];
    double value;
} Var;

Var  symtab[MAX_VARS];
int  sym_count = 0;

/* --- look up a variable; warn + return 0 if not found --- */
double get_var(char *name) {
    for (int i = 0; i < sym_count; i++)
        if (strcmp(symtab[i].name, name) == 0)
            return symtab[i].value;
    printf("  [Warning] Undefined variable '%s', defaulting to 0\n", name);
    return 0.0;
}

/* --- insert or update a variable --- */
void set_var(char *name, double val) {
    for (int i = 0; i < sym_count; i++) {
        if (strcmp(symtab[i].name, name) == 0) {
            symtab[i].value = val;
            return;
        }
    }
    if (sym_count < MAX_VARS) {
        strcpy(symtab[sym_count].name, name);
        symtab[sym_count].value = val;
        sym_count++;
    }
}

/* --- print symbol table at end --- */
void print_symtab() {
    printf("\n");
    printf("+------------------------------------------+\n");
    printf("|           VARIABLE / SYMBOL TABLE        |\n");
    printf("+------------------------------------------+\n");
    if (sym_count == 0) {
        printf("|  (no variables defined)                  |\n");
    } else {
        printf("| %-20s | %-18s |\n", "Variable", "Value");
        printf("|----------------------+-------------------|\n");
        for (int i = 0; i < sym_count; i++)
            printf("| %-20s | %-18g |\n", symtab[i].name, symtab[i].value);
    }
    printf("+------------------------------------------+\n");
}

void yyerror(const char *s);
int  yylex(void);
%}

/* ============================================================
   YACC DECLARATIONS
   ============================================================ */

/* semantic value can be a number OR a variable name */
%union {
    double  dval;
    char   *sval;
}

/* tokens that carry a value */
%token <dval> NUMBER
%token <sval> VAR

/* keyword tokens for built-in functions */
%token SIN COS TAN SQRT LOG EXP ABS POW POWER

/* type of non-terminal expr */
%type  <dval> expr

/* ---  OPERATOR PRECEDENCE  (lowest → highest)  --- */
%right '='
%left  '+' '-'
%left  '*' '/'
%right UMINUS
%right POWER

%%

/* ============================================================
   GRAMMAR RULES
   ============================================================ */

/* top-level: accept multiple lines */
program
    : program stmt '\n'
    | program '\n'
    | /* empty */
    ;

/* one statement per line */
stmt
    : VAR '=' expr   {
                         set_var($1, $3);
                         printf("  => %s = %g\n\n", $1, $3);
                         free($1);
                     }
    | expr           {
                         printf("  => %g\n\n", $1);
                     }
    ;

/* expressions */
expr
    /* --- literals and variables --- */
    : NUMBER                        { $$ = $1; }
    | VAR                           { $$ = get_var($1); free($1); }

    /* --- binary arithmetic --- */
    | expr '+' expr                 { $$ = $1 + $3; }
    | expr '-' expr                 { $$ = $1 - $3; }
    | expr '*' expr                 { $$ = $1 * $3; }
    | expr '/' expr                 {
                                        if ($3 == 0.0) {
                                            printf("  [Error] Division by zero!\n");
                                            $$ = 0;
                                        } else {
                                            $$ = $1 / $3;
                                        }
                                    }
    | expr POWER expr               { $$ = pow($1, $3); }

    /* --- unary minus --- */
    | '-' expr %prec UMINUS         { $$ = -$2; }

    /* --- parentheses --- */
    | '(' expr ')'                  { $$ = $2; }

    /* --- built-in single-argument functions --- */
    | SIN  '(' expr ')'            { $$ = sin($3);  }
    | COS  '(' expr ')'            { $$ = cos($3);  }
    | TAN  '(' expr ')'            { $$ = tan($3);  }
    | SQRT '(' expr ')'            {
                                        if ($3 < 0) {
                                            printf("  [Error] sqrt() of negative number!\n");
                                            $$ = 0;
                                        } else {
                                            $$ = sqrt($3);
                                        }
                                    }
    | LOG  '(' expr ')'            {
                                        if ($3 <= 0) {
                                            printf("  [Error] log() of non-positive number!\n");
                                            $$ = 0;
                                        } else {
                                            $$ = log($3);
                                        }
                                    }
    | EXP  '(' expr ')'            { $$ = exp($3);        }
    | ABS  '(' expr ')'            { $$ = fabs($3);       }

    /* --- built-in two-argument function --- */
    | POW  '(' expr ',' expr ')'   { $$ = pow($3, $5);   }
    ;

%%

/* ============================================================
   ERROR HANDLER
   ============================================================ */
void yyerror(const char *s) {
    fprintf(stderr, "  [Syntax Error] %s\n", s);
}

/* ============================================================
   MAIN
   ============================================================ */
int main() {
    /* pre-load math constants */
    set_var("PI", M_PI);
    set_var("E",  M_E);

    printf("+------------------------------------------+\n");
    printf("|    ARITHMETIC EXPRESSION EVALUATOR       |\n");
    printf("|         Using YACC / Bison               |\n");
    printf("+------------------------------------------+\n");
    printf("| Operators : + - * / ** (power)           |\n");
    printf("| Functions : sin cos tan sqrt log         |\n");
    printf("|             exp abs pow(x,y)             |\n");
    printf("| Variables : x = 5  (assign then use)     |\n");
    printf("| Constants : PI = 3.14159  E = 2.71828    |\n");
    printf("| Quit      : Ctrl+D                       |\n");
    printf("+------------------------------------------+\n\n");

    yyparse();

    print_symtab();
    return 0;
}
