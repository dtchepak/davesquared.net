---
layout: post
title: "Folds Pt 3: Left fold, right?"
date: 2012-03-24 01:33
comments: true
categories: ["haskell", "functional programming", "+folds"]
---

This post is part 3 of a [series on folds](/categories/-folds), which is my attempt to understand the topic. The examples are in Haskell, but hopefully you can follow along even if you're not familiar with the language. If you find yourself getting lost in the syntax, I've written a [Haskell quick start](/2012/02/haskell-newbie-attempts-a-haskell-quick-start.html) that goes through all the bits we'll use.

In [part 1](/2012/02/folds-pt1-from-recursion-to-folds.html) we found that a fold is a way of abstracting recursive operations over lists. In [part 2](/2012/02/folds-pt2-from-loops-to-folds.html) we saw that we could also express loops using recursion, which we could extract into a different type of fold. We learned that the loop-like fold is called a _left fold_ (it accumulates its values on the left of the expression), and that our original fold was called a _right fold_ (which accumulates to the right). 

``` haskell
foldLeft :: (a -> b -> a) -> a -> [b] -> a
foldLeft f acc (head:tail) = foldLeft f (f acc head) tail
foldLeft _ seed [] = seed

foldRight :: (a -> b -> b) -> b -> [a] -> b
foldRight f acc (head:tail) = f head (foldRight f acc tail)
foldRight _ seed [] = seed
```

We saw we could implement several functions using both left and right folds (like `sum`, `length`, and `mapFn`). As both folds abstract away explicit recursion, they seem capable of producing the same results, just with different orders of evaluation. It turns out these differences in evaluation have some important implications, so in this post we'll take a closer look at them.

<!-- more -->

## Flipped arguments and evaluation order

Both our folds take as arguments a function, a seed/accumulator, and a list. If we look closely at the type definitions of each, we can see that the first arguments differ:

    foldLeft :: (a -> b -> a) -> a -> [b] -> a
    foldRight :: (a -> b -> b) -> b -> [a] -> b

The function passed to `foldLeft` is called with the accumulator, then an item from the list (`f acc head`), but `foldRight` is called with the list item then the accumulator (`f head acc`). The function arguments are flipped. This can make some folds easier to write in one form than the other. In particular, folds that create lists seem to more naturally fit with `foldRight`:

    addOneRight list = foldRight (\head acc -> (head+1):acc) [] list

Here we add one to the list head, then prepend that onto the accumulated list using `(:)` (called _cons_, used for constructing lists).  

If we try and write this using a left fold, the order of the list head and accumulated list arguments passed to our lambda function gets flipped:

    addOneLeft' list = foldLeft (\acc head -> (head+1):acc) [] list

If we run these examples though, we get quite different results:

    *Main> addOneRight [1..5]
    [2,3,4,5,6]
    *Main> addOneLeft' [1..5]
    [6,5,4,3,2]

This is due to the difference in evaluation order we identified between the fold types, although now it starts to have more impact than just where our parentheses end up. `foldRight` builds up an expression that evaluates from right to left, so our list gets built up like this:

    addOneRight [1..5] 
        = (1+1) : (addOneRight [2..5])
        = (1+1) : (2+1) : (addOneRight [3..5])
        = ...
        = (1+1) : (2+1) : (3+1) : (4+1) : (5+1) : []
        = [2,3,4,5,6]

