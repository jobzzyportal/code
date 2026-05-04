%{
#include <stdio.h>
%}

%%

"he"|"she"|"they"|"it"|"we"|"you"|"I"          { printf("Pronoun     : %s\n", yytext); }

"run"|"eat"|"play"|"is"|"are"|"was"|"go"|"come"|"write"|"read"|"sleep"|"work"|"help"|"stop"|"love"|"like"|"need"|"make"|"do"|"have"|"say"|"get"|"see"|"know"   { printf("Verb        : %s\n", yytext); }

"quick"|"happy"|"sad"|"big"|"small"|"good"|"bad"|"hot"|"cold"|"fast"|"slow"|"new"|"old"|"young"|"smart"|"beautiful"|"tall"|"short"|"long"|"high"|"low"|"dark"|"bright"   { printf("Adjective   : %s\n", yytext); }

"quickly"|"slowly"|"very"|"really"|"always"|"never"|"often"|"already"|"soon"|"just"|"hard"|"fast"|"well"|"badly"|"easily"|"carefully"|"finally"|"maybe"|"perhaps"   { printf("Adverb      : %s\n", yytext); }

"on"|"in"|"under"|"over"|"at"|"by"|"with"|"from"|"to"|"of"|"into"|"above"|"below"|"near"|"between"|"through"|"before"|"after"|"behind"|"around"   { printf("Preposition : %s\n", yytext); }

"and"|"but"|"or"|"nor"|"so"|"yet"|"for"|"because"|"although"|"if"|"while"|"when"|"though"|"unless"|"however"|"therefore"   { printf("Conjunction : %s\n", yytext); }

"a"|"an"|"the"   { printf("Article     : %s\n", yytext); }

[a-zA-Z]+        { printf("Noun        : %s\n", yytext); }

[0-9]+           { printf("Number      : %s\n", yytext); }

[ \t\n]+         ;

.                { printf("Unknown     : %s\n", yytext); }

%%

int main() {
    printf("==========================================\n");
    printf("  ENGLISH PARTS OF SPEECH ANALYZER\n");
    printf("==========================================\n");
    printf("Enter sentence (Ctrl+D to end):\n");
    printf("------------------------------------------\n");
    yylex();
    return 0;
}

int yywrap() { return 1; }
