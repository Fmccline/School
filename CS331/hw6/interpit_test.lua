#!/usr/bin/env lua
-- interpit_test.lua
-- Glenn G. Chappell
-- 2 Apr 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- Test Program for Module interpit
-- Used in Assignment 6, Exercise B

interpit = require "interpit"  -- Import parseit module


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


-- numKeys
-- Given a table, return the number of keys in it.
function numKeys(tab)
    local keycount = 0
    for k, v in pairs(tab) do
        keycount = keycount + 1
    end
    return keycount
end


-- tableEq
-- Compare equality of two tables.
-- Handles table values recursively. Does "==" on non-table values.
-- Uses function numKeys.
function tableEq(t1, t2)
    -- Both params are tables?
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false
    end

    if numKeys(t1) ~= numKeys(t2) then
        return false
    end

    for k, t1v in pairs(t1) do
        local t2v = t2[k]
        if type(t1v) == "table" and type(t2v) == "table" then
            if not tableEq(t1v, t2v) then
                return false
            end
        else
            if t1v ~= t2v then
                return false
            end
        end
    end

    return true
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


-- Symbolic Constants for AST
-- Names differ from those in assignment, to avoid interference.
local STMTxLIST   = 1
local CRxSTMT     = 2
local PRINTxSTMT  = 3
local INPUTxSTMT  = 4
local SETxSTMT    = 5
local SUBxSTMT    = 6
local CALLxSTMT   = 7
local IFxSTMT     = 8
local WHILExSTMT  = 9
local BINxOP      = 10
local UNxOP       = 11
local NUMLITxVAL  = 12
local STRLITxVAL  = 13
local BOOLLITxVAL = 14
local VARIDxVAL   = 15
local ARRAYxREF   = 16


-- deepcopy
-- Returns deep copy of given value.
-- From http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- isState
-- Return true if given value is properly formatted Kanchil state table,
-- false otherwise.
function isState(tab)
    -- Is table?
    if type(tab) ~= "table" then
        return false
    end

    -- Has exactly 3 keys?
    if numKeys(tab) ~= 3 then
        return false
    end

    -- Has s, a keys?
    if tab.v == nil or tab.a == nil or tab.s == nil then
        return false
    end

    -- s, a keys are tables?
    if type(tab.v) ~= "table"
      or type(tab.a) ~= "table"
      or type(tab.s) ~= "table" then
        return false
    end

    -- All items in v are string:number
    -- String begins with "%"
    for k, v in pairs(tab.v) do
        if type(k) ~= "string" or type(v) ~= "number" then
            return false
        end
        if k:sub(1,1) ~= "%" then
            return false
        end
    end

    -- All items in a are string:table
    -- String begins with "%"
    -- All items in values in a are number:number
    for k, v in pairs(tab.a) do
        if type(k) ~= "string" or type(v) ~= "table" then
            return false
        end
        if k:sub(1,1) ~= "%" then
            return false
        end
        for kk, vv in pairs(v) do
            if type(kk) ~= "number" or type(vv) ~= "number" then
                return false
            end
        end
    end

    -- All items in s are string:table
    -- String begins with "&"
    for k, v in pairs(tab.s) do
        if type(k) ~= "string" or type(v) ~= "table" then
            return false
        end
        if k:sub(1,1) ~= "&" then
            return false
        end
    end

    return true
end


