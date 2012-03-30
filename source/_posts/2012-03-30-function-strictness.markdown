---
layout: post
title: "Function strictness"
date: 2012-03-30 23:10
comments: true
categories: ["haskell", "functional programming"]
---

I'm currently reading [Introduction to Functional Programming](http://www.amazon.com/Introduction-Functional-Programming-International-Computing/dp/0134841972/) by Richard Bird and Philip Wadler, and it contains a really nice explanation of function strictness that came up in my [last post](/2012/03/folds-pt3-left-fold-right.html). 

Bird and Wadler describe a strict function as one that is undefined when its input is undefined. The `⊥` symbol, or [bottom](http://en.wikipedia.org/wiki/Bottom_type), is used to represent 'undefined', so `f` is strict if `f ⊥ = ⊥`, otherwise it is non-strict.

<!-- more -->

I interpret this to mean that if a function can take an undefined or generally awkward expression (like `undefined`, `1/0` or an infinite list) for one of its arguments and return a defined, sensible value then it is non-strict in that argument.

The first example they give for this is a function that returns a constant:

    three :: a -> Int
    three x = 3
    {- Haskell GHCi session:
        *Main> three 3
        3
        *Main> three "hello"
        3
        *Main> three undefined
        3
        *Main> three (1/0)
        3
        *Main> three [1..]
        3
    -}

We can see that `three ⊥ = 3`, so it is non-strict. It never actually needs to evaluate its argument. So we can give it all kinds of wonderful arguments like`three (1/0)` (divide by zero), `three [1..]` (infinite list), `three (head [])` (the first element of an empty list) or even `three undefined`, and it will still happily return `3`.

Perhaps a more familiar example is `||`, the boolean _or_ operator. It will only evaluate its second argument if the first is `False`:

    *Main> True || False
    True
    *Main> False || True
    True
    *Main> False || False
    False
    *Main> undefined || True
    *** Exception: Prelude.undefined
    *Main> True || undefined
    True
    *Main> False || undefined
    *** Exception: Prelude.undefined

Here `⊥ || x = ⊥`, so `||` is strict in its first argument. But we also have `True || ⊥ = True`, so `||` is non-strict in its second argument when its first is `True`. This is how `||` is implemented in many languages (including C#, Ruby et al.), not just for functional languages like Haskell.

<div class="note"><b>Aside:</b> I can only think of one language that strictly evaluates both arguments given to <i>or</i>, but I'm sure there are more. Leave a comment if you know of any. :)</div>

## Non-strictness and laziness

Let's have a look at the related concept of laziness. Functional languages work by reducing expressions to their simplest forms (called _canonical_ or _normal_ form). There can be several approaches to doing this. Earlier we saw that Haskell could happily evaluate `three (1/0)`, even though dividing by zero isn't generally a good idea. This was because Haskell chose to reduce this expression by first applying the definition of the function `three`; that is, `three` with any argument reduces to the value `3`.

A language could also decide to reduce the argument first. This would mean applying the rule of the division operation `(/)` first, then trying to apply the definition of `3`. 

The first strategy is known as _lazy-evaluation_, while the second is the _eager-evaluation_ us imperative folks are more familiar with. Imperative languages tend to evaluate arguments before calling a function, so trying to call `Three(SomeMethodThatThrows())` in C# will break where a non-strict, lazy language like Haskell doesn't.

<div class="note"><b>Aside:</b> We can work around this eager-evaluation in C# (and some other languages) with deferred execution using delegates / lambdas. For example, <code>Three(() => SomeMethodThatThrows())</code>.</div>

As far as I can tell, _non-strictness_ is the mathematical property we saw at the beginning of this post, while _lazy-evaluation_ is the expression reduction strategy some languages like Haskell use to implement non-strictness. 

## References

* Richard Bird and Philip Wadler, [Introduction to Functional Programming](http://www.amazon.com/Introduction-Functional-Programming-International-Computing/dp/0134841972/).
* Wikibooks, [Haskell/Laziness](http://en.wikibooks.org/wiki/Haskell/Laziness). Online, accessed 2012-03-30.
* Haskell.org, [Lazy vs. non-strict](http://www.haskell.org/haskellwiki/Lazy_vs._non-strict). Online, accessed 2012-03-30.
