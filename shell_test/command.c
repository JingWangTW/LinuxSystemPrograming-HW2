#include <stdlib.h>
#include <string.h>
#include "command.h"

struct command_list * new_command_list()
{
    struct command_list * list = (struct command_list *) malloc (sizeof(struct command_list));
    
    list -> command = NULL;
    list -> backend = 0;
    
    return list;
}

struct command * new_command ()
{
    struct command * cmd = (struct command *) malloc (sizeof(struct command));
    
    cmd -> command_str = NULL;
    cmd -> next = NULL;
    cmd -> arg_list = NULL;
    cmd -> output = NULL;
    cmd -> input = NULL;
    
    return cmd;
}

void free_command_list (struct command_list * commandList)
{
    if (commandList != NULL)
    {
        free_commands(commandList -> command);
    
        free(commandList);
    }
}

void free_commands(struct command * cmd)
{
    struct command * temp;
    
    if (cmd != NULL)
    {
        temp = cmd -> next;
        
        while (cmd != NULL)
        {
            temp = cmd -> next;
            free_a_command(cmd);
            cmd = temp;
        }
    }
}

void free_a_command(struct command * cmd)
{
    free_arguments(cmd -> arg_list);
    
    if (cmd -> command_str != NULL)
        free(cmd -> command_str);
    
    if (cmd -> output != NULL)
        free(cmd -> output);
    
    if (cmd -> input != NULL)
        free(cmd -> input);
    
    free(cmd);
}

void free_arguments(struct argument * arg)
{
    struct argument * temp;
    
    if (arg != NULL)
    {
        temp = arg -> next;
        
        while (arg != NULL)
        {
            temp = arg -> next;
            
            free(arg -> arg);
            free(arg);
            
            arg = temp;
        }
    }
}

void append_command(struct command_list * commandList, struct command * command)
{
    if (commandList -> command != NULL)
    {
        struct command * cmd = commandList -> command;
        
        while (cmd -> next != NULL)
        {
            cmd = cmd -> next;
        }
        
        cmd -> next = command;
    }
    else
    {
        commandList -> command = command;
    }
}

void append_arg(struct command * command, char * arguments)
{
    if (command -> arg_list != NULL)
    {
        struct argument * arg = command -> arg_list;
        
        while (arg -> next != NULL)
        {
            arg = arg -> next;
        }
        
        arg -> next = (struct argument *) malloc (sizeof (struct argument));
        arg -> next -> arg = strdup(arguments);
        arg -> next -> next = NULL;
    }
    else
    {
        command -> arg_list = (struct argument *) malloc (sizeof (struct argument));
        command -> arg_list -> arg = strdup(arguments);
        command -> arg_list -> next = NULL;
    }
}