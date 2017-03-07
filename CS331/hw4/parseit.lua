-- parseit.lua
-- Frank Cline
-- 4 March 2017
-- For CS F331 Homework 6

--[[ ******** Grammar for Kanchil ********

(1)     program     →   stmt_list
(2)     stmt_list   →   { statement }
(3)     statement   →   “cr”
(4)                 |   “print” ( STRLIT | expr )
(5)                 |   “input” lvalue
(6)                 |   “set” lvalue “:” expr
(7)                 |   “sub” SUBID stmt_list “end”
(8)                 |   “call” SUBID
(9)                 |   “if” expr stmt_list { “elseif” expr stmt_list } [ “else” stmt_list ] “end”
(10)                |   “while” expr stmt_list “end”
(11)        expr    →   comp_expr { ( “&&” | “||” ) comp_expr }
(12)    comp_expr   →   “!” comp_expr
(13)                |   arith_expr { ( “==” | “!=” | “<” | “<=” | “>” | “>=” ) arith_expr }
(14)  arith_expr    →   term { ( “+” | “-” ) term }
(15)        term    →   factor { ( “*” | “/” | “%” ) factor }
(16)      factor    →   ( “+” | “-” ) factor
(17)                |   “(” expr “)”
(18)                |   NUMLIT
(19)                |   ( “true” | “false” )
(20)                |   lvalue
(21)      lvalue    →   VARID [ “[” expr “]” ]

--]]

lexit = require "lexit"

parseit = {}

-- Symbolic Constants for AST
STMT_LIST   = 1
CR_STMT     = 2
PRINT_STMT  = 3
INPUT_STMT  = 4
SET_STMT    = 5
SUB_STMT    = 6
CALL_STMT   = 7
IF_STMT     = 8
WHILE_STMT  = 9
BIN_OP      = 10
UN_OP       = 11
NUMLIT_VAL  = 12
STRLIT_VAL  = 13
BOOLLIT_VAL = 14
VARID_VAL   = 15
ARRAY_REF   = 16

-- lexer iteration
local iter
local state
local lexer_out_str
local lexer_out_cat

-- Current lexeme and lexeme category
local lexstr = ""
local lexcat = 0

-- advance
-- Gets next lexeme and lexeme category from the lexer
-- and stores it to lexstr and lexcat.
-- init() must be called before this function is called.
local function advance()
    lexer_out_str, lexer_out_cat = iter(state, lexer_out_str)

    if lexer_out_str ~= nil then
        lexstr, lexcat = lexer_out_str, lexer_out_cat
    else
        lexstr, lexcat = "", 0
    end
end


-- init
-- Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_str = lexit.lex(prog)
    advance()
end


-- atEnd
-- Return true if the end of the program has been reached
-- init() must be called before this function is called.
local function atEnd()
    return lexcat == 0
end


-- matchString
-- Takes a string and compares it to the current lexeme.
-- If they are equal, advances to the next lexeme and returns true.
--    If the string is ")", "]", "true", or "false" then an operator is
--    preferred for the next lexeme.
-- Otherwise, return false.
-- init() must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        if lexstr == ")" or lexstr == "]" or
          lexstr == "true" or lexstr == "false" then
          lexit.preferOp()
        end
        advance()
        return true
    else
        return false
    end
end


-- matchCat
-- Takes an integer and compares it to the current lexeme category.
-- If they are equal, advances to the next lexeme and returns true.
--    If the current lexeme category is a VARID or NUMLIT then an
--    operator is preferred for the next lexeme.
-- Otherwise, returns false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        if lexcat == lexit.VARID or lexcat == lexit.NUMLIT then
          lexit.preferOp()
        end
        advance()
        return true
    else
        return false
    end
end

-- parseit.parse
-- Takes a string that is the program to be parsed.
-- Returns bool,bool,table
--    First bool is if the syntax is correct.
--    Second bool is if the end of program is reached.
--    Table is the abstract syntax tree of the program.
function parseit.parse(program)
  init(program)
  -- program -> statement_list
  local good, ast = parse_stmt_list()
  local done = atEnd()

  return good, done, ast
