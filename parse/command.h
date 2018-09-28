
#ifndef COMMAND_H
#define COMMAND_H

struct argument
{
    char * arg;
    struct argument * next;
};

struct command 
{
    char * command_str;
    struct command * next;
    
    struct argument * arg_list;
    char * output;
    char * input;
};

struct command_list
{
    struct command * command;
    int backend;
};

struct command_list * new_command_list();

struct command * new_command();

void free_command_list(struct command_list *);

void free_commands(struct command *);

void free_a_command(struct command *);

void free_arguments(struct argument *);

void append_command(struct command_list * commandList, struct command * command);

void append_arg(struct command * command, char * arguments);

void execute_command_list(struct command_list *);

void execute_command(struct command *);

#endif