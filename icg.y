%{

#include <stdio.h>
#include <stdlib.h>
#include<string.h>
//#include "intercode.h"

void yyerror (char const *);
int yylex(void);
char errMess[55] = "Error";
extern char* yytext;
extern int yylineno;

%}

%define parse.error verbose

%union
{
    int number;
    char *string;
    char character;
	float decimal;
	struct inherited* inode;
   	 
}


%token <number> T_NUM  
%token <decimal> T_DECIMAL
%token <string> T_IDENTIFIER
%token <character> T_CHARACTER 
%token <string> T_STRING_LITERAL
%token <number> T_TRUE
%token <number> T_FALSE

%type<number> int_e
%type<number> rel_e
%type<decimal> float_e
%type<character> char_e
%type<string> str_e
%type<string> dec_int dec_float dec_char dec_string


%token T_IMPORT T_CLASS T_PACKAGE T_MAIN T_ARGS T_SOP
%token T_TYPEDEF T_STATIC T_NEW
%token T_PUBLIC T_PRIVATE T_PROTECTED
%token T_OC T_CC T_OF T_CF T_OS T_CS
%token T_CHAR T_INT T_FLOAT T_VOID T_STRING 
%token T_IF T_ELSE T_FOR T_CONTINUE T_BREAK T_RETURN
%token T_EQ T_ADD_ASSIGN T_SUB_ASSIGN T_MUL_ASSIGN T_DIV_ASSIGN 
%token T_ADD T_SUB T_MUL T_DIV T_MOD 
%token T_INC_OP T_DEC_OP T_LE T_GE  T_DEQ T_LT T_GT
%token T_AND_OP T_OR_OP T_NE_OP T_BIT_AND T_BIT_OR T_NOT
%token T_COMMA T_COL T_DOT T_SEMC T_EXP T_QUE  

/*
%token T_INC_OP T_DEC_OP T_LE T_GE T_EQ T_NE_OP T_DEQ
%token T_TYPEDEF T_STATIC
%token T_CHAR T_INT T_FLOAT T_CONST T_VOID 
%token T_AND_OP T_OR_OP T_MUL_ASSIGN T_DIV_ASSIGN T_MOD T_ADD_ASSIGN T_SUB_ASSIGN
%token T_IF T_ELSE T_FOR T_GOTO T_CONTINUE T_BREAK T_RETURN T_NEW
%token T_BOOL
%token T_IMPORT T_CLASS T_PACKAGE T_MAIN T_STRING T_ARGS T_PUBLIC T_PRIVATE T_PROTECTED T_SOP
%token T_OC T_CC T_OF T_CF T_OS T_CS
%token T_ADD T_SUB T_MUL T_DIV T_LT T_GT T_COMMA T_COL T_DOT
%token T_BIT_AND T_NOT T_EXP T_BIT_OR T_QUE T_SEMC
*/

%nonassoc T_EQ
%left T_ADD T_SUB
%left T_MUL T_DIV
%right T_LT T_GT T_LE T_GE T_DEQ

%%

S: compilation_unit    {printf("\nLine No. is %d  \n ACCEPTED\n\n\n\n",yylineno);  print_INT_CODE(); }
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

import_statement: 	T_IMPORT package_name T_DOT T_MUL T_SEMC
   		 | T_IMPORT package_name T_DOT T_IDENTIFIER  T_SEMC
         | T_IMPORT T_MUL T_SEMC
         |
   		 ;

package_name:  T_IDENTIFIER
		;
		   		  
modifier: T_PUBLIC
		| T_PRIVATE
		| T_PROTECTED
		;

class_stmt: modifier T_CLASS T_IDENTIFIER stmnt T_OF methods T_CF
      	;

    	
methods: other_method main_method
		;

other_method: other_method T_STATIC T_VOID T_IDENTIFIER T_OC T_CC T_OF stmnt T_CF
			| other_method T_PUBLIC T_VOID T_IDENTIFIER T_OC T_CC T_OF stmnt T_CF
			|
        	;

main_method: T_PUBLIC T_STATIC T_VOID T_MAIN T_OC T_STRING T_OS T_CS T_ARGS T_CC T_OF stmnt T_CF
        	;

stmnt: stmnt s1
  |
  ;

s1: variable_declaration T_SEMC   
	//| array
	| expression T_SEMC   	 
	| if_construct
	| for_construct
	| T_SOP T_OC T_STRING_LITERAL T_CC T_SEMC	
	| T_SEMC
	;

variable_declaration: dtypes
                	;