end

-- *********************************************************
-- Local Parsing Functions
-- 
-- Named: parse_<nonterminal name>
--
-- Returns bool,table
--    Bool is true if the syntax is correct
--    Table is the abstract syntax tree of the nonterminal.
-- *********************************************************

-- parse_stmt_list
-- stmt_list → { statement }
function parse_stmt_list()
  local good, ast, newast

  ast = { STMT_LIST }

  while true do
    if lexstr ~= "cr" and lexstr ~= "print" and lexstr ~= "input" and
      lexstr ~= "set" and lexstr ~= "sub" and lexstr ~= "call" and
      lexstr ~= "if" and lexstr ~= "while" then
      break
    end

    good, newast = parse_stmt()
    if not good then
      return false, nil
    end

    table.insert(ast,newast)
  end

  return true, ast
end

-- parse_stmt
-- statement → “cr”
--           | “print” ( STRLIT | expr )
--           | “input” lvalue
--           | “set” lvalue “:” expr
--           | “sub” SUBID stmt_list “end”
--           | “call” SUBID
--           | “if” expr stmt_list { “elseif” expr stmt_list } [ “else” stmt_list ] “end”
--           | “while” expr stmt_list “end”
function parse_stmt()
  local oldlexstr, good, ast, newast

  if matchString("cr") then
    return true, { CR_STMT }

  elseif matchString("print") then
    oldlexstr = lexstr
    if matchCat(lexit.STRLIT) then
      return true, { PRINT_STMT, {STRLIT_VAL, oldlexstr} }
    else
      good,ast = parse_expr()
      if not good then
        return false,nil
      end
      ast = { PRINT_STMT, ast }
    end

  elseif matchString("input") then
    good,ast = parse_lvalue()
    if not good then
      return false,nil
    end
    ast = { INPUT_STMT, ast }

  elseif matchString("set") then
    good,ast = parse_lvalue()
    if not good or not matchString(":") then
      return false,nil
    end
    good,newast = parse_expr()
    if not good then
      return false,nil
    end
    ast = {SET_STMT, ast, newast}

  elseif matchString("sub") then
    local subid = lexstr
    if not matchCat(lexit.SUBID) then
      return false,nil
    end
    good,ast = parse_stmt_list()
    if not good or not matchString("end") then
      return false,nil
    end
    ast = { SUB_STMT, subid, ast }

  elseif matchString("call") then
    oldlexstr = lexstr
    if not matchCat(lexit.SUBID) then
      return false,nil
    end
    ast = { CALL_STMT, oldlexstr }
    return true,ast

  elseif matchString("if") then
    local expr,stmt_list

    good,expr = parse_expr()
    if not good then
      return false,nil
    end

    good,stmt_list = parse_stmt_list()
    if not good then
      return false,nil
    end

    ast = { IF_STMT, expr, stmt_list }

    while true do
      oldlexstr = lexstr
      if not matchString("elseif") then
        break
      end

      good,expr = parse_expr()
      if not good then
        return false,nil
      end

      good,stmt_list = parse_stmt_list()
      if not good then
        return false,nil
      end
      table.insert(ast,expr)
      table.insert(ast,stmt_list)
    end

    if matchString("else") then
      good,stmt_list = parse_stmt_list()
      if not good then
        return false,nil
      end
      table.insert(ast,stmt_list)
    end

    if not matchString("end") then
      return false,nil
    end

  elseif matchString("while") then
    local expr,stmt_list

    good,expr = parse_expr()
    if not good then 
      return false,nil
    end

    good,stmt_list = parse_stmt_list()
    if not good or not matchString("end") then
      return false,nil
    end

    ast = { WHILE_STMT, expr, stmt_list }
  
  else
    return false,nil
  end

  return true,ast
end

