%{
    #include "project.tab.h"
%}

%%
\?          {return sym_Q;}
    
^cd         {printf("%s: is a COMMAND(%s)\n", yytext, "CD"); return CD;}
^cls        {printf("%s: is a COMMAND(%s)\n", yytext, "CLS"); return CLS;}
^date       {printf("%s: is a COMMAND(%s)\n", yytext, "DATE"); return DATE;}
^dir        {printf("%s: is a COMMAND(%s)\n", yytext, "DIR"); return DIR;}
^echo       {printf("%s: is a COMMAND(%s)\n", yytext, "ECH"); return ECH;}
^exit       {printf("%s: is a COMMAND(%s)\n", yytext, "EXIT"); return EXIT;}
^help       {printf("%s: is a COMMAND(%s)\n", yytext, "HELP"); return HELP;}
^md         {printf("%s: is a COMMAND(%s)\n", yytext, "MD"); return MD;}
^mkdir      {printf("%s: is a COMMAND(%s)\n", yytext, "MKDIR"); return MKDIR;}
^mklink     {printf("%s: is a COMMAND(%s)\n", yytext, "MKLINK"); return MKLINK;}
^path       {printf("%s: is a COMMAND(%s)\n", yytext, "PATH"); return PATH;}
^rd         {printf("%s: is a COMMAND(%s)\n", yytext, "RD"); return RD;}
^replace    {printf("%s: is a COMMAND(%s)\n", yytext, "REPLACE"); return REPLACE;}
^rmdir      {printf("%s: is a COMMAND(%s)\n", yytext, "RMDIR"); return RMDIR;}
^time       {printf("%s: is a COMMAND(%s)\n", yytext, "TIME"); return TIME;}
^tree       {printf("%s: is a COMMAND(%s)\n", yytext, "TREE"); return TREE;}
^ver        {printf("%s: is a COMMAND(%s)\n", yytext, "VER"); return VER;}
^vol        {printf("%s: is a COMMAND(%s)\n", yytext, "VOL"); return VOL;}

[a-zA-Z]":"		{printf("%s: is a ROOT\n", yytext); return ROOT;}
"on"|"off"    	{printf("%s: is a ONOFF\n", yytext); return ONOFF;}

((\/[DHJdhj]" ")*)? {printf("%s: is a MKLINK_ARG\n", yytext); return MKLINK_ARG;}
((\/[FAfa]" ")*)? 	{printf("%s: is a TREE_ARG\n", yytext); return TREE_ARG;}
(((\/[APRWaprw]" ")*)|((\/[PRSWUprswu]" ")*))? 	{printf("%s: is a REPLACE_ARG\n", yytext); return REPLACE_ARG;}

[a-zA-Z]:\\(([^\n\\\/:*?"<>|])+(\\([^\n\\\/:*?"<>|])+)*)? {printf("%s: is an ADDR\n", yytext); return ADDR;}
\\(([^\n\\\/:*?"<>|])+(\\([^\n\\\/:*?"<>|])+)*)? {printf("%s: is a RELADDR\n", yytext); return RELADDR;}

"/"[Q|q]    {printf("%s: is an ARG_q\n", yytext); return ARG_q;}
"/"[S|s]    {printf("%s: is an ARG_s\n", yytext); return ARG_s;}
"/"[T|t]    {printf("%s: is an ARG_t\n", yytext); return ARG_t;}

\n      {return EOL;}
[ \t]   {/**/}

.       {printf("ERROR INPUT. %c\n",*yytext);}
    
%%