/*           	
array: array_declaration
		| array_memalloc
		;
		
array_declaration: T_INT T_IDENTIFIER T_OS T_CS T_SEMC	
		| T_INT T_OS T_CS T_IDENTIFIER T_EQ T_NEW T_INT T_OS T_NUM T_CS T_SEMC 
		;

array_memalloc : T_IDENTIFIER T_EQ T_NEW T_INT T_OS T_NUM T_CS T_SEMC 
				;
*/

dtypes: T_INT dec_int
    	| T_FLOAT dec_float
    	| T_CHAR dec_char
    	| T_STRING  dec_string
    	;

//int
dec_int: T_IDENTIFIER { pushId($1);} T_EQ {push();} int_e  { codegen_assign();}  	

   		| dec_int T_COMMA T_IDENTIFIER    	
   					
   		| T_IDENTIFIER    	 		
   		;

//float
dec_float: 	T_IDENTIFIER { pushId($1);} T_EQ {push();} float_e	{ codegen_assign();} 
   		| dec_float T_COMMA T_IDENTIFIER  
   		| T_IDENTIFIER   		 		
   		;

//char 					
dec_char: T_IDENTIFIER { pushId($1);} T_EQ {push();} char_e  { codegen_assign();} 					
   		| dec_char T_COMMA T_IDENTIFIER    	   		
   		| T_IDENTIFIER   		 		
   		;
   
//String  					
dec_string: T_IDENTIFIER { pushId($1);} T_EQ {push();} str_e  { codegen_assign();} 		
   		| dec_string T_COMMA T_IDENTIFIER    
   		| T_IDENTIFIER   		 		
   		;

expression: int_e
         | rel_e
      	;

rel_e: int_e T_LT {push();} int_e   {codegen();}	 
      	| int_e T_GT {push();} int_e 	{codegen();} 
      	| int_e T_LE {push();} int_e 	{codegen();} 
      	| int_e T_GE {push();} int_e 	 {codegen();}
      	| int_e T_DEQ {push();} int_e    {codegen();} 
      	| int_e T_NE_OP {push();} int_e  {codegen();}   
      	| T_TRUE {push();}
      	| T_FALSE {push();}			
      	;
      	

int_e: int_e T_MUL {push();} int_e   	 
     | int_e T_DIV {push();} int_e    
     | int_e T_ADD {push();} int_e    
     | int_e T_SUB {push();} int_e    
     | T_IDENTIFIER   { pushId($1);}		
     | T_NUM	{push();}	 
     | T_IDENTIFIER T_INC_OP   	{push();} { pushId($1); pushId("=");} {pushId($1); pushId("+"); pushId("1"); codegen();} 				{codegen_assign();} 
     | T_IDENTIFIER T_DEC_OP	{push();} { pushId($1); pushId("=");} {pushId($1); pushId("-"); pushId("1"); codegen();} 				{codegen_assign();} 	 
     | T_INC_OP T_IDENTIFIER 	{pushId($2); pushId("=");} {pushId($2); pushId("+"); pushId("1"); codegen();}
     		{codegen_assign();}   	 
     | T_DEC_OP T_IDENTIFIER	{pushId($2); pushId("=");} {pushId($2); pushId("-"); pushId("1"); codegen();}
     		{codegen_assign();}	
     | T_IDENTIFIER {pushId($1);} T_EQ {push();} int_e  { codegen_assign();}   
     | T_OC int_e T_CC	{$$ = $2;}
	 ;


float_e: T_IDENTIFIER   { pushId($1);}	   				
	 | T_IDENTIFIER { pushId($1);} T_EQ {push();} float_e { codegen_assign();}
	 | T_DECIMAL  {push();}
	 ;

char_e: T_IDENTIFIER   { pushId($1);}	   				
	 | T_IDENTIFIER { pushId($1);} T_EQ {push();} char_e	{ codegen_assign();}
	 | T_CHARACTER    {push();}	
	 ;
					
str_e: T_IDENTIFIER   { pushId($1);}	   				
	 | T_IDENTIFIER { pushId($1);} T_EQ {push();} str_e  { codegen_assign();}
	 | T_STRING_LITERAL	{push();}
	 ;

if_construct: T_IF T_OC rel_e T_CC {if_label1();} T_OF stmnt T_CF else
		;
		
else: T_ELSE {if_label2();}  if_construct
	| T_ELSE {if_label2();}  T_OF stmnt T_CF {if_label3();}
	| {if_label3();}
	;

for_construct: T_FOR T_OC for_init T_SEMC {for_label1();} for_cond T_SEMC {for_label2();} for_cop {for_label4();} T_CC T_OF stmnt {for_label3();} T_CF 
		;


for_init: variable_declaration 
	|expression 
	| 
	;


for_cond: rel_e 
	|
	;

for_cop: int_e
	|
	;

/*
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
*/
	

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








