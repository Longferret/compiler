    /* This flex/bison example is provided to you as a starting point for your
     * assignment. You are free to use its code in your project.
     *
     * This example implements a simple calculator. You can use the '-l' flag to
     * list all the tokens found in the source file, and the '-p' flag (or no flag)
     * to parse the file and to compute the result.
     *
     * Also, if you have any suggestions for improvements, please let us know.
     */

%{
    /* Includes */
    #include <string>
    #include <stack>
    #include <sstream>

    #include "parser.hpp"
    #include "driver.hpp"
%}

    /* Flex options
     * - noyywrap: yylex will not call yywrap() function
     * - nounput: do not generate yyunput() function
     * - noinput: do not generate yyinput() function
     * - batch: tell Flex that the lexer will not often be used interactively
     */
%option noyywrap nounput noinput batch
%x ncomments
%x stringg

%{
    /* Code to include at the beginning of the lexer file. */
    using namespace std;
    using namespace VSOP;

    // Create a new INTEGER token from the value s. (changed)
    Parser::symbol_type make_INTEGER(const string &s,
                                    const location &loc);
                                    
    
    Parser::symbol_type make_STRINGL(const string &s,
                                    location &loc);
                                   

    // Print an lexical error message.
    static void print_error(const position &pos,
                            const string &m);
    // Print an lexical error message with offsets
    static void print_error_off(const position &pos,
                            const string &m, int offl,int offc);

    // Code run each time a pattern is matched.
    #define YY_USER_ACTION  loc.columns(yyleng);

    // Global variable used to maintain the current location.
    location loc;
    int commentnbr;
    string str;
    location tmploc;
    stack<location> stck;
    int bsn = 0;
%}

    /* Definitions */

sstring "\""
blank [ \t\r\f]
comment "/"{2}.*
lcomment "(*"
rcomment "*)"
lowercaseletter [a-z]
uppercaseletter [A-Z]
letter {uppercaseletter}|{lowercaseletter}
bindigit [0-1]
digit [0-9]
hexdigit {digit}|[a-fA-F]
integer ({digit}+|"0x"{hexdigit}+)
typeid {uppercaseletter}({letter}|{digit}|"_")*
objectid {lowercaseletter}({letter}|{digit}|"_")*
bs "\\"
bsb "\\""b"
bst "\\""t"
bsn "\\""n"
bsr "\\""r"
bsbs "\\""\\"
bsq  "\\""\""
bshex "\\x"{hexdigit}{2}
nointeger [0-9]+[a-zA-A]+
nohex "0x"([a-zA-Z]|[0-9])+

%%
%{
    // Code run each time yylex is called.
    loc.step();
%}
    /* Rules */
   
    /* White spaces */
{blank}+    loc.step();
\n+         loc.lines(yyleng); loc.step();
    /* Comments (2.2)*/
{comment}   loc.step();
{lcomment} {
	stck.push(loc);
	BEGIN(ncomments);
}
<ncomments>{rcomment} {
	stck.pop();
	loc.step();
	if(stck.empty()){
		BEGIN(INITIAL);
	}
}
<ncomments>{lcomment} {
	stck.push(loc);
	loc.step();
}
<ncomments><<EOF>> {
	BEGIN(INITIAL);
	print_error(stck.top().begin, "comment not ended: (*");
        return Parser::make_YYerror(tmploc);
}
<ncomments>. loc.step();

<ncomments>\n loc.lines(yyleng); loc.step();

    /* Integer Literals (2.3)*/
{integer}   return make_INTEGER(yytext, loc);
{nointeger} {
	print_error(loc.begin, "wrong integer: " + string(yytext));
        return Parser::make_YYerror(tmploc);
}
{nohex} {
	print_error(loc.begin, "wrong hex: " + string(yytext));
        return Parser::make_YYerror(tmploc);
}

    /* Keywords (2.4)*/
