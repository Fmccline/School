#!/usr/bin/env lua
-- lexit_test.lua
-- Glenn G. Chappell
-- 14 Feb 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Test Program for Module lexit
-- Used in Assignment 3, Exercise B

lexit = require "lexit"  -- Import lexit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

EXIT_ON_FIRST_FAILURE = true
-- If EXIT_ON_FIRST_FAILURE is true, then this program exits after the
-- first failing test. If it is false, then this program executes all
-- tests, reporting success/failure for each.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

function tester.test(self, success, testName)
    self.countTests = self.countTests+1
    io.write("    Test: " .. testName .. " - ")
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


function fail_exit()
    if EXIT_ON_FIRST_FAILURE then
        io.write("**************************************************\n")
        io.write("* This test program is configured to exit after  *\n")
        io.write("* the first failing test. To make it execute all *\n")
        io.write("* tests, reporting success/failure for each, set *\n")
        io.write("* variable                                       *\n")
        io.write("*                                                *\n")
        io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
        io.write("*                                                *\n")
        io.write("* to false, near the start of the test program.  *\n")
        io.write("**************************************************\n")

        -- Wait for user
        io.write("\nPress ENTER to quit ")
        io.read("*l")

        -- Terminate program
        os.exit(1)
    end
end


-- printTable
-- Given a table, prints it in (roughly) Lua literal notation. If
-- parameter is not a table, prints <not a table>.
function printTable(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string,
    -- or simply an indication of its type, if it is not number, string,
    -- or boolean.
    local function out(p)
        if type(p) == "number" then
            io.write(p)
        elseif type(p) == "string" then
            io.write('"'..p..'"')
        elseif type(p) == "boolean" then
            if p then
                io.write("true")
            else
                io.write("false")
            end
        else
            io.write('<'..type(p)..'>')
        end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in pairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        io.write("[")
        out(k)
        io.write("]=")
        out(v)
    end
    io.write(" }")
end


-- printArray
-- Given a table, prints it in (roughly) Lua literal notation for an
-- array. If parameter is not a table, prints <not a table>.
function printArray(t)
    -- out
    -- Print parameter, surrounded by double quotes if it is a string.
    local function out(p)
        if type(p) == "string" then io.write('"') end
        io.write(p)
        if type(p) == "string" then io.write('"') end
    end

    if type(t) ~= "table" then
        io.write("<not a table>")
    end

    io.write("{ ")
    local first = true  -- First iteration of loop?
    for k, v in ipairs(t) do
        if first then
            first = false
        else
            io.write(", ")
        end
        out(v)
    end
    io.write(" }")
end


-- tableEq
-- Compare equality of two tables.
-- Uses "==" on table values. Returns false if either of t1 or t2 is not
-- a table.
function tableEq(t1, t2)
    -- Both params are tables?
    local type1, type2 = type(t1), type(t2)
    if type1 ~= "table" or type2 ~= "table" then
        return false
    end

    -- Get number of keys in t1 & check values in t1, t2 are equal
    local t1numkeys = 0
    for k, v in pairs(t1) do
        t1numkeys = t1numkeys + 1
        if t2[k] ~= v then
            return false
        end
    end

    -- Check number of keys in t1, t2 same
    local t2numkeys = 0
    for k, v in pairs(t2) do
        t2numkeys = t2numkeys + 1
    end
    return t1numkeys == t2numkeys
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Lexeme Categories
KEY = 1
VARID = 2
SUBID = 3
NUMLIT = 4
STRLIT = 5
OP = 6
PUNCT = 7
MAL = 8


function checkLex(t, prog, expectedOutput, testName, poTest)
    local poCalls = {}
    local function printResults(output, printPOC)
        if printPOC == true then
            io.write(
              "[* indicates preferOp() called before this lexeme]\n")
        end
        local blank = " "
        local i = 1
        while i*2 <= #output do
            local lexstr = '"'..output[2*i-1]..'"'
            if printPOC == true then
               if poCalls[i] then
                   lexstr = "* " .. lexstr
               else
                   lexstr = "  " .. lexstr
               end
            end
            local lexlen = lexstr:len()
            if lexlen < 8 then
                lexstr = lexstr..blank:rep(8-lexlen)
            end
            local catname = lexit.catnames[output[2*i]]
            print(lexstr, catname)
            i = i+1
        end
    end

    local actualOutput = {}

    local count = 1
    local poc = false
    if poTest ~= nil then
        poc = poTest(count, nil, nil)
        if poc then lexit.preferOp() end
    end
    table.insert(poCalls, poc)

    for lexstr, cat in lexit.lex(prog) do
        table.insert(actualOutput, lexstr)
        table.insert(actualOutput, cat)
        count = count+1
        poc = false
        if poTest ~= nil then
            poc = poTest(count, lexstr, cat)
            if poc then lexit.preferOp() end
        end
        table.insert(poCalls, poc)
    end

    local success = tableEq(actualOutput, expectedOutput)
    t:test(success, testName)
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("Input for the last test above:\n")
        io.write('"'..prog..'"\n')
        io.write("\n")
        io.write("Expected output of lexit.lex:\n")
        printResults(expectedOutput)
        io.write("\n")
        io.write("Actual output of lexit.lex:\n")
        printResults(actualOutput, poTest ~= nil)
        io.write("\n")
        fail_exit()
   end
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_categories(t)
    io.write("Test Suite: Lexeme categories\n")
    local success

    success = lexit.KEY == KEY
    t:test(success, "Value of lexit.KEY")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.KEY is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.VARID == VARID
    t:test(success, "Value of lexit.VARID")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.VARID is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.SUBID == SUBID
    t:test(success, "Value of lexit.SUBID")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.SUBID is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.NUMLIT == NUMLIT
    t:test(success, "Value of lexit.NUMLIT")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.NUMLIT is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.STRLIT == STRLIT
    t:test(success, "Value of lexit.STRLIT")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.STRLIT is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.OP == OP
    t:test(success, "Value of lexit.OP")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.OP is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.PUNCT == PUNCT
    t:test(success, "Value of lexit.PUNCT")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.PUNCT is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    success = lexit.MAL == MAL
    t:test(success, "Value of lexit.MAL")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("lexit.MAL is undefined or has the wrong value.\n")
        io.write("\n")
        fail_exit()
    end

    local success =
        #lexit.catnames == 8 and
        lexit.catnames[KEY]    == "Keyword" and
        lexit.catnames[VARID]  == "VariableIdentifier" and
        lexit.catnames[SUBID]  == "SubroutineIdentifier" and
        lexit.catnames[NUMLIT] == "NumericLiteral" and
        lexit.catnames[STRLIT] == "StringLiteral" and
        lexit.catnames[OP]     == "Operator" and
        lexit.catnames[PUNCT]  == "Punctuation" and
        lexit.catnames[MAL]    == "Malformed"
    t:test(success, "Value of catnames member")
    if EXIT_ON_FIRST_FAILURE and not success then
        io.write("\n")
        io.write("Array lexit.catnames does not have the required\n")
        io.write("values. See the assignment description, where the\n")
        io.write("proper values are listed in a table.\n")
        io.write("\n")
        fail_exit()
    end
end

function test_key(t)
    io.write("Test Suite: Keyword\n")

    checkLex(t, "a", {"a",MAL}, "single letter")
    checkLex(t, "a  ", {"a",MAL}, "single letter + space")
    checkLex(t, "a#", {"a",MAL}, "single letter + comment")
    checkLex(t, "a #", {"a",MAL}, "single letter + space + comment")
    checkLex(t, " a", {"a",MAL}, "space + letter")
    checkLex(t, "#\na", {"a",MAL}, "comment + letter")
    checkLex(t, "#\n a", {"a",MAL}, "comment + space + letter")
    checkLex(t, "ab", {"ab",MAL}, "two letters")
    checkLex(t, "call", {"call",KEY}, "keyword: call")
    checkLex(t, "cr", {"cr",KEY}, "keyword: cr")
    checkLex(t, "else", {"else",KEY}, "keyword: else")
    checkLex(t, "elseif", {"elseif",KEY}, "keyword: elseif")
    checkLex(t, "end", {"end",KEY}, "keyword: end")
    checkLex(t, "false", {"false",KEY}, "keyword: false")
    checkLex(t, "if", {"if",KEY}, "keyword: if")
    checkLex(t, "input", {"input",KEY}, "keyword: input")
    checkLex(t, "print", {"print",KEY}, "keyword: print")
    checkLex(t, "set", {"set",KEY}, "keyword: set")
    checkLex(t, "sub", {"sub",KEY}, "keyword: sub")
    checkLex(t, "true", {"true",KEY}, "keyword: true")
    checkLex(t, "while", {"while",KEY}, "keyword: while")
    checkLex(t, "begin", {"begin",MAL}, "eliminated keyword: begin")
    checkLex(t, "calls", {"calls",MAL}, "keyword+letter")
    checkLex(t, "calL", {"calL",MAL}, "keyword -> 1 letter UC")
    checkLex(t, "CALL", {"CALL",MAL}, "keyword -> all UC")
    checkLex(t, "pri nt",{"pri",MAL,"nt",MAL},"split keyword #1")
    checkLex(t, "prin",{"prin",MAL},"partial keyword")
    checkLex(t, "pri#\nnt",{"pri",MAL,"nt",MAL},"split keyword #2")
    checkLex(t, "pri2nt",{"pri",MAL,"2",NUMLIT,"nt",MAL},"split keyword #3")
    checkLex(t, "pri_nt",{"pri",MAL,"_",PUNCT,"nt",MAL},"split keyword #4")
    checkLex(t, "else if",{"else",KEY,"if",KEY},"split keyword #5")
    checkLex(t, "_while",{"_",PUNCT,"while",KEY},"_ + keyword")
    local astr = "a"
    local longbadkey = astr:rep(10000)
    checkLex(t, longbadkey,{longbadkey,MAL}, "long bad-keyword")
end


function test_varid(t)
    io.write("Test Suite: VariableIdentifier\n")

    checkLex(t, "%", {"%",OP}, "percent")
    checkLex(t, "%%", {"%",OP,"%",OP}, "percent + percent")
    checkLex(t, "%%%", {"%",OP,"%",OP,"%",OP}, "percent + percent + percent")
    checkLex(t, "%%%%", {"%",OP,"%",OP,"%",OP,"%",OP}, "percent + percent + percent + percent")
    checkLex(t, "%a", {"%a",VARID}, "percent + letter")
    checkLex(t, "%%a", {"%",OP,"%a",VARID}, "percent + percent + letter")
    checkLex(t, "% a", {"%",OP,"a",MAL}, "percent + space + letter")
    checkLex(t, "%_", {"%_",VARID}, "percent + underscore")
    checkLex(t, "% _", {"%",OP,"_",PUNCT}, "percent + space + letter")
    checkLex(t, "%3", {"%",OP,"3",NUMLIT}, "percent + digit")
    checkLex(t, "% 3", {"%",OP,"3",NUMLIT}, "percent + space + digit")
    checkLex(t, "%a3", {"%a3",VARID}, "percent + letter + digit")
    checkLex(t, "%_3", {"%_3",VARID}, "percent + underscore + digit")
    checkLex(t, "%abc_39xyz", {"%abc_39xyz",VARID}, "medium-length VARID")
    checkLex(t, "%abc%def", {"%abc",VARID,"%def",VARID}, "VARID + VARID")
    checkLex(t, "%abc%", {"%abc",VARID,"%",OP}, "VARID + percent")
    checkLex(t, "%while", {"%while",VARID}, "VARID containing keyword")
end


function test_subid(t)
    io.write("Test Suite: SubroutineIdentifier\n")

    checkLex(t, "&", {"&",PUNCT}, "amper")
    checkLex(t, "&&", {"&&",OP}, "amper + amper")
    checkLex(t, "&&&", {"&&",OP,"&",PUNCT}, "amper + amper + amper")
    checkLex(t, "&&&&", {"&&",OP,"&&",OP}, "amper + amper + amper + amper")
    checkLex(t, "&a", {"&a",SUBID}, "amper + letter")
    checkLex(t, "&&a", {"&&",OP,"a",MAL}, "amper + amper + letter")
    checkLex(t, "& a", {"&",PUNCT,"a",MAL}, "amper + space + letter")
    checkLex(t, "&_", {"&_",SUBID}, "amper + underscore")
    checkLex(t, "& _", {"&",PUNCT,"_",PUNCT}, "amper + space + letter")
    checkLex(t, "&3", {"&",PUNCT,"3",NUMLIT}, "amper + digit")
    checkLex(t, "& 3", {"&",PUNCT,"3",NUMLIT}, "amper + space + digit")
    checkLex(t, "&a3", {"&a3",SUBID}, "amper + letter + digit")
    checkLex(t, "&_3", {"&_3",SUBID}, "amper + underscore + digit")
    checkLex(t, "&abc_39xyz", {"&abc_39xyz",SUBID}, "medium-length SUBID")
    checkLex(t, "&abc&def", {"&abc",SUBID,"&def",SUBID}, "SUBID + SUBID")
    checkLex(t, "&abc&", {"&abc",SUBID,"&",PUNCT}, "SUBID + amper")
    checkLex(t, "&while", {"&while",SUBID}, "SUBID containing keyword")
end


function test_numlit(t)
    io.write("Test Suite: NumericLiteral\n")

    checkLex(t, "3", {"3",NUMLIT}, "single digit")
    checkLex(t, "3a", {"3",NUMLIT,"a",MAL}, "single digit then letter")

    checkLex(t, "123456", {"123456",NUMLIT}, "num, no dot")
    checkLex(t, ".123456", {".",PUNCT,"123456",NUMLIT},
             "num, dot @ start")
    checkLex(t, "123456.", {"123456",NUMLIT,".",PUNCT},
             "num, dot @ end")
    checkLex(t, "123.456", {"123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "num, dot in middle")
    checkLex(t, "1.2.3", {"1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                          "3",NUMLIT}, "num, 2 dots")

    checkLex(t, "+123456", {"+123456",NUMLIT}, "+num, no dot")
    checkLex(t, "+.123456", {"+",OP,".",PUNCT,"123456",NUMLIT},
             "+num, dot @ start")
    checkLex(t, "+123456.", {"+123456",NUMLIT,".",PUNCT},
             "+num, dot @ end")
    checkLex(t, "+123.456", {"+123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "+num, dot in middle")
    checkLex(t, "+1.2.3", {"+1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                           "3",NUMLIT}, "+num, 2 dots")

    checkLex(t, "-123456", {"-123456",NUMLIT}, "-num, no dot")
    checkLex(t, "-.123456", {"-",OP,".",PUNCT,"123456",NUMLIT},
             "-num, dot @ start")
    checkLex(t, "-123456.", {"-123456",NUMLIT,".",PUNCT},
             "-num, dot @ end")
    checkLex(t, "-123.456", {"-123",NUMLIT,".",PUNCT,"456",NUMLIT},
             "-num, dot in middle")
    checkLex(t, "-1.2.3", {"-1",NUMLIT,".",PUNCT,"2",NUMLIT,".",PUNCT,
                           "3",NUMLIT}, "-num, 2 dots")

    checkLex(t, "--123456", {"-",OP,"-123456",NUMLIT}, "--num, no dot")
    checkLex(t, "--123456", {"-",OP,"-123456",NUMLIT},
             "--num, dot @ end")

    local onestr = "1"
    local longnumstr = onestr:rep(10000)
    checkLex(t, longnumstr, {longnumstr,NUMLIT}, "very long num #1")
    checkLex(t, longnumstr.."+", {longnumstr,NUMLIT,"+",OP},
             "very long num #2")
    checkLex(t, "123 456", {"123",NUMLIT,"456",NUMLIT},
             "space-separated nums")

    -- Exponents
    checkLex(t, "123e456", {"123e456",NUMLIT}, "num with exp")
    checkLex(t, "123e+456", {"123e+456",NUMLIT}, "num with +exp")
    checkLex(t, "123e-456", {"123",NUMLIT,"e",MAL,"-456",NUMLIT}, "num with -exp")
    checkLex(t, "+123e456", {"+123e456",NUMLIT}, "+num with exp")
    checkLex(t, "+123e+456", {"+123e+456",NUMLIT}, "+num with +exp")
    checkLex(t, "+123e-456", {"+123",NUMLIT,"e",MAL,"-456",NUMLIT}, "+num with -exp")
    checkLex(t, "-123e456", {"-123e456",NUMLIT}, "-num with exp")
    checkLex(t, "-123e+456", {"-123e+456",NUMLIT}, "-num with +exp")
    checkLex(t, "-123e-456", {"-123",NUMLIT,"e",MAL,"-456",NUMLIT}, "-num with -exp")
    checkLex(t, "123E456", {"123E456",NUMLIT}, "num with Exp")
    checkLex(t, "123E+456", {"123E+456",NUMLIT}, "num with +Exp")
    checkLex(t, "123E-456", {"123",NUMLIT,"E",MAL,"-456",NUMLIT}, "num with -Exp")
    checkLex(t, "+123E456", {"+123E456",NUMLIT}, "+num with Exp")
    checkLex(t, "+123E+456", {"+123E+456",NUMLIT}, "+num with +Exp")
    checkLex(t, "+123E-456", {"+123",NUMLIT,"E",MAL,"-456",NUMLIT}, "+num with -Exp")
    checkLex(t, "-123E456", {"-123E456",NUMLIT}, "-num with Exp")
    checkLex(t, "-123E+456", {"-123E+456",NUMLIT}, "-num with +Exp")
    checkLex(t, "-123E-456", {"-123",NUMLIT,"E",MAL,"-456",NUMLIT}, "-num with -Exp")

    checkLex(t, "1.2e34", {"1",NUMLIT,".",PUNCT,"2e34",NUMLIT},
             "num with dot, exp")
    checkLex(t, "12e3.4", {"12e3",NUMLIT,".",PUNCT,"4",NUMLIT},
             "num, exp with dot")

    checkLex(t, "e", {"e",MAL}, "Just e")
    checkLex(t, "E", {"E",MAL}, "Just E")
    checkLex(t, "e3", {"e",MAL,"3",NUMLIT}, "e3")
    checkLex(t, "E3", {"E",MAL,"3",NUMLIT}, "E3")
    checkLex(t, "e+3", {"e",MAL,"+3",NUMLIT}, "e+3")
    checkLex(t, "E+3", {"E",MAL,"+3",NUMLIT}, "E+3")
    checkLex(t, "1e3", {"1e3",NUMLIT}, "e+3")
    checkLex(t, "123e", {"123",NUMLIT,"e",MAL}, "num e")
    checkLex(t, "123E", {"123",NUMLIT,"E",MAL}, "num E")
    checkLex(t, "123ee", {"123",NUMLIT,"ee",MAL}, "num ee #1")
    checkLex(t, "123Ee", {"123",NUMLIT,"Ee",MAL}, "num ee #2")
    checkLex(t, "123eE", {"123",NUMLIT,"eE",MAL}, "num ee #3")
    checkLex(t, "123EE", {"123",NUMLIT,"EE",MAL}, "num ee #4")
    checkLex(t, "123ee1", {"123",NUMLIT,"ee",MAL,"1",NUMLIT}, "num ee num #1")
    checkLex(t, "123Ee1", {"123",NUMLIT,"Ee",MAL,"1",NUMLIT}, "num ee num #2")
    checkLex(t, "123eE1", {"123",NUMLIT,"eE",MAL,"1",NUMLIT}, "num ee num #3")
    checkLex(t, "123EE1", {"123",NUMLIT,"EE",MAL,"1",NUMLIT}, "num ee num #4")
    checkLex(t, "123e+", {"123",NUMLIT,"e",MAL,"+",OP}, "num e+ #1")
    checkLex(t, "123E+", {"123",NUMLIT,"E",MAL,"+",OP}, "num e+ #2")
    checkLex(t, "123e-", {"123",NUMLIT,"e",MAL,"-",OP}, "num e- #1")
    checkLex(t, "123E-", {"123",NUMLIT,"E",MAL,"-",OP}, "num e- #2")
    checkLex(t, "123e+e7", {"123",NUMLIT,"e",MAL,"+",OP,"e",MAL,"7",NUMLIT},
             "num e+e7")
    checkLex(t, "123e-e7", {"123",NUMLIT,"e",MAL,"-",OP,"e",MAL,"7",NUMLIT},
             "num e-e7")
    checkLex(t, "123e7e", {"123e7",NUMLIT,"e",MAL}, "num e7e")
    checkLex(t, "123e+7e", {"123e+7",NUMLIT,"e",MAL}, "num e+7e")
    checkLex(t, "123e-7e", {"123",NUMLIT,"e",MAL,"-7",NUMLIT,"e",MAL}, "num e-7e")
    checkLex(t, "123f7", {"123",NUMLIT,"f",MAL,"7",NUMLIT}, "num f7 #1")
    checkLex(t, "123F7", {"123",NUMLIT,"F",MAL,"7",NUMLIT}, "num f7 #3")

    checkLex(t, "123 e+7", {"123",NUMLIT,"e",MAL,"+7",NUMLIT},
             "space-separated exp #1")
    checkLex(t, "123 e-7", {"123",NUMLIT,"e",MAL,"-7",NUMLIT},
             "space-separated exp #2")
    checkLex(t, "123e1 2", {"123e1",NUMLIT,"2",NUMLIT},
             "space-separated exp #3")
    checkLex(t, "123end", {"123",NUMLIT,"end",KEY},
             "number end")
    checkLex(t, "1e2e3", {"1e2",NUMLIT,"e",MAL,"3",NUMLIT},
             "number exponent #1")
    checkLex(t, "1e+2e3", {"1e+2",NUMLIT,"e",MAL,"3",NUMLIT},
             "number exponent #2")
    checkLex(t, "1e-2e3", {"1",NUMLIT,"e",MAL,"-2e3",NUMLIT},
             "number exponent #3")

    twostr = "2"
    longexp = twostr:rep(10000)
    checkLex(t, "3e"..longexp, {"3e"..longexp,NUMLIT}, "long exp #1")
    checkLex(t, "3e"..longexp.."-", {"3e"..longexp,NUMLIT,"-",OP},
             "long exp #2")
end


function test_strlit(t)
    io.write("Test Suite: StringLiteral\n")

    checkLex(t, "''", {"''",STRLIT}, "Empty single-quoted str")
    checkLex(t, "\"\"", {"\"\"",STRLIT}, "Empty double-quoted str")
    checkLex(t, "'a'", {"'a'",STRLIT}, "1-char single-quoted str")
    checkLex(t, "\"b\"", {"\"b\"",STRLIT}, "1-char double-quoted str")
    checkLex(t, "'abc def'", {"'abc def'",STRLIT},
             "longer single-quoted str")
    checkLex(t, "\"The quick brown fox.\"",
             {"\"The quick brown fox.\"",STRLIT},
             "longer double-quoted str")
    checkLex(t, "'aa\"bb'", {"'aa\"bb'",STRLIT},
             "single-quoted str with double quote")
    checkLex(t, "\"cc'dd\"", {"\"cc'dd\"",STRLIT},
             "double-quoted str with single quote")
    checkLex(t, "'aabbcc", {"'aabbcc",MAL},
             "partial single-quoted str #1")
    checkLex(t, "'aabbcc\"", {"'aabbcc\"",MAL},
             "partial single-quoted str #2")
    checkLex(t, "\"aabbcc", {"\"aabbcc",MAL},
             "partial double-quoted str #1")
    checkLex(t, "\"aabbcc'", {"\"aabbcc'",MAL},
             "partial double-quoted str #2")
    checkLex(t, "'\"'\"'\"", {"'\"'",STRLIT,"\"'\"",STRLIT},
             "multiple strs")
    checkLex(t, "'#'#'\n'\n'", {"'#'",STRLIT,"'\n'",STRLIT},
             "strs & comments")
    checkLex(t, "\"a\"a\"a\"a\"",
             {"\"a\"",STRLIT,"a",MAL,"\"a\"",STRLIT,"a",MAL,"\"",MAL},
             "strs & identifiers")
    xstr = "x"
    longstr = "'"..xstr:rep(10000).."'"
    checkLex(t, "a"..longstr.."b", {"a",MAL,longstr,STRLIT,"b",MAL},
             "very long str")
end


function test_op(t)
    io.write("Test Suite: Operator\n")

    -- Operator alone
    checkLex(t, "&&", {"&&",OP}, "&& alone")
    checkLex(t, "||", {"||",OP}, "|| alone")
    checkLex(t, "!",  {"!",OP},  "! alone")
    checkLex(t, "==", {"==",OP}, "== alone")
    checkLex(t, "!=", {"!=",OP}, "!= alone")
    checkLex(t, "<",  {"<",OP},  "< alone")
    checkLex(t, "<=", {"<=",OP}, "<= alone")
    checkLex(t, ">",  {">",OP},  "> alone")
    checkLex(t, ">=", {">=",OP}, ">= alone")
    checkLex(t, "+",  {"+",OP},  "+ alone")
    checkLex(t, "-",  {"-",OP},  "- alone")
    checkLex(t, "*",  {"*",OP},  "* alone")
    checkLex(t, "/",  {"/",OP},  "/ alone")
    checkLex(t, "%",  {"%",OP},  "% alone")
    checkLex(t, "[",  {"[",OP},  "[ alone")
    checkLex(t, "]",  {"]",OP},  "] alone")
    checkLex(t, ":",  {":",OP},  ": alone")

    -- Operator followed by digit
    checkLex(t, "&&1", {"&&",OP,"1",NUMLIT}, "&& 1")
    checkLex(t, "||1", {"||",OP,"1",NUMLIT}, "|| 1")
    checkLex(t, "!1",  {"!",OP,"1",NUMLIT},  "! 1")
    checkLex(t, "==1", {"==",OP,"1",NUMLIT}, "== 1")
    checkLex(t, "!=1", {"!=",OP,"1",NUMLIT}, "!= 1")
    checkLex(t, "<1",  {"<",OP,"1",NUMLIT},  "< 1")
    checkLex(t, "<=1", {"<=",OP,"1",NUMLIT}, "<= 1")
    checkLex(t, ">1",  {">",OP,"1",NUMLIT},  "> 1")
    checkLex(t, ">=1", {">=",OP,"1",NUMLIT}, ">= 1")
    checkLex(t, "+1",  {"+1",NUMLIT},  "+ 1")
    checkLex(t, "-1",  {"-1",NUMLIT},  "- 1")
    checkLex(t, "*1",  {"*",OP,"1",NUMLIT},  "* 1")
    checkLex(t, "/1",  {"/",OP,"1",NUMLIT},  "/ 1")
    checkLex(t, "%1",  {"%",OP,"1",NUMLIT},  "% 1")
    checkLex(t, "[1",  {"[",OP,"1",NUMLIT},  "[ 1")
    checkLex(t, "]1",  {"]",OP,"1",NUMLIT},  "] 1")
    checkLex(t, ":1",  {":",OP,"1",NUMLIT},  ": 1")

    -- Operator followed by letter
    checkLex(t, "&&a", {"&&",OP,"a",MAL}, "&& a")
    checkLex(t, "||a", {"||",OP,"a",MAL}, "|| a")
    checkLex(t, "!a",  {"!",OP,"a",MAL},  "! a")
    checkLex(t, "==a", {"==",OP,"a",MAL}, "== a")
    checkLex(t, "!=a", {"!=",OP,"a",MAL}, "!= a")
    checkLex(t, "<a",  {"<",OP,"a",MAL},  "< a")
    checkLex(t, "<=a", {"<=",OP,"a",MAL}, "<= a")
    checkLex(t, ">a",  {">",OP,"a",MAL},  "> a")
    checkLex(t, ">=a", {">=",OP,"a",MAL}, ">= a")
    checkLex(t, "+a",  {"+",OP,"a",MAL},  "+ a")
    checkLex(t, "-a",  {"-",OP,"a",MAL},  "- a")
    checkLex(t, "*a",  {"*",OP,"a",MAL},  "* a")
    checkLex(t, "/a",  {"/",OP,"a",MAL},  "/ a")
    checkLex(t, "%a",  {"%a",VARID},  "% a")
    checkLex(t, "[a",  {"[",OP,"a",MAL},  "[ a")
    checkLex(t, "]a",  {"]",OP,"a",MAL},  "] a")
    checkLex(t, ":a",  {":",OP,"a",MAL},  ": a")

    -- Operator followed by "*"
    checkLex(t, "&&*", {"&&",OP,"*",OP}, "&& *")
    checkLex(t, "||*", {"||",OP,"*",OP}, "|| *")
    checkLex(t, "!*",  {"!",OP,"*",OP},  "! *")
    checkLex(t, "==*", {"==",OP,"*",OP}, "== *")
    checkLex(t, "!=*", {"!=",OP,"*",OP}, "!= *")
    checkLex(t, "<*",  {"<",OP,"*",OP},  "< *")
    checkLex(t, "<=*", {"<=",OP,"*",OP}, "<= *")
    checkLex(t, ">*",  {">",OP,"*",OP},  "> *")
    checkLex(t, ">=*", {">=",OP,"*",OP}, ">= *")
    checkLex(t, "+*",  {"+",OP,"*",OP},  "+ *")
    checkLex(t, "-*",  {"-",OP,"*",OP},  "- *")
    checkLex(t, "**",  {"*",OP,"*",OP},  "* *")
    checkLex(t, "/*",  {"/",OP,"*",OP},  "/ *")
    checkLex(t, "%*",  {"%",OP,"*",OP},  "% *")
    checkLex(t, "[*",  {"[",OP,"*",OP},  "[ *")
    checkLex(t, "]*",  {"]",OP,"*",OP},  "] *")
    checkLex(t, ":*",  {":",OP,"*",OP},  ": *")

    -- Eliminated operators
    checkLex(t, "++", {"+",OP,"+",OP}, "old operator: ++")
    checkLex(t, "++2", {"+",OP,"+2",NUMLIT}, "old operator: ++ digit")
    checkLex(t, "--", {"-",OP,"-",OP}, "old operator: --")
    checkLex(t, "--2", {"-",OP,"-2",NUMLIT}, "old operator: -- digit")
    checkLex(t, ".", {".",PUNCT}, "old operator: .")
    checkLex(t, "=", {"=",PUNCT}, "old operator: =")
    checkLex(t, "+=", {"+",OP,"=",PUNCT}, "old operator: +=")
    checkLex(t, "+==", {"+",OP,"==",OP}, "old operator: += =")
    checkLex(t, "-=", {"-",OP,"=",PUNCT}, "old operator: -=")
    checkLex(t, "-==", {"-",OP,"==",OP}, "old operator: -= =")
    checkLex(t, "*=", {"*",OP,"=",PUNCT}, "old operator: *=")
    checkLex(t, "*==", {"*",OP,"==",OP}, "old operator: *= =")
    checkLex(t, "/=", {"/",OP,"=",PUNCT}, "old operator: *=")
    checkLex(t, "/==", {"/",OP,"==",OP}, "old operator: /= =")

    -- Partial operators
    checkLex(t, "&", {"&",PUNCT}, "partial operator: &")
    checkLex(t, "|", {"|",PUNCT}, "partial operator: |")
    checkLex(t, "=", {"=",PUNCT}, "partial operator: =")

    -- More complex stuff
    checkLex(t, "=====", {"==",OP,"==",OP,"=",PUNCT}, "=====")
    checkLex(t, "=<<==", {"=",PUNCT,"<",OP,"<=",OP,"=",PUNCT}, "=<<==")
    checkLex(t, "**/ ",  {"*",OP,"*",OP,"/",OP}, "**/ ")
    checkLex(t, "& &",   {"&",PUNCT,"&",PUNCT}, "& &")
    checkLex(t, "| |",   {"|",PUNCT,"|",PUNCT}, "| |")
    checkLex(t, "= =",   {"=",PUNCT,"=",PUNCT}, "= =")
    checkLex(t, "--2-",  {"-",OP,"-2",NUMLIT,"-",OP}, "--2-")

    -- Punctuation chars
    checkLex(t, "$(),.;?@\\^_`{}~",
             {"$",PUNCT,"(",PUNCT,")",PUNCT,
              ",",PUNCT,".",PUNCT,";",PUNCT,"?",PUNCT,"@",PUNCT,
              "\\",PUNCT,"^",PUNCT,"_",PUNCT,"`",PUNCT,"{",PUNCT,
              "}",PUNCT,"~",PUNCT},
             "assorted punctuation")
end


function test_illegal(t)
    io.write("Test Suite: Illegal Characters\n")

    checkLex(t, "\001", {"\001",MAL}, "Single illegal character #1")
    checkLex(t, "\031", {"\031",MAL}, "Single illegal character #2")
    checkLex(t, "a\002bcd\003\004ef",
             {"a",MAL,"\002",MAL,"bcd",MAL,"\003",MAL,
              "\004",MAL,"ef",MAL},
             "Various illegal characters")
    checkLex(t, "a#\001\nb", {"a",MAL,"b",MAL},
             "Illegal character in comment")
    checkLex(t, "b'\001'", {"b",MAL,"'\001'",STRLIT},
             "Illegal character in single-quoted string")
    checkLex(t, "c\"\001\"", {"c",MAL,"\"\001\"",STRLIT},
             "Illegal character in double-quoted string")
    checkLex(t, "b'\001", {"b",MAL,"'\001",MAL},
             "Illegal character in single-quoted partial string")
    checkLex(t, "c\"\001", {"c",MAL,"\"\001",MAL},
             "Illegal character in double-quoted partial string")
end


function test_comment(t)
    io.write("Test Suite: Space & Comments\n")

    -- Space
    checkLex(t, " ", {}, "Single space character #1")
    checkLex(t, "\t", {}, "Single space character #2")
    checkLex(t, "\n", {}, "Single space character #3")
    checkLex(t, "\r", {}, "Single space character #4")
    checkLex(t, "\f", {}, "Single space character #5")
    checkLex(t, "ab 12", {"ab",MAL,"12",NUMLIT},
             "Space-separated lexemes #1")
    checkLex(t, "ab\t12", {"ab",MAL,"12",NUMLIT},
             "Space-separated lexemes #2")
    checkLex(t, "ab\n12", {"ab",MAL,"12",NUMLIT},
             "Space-separated lexemes #3")
    checkLex(t, "ab\r12", {"ab",MAL,"12",NUMLIT},
             "Space-separated lexemes #4")
    checkLex(t, "ab\f12", {"ab",MAL,"12",NUMLIT},
             "Space-separated lexemes #5")
    blankstr = " "
    longspace = blankstr:rep(10000)
    checkLex(t, longspace.."abc"..longspace, {"abc",MAL},
             "very long space")

    -- Comments
    checkLex(t, "#abcd\n", {}, "Comment")
    checkLex(t, "12#abcd\nab", {"12",NUMLIT,"ab",MAL},
             "Comment-separated lexemes")
    checkLex(t, "12#abcd", {"12",NUMLIT}, "Unterminated comment #1")
    checkLex(t, "12#abcd#", {"12",NUMLIT}, "Unterminated comment #2")
    checkLex(t, "12#a\n#b\n#c\nab", {"12",NUMLIT,"ab",MAL},
             "Multiple comments #1")
    checkLex(t, "12#a\n  #b\n \n #c\nab", {"12",NUMLIT,"ab",MAL},
             "Multiple comments #2")
    checkLex(t, "12#a\n=#b\n.#c\nab",
             {"12",NUMLIT,"=",PUNCT,".",PUNCT,"ab",MAL},
             "Multiple comments #3")
    checkLex(t, "a##\nb", {"a",MAL,"b",MAL}, "Comment with # #1")
    checkLex(t, "a##b", {"a",MAL}, "Comment with # #2")
    checkLex(t, "a##b\n\nc", {"a",MAL,"c",MAL}, "Comment with # #3")
    xstr = "x"
    longcmt = "#"..xstr:rep(10000).."\n"
    checkLex(t, "a"..longcmt.."b", {"a",MAL,"b",MAL}, "very long comment")
end


function test_preferop(t)
    io.write("Test Suite: Using preferOp\n")

    local function po_false(n,s,c) return false end
    local function po_true(n,s,c) return true end
    local function po_two(n,s,c) return n==2 or n==5 end
    local function po_val(n,s,c)
        return c == VARID
          or c == NUMLIT
          or s == "]"
          or s == ")"
          or s == "true"
          or s == "false"
    end

    checkLex(t, "-1-1-1-1", {"-1",NUMLIT,"-1",NUMLIT,"-1",NUMLIT,
                             "-1",NUMLIT},
             "preferOp never called #1", po_false)
    checkLex(t, "+1+1+1+1", {"+1",NUMLIT,"+1",NUMLIT,"+1",NUMLIT,
                             "+1",NUMLIT},
             "preferOp never called #2", po_false)
    checkLex(t, "%a%a%a%a", {"%a",VARID,"%a",VARID,"%a",VARID,
                             "%a",VARID},
             "preferOp never called #3", po_false)
    checkLex(t, "-1-1-1-1", {"-",OP,"1",NUMLIT,"-",OP,"1",NUMLIT,"-",OP,
                             "1",NUMLIT,"-",OP,"1",NUMLIT},
             "preferOp always called #1", po_true)
    checkLex(t, "+1+1+1+1", {"+",OP,"1",NUMLIT,"+",OP,"1",NUMLIT,"+",OP,
                             "1",NUMLIT,"+",OP,"1",NUMLIT},
             "preferOp always called #2", po_true)
    checkLex(t, "%a%a%a%a", {"%",OP,"a",MAL,"%",OP,"a",MAL,"%",OP,
                             "a",MAL,"%",OP,"a",MAL},
             "preferOp always called #3", po_true)
    checkLex(t, "&a&a&a&a", {"&a",SUBID,"&a",SUBID,"&a",SUBID,"&a",SUBID},
             "preferOp always called #4", po_true)
    checkLex(t, ".1.1.1.1", {".",PUNCT,"1",NUMLIT,".",PUNCT,"1",NUMLIT,
                             ".",PUNCT,"1",NUMLIT,".",PUNCT,"1",NUMLIT},
             "preferOp always called #5", po_true)
    checkLex(t, "!=!=!=!=", {"!=",OP,"!=",OP,"!=",OP,"!=",OP},
             "preferOp always called #6", po_true)
    checkLex(t, "-1-1-1-1", {"-1",NUMLIT,"-",OP,"1",NUMLIT,"-1",NUMLIT,
                             "-",OP,"1",NUMLIT},
             "preferOp called on lexemes 2 & 5, #1", po_two)
    checkLex(t, "%a%a%a%a", {"%a",VARID,"%",OP,"a",MAL,"%a",VARID,
                             "%",OP,"a",MAL},
             "preferOp called on lexemes 2 & 5, #2", po_two)
    checkLex(t, "-1-1-1-1", {"-1",NUMLIT,"-",OP,"1",NUMLIT,"-",OP,
                             "1",NUMLIT,"-",OP,"1",NUMLIT},
             "preferOp called after values", po_val)
    checkLex(t, "%a%a%a%a", {"%a",VARID,"%",OP,"a",MAL,"%a",VARID,
                             "%",OP,"a",MAL},
             "preferOp called after values", po_val)
end


function test_program(t)
    io.write("Test Suite: Complete Programs\n")

    local function po_val(n,s,c)
        return c == VARID
          or c == NUMLIT
          or s == "]"
          or s == ")"
          or s == "true"
          or s == "false"
    end

    -- Short program, little whitespace
    checkLex(t, "set%a_1[0]:1"..
                "set%a_1[%a_1[0]]:%a_1[0]+2"..
                "set%_b2b:%a_1[0]+3"..
                "if%_b2b==6print'good'cr "..
                "elseif%_b2b>6print'too high'cr "..
                "else print'too low'cr "..
                "end",
             {"set",KEY,"%a_1",VARID,"[",OP,"0",NUMLIT,"]",OP,":",OP,
                "1",NUMLIT,
              "set",KEY,"%a_1",VARID,"[",OP,"%a_1",VARID,"[",OP,
                "0",NUMLIT,"]",OP,"]",OP,":",OP,"%a_1",VARID,"[",OP,
                "0",NUMLIT,"]",OP,"+",OP,"2",NUMLIT,
              "set",KEY,"%_b2b",VARID,":",OP,"%a_1",VARID,"[",OP,
                "0",NUMLIT,"]",OP,"+",OP,"3",NUMLIT,
              "if",KEY,"%_b2b",VARID,"==",OP,"6",NUMLIT,"print",KEY,
                "'good'",STRLIT,"cr",KEY,
              "elseif",KEY,"%_b2b",VARID,">",OP,"6",NUMLIT,"print",KEY,
               "'too high'",STRLIT,"cr",KEY,
              "else",KEY,"print",KEY,"'too low'",STRLIT,"cr",KEY,
              "end",KEY},
              "Short program, little whitespace", po_val)

    -- Program from slides
    checkLex(t, "# Subroutine &fibo\n"..
                "# Given %k, set %fibk to F(%k),\n"..
                "sub &fibo\n"..
                "    set %a: 0  # Consecutive Fibos\n"..
                "    set %b: 1\n"..
                "    set %i: 0  # Loop counter\n"..
                "    while %i < %k\n"..
                "        set %c: %a+%b  # Advance\n"..
                "        set %a: %b\n"..
                "        set %b: %c\n"..
                "        set %i: %i+1   # ++counter\n"..
                "    end\n"..
                "    set %fibk: %a  # Result\n"..
                "end\n"..
                "\n"..
                "#  Get number of Fibos to output\n"..
                "print \"How many Fibos to print: \"\n"..
                "input %n\n"..
                "cr cr\n"..
                "\n"..
                "# print requested number of Fibos\n"..
                "set %j: 0  # Loop counter\n"..
                "while %j < %n\n"..
                "    set %k: %j\n"..
                "    call &fibo\n"..
                "    print \"  \"\n"..
                "    print %fibk cr\n"..
                "end\n",
             {"sub",KEY,"&fibo",SUBID,
              "set",KEY,"%a",VARID,":",OP,"0",NUMLIT,
              "set",KEY,"%b",VARID,":",OP,"1",NUMLIT,
              "set",KEY,"%i",VARID,":",OP,"0",NUMLIT,
              "while",KEY,"%i",VARID,"<",OP,"%k",VARID,
              "set",KEY,"%c",VARID,":",OP,"%a",VARID,"+",OP,"%b",VARID,
              "set",KEY,"%a",VARID,":",OP,"%b",VARID,
              "set",KEY,"%b",VARID,":",OP,"%c",VARID,
              "set",KEY,"%i",VARID,":",OP,"%i",VARID,"+",OP,"1",NUMLIT,
              "end",KEY,
              "set",KEY,"%fibk",VARID,":",OP,"%a",VARID,
              "end",KEY,
              "print",KEY,"\"How many Fibos to print: \"",STRLIT,
              "input",KEY,"%n",VARID,
              "cr",KEY,"cr",KEY,
              "set",KEY,"%j",VARID,":",OP,"0",NUMLIT,
              "while",KEY,"%j",VARID,"<",OP,"%n",VARID,
              "set",KEY,"%k",VARID,":",OP,"%j",VARID,
              "call",KEY,"&fibo",SUBID,
              "print",KEY,"\"  \"",STRLIT,
              "print",KEY,"%fibk",VARID,"cr",KEY,
              "end",KEY},
              "Program from slides", po_val)

    -- Program with other lexemes, little whitespace
    checkLex(t, "if!(true&&false||1)<2<=3>4>=5-6*7/8%9"..
                "set%abcdefg_12345:00000"..
                "print+123e45--987E+65+%abcdefg_12345 "..
                "end",
             {"if",KEY,"!",OP,"(",PUNCT,"true",KEY,"&&",OP,"false",KEY,
                "||",OP,"1",NUMLIT,")",PUNCT,"<",OP,"2",NUMLIT,"<=",OP,
                "3",NUMLIT,">",OP,"4",NUMLIT,">=",OP,"5",NUMLIT,"-",OP,
                "6",NUMLIT,"*",OP,"7",NUMLIT,"/",OP,"8",NUMLIT,"%",OP,
                "9",NUMLIT,
              "set",KEY,"%abcdefg_12345",VARID,":",OP,"00000",NUMLIT,
              "print",KEY,"+123e45",NUMLIT,"-",OP,"-987E+65",NUMLIT,
                "+",OP,"%abcdefg_12345",VARID,
              "end",KEY},
              "Program with other lexemes, little whitespace", po_val)
end


function test_lexit(t)
    io.write("TEST SUITES FOR MODULE lexit\n")
    test_categories(t)
    test_key(t)
    test_varid(t)
    test_subid(t)
    test_numlit(t)
    test_strlit(t)
    test_op(t)
    test_illegal(t)
    test_comment(t)
    test_preferop(t)
    test_program(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_lexit(tester)
io.write("\n")
if tester:allPassed() then
    io.write("All tests successful\n")
else
    io.write("Tests ********** UNSUCCESSFUL **********\n")
    io.write("\n")
    io.write("**************************************************\n")
    io.write("* This test program is configured to execute all *\n")
    io.write("* tests, reporting success/failure for each. To  *\n")
    io.write("* make it exit after the first failing test, set *\n")
    io.write("* variable                                       *\n")
    io.write("*                                                *\n")
    io.write("*   EXIT_ON_FIRST_FAILURE                        *\n")
    io.write("*                                                *\n")
    io.write("* to true, near the start of the test program.   *\n")
    io.write("**************************************************\n")
end

-- Wait for user
io.write("\nPress ENTER to quit ")
io.read("*l")

