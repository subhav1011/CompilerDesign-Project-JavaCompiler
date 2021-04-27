%{
#include <stdio.h>
#include<stdbool.h>
#include<string.h>

void PSymTable();
int mapping(char *,int);
int yylex(void);
void yyerror (char const *);
int func(int, int, int);

char errMess[50] = "Error";
extern char* yytext;
extern int yylineno;
extern int yyscope;
int xpos =-1;
int idx =-1; // A global variabT_LE to hold the number of entries in the symbol tabT_LE
int addr=0;
//int* addr;
struct SymTable
{
    char idName[50];
    int value;
    float f_val;
    char c_val;
    char s_val[100];
    int type;  //0-int , 1-float  , 2-char, 3-String, 4-array
    int line_no;
    int scope;
    int size;
};

struct SymTable st[50];



%}

%define parse.error verbose		//automatically gives more detailed error

%union
{
    	int number;
    	char *string;
    	char character;
		float decimal;
   	 
}

%token <number> T_NUM  
%token <decimal>  T_DECIMAL
%token <string> T_IDENTIFIER
%token <character> T_CHARACTER 
%token <string> T_STRING_LITERAL
%token <number> T_TRUE
%token <number> T_FALSE

%type<number> int_e
%type<decimal> float_e
%type<character> char_e
%type<string> str_e
%type<string> dec_int
%type<string> dec_float
%type<string> dec_char
%type<string> dec_string
%type<number> rel_e


%token T_INC_OP T_DEC_OP T_LE T_GE T_EQ T_NE_OP T_DEQ
%token T_AND_OP T_OR_OP T_MUL_ASSIGN T_DIV_ASSIGN T_MOD T_ADD_ASSIGN T_SUB_ASSIGN
%token T_TYPEDEF T_STATIC
%token T_CHAR T_INT T_FLOAT T_CONST T_VOID 
%token T_IF T_ELSE T_FOR T_GOTO T_CONTINUE T_BREAK T_RETURN T_NEW
//%token T_TRUE T_FALSE T_BOOL
%token T_IMPORT T_CLASS T_PACKAGE T_MAIN T_STRING T_ARGS T_PUBLIC T_PRIVATE T_PROTECTED T_SOP
%token T_OC T_CC T_OF T_CF T_OS T_CS
%token T_ADD T_SUB T_MUL T_DIV T_LT T_GT T_COMMA T_COL T_DOT
%token T_BIT_AND T_NOT T_EXP T_BIT_OR T_QUE T_SEMC



%nonassoc T_EQ
%left T_ADD T_SUB
%left T_MUL T_DIV
%right T_LT T_GT T_LE T_GE T_DEQ

%%
S: compilation_unit    { PSymTable(); printf("\n ACCEPTED\n"); return 0; }
  ;
  
compilation_unit: package_statement import_statement class_stmt
             	;
             	
package_statement: T_PACKAGE package T_SEMC package_statement
				|	
             	;

package: T_IDENTIFIER 
		| package T_DOT T_IDENTIFIER
		| package T_MUL
		;

import_statement: T_IMPORT class_name  T_DOT T_MUL T_SEMC
		   		  | T_IMPORT class_name T_SEMC
				  | T_IMPORT T_MUL T_SEMC
				  |
		   		  ;
		   		  
modifier: T_PUBLIC
		| T_PRIVATE
		| T_PROTECTED
		;

class_stmt: modifier T_CLASS class_name stmnt T_OF methods T_CF
      	;
      	
class_name: T_IDENTIFIER
    	;

methods: other_method main_method
		;

other_method: other_method T_STATIC T_VOID T_IDENTIFIER T_OC T_CC T_OF stmnt T_CF
			| other_method modifier T_VOID T_IDENTIFIER T_OC T_CC T_OF stmnt T_CF
			|
        	;

main_method: T_PUBLIC T_STATIC T_VOID T_MAIN T_OC T_STRING T_OS T_CS T_ARGS T_CC T_OF stmnt T_CF
        	;

stmnt: stmnt s1
  |
  ;

s1: variable_declaration T_SEMC   
	| array
	| expression T_SEMC   	 
	| if_construct
	| for_construct
	| T_SOP T_OC T_STRING_LITERAL T_CC T_SEMC	{printf("%s\n",$3);}
	| T_SEMC
	;

variable_declaration: dtypes
                	;
                	
array: array_declaration
		| array_memalloc
		;
		
array_declaration: T_INT T_IDENTIFIER T_OS T_CS T_SEMC	{if(mapping($2,yyscope)==-1){idx++; strcpy(st[idx].idName,$2); 
						st[idx].type =4; 		st[idx].scope = yyscope; }else{yyerror(errMess);}}
						
		| T_INT T_OS T_CS T_IDENTIFIER T_EQ T_NEW T_INT T_OS T_NUM T_CS T_SEMC {if(mapping($4,yyscope)==-1)
			{idx++; strcpy(st[idx].idName, $4); st[idx].type =4; st[idx].scope = yyscope;  st[idx].value=addr; st[idx].size=$9;
			 addr= addr + st[idx].size*sizeof(int); } }
		;

