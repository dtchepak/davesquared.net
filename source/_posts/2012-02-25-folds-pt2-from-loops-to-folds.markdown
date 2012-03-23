---
layout: post
title: "Folds Pt 2: From loops to folds"
date: 2012-02-25 15:35
comments: true
categories: ["haskell", "functional programming", "+folds"]
---

This post is part 2 of a [series on folds](/categories/-folds). Folds seem to crop up quite often in functional programing, and this series is my attempt to learn a little about the topic. 

In [part 1](/2012/02/folds-pt1-from-recursion-to-folds.html) we found that a fold is a way of abstracting recursive operations over lists. In this post we'll look at a different way of folding; one that traverses lists in a similar way to a `for`/`foreach` loop.

<!-- more -->

The examples are in Haskell, but I'm not going to assume you've had a chance to try it and so I'll try to explain it as I go. Hopefully the concepts will make sense even if you're not familiar with Haskell. If you find yourself getting lost in the syntax, I've written a [Haskell quick start](/2012/02/haskell-newbie-attempts-a-haskell-quick-start.html) that goes through all the bits we'll use.

## Previously, on davesquared.net...

[Last time](/2012/02/folds-pt1-from-recursion-to-folds.html) we looked at recursive functions over lists like this one:

``` haskell
add :: Num a => [a] -> a    -- Take a list of numbers, return a number
add (head:tail) = head + add tail
add [] = 0
```

We defined our `add` function as returning the head of the list added to the result of recursively calling `add` on the rest of the list (known as the tail). We also defined a stopping condition for our recursion: when `add` is called with an empty list `[]`, it returns `0`. Tracing through a call to this function showed something like this:

    add [1,3,5]
        = add (1:[3,5])         -- split list into head and tail: 1 and [3,5]
        = 1 + (add [3,5])
        = 1 + (3 + (add [5]))
        = 1 + (3 + (5 + (add [])))
        = 1 + (3 + (5 + 0))     -- recursive calls now stopped. Time to evaluate the expression.
        = 1 + (3 + 5)
        = 1 + 8
        = 9

Here we evaluate the head of the list, and add it to the result of the expression accumulating on the right. Once the recursion reaches the stopping condition we've got a long line of brackets accumulated on the right, and we can start evaluating them all until they reduce back to our answer.

In the last post we looked at a few recursive functions like this, and found they all had a few things in common: a seed value to return for the empty list case, and a two argument function that is applied to the head of the list and the accumulated result of calling the original function on the tail of the list. Using this realisation we abstracted the common bits of these recursive operations into a `fold` function:

``` haskell
fold :: (a -> b -> b) -> b -> [a] -> b
fold f seed (head:tail) = f head (fold f seed tail)
fold _ seed [] = seed

-- Re-writing add function using fold:
addWithFold :: Num a => [a] -> a
addWithFold list = fold (+) 0 list
    -- (+) is a two arg function. In lambda syntax: (\x y -> x + y)
```

And this `addWithFold` function worked exactly the same as our original `add` function, except we no longer have to explicitly use recursion, it's abstracted away in our `fold` function. Tracing through a call to `addWithFold` showed it expands out exactly as per our original `add [1,3,5]` example above, including the expressions accumulating on the right (you can see an example of tracing through a fold in [part 1](/2012/02/folds-pt1-from-recursion-to-folds.html)).

And that's where we left things last post.

## Writing `add` using a loop

What if we rewrote our original, recursive version of `add` using a standard, imperative loop? Let's see how that would look in a C-like language (in this case, C#):

``` csharp
int Add(int[] numbers) {
    int acc = 0;
    for (int i=0; i < numbers.Length; i++) {
        acc += numbers[i];
    }
    return acc;
}
```

We initialise an accumulator `acc` to 0, then keep adding each member of the list of numbers to it before returning the final value of `acc`.

