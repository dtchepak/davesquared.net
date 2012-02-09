increment :: Int -> Int
increment i = i + 1

add :: Int -> Int -> Int
add a b = a + b

addFive = add 5

-- when we don't know the exact type
meaningOfLife :: a -> Int
meaningOfLife x = 42

-- pattern matching
isZero :: Int -> Bool
isZero 0 = True
isZero x = False

isFirstItemZero :: [Int] -> Bool
isFirstItemZero (head:tail) = isZero head
isFirstItemZero _ = False

hasMoreThanOne :: [a] -> Bool
hasMoreThanOne (first:second:_) = True
hasMoreThanOne _ = False

-- pattern matching with recursion
len :: [a] -> Int
len (head:tail) = 1 + len tail
len [] = 0

{- The above len function is syntactic sugar for:
len x =
    case x of 
        (head:tail) -> 1 + len tail
        []          -> 0
-}

-- higher-order functions
incrementIf :: (Int -> Bool) -> Int -> Int
incrementIf predicate x = if predicate x then increment x else x

-- guards
howRelated :: (Ord a) => a -> a -> String
howRelated first second
    | first > second    = "greater than"
    | first < second    = "less than"
    | otherwise         = "equal to"

-- where and let
circumference radius = 2 * pi * radius

circumference' radius = pi * diameter
    where diameter = 2 * radius

circumference'' radius = 
    let diameter = 2 * radius 
    in  pi * diameter


-- putting it together
filterList :: (a -> Bool) -> [a] -> [a]
filterList _ [] = []
filterList f (head:tail) = if f head then head : filteredTail else filteredTail
    where filteredTail = filterList f tail