array_memalloc : T_IDENTIFIER T_EQ T_NEW T_INT T_OS T_NUM T_CS T_SEMC {xpos = mapping($1,yyscope); 
				if(xpos!=-1 && st[xpos].type==4) { st[idx].value=addr; st[idx].size=$6; addr= addr + st[idx].size*sizeof(int);}}
				;

dtypes: T_INT dec_int
    	| T_FLOAT dec_float
    	| T_CHAR dec_char
    	| T_STRING  dec_string
    	;

//int
dec_int: T_IDENTIFIER T_EQ int_e    	{if(mapping($1,yyscope)==-1){idx++; strcpy(st[idx].idName,$1); st[idx].type =0; 						st[idx].value = $3; st[idx].scope = yyscope;  st[idx].line_no = yylineno; } else {yyerror(errMess);} }

   		| dec_int T_COMMA T_IDENTIFIER    	{if(mapping($3,yyscope)==-1) {idx++; strcpy(st[idx].idName,$3);  st[idx].type =0; 						st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   					
   		| T_IDENTIFIER    	 		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =0; 						st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		;

//float
dec_float: 	T_IDENTIFIER T_EQ float_e		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =1; st[idx].f_val = $3; 			st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		
   		| dec_float T_COMMA T_IDENTIFIER    	{if(mapping($3,yyscope)==-1) { idx++; strcpy(st[idx].idName,$3);  st[idx].type =1; 
   			st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);}}
   		
   		| T_IDENTIFIER   		 		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1);  st[idx].type =1; 
   			st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		;

//char 					
dec_char: T_IDENTIFIER T_EQ char_e		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =2; 					st[idx].c_val = $3; st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   					
   		| dec_char T_COMMA T_IDENTIFIER    	{if(mapping($3,yyscope)==-1) { idx++; strcpy(st[idx].idName,$3);  st[idx].type =2; 
   			st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		
   		| T_IDENTIFIER   		 		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1);  st[idx].type =2; 
   			st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		;
   
//String  					
dec_string: T_IDENTIFIER T_EQ str_e			{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1); st[idx].type =3; 
			strcpy(st[idx].s_val,$3); st[idx].scope = yyscope;  st[idx].size=strlen(st[idx].s_val); st[idx].line_no = yylineno;} 				else {yyerror(errMess);} }
   					
   		| dec_string T_COMMA T_IDENTIFIER    	{if(mapping($3,yyscope)==-1) { idx++; strcpy(st[idx].idName,$3);  					st[idx].type =3;  st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   					
   		| T_IDENTIFIER   		 		{if(mapping($1,yyscope)==-1) {idx++; strcpy(st[idx].idName,$1);  st[idx].type =3; 
   				st[idx].scope = yyscope;  st[idx].line_no = yylineno;} else {yyerror(errMess);} }
   		;

expression: int_e
         | rel_e
         //| float_e
      	;

rel_e: int_e T_LT int_e   	 {$$ = func($1,$3,1);}
      	| int_e T_GT int_e 	 {$$ = func($1,$3,2);}
      	| int_e T_LE int_e 	 {$$ = func($1,$3,3);}
      	| int_e T_GE int_e 	 {$$ = func($1,$3,4);}
      	| int_e T_DEQ int_e     {$$ = func($1,$3,5);}
      	| int_e T_NE_OP int_e     {$$ = func($1,$3,6);}
      	| T_TRUE		
      	;
      	

int_e: int_e T_MUL int_e   	 {$$ = $1 * $3;}
     | int_e T_DIV int_e    {$$ = $1 / $3;}
     | int_e T_ADD int_e    { $$ = $1 + $3;}
     | int_e T_SUB int_e    {$$ = $1 - $3;}
     | T_IDENTIFIER   		{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==0) { $$ = st[xpos].value; } 	
     		else {yyerror(errMess);} }
     | T_NUM   			 {$$ =  $1; }
     | T_IDENTIFIER T_INC_OP   	 {xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==0){$$=st[xpos].value++;} 
     		else {yyerror(errMess);} }
     | T_IDENTIFIER T_DEC_OP   	 {xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==0){ $$=st[xpos].value--;}
     		else {yyerror(errMess);} }
     | T_INC_OP T_IDENTIFIER    	 {xpos = mapping($2,yyscope); if(xpos!=-1 && st[xpos].type==0){ $$=++st[xpos].value;}
     		else {yyerror(errMess);} }
     | T_DEC_OP T_IDENTIFIER		{xpos = mapping($2,yyscope); if(xpos!=-1 && st[xpos].type==0){ $$=--st[xpos].value;}
     		else {yyerror(errMess);} }
     | T_IDENTIFIER T_EQ int_e    {xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==0) { st[xpos].value = $3; } 
     		else {yyerror(errMess);} }
     | T_OC int_e T_CC	{$$=$2;}
	 ;


