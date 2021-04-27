%{
#include <stdio.h>
//#include "parsefile.tab.h"
//#include "syntax_tree.tab.h"
//#include "icg.tab.h"

int yyscope=-1;
%}

%option yylineno
digit	[0-9]
letter	[a-zA-Z_]

%x COMMENTS
%%
[ \t\n]		    ;
"//".*			;
"/*"			{BEGIN(COMMENTS);}
<COMMENTS>"*/"	{BEGIN(INITIAL);}
<COMMENTS>\n	;
<COMMENTS>.		;

"break"			 	return(T_BREAK); 
"char"				return(T_CHAR);
"continue"			return(T_CONTINUE);
"else"				return(T_ELSE);
"float"				return(T_FLOAT);
"for"            	return(T_FOR);
"if"           	 	return(T_IF); 
"int"            	return(T_INT);  
"true"              return(T_TRUE);
"false"             return(T_FALSE);
"return"        	return(T_RETURN);
"static"        	return(T_STATIC);
"void"            	return(T_VOID);
"import"			return(T_IMPORT);
"class"				return(T_CLASS);
"package"			return(T_PACKAGE);
"main"				return(T_MAIN);
"String"			return(T_STRING);
"public"			return(T_PUBLIC);
"private"			return(T_PRIVATE);
"protected"			return(T_PROTECTED);
"System.out.println"	return(T_SOP);
"args"				return(T_ARGS);
"new"				return(T_NEW);

(\'{letter}\')				{yylval.character = yytext[1]; return(T_CHARACTER); }
{letter}({letter}|{digit})*	{yylval.string=strdup(yytext); if(yyleng>31){yyerror("max identifier length exceeded\n");} else{ return (T_IDENTIFIER);}}
{digit}+					{yylval.number=atoi(yytext); return T_NUM; }
({digit}*\.{digit}+)     	{yylval.decimal=atof(yytext); return (T_DECIMAL) ; }
\"([^\\\"]|\\.)*\"   		{yylval.string=strdup(yytext+1); yylval.string[yyleng-2] = 0; return(T_STRING_LITERAL); }



"+="            	return(T_ADD_ASSIGN);
"-="            	return(T_SUB_ASSIGN);
"*="           		return(T_MUL_ASSIGN); 
"/="            	return(T_DIV_ASSIGN); 
"++"            	return(T_INC_OP);
"--"               	return(T_DEC_OP); 
"&&"               	return(T_AND_OP); 
"||"            	return(T_OR_OP); 
"!="            	return(T_NE_OP); 
"("		 			return(T_OC);
")"		 			return(T_CC);
"{" 		 		{yyscope +=1; return (T_OF);}
"}" 		 		{yyscope -=1; return (T_CF);}
"[" 		 		return(T_OS);
"]"		 			return(T_CS);
"+"		 			return(T_ADD);
"*" 			 	return(T_MUL);
"/"	    	     	return(T_DIV);
"-"				 	return(T_SUB);
"<"				 	return(T_LT);
">" 			 	return(T_GT);
","         	 	return(T_COMMA);
"<="			 	return(T_LE);
">="			 	return(T_GE);
"=="			 	return(T_DEQ);
":"              	return(T_COL);
"="            		return(T_EQ); 
"."            		return(T_DOT); 
"&"            		return(T_BIT_AND); 
"!"            		return(T_NOT); 
"%"            		return(T_MOD); 
"^"            		return(T_EXP); 
"|"           		return(T_BIT_OR); 
"?"            		return(T_QUE); 
";"            		return(T_SEMC); 
.            		;
%%