"and"       return Parser::make_AND(loc);
"extends"   return Parser::make_EXTENDS(loc);
"isnull"    return Parser::make_ISNULL(loc);
"string"    return Parser::make_STRING(loc);
"bool"      return Parser::make_BOOL(loc);
"false"     return Parser::make_FALSE(loc);
"let"       return Parser::make_LET(loc);
"then"      return Parser::make_THEN(loc);
"class"     return Parser::make_CLASS(loc);
"if"        return Parser::make_IF(loc);
"new"       return Parser::make_NEW(loc);
"true"      return Parser::make_TRUE(loc);
"do"        return Parser::make_DO(loc);
"in"        return Parser::make_IN(loc);
"not"       return Parser::make_NOT(loc);
"unit"      return Parser::make_UNIT(loc);
"else"      return Parser::make_ELSE(loc);
"int32"     return Parser::make_INT32(loc);
"self"      return Parser::make_SELF(loc);
"while"     return Parser::make_WHILE(loc);

    /* Type Identifiers (2.5)*/
{typeid}    return Parser::make_TYPEID(yytext, loc);

    /* Object Identifiers (2.6)*/
{objectid}  return Parser::make_OBJECTID(yytext, loc);
    /* String Litterals (2.7) */

{sstring} {
	tmploc = loc;
	str.clear();
	str.append(yytext);
	loc.step();
	BEGIN(stringg);
	bsn = 0;
} 

<stringg>{bs}"\n" {
	loc.lines(1);
	loc.step();
	bsn = 1;
}

<stringg>(" "|\t)* {
	if(bsn){
		loc.step();
		bsn = 0;
	}
	else{
		str.append(yytext);
		loc.step();
	}
}
<stringg>{bsb} str.append("\\x08"); loc.step();

<stringg>{bst} str.append("\\x09"); loc.step();

<stringg>{bsn} str.append("\\x0a"); loc.step();

<stringg>{bsr} str.append("\\x0d"); loc.step();

<stringg>{bsbs} str.append("\\x5c"); loc.step();

<stringg>{bshex} str.append(yytext); loc.step();

<stringg>{bsq} str.append("\\x22"); loc.step();

<stringg>{bs} {
	print_error(loc.begin, "incorrect backslash: " + string(yytext));
        return Parser::make_YYerror(loc);
}

<stringg>{sstring} {
	BEGIN(INITIAL);
	loc.step();
	str.append(yytext);
	return Parser::make_STRINGL(str,tmploc);
}

<stringg><<EOF>> {
	BEGIN(INITIAL);
	print_error(tmploc.begin, "string not finished: " + str);
        return Parser::make_YYerror(loc);
}

<stringg>\n {
	print_error(loc.begin, "forbidden linefeed: " + string(yytext));
        return Parser::make_YYerror(loc);
}

<stringg>. {
	loc.step(); bsn = 0;
	int n = yytext[0];
	if(n>126 || n<32){
		str.append("\\x");
		stringstream ss;
		ss<< hex << n;
		string res ( ss.str() );
		str.append(res);
	}
	else{
		str.append(yytext);
	}
}


    /* Operators (2.8)*/
"{"         return Parser::make_LBRACE(loc);
"}"         return Parser::make_RBRACE(loc);
"("         return Parser::make_LPAR(loc);
")"         return Parser::make_RPAR(loc);
":"         return Parser::make_COLON(loc);
";"         return Parser::make_SEMICOLON(loc);
","         return Parser::make_COMMA(loc);
"+"         return Parser::make_PLUS(loc);
"-"         return Parser::make_MINUS(loc);
"*"         return Parser::make_TIMES(loc);
"/"         return Parser::make_DIV(loc);
"^"         return Parser::make_POW(loc);
"."         return Parser::make_DOT(loc);
"="         return Parser::make_EQUAL(loc);
"<"         return Parser::make_LOWER(loc);
"<="        return Parser::make_LOWEREQUAL(loc);
"<-"        return Parser::make_ASSIGN(loc);

    /* Numbers and identifiers */
    /* {int}       return make_NUMBER(yytext, loc); */
    /* {id}    return Parser::make_IDENTIFIER(yytext, loc); */


    /* Invalid characters */