Here our last list item `5` gets evaluated with our accumulator `[]` first. In other words, it is [right-associative](http://en.wikipedia.org/wiki/Operator_associativity); `foldRight (+) 0 [1..5]` will create the expression `1 + (2 + (3 + (4 + (5 + 0))))` which evaluates the right-most term first. 

But `foldLeft` works more like a loop, and evaluates from left to right (it is left-associative; `foldLeft (+) 0 [1..5]` creates `((((0 + 1) + 2) + 3) + 4) + 5`), so our first list item `1` gets evaluated with the accumulator `[]` first:

    addOneLeft' [1..5]
        = addOneLeft' ((1+1) : []) [2..5]            -- Evals 1 with accumulator [] first.
        = addOneLeft' ((2+1) : (1+1) : []) [3..5]
        = ...
        = (5+1) : (4+1) : (3+1) : (2+1) : (1+1) : []
        = [6,5,4,3,2]

To fix our `addOneLeft` function, we want to append the item to the end of the accumulated list, rather than add it to the front. We can do this by using `(++)` which concatenates lists, and use `[head+1]` to convert the list element to a list so we can concatenate it.

    addOneLeft list = foldLeft (\acc head -> acc ++ [head+1]) [] list
    {-
    addOneLeft [1..5]
        = addOneLeft ([] ++ [1+1]) [2..5]
        = addOneLeft ([] ++ [1+1] ++ [2+1]) [3..5]
        = ...
        = [] ++ [1+1] ++ [2+1] ++ [3+1] ++ [4+1] ++ [5+1]
        = [2,3,4,5,6]
    -}

This gives us the `[2,3,4,5,6]` answer we expect.

So not only do the functions we pass to both folds differ in argument order, but the order the accumulated value is populated is also reversed.

## To infinity, and beyond!

In the last section we saw that `foldLeft` and `foldRight` evaluate in opposite orders. This difference in evaluation order has another important impact, and that is how the different folds handle infinite lists.

### Taking just a bit of an infinite list

First we'll need to take a small digression to explain how Haskell works with infinite lists. The `take` function in Haskell grabs a specified number of elements from the start of a list. We can implement a basic version of this function so we can trace exactly what's happening when we call it.

```haskell
take' :: Num a => a -> [b] -> [b]
take' 0 _ = []              -- The underscore '_' matches any argument value.
take' _ [] = []
take' i (head:tail) = head : (take' (i-1) tail)
```

We can use our `take'` function like this:

    *Main> take' 0 [1..10]
    []
    *Main> take' 5 [1..10]
    [1,2,3,4,5]
    *Main> take' 3 [1..]
    [1,2,3]

The first two calls take 0 and 5 elements respectively from a list of 10 numbers. The third call takes 3 elements from `[1..]`, which is Haskell for "an infinite list starting from 1". We can get away with using infinite lists because Haskell uses [lazy evaluation](http://en.wikipedia.org/wiki/Lazy_evaluation) (more precisely, it is [non-strict](http://www.haskell.org/haskellwiki/Lazy_vs._non-strict)); it can evaluate only what it absolutely needs to in order to get a result from an expression. 

If you type `[1..]` into GHCi, the interpreter will try and print this list to the terminal. Because printing every element in a list requires evaluating every element, this will continually spit out numbers until you stop it with `Ctrl + c` or something catastrophic happens to the process (like being stopped by the heat death of the universe).

If, instead of dumping `[1..]` to the terminal, we use it as an argument to our `take'` function, it will only evaluate the elements it needs from the list.

    take' 3 [1..]
        = 1 : take' 2 [2..]
        = 1 : 2 : take' 1 [3..]
        = 1 : 2 : 3 : take' 0 [4..]
        = 1 : 2 : 3 : []        -- We defined take' 0 of any list as []

Because `take' 0 [4..]` can return `[]` without further evaluation of the infinite list `[4..]`, Haskell returns the result without getting stuck in an infinite loop.

### Folding over infinite lists

Let's apply this knowledge to folds. I'll try adding one to each element of an infinite list using our addOne functions, and only taking the first three elements from the result:

    *Main> take' 3 (addOneRight [1..])
    [2,3,4]
    *Main> take' 3 (addOneLeft [1..])
    ^CInterrupted.

Hmm. The `addOneRight` call worked fine, but `addOneLeft` just hung until I interrupted it using `Ctrl + c`. We've already seen how the `addOneRight` and `addOneLeft` functions are evaluated, so let's trace through how that pattern works with infinite lists.

    addOneRight [1..]
        = (1+1) : addOneRight [2..]
        = (1+1) : (2+1) : addOneRight [3..]
        = (1+1) : (2+1) : (3+1) : ...

    addOneLeft [1..]
        = addOneLeft ([] ++ [1+1]) [2..]
        = addOneLeft ([] ++ [1+1] ++ [2+1]) [3..]
        = addOneLeft ([] ++ [1+1] ++ [2+1] ++ [3+1] ++ ...) ...

The right fold version is able to evaluate elements straight away; first `(1+1)`, then `(2+1)` and so on, so `take'` can start consuming them immediately. The recursive call keeps generating elements off to the right, but if we stop needing to use the next element, Haskell's going to be lazy and not evaluate the next recursive step.

    take' 3 (addOneRight [1..])
        = take' 3 ((1+1) : addOneRight [2..])
        = (1+1) : take' 2 (addOneRight [2..])
        = (1+1) : take' 2 ((2+1) : addOneRight [3..])
        = (1+1) : (2+1) : take' 1 (addOneRight [3..])
        = (1+1) : (2+1) : take' 1 ((3+1) : addOneRight [4..])
        = (1+1) : (2+1) : (3+1) : take' 0 (addOneRight [4..])
        = (1+1) : (2+1) : (3+1) : []        -- take' 0 of any list is [], we don't need to eval it.

In contrast, the left fold version can't start evaluating until its recursive call reaches the end of the list.

    take' 3 (addOneLeft [1..])
        = take' 3 (addOneLeft ([] ++ [1+1]) [2..])
        = take' 3 (addOneLeft ([] ++ [1+1] ++ [2+1]) [3..])
        = take' 3 (addOneLeft ([] ++ [1+1] ++ [2+1] ++ [3+1]) [4..])
        = take' 3 (addOneLeft ([] ++ [1+1] ++ [2+1] ++ [3+1] ++ ...) ...)

So while `take'` was able to get a list of the form `(1+1) : rest` from `addOneRight` that it could start using straight away, the left fold has to completely evaluate `addOneLeft` before it gets access to a list in that form. And because that requires evaluating a function over every element in an infinite list, that's going to take quite some time...

### Strictly thwarting our conquest of infinity

So far we've seen that while left folds aren't going to do us any favours when it comes to infinite lists, right folds seem to take them in their stride. There is a wrinkle here though; if the function we pass to our right fold needs to evaluate both its arguments (or its right argument first), then the recursion is not going to terminate and we're going to end up hanging, just like our left fold. 

The arguments a function needs to evaluate to produce a result is described as its [strictness](http://www.haskell.org/haskellwiki/Non-strict_semantics). A function that always needs to evaluate both its arguments is said to be strict in both its arguments. If it can sometimes get away with only evaluating some of its arguments it is non-strict (or, for example, just strict in its first argument).

An example of a function that is strict in both its arguments is `(+)`, which needs to evaluate both its left and right sides to return a result:

    *Main> foldRight (+) 0 [1..10]
    55
    *Main> foldRight (+) 0 [1..]
    ^CInterrupted.

While not being able to sum an infinite list does not come as a complete surprise, even code that we imagine could return a result early will not necessarily work. Let's try and see if the sum of our list exceeds 5:

    *Main> (>5) ( foldRight (+) 0 [1..10] )
    True
    *Main> (>5) ( foldRight (+) 0 [1..] )
    ^CInterrupted.

Why doesn't this stop as soon as the sum reaches 20? 

    (>20) (foldRight (+) 0 [1..])
        = (>5) (1 + foldRight (+) 0 [2..])
        = (>5) (1 + (2 + foldRight (+) 0 [3..]))
        = (>5) (1 + (2 + (3 + foldRight (+) 0 [4..])))
        = ...

Even though our total is now greater than 5, our `(+)` operator isn't able to give us a result because it needs to evaluate both its left and right sides. When it looks at `(1 + rest)`, it tries to evaluate `rest` to give us an answer, which brings it to `(1 + (2 + rest))`. Again it needs to evaluate `rest` to finish evaluating the original `(1 + rest)` call. So before we can check `(>5)`, we have to wait until the infinite number of right-hand sides have been evaluated. And so again we reach for `Ctrl + c`.

This is different to our `take'` example which used the `(:)` and `(++)` operators, which are non-strict. If a function only needs the head of a list, it can grab that from `1:rest` without having to strictly evaluate the `rest` argument.

## Left or right?

So how to we know when to choose a left fold over a right fold? I'm not entirely sure, but we can make some guesses based on what we've found so far.

First, if we want to work with infinite lists we're going to need a right fold. It can be quite handy to have functions like `map` (`mapFn` in previous posts) work with infinite lists, as that can give us elegant ways of writing some functions (for example, finding all the numbers whose squares are less than 1000: `takeWhile (< 1000) (map (^2) [0..])`. Thanks to [@puffnfresh](https://twitter.com/puffnfresh) for this example). So we'd write `map` as a right fold. This also means we would pick the right fold version of our `addOne` function (as it is a mapping of `(+1)` over a list).

If we can't work with infinite lists (say, because we're using a strict function like `(+)`), then we have a choice. We've seen arguments are passed in different orders to the function being folded, and the order of evaluation is reversed, either of which may better suit what we are trying to do with our fold. For example, reversing a list using `foldLeft (\acc h -> h:acc) []`, or just `foldLeft (flip (:)) []`, seems quite neat.

I've seen suggestions to consider [loop-like vs. list recursion](http://stackoverflow.com/a/1446803/906) and [operator associativity](http://stackoverflow.com/a/1446478/906) in making a choice, but I'm not entirely sure how to apply these suggestions yet, so at the moment I'm stuck considering infinite lists and which order of evaluation suits what I'm trying to achieve.

When trying to work out how to write a fold and which variant to use, I find it useful to think about the accumulator (`acc`) argument in the function we're folding as _delving_ into the recursion. For left fold the function is `(\acc head -> ...)`, while right is `(\head acc -> ...)`, and the `acc` argument in both represents the result (or eventual result) of recursing over the rest of the list. This not only helps me to work out if a function can be folded right over an infinite list, but also helps me to work out how I need to implement or compose that function to give me the required result from my fold.

There is one other important difference between the folds we haven't covered yet, and that is the question of efficiency in time taken and space used. We'll look at this in the next post.

## Conclusion

We've now seen a few key differences between left and right folds that give us an idea as to why we've bothered coming up with different ways of abstracting away recursion, despite both folds initially looking as if they produced identical results.

First we saw that `foldRight` takes a function with the accumulator passed in on the right, while `foldLeft` has it passed in on the left. Depending on the arguments required to the function being folded, this can make certain folds simpler to call in one direction than the other (such as being able to use `(:)` instead of `(++)` to build up lists while maintaining its order).

More importantly, we saw that the order of evaluation was different for the folds. Left folds start combining the first element with the initial accumulator, whereas for right folds the last element is the first combined with the initial accumulator value. This causes folding `(:)` using left fold to reverse a list, while the right fold preserves the initial order.

This evaluation order means left folds don't work on infinite lists (it needs to get to the final element first before it can start evaluating the expression), while right folds (depending on a function's strictness) can sometimes work happily with an infinite list. To determine whether a function will work with infinite lists, we need to think about whether that function can return a result without accessing its second parameter (`acc`, or accumulator). 

We can use these differences to decide which type of fold to use. If we need to handle infinite lists then a right fold is our only choice. Otherwise we can consider which evaluation order seems to best suit what we're trying to achieve. We are also yet to cover a final discriminator, the efficiency of different folds, and this will give us a bit more of a clue as to when we want to use each type of fold. We'll look at this aspect in the next post of this series, starting with finding a significant problem with our current `foldLeft` implementation.

