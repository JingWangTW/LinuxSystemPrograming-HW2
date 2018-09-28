#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "command.h"

#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <pwd.h>
#include <errno.h>

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

char ** create_argument_arr(char * file_name, struct argument * arg_list)
{
    int i = 0;
    int total = 0;
    struct argument * ptr = arg_list;
    char ** arg_arr;
    
    while (ptr != NULL)
    {
        total++;
        ptr = ptr -> next;
    }
    
    // add one to store null ptr
    // add one to store file name
    arg_arr = (char **) malloc (sizeof(char *) * (total + 2));

    ptr = arg_list;
    arg_arr[0] = file_name;
    
    i = 1;
    while (ptr != NULL)
    {
        arg_arr[i++] = ptr -> arg;
        ptr = ptr -> next;
    }
    arg_arr[i] = NULL;
    
    return arg_arr;
}

void execute_a_command(char * cmd, char ** arg, int input_id, int output_id)
{
    dup2(input_id, STDIN_FILENO);   //replace input descriptor
    dup2(output_id, STDOUT_FILENO); //replace output descriptor
    close(input_id);
    close(output_id);
    execvp(cmd, arg);
    printf("%s: command not found\n", cmd);
    exit(0);
}

void change_directory(char * path)
{
    if (path[0] == '~')
    {
        char * newPath;
        
        newPath = (char *) malloc (sizeof(char) * (strlen(path) + 100));
        
        strcpy(newPath, getpwuid(getuid())->pw_dir);
        strcat(newPath, path+1);
        
        if (chdir(newPath) == -1)
        {
            printf("%d: %s\n", errno, strerror(errno));
        }
    }
    else
    {
        if (chdir(path) == -1)
        {
            printf("%d: %s\n", errno, strerror(errno));
        }
    }
}

int check_special_command(struct command_list * commands)
{
    char * first_command = commands -> command -> command_str;
    
    if(strcmp(first_command, "cd") == 0)
    {
        change_directory(commands -> command -> arg_list -> arg);
        
        return 1;
    }
    else if (strcmp(first_command, "exit") == 0)
    {
        exit(0);
    }
    else
    {
        return 0;
    }
}

void execute_command_list(struct command_list * commands)
{
    pid_t process_id;
    int input_id, output_id;
    struct command * command;
    char ** argument_arr;
    const mode_t output_file_perm = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
    int last_pipe_exit = dup(STDIN_FILENO);
    
    if (!check_special_command(commands))
    {
        process_id = fork();
        
        if (process_id < 0)
        {
            printf ("fork command child process error!!!\n");
        }
        else if (process_id == 0)
        {
            int check_first = 1;
            
            command = commands -> command;
            
            while (command != NULL)
            {
                argument_arr = create_argument_arr(command -> command_str, command -> arg_list);
                
                // check if is first command, deal with input
                if (check_first)
                {               
                    if(command -> input != NULL)
                        input_id = open(command -> input, O_RDONLY);
                    else
                        input_id = dup(STDIN_FILENO);
                    
                    last_pipe_exit = dup(input_id);
                    close(input_id);
                    
                    if(input_id == -1)
                    {
                        printf ("%s: No such file or directory\n", command -> input);
                        exit(0);
                    }
                }
                // check if is last command, deal with output
                // might be the first and the last command in the same time
                if (command -> next == NULL)
                {                
                    if (command -> output != NULL)
                        output_id = open(command -> output, O_WRONLY | O_CREAT | O_TRUNC, output_file_perm);
                    else 
                        output_id = dup(STDOUT_FILENO);
                    
                    if(output_id == -1)
                    {
                        printf ("%s: Open file failed\n", command -> input);
                        exit(0);
                    }
                }
                // other command
                else
                {
                    int file_descriptor[2];
                    
                    // get file descriptor
                    pipe(file_descriptor);
                    input_id = file_descriptor[0];
                    output_id = file_descriptor[1];
                }
                
                //check if last command, fork child process
                if (command -> next != NULL)
                {
                    process_id = fork();
                    
                    if (process_id < 0)
                    {
                        printf("fork new command failed\n");
                        exit(0);
                    }
                    else if (process_id == 0)
                    {
                        execute_a_command (command -> command_str, argument_arr, last_pipe_exit, output_id);
                    }
                    else
                    {
                        free(argument_arr);
                    }
                }
                // last command, leave the process
                else
                {
                    execute_a_command (command -> command_str, argument_arr, last_pipe_exit, output_id);
                }
                
                // duplicate the file foe next command
                last_pipe_exit = dup(input_id);
                
                command = command -> next;
                check_first = 0;
                
                close(input_id);
                close(output_id);
            }
        }
        //parent process
        else
        {
            int status;

            if( !commands -> backend )
            {
                if(( process_id == waitpid(process_id, &status, 0) ) < 0)
                    printf("wait pid error\n");

            }
        }
    }
}
