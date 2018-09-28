%{

#include <stdio.h>
#include <string.h>
#include "command.h"

#define YYSTYPE char*

extern int yylex();
void  yyerror(char *);

struct command_list * commands;
struct command * command;

%}


%token INPUT_SIGNAL OUTPUT_SIGNAL
%token BACKEND 
%token PIPE
%token EOL
%token ARG_WORD
%token CH_DIR

%%

command_line
    :
    |   commands background {printf("1\n");}
    |   CH_DIR 
    ;

background
    :
    |   BACKEND {
                    commands -> backend = 1;    {printf("2\n");}
                }
    ;
    
commands
    :   commands PIPE single_command{printf("3\n");}
    |   single_command{printf("4\n");}
    ;

single_command
    :   ARG_WORD arg_list   {printf("5\n");
                                command -> command_str = strdup($1);
                                append_command(commands, command);
                                command = new_command();
                            }
    ;

arg_list
    :   
    |   arg_list arg{printf("6\n");}
    ;

arg
    :   ARG_WORD    {
                        append_arg(command, $1);{printf("7\n");}
                    }
    |   io_string
    ;

io_string
    :   INPUT_SIGNAL ARG_WORD   {
                                    command -> input = strdup($2);printf("8\n");
                                }
    |   OUTPUT_SIGNAL ARG_WORD  {
                                    command -> output = strdup($2);printf("9\n");
                                }
    ;
    
%%

int main(int argc,char **argv){

    commands = new_command_list();
    command = new_command();
    
	yyparse();
}

void yyerror(char *s)
{
 fprintf(stderr,"error:%s\n",s);
}
