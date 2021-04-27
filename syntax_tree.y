%{
#include <stdio.h>
#include<stdbool.h>
#include<string.h>
//#include"ast.h"
#include"print_tree.c"
//#include"temp_print.c"


int yylex(void);
void yyerror (char const *);

char errMess[50] = "Error";
extern char* yytext;
extern int yylineno;
//extern int yyscope;
//int xpos =-1;
//int idx =-1; // A global variable to hold the number of entries in the symbol table



node* createnode(node*, node*, char*);


%}

%union
{
    	int number;
    	char *string;
    	char character;
		float decimal;
		struct node* node;

}


%token <number> T_NUM  
%token <decimal>  T_DECIMAL
%token <string> T_IDENTIFIER
%token <character> T_CHARACTER 
%token <string> T_STRING_LITERAL


%type<node> S compilation_unit extras package_statement package import_statement modifier class_stmt class_name methods other_method
%type<node> main_method stmnt s1 variable_declaration array array_declaration array_memalloc dtypes
%type<node> dec_int dec_float dec_char dec_string
%type<node> expression int_e rel_e float_e char_e str_e
%type<node> if_construct if_construct2 else
%type<node> for_construct for_args for_conds for_init for_cond for_op

%type<node> num decimal identifier character string_literal

%token<node> T_INC_OP T_DEC_OP T_LE T_GE T_EQ T_NE_OP T_DEQ
%token<node> T_AND_OP T_OR_OP T_MUL_ASSIGN T_DIV_ASSIGN T_MOD T_ADD_ASSIGN T_SUB_ASSIGN
%token<node> T_TYPEDEF T_STATIC
%token<node> T_CHAR T_INT T_FLOAT T_CONST T_VOID 
%token<node> T_IF T_ELSE T_FOR T_GOTO T_CONTINUE T_BREAK T_RETURN T_NEW
%token<node> T_TRUE T_FALSE T_BOOL
%token<node> T_IMPORT T_CLASS T_PACKAGE T_MAIN T_STRING T_ARGS T_PUBLIC T_PRIVATE T_PROTECTED T_SOP
%token<node> T_OC T_CC T_OF T_CF T_OS T_CS
%token<node> T_ADD T_SUB T_MUL T_DIV T_LT T_GT T_COMMA T_COL T_DOT
%token<node> T_BIT_AND T_NOT T_EXP T_BIT_OR T_QUE T_SEMC

m
%nonassoc T_EQ
%left T_ADD T_SUB
%left T_MUL T_DIV
%right T_LT T_GT T_LE T_GE T_DEQ

%%
S:  compilation_unit  {$$=createnode($1,NULL,"S"); print_ascii_tree($1);}		//print_t($1)
  ;

//to solve type clash
num: T_NUM					{$$=createnode(NULL,NULL,yytext);}
	;
decimal: T_DECIMAL			{$$=createnode(NULL,NULL,yytext);}
	;
identifier: T_IDENTIFIER	{$$=createnode(NULL,NULL,yytext);}
	;
character: T_CHARACTER		{$$=createnode(NULL,NULL,yytext);}
	;
string_literal: T_STRING_LITERAL {$$=createnode(NULL,NULL,yytext);}
	;


compilation_unit: extras class_stmt		{$$=createnode($1,$2,"compilation_unit");}
             	;

extras: package_statement import_statement		{$$=createnode($1,$2,"extras");}
	;
             	
package_statement: T_PACKAGE package T_SEMC package_statement 	{$$=createnode($2,$4,"package_statement");}
				|	{$$=NULL;}
             	;

package: identifier 					{$$=createnode($1,NULL,"package");} // printf("%s \n",$1->name);}
		| package T_DOT identifier		{$$=createnode($1,$3,".");}
		| package T_MUL					{$$=createnode($1,$2,"*");}
		;

import_statement: T_IMPORT class_name  T_DOT T_MUL T_SEMC	{$$=createnode($2,NULL,"import_statement");}
		   		  | T_IMPORT class_name T_SEMC				{$$=createnode($2,NULL,"import_statement");}
				  | T_IMPORT T_MUL T_SEMC					{$$=createnode($2,NULL,"import_statement");}
				  |		{$$=NULL;}
		   		  ;
		   		  
