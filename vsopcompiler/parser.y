/* This flex/bison example is provided to you as a starting point for your
 * assignment. You are free to use its code in your project.
 *
 * This example implements a simple calculator. You can use the '-l' flag to
 * list all the tokens found in the source file, and the '-p' flag (or no flag)
 * to parse the file and to compute the result.
 *
 * Also, if you have any suggestions for improvements, please let us know.
 */

%skeleton "lalr1.cc" // -*- C++ -*-
%language "c++"
%require "3.7.5"
%locations

%defines

// Put parser inside a namespace
%define api.namespace {VSOP}

// Give the name of the parser class
%define api.parser.class {Parser}

// Force the token kind enum (used by the lexer) and the symbol kind enum
// (used by the parser) to use the same value for the tokens.
// (e.g. '+' will be represented by the same integer value in both enums.)
%define api.token.raw

// Tokens contain their type, value and location
// Also allow to use the make_TOKEN functions
%define api.token.constructor

// Allow to use C++ objects as semantic values
%define api.value.type variant

// Add some assertions.
%define parse.assert

// C++ code put inside header file
%code requires {
    #include <string>

    namespace VSOP
    {
        class Driver;
    }
}

// Add an argument to the parser constructor
%parse-param {VSOP::Driver &driver}

%code {
    #include "driver.hpp"

    using namespace std;
}

// Token and symbols definitions
%token
    EXTENDS    "extends"
    AND        "and"
    ISNULL     "isnull"
    STRING     "string"
    BOOL       "bool"
    FALSE      "false"
    LET        "let"
    THEN       "then"
    CLASS      "class"
    IF         "if"
    NEW        "new"
    TRUE       "true"
    DO         "do"
    IN         "in"
    NOT        "not"
    UNIT       "unit"
    ELSE       "else"
    INT32      "int32"
    SELF       "self"
    WHILE      "while"

    LBRACE     "{"
    RBRACE     "}"
    LPAR       "("
    RPAR       ")"
    COLON      ":"
    SEMICOLON  ";"
    COMMA      ","
    PLUS       "+"
    MINUS      "-"
    TIMES      "*"
    DIV        "/"
    POW        "^"
    DOT        "."
    EQUAL      "="
    LOWER      "<"
    LOWEREQUAL "<="
    ASSIGN     "<-"
;

// For some symbols, need to store a value
%token <int> INTEGER "integer-literal"
%token <std::string> TYPEID "type-identifier"
%token <std::string> OBJECTID "object-identifier"
%token <std::string> STRINGL "string-literal"
%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"
%nterm <int> exp

// Precedence
%left "+" "-"; // Could also do: %left PLUS MINUS
%left "*" "/";

%%
// Grammar rules

%start unit;
unit: assignments exp  { driver.result = $2; };

assignments:
    %empty                      {}
    | assignments assignment    {};

assignment:
    "identifier" ":=" exp { driver.add_variable($1, $3); };

exp:
    "number"
    | "identifier"  {
                        if (!driver.has_variable($1))
                        {
                            error(@1, "variable " + $1 + " not defined");
                            YYERROR;
                        }
                        $$ = driver.get_variable($1);
                    }
    | exp "+" exp   { $$ = $1 + $3; }
    | exp "-" exp   { $$ = $1 - $3; }
    | exp "*" exp   { $$ = $1 * $3; }
    | exp "/" exp   { $$ = $1 / $3; }
    | "(" exp ")"   { $$ = $2; }

%%
// User code
void VSOP::Parser::error(const location_type& l, const std::string& m)
{
    const position &pos = l.begin;

    cerr << *(pos.filename) << ":"
         << pos.line << ":" 
         << pos.column << ": "
         << m
         << endl;
}
