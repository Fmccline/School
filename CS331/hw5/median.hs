-- median.hs
-- Frank Cline
-- 25 March 2017
--
-- CS 331 HW 5 Exercise C

import System.IO
import Data.List

main = do
    putStrLn "Enter a series of integers, and I will compute the median!\n"
    hFlush stdout
    list <- get_user_list
    if (list == []) 
    	then 
    		putStrLn "Empty list - no median\n"
    	else 
    		get_median list
    another_median

-- get_user_list
-- gets an integer from the user and adds it to a list.
-- 		Input must be an integer.
-- returns the list of integers.
get_user_list :: IO [Int]
get_user_list = get_user_list' []
    where
        get_user_list' list = do
        putStr "Input number (blank line to end):"
        hFlush stdout
        number <- getLine
        if (number == [])
        	then 
        		return list 
    		else 
    			get_user_list' $ (read number :: Int):list

-- get_median
-- takes a list of numbers
-- sorts the list, finds the median, then returns the median
get_median list = do
    sorted_list <- return (sort list)
    median <- return (sorted_list !! (div (length sorted_list) 2))
    putStr "The median is: "
    print median

-- another_median
-- asks the user if they wish to run the program again
-- calls main if yes, finishes the program otherwise
another_median = do
    putStr "Find another median for a list? [y/n]"
    hFlush stdout
    restart <- getLine
    if restart == "y"
        then do
        	putStrLn ""
        	main
    	else 
    		putStrLn "Alrighty, cya later!"
 