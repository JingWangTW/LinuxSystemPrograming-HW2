%{
#include <stdio.h>
#include "command.h"
#define YYSTYPE char*
extern int yylex();
void  yyerror(char *);
%}


%token INPUT_SIGNAL OUTPUT_SIGNAL
%token BACKEND 
%token PIPE
%token EOL
%token ARG_WORD

%%

command_line
    :
    |   command_strings backend EOL {printf("command line \n");}
    ;
    
backend
    :
    |   BACKEND {printf("backend \n");}
    ;

command_strings
    :   command_strings PIPE ARG_WORD arg_list_no_input { printf("1 \n"); }
    |   ARG_WORD arg_list { printf("2 \n"); }
    ;
/*
command_strings_no_output
    :   command_strings ARG_WORD arg_list_no_output{ printf("3-3 \n"); }
    |   ARG_WORD arg_list_no_output{ printf("3-4 \n"); }
    ;
*/


arg_list
    :
    |   arg_list arg {printf("4 \n");}
    ;    
    
arg_list_no_input
    :
    | arg_list_no_input arg_no_input{ printf("5 \n"); }
    ;

/*
arg_list_no_output
    : 
    | arg_list_no_output arg_no_output{ printf("6 \n"); }
    ;
*/
  
arg
    :   ARG_WORD {printf("7 \n");}
    |   INPUT_SIGNAL ARG_WORD{ printf("8 \n"); }
    |   OUTPUT_SIGNAL ARG_WORD{ printf("9 \n"); }
    ;

arg_no_input
    :   ARG_WORD {printf("10 \n");}
    |   OUTPUT_SIGNAL ARG_WORD{ printf("11 \n"); }
    ;
/*
arg_no_output
    : ARG_WORD{ printf("12 \n"); }
    | INPUT_SIGNAL ARG_WORD{ printf("13 \n"); }
*/
    
%%
    
int main(int argc,char **argv){
	yyparse();
}

void yyerror(char *s)
{
 fprintf(stderr,"error:%s\n",s);
}
