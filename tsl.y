%{
#include <stdio.h>
#include <string.h>
#include "tslAST.h"


enumType eType;
nodeKind nk;

extern int yylineno;
node *root;
%}

%start start_program
%union {
	struct _node *ptrVal;
	struct _idDec * IDDecNode;
	struct _idDecTail *IDDecTailNode;
	struct _idListNode *IDListNode;
	struct _numListNode *NUMListNode;

	char lexeme[20];
	
	int intVal;
	unsigned eType;
	unsigned nk;
	char charVal;
	int tslLineno;
}
%token START
// type
%token INT INTSET CHAR CHARSET BITSET INTTUP CHARTUP BOOL
%type<eType> type
// Assignment 
%token <ptrVal> ASSIGN ADD_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN OR_ASSIGN INC DEC ADD LESS TOUCH_VAL
// basic operator
%token SUB MUL DIV MOD
// Relational operatior
%token EQUAL GREATER GREATER_EQUAL LESS_EQUAL NOT_EQUAL
// Logical operator
%token OP_AND OP_OR OP_NOT 
// Bit operator
%token BIT_NOT BIT_AND BIT_OR BIT_NAND BIT_NOR BIT_XOR BIT_BIC
// Puntuator
%token COMMA SEMICOLON OPPAR CLPAR CLBRA OPBRA
// Statement
%token IF ELSE WHILE FOR REPEAT TOUCH RETURN READ WRITE
// Constant, Variable
%token TRUE FALSE BIT
%token <ptrVal> ID
%token <intVal> NUM
%type <IDDecNode> id_dec
%type <IDListNode> id_list
%type <NUMListNode> num_list
%type <IDDecTailNode> id_dec_tail

%type <ptrVal> assign_term start_program
%type <ptrVal> arithmetic_factor arithmetic_term arithmetic_expr
%type <ptrVal> expr relational_expr
%type <ptrVal> stmt while_stmt for_stmt touch_stmt if_stmt repeat_stmt read write ret_stmt stmt_list
%type <ptrVal> id_num assign_stmt body func_dec

%%

start_program	: func_dec START body {
	$$ = (node *)malloc(sizeof(node));
	$$->childPointer[0] = $1;
	$$->childPointer[1] = $3;
	$$->childPointer[2] = NULL;
	$$->numOfChild = 2;
	$$->kind = nk_start_program;
	root = $$;
	printf("start_program -> func_dec START body\n");
}
| START body {
	$$ = (node *)malloc(sizeof(node));
	$$->childPointer[0] = $2;
	$$->childPointer[1] = NULL;
	$$->numOfChild = 1;
	$$->kind = nk_start_program;
	root = $$;
	printf("start_program -> START body\n");
};
id_list : ID 
		{$$ = (idListNode *)malloc(sizeof(idListNode));
		$$->idNum = 0;
		strcpy($$->name[$$->idNum++], yylval.ptrVal->IDName); }
		| id_list COMMA ID {
		$$ = $1;
		$$->idNum = $1->idNum;
		strcpy($$->name[$$->idNum++],yylval.ptrVal->IDName); };	
type 	: INT	{$$ = eINT; /*printf("type -> INT\n");*/}
		| CHAR	{$$ = eCHAR; /*printf("type -> CHAR\n");*/}
		| INTSET {$$ = eINTSET;	/*printf("type -> INTSET%d\n", eINTSET);*/}
		| CHARSET {$$ = eCHARSET; printf("type -> CHARSET\n");}
		| BITSET {$$ = eBITSET;	printf("type -> BITSET\n");	}
		| INTTUP {$$ = eINTTUP;	printf("type -> INTTUP\n");}
		| CHARTUP {$$ = eCHARTUP; printf("type -> CHARTUP\n");}
		| BOOL {$$ = eBOOL;	printf("type -> BOOL\n");};
id_dec_tail : ASSIGN id_num {
//		printf("id_dec_tail -> ASSIGN id_num\n");
		
		}
