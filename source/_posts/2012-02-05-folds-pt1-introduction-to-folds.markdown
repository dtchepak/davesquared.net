---
layout: post
title: "Folds Pt 1: Introduction to folds"
date: 2012-02-05 00:08
comments: true
categories: ["haskell", "functional programming", "+folds"]
---

I've recently been trying to [learn some functional programming](http://learnyouahaskell.com/), and one of the first things to trip me up was the idea of _folds_. At their simplest, folds seem to be a short-hand for defining recursions over lists, but I find I start getting lost somewhere between fold types and optimising for languages with lazy evaluation. 

This [series on folds](/categories/-folds) is my attempt to pull together the little bits and pieces I've managed to pick up into a form I can understand. If you're not familiar with folds, hopefully it will help get you started, and if you are then please send any corrections via comments or email and I'll update the post. 

In this first post of the series we will try to work out what folds are. We'll start by looking at some problems we can solve using recursion over lists. We'll then try and work out what these solutions have in common, and factor that out. Finally we'll see how this relates to folds, and how we can use folds to solve these problems more succinctly.

<!--more-->

<div class="note"><b>Note:</b> I'll use Haskell for this post but won't assume you've had a chance to try it out, so I'll try and explain all the relevant bits as we go. This also means that I'll avoid some nice features of Haskell that could make the examples more concise and idiomatic, so we can focus less on the language, and more on the topic of folding.
</div>

## Recursing over lists

Let's look at a Haskell function that uses recursion to return the length of a list.

``` haskell
len :: [a] -> Int
len (head:tail) = 1 + len tail
len [] = 0
```

The first line declares the type of our `len` function; it takes a list of any type `a` (expressed as `[a]`), and returns an `Int`.

The second line is where we define the length function in terms of recursion. Given the list argument, we're going to use [pattern matching](http://learnyouahaskell.com/syntax-in-functions#pattern-matching) to break that argument into its `head` (the first element of the list), and its `tail` (the rest of the list). For example: the head of the list `[1,2,3]` is `1` and its tail is `[2,3]`. When `len` is called with a list that has a head and tail, we're going to return 1 plus the result of recursively calling `len` on the tail. We'll see an example of this in a minute to make this a bit clearer if you're lost in the syntax.

What happens when we've recursively called `len` and get to the end of the list? This is what the last line is for; it is the _stopping condition_ for our recursion. If `len` is called for a list without a head and tail (i.e. the empty list), the pattern on the second line will not be matched and Haskell will look for the next `len` definition to see if that can provide a return value. Our third line can; it returns the length of the empty list `[]` as 0.

Let's manually trace through what happens when we call this function:

```
len [1,2,3]
    = 1 + len [2,3]
    = 1 + 1 + len [3]
    = 1 + 1 + 1 + len []
    = 1 + 1 + 1 + 0
    = 3
```

Looks reasonable to me. We've defined the length of a list as 1 for its first element (its head) plus the length of the rest (its tail). And when we have a list with no elements (the empty list), its length is 0.

## A pattern emerges

What other list functions can we define using recursion? How about adding together all the numbers in a list?

``` haskell
add :: Num a => [a] -> a  --Take a list of numbers, return a number (all the elements added together)
add (head:tail) = head + add tail
add [] = 0
{- Results:
add [2,4,6]
    = 2 + add [4,6]
    = 2 + 4 + add [6]
    = 2 + 4 + 6 + add []
    = 2 + 4 + 6 + 0
    = 12
-}
```

This works very similarly to our `len` function, but instead of adding 1 to get the length, we're adding the head value to get the sum of all the elements. Adding the elements of an empty list gives us 0. How about mapping a function over every element of the list? 

``` haskell
mapFn :: (a->b) -> [a] -> [b] -- 1st arg is function that takes an "a" and returns a "b",
                              -- 2nd arg is a list of "a",
                              -- and we return a list of "b".
mapFn fn (head:tail) = (fn head) : mapFn fn tail
mapFn fn [] = []
{- Results:
mapFn (+1) [1,2]
    = (1+1) : mapFn (+1) [2]
    = (1+1) : (2+1) : mapFn (+1) []
    = (1+1) : (2+1) : []    --mapFn of [] is []
    = (1+1) : [3]
    = [2,3]
-}
```

In this example we've defined `mapFn` as a function `fn` applied to the head of the list (by calling `fn head`), then joined the result (using `:`) to the result of mapping `fn` over the rest of the list. We've also stated that mapping a function over an empty list returns an empty list.

All the functions we've seen follow a similar pattern. They operate over a list by splitting the list into head and tail, and return the result of doing _something_ to the head and the result of recursively calling itself on tail. For `len`, the _something_ was `1+`. For `add` it was `head +` and for `mapFn` it was applying `fn` to the head and joining to the rest of the result. And all of the functions have a value for the empty list to act as a stopping condition (returning 0 or `[]` in these cases).

## Eliminating the duplication

As programmers we eschew duplication, so let's introduce a function `f` that will remove the common bits of these functions, and instead let us focus on the important differences between them. What arguments will `f` need to take? This might end up sounding a bit confusing while we nut it out, but let's push through it and see if it makes sense once we try and wire it all up at the end.

