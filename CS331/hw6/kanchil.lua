#!/usr/bin/env lua
-- kanchil.lua
-- Glenn G. Chappell
-- 27 Mar 2017
--
-- For CS F331 / CSCE A331 Spring 2017
-- REPL/Shell for the Kanchil Programming Language
-- Requires lexit.lua, parseit.lua, interpit.lua


parseit = require "parseit"
interpit = require "interpit"


-- ***** Variables *****


local kanchilstate = { v={}, a={}, s={} }  -- Kanchil variable values


-- ***** Utility Functions *****


-- We define these functions so that we can pass them as parameters.


-- inputLine
-- Input a line of text from standard input and return it in string
-- form, with no trailing newline.
function inputLine()
    return io.read("*l")
end


-- outputString
-- Output the given string to standard output, with no added newline.
function outputString(s)
    io.write(s)
end


-- ***** Functions for Kanchil Interpreter *****


-- runKanchil
-- Given a string, attempt to treat it as source code for a Kanchil
-- program, and execute it. I/O uses standard input & output.
-- Parameters:
--   program  - Kanchil source code
--   state    - Values of Kanchil variables as in interpit.interp.
-- Returns three values:
--   good     - true if program parsed successfully; false otherwise.
--   done     - true if parse reached end of program; false otherwise.
--   newstate - If good, done are both true, then new value of state,
--              updated with revised values of variables. Otherwise,
--              same as passed value of state.
function runKanchil(program, state)
    local good, done, ast = parseit.parse(program)
    local newstate
    if good and done then
        newstate = interpit.interp(ast, state, inputLine, outputString)
    else
        newstate = state
    end
    return good, done, newstate
end


-- isKanchilSourceFilename
-- Given string, return true if it looks like the name of a Kanchil
-- source file: no whitespace, ends with ".kch", and has something
-- before the ".". Otherwise, return false.
function isKanchilSourceFilename(s)
    if s:len() < 5 then
        return false
    end
    if s:sub(s:len()-3,s:len()) ~= ".kch" then
        return false
    end
    for i = 1, s:len() do
        local c = s:sub(i,i)
        if c == " " or c == "\t" or c == "\n" or c == "\r"
          or c == "\f" then
            return false
        end
    end
    return true
end


-- runFile
-- Given filename, attempt to read source for a Kanchil program from it,
-- and execute the program.
function runFile(fname)
    function readable(fname)
        local f = io.open(fname, "r")
        if f ~= nil then
            f:close()
            return true
        else
            return false
        end
    end

    local good, done

    if not readable(fname) then
        io.write("*** ERROR - ")
        io.write("Kanchil source file not readable: ")
        io.write(fname.."\n")
        return
    end
    local source = ""
    for line in io.lines(fname) do
        source = source .. line .. "\n"
    end
    good, done, kanchilstate = runKanchil(source, kanchilstate)
    if not good then
        io.write("*** ERROR - ")
        io.write("Syntax error in Kanchil source file: ")
        io.write(fname.."\n")
    elseif not done then
        io.write("*** ERROR - ")
        io.write("Extra characters at end of Kanchil source file: ")
        io.write(fname.."\n")
    end
    io.write("\n")
    io.write("Press ENTER to quit ")
    io.read("*l")
end


-- repl
-- Kanchil REPL. Prompt & get a line. If it is blank, then exit. If it
-- looks like the filename of a Kanchil source file, then get Kanchil
-- source from it, execute, and exit. Otherwise, treat line as Kanchil
-- program, and attempt to execute it. If it looks like an incomplete
-- Kanchil program, then keep inputting, and continue to attempt to
-- execute. REPEAT.
function repl()
    local good, done
    local source = ""

    io.write("Type Kanchil source filename (---.kch) or Kanchil code\n")
    io.write("Blank line to exit\n")
    while true do
        if source == "" then
            io.write(">> ")
        else
            io.write(".. ")
        end
        local line = io.read("*l")  -- Read a line
        if line == "" then
            break
        elseif (isKanchilSourceFilename(line)) then
            runFile(line)
            break
        else
            source = source..line
            good, done, kanchilstate = runKanchil(source, kanchilstate)
            if good and done then
                source = ""
                io.write("\n")
            elseif not done then
                source = ""
                io.write("*** ERROR - ")
                io.write("Syntax error\n")
                io.write("\n")
            else  -- not good, done
                source = source.."\n"  -- Continue inputting source
            end
        end
    end
end


-- ***** Main Program *****


-- Command-line argument? If so treat as Kanchil source filename, read
-- source, and execute.
if arg[1] ~= nil then
    runFile(arg[1])
-- Otherwise, fire up the Kanchil REPL.
else
    repl()
end

