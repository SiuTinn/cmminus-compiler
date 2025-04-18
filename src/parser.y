/* parser.y — Bison grammar for CMINUS with AST support */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"            /* ASTNode, ast_new_node, ast_add_child, ast_print */

extern int yylineno;       /* from Flex */
int yylex(void);           /* lexer entry */
void yyerror(const char *s) {
    fprintf(stderr, "Error type B at Line %d: %s\n", yylineno, s);
}

/* The root of the AST */
ASTNode *root = NULL;
%}

%code requires {
    #include "ast.h"
}

/* Value‐type union: match yylval.str / .ival / .fval in lexical.l */
%union {
    char      *str;
    int        ival;
    float      fval;
    ASTNode   *node;
}

/* ———— Terminals ———— */
/* 关键字 */
%token        STRUCT RETURN IF ELSE WHILE
/* 类型关键字，<str> 使得 $1 能取到 strdup(yytext) */
%token <str>  TYPE
/* ID/常量 */
%token <str>  ID
%token <ival> INT
%token <fval> FLOAT
/* 运算符 */
%token <str>  RELOP       /* $2 in Exp: Exp RELOP Exp */
%token <str>  ASSIGNOP    /* $2 in Exp: Exp ASSIGNOP Exp */
%token        PLUS MINUS STAR DIV AND OR
/* 分隔符 */
%token        SEMI COMMA LP RP LB RB LC RC DOT

/* Nonterminals that carry ASTNode* */
%type   <node> Program ExtDefList ExtDef Specifier StructSpecifier OptTag Tag ExtDecList VarDec FunDec VarList ParamDec CompSt StmtList Stmt DefList Def DecList Dec Exp Args

/* Operator precedences */
%right ASSIGNOP
%left  OR
%left  AND
%left  RELOP
%left  PLUS MINUS
%left  STAR DIV
%right NOT UMINUS

%start Program

%%

/*—————— Grammar rules with AST actions ——————*/

Program
    : ExtDefList
      { root = $1; }
    ;

ExtDefList
    : /* empty */
      { $$ = ast_new_node(NODE_EXTDEFLIST, NULL, yylineno); }
    | ExtDefList ExtDef
      {
        $$ = $1;
        ast_add_child($$, $2);
      }
    ;

ExtDef
    : Specifier ExtDecList SEMI
      {
        $$ = ast_new_node(NODE_EXTDEF, NULL, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $2);
      }
    | Specifier SEMI
      {
        $$ = ast_new_node(NODE_EXTDEF, NULL, yylineno);
        ast_add_child($$, $1);
      }
    | Specifier FunDec CompSt
      {
        $$ = ast_new_node(NODE_EXTDEF, NULL, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $2);
        ast_add_child($$, $3);
      }
    ;

Specifier
    : TYPE
      { $$ = ast_new_node(NODE_SPECIFIER, $1, yylineno); }
    | StructSpecifier
      { $$ = $1; }
    ;

StructSpecifier
    : STRUCT OptTag LC DefList RC
      {
        $$ = ast_new_node(NODE_STRUCTSPEC, NULL, yylineno);
        ast_add_child($$, $2);  /* tag if any */
        ast_add_child($$, $4);  /* field definitions */
      }
    | STRUCT Tag
      {
        $$ = ast_new_node(NODE_STRUCTSPEC, NULL, yylineno);
        ast_add_child($$, $2);
      }
    ;

OptTag
    : ID
      { $$ = ast_new_node(NODE_TAG, $1, yylineno); }
    | /* empty */
      { $$ = ast_new_node(NODE_TAG, NULL, yylineno); }
    ;

Tag
    : ID
      { $$ = ast_new_node(NODE_TAG, $1, yylineno); }
    ;

ExtDecList
    : VarDec
      { $$ = ast_new_node(NODE_EXTDECLIST, NULL, yylineno); ast_add_child($$, $1); }
    | ExtDecList COMMA VarDec
      {
        $$ = $1;
        ast_add_child($$, $3);
      }
    ;

VarDec
    : ID
      { $$ = ast_new_node(NODE_VARDEC, $1, yylineno); }
    | VarDec LB INT RB
      {
        $$ = ast_new_node(NODE_VARDEC, NULL, yylineno);
        ast_add_child($$, $1);
        /* create INT node for the subscript */
        char buf[32]; snprintf(buf,32,"%d",$3);
        ASTNode *n = ast_new_node(NODE_INT, buf, yylineno);
        ast_add_child($$, n);
      }
    ;

FunDec
    : ID LP VarList RP
      {
        $$ = ast_new_node(NODE_FUNDEC, $1, yylineno);
        ast_add_child($$, $3);
      }
    | ID LP RP
      {
        $$ = ast_new_node(NODE_FUNDEC, $1, yylineno);
      }
    ;

VarList
    : ParamDec
      { $$ = ast_new_node(NODE_VARLIST, NULL, yylineno); ast_add_child($$, $1); }
    | VarList COMMA ParamDec
      {
        $$ = $1;
        ast_add_child($$, $3);
      }
    ;