.           {
                print_error(loc.begin, "invalid character: " + string(yytext));
                return Parser::make_YYerror(tmploc);
}
    
    /* End of file */
<<EOF>>     return Parser::make_YYEOF(loc);
%%

    /* User code */
    
    

    // changed
Parser::symbol_type make_INTEGER(const string &s,
                                const location& loc)                             
{
    int n;
    if(s[1] == 'x'){
      size_t a = 2;
      n = stoi(s,&a,16);
    }
    else{
      n = stoi(s);
    }

    return Parser::make_INTEGER(n, loc);
}

Parser::symbol_type make_STRINGL(const string &s,
                                 location& loc)                             
{
    string out;
    out.append(1,'"');
    int offc = 1;
    int offl = 0;
    for(size_t i=1;i<s.length()-1;i++){
       if(s[i] == '\n'){
          print_error_off(loc.begin, "raw line feed: " + string(yytext),offl,offc);
          return Parser::make_YYerror(loc);
       }
       if(s[i] == '"' && s.length()<3){
          print_error_off(loc.begin, "invalid character: " + string(yytext),offl,offc);
          return Parser::make_YYerror(loc);
       }
       if(s[i] == 92){
          switch (s[i+1])
          {
           case 'b':
           {
               out.append(1,92);
               out.append(1,'x');
               out.append(1,'0');
               out.append(1,'8');
               i++;
               break;
           }
           case 't':
           {
               out.append(1,92);
               out.append(1,'x');
               out.append(1,'0');
               out.append(1,'9');
               i++;
               break;
           }
           case 'n':
           {
               out.append(1,92);
               out.append(1,'x');
               out.append(1,'0');
               out.append(1,'a');
               i++;
               break;
           }
           case 'r':
           {
               out.append(1,92);
               out.append(1,'x');
               out.append(1,'0');
               out.append(1,'d');
               i++;
               break;
           }
           case '"':
           {
               if(s.length()-1 == i+1){
                   print_error_off(loc.begin, "invalid character: " + string(yytext),offl,offc);
                   return Parser::make_YYerror(loc);
               }
               out.append(1,'"');
               i++;
               break;
           }
           case 92:
           {
               out.append(1,92);
               i++;
               break;
           }
           case 'x':
           {
               //verify string is long enough
               if(s.length()-1 <= i+3){
                   print_error(loc.begin, "invalid hex number: " + string(yytext));
                   return Parser::make_YYerror(loc);
               }
               out.append(1,92);
               out.append(1,'x');
               out.append(1,s[i+2]);
               out.append(1,s[i+3]);
               i = i+3;
               break;
           }
           case '\n':
           {
               i=i+2;
               while(s[i]==' ' || s[i]=='\t'){
                   i++;
               }
               i--;
               offc = -1;
               offl++;
               break;
           }
           default:
               print_error_off(loc.begin, "invalid character: " + string(yytext),offl,offc);
               return Parser::make_YYerror(loc);
               break;
         }
       }
       
       else{
          out.append(1,s[i]);
       }
       offc++;
    }
    out.append(1,'"');
    return Parser::make_STRINGL(out, loc);
}

static void print_error(const position &pos, const string &m)
{
    cerr << *(pos.filename) << ":"
         << pos.line << ":"
         << pos.column << ":"
         << " lexical error: "
         << m
         << endl;
}

static void print_error_off(const position &pos, const string &m, int offl, int offc)
{
    cerr << *(pos.filename) << ":"
         << pos.line+offl << ":"
         << pos.column+offc << ":"
         << " lexical error: "
         << m
         << endl;
}

void Driver::scan_begin()
{
    loc.initialize(&source_file);

    if (source_file.empty() || source_file == "-")
        yyin = stdin;
    else if (!(yyin = fopen(source_file.c_str(), "r")))
    {
        cerr << "cannot open " << source_file << ": " << strerror(errno) << '\n';
        exit(EXIT_FAILURE);
    }
}

void Driver::scan_end()
{
    fclose(yyin);
}
