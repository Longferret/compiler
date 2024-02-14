/* This flex/bison example is provided to you as a starting point for your
 * assignment. You are free to use its code in your project.
 *
 * This example implements a simple calculator. You can use the '-l' flag to
 * list all the tokens found in the source file, and the '-p' flag (or no flag)
 * to parse the file and to compute the result.
 *
 * Also, if you have any suggestions for improvements, please let us know.
 */

#include <iostream>
#include <string>
#include <map>

#include "driver.hpp"
#include "parser.hpp"

using namespace std;
using namespace VSOP;

/**
 * @brief Map a token type to a string.
 */
static const map<Parser::token_type, string> type_to_string = {
    {Parser::token::AND, "and"},
    {Parser::token::EXTENDS, "extends"},
    {Parser::token::ISNULL, "isnull"},
    {Parser::token::STRING, "string"},
    {Parser::token::BOOL, "bool"},
    {Parser::token::FALSE, "false"},
    {Parser::token::LET, "let"},
    {Parser::token::THEN, "then"},
    {Parser::token::CLASS, "class"},
    {Parser::token::IF, "if"},
    {Parser::token::NEW, "new"},
    {Parser::token::TRUE, "true"},
    {Parser::token::DO, "do"},
    {Parser::token::IN, "in"},
    {Parser::token::NOT, "not"},
    {Parser::token::UNIT, "unit"},
    {Parser::token::ELSE, "else"},
    {Parser::token::INT32, "int32"},
    {Parser::token::SELF, "self"},
    {Parser::token::WHILE, "while"},
    {Parser::token::LBRACE, "lbrace"},
    {Parser::token::RBRACE, "rbrace"},
    {Parser::token::LPAR, "lpar"},
    {Parser::token::RPAR, "rpar"},
    {Parser::token::COLON, "colon"},
    {Parser::token::SEMICOLON, "semicolon"},
    {Parser::token::COMMA, "comma"},
    {Parser::token::PLUS, "plus"},
    {Parser::token::MINUS, "minus"},
    {Parser::token::TIMES, "times"},
    {Parser::token::DIV, "div"},
    {Parser::token::POW, "pow"},
    {Parser::token::DOT, "dot"},
    {Parser::token::EQUAL, "equal"},
    {Parser::token::LOWER, "lower"},
    {Parser::token::LOWEREQUAL, "lower-equal"},
    {Parser::token::ASSIGN, "assign"},

    {Parser::token::INTEGER, "integer-literal"},
    {Parser::token::TYPEID, "type-identifier"},
    {Parser::token::OBJECTID, "object-identifier"},
    {Parser::token::STRINGL, "string-literal"},

    {Parser::token::IDENTIFIER, "identifier"},
    {Parser::token::NUMBER, "number"},
};

/**
 * @brief Print the information about a token
 *
 * @param token the token
 */
static void print_token(Parser::symbol_type token)
{
    position pos = token.location.begin;
    Parser::token_type type = (Parser::token_type)token.type_get();

    cout << pos.line << ","
         << pos.column << ","
         << type_to_string.at(type);

    switch (type)
    {
    case Parser::token::NUMBER:
    {
        int value = token.value.as<int>();
        cout << "," << value;
        break;
    }

    case Parser::token::IDENTIFIER:
    {
        string id = token.value.as<string>();
        cout << "," << id;
        break;
    }
    case Parser::token::TYPEID:
    {
        string type_id = token.value.as<string>();
        cout << "," << type_id;
        break;
    }
    case Parser::token::STRINGL:
    {
        string stringl = token.value.as<string>();
        cout << "," << stringl;
        break;
    }
    case Parser::token::INTEGER:
    {
        int value = token.value.as<int>();
        cout << "," << value;
        break;
    }
    case Parser::token::OBJECTID:
    {
        string objectid = token.value.as<string>();
        cout << "," << objectid;
        break;
    }

    default:
        break;
    }

    cout << endl;
}

int Driver::lex()
{
    scan_begin();

    int error = 0;

    while (true)
    {
        Parser::symbol_type token = yylex();

        if ((Parser::token_type)token.type_get() == Parser::token::YYEOF)
            break;

        if ((Parser::token_type)token.type_get() != Parser::token::YYerror)
            tokens.push_back(token);

        else
            error = 1;
    }

    scan_end();

    return error;
}

int Driver::parse()
{
    scan_begin();

    parser = new Parser(*this);

    int res = parser->parse();
    scan_end();

    delete parser;

    return res;
}

void Driver::print_tokens()
{
    for (auto token : tokens)
        print_token(token);
}