ParamDec
    : Specifier VarDec
      {
        $$ = ast_new_node(NODE_PARAMDEC, NULL, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $2);
      }
    ;

CompSt
    : LC DefList StmtList RC
      {
        $$ = ast_new_node(NODE_COMPST, NULL, yylineno);
        ast_add_child($$, $2);
        ast_add_child($$, $3);
      }
    ;

DefList
    : /* empty */
      { $$ = ast_new_node(NODE_DEFLIST, NULL, yylineno); }
    | DefList Def
      {
        $$ = $1;
        ast_add_child($$, $2);
      }
    ;

Def
    : Specifier DecList SEMI
      {
        $$ = ast_new_node(NODE_DEF, NULL, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $2);
      }
    ;

DecList
    : Dec
      { $$ = ast_new_node(NODE_DECLIST, NULL, yylineno); ast_add_child($$, $1); }
    | DecList COMMA Dec
      {
        $$ = $1;
        ast_add_child($$, $3);
      }
    ;

Dec
    : VarDec
      { $$ = ast_new_node(NODE_DEC, NULL, yylineno); ast_add_child($$, $1); }
    | VarDec ASSIGNOP Exp
      {
        $$ = ast_new_node(NODE_DEC, NULL, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    ;

StmtList
    : /* empty */
      { $$ = ast_new_node(NODE_STMTLIST, NULL, yylineno); }
    | StmtList Stmt
      {
        $$ = $1;
        ast_add_child($$, $2);
      }
    ;

Stmt
    : Exp SEMI
      {
        $$ = ast_new_node(NODE_STMT, NULL, yylineno);
        ast_add_child($$, $1);
      }
    | CompSt
      { $$ = $1; }
    | RETURN Exp SEMI
      {
        $$ = ast_new_node(NODE_STMT, "return", yylineno);
        ast_add_child($$, $2);
      }
    | IF LP Exp RP Stmt
      {
        $$ = ast_new_node(NODE_STMT, "if", yylineno);
        ast_add_child($$, $3);
        ast_add_child($$, $5);
      }
    | IF LP Exp RP Stmt ELSE Stmt
      {
        $$ = ast_new_node(NODE_STMT, "if-else", yylineno);
        ast_add_child($$, $3);
        ast_add_child($$, $5);
        ast_add_child($$, $7);
      }
    | WHILE LP Exp RP Stmt
      {
        $$ = ast_new_node(NODE_STMT, "while", yylineno);
        ast_add_child($$, $3);
        ast_add_child($$, $5);
      }
    ;

Exp
    : Exp ASSIGNOP Exp
      {
        $$ = ast_new_node(NODE_EXP, "=", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp AND Exp
      {
        $$ = ast_new_node(NODE_EXP, "&&", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp OR Exp
      {
        $$ = ast_new_node(NODE_EXP, "||", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp RELOP Exp
      {
        $$ = ast_new_node(NODE_EXP, $2, yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp PLUS Exp
      {
        $$ = ast_new_node(NODE_EXP, "+", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp MINUS Exp
      {
        $$ = ast_new_node(NODE_EXP, "-", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp STAR Exp
      {
        $$ = ast_new_node(NODE_EXP, "*", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp DIV Exp
      {
        $$ = ast_new_node(NODE_EXP, "/", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | LP Exp RP
      { $$ = $2; }
    | MINUS Exp %prec UMINUS
      {
        $$ = ast_new_node(NODE_EXP, "neg", yylineno);
        ast_add_child($$, $2);
      }
    | NOT Exp
      {
        $$ = ast_new_node(NODE_EXP, "!", yylineno);
        ast_add_child($$, $2);
      }
    | ID LP Args RP
      {
        $$ = ast_new_node(NODE_EXP, "call", yylineno);
        ast_add_child($$, ast_new_node(NODE_ID, $1, yylineno));
        ast_add_child($$, $3);
      }
    | ID LP RP
      {
        $$ = ast_new_node(NODE_EXP, "call", yylineno);
        ast_add_child($$, ast_new_node(NODE_ID, $1, yylineno));
      }
    | Exp LB Exp RB
      {
        $$ = ast_new_node(NODE_EXP, "array", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, $3);
      }
    | Exp DOT ID
      {
        $$ = ast_new_node(NODE_EXP, ".", yylineno);
        ast_add_child($$, $1);
        ast_add_child($$, ast_new_node(NODE_ID, $3, yylineno));
      }
    | ID
      { $$ = ast_new_node(NODE_ID, $1, yylineno); }
    | INT
      {
        char buf[32]; snprintf(buf,32,"%d",$1);
        $$ = ast_new_node(NODE_INT, buf, yylineno);
      }
    | FLOAT
      {
        char buf[32]; snprintf(buf,32,"%.6g",$1);
        $$ = ast_new_node(NODE_FLOAT, buf, yylineno);
      }
    ;

Args
    : Exp
      { $$ = ast_new_node(NODE_ARGS, NULL, yylineno); ast_add_child($$, $1); }
    | Args COMMA Exp
      {
        $$ = $1;
        ast_add_child($$, $3);
      }
    ;

%%