| ASSIGN OPBRA num_list CLBRA {
//		printf("id_dec_tail -> ASSIGN OPBRA num_list CLBRA\n");
		int sz = $3->size;
		int i = 0;
		$$ = (idDecTail *)malloc(sizeof(idDecTail));
		for(i = 0 ; i < sz ; ++i) {
		//	printf("%d, ", $3->nums[i]);
			$$->nums[i] = $3->nums[i];
		}
		$$->size = $3->size;
//		printf("\n");
		
}
| ASSIGN OPBRA CLBRA {
		$$ = (idDecTail *)malloc(sizeof(idDecTail));
		$$->size = 0;		
		/*$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_id_dec_tail;*/
//		printf("id_dec_tail -> ASSIGN OPBRA CLBRA\n");
};
id_dec	: type id_list {
		char str[10];
		int i = 0;
		$$ = (idDecNode *)malloc(sizeof(idDecNode));
		$$->typeKind = $1;
		for(i = 0 ; i < $2->idNum ; ++i) {
			strcpy($$->name[i], $2->name[i]);
		}
		$$->idNum = $2->idNum;
		typeToString(str, $1);
		for(i = 0 ; i < $$->idNum ; ++i) {
			printf("%s\n", $$->name[i]);
			InsertSymbol($$->name[i], yylineno, $1, 0, NULL, NULL, 1);
		}
}

		
| type id_list id_dec_tail {
//		printf("id_dec -> type id_list id_dec_tail\n");	
	char str[10];
	int i = 0;
	int sz;
	$$ = (idDecNode *)malloc(sizeof(idDecNode));
	$$->typeKind = $1;
	for(i = 0 ; i < $2->idNum ; ++i) {
		strcpy($$->name[i], $2->name[i]);
		//printf("InsertSymbol success = %d\n", 
		InsertSymbol($$->name[i], yylineno, $1, 1, $3->nums, NULL, $3->size);
	}
	$$->idNum = $2->idNum;
	typeToString(str, $1);
	sz = $3->size;
	/*
	for(i = 0 ; i < sz ; ++i) {
		$$->nums[i] = $3->nums[i];
		printf("At id_dec : %d, ", $$->nums[i]);
	}*/
};
literal	: BIT | NUM | TRUE | FALSE;
id_num : ID {
		$$ = yylval.ptrVal;
			printf("id_num -> ID\n");	
}
| NUM { $$ = yylval.ptrVal;
//			printf("id_num -> NUM\n");		
};
num_list : NUM {
		$$ = (numListNode *)malloc(sizeof(numListNode));
		$$->size = 0;
		$$->nums[$$->size++] = yylval.ptrVal->ival;

//			printf("num_list -> NUM\n");
		 } 

| num_list COMMA NUM {
		$$ = $1;
		$$->size = $1->size;
		$$->nums[$$->size++] = yylval.ptrVal->ival;
//			printf("num_list -> num_list COMMA NUM\n");
		}; 	


arg_list : type ID {printf("arg_list -> type ID\n");
}
| arg_list COMMA type ID {
		printf("arg_list -> arg_list COMMA type ID\n");
};
func_head 	: type ID OPPAR arg_list CLPAR {
		printf("func_head -> type ID OPPAR arg_list CLPAR\n");
}

| type ID OPPAR CLPAR {
		printf("func_head -> type ID OPPAR CLPAR\n");
};
func_main	: SEMICOLON {
		printf("func_main -> SEMICOLON\n");
}
| body {
		printf("func_main -> body\n");
};
func_dec : func_dec func_head func_main {
		printf("func_dec -> func_dec func_head func_main\n");
}
| func_head func_main {
		printf("func_dec -> func_head func_main\n");
};

stmt : assign_stmt {$$ = $1;  printf("stmt -> assign_stmt\n");}
     | while_stmt { $$ = $1; printf("stmt -> while_stmt"); }
     | for_stmt { $$ = $1;  printf("stmt -> for_stmt\n");  }
     | touch_stmt {	$$ = $1; printf("stmt -> touch_stmt\n"); }
     | if_stmt { $$ = $1; printf("stmt -> if_stmt\n"); }
     | repeat_stmt { $$ = $1; printf("stmt -> repeat_stmt"); }
     | read { $$ = $1; printf("stmt -> read\n");}
     | write { $$ = $1; printf("stmt -> write\n");}
	 | id_dec {printf("stmt -> id_dec\n");}
	 | ret_stmt { $$ = $1; printf("stmt -> ret_stmt");};

stmt_list : stmt SEMICOLON {
		$$ = (node *)malloc(sizeof(node));
		$$->numOfChild = 0;
		$$->childPointer[$$->numOfChild++] = $1;
		$$->kind = nk_stmt_list;
//		printf("stmt_list -> stmt SEMICOLON\n");
}
| stmt_list stmt SEMICOLON {
		$$ = $1;
		$$->childPointer[$$->numOfChild++] = $2;		
		//		printf("stmt_list -> stmt_list stmt SEMICOLON\n");
};

body : OPBRA stmt_list CLBRA {
		$2->childPointer[$2->numOfChild] = NULL;
		$$ = $2;
		
//		printf("body -> OPBRA stmt_list CLBRA\n");

} 
	| OPBRA CLBRA {}
	;
