-- interpit.lua
-- Frank Cline
-- 6 April 2017
-- CS 331 Assignment 6 Exercise B


-- *********************************************************************
-- * To run a Kanchil program, use kanchil.lua (which uses this file). *
-- *********************************************************************


local interpit = {}  -- Our module


-- ***** Variables *****


-- Symbolic Constants for AST

local STMT_LIST   = 1
local CR_STMT     = 2
local PRINT_STMT  = 3
local INPUT_STMT  = 4
local SET_STMT    = 5
local SUB_STMT    = 6
local CALL_STMT   = 7
local IF_STMT     = 8
local WHILE_STMT  = 9
local BIN_OP      = 10
local UN_OP       = 11
local NUMLIT_VAL  = 12
local STRLIT_VAL  = 13
local BOOLLIT_VAL = 14
local VARID_VAL   = 15
local ARRAY_REF   = 16


-- ***** Utility Functions *****


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return numToInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
	if n == nil then
		return "0"
	else
    	return ""..n
    end
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    if b then
        return 1
    else
        return 0
    end
end



-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding values of Zebu integer variables
--             Value of simple variable xyz is in state.s["xyz"]
--             Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             outcall(str) outputs str with no added newline
--             To print a newline, do outcall("\n")
-- Return Value:
--   state updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.

    local interp_stmt_list
    local interp_stmt

    -- ***** interp_<name non terminal>(ast) *****
    -- 
    -- Interprets the given abstract syntax tree (given as a table)
    -- depending on what the non terminal is.


    -- interp_stmt_list
    function interp_stmt_list(ast)  -- Already declared local
    	if ast ~= nil and #ast > 1 then
	        for i = 2, #ast do
	            interp_stmt(ast[i])
	        end
	    end
    end

    -- interp_stmt
    function interp_stmt(ast)
        local name, body, str

        if ast[1] == CR_STMT then
            outcall("\n")
        elseif ast[1] == PRINT_STMT then
            interp_print(ast[2])
        elseif ast[1] == INPUT_STMT then
			interp_input(ast[2])	
        elseif ast[1] == SET_STMT then
            interp_set_stmt(ast[2],ast[3])
        elseif ast[1] == SUB_STMT then
            name = ast[2]
            body = ast[3]
            state.s[name] = body
        elseif ast[1] == CALL_STMT then
            name = ast[2]
            body = state.s[name]
            if body == nil then
                body = { STMT_LIST }  -- Default AST
            end
            interp_stmt_list(body)
        elseif ast[1] == IF_STMT then
            interp_if_stmt(ast)
        elseif ast[1] == WHILE_STMT then
            interp_while_stmt(ast)
        else
        end
    end

    -- interp_print
    function interp_print(ast)
		if ast[1] == STRLIT_VAL then
            str = ast[2]
            outcall(str:sub(2,str:len()-1))
        else
            outcall(numToStr(interp_expr(ast)))
        end
    end

	-- interp_expr
    function interp_expr(ast)
    	local value_1,value_2

    	if type(ast[1]) ~= "table" then
    		return evaluate_val(ast)
    	elseif ast[1][1] == ARRAY_REF then
    		return evaluate_val(ast[1])
		elseif ast[1][1] == BIN_OP then
			value_1 = evaluate_val(ast[2])
			value_2 = evaluate_val(ast[3])
			return evaluate_op(ast[1][2],value_1,value_2)
		elseif ast[1][1] == UN_OP then
			value = evaluate_val(ast[2])
			return evaluate_un_op(ast[1][2],value)
		end
    end

    -- interp_input
    function interp_input(ast)
    	interp_set_stmt(ast,{NUMLIT_VAL,incall()})
    end

    -- interp_set_stmt
    function interp_set_stmt(lvalue, expr)
		if lvalue[1] == VARID_VAL then
    		state.v[lvalue[2]] = evaluate_val(expr)
    	else
    		index = evaluate_val(lvalue[3])
    		if state.a[lvalue[2][2]] == nil then
    			state.a[lvalue[2][2]] = {}
    		end
			state.a[lvalue[2][2]][index] = evaluate_val(expr)
    	end
	end
    
	-- interp_if_stmt
	function interp_if_stmt(ast)
		local true_expr_flag = 0
        for i = 2, #ast do
        	if ast[i][1] ~= STMT_LIST then
        		true_expr_flag = interp_expr(ast[i])
        	elseif true_expr_flag ~= 0 and true_expr_flag ~= nil then
        		interp_stmt_list(ast[i])
        		return
        	end
        end

        if ast[#ast-1][1] == STMT_LIST then
    		interp_stmt_list(ast[#ast])
    	end
    end

    -- interp_while_stmt
    function interp_while_stmt(ast)
    	while interp_expr(ast[2]) ~= 0 do
    		interp_stmt_list(ast[3])
    	end
    end

    -- evaluate_val
    -- returns a value depending on the table given
    -- 		i.e {STRLIT_VAL, "Hello"} returns "Hello"
    function evaluate_val(value)
    	if type(value[1]) == "table" then
    		return interp_expr(value)
		elseif value[1] == NUMLIT_VAL then
			return strToNum(value[2])
		elseif value[1] == STRLIT_VAL then
			return value[2]
		elseif value[1] == BOOLLIT_VAL then
			return boolToInt(value[2])
		elseif value[1] == VARID_VAL then
			return state.v[value[2]]
		elseif value[1] == ARRAY_REF then
			var = value[2][2]
			index = strToNum(value[3][2])
			if state.a[var] == nil then
				return 0
			elseif state.a[var][index] == nil then
				return 0
			else
				return state.a[var][index]
			end
		end
 	end

 	-- evaluate_op
 	-- returns the evaluation of whatever (value_1 op value_2) equals
 	-- 		i.e. (+,3,5) returns 8
    function evaluate_op(op, value_1, value_2)
    	if op == "==" then
    		return boolToInt(value_1 == value_2)

    	elseif op == ">=" then
    		return boolToInt(value_1 >= value_2)

    	elseif op == "<=" then
    		return boolToInt(value_1 <= value_2)

    	elseif op == ">" then
    		return boolToInt(value_1 > value_2)	

    	elseif op == "<" then
    		return boolToInt(value_1 < value_2)

    	elseif op == "!=" then
    		return boolToInt(value_1 ~= value_2)

    	elseif op == "&&" then
    		if value_1 == 0 or value_2 == 0 then
    			return 0
    		else
    			return 1
    		end

    	elseif op == "||" then
    		if value_1 == 0 and value_2 == 0 then
    			return 0
    		else
    			return 1
    		end

    	elseif op == "+" then
    		return value_1 + value_2	

    	elseif op == "-" then
    		return value_1 - value_2	

    	elseif op == "*" then
    		return value_1 * value_2	

    	elseif op == "/" then
    		if value_2 == 0 then
    			return 0;
    		elseif value_1*value_2 > 0 then
    			return math.floor(value_1 / value_2)
    		else
    			return -math.floor(-value_1 / value_2)
    		end

    	elseif op == "%" then
    		if value_2 == 0 then
    			return 0;
    		else
    			return value_1 % value_2	
    		end
    	end
    end

    -- evaluate_un_op
 	-- returns the evaluation of whatever (op value) equals
 	-- 		i.e. (!,true) returns false
    function evaluate_un_op(op, value)
    	if op == "+" then
    		return strToNum(value)
    	elseif op == "-" then
    		return 0-strToNum(value)
    	else
    		if value == 0 then
    			return 1
    		else
    			return 0
    		end
    	end
    end

    -- Body of function interp
    interp_stmt_list(ast)
    return state
end

-- ***** Module Export *****


return interpit

