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
    |   commands background
    ;

background
    :
    |   BACKEND {
                    commands -> backend = 1;
                }
    ;
    
commands
    :   commands PIPE single_command
    |   single_command
    ;

single_command
    :   ARG_WORD arg_list   {
                                command -> command_str = strdup($1);
                                append_command(commands, command);
                                command = new_command();
                            }
    ;

arg_list
    :   
    |   arg_list arg
    ;

arg
    :   ARG_WORD    {
                        append_arg(command, $1);
                    }
    |   io_string
    ;

io_string
    :   INPUT_SIGNAL ARG_WORD   {
                                    command -> input = strdup($2);
                                }
    |   OUTPUT_SIGNAL ARG_WORD  {
                                    command -> output = strdup($2);
                                }
    ;
    
%%

int parse()
{
    if (commands != NULL)
    {
        free_command_list(commands);
        commands = NULL;
    }
    
    if (command != NULL)
    {
        free_a_command(command);
        command = NULL;
    }
        
    commands = new_command_list();
    command = new_command();
    
	yyparse();
}

void yyerror(char *s)
{
 //fprintf(stderr,"error:%s\n",s);
}
