

%{
#define YYSTYPE char*
#include "shell.tab.h"
#include <string.h>
%}


%%

\<      {return INPUT_SIGNAL;}
\<\<    {return INPUT_SIGNAL;}
\>      {return OUTPUT_SIGNAL;}
\>\>    {return OUTPUT_SIGNAL;}

cd      {return CH_DIR;}    

&       {return BACKEND;}

\|      {return PIPE;}

[\n]  	{return EOL;}
[ \t] 	{}

[^\n\t |&\<\>]+  {yylval=strdup(yytext);  return ARG_WORD;}

%%

int yywrap(){return 1;}