%{
#include <stdio.h>
%}

%%

"int"|"float"|"char"|"double"|"long"|"short"|"void"|"return"|"if"|"else"|"while"|"for"|"do"|"switch"|"case"|"break"|"continue"|"struct"|"typedef"|"const"|"static"|"unsigned"|"signed"|"sizeof"   { printf("Keyword     : %s\n", yytext); }

"#include"|"#define"|"#ifdef"|"#ifndef"|"#endif"|"#pragma"   { printf("Preprocessor: %s\n", yytext); }

"=="|"!="|"<="|">="|"&&"|"||"|"++"|"--"|"+="|"-="|"*="|"/="|"->"   { printf("Operator    : %s\n", yytext); }
"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"!"|"&"|"|"|"^"|"~"                { printf("Operator    : %s\n", yytext); }

[0-9]+\.[0-9]+   { printf("Float Const : %s\n", yytext); }
[0-9]+           { printf("Int Const   : %s\n", yytext); }

\"[^\"]*\"       { printf("String      : %s\n", yytext); }
\'[^\']\'        { printf("Char Const  : %s\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]*   { printf("Identifier  : %s\n", yytext); }

";"|","|"("|")"|"{"|"}"|"["|"]"   { printf("Symbol      : %s\n", yytext); }

[ \t\n]+   ;

.          { printf("Unknown     : %s\n", yytext); }

%%

int main() {
    printf("==========================================\n");
    printf("    C LANGUAGE LEXICAL ANALYZER\n");
    printf("      (WITHOUT SYMBOL TABLE)\n");
    printf("==========================================\n");
    printf("Enter C code (Ctrl+D to end):\n");
    printf("------------------------------------------\n");
    yylex();
    return 0;
}

int yywrap() { return 1; }