modifier: T_PUBLIC		{$$=createnode(NULL,NULL,"public");}
		| T_PRIVATE		{$$=createnode(NULL,NULL,"private");}
		| T_PROTECTED	{$$=createnode(NULL,NULL,"protected");}
		;
		
class_stmt: modifier T_CLASS class_name stmnt T_OF methods T_CF {$$=createnode($4,$6,"class_stmnt");}
      	;
      	
class_name: identifier	{$$=createnode($1,NULL,"class_name");}
    	;

methods: other_method main_method	{$$=createnode($1,$2,"methods");}
		;

other_method: other_method T_STATIC T_VOID identifier T_OC T_CC T_OF stmnt T_CF	{$$=createnode($4,$8,"other_method");}
			| other_method modifier T_VOID identifier T_OC T_CC T_OF stmnt T_CF	{$$=createnode($4,$8,"other_method");}
			| 	{$$=NULL;}
        	;

main_method: T_PUBLIC T_STATIC T_VOID T_MAIN T_OC T_STRING T_OS T_CS T_ARGS T_CC T_OF stmnt T_CF	
				{$$=createnode($12,NULL,"main_method");}
        	;

stmnt: stmnt s1	{$$=createnode($1,$2,"stmnt");}
  | 	{$$=NULL;}
  ;

s1: variable_declaration T_SEMC					{$$=createnode($1,NULL,"s1");}
	| array										{$$=createnode($1,NULL,"s1");}
	| expression T_SEMC   	 					{$$=createnode($1,NULL,"s1");}
	| if_construct								{$$=createnode($1,NULL,"s1");}
	| for_construct								{$$=createnode($1,NULL,"s1");}
	| T_SOP T_OC string_literal T_CC T_SEMC		{$$=createnode(createnode(NULL,$3,"print"),NULL,"s1");}
	| T_SEMC									{$$=createnode(NULL,NULL,"s1: ';'");}
	;

variable_declaration: dtypes	{$$=createnode($1,NULL,"variable_declaration");}
                	;
                	
array: array_declaration	{$$=createnode($1,NULL,"array");}
		| array_memalloc	{$$=createnode($1,NULL,"array");}
		;
		
array_declaration: T_INT identifier T_OS T_CS T_SEMC	{$$=createnode($2,NULL,"array_declaration");}
		| T_INT T_OS T_CS identifier T_EQ T_NEW T_INT T_OS num T_CS T_SEMC 	{$$=createnode($4,NULL,"array_declaration");}
		;

array_memalloc : identifier T_EQ T_NEW T_INT T_OS num T_CS T_SEMC {$$=createnode($1,$6,"array_memalloc");}
				;

dtypes: T_INT dec_int				{$$=createnode(createnode(NULL,NULL,"int"),$2,"dtypes");}
    	| T_FLOAT dec_float			{$$=createnode(createnode(NULL,NULL,"float"),$2,"dtypes");}
    	| T_CHAR dec_char			{$$=createnode(createnode(NULL,NULL,"char"),$2,"dtypes");}
    	| T_STRING  dec_string		{$$=createnode(createnode(NULL,NULL,"string"),$2,"dtypes");}
    	;

//int
dec_int: identifier T_EQ int_e			{$$=createnode($1,$3,"=");}

   		| dec_int T_COMMA identifier    {$$=createnode($1,$3,",");}
   					
   		| identifier    	 			{$$=createnode($1,NULL,"dec_int");}
   		;

//float
dec_float: 	identifier T_EQ float_e		{$$=createnode($1,$3,"=");}
   		
   		| dec_float T_COMMA identifier	{$$=createnode($1,$3,",");}
   		
   		| identifier   		 			{$$=createnode($1,NULL,"dec_float");}
   		;

//char 					
dec_char: identifier T_EQ char_e		{$$=createnode($1,$3,"=");}
   					
   		| dec_char T_COMMA identifier	{$$=createnode($1,$3,",");}    	
   		
   		| identifier   		 			{$$=createnode($1,NULL,"dec_char");}
   		;
   
//String  					
dec_string: identifier T_EQ str_e		{$$=createnode($1,$3,"=");}
   					
   		| dec_string T_COMMA identifier	{$$=createnode($1,$3,",");}	
   					
   		| identifier   		 			{$$=createnode($1,NULL,"dec_string");}
   		;

expression: int_e						{$$=createnode($1,NULL,"expression");}
         | rel_e						{$$=createnode($1,NULL,"expression");}
         //| float_e
      	;

