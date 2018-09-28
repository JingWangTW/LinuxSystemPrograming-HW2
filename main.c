#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pwd.h>
#include <readline/readline.h>
#include <readline/history.h>

#include "parse/command.h"
#include "parse/parse.tab.h"

typedef struct yy_buffer_state * YY_BUFFER_STATE;
extern int parse();
extern YY_BUFFER_STATE yy_scan_string(char *);
extern YY_BUFFER_STATE yy_scan_buffer(char *, size_t);
extern void yy_delete_buffer(YY_BUFFER_STATE);

extern struct command_list * commands;
extern struct command * command;

void initShell();
void sig_fork(int);
void doShell();
char * getInput();
char * getPrefix();
void execute_cd(char *);
void child_signal(int);

int main ()
{
    initShell();
    
    while (1)
    {
        doShell();
    }
    
    return 0;
}

void initShell() 
{
    signal(SIGHUP, SIG_IGN);
    signal(SIGINT, SIG_IGN);
    signal(SIGQUIT, SIG_IGN);
    signal(SIGTSTP, SIG_IGN);
    signal(SIGSTOP, SIG_IGN);
    signal(SIGCHLD, child_signal);
    
    commands = NULL;
    command = NULL;
}

void child_signal(int signo)
{
    int stat;
    
    waitpid(0, &stat, WNOHANG);
}

void doShell()
{
    char * input;
    int parseResult;
    
    input = getInput();
    
    if(strcmp(input, "") == 0)
        return;
    
    YY_BUFFER_STATE buffer = yy_scan_string(input);
    
    parseResult = parse();
    
    yy_delete_buffer(buffer);
    
    if (parseResult)
    {
        printf("%s: syntax error!\n", input);
    }
    else
    {
        execute_command_list(commands);
    }
    
    free_command_list (commands);
    commands = NULL;
    command = NULL;
}

char * getInput()
{
    char * prefix = getPrefix();
    
    static char * command = NULL;
    
    command = readline(prefix);
    
    if (command && *command)
    {
        add_history(command);
    }
    
    return command;
    
    free(prefix);
        
    /*
    char * command = (char *) malloc (sizeof(char) * sysconf(_SC_ARG_MAX));
    
    fgets(command, sysconf(_SC_ARG_MAX), stdin);
    
    command[strlen(command)-1] = '\0';
    
    return command;
    
    */
}

char * getPrefix()
{
    char * hostName = (char *) malloc (sizeof(char) * sysconf(_SC_HOST_NAME_MAX));
    char currentPath[1000];
    char * homeDirectory;
    char * userName;
    char * prefix;
    
    gethostname(hostName, sizeof(char) * sysconf(_SC_HOST_NAME_MAX));
    getcwd(currentPath, sizeof(currentPath));
    homeDirectory = getpwuid(getuid())->pw_dir;
    userName = getenv("USER");
    
    prefix = (char *) malloc (sizeof(char) * (strlen(userName) + strlen(hostName) + strlen(currentPath) + 100 ));
    
    //under the home directory
    if (strncmp(currentPath, homeDirectory, strlen(homeDirectory)) == 0)
    {
        sprintf(prefix, "[%s@%s ~%s]: ", userName, hostName, currentPath + strlen(homeDirectory));
    }
    else
    {
        sprintf(prefix, "[%s@%s %s]: ", userName, hostName, currentPath);
    }
    
    free(hostName);
    
    return prefix;
}