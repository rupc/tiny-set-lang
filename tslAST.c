#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tslAST.h"
int LableNum = 0;
void typeToString(char str[10], const unsigned eType) {
	switch(eType) {
		case 0:	
			strcpy(str, "INT");
			break;
		case 1:
			strcpy(str, "CHAR");
			break;
		case 2:
			strcpy(str, "BOOL");
			break;
		case 3:
			strcpy(str, "INTSET");
			break;
		case 4:
			strcpy(str, "CHARSET");
			break;
		case 5:
			strcpy(str, "BITSET");
			break;
		case 6:
			strcpy(str, "INTTUP");
			break;
		case 7:
			strcpy(str, "CHARTUP");
			break;
		default:
			strcpy(str, "NOTHING");
			break;
	}
}

int hash(char * Symbol) {
	int hash = 0;
	unsigned int p = 0xedb88320;
	int i;
	
	for(i=0; Symbol[i] != 0; i++)
	{
		p = (p <<1) | (p>>(32-1));//1비트 left shift
		hash = (int)(p*hash+Symbol[i]);
	}
	
	hash &= 0x7fffffff; //양수 보장
	return hash % HASHSIZE;
}
int LookUpSymbol(char *Symbol) {
	int hv = hash(Symbol);
	symtab* tmp = &symt[hv];

	if( tmp->idName == NULL)
		return 1;
	else
	{	
		return 0; 
	}
}
symtab* ReadSymbol(char *Symbol) {
	int hv = hash(Symbol);
	symtab * tmp = &symt[hv];

	if(tmp->idName != NULL)
		return tmp;
	else	
	{
		yyerror("variable is already declared");
		return NULL;
	}
}

void printSymt() {
	int i, j = 0;
	printf("ID\tType\tInit\tLine\tHash\tADDR\tInitval\n");
	for(i = 0 ; i < HASHSIZE; ++i) {
		if(strlen(symt[i].idName)  != 0) {
			printf("%s\t%d\t%d\t%d\t%d\t%x\t", symt[i].idName, symt[i].type, symt[i].inItFlag, symt[i].lineno, symt[i].hashNum, symt[i].address);
			
			if(symt[i].inItFlag == 1) {
				
				for(j = 0; j < symt[i].size; j++) {
					printf("%d, ", symt[i].pIval[j]);
				}
			}
			printf("\n");
		}
	}
}
/*
*/
int testInsertSymbol(char *Symbol, int lineno, int typeKind, int InitFlag, int *pIval, char *cval, int size) {
	printf("%s\t%d\t%d\t%d\n", Symbol, lineno, typeKind, InitFlag);
	if(LookUpSymbol(Symbol) == 0) {
		int hv = hash(Symbol);
		strcpy(symt[hv].idName, Symbol);
		printf("idName = %s\n", symt[hv].idName);
	}
}

int InsertSymbol(char *Symbol, int lineno, int typeKind, int InitFlag, int *pIval, char *pCval, int size) {
//	printf("Current Inserted Symbol : %s", Symbol);
	if(LookUpSymbol(Symbol) == 0) {
		int hv = hash(Symbol);
		
		strcpy(symt[hv].idName, Symbol);
		symt[hv].type = typeKind;
		symt[hv].lineno = lineno;
		symt[hv].size = size;
		symt[hv].hashNum = hv;
		symt[hv].address = (unsigned int)&symt[hv];
		if(InitFlag == 0) {
			symt[hv].inItFlag = 0;
			//printf("hash : %d\n", hv);
			return 0; // Insert Success
		} 
		switch(typeKind) {
			case eINT:
				if(size == 1) { // one value
					symt[hv].pIval = (int *)malloc(sizeof(int));
					*(symt[hv].pIval) = pIval[0];
				} else if(size > 1) { // array
					symt[hv].pIval = (int *)malloc(sizeof(int) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pIval[i] = pIval[i];
					}
				}
								
				break;
			case eCHAR:
				if(size == 1) { // one value
					symt[hv].pCval = (char *)malloc(sizeof(char));
					*(symt[hv].pCval) = pCval[0];
				} else if(size > 1) { // array
					symt[hv].pCval = (char *)malloc(sizeof(char) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pCval[i] = pCval[i];
					}
				}
				break;
			case eBOOL:
				if(size == 1) { // one value
					symt[hv].pIval = (int *)malloc(sizeof(int));
					*(symt[hv].pIval) = pIval[0];
				} else if(size > 1) { // array
					symt[hv].pIval = (int *)malloc(sizeof(int) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pIval[i] = pIval[i];
					}
				}
				break;
			case eINTSET:
				if(size == 1) { // one value
					symt[hv].pIval = (int *)malloc(sizeof(int));
					*(symt[hv].pIval) = pIval[0];
				} else if(size > 1) { // array
					symt[hv].pIval = (int *)malloc(sizeof(int) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pIval[i] = pIval[i];
					}
				}
				break;
			case eCHARSET:
				if(size == 1) { // one value
					symt[hv].pCval = (char *)malloc(sizeof(char));
					*(symt[hv].pCval) = pCval[0];
				} else if(size > 1) { // array
					symt[hv].pCval = (char *)malloc(sizeof(char) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pCval[i] = pCval[i];
					}
				}
				break;
			case eBITSET:
				if(size == 1) { // one value
					symt[hv].pIval = (int *)malloc(sizeof(int));
					*(symt[hv].pIval) = pIval[0];
				} else if(size > 1) { // array
					symt[hv].pIval = (int *)malloc(sizeof(int) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pIval[i] = pIval[i];
					}
				}
				break;
			case eINTTUP:
				if(size == 1) { // one value
					symt[hv].pIval = (int *)malloc(sizeof(int));
					*(symt[hv].pIval) = pIval[0];
				} else if(size > 1) { // array
					symt[hv].pIval = (int *)malloc(sizeof(int) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pIval[i] = pIval[i];
					}
				}
				break;
			case eCHARTUP:
				if(size == 1) { // one value
					symt[hv].pCval = (char *)malloc(sizeof(char));
					*(symt[hv].pCval) = pCval[0];
				} else if(size > 1) { // array
					symt[hv].pCval = (char *)malloc(sizeof(char) * size);
					int i;
					for(i = 0 ; i < size ; ++i) {
						symt[hv].pCval[i] = pCval[i];
					}
				}
				break;
		
		}
		symt[hv].inItFlag = 1;
		return 0;
	} else {
		return -1;
	}	
}
void printHead() {
	printf("Start_Program\n");

}

