%{
    #include <stdio.h>
%}

%token CD CLS DATE DIR ECH EXIT HELP MD MKDIR MKLINK PATH RD REPLACE RMDIR TIME TREE VOL VER
%token EOL ADDR RELADDR ONOFF ROOT sym_Q
%token REPLACE_ARG TREE_ARG MKLINK_ARG

%token ARG_q ARG_s ARG_t

%%

calclist:
    | calclist cd       EOL
    | calclist cls      EOL
    | calclist date     EOL
    | calclist dir      EOL
    | calclist echo     EOL
    | calclist exit     EOL
    | calclist mkdir    EOL
    | calclist mklink   EOL
    | calclist path     EOL
    | calclist rd       EOL
    | calclist rmdir    EOL
    | calclist time     EOL
    | calclist tree     EOL
    | calclist vol      EOL

    | calclist EOL                                      {printf("\n> EOL\n");}
    | calclist HELP EOL                                 {printf("\n> HELP\n");}
    | calclist REPLACE ADDR sym_Q ADDR REPLACE_ARG EOL  {printf("\n> REPLACE ADDR sym_Q ADDR REPLACE_ARG EOL\n");}
    | calclist VER EOL                                  {printf("\n> VER\n");}
    ;

cd:
     CD                             {printf("\n> CD\n");}
    |CD ADDR                        {printf("\n> CD ADDR\n");}
    ;

cls:
     CLS                            {printf("\n> CLS\n");}
    ;                                        


date:
     DATE                           {printf("\n> DATE\n");}
    |DATE ARG_t                     {printf("\n> DATE ARG_t\n");}
    ;

dir:
     DIR                            {printf("\n> DIR\n");}
    |DIR ADDR                       {printf("\n> DIR ADDR\n");}
    ;

echo:
     ECH                            {printf("\n> ECH\n");}
    |ECH ONOFF                      {printf("\n> ECH ONOFF\n");}
    ;

exit:
     EXIT                           {printf("\n> EXIT\n");}
     ;                                        

mkdir:
     MKDIR RELADDR                  {printf("\n> MKDIR RELADDR\n");}
    |MD RELADDR                     {printf("\n> MD RELADDR\n");}
    ;

/* MKLINK_ARG ==>  ((\/[DHJdhj]" ")*)? */
mklink:
     MKLINK MKLINK_ARG ADDR         {printf("\n> MKLINK MKLINK_ARG ADDR\n");}
    |MKLINK ADDR                    {printf("\n> MKLINK ADDR \n");}
    ;

path:
     PATH                           {printf("\n> PATH\n");}
    |PATH ADDR                      {printf("\n> PATH ADDR\n");}
    ;

rd  :
     RD ADDR                        {printf("\n> RD ADDR\n");}
    |RD ARG_s sym_Q ARG_q ADDR      {printf("\n> RD ARG_s sym_Q ARG_q ADDR\n");}
    |RD ARG_q ARG_s sym_Q ADDR      {printf("\n> RD ARG_q ARG_s sym_Q ADDR\n");}
    |RD ARG_s sym_Q ADDR            {printf("\n> RD ARG_s sym_Q ADDR\n");}
    |RD ARG_q ADDR                  {printf("\n> RD ARG_q ADDR\n");}
    ;                                        

rmdir:                                             
     RMDIR ADDR                     {printf("\n> RMDIR ADDR\n");}
    |RMDIR ARG_s sym_Q ARG_q ADDR   {printf("\n> RMDIR ARG_s sym_Q ARG_q ADDR\n");}
    |RMDIR ARG_q ARG_s sym_Q ADDR   {printf("\n> RMDIR ARG_q ARG_s sym_Q ADDR\n");}
    |RMDIR ARG_s sym_Q ADDR         {printf("\n> RMDIR ARG_s sym_Q ADDR\n");}
    |RMDIR ARG_q ADDR               {printf("\n> RMDIR ARG_q ADDR\n");}
    ;

time:
     TIME                           {printf("\n> TIME\n");}
    |TIME ARG_t                     {printf("\n> TIME ARG_t\n");}
    ;

/* TREE_ARG  ==>  ((\/[FAfa]" ")*)? */
tree:   
     TREE                           {printf("\n> TREE\n");}
    |TREE ADDR sym_Q TREE_ARG       {printf("\n> TREE ADDR sym_Q TREE_ARG\n");}
    ;

vol:
    VOL                             {printf("\n> VOL\n");}
    |VOL ROOT                       {printf("\n> VOL ROOT\n");}
    ;

%%

main(int argc,char **argv){
    yyparse();
}

yyerror(char *s)
{
    fprintf(stderr,"error:%s\n",s);
}