Our function will need to take a list of some type; all our previous functions have. As I don't know exactly what type of elements will be in the list, let's just call them type `a` as a place holder. We'll also need to return a result, but what type should the return value be? For `len`, we used `Int`; it always returns an `Int`, even if it is working with a list of characters. So the result does not have to be the same type as the elements in the list; let's just say it will return some type `b`.

We'll also need some value to return for our stopping condition in the case of the empty list (for `len` this was 0). Now as we'll be returning this value for the empty list, it will need to be the same type as our return value, which we called type `b`.

That's most of the commonalities out of the way. What's left is the _something_ we do to the head of the list and the result of recursively calling on the tail. That sounds like a function definition to me; it takes the head of our list of `a`s, and the result of calling on the tail (we called the result type `b`), and returns the final result (also type `b`).

In Haskell-speak, we now have our function declaration as `f :: (a -> b -> b) -> b -> [a] -> b`. The first argument is the function that does _something_ with the head and the result of the recursive call with the tail. The second argument is the value we want to use when our list is empty. The third argument is the list of `a`s we're recursing over. And finally, we're returning some value of type `b`.

If you're feeling a bit lost then that makes two of us. Let's try and implement it based on what we know and hope for the best. :)

``` haskell
f :: (a -> b -> b) -> b -> [a] -> b
f func valueWhenEmpty (head:tail) = func head (f func valueWhenEmpty tail)
f func valueWhenEmpty [] = valueWhenEmpty
```

## Wat?

If you're like me then you're probably thinking our `f` looks like [gobbledegook](http://en.wikipedia.org/wiki/Gobbledygook). Let's start by looking at the familiar pieces. The last line has our stopping condition for the empty list `[]`; it just returns the required value when the list is empty. Line 2 has our trusty `(head:tail)` pattern on the left-hand side. What's the right-hand side doing?

Remember, the first argument (`func`) is a function that is going to do _something_ with the head of the list and the result of recursively calling on the tail. The `f func valueWhenEmpty tail` is our recursive call with the tail. If it helps, we could pull out that part of the statement and rewrite the second line like this:

``` haskell
f func valueWhenEmpty (head:tail) = func head recursiveCallWithTail 
    where recursiveCallWithTail = f func valueWhenEmpty tail
```

Let's try and apply this to something we already know -- our trusty old `len` function. If we've extracted out the common bits of the recursion we should be able to express `len` in terms of `f`.

``` haskell
-- original
len :: [a] -> Int
len (head:tail) = 1 + len tail
len [] = 0

-- new
len2 :: [a] -> Int
len2 list = f func 0 list
    where func head lenOfTail = 1 + lenOfTail
```

I think I'm starting to see how this hangs together now. Our `func` takes as arguments the head of the list, and the result of recursively calling with tail (which in this case gives the length of the tail). This returns `1 + lenOfTail`, which is the same as `1 + len tail` from the original `len` function. We're also passing in `0` for our empty list value, which gives us the same as the `len [] = 0` from the original example. 

Let's step through the evaluation of each function:

```
len [1,2,3]
    = 1 + len [2,3]
    = 1 + (1 + len [3])
    = 1 + (1 + (1 + len []))
    = 1 + (1 + (1 + 0))
    = 3

len2 [1,2,3]
    = f func 0 [1,2,3]
    = 1 + (f func 0 [2,3])
    = 1 + (1 + (f func 0 [3]))
    = 1 + (1 + (1+ (f func 0 [])))
    = 1 + (1 + (1+0))
    = 3
```

Here we can see that both `len` and `len2` work exactly the same way, it's just that `len2` is now going via a function that handles the recursion plumbing for us.

## Folding

As you may have guessed, our `f` function is a _fold_ (more specifically, a right fold, which we'll get to in a later post). We're _folding_ the `func` argument over a list and providing a particular value for the stopping condition.

What I've been clumsily referring to as "the result of recursively calling the function on the tail" tends to be known as the _accumulator_, because it represents the accumulation of the results for each element in the tail. The empty list value is also known as the _seed_, as that ends up being the first value of the accumulator once we get to the bottom of the recursion and start working out way back up. Fold itself can also be known as [inject or reduce](http://railspikes.com/2008/8/11/understanding-map-and-reduce), or [Aggregate in .NET](http://msdn.microsoft.com/en-us/library/bb549218.aspx).

Let's quickly express our other examples using our fold function (renamed from `f`):

``` haskell
add2 :: Num a => [a] -> a
add2 list = fold (+) 0 list

mapFn2 :: (a->b) -> [a] -> [b]
mapFn2 fn list = fold (\element acc -> (fn element) : acc) [] list
  -- Here (\a b -> retVal) is a lambda expression that takes 2 arguments.
  -- Think Func<A, B, B> in C#.
```

## But why?!?!

Because it gives us a way of expressing functions that work over lists without the noise of the recursion mechanics getting in the way.

At first the fold versions may seem confusing compared to explicit recursion, but after gaining some familiarity with the steps, folds start to let us immediately focus on the intent of the code. Our function becomes a statement of the absolute essence of the problem we're solving. The `add2` example shows us folding `+` over a list, starting with a seed of 0. The essence of the function is adding, and there's the `(+)` function sitting first and foremost in the call to `fold`.

Once we start using some Haskell niceties like partial application and function composition we can start getting some very concise, elegant function definitions, expressed in terms of other functions.

## Still to come...

In the next post we'll look at the different types of folds. After that we'll move on to look at some of the runtime characteristics of folds (and what we can do about them :)).


