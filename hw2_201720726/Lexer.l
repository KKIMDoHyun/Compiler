%{
	#include <stdio.h>
	#include <string.h>
	#include <stdbool.h>
	#include <stdlib.h>
	#define TOKEN_LIST_MAX 100 
	#define TOKEN_VALUE_MAX 10
	#define SYMBOL_TABLE_MAX 100
	#define SYMBOL_MAX 10

	typedef enum { ID = 1, INT, REAL, PLUS, MINUS, MUL, DIV, ASSIGN, LP, RP } TOKEN; 


	typedef struct {
		TOKEN token;
		char value[TOKEN_VALUE_MAX+1];
	}TOKEN_LIST;


	typedef struct Node{
		TOKEN tok;
		int ikey;
		double dkey;
		char symbol[SYMBOL_MAX+1];
		struct Node* left;
		struct Node* right;
	}Node;
	

	/************************************************************************
	 *																	    *
	 * 심볼테이블을 위한 구조체												        * 
	 * 심볼테이블은 배열로 구성한다.										            *
	 *																	    *
	 * 심볼테이블은 다음과 같이 구성된다.									            *
	 * symbol(@char[10]) - 입력한 수식에서 변수(Identifier)가 저장된다.		        *	 * (symbol은 최대 10자를 넘지 않는다고 가정한다.)						            *
	 * type(@TOKEN) - 변수에 저장되는 값이 정수인지 실수인지				                *
	 *				  구분하기 위한 타입 정보입니다. 						            *
	 * value(@union) - 변수에 저장되는 값을 나타냅니다.						        *
	 *																	    *
	 * (주의) 반드시 이걸 사용해서 구현 안하셔도 됩니다 !!. 				                *
	 * (주의) 본인이 편한 방식으로 구현 하셔도 됩니다 !!.					                *
	 *																	    *
	 ***********************************************************************/
	typedef struct {
		char symbol[SYMBOL_MAX+1];
		TOKEN type;
		double value;
		int key;
	} SYMBOL_TABLE;

	TOKEN_LIST in[TOKEN_LIST_MAX] = { 0, };

	int count = 0;

	int errorcount = 0;
	//precedence stack[10];
	//int cn = 0;



/* Variables */
	TOKEN_LIST token_list[TOKEN_LIST_MAX];
	SYMBOL_TABLE symbol_table[SYMBOL_TABLE_MAX];
	int token_number = 0;// 토큰 리스트에 저장된 토큰의 수
	int symbol_number = 0;// 심볼 테이블에 저장된 심볼의 수

	/* Functions */
	void do_lexical_analysis();
	void yyerror(char* );
	void initialize_symbol_table();
	bool is_symbol_duplicated(char* target);
	int find_symbol(char* target);
	void initialize_token_list(); 
	void print_token_list();
	void save_token(TOKEN token, char* value);
	void save_symbol(char* symbol);


	double cal(struct Node* node);
	struct Node* A();
	struct Node* AP();
	struct Node* E();
	struct Node* EP();
	struct Node* T();
	struct Node* TP();
	struct Node* F();
	struct Node* FP();
%}
id [a-zA-Z_][a-zA-Z0-9_]*
integer [1-9][0-9]*|[0]
real (0|[1-9][0-9]*)\.(0|[0-9]*[1-9])
delim [ \t\r]
ws {delim}+
under_score [_]+
digit_first [0-9]+[a-zA-Z|0-9|_]+	

%%
{ws}	;
"+"	{save_token(PLUS, "+");}
"-"	{save_token(MINUS, "-");}
"*"	{save_token(MUL, "*");}
"/"	{save_token(DIV, "/");}
"="	{save_token(ASSIGN, "=");}
"("	{save_token(LP, "(");}
")"	{save_token(RP, ")");}
"\n"	{ /* 어휘 분석기를 종료 시킨다 */ return 0;}

{integer}		{save_token(INT, yytext);}
{real}			{save_token(REAL, yytext);}

{digit_first}	{yyerror(yytext);}
{under_score}	{yyerror(yytext);}
{id}		{ save_symbol(yytext); save_token(ID, yytext);}
.		{yyerror(yytext);}
%%

int main()
{
struct Node* ROOT = (struct Node*)malloc(sizeof(struct Node));
	double num = 0;
	initialize_symbol_table();			// 심볼 테이블을 초기화 한다.

	while(!feof(stdin)) {
		initialize_token_list();		// 토큰 리스트를 초기화 한다.	
		printf(">");					// 프롬프트를 출력한다.
		do_lexical_analysis();			// 어휘 분석기를 호출한다.
		//print_token_list();		// 토큰리스트 출력
		
		num = cal(A());
	
		count = 0;
		if(errorcount == 0){
			printf("%.2lf\n",num);
		}
		errorcount = 0;

	}
	fclose(yyin);
	return 0;
}


void initialize_symbol_table() 
{
	for(int i = 0; i < SYMBOL_TABLE_MAX; i++) {
		symbol_table[i].symbol[0] = '\0';
		symbol_table[i].value = 0;
	}
}


void initialize_token_list() 
{
	token_number =0;
	for(int i = 0; i < TOKEN_LIST_MAX; i++) {
		token_list[i].token = 0;
		token_list[i].value[0] = '\0';
	}
}


void do_lexical_analysis()
{
		yyin = stdin;
		yylex();
		yyrestart(yyin);
}


void yyerror(char* e)
{
	//printf("lexical error\n");
	errorcount = 1;
}