Let's use a little bit of imagination now. Say C# was actually a language with [lazy evaluation](http://en.wikipedia.org/wiki/Lazy_evaluation) like Haskell, so it does not actually evaluate any functions like `(+)` until it absolutely has to. If we were to trace through the execution of the loop in this lazy world we'd see something like this:

    Add(new[] { 1, 3, 5 });
        acc = 0                     // Initial value
        acc = (0 + 1)               // 1st iteration
        acc = ((0 + 1) + 3)         // 2nd iteration
        acc = (((0 + 1) + 3) + 5)   // 3rd iteration and end of loop
        acc = ((1 + 3) + 5)         // Start evaluating...
        acc = (4 + 5)
        acc = 9                     // ... return result

Notice that the here our expression is building up on the left side, instead of on the right-hand side we saw for our version which used `fold`?

        -- Loop version:
        ((0 + 1) + 3) + 5

        -- Fold version:
        1 + (3 + (5 + 0))

Well, we could also write a Haskell function that uses an accumulator too. But Haskell doesn't have imperative-style loops, so we'll need to go back to recursion.

``` haskell
add' list =
    let accumulate acc (head:tail) = accumulate (acc+head) tail
        accumulate acc []          = acc
    in accumulate 0 list
```

Here we've used `let` to introduce a kind of nested function `accumulate` within `add'`. It includes an extra variable `acc` to store our accumulated value. The `accumulate` function recursively calls itself until it stops at the empty list. Our `add'` function kicks off this recursion with the initial accumulator value by calling `accumulate 0 list`.

Now look at what happens when we trace through a call to `add'`:

    add' [1,3,5]
        = accumulate 0 [1,3,5]
        = accumulate (0 + 1) [3,5]
        = accumulate ((0 + 1) + 3) [5]
        = accumulate (((0 + 1) + 3) + 5) []  -- stopping condition for recursion, returns acc
        = (((0 + 1) + 3) + 5)                -- recursive calls now stopped. Time to evaluate
        = ((1 + 3) + 5)
        = (4 + 5)
        = 9

Look familiar? This results in the same `((0 + 1) + 3) + 5` expression that is produced by the looping version of the function. We're accumulating our values in parentheses on the left hand side of our expression.

## More examples of loop-style recursions

In [part 1](/2012/02/folds-pt1-from-recursion-to-folds.html) we implemented a few different functions using recursion that built up expressions on their right hand sides. We can also implement these using loop-like recursion as we did for `add'`. Here are `len` and `mapFn` from the previous post, rewritten to accumulate values on the left hand side:

``` haskell
len :: [a] -> Int
len list =
    let accumulate acc (head:tail) = accumulate (acc+1) tail
        accumulate acc []          = acc
    in accumulate 0 list

mapFn :: (a -> b) -> [a] -> [b]
mapFn f list =
    let accumulate acc (head:tail) = accumulate (acc ++ [f head]) tail  -- (++) concats lists
        accumulate acc []          = acc
    in accumulate [] list

{-
*Main> len [1..10]
10
*Main> mapFn (*2) [1,3,5,7]
[2,6,10,14]
-}
```

All these functions look strikingly similar. They perform an operation with the `acc` accumulator and the `head` of the list, and make a recursive call with this value as the new accumulator. And they all start off with an initial case, commonly called a _seed_. For `add'` and `len` the seed is 0, for `mapFn` it's `[]`.

Last post we were able to generalise the common parts of recursive functions into a `fold` function that accumulated values on the right hand side. Can we write a fold function that evaluates in this loop-like way instead?

## Looping using a fold

They key areas of difference between all these functions is the initial seed used for the accumulator, and the operation we perform on the accumulator `acc` and the head of the list. This means that, similar to the last time we wrote fold, we're going to have to pass in a seed and a function to operate on `acc` and head. And we'll need to pass in a list to fold over.

### Type detective work

Let's try and work out what the types of these arguments need to be. Here's the types we need to figure out, with placeholders (indicated by question marks) for the argument types and the return type:

    foldLeft :: (function?) -> seed? -> list? -> return?

