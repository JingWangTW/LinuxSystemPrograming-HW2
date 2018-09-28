%{
#include <stdio.h>
#include "command.h"
extern int yylex();

void yyerror(char *s){
  //printf("%s\n", s);
}

struct Command command;
struct SingleCmd *single_cmd;
%}

%token WORD
%token PIPE
%token GREATGREAT
%token GREAT
%token LESSLESS
%token LESS
%token AND

%%

command
    : cmd_pipe background
    |
    ;

background
    : AND { command.background = 1; }
    |
    ;

/*
io_list
    : io_list io
    |
    ;
*/
io
    : GREATGREAT WORD { single_cmd->greatgreat = strdup($2); }
    | GREAT WORD { single_cmd->great = strdup($2); }
    | LESSLESS WORD { single_cmd->lessless = strdup($2); }
    | LESS WORD { single_cmd->less = strdup($2); }
    ;

cmd_pipe
    : cmd_pipe PIPE cmd_arg_io
    | cmd_arg_io
    ;

cmd_arg_io
    : WORD arg_list {  
        single_cmd->cmd = strdup($1); 
        push_cmd(&command, single_cmd);
        single_cmd = new_SingleCmd();
      }
    ;

arg_list
    :
    | arg_list arg_io
    ;

arg_io 
    : WORD { 
        check_arg_regex(single_cmd, $1);
        printf("arg: %s\n", $1);
      }
    | io
    ;


%%

int parse(){  
  init_command(&command);
  single_cmd = new_SingleCmd();
  return yyparse();
}

/*
int main(int argc, char** argv)
{
    | lines cmd_arg  {  }
    yyparse();
    return 0;
}*/
