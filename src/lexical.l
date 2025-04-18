%option noyywrap yylineno
%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
extern int yylineno;
void yyerror(const char *s);
%}

%x COMMENT          

%%                  

"//".*              {  }

"/*"                { BEGIN(COMMENT); }
<COMMENT>{
    "*/"            { BEGIN(INITIAL); }
    .|\n            { }
}

"struct"                          { return STRUCT; }
"return"                          { return RETURN; }
"if"                              { return IF; }
"else"                            { return ELSE; }
"while"                           { return WHILE; }

"int"|"float"                     { yylval.str = strdup(yytext); return TYPE; }

[a-zA-Z_][a-zA-Z0-9_]*            { yylval.str = strdup(yytext); return ID; }

([0-9]+\.[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?  { yylval.fval = atof(yytext); return FLOAT; }

0[xX][0-9a-fA-F]+                 { yylval.ival = strtol(yytext, NULL, 16); return INT; }
0[0-7]+                           { yylval.ival = strtol(yytext, NULL, 8);  return INT; }
[1-9][0-9]*|0                     { yylval.ival = atoi(yytext);            return INT; }

"=="|"!="|"<="|">="               { yylval.str = strdup(yytext); return RELOP; }
"<"|">"                           { yylval.str = strdup(yytext); return RELOP; }

"="                               { yylval.str = strdup(yytext); return ASSIGNOP; }

"&&"                              { return AND; }
"||"                              { return OR; }

";"                               { return SEMI; }
","                               { return COMMA; }
"\+"                              { return PLUS; }
"-"                               { return MINUS; }
"\*"                              { return STAR; }
"/"                               { return DIV; }
"("                               { return LP; }
")"                               { return RP; }
"\["                              { return LB; }
"\]"                              { return RB; }
"\{"                              { return LC; }
"\}"                              { return RC; }
"\."                              { return DOT; }

[ \t\n]+                          {  }

.   { 
        char buf[64];
        snprintf(buf, sizeof(buf), "Mysterious character \"%s\"", yytext);
        fprintf(stderr, "Error type A at Line %d: %s\n", yylineno, buf);
    }
%%
