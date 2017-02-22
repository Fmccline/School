-- lexit.lua
-- Frank Cline
-- 20 Feb 2017
-- Assignment 3 lexer file

lexit = require "lexit"

local catnames = 
{
	"Keyword",
	"VariableIdentifier",
	"SubroutineIdentifier",
	"NumericLiteral",
	"StringLiteral",
	"Operator",
	"Punctuation",
	"Malformed"	
}

program = "\"hello world\" \'\"does this work?\"\' \"hello\""

for lexeme,cat in lexit.lex(program) do
	io.write(lexeme .. " : " .. catnames[cat] .. "\n")
end