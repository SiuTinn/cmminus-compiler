all: cc

lex.yy.c: src/lexical.l
	flex -o $@ $<

parser.tab.c parser.tab.h: src/parser.y
	bison -d -o parser.tab.c $<

cc: lex.yy.c parser.tab.c src/*.c
	gcc -g -Wall -Iinclude lex.yy.c parser.tab.c src/*.c -o cc

clean:
	rm -f cc lex.yy.c parser.tab.c parser.tab.h