rel_e: int_e T_LT int_e   	 			{$$=createnode($1,$3,"<");}
      	| int_e T_GT int_e 	 			{$$=createnode($1,$3,">");}
      	| int_e T_LE int_e 	 			{$$=createnode($1,$3,"<=");}
      	| int_e T_GE int_e 	 			{$$=createnode($1,$3,">=");}
      	| int_e T_DEQ int_e     		{$$=createnode($1,$3,"==");}
      	| int_e T_NE_OP int_e     		{$$=createnode($1,$3,"!=");}
      	| T_TRUE 						{$$=createnode(NULL,NULL,"true");}
      	| T_FALSE 						{$$=createnode(NULL,NULL,"false");}
      	;
      	

int_e: int_e T_MUL int_e   	 			{$$=createnode($1,$3,"*");}
     | int_e T_DIV int_e    			{$$=createnode($1,$3,"/");}
     | int_e T_ADD int_e    			{$$=createnode($1,$3,"+");}
     | int_e T_SUB int_e    			{$$=createnode($1,$3,"-");}
     | identifier   					{$$=createnode($1,NULL,"int_e");}
     | num   			 				{$$=createnode($1,NULL,"int_e");}
     | identifier T_INC_OP   	 		{$$=createnode($1,createnode(NULL,NULL,"++"),"int_e");}
     | identifier T_DEC_OP   	 		{$$=createnode($1,createnode(NULL,NULL,"--"),"int_e");}
     | T_INC_OP identifier    	 		{$$=createnode(createnode(NULL,NULL,"++"),$2,"int_e");}
     | T_DEC_OP identifier				{$$=createnode(createnode(NULL,NULL,"--"),$2,"int_e");}
     | identifier T_EQ int_e    		{$$=createnode($1,$3,"=");}
     | T_OC int_e T_CC					{$$=$2;}
	 ;


float_e: identifier   					{$$=createnode($1,NULL,"float_e");}
	 | decimal   						{$$=createnode($1,NULL,"float_e");}
	 | identifier T_EQ float_e   		{$$=createnode($1,$3,"=");}
	 ;

char_e: identifier   					{$$=createnode($1,NULL,"char_e");}
	 | character  						{$$=createnode($1,NULL,"char_e");}
	 | identifier T_EQ char_e  			{$$=createnode($1,$3,"=");}
	 ;
					
str_e: identifier  						{$$=createnode($1,NULL,"str_e");}
	 | string_literal					{$$=createnode($1,NULL,"str_e");}
	 | identifier T_EQ str_e  			{$$=createnode($1,$3,"=");}
	 ;

if_construct: 	if_construct2	{$$=createnode($1,NULL,"if_construct");}		 
	   	| if_construct2 else	{$$=createnode($1,$2,"if_construct");}
		;

if_construct2:	T_IF T_OC expression T_CC T_OF stmnt T_CF	{$$=createnode($3,$6,"if_construct2");}	
		;

		
else: T_ELSE T_OF stmnt T_CF	{$$=createnode($3,NULL,"else");}
		| T_ELSE if_construct	{$$=createnode(NULL,$2,"else");}
		;

for_construct: T_FOR T_OC for_args T_CC T_OF stmnt T_CF		{$$=createnode($3,$6,"for_construct");}
    	;

for_args: for_conds T_SEMC for_op	{$$=createnode($1,$3,"for_args");}
   	;

for_conds: for_init T_SEMC for_cond	{$$=createnode($1,$3,"for_conds");}
	;

for_init: T_INT dec_int		{$$=createnode(createnode(NULL,NULL,"int"),$2,"for_init");}
	| dec_int				{$$=createnode($1,NULL,"for_init");}
	| 	{$$=NULL;}
	;

for_cond: rel_e				{$$=createnode($1,NULL,"for_cond");}
	| 	{$$=NULL;}
	;
	
for_op: int_e				{$$=createnode($1,NULL,"for_op");}
	| 	{$$=NULL;}
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

node* createnode(node* left, node* right, char* name){
	node* new=(node*)malloc(sizeof(struct node));
	new->name=(char*)malloc(sizeof(char)*strlen(name));
	
	new->left=left;
	new->right=right;
	//new->name=name;
	strcpy(new->name,name);
	
	return new;
}


//==================== Print tree ====================














	 
