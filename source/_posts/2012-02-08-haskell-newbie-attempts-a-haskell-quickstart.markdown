---
layout: post
title: "Haskell newbie attempts a Haskell quick start guide"
date: 2012-02-07 21:15
comments: true
categories: ["haskell", "functional programming"]
---

I recently posted an [attempt to explain folds using Haskell](http://davesquared.net/2012/02/folds-pt1-from-recursion-to-folds.html), and I got some feedback that the code samples were quite hard to follow for people that hadn't played with Haskell before. Now the best way that I know of to get jump-started with Haskell is the excellent [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) guide. I heartily recommend leaving this post right now and reading it. Here's [the link](http://learnyouahaskell.com/) again in case you missed it the first time.

Are you still here? Oh. Well, seeing as you don't seem to want to listen to my advice, you deserve the rest of this post. It features a complete Haskell-n00b sharing his ignorance and misinformation with a reckless disregard for your quest to understand the basics of Haskell in a way that may permanently impair your ability to learn Haskell, understand functional programming, operate heavy machinery, socialise with other humans or be trusted with the weighty responsibility of goldfish ownership.

The aim, despite your reticence to go through an [extraordinarily helpful Haskell tutorial](http://learnyouahaskell.com/), is to get going with the very basics of Haskell insanely quickly and with a minimum of understanding about what's actually going on. Because that's just the way I roll. And let's face it, you deserve it for not taking my advice. ;) ([Last chance](http://learnyouahaskell.com/) for redemption.)

<!-- more -->

## Getting to a Haskell interactive prompt

Grab the Haskell Platform from [Haskell.org](http://www.haskell.org/). Once installed, go to your favourite terminal and type `ghci` to load the [Glorious Glasgow Haskell Compilation System](http://www.haskell.org/ghc/docs/latest/html/users_guide/index.html) interactive environment (assuming `ghci` is on your path). You should see GHCi's `Prelude>` prompt. If you type in something profound like `7*6` and hit return you should get an answer of sorts. 

Don't do it now, but when you want to exit, type `:q` (in glorious vim tradition).

## Loading a Haskell file

Create a file called `haskell-misinformation.hs` in the same directory you ran `ghci` from. Actually, you can call it whatever you want, but it should end in `.hs`. Now jump back to your GHCi prompt and type `:l haskell-misinformation.hs` (you get tab for autocomplete). This will load your file into GHCi. Now whenever we make changes to our Haskell file, we just need to type `:r` to reload it and pick up our changes.

Here's what it looks like on my machine:

```
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
```

## Writing a function

Let's write a function that takes an integer and increments it. In our Haskell file, type:

``` haskell
increment :: Int -> Int
increment i = i + 1
```

Switch back to GHCi and reload our Haskell file by typing `:r` and hitting return (from now on, we'll abbreviate this to "reload the file"). If we then type `increment 3` into GHCi we should get the unsurprising result of `4`.

```
*Main> :r
[1 of 1] Compiling Main             ( haskell-misinformation.hs, interpreted )
Ok, modules loaded: Main.
*Main> increment 3
4
```

Notice we don't need any parentheses for our function call? (i.e. not `increment(3)`.)

So let's look at this syntax. The first line is the type declaration of our `increment` function. The `Int -> Int` bit shows the arguments and return type to our function. In this case, `increment` takes an `Int` and returns an `Int`. At first this confused me, having argument types and return types all bundled together like that, with `-&gt;` arrows thrown around somewhat haphazardly, but it ends up making a lot of sense later on. 

But we're not here to make a lot of sense. We're here to get started with Haskell quickly. Let's move on before any accidental learning takes place!

## Writing another function

Another function? Sigh. Well, I guess that's what we get for working in a functional language.

Let's write a `add` function that adds two numbers together. Before we do, let's try and work out that weird, `-&gt;`-filled type signature. Our function is going to take 2 `Int` arguments, and return an `Int`. So let's write all that out separated by arrows:

``` haskell
add :: Int -> Int -> Int
add a b = a + b
```

Reload the file and run `add 3 39`. We don't use parentheses when calling functions, and arguments are separated by spaces. GHCi helpfully tells us the answer is `42`. Amazing! Is there anything this Haskell thing can't do?

## Fun with function arguments

Before we go on, try typing `:t add` into GHCi for me. It should return `add :: Int -> Int -> Int`, the type declaration of our function. You can use that to query the types of lots of things, like `1`, `True` and `[]`.

Now try typing `:t add 5`. I get this:

```
*Main> :t add 5
add 5 :: Int -> Int
```

Hmmm. The type of `add` is `Int -> Int -> Int`, which means it takes 2 integers and returns an integer. The type of `add 5` is `Int -> Int`, which means it takes 1 integer and returns 1 integer. We gave it the first argument and the result is another function which takes the rest of the arguments.

Let's put that into a new function in our Haskell file and reload it. It should look something like this:

``` haskell
increment :: Int -> Int
increment i = i + 1

add :: Int -> Int -> Int
add a b = a + b

addFive = add 5
```

Notice we didn't put the type declaration in for `addFive`? That's because Haskell can infer that for us. In fact, we didn't need to put in any of the previous ones either. Haskell can work those out too. Hah! Made you type for nothing!

Now if we call `addFive 10` in GHCi we get `15`. This may strike you as a bit strange. Where is `addFive`'s argument? Shouldn't we have written `addFive a = add 5 a`?

Well, that would work as too, but we already used `:t` to determine `add 5` is a function that takes one integer and returns another. By writing `addFive = add 5` we have just given that function a name.

This is called partial function application. If we just give a few of the arguments a function requires, it will return a function that takes the remainder of the arguments. As an aside, this is the reason for the funny `-&gt;` symbols in the function type declaration; [all Haskell functions take just one argument](http://www.haskell.org/haskellwiki/Currying) (warning: don't click that link if you are feeling lost. You don't need partial application to understand the rest of this post). 

## When we don't know the exact type

So far our type declarations have all involved `Int`. What if we want to return `42` for any argument of any type? After all, it is the meaning of life, the universe and everything. For that we can use a lowercase placeholder to represent that type (Haskell standard seems to be a single character, but I think any string that begins with a lowercase char will do).

``` haskell
meaningOfLife :: a -> Int
meaningOfLife x = 42
```

Now no matter what argument we give it, the answer is always 42.

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

```
*Main> [1,2,3,4,5,6,7,8]
[1,2,3,4,5,6,7,8]
*Main> [1..8]
[1,2,3,4,5,6,7,8]
*Main> [1,3..8]
[1,3,5,7]
*Main> []
[]
```

Lists can also be constructed using the _cons_ operator, which in Haskell is `:`. The `:` operator takes two arguments. The first is the element you want to add to the front of a list, and the second is an existing list (bonus points if you can work out what the type declaration for this will be before running `:t (:)`). So we can add 1 to the front of an empty list, or to an existing list:

```
*Main> 1:[]
[1]
*Main> 1:[2,3,4,5]
[1,2,3,4,5]
```

In fact, `[1,2,3]` is actually shorthand for `1:2:3:[]` (as pointed out in this [tutorial I forgot to mention previously](http://learnyouahaskell.com/starting-out#an-intro-to-lists)). 

We're really dealing with a linked list here. A Haskell list consists of an initial element, called the _head_, with a link to the rest of the list, called the _tail_. There's even built-in functions to help us get at these bits of the list:

```
*Main> let myList = [1,2,3,4,5]
*Main> head myList
1
*Main> tail myList
[2,3,4,5]
```

## Pattern matching

I hope you're still reading, because this is such a fun part of Haskell. Unless you've gone off to read [Learn You a Haskell](http://learnyouahaskell.com/) of course.

When defining a function in Haskell, we can actually provided different function bodies for different patterns of arguments. For example, let's add this to our Haskell file:

``` haskell
isZero :: Int -> Bool
isZero 0 = True
isZero x = False
``` 

When we call this function, Haskell will check the function bodies from top to bottom, and evaluate the first one that matches the pattern for the specified arguments.

```
*Main> isZero 1
False
*Main> isZero 432
False
*Main> isZero 0
True
```

We can do much more exciting things than that with patterns though. We can tease apart data types like the lists we were working with earlier.

``` haskell
isFirstItemZero :: [Int] -> Bool
isFirstItemZero (head:tail) = isZero head
isFirstItemZero x = False
```

Now if we call `isFirstItemZero [1,2,3]`, Haskell will check the first function body. Does `[1,2,3]` fit the pattern `(head:tail)`? Remembering that `[1,2,3]` is the same as `1:[2,3]`, we can see that it does. So we return `isZero 1`, which is `False`. By the same logic we get `isFirstItemZero [0,1,2]` equal to `True`.

What about `isFirstItemZero []`? We can't break that into a head and a tail, so Haskell will check the next function body. Could `[]` go into a variable `x`? If we type `let x = []` into GHCi it doesn't complain, so I guess it can. So Haskell evaluates the second function body, so it returns `False`.

Haskell can work with some truly awesome patterns, but just to show you we're not limited to single values and basic head/tail, let's add this to our Haskell file:

``` haskell
hasMoreThanOne :: [a] -> Bool
hasMoreThanOne (first:second:_) = True
hasMoreThanOne _ = False
```

This will return `True` whenever the argument fits the pattern `(first:second:_)`. In Haskell, the underscore `_` matches anything, so all these will be `True`:

```
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
```

Anything that doesn't match that pattern, like `[1]` or `[]`, will fall through to the second function body and return `False`.

## Pattern matching with recursion

Let's try an example that uses recursion:

``` haskell
len :: [a] -> Int
len (head:tail) = 1 + len tail
len [] = 0
```

What happens when we call `len [1,2,3]`? Well, `[1,2,3]` gets split into `1:[2,3]`, so the function returns `1 + len [2,3]`.

So what's `len [2,3]`? Well, `[2,3]` gets split into `2:[3]`, so that will return `1 + len [3]`. By the same logic `len [3]` returns `1 + len []`.

What's `len []`? That doesn't have a head and tail, so that falls through to the second method body, which returns `0`. So tracing through the whole function call, we get:

```
len [1,2,3]
    = 1 + len [2,3]
    = 1 + (1 + len [3])
    = 1 + (1 + (1 + len []))
    = 1 + (1 + (1 + 0))
    = 3
```

## A few other syntactical tidbits

There's a couple of other constructs we can use for functions. 




