flex tsl.l
bison -dy tsl.y
gcc -o tsl lex.yy.c y.tab.c tslAST.c -lfl -ly
./tsl < sam1.c
