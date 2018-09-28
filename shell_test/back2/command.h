
struct arg
{
    char * arg;
    struct arg * next;
};

struct command 
{
    char * command;
    struct command * next;
    
    struct arg * arg_list;
    char * output;
    char * input;
};

struct command_list
{
    struct command * next;
    int backend;
};