void printChildNodes(node *curr) {
	int i = 0;
	while(curr->childPointer[i] != NULL) {
		printf("%d-", curr->childPointer[i]->kind);
		++i;
	}
	printf("\nNumOfChild : %d\n", i);
}

void prunChildNodes(node *curr) {
	int i , k= 0;
	int j = 0;
	
	while(curr->childPointer[i] != NULL) {
		if(curr->childPointer[i]->kind != 0 &&
			curr->childPointer[i]->kind != 1 &&
			curr->childPointer[i]->kind != 3) {
			curr->childPointer[j] = curr->childPointer[i];
			++j;
		}
		++i;
	}
	printf("\nNumOfChild : %d\n", i);
	curr->childPointer[j] = NULL;
	
}
void KindToString(int kind, char buf[10]) {
	switch (kind){
		case nk_NUM : 
			strcpy(buf, "NUM");
			break;
		case nk_ID : 
			strcpy(buf, "ID");
			break;
		case nk_stmt_list : 
			strcpy(buf, "stmt_list");
			break;
		case nk_assign_stmt : 
			strcpy(buf, "assign_stmt");
			break;
		case nk_ASSIGN : 
			strcpy(buf, "ASSIGN");
			break;
		case nk_for_stmt : 
			strcpy(buf, "for_stmt");
			break;
		case nk_relational_expr : 
			strcpy(buf, "relational_expr");
			break;
		case nk_LESS : 
			strcpy(buf, "LESS");
			break;
		case nk_assign_term : 
			strcpy(buf, "assign_term");
			break;
		case nk_INC : 
			strcpy(buf, "INC");
			break;
		case nk_read : 
			strcpy(buf, "read");
			break;
		case nk_ADD_ASSIGN : 
			strcpy(buf, "ADD_ASSIGN");
			break;
		case nk_arithmetic_expr : 
			strcpy(buf, "arithmetic_expr");
			break;
		case nk_ADD : 
			strcpy(buf, "ADD");
			break;
		case nk_write : 
			strcpy(buf, "write");
			break;
		case nk_touch_stmt : 
			strcpy(buf, "touch_stmt");
			break;
		case nk_TOUCH_VAL : 
			strcpy(buf, "TOUCH_VAL");
			break;
	}
}

int depth = 0;
int idx = 0;
char buf[10];
int visitOrder = 1;
void printTree(node* root ) {
	int i = 0;
	while(root->childPointer[i] != NULL) {
		for(idx = 0 ; idx < depth ; ++idx) {
			printf("\t");
		}
		KindToString(root->childPointer[i]->kind, buf);
		printf("%d-%s",visitOrder++, buf);
		if(strcmp(buf, "ID") == 0) {
			printf("(%s)", root->childPointer[i]->IDName);
		} else if(strcmp(buf, "NUM") == 0) {
			printf("(%d)", root->childPointer[i]->ival);
		}
		printf("\n");
		
		++depth;
		printTree(root->childPointer[i]);
		--depth;
		++i;
	}
}

symtab *st;

