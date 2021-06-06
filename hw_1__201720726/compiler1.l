%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define MAX 300	
int num = 0;
char *I_D[MAX] = {NULL, };
char *STR[MAX] = {NULL, };
int i = 0;
int k = 0;
int indexcount = 0;
int stringcount = 0;
int count = 0;
int count2 = 0;
char *str;
char *str2;
char *str3;
int len;
char *r;
%}

%x C_COMMENT
ws [ \t\n]+
letter [a-zA-z]
digit [0-9]
alnum {letter}|{digit}
print [ -~]

ID [_]*[a-zA-Z][a-zA-Z0-9_]*|[_]+[0-9]+[a-zA-Z0-9]*
INT [-+]?[0-9]+
DOUBLE [-+]?{digit}+"."{digit}+|[-+]?[0-9]+"e"[-+]?[0-9]*|[-+]?[0-9]+"."[0-9]+"e"[-+]?[0-9]*|[-+]?[0-9]+"E"[-+]?[0-9]*|[-+]?[0-9]+"."[0-9]+"E"[-+]?[0-9]*
STRING [\"]{print}*[\"]
COMMENT2 "/""/"{print}*
COMMENT1 "/*"([^*]|(\*+[^*/]))*\*+\/
ERROR .

%%
{ws} {}
"+" {printf("<OP, %s>%20s\n",yytext,yytext);}
"-" {printf("<OP, %s>%20s\n",yytext,yytext);}
"*" {printf("<OP, %s>%20s\n",yytext,yytext);}
"/" {printf("<OP, %s>%20s\n",yytext,yytext);}
"=" {printf("<OP, %s>%20s\n",yytext,yytext);}
">" {printf("<OP, %s>%20s\n",yytext,yytext);}
">=" {printf("<OP, %s>%20s\n",yytext,yytext);}
"<" {printf("<OP, %s>%20s\n",yytext,yytext);}
"<=" {printf("<OP, %s>%20s\n",yytext,yytext);}
"==" {printf("<OP, %s>%20s\n",yytext,yytext);}
"!=" {printf("<OP, %s>%20s\n",yytext,yytext);}
"(" {printf("<LPAREN, >%20s\n",yytext);}
")" {printf("<RPAREN, >%20s\n",yytext);}
";" {printf("<SEMI, >%20s\n",yytext);}
"," {printf("<COMMA, >%20s\n",yytext);}
"{" {printf("<LBRACE, >%20s\n",yytext);}
"}" {printf("<RBRACE, >%20s\n",yytext);}
"\"" {printf("<DOUBLE QUOTE, >%20s\n",yytext);}
"int"|"INT" {printf("<INT, >%20s\n",yytext);}
"double"|"DOUBLE" {printf("<DOUBLE, >%20s\n",yytext);}
"str"|"STR" {printf("<STRING, >%20s\n",yytext);}
"if" {printf("<IF, >%16s\n",yytext);}
"while" {printf("<WHILE, >%20s\n",yytext);}
"return" {printf("<RETURN, >%20s\n",yytext);}

{COMMENT1} {printf("<COMMENT>%20s\n",yytext);}
{COMMENT2} {printf("<COMMENT>%20s\n",yytext);}
{ID} {
	if(strlen(yytext) <= 16) 
	str = strdup(yytext);	
	else
	str = strndup(yytext,16);
	
	for(k = 0; k < indexcount; k++){
	if(strcmp(I_D[k],str) == 0){
		printf("<ID, %d>%20s\n",k+1,str);
		break;
		}
	count++;
	}
	if(count == indexcount){	
		I_D[indexcount] = str;
		printf("<ID, %d>%20s\n",indexcount+1,str);
		indexcount++;
	}
	count = 0;
	str = NULL;
	
}
{INT} {	
	str3 = strdup(yytext);
	len = strlen(str3);
	if(len <= 10)
	printf("<INTEGER, %s>%20s\n",str3,str3);
	else{
	r = str3 + len - 10;
	printf("<INTEGER, %s>%20s\n",r,r);
	}
	
}
{DOUBLE} {printf("<DOUBLE, %s>%20s\n",yytext,yytext);}
{STRING} {
	str2 = strdup(yytext);

	for(k = 0; k < stringcount; k++){
	if(strcmp(STR[k],str2) == 0){
		printf("<STRING, %d>%20s\n",k+1,str2);
		break;
		}
	count2++;
	}
	if(count2 == stringcount){
		STR[stringcount] = str2;
		printf("<STRING, %d>%20s\n",stringcount+1,str2);
		stringcount++;
	}
	count2 = 0;
	str2 = NULL;
}
{ERROR} {printf("< lexical error~!!!! >%20s\n",yytext);}
%%

int main(int argc, char *argv[]){
	if(argc>1){
		FILE *file;
		file = fopen(argv[1],"r");
		if(!file){
		  fprintf(stderr,"could not open %s\n",argv[1]);
		
		}
		yyin = file;
	}

	yylex();
	printf("=====symbol table=====\n");
	printf("INDEX\tSYMBOLS\n");
	for(i = 0; i < indexcount; i++){
		printf(" %d\t%s\n",i+1,I_D[i]);
	}
		printf("=====string table=====\n");
		printf("INDEX\tSTRINGS\n");
	for(i = 0; i < stringcount; i++){
		printf(" %d\t%s\n",i+1,STR[i]);
	}
	return 0;
}