-- checkInterp
-- Given tester object, AST, array of input strings, input state, array
-- of expected output strings, expected output state, and string giving
-- the name of the test. Calls interpit.interp and checks output strings
-- & state. Prints result. If test fails and EXIT_ON_FIRST_FAILURE is
-- true, then print detailed results and exit program.
function checkInterp(t, ast,
                     input, statein,
                     expoutput, expstateout,
                     testName)
    -- Error flags
    local err_incallparam = false
    local err_outcallnil = false
    local err_outcallnonstr = false

    local incount = 0
    local function incall(param)
        if param ~= nil then
            err_incallparam = true
        end
        incount = incount + 1
        if incount <= #input then
            return input[incount]
        else
            return ""
        end
    end

    local output = {}
    local function outcall(str)
        if type(str) == "string" then
            table.insert(output, str)
        elseif str == nil then
            err_outcallnil = true
            table.insert(output, "")
        else
            err_outcallnonstr = true
            table.insert(output, "")
        end
    end

    local stateout = interpit.interp(ast, statein, incall, outcall)

    local pass = true
    local msg = ""

    if incount > #input then
        pass = false
        msg = msg .. "Too many calls to incall\n"
    elseif incount < #input then
        pass = false
        msg = msg .. "Too few calls to incall\n"
    end

    if err_incallparam then
        pass = false
        msg = msg .. "incall called with parameter\n"
    end

    if #output > #expoutput then
        pass = false
        msg = msg .. "Too many calls to outcall\n"
    elseif #output < #expoutput then
        pass = false
        msg = msg .. "Too few calls to outcall\n"
    end

    if err_outcallnil then
        pass = false
        msg = msg .. "outcall called with nil or missing parameter\n"
    end
    if err_outcallnonstr then
        pass = false
        msg = msg .. "outcall called with non-string parameter\n"
    end

    if not tableEq(output, expoutput) then
        pass = false
        msg = msg .. "Output incorrect\n"
    end

    if isState(stateout) then
        if not tableEq(stateout, expstateout) then
            pass = false
            msg = msg .. "Returned state is incorrect\n"
        end
    else
        pass = false
        msg = msg .. "Returned state is not a Kanchil state\n"
    end

    t:test(pass, testName)
    if pass or not EXIT_ON_FIRST_FAILURE then
        return
    end

    io.write("\n")
    io.write(msg)
    io.write("\n")
    fail_exit()
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_pre_written(t)
    io.write("Test Suite: programs that work with pre-written funcs\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Empty program
    ast = {STMTxLIST}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Empty program")

    -- Cr
    ast = {STMTxLIST, {CRxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "cr")

    -- Two cr-statements
    ast = {STMTxLIST, {CRxSTMT}, {CRxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\n", "\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Two cr-statements")

    -- Print: empty string
    ast = {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "''"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {""}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: empty string")

    -- Print: string, single-quoted
    ast = {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string, single-quoted")

    -- Print: string, double-quoted
    ast = {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, '"def"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"def"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string, double-quoted")

    -- Print: string + cr
    ast = {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'abc'"}}, {CRxSTMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc", "\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string + cr")

    -- Sub, no call
    ast = {STMTxLIST, {SUBxSTMT, "&x",
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, s={["&x"]={STMTxLIST,
      {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Sub, no call")

    -- Call, no sub
    ast = {STMTxLIST, {CALLxSTMT, "&x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Call, no sub")

    -- Sub with call (wrong name)
    ast = {STMTxLIST, {SUBxSTMT, "&x",
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}},
      {CALLxSTMT, "&y"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, s={["&x"]={STMTxLIST,
      {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Sub with call (wrong name)")

    -- Sub with call (right name)
    ast = {STMTxLIST, {SUBxSTMT, "&x",
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}},
      {CALLxSTMT, "&x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc"}
    expstateout = {v={}, a={}, s={["&x"]={STMTxLIST,
      {PRINTxSTMT, {STRLITxVAL, "'abc'"}}}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Sub with call (right name)")

    -- Sub defs sub, no call
    ast = {STMTxLIST, {SUBxSTMT, "&x",
      {STMTxLIST, {SUBxSTMT, "&y", {STMTxLIST}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, s={["&x"]={STMTxLIST,
      {SUBxSTMT, "&y", {STMTxLIST}}}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Sub defs sub, no call")

    -- Sub defs sub, with call
    ast = {STMTxLIST, {SUBxSTMT, "&x",
      {STMTxLIST, {SUBxSTMT, "&y", {STMTxLIST}}}},
      {CALLxSTMT, "&x"}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={}, s={["&x"]={STMTxLIST,
      {SUBxSTMT, "&y", {STMTxLIST}}},
      ["&y"]={STMTxLIST}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Sub defs sub, with call")
end


function test_simple(t)
    io.write("Test Suite: simple programs\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Simple set
    ast = {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%a"},
      {NUMLITxVAL, "42"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%a"]=42}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple set")

    -- Simple if #1
    ast = {STMTxLIST, {IFxSTMT, {NUMLITxVAL, "0"}, {STMTxLIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple if #1")

    -- Simple if #2
    ast = {STMTxLIST, {IFxSTMT, {NUMLITxVAL, "4"}, {STMTxLIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple if #2")

    -- Simple while
    ast = {STMTxLIST, {WHILExSTMT, {NUMLITxVAL, "0"}, {STMTxLIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple while")

   -- Simple input
    ast = {STMTxLIST, {INPUTxSTMT, {VARIDxVAL, "%b"}}}
    input = {"37"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%b"]=37}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple input")

    -- Print: number
    ast = {STMTxLIST, {PRINTxSTMT, {NUMLITxVAL, "28"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"28"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: number")

    -- Print: undefined variable
    ast = {STMTxLIST, {PRINTxSTMT, {VARIDxVAL, "%d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: undefined variable")

    -- Set + print: variable
    ast = {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%c"}, {NUMLITxVAL, "57"}},
      {PRINTxSTMT, {VARIDxVAL, "%c"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"57"}
    expstateout = {v={["%c"]=57}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set + print: variable")

    -- Set + print: other variable
    ast = {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%c"}, {NUMLITxVAL, "57"}},
      {PRINTxSTMT, {VARIDxVAL, "%d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {v={["%c"]=57}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set + print: variable")

    -- Input + print: variable
    ast = {STMTxLIST, {INPUTxSTMT, {VARIDxVAL, "%c"}},
      {PRINTxSTMT, {VARIDxVAL, "%c"}}}
    input = {"12"}
    statein = deepcopy(emptystate)
    expoutput = {"12"}
    expstateout = {v={["%c"]=12}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Input + print: variable")

    -- Input + print: other variable
    ast = {STMTxLIST, {INPUTxSTMT, {VARIDxVAL, "%c"}},
      {PRINTxSTMT, {VARIDxVAL, "%d"}}}
    input = {"24"}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {v={["%c"]=24}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Input + print: other variable")

    -- Set array
    ast = {STMTxLIST, {SETxSTMT,
      {ARRAYxREF, {VARIDxVAL, "%a"}, {NUMLITxVAL, "2"}},
      {NUMLITxVAL, "7"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={}, a={["%a"]={[2]=7}}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set array")
end


function test_state(t)
    io.write("Test Suite: modified initial state\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Empty program
    ast = {STMTxLIST}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - empty program")

    -- Set simple var #1
    ast = {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%a"}, {NUMLITxVAL, "3"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = {v={["%a"]=3,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set simple var #1")

    -- Set simple var #2
    ast = {STMTxLIST, {SETxSTMT, {VARIDxVAL, "%c"}, {NUMLITxVAL, "3"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = {v={["%a"]=1,["%b"]=2,["%c"]=3},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set simple var #2")

    -- Set array #1
    ast = {STMTxLIST, {SETxSTMT,
      {ARRAYxREF, {VARIDxVAL, "%b"}, {NUMLITxVAL, "2"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=9,[4]=3}}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #1")

    -- Set array #2
    ast = {STMTxLIST, {SETxSTMT,
      {ARRAYxREF, {VARIDxVAL, "%b"}, {NUMLITxVAL, "-5"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3,[-5]=9}}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #2")

    -- Set array #3
    ast = {STMTxLIST, {SETxSTMT,
      {ARRAYxREF, {VARIDxVAL, "%c"}, {NUMLITxVAL, "0"}},
      {NUMLITxVAL, "9"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {}
    expstateout = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3},["%c"]={[0]=9}},
      s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #3")

    -- Print simple var #1
    ast = {STMTxLIST, {PRINTxSTMT, {VARIDxVAL, "%a"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print simple var #1")

    -- Print simple var #2
    ast = {STMTxLIST, {PRINTxSTMT, {VARIDxVAL, "%c"}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print simple var #2")

    -- Print array #1
    ast = {STMTxLIST, {PRINTxSTMT, {ARRAYxREF, {VARIDxVAL, "%a"},
      {NUMLITxVAL, "4"}}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #1")

    -- Print array #2
    ast = {STMTxLIST, {PRINTxSTMT, {ARRAYxREF, {VARIDxVAL, "%a"},
      {NUMLITxVAL, "8"}}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #2")

    -- Print array #3
    ast = {STMTxLIST, {PRINTxSTMT, {ARRAYxREF, {VARIDxVAL, "%c"},
      {NUMLITxVAL, "8"}}}}
    input = {}
    statein = {v={["%a"]=1,["%b"]=2},
      a={["%a"]={[2]=3,[4]=7},["%b"]={[2]=7,[4]=3}}, s={}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #3")

    -- Print-set-print-input-print
    ast = {STMTxLIST,
      {PRINTxSTMT, {VARIDxVAL, "%abc"}},
      {SETxSTMT, {VARIDxVAL, "%abc"}, {NUMLITxVAL, "55"}},
      {PRINTxSTMT, {VARIDxVAL, "%abc"}},
      {INPUTxSTMT, {VARIDxVAL, "%abc"}},
      {PRINTxSTMT, {VARIDxVAL, "%abc"}}}
    input = {"66"}
    statein = {v={["%abc"]=44}, a={}, s={}}
    expoutput = {"44", "55", "66"}
    expstateout = {v={["%abc"]=66}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print-set-print-input-print")
end


function test_expr(t)
    io.write("Test Suite: expressions\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Print unary +
    ast = {STMTxLIST, {PRINTxSTMT,
      {{UNxOP, "+"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"5"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print unary +")

    -- Print unary -
    ast = {STMTxLIST, {PRINTxSTMT,
      {{UNxOP, "-"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-5"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print unary -")

    -- Print ! #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{UNxOP, "!"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print ! #1")

    -- Print ! #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{UNxOP, "!"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print ! #2")

    -- Print binary +
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "+"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print binary +")

    -- Print binary -
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "-"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"3"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print binary -")

    -- Print *
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "*"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"10"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print *")

    -- Print /
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "/"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"2"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print /")

    -- Print / (div by zero)
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "/"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print / (div by zero)")

    -- Print %
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "%"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print %")

    -- Print % (div by zero)
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "%"}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print % (div by zero)")

    -- Print == #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "=="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print == #1")

    -- Print == #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "=="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print == #2")

    -- Print != #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "!="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print != #1")

    -- Print != #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "!="}, {NUMLITxVAL, "5"}, {NUMLITxVAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print != #2")

    -- Print < #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #1")

    -- Print < #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #2")

    -- Print < #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<"}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #3")

    -- Print <= #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #1")

    -- Print <= #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #2")

    -- Print <= #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "<="}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #3")

    -- Print > #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #1")

    -- Print > #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #2")

    -- Print > #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">"}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #3")

    -- Print >= #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "1"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #1")

    -- Print >= #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #2")

    -- Print >= #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, ">="}, {NUMLITxVAL, "3"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #3")

    -- Print && #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print && #1")

    -- Print && #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print && #2")

    -- Print && #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print && #3")

    -- Print && #4
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "&&"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print && #4")

    -- Print || #1
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print || #1")

    -- Print || #2
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "2"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print || #2")

    -- Print || #3
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print || #3")

    -- Print || #4
    ast = {STMTxLIST, {PRINTxSTMT,
      {{BINxOP, "||"}, {NUMLITxVAL, "0"}, {NUMLITxVAL, "0"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print || #4")

    -- Longer expression
    ast =
      {STMTxLIST,
        {PRINTxSTMT,
          {{UNxOP, "-"},
            {{BINxOP, "-"},
              {{BINxOP, "=="}, {VARIDxVAL, "%x"}, {NUMLITxVAL, "3"}},
              {{BINxOP, "*"},
                {NUMLITxVAL, "9"},
                {{UNxOP, "+"}, {VARIDxVAL, "%y"}}
              }
            }
          }
        }
      }
    input = {}
    statein = {v={["%x"]=3, ["%y"]=5}, a={}, s={}}
    expoutput = {"44"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Longer expression")
end


function test_intconv(t)
    io.write("Test Suite: integer conversion\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Numeric literal #1
    ast =
      {STMTxLIST,
        {SETxSTMT, {VARIDxVAL, "%n"}, {NUMLITxVAL, "5.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%n"]=5}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #1")

    -- Numeric literal #2
    ast =
      {STMTxLIST,
        {SETxSTMT, {VARIDxVAL, "%n"}, {NUMLITxVAL, "-7.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%n"]=-7}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #2")

    -- Numeric literal #3
    ast =
      {STMTxLIST,
        {SETxSTMT, {VARIDxVAL, "%n"}, {NUMLITxVAL, "5.74e1"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%n"]=57}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #3")

    -- Input
    ast =
      {STMTxLIST,
        {INPUTxSTMT, {VARIDxVAL, "%n"}}
      }
    input = {"2.9"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {v={["%n"]=2}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - input")

    -- Division + multiplication #1
    ast =
      {STMTxLIST,
        {PRINTxSTMT,
          {{BINxOP, "*"},
            {{BINxOP, "/"}, {NUMLITxVAL, "10"}, {NUMLITxVAL, "3"}},
            {NUMLITxVAL, "3"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"9"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - division + multiplication #1")

    -- Division + multiplication #2
    ast =
      {STMTxLIST,
        {PRINTxSTMT,
          {{BINxOP, "*"},
            {{BINxOP, "/"}, {NUMLITxVAL, "-3"}, {NUMLITxVAL, "2"}},
            {NUMLITxVAL, "2"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-2"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - division + multiplication #2")
end


function test_if(t)
    io.write("Test Suite: if-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- If #1
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "4"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If #1")

    -- If #2
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If #1")

    -- If-else #1
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "5"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-else #1")

    -- If-else #2
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-else #2")

    -- If-elseif #1
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "6"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "7"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #1")

    -- If-elseif #2
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "7"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #2")

    -- If-elseif #3
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #3")

    -- If-elseif-else #1
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "6"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "7"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #1")

    -- If-elseif-else #2
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "7"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #2")

    -- If-elseif-else #3
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #3")

    -- If-elseif*-else #1
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "8"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
      {NUMLITxVAL, "9"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'e'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #1")

    -- If-elseif*-else #2
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
      {NUMLITxVAL, "9"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'e'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #2")

    -- If-elseif*-else #3
    ast = {STMTxLIST, {IFxSTMT,
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}},
      {NUMLITxVAL, "0"},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'e'"}}},
      {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"f"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #3")

    -- Nested if-else #1
    ast =
      {STMTxLIST,
        {IFxSTMT,
          {NUMLITxVAL, "1"},
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}
            }
          },
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #1")

    -- Nested if-else #2
    ast =
      {STMTxLIST,
        {IFxSTMT,
          {NUMLITxVAL, "1"},
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}
            }
          },
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #2")

    -- Nested if-else #3
    ast =
      {STMTxLIST,
        {IFxSTMT,
          {NUMLITxVAL, "0"},
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}
            }
          },
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "1"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #3")

    -- Nested if-else #4
    ast =
      {STMTxLIST,
        {IFxSTMT,
          {NUMLITxVAL, "0"},
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'a'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'b'"}}}
            }
          },
          {STMTxLIST,
            {IFxSTMT,
              {NUMLITxVAL, "0"},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'c'"}}},
              {STMTxLIST, {PRINTxSTMT, {STRLITxVAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #4")
end


function test_while(t)
    io.write("Test Suite: while-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- While loop - counted
    ast =
      {STMTxLIST,
        {SETxSTMT, {VARIDxVAL, "%i"}, {NUMLITxVAL, "0"}},
        {WHILExSTMT,
          {{BINxOP, "<"}, {VARIDxVAL, "%i"}, {NUMLITxVAL, "7"}},
          {STMTxLIST,
            {PRINTxSTMT,
              {{BINxOP, "*"}, {VARIDxVAL, "%i"}, {VARIDxVAL, "%i"}}
            },
            {SETxSTMT,
              {VARIDxVAL, "%i"},
              {{BINxOP, "+"}, {VARIDxVAL, "%i"}, {NUMLITxVAL, "1"}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0", "1", "4", "9", "16", "25", "36"}
    expstateout = {v={["%i"]=7},a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "While loop - counted")

    -- While loop - input with sentinel
    ast =
      {STMTxLIST,
        {SETxSTMT, {VARIDxVAL, "%notdone"}, {NUMLITxVAL, "1"}},
        {WHILExSTMT,
          {VARIDxVAL, "%notdone"},
          {STMTxLIST,
            {INPUTxSTMT, {VARIDxVAL, "%n"}},
            {IFxSTMT,
              {{BINxOP, "=="}, {VARIDxVAL, "%n"}, {NUMLITxVAL, "99"}},
              {STMTxLIST,
                {SETxSTMT, {VARIDxVAL, "%notdone"}, {NUMLITxVAL, "0"}}
              },
              {STMTxLIST,
                {PRINTxSTMT, {VARIDxVAL, "%n"}},
                {CRxSTMT}
              }
            }
          }
        },
        {PRINTxSTMT, {STRLITxVAL, "'Bye!'"}},
        {CRxSTMT}
      }
    input = {"1", "8", "-17", "13.5", "99"}
    statein = deepcopy(emptystate)
    expoutput = {"1", "\n", "8", "\n", "-17", "\n", "13", "\n", "Bye!", "\n"}
    expstateout = {v={["%notdone"]=0, ["%n"]=99}, a={}, s={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "While loop - input with sentinel")
end


function test_sub(t)
    io.write("Test Suite: sub-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {v={}, a={}, s={}}

    -- Recursion
    ast =
      {STMTxLIST,
        {SUBxSTMT, "&x",
          {STMTxLIST,
            {PRINTxSTMT, {VARIDxVAL, "%c"}},
            {SETxSTMT,
              {VARIDxVAL, "%c"},
              {{BINxOP, "-"}, {VARIDxVAL, "%c"}, {NUMLITxVAL, "1"}}
            },
            {IFxSTMT,
              {{BINxOP, ">"}, {VARIDxVAL, "%c"}, {NUMLITxVAL, "0"}},
              {STMTxLIST, {CALLxSTMT, "&x"}}
            }
          }
        },
        {SETxSTMT, {VARIDxVAL, "%c"}, {NUMLITxVAL, "3"}},
        {CALLxSTMT, "&x"}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"3", "2", "1"}
    expstateout = {v={["%c"]=0}, a={}, s={["&x"]=
      {STMTxLIST, {PRINTxSTMT, {VARIDxVAL, "%c"}},
      {SETxSTMT, {VARIDxVAL, "%c"},
      {{BINxOP, "-"}, {VARIDxVAL, "%c"}, {NUMLITxVAL, "1"}}},
      {IFxSTMT, {{BINxOP, ">"}, {VARIDxVAL, "%c"}, {NUMLITxVAL, "0"}},
      {STMTxLIST, {CALLxSTMT, "&x"}}}}
    }}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Recursion")
end


function test_interpit(t)
    io.write("TEST SUITES FOR MODULE parseit\n")
    test_pre_written(t)
    test_simple(t)
    test_state(t)
    test_expr(t)
    test_intconv(t)
    test_if(t)
    test_while(t)
    test_sub(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_interpit(tester)
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

