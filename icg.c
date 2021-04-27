#include <stdio.h>
#include <stdlib.h>
#include<string.h>
#include <ctype.h>

void push(); 
void pushId(char *name);
void codegen();
void codegen_assign();
void print_INT_CODE();
void if_label1();
void if_label2();
void if_label3();
void for_label1();
void for_label2();
void for_label3();
void for_label4();
extern char* yytext;

int count=0;
int top=0;
int i=0;
char tmp[12]="t";
char stack[100][10];
int label[200];
int lnum=0;
int ltop=0;
char s[12];
void push(); 
void pushId(char *name);
void codegen();
void codegen_assign();
void print_INT_CODE();
void if_label1();
void if_label2();
void if_label3();
void for_label1();
void for_label2();
void for_label3();
void for_label4();

struct intcode
{
	char op[10];
	char arg1[10];
	char arg2[10];
	char result[10];
};
struct intcode quadruple[100];
int inx = 0;

void push()
{
  	strcpy(stack[++top],yytext);
}

void pushId(char *name) {
	strcpy(stack[++top],name);
}

void codegen() {
 	snprintf(tmp, 12, "t%d",i);
  	strcpy(quadruple[inx].result , tmp);
	strcpy(quadruple[inx].op , stack[top-1]);
	strcpy(quadruple[inx].arg1, stack[top-2]);
	strcpy(quadruple[inx].arg2 , stack[top]);
	inx++;
  	printf("%s = %s %s %s\n",tmp,stack[top-2],stack[top-1],stack[top]);
  	top-=2;
 	strcpy(stack[top],tmp);
 	i++;
}


void codegen_assign() {
 	strcpy(quadruple[inx].result , stack[top-2]);
	strcpy(quadruple[inx].op , "=");
	strcpy(quadruple[inx].arg1, stack[top]);
	strcpy(quadruple[inx].arg2 , "");
	inx++;
 	printf("%s = %s\n",stack[top-2],stack[top]);
 	top-=2;
}
 
void if_label1() {
 	lnum++; 
 	snprintf(s, 12, "L%d", lnum);
 	snprintf(tmp, 12, "t%d", i); 
	strcpy(quadruple[inx].result , s);
	strcpy(quadruple[inx].op , "iffalse");
	strcpy(quadruple[inx].arg1, stack[top]);
	strcpy(quadruple[inx].arg2 , "");
	inx++; 
 	printf("if(not %s) ",stack[top]);
 	printf("goto L%d\n",lnum);
 	label[++ltop]=lnum;
}

void if_label2() {
	int x;
	char s1[12]; 
	lnum++;
	x=label[ltop--]; 
	snprintf(s, 12, "L%d", lnum);
	strcpy(quadruple[inx].result , s);
	strcpy(quadruple[inx].op , "goto");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , "");
	inx++; 
	snprintf(s1, 12, "L%d", x);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("goto L%d\n",lnum); 	
	printf("\nL%d: \n",x);
	label[++ltop]=lnum;
}

void if_label3() {
	int y;
	char s1[12];
	y=label[ltop--]; 
	snprintf(s1, 12, "L%d", y);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("\nL%d: \n",y);
	top--;
}

void for_label1() {
	char s1[12];
	lnum++; 
	label[++ltop]=lnum;
	
	snprintf(s1, 12, "L%d", lnum);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("\nL%d: \n",lnum);
	
	label[++ltop]=++lnum;
	label[++ltop]=++lnum;
	label[++ltop]=++lnum;
}

void for_label2() {
	char s1[12];
	
	snprintf(s1, 12, "L%d", label[ltop-2]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "if");
	strcpy(quadruple[inx].arg1, stack[top]);
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("if %s goto L%d\n",stack[top], label[ltop-2]); 
	
	snprintf(s1, 12, "L%d", label[ltop]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "goto");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("goto L%d\n",label[ltop]); 
	
	snprintf(s1, 12, "L%d", label[ltop-1]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("\nL%d: \n",label[ltop-1]);
}

void for_label3() { 
	char s1[12];
	
	snprintf(s1, 12, "L%d", label[ltop-1]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "goto");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("goto L%d\n",label[ltop-1]);
	
	snprintf(s1, 12, "L%d", label[ltop]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("\nL%d: \n",label[ltop]);
	ltop = ltop-4;
}

void for_label4() { 
	char s1[12];
	
	snprintf(s1, 12, "L%d", label[ltop-3]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "goto");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("goto L%d\n",label[ltop-3]);
	
	snprintf(s1, 12, "L%d", label[ltop-2]);
	strcpy(quadruple[inx].result , s1);
	strcpy(quadruple[inx].op , "label");
	strcpy(quadruple[inx].arg1, "");
	strcpy(quadruple[inx].arg2 , ""); 
	inx++;
	printf("\nL%d: \n",label[ltop-2]); 
}

void print_INT_CODE() {
	int i;
	printf("the value of inx %d\n",inx);
	printf("\n--------------------------------------------------------\n");
	printf("\nINTERMEDIATE CODE\n\n");
	printf("--------------------------------------------------------\n");
	printf("--------------------------------------------------------\n");
	printf("\n%15s%10s%10s%10s%10s","#","op","arg1","arg2","result\n");
	printf("--------------------------------------------------------\n");
	
	for(i=0;i<inx;i++)
	{
		printf("\n%15d%10s%10s%10s%10s", i,quadruple[i].op, quadruple[i].arg1,quadruple[i].arg2,quadruple[i].result);
	}
	printf("\n\t\t -----------------------");
	printf("\n");
}