float_e: T_IDENTIFIER   	{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==1) { $$ = st[xpos].f_val; } 
						else {yyerror(errMess);} }
	 | T_DECIMAL   				{$$ = $1; }
	 | T_IDENTIFIER T_EQ float_e   	{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==1) { st[xpos].f_val = $3; } else 						{yyerror(errMess);}}
	 ;

char_e: T_IDENTIFIER   		{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==2) { $$ = st[xpos].c_val; } 
			else {yyerror(errMess);} }
	 | T_CHARACTER  				{$$ = $1; }
	 | T_IDENTIFIER T_EQ char_e  	{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==2) { st[xpos].c_val = $3; } else {yyerror(errMess);}}
	 ;
					
str_e: T_IDENTIFIER  		{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==3) { $$ = strcpy(st[idx].s_val,$1); } 
			else {yyerror(errMess);} }
	 | T_STRING_LITERAL				{$$ = $1; }
	 | T_IDENTIFIER T_EQ str_e  	{xpos = mapping($1,yyscope); if(xpos!=-1 && st[xpos].type==3) { strcpy(st[idx].s_val,$3); 				st[idx].size=strlen(st[idx].s_val)	;  } else {yyerror(errMess);}}
	 ;

if_construct: T_IF T_OC expression T_CC T_OF stmnt T_CF   		 
	   	| T_IF T_OC expression T_CC T_OF stmnt T_CF else
		;
		
else: T_ELSE T_OF stmnt T_CF
		| T_ELSE if_construct
		;

for_construct: T_FOR T_OC for_args T_CC T_OF stmnt T_CF
    	;

for_args: for_conds T_SEMC for_op
   	;

for_conds: for_init T_SEMC for_cond
	;

for_init: T_INT dec_int
	| dec_int
	|
	;

for_cond: rel_e
	|
	;
	
for_op: int_e
	|
	;
	

%%



void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
  	printf("Error occured at  Line No.  %d\n" , yylineno);
   	printf("Error near : %s\n" , yytext);
}

int yywrap() { 
	return 1;
}

int main() {
	yyparse();
	return 1;
}

int func(int a, int b, int k ) {
	switch(k) {
		case 1: return (a<b);
     	break;

		case 2: return (a>b);
     	break;
     	 
		case 3: return (a<=b);
     	break;
     	 
		case 4: return (a>=b);
     	break;
     	 
		case 5: return (a==b);
     	break;
     	 
		case 6: return (a!=b);
     	break;
	}
}    

int mapping(char *name, int scope)
{
    int j;
    //int res[2]={-1,-1};
    
    for(j=0;j<idx+1;j++)
    {
	 
   	 if(strcmp(name, st[j].idName)==0 && scope >= st[j].scope)
   	 {    		 
   		 return j;
   	 }
    }
return -1;
}


void PSymTable() {
    int j=-1;
    printf("\nType\tName\tValue\t\tScope\tline\tSize(bytes)\n");
    for(j=0;j<=idx;j++)	{    
		if(st[j].type==0) {
			printf("int\t");
			printf("%s\t%d\t\t%d\t%d\t%d\n",st[j].idName,st[j].value, st[j].scope, st[j].line_no,sizeof(int));
		}
		else if(st[j].type==1) {
			printf("float\t");
			printf("%s\t%f\t\t%d\t%d\t%d\n",st[j].idName,st[j].f_val, st[j].scope, st[j].line_no,sizeof(float));
		}
		else if(st[j].type==2) {
			printf("char\t");
			printf("%s\t%c\t\t%d\t%d\t%d\n",st[j].idName,st[j].c_val, st[j].scope, st[j].line_no,sizeof(char));
		}
		else if(st[j].type==3) {
			printf("string\t");
			//printf("%s\t%s\t\t%d\t%d\t%d\n",st[j].idName,st[j].s_val, st[j].scope, st[j].line_no,st[j].size);
			printf("%s\t%s\t\t%d\t%d\t%d\n",st[j].idName,st[j].s_val, st[j].scope, st[j].line_no,sizeof(st[j].s_val));
		}
		else if(st[j].type==4) {
			printf("array\t");
			printf("%s\t%d\t%d\t%d\t%d\n",st[j].idName,st[j].s_val, st[j].scope, st[j].line_no,st[j].size*sizeof(int));
		}
		
    }
}

     	 
