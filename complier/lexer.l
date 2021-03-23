%{
#include <string>

using namespace std;

#include "common.h"
#include "parser.h"
#include "symbol.h"
#include "tree.h"

extern symbol_table symtbl;

Node dummy;//����Ľ�㣬������ֵ��yylval����Ϊlex��yacc�Ľ������Ա����ý�������

int lineno = 1;//�к�

%}

%name lexer

id 			[a-zA-Z_]+[a-zA-Z0-9_]*
num 		(-?[1-9]+[0-9]*)|(-?[1-9])|0
constchar 	'.'
newline 	\n
whitespace 	[ \t]+

%%

%{

	YYSTYPE YYFAR& yylval = *(YYSTYPE YYFAR*)yyparserptr->yylvalptr;

%}

"int"		{return INT;}
"char"		{return CHAR;}

"if"		{return IF;}
"else"		{return ELSE;}
"while"		{return WHILE;}
"for"		{return FOR;}

"input"		{return INPUT;}
"print"		{return PRINT;}

"main"		{return MAIN;}

"=="		{return EQ;}
"!="		{return NE;}
">="		{return GE;}
"<="		{return LE;}

"||"		{return OR;}
"&&"		{return AND;}
"!"			{return NOT;}
"="			{return ASSIGN;}

"++"		{return INC;}
"--"		{return DEC;}
">>"		{return SHR;}
"<<"		{return SHL;}

"+"			{return PLUS;}
"-"			{return MINUS;}
"*"			{return TIMES;}
"/"			{return OVER;}
"%"			{return REM;}
"&"			{return BAND;}
"|"			{return BOR;}
"^"			{return BXOR;}
"~"			{return BNOT;}
"<"			{return LT;}
">"			{return GT;}

";"			{return SEMICOLON;}
","			{return COMMA;}
"("			{return LPAREN;}
")"			{return RPAREN;}
"{"			{return LBRACE;}
"}"			{return RBRACE;}
"/*"		{
				char c;
				LABEL:
				do
				{
					c = input();
					if(c == '\n')
						lineno++;
				}while(c != '*');//�������ע�ͺ����'*',����⵽'*'ʱ����ѭ��

				do
				{
					c = input();
					if(c == '/')
						break;
					if(c == '\n')
						lineno++;
					if(c != '*')
						goto LABEL;
				}while(c == '*');//�������ע�ͺ����'/',��������'*'���ַ�����'/'�ǣ�����goto��䷵�ص���һ��ѭ�������¼��'*'
			}//�ٶ�"/*"�ĺ���һ�������"*/"
"//"		{
				char c;
				do
				{
					c = input();
					if(c == '\n')
						break;
				}while(c != '\n');
			}//����"//"��������е��ַ�,ֱ���������з�'\n'

{id}		{
				int p;
				p = symtbl.lookup(yytext);//�ڷ��ű��в��ҵ�ǰʶ�������id�����id�Ѿ������ڷ��ű��У��򷵻ظ�id�ڷ��ű��е�λ�ã����id���ڷ��ű��У��򷵻�-1
				if(p == -1)
				{
					p = symtbl.insert(yytext, ID);//�����id���ڷ��ű��У���p = -1���򽫸�id+"/n"���뵽���ű���(string����)
				}
				else
				{
					dummy.type = symtbl.get_type(p);//�����id�ڷ��ű��У�����ݸ�id�ڷ��ű��е�λ������ø�id������
				}
				yylval = &dummy;
				yylval->attr.symtbl_seq = p;//yylval����ڷ��ű��е�λ�þ��Ǹ�id�ڷ��ű��е�λ�ã���ʵ����Ϊ�˴��ݸ�yacc�ڴ����µĽ���ʱ��ʹ�ã��Ա㽫�����Ը�ֵ�����ڵ㣬��Ϊ�ۺ�����
				return ID;
			}
{num}		{
				yylval = &dummy;
				yylval->attr.vali = atoi(yytext);//atoi()������yytextת�����������Ӷ���num������ֵ����dummy(yylval)����vali����
				return NUM;
			}
{constchar}	{
				yylval = &dummy;
				yylval->attr.valc = yytext[0];//ȡyytext�еĵ�һ���ַ�����ֵ��yylval�е�valc����
				return CONSTCHAR;
			}
{newline}	{
				lineno++;
				#ifdef LEX_DEBUG
					cout<<"lineno:"<<lineno<<endl;
				#endif
			}
{whitespace}	{}//ֱ������
.			{
				#ifdef LEX_DEBUG
					cout<<"error!"<<endl;
				#endif
				return ERROR;
			}//��������ʶ��������ַ���֮�⣬����δ��ʶ��������ַ���ȫ����"error!"���

%%