void codeGenAssignStmt(node *root) {
	int right;
	int flag;
	int oper = root->childPointer[1]->kind;
	st = ReadSymbol(root->childPointer[0]->IDName);
	
	if(root->childPointer[2]->kind == nk_NUM) {
		right = root->childPointer[2]->ival;
		flag = 0;
	} else if(root->childPointer[2]->kind == nk_ID) {
		symtab *tmp = ReadSymbol(root->childPointer[2]->IDName);
		right = tmp->address + 0x24;
		flag = 1;
	}
	
	printf("\tpush eax\n");
	printf("\tpush ebx\n");
	printf("\tmov eax, %x\n", st->address + 0x24);
	printf("\tmov ebx, %d\n", right);
	if(oper == nk_ASSIGN) {
		if(flag == 0) 
			printf("\tmov [eax], ebx\n");
		else if(flag == 1) {
			printf("\tpush ecx\n");
			printf("\tmov ecx, [ebx]\n");
			printf("\tmov [eax], ecx\n");
			printf("\tpop ecx\n");
		}
	} else if(oper == nk_ADD_ASSIGN) {
		if(flag == 0) {
			printf("\tadd [eax], ebx\n");
		} else if(flag == 1) {
			printf("\tpush ecx\n");
			printf("\tmov ecx, [ebx]\n");
			printf("\tadd [eax], ecx\n");
			printf("\tpop ecx\n");
		}
		
	}
	printf("\tpop ebx\n");
	printf("\tpop eax\n");
}

void codeGenReadStmt(node *root) {
	st = ReadSymbol(root->childPointer[0]->IDName);
	
	printf("\tpush eax\n");
	printf("\tcall readint\n");
	printf("\tmov [%x], eax\n", st->address + 0x24);
	printf("\tpop eax\n");
}

void codeGenWriteStmt(node *root) {
	st = ReadSymbol(root->childPointer[0]->IDName);
	
	printf("\tpush eax\n");
	printf("\tmov eax, [%x]\n", st->address + 0x24);
	if(st->type == eINT) {
		printf("\tcall writeint\n");
	}
	else if(st->type == eCHAR) {
		printf("\tcall writechar\n");
	}
	else if(st->type == eINTSET) {
		int loopSize = st->size;
		int outputVal = st->pIval[0];
		printf("\tpush ecx\n");
		printf("\tpush ebx\n");
		printf("\tpush edx\n");
		printf("\tmov ecx, 0\n");
		printf("\tmov ebx, [%x]\n", st->address + 0x44); // size : loop count, ebx
		printf("\tmov edx, [%x]\n", st->address + 0x36); // pIval : value of array, edx
		printf("L%d : \n", LableNum);
		printf("\tmov eax, edx\n");
		printf("\tcall writeint\n");
		
		printf("\tadd edx, 4\n");
		printf("\tinc ecx\n");
		printf("\tcmp ecx, ebx\n");
		printf("\tjl L%d\n", LableNum);

		printf("\tpop edx\n");
		printf("\tpop ebx\n");
		printf("\tpop ecx\n");
		LableNum++;
	}
	
	printf("\tpop eax\n");
}
int forLabelFlag = 0;
int assignVarAddress;
void codeGenForStmt(node *root) {
	symtab *stLeft = ReadSymbol(root->childPointer[0]->childPointer[0]->IDName);
	
	int loopCount = root->childPointer[1]->childPointer[2]->ival;
	assignVarAddress = stLeft->address;
	printf("\tpush eax\n");
	printf("\tpush ebx\n");
	printf("\tpush ecx\n");
	
	printf("\tmov ecx, %d\n", loopCount);
	forLabelFlag = 1;


}
void codeGenForTail() {
	printf("\tmov eax, [%x]\n", assignVarAddress);
	printf("\tinc eax\n");
	printf("\tmov [%x], eax\n", assignVarAddress);
	printf("\tcmp eax, ecx\n");
	printf("\tjl L%d\n", LableNum);

	printf("\tpop ecx\n");
	printf("\tpop ebx\n");
	printf("\tpop eax\n");
	LableNum++;
}
int forFlag = 0;
int fordepth;
int depth2 = 0;
void codeGen(node *root) {
	int i = 0;
	while(root->childPointer[i] != NULL) {
		++depth2;
		switch(root->childPointer[i]->kind) {
			case nk_assign_stmt : 		
				codeGenAssignStmt(root->childPointer[i]);
				break;
			case nk_for_stmt : 
				fordepth = depth2;
				codeGenForStmt(root->childPointer[i]);
				forFlag = 1;
				break;
			case nk_read : 
				codeGenReadStmt(root->childPointer[i]);
				break;
			case nk_write : 
				codeGenWriteStmt(root->childPointer[i]);
				break;
		}
		codeGen(root->childPointer[i]);
		--depth2;
		if(forLabelFlag == 1) {
			printf("L%d : \n", LableNum);
			forLabelFlag = 0;
		}
		if(fordepth == depth2 + 1 && forFlag == 1) {
			forFlag = 0;
			codeGenForTail();
		}
		++i;
	}
}
