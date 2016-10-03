%option yylineno

%{
#include <string.h>
#include <stdio.h>
#include "y.tab.h"
#include "tslAST.h"
enumType eType;
nodeKind nk;
int line_num = 1;

%}

delim		[ \t\n]
ws			{delim}+
letter		[A-Za-z]
digit		[0-9]
id			{letter}({letter}|{digit})*
number		{digit}+
binary		"0b"[01]+
%%

"read"		{return READ;}
"write"		{return WRITE;}
"START()"	{return START;}
"int"		{return INT;}
"intset"	{return INTSET;} 
"char"		{return CHAR;}
"charset"	{return CHARSET;}
"bitset"	{return BITSET;}
"inttup"	{return INTTUP;}
"chartup"	{return CHARTUP;}
"bool"		{return BOOL;}

"="			{	yylval.ptrVal = (node *)malloc(sizeof(node));
				yylval.ptrVal->kind = nk_ASSIGN;
				return ASSIGN;}
"+="		{	yylval.ptrVal = (node *)malloc(sizeof(node));
				yylval.ptrVal->kind = nk_ADD_ASSIGN;
				return ADD_ASSIGN;}
"-="		{return MINUS_ASSIGN;}
"*="		{return MUL_ASSIGN;}
"/="		{return DIV_ASSIGN;}
"%="		{return MOD_ASSIGN;}
"&="		{return AND_ASSIGN;}
"|="		{return OR_ASSIGN;}
"++"		{yylval.ptrVal = (node *)malloc(sizeof(node));
				yylval.ptrVal->kind = nk_INC;
				return INC;}
"--"		{return DEC;}

"+"		{yylval.ptrVal = (node *)malloc(sizeof(node));
				yylval.ptrVal->kind = nk_ADD;
				return ADD;}
"-"		{return SUB;}
"*"		{return MUL;}
"/"		{return DIV;}
"%"		{return MOD;}

"=="		{return EQUAL;}
">"		{return GREATER;}
"<"		{	yylval.ptrVal = (node *)malloc(sizeof(node));
			yylval.ptrVal->kind = nk_LESS;
			return LESS;}
">="		{return GREATER_EQUAL;}
"<="		{return LESS_EQUAL;}
"!="	{return NOT_EQUAL;}
"~"		{return BIT_NOT;}
"&"		{return BIT_AND;}
"|"		{return BIT_OR;}
"~&"		{return BIT_NAND;}
"~|"		{return BIT_NOR;}
"^"		{return BIT_XOR;}
"&~"		{return BIT_BIC;}

"&&"		{return OP_AND;}
"||"		{return OP_OR;}
"!"		{return OP_NOT;}

","		{return COMMA;}
";"		{return SEMICOLON;}
"("		{return OPPAR;}
")"		{return CLPAR;}
"}"		{return CLBRA;}
"{"		{return OPBRA;}
"//".*		;

"if"		{return IF;}
"else"		{return ELSE;}
"while"		{return WHILE;}
"for"		{return FOR;}
"repeat"	{return REPEAT;}
"touch"		{return TOUCH;}

"return"	{return RETURN;}
"true"		{return TRUE;}
"false"		{return FALSE;}
"touch.val" {yylval.ptrVal = (node *)malloc(sizeof(node));
			yylval.ptrVal->kind = nk_TOUCH_VAL;
			return TOUCH_VAL;}
{ws}		;
{id}		{
	strcpy(yylval.lexeme, yytext); 
	yylval.ptrVal = (node *)malloc(sizeof(node));
	strcpy(yylval.ptrVal->IDName, yytext);

	yylval.ptrVal->kind = nk_ID;
	return (ID);
}
{number}	{
	yylval.intVal = atoi(yytext); 
	yylval.ptrVal = (node *)malloc(sizeof(node));
	yylval.ptrVal->kind = nk_NUM;
	yylval.ptrVal->ival = atoi(yytext);
	return (NUM);}
{binary}	{return BIT;}

.			{printf("%s", yytext);}

%%