assign_stmt : ID ASSIGN assign_term {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_assign_stmt;
		$$->childPointer[0] = $1;
		$$->childPointer[1] = $2;
		$$->childPointer[2] = $3;
		$$->childPointer[3] = NULL;
		$$->numOfChild = 3;
		//printf("assign_stmt %s = %d\n", $1->IDName, $3->ival);
}
| ID ADD_ASSIGN assign_term {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_assign_stmt;
		$$->childPointer[0] = $1;
		$$->childPointer[1] = $2;
		$$->childPointer[2] = $3;
		$$->childPointer[3] = NULL;
		$$->numOfChild = 3;
//		printf("assign_stmt -> ID ADD_ASSIGN assign_term\n");
}
			| ID MINUS_ASSIGN assign_term {}
			| ID MUL_ASSIGN assign_term {}
			| ID MOD_ASSIGN assign_term {}
			| ID AND_ASSIGN assign_term {}
			| ID OR_ASSIGN assign_term {}
	 	    | assign_term { $$ = $1;}
			;
assign_term : INC ID {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_assign_term;
		$$->childPointer[0] = $1;
		$$->childPointer[1] = $2;
		$$->childPointer[2] = NULL;
		$$->numOfChild = 2;
}
| DEC ID {
		printf("assign_term -> DEC ID\n");		
}
| ID INC {
		printf("assign_term -> ID INC\n");
}
| ID DEC {
		printf("assign_term -> ID DEC\n");
}
| TOUCH_VAL {
		$$ = yylval.ptrVal;
		
//		printf("assign_term -> TOUCH_VAL\n");
}
| expr {
		$$ = $1;
		printf("assign_term -> expr\n");
};

repeat_stmt : REPEAT OPPAR NUM CLPAR body {
		printf("repeat_stmt -> REPEAT OPPAR NUM CLPAR body\n");
}
| REPEAT OPPAR ID CLPAR body {
		printf("repeat_stmt -> REPEAT OPPAR ID CLPAR body\n");	
};
while_stmt : WHILE OPPAR stmt CLPAR body {
		printf("while_stmt -> WHILE OPPAR stmt CLPAR body\n");	
};
for_stmt : FOR OPPAR assign_stmt SEMICOLON relational_expr SEMICOLON assign_stmt CLPAR body {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_for_stmt;
		$$->childPointer[0] = $3;
		$$->childPointer[1] = $5;
		$$->childPointer[2] = $7;
		$$->childPointer[3] = $9;
		$$->childPointer[4] = NULL;
		$$->numOfChild = 4;
//	printf("for_stmt -> FOR OPPAR assign_stmt SEMICOLON relational_expr SEMICOLON assign_stmt CLPAR body\n");
};
touch_stmt : TOUCH OPPAR ID COMMA ID COMMA ID CLPAR body {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_touch_stmt;
		//$$->childPointer[0] = $3;
		$$->childPointer[0] = $3;
		$$->childPointer[1] = $5;
		$$->childPointer[2] = $7;
		$$->childPointer[3] = $9;
		$$->childPointer[4] = NULL;
		$$->numOfChild = 4;
//		printf("touch_stmt -> WHILE OPPAR stmt CLPAR body\n");		
};
if_stmt : IF OPPAR expr CLPAR body {
//		printf("if_stmt -> IF OPPAR expr CLPAR body\n");
}
| IF OPPAR expr CLPAR body ELSE body {	
//		printf("if_stmt -> IF OPPAR expr CLPAR body ELSE body\n");
};

read	: READ OPPAR ID CLPAR {
	$$ = (node *)malloc(sizeof(node));
	$$->kind = nk_read;
	$$->childPointer[0] = $3;
	$$->childPointer[1] = NULL;
//	$$->idListPointer = $3;
//		printf("read\n");
};
write	: WRITE OPPAR ID CLPAR {
	$$ = (node *)malloc(sizeof(node));
	$$->kind = nk_write;
	$$->childPointer[0] = $3;
	$$->childPointer[1] = NULL;
//	$$->idListPointer = $3;
//		printf("write\n");
};
ret_stmt : RETURN ID {printf("RETURN ID\n");} 
| RETURN literal {
		printf("RETURN literal\n");
};
function_tail : OPPAR id_list CLPAR  {
		printf("function_tail -> OPPAR id_list CLPAR\n");
}
| OPPAR CLPAR {
		printf("function_tail -> OPPAR CLPAR\n");
};
function_call : ID function_tail {
		printf("function_tail -> ID function_tail\n");	
};

