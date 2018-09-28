

%{
#define YYSTYPE char*
#include "shell.tab.h"
#include <stdio.h>
%}


%%

"\<"    {return INPUT_SIGNAL;}
"\<\<"  {return INPUT_SIGNAL;}
"\>"    {return OUTPUT_SIGNAL;}
"\>\>"  {return OUTPUT_SIGNAL;}



"&"     {return BACKEND;}

\|      {return PIPE;}

[\n]  	{return EOL;}
[ \t] 	{}

[^\n\t |&\<\>]+  {yylval=yytext;  return ARG_WORD;}

%%

int yywrap(){return 1;}