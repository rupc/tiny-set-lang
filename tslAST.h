#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define HASHSIZE	1024
typedef enum {
	eINT, eCHAR, eBOOL, 
	eINTSET, eCHARSET, eBITSET, 
	eINTTUP, eCHARTUP
} enumType;

typedef enum {
	nk_NUM, nk_ID,
	nk_start_program, // 2
	nK_id_list,
	nk_type,
	nk_literal,
	nk_id_num,
	nk_num_list,
	nk_id_dec_tail, // 8
	nk_id_dec,
	nk_arg_list,
	nk_func_head,
	nk_func_main,
	nk_func_dec,
	nk_stmt,
	nk_stmt_list,	//15
	nk_body, 		//16
	nk_assign_stmt,
	nk_assign_term,
	nk_repeat_stmt,
	nk_while_stmt, // 20
	nk_for_stmt,
	nk_touch_stmt,
	nk_if_stmt,
	nk_read,
	nk_write,
	nk_ret_stmt,
	nk_function_tail,
	nk_function_call,
	nk_expr,
	nk_bit_expr, // 30
	nk_bit_term,
	nk_bit_factor,
	nk_bit_end,
	nk_relational_expr,
	nk_arithmetic_expr,
	nk_arithmetic_term,
	nk_arithmetic_factor, 
	nk_logical_expr,
	nk_logical_term,
	nk_logical_factor, //40
	nk_logical_end,
	nk_EQUAL,
	nk_GREATER, 
	nk_LESS, 
	nk_GREATOR_EQUAL,
	nk_LESS_EQUAL, 
	nk_NOT_EQUAL, 
	nk_BIT_NOT, 
	nk_BIT_AND, 
	nk_BIT_OR, // 50
	nk_BIT_NAND, 
	nk_BIT_NOR,
	nk_BIT_XOR, 
	nk_BIT_BIC,
	nk_OP_AND, 
	nk_OP_OR, 
	nk_OP_NOT,
	nk_ADD, nk_SUB, nk_MUL, // 60
	nk_DIV,
	nk_MOD,
	nk_ASSIGN, // 63
	nk_ADD_ASSIGN,
	nk_INC,
	nk_TOUCH_VAL
} nodeKind;

typedef struct _SymbolTable {
	char idName[20];
	unsigned type;
	int value;
	int lineno;
	int inItFlag;
	
	int *pIval;
	char *pCval;
	int size;
	int hashNum;
	int address;
} symtab;

typedef struct _node {
    nodeKind kind;
    // Each node can have 10 children at most 
    struct _node *childPointer[10];
    struct _idListNode *idListPointer;
    unsigned numOfChild;
    int ival;
    char cval;
    char IDName[20];
} node;
typedef struct _idDec {
	unsigned typeKind;
	char name[10][20];
	unsigned idNum;
	int nums[100]; // intset
} idDecNode;
typedef struct _idDecTail {
	int nums[100];
	int size;
} idDecTail;

typedef struct _idListNode {
	// At most 10 variables and 20 characters at once.
	char name[10][20]; 
	unsigned idNum;
} idListNode;
typedef struct _numListNode {
	int nums[100]; // At most 100 elements at once.
	unsigned size;
} numListNode;


void typeToString(char str[10], const unsigned eType);

symtab symt[HASHSIZE];

void printHead();
void printTree(node* root);
void printChildNodes(node *curr);

void KindToString(int kind, char buf[10]);
void printSymt();
int hash(char * s);
int LookUpSymbol(char *Symbol);
symtab* ReadSymbol(char *Symbol);
int InsertSymbol(char *Symbol, int lineno, int typeKind, int InitFlag, int *pIval, char *cVal, int size);
int testInsertSymbol(char *Symbol, int lineno, int typeKind, int InitFlag, int *pIval, char *cval, int size);

void codeGen(node *root);
void codeGenAssignStmt(node *root);
void codeGenReadStmt(node *root);
void codeGenWriteStmt(node *root);
void codeGenRelationStmt(node *root);
void codeGenForStmt(node *root);