expr 	: logical_expr {printf("expr -> logical_expr\n");		
}
| arithmetic_expr {
//		printf("expr -> arithmetic_expr\n");
	$$ = $1;		
//	printf("\nexxxxxpr : %s\n", $1->IDName);
}
| relational_expr {
	$$ = $1;
//		printf("expr -> relational_expr\n");	
}
| bit_expr {
		printf("expr -> bit_expr\n");			
}
| function_call {
		printf("expr -> function_call\n");	
};

relational_expr : expr EQUAL id_num {
		printf("relational_expr -> expr EQUAL id_num\n");
}
| ID LESS id_num {
		$$ = (node *)malloc(sizeof(node));
		$$->kind = nk_relational_expr;
		$$->childPointer[0] = $1;
		$$->childPointer[1] = $2;
		$$->childPointer[2] = $3;
		$$->childPointer[3] = NULL;
		$$->numOfChild = 3;
		printf("relational_expr -> expr LESS id_num\n");
}
| expr GREATER id_num {
		printf("relational_expr -> expr GREATER id_num\n");
}
| expr GREATER_EQUAL id_num {
		printf("relational_expr -> expr GREATER_EQUAL id_num\n");
}
| expr LESS_EQUAL id_num {
		printf("relational_expr -> expr LESS_EQUAL id_num\n");
}
| expr NOT_EQUAL id_num {
		printf("relational_expr -> expr NOT_EQUAL id_num\n");
}; 

arithmetic_expr : ID ADD arithmetic_term {
	$$ = (node *)malloc(sizeof(node));
	$$->childPointer[0] = $1;
	$$->childPointer[1] = $2;
	$$->childPointer[2] = $3;
	$$->childPointer[3] = NULL;
	$$->numOfChild = 3;
	$$->kind = nk_arithmetic_expr;
	//		printf("arithmetic_expr -> arithmetic_expr ADD arithmetic_term\n");
}
| arithmetic_expr SUB arithmetic_term {
//		printf("arithmetic_expr -> arithmetic_expr SUB arithmetic_term\n");
}
| arithmetic_term {
//		printf("arithmetic_expr -> arithmetic_term\n");
	$$ = $1;				
};
arithmetic_term : arithmetic_term MUL arithmetic_factor {
//		printf("arithmetic_term -> arithmetic_term MUL arithmetic_factor\n");
}
| arithmetic_term DIV arithmetic_factor {
//		printf("arithmetic_term -> arithmetic_term DIV arithmetic_factor\n");	
}
| arithmetic_term MOD arithmetic_factor {
//		printf("arithmetic_term -> arithmetic_term MOD arithmetic_factor\n");

}
| arithmetic_factor {
//		printf("arithmetic_term -> arithmetic_factor\n");
	$$ = $1;
};

arithmetic_factor : ID { $$ = yylval.ptrVal;
//		printf("afafafaf -> %s\n", yylval.ptrVal->IDName);
//	printf("\n\n%s\n\n", name); printf("arithmetic_factor -> ID\n");
}
| NUM { $$ = yylval.ptrVal;
		printf("\narithmetic_factor -> %d\ns", yylval.ptrVal->ival);
//		printf("arithmetic_factor -> NUM\n");
}
| OPPAR arithmetic_expr CLPAR {
//		printf("arithmetic_factor -> OPPAR arithmetic_expr CLPAR\n");	
};

bit_expr : bit_expr BIT_OR bit_term 
		 | bit_expr BIT_NOR bit_term 
		 | bit_expr BIT_XOR bit_term 
		 | bit_term;
bit_term : bit_term BIT_AND bit_factor 
		 | bit_term BIT_NAND bit_factor 
		 | bit_term BIT_BIC bit_factor 
		 | bit_factor;
bit_factor : BIT_NOT bit_end | bit_end;
bit_end : BIT | OPPAR bit_expr CLPAR;
logical_expr : logical_expr OP_OR logical_term | logical_term;
logical_term : logical_term OP_AND logical_factor | logical_factor;
logical_factor : logical_factor OP_NOT logical_end | logical_end;
logical_end : TRUE | FALSE | OPPAR logical_expr CLPAR;


%%

int main(int argc, char **argv) {
	yyparse();
	printSymt();
	printHead();
	prunChildNodes(root->childPointer[0]);
	printChildNodes(root->childPointer[0]);
	printf("---------- Abstract Syntax Tree ----------\n");
	printTree(root);
	printf("---------- Abstract Syntax Tree(End) ----------");
	printf("\n\n");
	printf("---------- Code Generation ----------\n");
	codeGen(root);
	printf("---------- Code Generation(End) ----------\n");
}

yyerror(char *s) {
	fprintf(stderr, "error : %s\n", s);
}



