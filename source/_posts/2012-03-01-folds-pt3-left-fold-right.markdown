---
layout: post
title: "Folds Pt 3: Left fold, right?"
date: 2012-02-23 22:49
comments: true
categories: ["haskell", "functional programming", "+folds"]
published: false
---

This post is part 3 of a [series on folds](/categories/-folds), which is my attempt to understand folds. In [part 1](/2012/02/folds-pt1-from-recursion-to-folds.html) we found that a fold is a way of abstracting recusive operations over lists. In [part 2](/2012/02/folds-pt2-from-loops-to-folds.html) we saw that we could also express loops using recursion, which we could extract into a different type of fold. We learned that the loop-like fold is called a _left fold_ (it accumulates it values on the left of the expression), and that our original fold was called a _right fold_. In this post we'll look at the differences between these functions.

<!-- more -->

If you haven't read the previous parts, I should point out that the examples for these posts are in Haskell, but I'll try to explain the syntax as we go in case you aren't familiar with it. If you find yourself getting lost in the syntax, I've written a [Haskell quick start](/2012/02/haskell-newbie-attempts-a-haskell-quick-start.html) that goes through all the bits we'll use.

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

It turns out that this order of evaluation can make a world of difference, especially in a lazily-evaluted language like Haskell. Say we want to take the first element greater than 10 from an infinite list.

    *Main> foldRight (\head acc -> if head>10 then head else acc) 0 [1..]
    11
    *Main> foldLeft (\acc head -> if head>10 then head else acc) 0 [1..]
    ^CInterrupted.

-- Show good illustration of infinite list stuff. Maybe take over mapped list?

    *Main> take 5 [1..100]
    [1,2,3,4,5]
    *Main> take 5 (mapFnRight (*2) [1..])
    [2,4,6,8,10]
    *Main> take 5 (mapFnLeft (*2) [1..])
    ^CInterrupted.

