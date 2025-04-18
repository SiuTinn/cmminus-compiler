#include <stdio.h>
extern FILE *yyin;
extern int yylineno;
extern int yyparse(void);

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }
    yylineno = 1;
    return yyparse();
}
