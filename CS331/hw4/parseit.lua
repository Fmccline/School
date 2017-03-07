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

-- For lexer iteration
local iter            -- Iterator returned by lexer.lex
local state           -- State for above iterator (maybe not used)
local lexer_out_str   -- Return value #1 from above iterator
local lexer_out_cat   -- Return value #2 from above iterator

-- For current lexeme
local lexstr = ""
local lexcat = 0

local finalstr = ""

-- Utility Functions

-- advance
-- Go to next lexeme and load it into lexstr, lexcat.
-- Should be called once before any parsing is done.
-- Function init must be called before this function is called.
local function advance()
    -- Advance the iterator
    lexer_out_str, lexer_out_cat = iter(state, lexer_out_str)

    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_str ~= nil then
        lexstr, lexcat = lexer_out_str, lexer_out_cat
    else
        lexstr, lexcat = "", 0
    end

    finalstr = finalstr.." "..lexstr
end


-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_str = lexit.lex(prog)
    advance()
end


-- atEnd
-- Return true if pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end


-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
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
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
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

function parseit.parse(program)
  init(program)

  -- Get results from parsing
  local good, ast = parse_stmt_list()  -- Parse start symbol
  local done = atEnd()

  io.write("Parsed: "..finalstr)
  io.write("\nCategory: " .. lexcat .. "\n")
  io.write("Lexeme: " .. lexstr .. "\n")

  finalstr = ""
  -- And return them
  return good, done, ast
end

-- ***********************
-- Local Parsing Functions
-- ***********************

-- parse_stmt_list
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
function parse_stmt()
  local oldlexstr, good, ast

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
    good,ast = parse_lvalue
    if not good or not matchString(":") then
      return false,nil
    end
    good,newast = parse_expr()
    if not good then
      return false,nil
    end
    ast = {SET_STMT, ast, newast}

  elseif matchString("sub") then
    oldlexstr = lexstr
    good,ast = parse_stmt_list()  
    if not good and not matchString("end") then
      return false,nil
    end
    ast = { SUB_STMT, oldlexstr, ast }

  elseif matchString("call") then
    ast = { CALL_STMT, lexstr }
    return true,ast

  elseif matchString("if") then
    good,expr = parse_expr()
    if not good then
      return false,nil
    end

    good,stmt_list = parse_stmt_list()
    if not good or not matchString("end") then
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
-- expr    →   comp_expr { ( “&&” | “||” ) comp_expr }
function parse_expr()
  local oldlexstr, good, ast

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
  local oldlexstr, good, ast

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
  local oldlexstr, good, ast

  good,ast = parse_term()
  if not good then
    return nil,false
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
  local oldlexstr, good, ast

  good,ast = parse_factor()
  if not good then
    return nil,false
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
  local oldlexstr, good, ast

  oldlexstr = lexstr
  if matchString("+") or matchString("-") then
    good,newast = parse_factor()
    if not good then
      return false,nil
    end
    ast = { {BIN_OP, oldlexstr}, ast, newast }

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
  local oldlexstr, good, ast

  oldlexstr = lexstr
  if matchString("[") then
    good,newast = parse_expr()
    if not good or not matchString("]") then
      return false,nil
    end
    ast = { ARRAY_REF, { VARID_VAL, oldlexstr }, newast }

  elseif matchCat(lexit.VARID) then
    ast = { VARID_VAL, oldlexstr }

  else
    return false,nil
  end

  return true,ast
end




return parseit