void save_token(TOKEN token, char* value)
{
	token_list[token_number].token = token;
	strcpy(token_list[token_number].value, value);
	token_number++;
}


void save_symbol(char* symbol)
{
	// 심볼이 중복되지 않는 경우
	if(!is_symbol_duplicated(symbol)) {
		// 심볼 테이블에 저장
		strcpy(symbol_table[symbol_number].symbol, symbol);
		symbol_number++;

	}
}


bool is_symbol_duplicated(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 중복되는 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return true;
	}
	// 중복 안되는 경우
	return false;
}


int find_symbol(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 일치하는 심볼을 찾은 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return i;
	}
	return -1;
}


void print_token_list()
{
	int symbol_index = 0;
	printf("%s%20s\n", "TOKEN", "LEXEME");
	for(int i = 0; i < token_number; i++) {
		switch(token_list[i].token)
		{
			case INT: printf("%s%16s\n", "INTEGER", token_list[i].value); break;
			case REAL: printf("%s%16s\n", "REAL", token_list[i].value); break;
			case ID:
				if((symbol_index = find_symbol(token_list[i].value)) != -1)
				{
					printf("%s,%d%20s\n", "ID", symbol_index+1, 
							symbol_table[symbol_index].symbol); 
				}
				break;
			case PLUS: printf("%s%16s\n", "PLUS",token_list[i].value); break;
			case MINUS: printf("%s%16s\n", "MINUS",token_list[i].value); break;
			case MUL: printf("%s%16s\n", "MUL",token_list[i].value); break;
			case DIV: printf("%s%16s\n", "DIV",token_list[i].value); break;
			case ASSIGN: printf("%s%16s\n", "ASSIGN",token_list[i].value); break;
			case LP: printf("%s%16s\n", "LP",token_list[i].value); break;
			case RP: printf("%s%16s\n", "RP",token_list[i].value); break;
			default: break;
		}
	}

}


double cal(Node* node){

		if(errorcount == 0){
		if (node->tok == INT) {
			return node->ikey;
		}

		else if (node->tok == REAL) {
			return node->dkey;
		}

		else if(node->tok == ID){
			return symbol_table[find_symbol(node->symbol)].value;
		}

	switch(node->tok){
		case PLUS :
					return (cal(node->left) + cal(node->right));
		case MINUS :
					return (cal(node->left) - cal(node->right));
		case MUL :
					return (cal(node->left) * cal(node->right));
		case DIV :
					return (cal(node->left) / cal(node->right));
		case ASSIGN :
					symbol_table[find_symbol(node->left->symbol)].value = cal(node->right);
	
		}	
	}
	else{
		printf("error : lexical error\n");
	}
}



Node* A() {
	if (token_list[count].token == ID) {
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		strcpy(node->symbol, token_list[count].value);
		count++;		
		return AP(node);
	}
	else {
		return EP(TP(F()));
	}
}

Node* AP(Node* func) {
	if (token_list[count].token == ASSIGN) {
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		count++;

		node->left = func;
		node->right = A();
		return node;
	}
	else {
		return EP(TP(func));
	}
}

Node* E() {
	return EP(T());
}

Node* EP(Node* func) {
	if (token_list[count].token == PLUS) {
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		count++;
		node->left = func;	//파라미터로 받은 tree와
		node->right = T();	//T에서 반환된 tree를 child로 함.
		return EP(node);	//EP이 반환환 tree를 반환
	}
	else if (token_list[count].token == MINUS) {

		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		count++;
		node->left = func;	//파라미터로 받은 tree와
		node->right = T();	//F에서 반환된 tree를 child로 함.
		return EP(node);	//EP이 반환환 tree를 반환
	}
	else return(func);	//e면 파라미터 리턴
}

Node* T() {
	return TP(F());	//F가 반환한 TREE를 T'의 파라미터로 전달
}

Node* TP(Node *func) {
	if (token_list[count].token == MUL){
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		count++;
		node->left = func;	//파라미터로 받은 tree와
		node->right = F();	//F에서 반환된 tree를 child로 함.
		return TP(node);	//TP이 반환환 tree를 반환
	}
	else if (token_list[count].token == DIV) {
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		count++;
		node->left = func;	//파라미터로 받은 tree와
		node->right = F();	//F에서 반환된 tree를 child로 함.
		return TP(node);	//TP이 반환환 tree를 반환
	}
	else return func;	// e면 paramether로 전달받은 tree 반환
}

Node* F(){
	if (token_list[count].token == ID) {	//id면
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		strcpy(node->symbol, token_list[count].value);
		count++;
		return node;					//return해줌
	}
	else if (token_list[count].token == INT) {	//정수면
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		node->ikey = atoi(token_list[count].value);
		count++;
		return node;					//return해줌
	}
	else if (token_list[count].token == REAL) {	//실수면
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦
		node->tok = token_list[count].token;
		node->dkey = atof(token_list[count].value);
		count++;
		return node;					//return해줌
	}
	else if(token_list[count].token == LP){	//(E)를 만나면
		struct Node* node1 = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦	
		count++;
		node1 = E();				//E가 반환한 tree를 반환
		if(token_list[count].token == RP){
			count++;
			return node1;
			}
		}
	else if(token_list[count].token == MINUS){
		struct Node* node = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦	
		struct Node* node1 = (struct Node*)malloc(sizeof(struct Node)); //id 단말 node 만듦	
		node->tok = token_list[count].token;
		count++;
		node1-> ikey = 0;
		node1->tok = INT;
		node->left = node1;
		node->right = F();
		return node;
	}
	else return 0;			//그 외
	}
