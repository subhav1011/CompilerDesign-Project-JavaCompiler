A compiler created for JAVA, to handle errors and some basic JAVA constructs.

Follow the instructions below to run the code on a Linux OS:-

A. To Generate the errors in the code using a testcase file:
1. lex lexfile.l && bison -d parsefile.y
2. gcc lex.yy.c parsefile.tab.c -ll -w
3. ./a.out < test.java

B. To Generate the syntax tree:
1. lex lexfile.l && bison -d syntax_tree.y
2. gcc lex.yy.c syntax_tree.y -ll -w
3. ./a.out < test.java

C. To Generate ICG and test optimisations:
1. lex lexfile.l && bison -d icg.y
2. gcc lex.yy.c icg.tab.c icg.c -ll -w
3. ./a.out < test.java 
4. python3 opt.py