-- parse_expr
-- expr → comp_expr { ( “&&” | “||” ) comp_expr }
function parse_expr()
  local oldlexstr, good, ast, newast

  good,ast = parse_comp_expr()
  if not good then
    return false,nil
  end

  while true do
    oldlexstr = lexstr
    if not matchString("&&") and not matchString("||") then
      break
    end
    good, newast = parse_comp_expr()
    if not good then
      return false, nil
    end
    ast = { { BIN_OP, oldlexstr }, ast, newast }
  end

  return true,ast
end

-- parse_comp_expr
-- comp_expr   →   “!” comp_expr
--             |   arith_expr { ( “==” | “!=” | “<” | “<=” | “>” | “>=” ) arith_expr }
function parse_comp_expr()
  local oldlexstr, good, ast, newast

  if matchString("!") then
    good,ast = parse_comp_expr()
    if not good then
      return false,nil
    end
    ast = { {UN_OP, "!"}, ast }
    return true,ast
  end

  good,ast = parse_arith_expr()
  if not good then
    return false,nil
  end
  
  while true do
    oldlexstr = lexstr
    if not matchString("==") and not matchString("!=") 
      and not matchString("<") and not matchString("<=")
      and not matchString(">") and not matchString(">=") then
      break
    end

    good, newast = parse_arith_expr()
    if not good then
      return false, nil
    end
    ast = { { BIN_OP, oldlexstr }, ast, newast }
  end

  return true,ast
end

-- parse_arith_expr
-- arith_expr → term { ( “+” | “-” ) term }
function parse_arith_expr()
  local oldlexstr, good, ast, newast

  good,ast = parse_term()
  if not good then
    return false,nil
  end

  while true do
    oldlexstr = lexstr
    if not matchString("+") and not matchString("-") then
      break
    end

    good,newast = parse_term()
    if not good then
      return false,nil
    end
    ast = { {BIN_OP, oldlexstr}, ast, newast }
  end

  return true,ast
end

-- parse_term
-- term → factor { ( “*” | “/” | “%” ) factor }
function parse_term()
  local oldlexstr, good, ast, newast

  good,ast = parse_factor()
  if not good then
    return false,nil
  end

  while true do
    oldlexstr = lexstr
    if not matchString("*") and not matchString("/") 
      and not matchString("%") then
      break
    end

    good,newast = parse_factor()
    if not good then
      return false,nil
    end
    ast = { {BIN_OP, oldlexstr}, ast, newast }
  end

  return true,ast
end

-- parse_factor
-- factor → ( “+” | “-” ) factor
--        |   “(” expr “)”
--        |   NUMLIT
--        |   ( “true” | “false” )
--        |   lvalue
function parse_factor()
  local oldlexstr, good, ast, newast

  oldlexstr = lexstr
  if matchString("+") or matchString("-") then
    good,newast = parse_factor()
    if not good then
      return false,nil
    end
    ast = { {UN_OP, oldlexstr}, newast }

  elseif matchString("(") then
    good,ast = parse_expr()
    if not good or not matchString(")") then
      return false,nil
    end

  elseif matchCat(lexit.NUMLIT) then
    ast = { NUMLIT_VAL, oldlexstr }

  elseif matchString("true") or matchString("false") then
    ast = { BOOLLIT_VAL, oldlexstr }

  else
    good,ast = parse_lvalue() 
    if not good then
      return false,nil
    end
  end

  return true,ast
end

-- parse_lvalue
-- lvalue → VARID [ “[” expr “]” ]
function parse_lvalue()
  local oldlexstr, good, ast, newast
  oldlexstr = lexstr
  if matchCat(lexit.VARID) then
    ast = { VARID_VAL, oldlexstr }
  else
    return false,nil
  end

  if matchString("[") then
    good,newast = parse_expr()
    if not good or not matchString("]") then
      return false,nil
    end
    ast = { ARRAY_REF, { VARID_VAL, oldlexstr }, newast }
  end
  return true,ast
end

return parseit
