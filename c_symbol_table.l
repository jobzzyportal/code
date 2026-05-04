%{
#include <stdio.h>
#include <string.h>

/* ---- SYMBOL TABLE ---- */
char  symtab[200][50];
char  symtype[200][20];
int   count = 0;

int search(char *str) {
    for (int i = 0; i < count; i++)
        if (strcmp(symtab[i], str) == 0)
            return i;
    return -1;
}

void insert(char *str, char *type) {
    if (search(str) == -1) {
        strcpy(symtab[count], str);
        strcpy(symtype[count], type);
        count++;
    }
}

void print_symtable() {
    printf("\n==========================================\n");
    printf("            SYMBOL TABLE\n");
    printf("==========================================\n");
    printf("%-5s %-20s %-15s\n", "S.No", "Token", "Type");
    printf("------------------------------------------\n");
    for (int i = 0; i < count; i++)
        printf("%-5d %-20s %-15s\n", i+1, symtab[i], symtype[i]);
    printf("==========================================\n");
    printf("Total entries: %d\n", count);
}
%}

%%

"int"|"float"|"char"|"double"|"long"|"short"|"void"|"return"|"if"|"else"|"while"|"for"|"do"|"switch"|"case"|"break"|"continue"|"struct"|"typedef"|"const"|"static"|"unsigned"|"signed"|"sizeof"   {
    insert(yytext, "KEYWORD");
    printf("Keyword     : %s\n", yytext);
}

"=="|"!="|"<="|">="|"&&"|"||"|"++"|"--"|"+="|"-="|"*="|"/="|"->"   {
    printf("Operator    : %s\n", yytext);
}
"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"!"|"&"|"|"   {
    printf("Operator    : %s\n", yytext);
}

[0-9]+\.[0-9]+   {
    insert(yytext, "FLOAT CONST");
    printf("Float Const : %s\n", yytext);
}
[0-9]+           {
    insert(yytext, "INT CONST");
    printf("Int Const   : %s\n", yytext);
}

\"[^\"]*\"       {
    insert(yytext, "STRING");
    printf("String      : %s\n", yytext);
}
\'[^\']\'        {
    insert(yytext, "CHAR CONST");
    printf("Char Const  : %s\n", yytext);
}

[a-zA-Z_][a-zA-Z0-9_]*   {
    insert(yytext, "IDENTIFIER");
    printf("Identifier  : %s\n", yytext);
}

";"|","|"("|")"|"{"|"}"|"["|"]"   {
    printf("Symbol      : %s\n", yytext);
}

[ \t\n]+   ;

.    { printf("Unknown     : %s\n", yytext); }

%%

int main() {
    printf("==========================================\n");
    printf("    C LANGUAGE LEXICAL ANALYZER\n");
    printf("       (WITH SYMBOL TABLE)\n");
    printf("==========================================\n");
    printf("Enter C code (Ctrl+D to end):\n");
    printf("------------------------------------------\n");
    yylex();
    print_symtable();
    return 0;
}

int yywrap() { return 1; }
