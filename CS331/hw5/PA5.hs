-- PA5.hs
-- Frank Cline
-- 25 March 2017
--
-- CS 331 HW 5 Exercise B

-- module PA5 where
module PA5 where

-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map collatz_counter [0..] -- DUMMY; REWRITE THIS!!!

-- collatz_counter
collatz_counter n = collatz_count (n+1) 0

-- collatz_count
collatz_count n count
	| n == 1 = count
	| mod n 2 == 0 = collatz_count (div n 2) (count+1)
	| otherwise = collatz_count ((3*n)+1) (count+1)

-- findList
-- testEq (PA5.findList [20..25] [3..100]) (Just 17) doesn't pass, but when I
-- copy paste "PA5.findList [20..25] [3..100]" into the interpreter, I get Just 17.
findList :: Eq a => [a] -> [a] -> Maybe Int
findList [] _ = Nothing
findList list1 list2
	| (subList list1 list2) < 0 = Nothing
	| otherwise = Just (subList list1 list2)

-- subList
subList :: Eq a => [a] -> [a] -> Int
subList _ [] = minBound :: Int
subList x1s (x2:x2s)
  | all (uncurry (==)) (zip x1s (x2:x2s)) = 0
  | otherwise = if (length x1s) > (length x2s) 
  	then minBound :: Int 
  	else 1 + (subList x1s x2s)

-- op ##
(##) :: Eq a => [a] -> [a] -> Int
[] ## _ = 0
_ ## [] = 0
(x1:xs1) ## (x2:xs2)
	| x1 == x2 = 1 + xs1 ## xs2
	| otherwise = xs1 ## xs2

-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB predicate list1 list2 = myfilterAB predicate list1 list2 []

-- myfilterAB
-- takes paremeters from filterAB as well as another list that is the
-- list to be returned
myfilterAB :: (a -> Bool) -> [a] -> [b] -> [b] -> [b]
myfilterAB predicate [] _ return_list = return_list
myfilterAB predicate _ [] return_list = return_list
myfilterAB predicate (x1:xs1) (x2:xs2) return_list =
	if predicate x1
		then myfilterAB predicate xs1 xs2 (return_list++[x2])
	else myfilterAB predicate xs1 xs2 return_list


