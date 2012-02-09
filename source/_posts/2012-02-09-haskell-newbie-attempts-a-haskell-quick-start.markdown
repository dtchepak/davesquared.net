---
layout: post
title: "Haskell newbie attempts a Haskell quick start guide"
date: 2012-02-09 12:02
comments: true
categories: ["haskell", "functional programming"]
---

I recently posted an [attempt to explain folds using Haskell](http://davesquared.net/2012/02/folds-pt1-from-recursion-to-folds.html), and I got some feedback that the code samples were quite hard to follow for people that hadn't played with Haskell before. Now the best way that I know of to quickly get started with Haskell is to go through the excellent [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) guide. I heartily recommend leaving this post right now and reading it. The whole guide is available free online, but you can also buy print copies of the fantastic reference. Here's [the link](http://learnyouahaskell.com/) again in case you missed it the first time.  

Are you still here? Oh. Well, seeing as you don't seem to want to listen to my advice, you deserve the rest of this post. It features a complete Haskell-n00b sharing his ignorance and misinformation with a reckless disregard for your quest to understand the basics of Haskell in a way that may permanently impair your ability to learn Haskell, understand functional programming, operate heavy machinery, socialise with other humans or be trusted with the weighty responsibility of goldfish ownership.

The aim of this post, despite your reticence to go through an [extraordinarily helpful Haskell tutorial](http://learnyouahaskell.com/), is to get going with the very basics of Haskell insanely quickly and with a minimum of understanding about what's actually going on. Because that's just the way I roll. And let's face it, you deserve it for not taking my advice. ;) ([Last chance](http://learnyouahaskell.com/) for redemption.)

<!-- more -->

## Getting to a Haskell interactive prompt

Grab the Haskell Platform from [Haskell.org](http://www.haskell.org/). Once installed, go to your favourite terminal and type `ghci` to load the [Glorious Glasgow Haskell Compilation System](http://www.haskell.org/ghc/docs/latest/html/users_guide/index.html) interactive environment (assuming `ghci` is on your path). You should see GHCi's `Prelude>` prompt. If you type in something profound like `7*6` and hit return you should get an answer of sorts. 

Don't do it now, but when you want to exit, type `:q` (in glorious vim tradition).

## Loading a Haskell file

Create a blank file called `haskell-misinformation.hs` in the same directory you ran `ghci` from. Actually, you can call it whatever you want, but it should end in `.hs`. Now jump back to your GHCi prompt and type `:l haskell-misinformation.hs` (you get tab for autocomplete). This will load your file into GHCi. Now whenever we make changes to our Haskell file, we just need to type `:r` to reload it and pick up our changes.

Here's what it looks like on my machine:

    ~  % ghci
    GHCi, version 7.0.4: http://www.haskell.org/ghc/  :? for help
    Loading package ghc-prim ... linking ... done.
    Loading package integer-gmp ... linking ... done.
    Loading package base ... linking ... done.
    Loading package ffi-1.0 ... linking ... done.
    Prelude> :l haskell-misinformation.hs 
    [1 of 1] Compiling Main             ( haskell-misinformation.hs, interpreted )
    Ok, modules loaded: Main.
    *Main> :r
    Ok, modules loaded: Main.
    *Main> 

## Writing a function

Let's write an function that takes an integer and increments it. In our Haskell file, type:

``` haskell
increment :: Int -> Int
increment i = i + 1
```

Switch back to GHCi and reload our Haskell file by typing `:r` and hitting return (from now on, we'll abbreviate this to "reload the file"). If we then type `increment 3` into GHCi we should get the unsurprising result of `4`.

    *Main> :r
    [1 of 1] Compiling Main             ( haskell-misinformation.hs, interpreted )
    Ok, modules loaded: Main.
    *Main> increment 3
    4

Notice we don't need any parentheses for our function call? We just put the arguments straight after the function name.

Let's take a close look at this syntax. The first line is the type declaration of our `increment` function. The `Int -> Int` bit shows the arguments and return type to our function. In this case, `increment` takes an `Int` and returns an `Int`. At first this confused me, having argument types and return types all bundled together like that, with `->` arrows thrown around somewhat haphazardly, but it ends up making a lot of sense later on. 

But we're not here to make a lot of sense. We're here to get started with Haskell quickly. Let's move on before any accidental learning takes place!

## Writing another function

Let's write an `add` function that adds two numbers together. Before we do, let's try and work out that weird, arrow-filled type signature. Our function is going to take 2 `Int` arguments, and return an `Int`. So let's write all that out separated by arrows:

``` haskell
add :: Int -> Int -> Int
add a b = a + b
```

Reload the file and run `add 3 39`. As we saw ealier we don't use parentheses when calling functions, and now we can see that multiple arguments are separated by spaces. GHCi helpfully tells us the answer is `42`. Amazing! Is there anything this Haskell thing can't do?

## Fun with function arguments

Before we go on, try typing `:t add` into GHCi. It should return `add :: Int -> Int -> Int`, the type declaration of our function. You can use that to query the types of lots of things, so it's a handy trick to remember.

Now try typing `:t add 5`. I get this:

    *Main> :t add 5
    add 5 :: Int -> Int

Hmmm. The type of `add` is `Int -> Int -> Int`, which means it takes 2 integers and returns an integer. The type of `add 5` is `Int -> Int`, which means it takes 1 integer and returns 1 integer. We gave `add` its first argument and the result is another function which takes the rest of the arguments.

Let's put that into a new function in our Haskell file and reload it. Our file should look something like this:

``` haskell
increment :: Int -> Int
increment i = i + 1

add :: Int -> Int -> Int
add a b = a + b

addFive = add 5
```

Notice we didn't put the type declaration in for `addFive`? That's because Haskell can infer that for us. In fact, we didn't need to put in any of the previous ones either. Haskell can work those out too. Hah! Made you type for nothing! Actually I did have my reasons; I feel getting to grips with the type declarations is really important for using Haskell effectively.

Now if we call `addFive 10` in GHCi we get `15`. This may strike you as a bit strange. Where is `addFive`'s argument? Shouldn't we have written `addFive a = add 5 a`?

Well, that would work too, but we already used `:t` to determine `add 5` is a function that takes one integer and returns another. By writing `addFive = add 5` we have just given that function a name.

This is called partial function application. If we just give a few of the arguments a function requires, it will return a function that takes the remainder of the arguments. As an aside, this is the reason for the funny `->` symbols in the function type declaration; [all Haskell functions take just one argument](http://www.haskell.org/haskellwiki/Currying) (*warning:* don't click that link if you are feeling lost. You don't need partial application to understand the rest of this post). 

## When we don't know the exact type

So far our type declarations have all involved `Int`. What if we want to return `42` for any argument of any type? After all, it is the meaning of life, the universe and everything. For that we can use a lowercase placeholder to represent that type (Haskell convention is to use a single character, but I think any string that begins with a lowercase char will do). In this case we'll use `a`.

``` haskell
meaningOfLife :: a -> Int
meaningOfLife x = 42
```

In the function body we're putting the argument we get into a variable named `x`, but no matter what that variable contains, the answer is always 42.

```
*Main> meaningOfLife 123
42
*Main> meaningOfLife 20
42
*Main> meaningOfLife 3.1416
42
*Main> meaningOfLife "hello world"
42
*Main> meaningOfLife []
42
```

## Lists

Haskell has a list type that we can construct using square brackets, as I've done in the following GHCi session:

    *Main> [1,2,3,4,5,6,7,8]
    [1,2,3,4,5,6,7,8]
    *Main> [1..8]
    [1,2,3,4,5,6,7,8]
    *Main> [1,3..8]
    [1,3,5,7]
    *Main> []
    []

Lists can also be constructed using the _cons_ operator, which in Haskell is `:`. The `:` operator takes two arguments. The first is the element you want to add to the front of a list, and the second is an existing list (bonus points if you can work out what the type declaration for this will be before running `:t (:)`). So we can add 1 to the front of an empty list, or to an existing list:

    *Main> 1:[]
    [1]
    *Main> 1:[2,3,4,5]
    [1,2,3,4,5]

In fact, `[1,2,3]` is actually shorthand for `1:2:3:[]` (as pointed out in this [tutorial I forgot to mention previously](http://learnyouahaskell.com/starting-out#an-intro-to-lists)). 

We're really dealing with a linked list here. A Haskell list consists of an initial element, called the _head_, with a link to the rest of the list, called the _tail_. There's even built-in functions to help us get at these bits of the list:

    *Main> let myList = [1,2,3,4,5]
    *Main> head myList
    1
    *Main> tail myList
    [2,3,4,5]

A `String` in Haskell is a list of characters, so we can do these same list operations on strings. The string `"hello"` is the same as `'h':'e':'l':'l':'o':[]`, so `tail "hello"` will return `"ello"`

## Pattern matching

I hope you're still reading (unless you've gone off to read [Learn You a Haskell](http://learnyouahaskell.com/) of course), because this is such a fun part of Haskell. 

When defining a function in Haskell, we can actually provided different function bodies for different patterns of arguments. For example, let's add this to our Haskell file:

``` haskell
isZero :: Int -> Bool
isZero 0 = True
isZero x = False
``` 

When we call this function, Haskell will check the function bodies from top to bottom, and evaluate the first one that matches the pattern for the specified arguments.

    *Main> isZero 1
    False
    *Main> isZero 432
    False
    *Main> isZero 0
    True

We can do much more exciting things than that with patterns though. We can tease apart data types like the lists we were working with earlier.

``` haskell
isFirstItemZero :: [Int] -> Bool
isFirstItemZero (head:tail) = isZero head
isFirstItemZero x = False
```

Now if we call `isFirstItemZero [1,2,3]`, Haskell will check the first function body. Does `[1,2,3]` fit the pattern `(head:tail)`? Remembering that `[1,2,3]` is the same as `1:[2,3]`, we can see that it does. So we return `isZero 1`, which is `False`. By the same logic we get `isFirstItemZero [0,1,2]` equal to `True`.

What about `isFirstItemZero []`? We can't break that into a head and a tail, so Haskell will check the next function body. Could `[]` go into a variable `x`? If we type `let x = []` into GHCi it doesn't complain, so I guess it can. Haskell evaluates the second function body, so it returns `False`.

Haskell can work with some truly awesome patterns, but just to show you we're not limited to single values and basic head/tail, let's add this to our Haskell file:

``` haskell
hasMoreThanOne :: [a] -> Bool
hasMoreThanOne (first:second:_) = True
hasMoreThanOne _ = False
```

This will return `True` whenever the argument fits the pattern `(first:second:_)`. In Haskell, the underscore `_` matches anything, so all these will be `True`:

    *Main> hasMoreThanOne (1:2:[])
    True
    *Main> hasMoreThanOne (1:2:[3,4,5])
    True
    *Main> hasMoreThanOne [1,2]
    True
    *Main> hasMoreThanOne [1,2,3,4]
    True
    *Main> hasMoreThanOne [1..]
    True

Anything that doesn't match that pattern, like `[1]` or `[]`, will fall through to the second function body and return `False`.

## Pattern matching with recursion

Let's try an example that uses recursion:

``` haskell
len :: [a] -> Int
len (head:tail) = 1 + len tail
len [] = 0
```

What happens when we call `len [1,2,3]`? Well, `[1,2,3]` gets split into `1:[2,3]`, so the function returns `1 + len [2,3]`.

So what's `len [2,3]`? The `[2,3]` gets split into `2:[3]`, so that will return `1 + len [3]`. By the same logic `len [3]` returns `1 + len []`.

What's `len []`? That doesn't have a head and tail, so that falls through to the second method body, which returns `0`. So tracing through the whole function call, we get:

    len [1,2,3]
        = 1 + len [2,3]
        = 1 + (1 + len [3])
        = 1 + (1 + (1 + len []))
        = 1 + (1 + (1 + 0))
        = 3

## Pattern matching with case expressions

If you find the multiple function bodies used for pattern matching confusing, you might find the case syntax easier to follow. In fact, according to [Learn You a Haskell](http://learnyouahaskell.com/syntax-in-functions#case-expressions), function pattern matching is really just syntactic sugar for case expressions anyway. So we can modify our previous `len` function like this:

``` haskell
len :: [a] -> Int
len x =
    case x of 
        (head:tail) -> 1 + len tail
        []          -> 0
```

I find this more confusing, so I'm not going to attempt to explain it, but I'd thought I'd mention it in case it helps you.

## Higher-order functions

A higher-order function is one which takes one or more functions as arguments or returns a function (or both). In other words, it has a function in its type declaration. Functions passed to other functions are written with their type declarations surrounded by parentheses. 

Let's write a higher-order function called `incrementIf` that increments an integer only if another function returns `True` for that integer. So the function we're passing through to `incrementIf` is going to have a type of `Int -> Bool` -- it will take an integer and return true or false, just like a `Func<int, bool>` in C# if you're familiar with that. The second argument to `incrementIf` will be the integer it is working with, and finally `incrementIf` will return an integer. 

``` haskell
incrementIf :: (Int -> Bool) -> Int -> Int
incrementIf predicate x = if predicate x then increment x else x
```

Here we have two arguments; the first one being a predicate function, the second being our integer. We've also used an `if-then-else` expression to return the incremented integer if the predicate is true, or else return the integer unchanged.

To test this we can use Haskell's built in `even` function (or we could write it ourselves), which will return true or false depending on whether the integer is even.

    *Main> incrementIf even 2
    3
    *Main> incrementIf even 1
    1
    *Main> incrementIf even 4
    5

We can also declare simple functions in-line using lambda syntax. The syntax for lambdas follows the pattern `(\ firstArg secondArg ... -> functionBody)` (the `\` is meant to represent the lambda symbol λ). So rather than using the built-in `even` function, we could pass our own using a lambda:

    *Main> incrementIf (\x -> x `mod` 2 == 0) 5
    5
    *Main> incrementIf (\x -> x `mod` 2 == 0) 6
    7

## `where` and `let`

The last bit of Haskell I used in my [folds post](http://davesquared.net/2012/02/folds-pt1-from-recursion-to-folds.html) was a `where` binding. These can be used to pull out part of an expression for clarity, or to remove duplication if the same expression is used in multiple places within a single function. For example, these two functions are equivalent (the `'` mark is legal in Haskell function names):

``` haskell
circumference radius = 2 * pi * radius

circumference' radius = pi * diameter
    where diameter = 2 * radius
```

You can also use a `let` binding for this, which goes before the function body rather than after.

``` haskell
circumference'' radius = 
    let diameter = 2 * radius 
    in  pi * diameter
```

The `let` binding has some other properties (for example, you can use it in lots of places, such as typing `let a = 1` into GHCi), but check [Learn You a Haskell](http://learnyouahaskell.com/syntax-in-functions#let-it-be) for more details.

## Putting it together

Let's apply a whole bunch of the things we've covered in this post. Let's write a function that filters a list. This function will have to take another function to do the filtering, which makes it a higher-order function. We'll also use pattern matching and recursion to work our way through the list. We also want to support any type of list elements, so we'll need a type signature that reflects that.

If we're dealing with lists of any element type, let's just call that type `a`. If we are filtering elements from a list of `a`, we're going to end up with another list of `a`, so that will also be our return type. The predicate function we pass in to do the actual filtering on each element is going to have to take one of these `a`s, and return `True` or `False`.

``` haskell
filterList :: (a -> Bool) -> [a] -> [a]
```

Now let's try and implement it. We're going to use pattern matching to break the list argument up into its head and tail. If the head element satisfies the predicate function, then well add that to the head of the result of filtering the tail. Otherwise we'll drop that head element, and just return the result of filtering the tail. Finally, as a stopping condition for our recursion, we'll tell Haskell that filtering the empty list will return the empty list, irrespective of what predicate function we pass in.

``` haskell
filterList :: (a -> Bool) -> [a] -> [a]
filterList f (head:tail) = if f head then head : filteredTail else filteredTail
    where filteredTail = filterList f tail
filterList _ [] = []
```

We've used `where` to pull out the `filteredTail` expression, otherwise we would have had to have `filterList f tail` in both the `if` and `else` conditions. This was just to try and make things neater, but we could have written it all in line too.

Now let's use some declared functions and lambdas to filter a couple of lists:

    *Main> filterList even [1..10]
    [2,4,6,8,10]
    *Main> filterList odd [1..10]
    [1,3,5,7,9]
    *Main> filterList isZero [-3..3]
    [0]
    *Main> filterList (\x -> x > 10) [42, 7, 2, 109, 0, 15]
    [42,109,15]
    *Main> filterList (\x -> x `mod` 3 == 0) [1..20]
    [3,6,9,12,15,18]
    *Main> filterList (\x -> x <= 'g') "Hello world, how are you today?"
    "He d,  ae  da?"

If you've followed this whole `filterList` example then congratulations on making it successfully through the minefield that was my attempt at a Haskell quick start! Despite my best efforts, you've manage to learn a bit of Haskell. :)

## Where to from here?

There is loads more to cover before I'd say we know introductory Haskell, particularly function composition, abstract data types (and pattern matching on those), typeclasses, IO, and then on to functors and [monads](/2011/08/functional-programming-newbie-and.html). The best way I know of to get this knowledge in a fun and attainable way is [Learn You a Haskell](http://learnyouahaskell.com/). But we've definitely made a start, and hopefully we've got enough to start deciphering code samples we see around the place.

Let me know if this helped you at all, or if you want me to go into something in greater detail, or if you'd like me to push further into some of the introductory stuff I've picked up so far.

[Download the code: haskell-misinformation.hs](/downloads/code/haskell-misinformation.hs)