First let's take a look at the seed. For `add'` and `len` we passed in `0`, an `Int`, and this is the type we ended up returning from the functions. For `mapFn` we passed in a list `[]`, and we ended up returning a list which was the result of applying the mapping to each element. So it looks like the seed and the return value have to be the same type, but it doesn't really matter what that type is. Let's just call it type `a` for now.

    foldLeft :: (function?) -> a -> list? -> a

Next let's look at the list we pass in. For `add'` this was `[Int]`, a list of `Int`. For `len` and `mapFn` it was any type of list. So this can really be any type of list, and it doesn't have to be the same type that is used for the seed or the function return value (for example `len` takes any list `[a]` and returns an `Int` which represents the length of the list). So we'll say the list elements are of any type `b`, which means it can be any type, but that it does not have to be the same type as our accumulator of type `a`.

    foldLeft :: (function?) -> a -> [b] -> a

The last type we need to figure out is the function that operates on the accumulator `acc` and the head of the list and returns the new value of the accumulator. For `add'`, this function was `acc + head`. We already decided that our accumulator is of type `a`. We also know our list elements are of type `b`, so the head of the list that gets passed into the function will be something of type `b`. And then our function returns the new value of the accumulator, which will need to be the same type `a` as our previous accumulator. So the function will need to have the type `a -> b -> a`.

All this gives the following type definition:

``` haskell
foldLeft :: (a -> b -> a) -> a -> [b] -> a
```

Here we have 3 arguments: a function that takes an accumulator of type `a` and a list head of type `b` and returns the new accumulator; a value of type `a` as the seed for the accumulator; and a list `[b]`. Then our function will return the final accumulated value of type `a`.

I find reasoning about all the types that go flying around quite tricky, but I've also found understanding them is a major part of the battle.

### Implementing the left fold

Now we need to try and fit all of this together. I'm going to use our `add'`, `len` and `mapFn` examples as a template:

``` haskell
foldLeft :: (a -> b -> a) -> a -> [b] -> a
foldLeft f seed list =
    let accumulate acc (head:tail) = accumulate (f acc head) tail
        accumulate acc []          = acc
    in accumulate seed list
```

This follows the same format as our previous functions. The only difference is that we're passing in `f` and calling `f acc head` to get the new accumulator value, and that we're passing in a `seed`. We can simplify this a bit because we already have the seed argument to `foldLeft` that we can use as the accumulator (so we don't need to declare an inner `accumulate` function):

``` haskell
foldLeft :: (a -> b -> a) -> a -> [b] -> a
foldLeft f acc (head:tail) = foldLeft f (f acc head) tail
foldLeft _ seed [] = seed
```

If we trace through an example we'll see it works exactly the same as our previous, loop-like recursion:

    foldLeft (+) 0 [1,3,5]
        = foldLeft (+) (0 + 1) [3,5]
        = foldLeft (+) ((0 + 1) + 3) [5]
        = foldLeft (+) (((0 + 1) + 3) + 5) []
        = (((0 + 1) + 3) + 5)
        = ...
        = 9

Now we are able to rewrite our other functions without having to use explicit recursion:

``` haskell
lenLeft :: [a] -> Int
lenLeft list = foldLeft (\acc head -> acc+1) 0 list

mapFnLeft :: (a -> b) -> [a] -> [b]
mapFnLeft f list = foldLeft (\acc head -> acc ++ [f head]) [] list

{-
*Main> lenLeft [1..10]
10
*Main> mapFnLeft (*2) [1..10]
[2,4,6,8,10,12,14,16,18,20]
-}
```

## Left or right?

We now have two versions of folding: `foldLeft` that works like a loop and accumulates values on the left hand side, and `foldRight` that accumulates values on the right. 

``` haskell
foldLeft :: (a -> b -> a) -> a -> [b] -> a
foldLeft f acc (head:tail) = foldLeft f (f acc head) tail
foldLeft _ seed [] = seed

foldRight :: (a -> b -> b) -> b -> [a] -> b
foldRight f seed (head:tail) = f head (foldRight f seed tail)
foldRight _ seed [] = seed
```

These functions are provided in the standard Haskell Prelude library as `foldl` and `foldr`. Both are used to abstract away explicit recursion, and other than our observation about the order it evaluates expression, they both give the same results.

It turns out that this order of evaluation can make a world of difference, especially in a lazily-evaluted language like Haskell. In the [next post](/2012/03/folds-pt3-left-fold-right.html) in this series, we'll look at some of these differences.

