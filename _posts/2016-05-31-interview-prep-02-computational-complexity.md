---
layout: post
title: Interview Prep 02 - Computational Complexity
permalink: guides/interview-prep-02
date: 2016-05-31
---

## {{ page.title }}

<hr class="left" />

Computational complexity is a formal way of analyzing how efficient a solution is. We are going to use big O notation to talk about algorithms' time complexity and space complexity. Unless otherwise specified, we'll be talking about the average case complexity.

Here's a brief description of what those terms mean.

### Time and Space Complexity

**Time complexity** roughly corresponds with how long it will take an algorithm to run. More specifically, it is a measure of how many "steps" an algorithm will take (see the previous exercises). If you halve the number of steps an algorithm takes, it does not mean that your algorithm will run in exactly half the time. The actual run time of a program depends on a lot of factors beyond your control, such as how busy the processor is with other tasks and optimizations the compiler/interpreter makes for you.

**Space complexity** describes how much memory your algorithm needs to run. Again, the space complexity of an algorithm may not perfectly describe how much RAM your implementation of the algorithm actually uses due to factors outside of your control.

### Asymptotic Complexity

When we consider the complexity of an algorithm, we typically care about what happens as the number of input or the size of inputs gets very large. Saving one or two steps (for example, by starting a factorial algorithm at 1 rather than 0), does not make an algorithm less complex.

Mathematically, we describe this concept as "asymptotic complexity". "Asymptotic" means we look at the complexity as the number/size of inputs approaches infinity (i.e. gets arbitrarily large).

### Big O Notation

Big O notation is a common way to describe the asymptotic complexity of an algorithm. To describe an algorithm with big O, we need to find a function that describes how the number of steps increases based on the input.

Here's an example. Given an array with `n` elements, find the largest element.

```js
const findMax = (arr) => {
    let max = arr[0];
    for(let i = 1; i < arr.length; i++) {
        if(arr[i] > max) max = arr[i];
    }
    return max;
}
```

Each time the number of elements in `arr` increases by 1, our algorithm will take one additional step to find the maximum.

Therefore, we can describe the number of steps with a function `f(n)`, and we just argued that `f(n) = n`. This means that the big O notation of `findMax` is `O(n)`.

For a different algorithm, we might find that `f(n) = n^2 + n + 3`. Because we are looking for the asymptotic complexity, we can omit the lower order terms `n` and `3` when writing the big O. (As n gets very large, the `n` and `3` terms become so small relative to the `n^2` term that we can ignore them). Thus the big O notation for this algorithm would simply be `O(n^2)`.

We can also omit any constant multiples. For example if `f(n) = 4n`, the big O would simply be `O(n)`.

It is possible to figure out an algorithm's computational complexity and express it in big O notation mathematically. We won't go into the details, but instead teach you heuristics for figuring out the computational complexity of various algorithms.

### Example Complexities

Here are some common time complexities and examples of algorithms:

| Time Complexity | Example Algorithm |
|-----------------|-----------|
|`O(1)`|is number even?|
|`O(log(n))` (usually with base 2)|binary search|
|`O(sqrt(n))`|[`fasterPrime()`]({% post_url 2016-05-30-interview-prep-01-counting-and-primes %})|
|`O(n)`|find maximum, linear search|
|`O(n*log(n))`|merge sort|
|`O(n^2)`|select sort|
|`O(n!)`|bogosort|

We'll go through each of these algorithms.

You can find the tests for these exercises [here](https://github.com/eloquently/interview-prep-02).

### `isEven()`

Write a function `isEven()` that takes one parameter: `n` and returns true if `n` is even -- otherwise it will return false.

`isEven()` is simply `O(1)` because it only requires one step to complete. If we had another function, `isNextNumEven()` that determined if `n+1` was even, our function would require two steps: `n+1` and then `isEven()`. `isNextNumEven()` would still be `O(1)` even though it requires two steps because we can eliminate any constants in the function.

### `linearSearch()`

Let's say we have the following array (top row is index, bottom row contains values).

<table>
<thead>
<tr>
<th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th>
</tr>
</thead>
<tbody>
<tr>
<td>4</td><td>8</td><td>15</td><td>16</td><td>23</td><td>42</td><td>64</td><td>100</td><td>112</td><td>1000</td>
</tr>
</tbody>
</table>

```js
arr = [4, 8, 15, 16, 23, 42, 64, 100, 112, 1000]
```

We want to find the index of `23` (the solution is 4).

One way to solve this problem is to start at 0 and look at each element. If that element is 23, then return the index.

This is called a linear search. Write a `linearSearch` function that will take two parameters, `needle` and `haystack`. The first parameter, `needle` is the number we are searching for. The second parameter, `haystack`, is the array we are searching in.

The function should return the index of the position of `needle`. You can assume that `needle` will always be in the `haystack`.

#### Complexity Analysis

Try to figure out what the time complexity of your `linearSearch()` is and why before reading on.

On average, the algorithm will find `needle` in `n/2` steps. `n/2 = 1/2 * n`. Since we omit a multiplied constant, big O for this algorithm is `O(n)`.

### `binarySearch()`

If `haystack` is sorted, we can find something in it much faster than with a `linearSearch()`. Imagine that you have a phone book (names in it are sorted alphabetically) and you are trying to find a particular person's phone number. Finding the number with `linearSearch()` would mean you start at page one, read every name, then go to the next page, read every name, until you find the person you are looking for. This is not very efficient. How could you do better? Assume the phone book has no table of contents or index -- it's just a sorted list of people and phone numbers.

One way is to open the phone book to the middle, check the names of the people on that page. Then if the name of the person you are looking for comes before that page, flip to the middle of the first half of the phone book and repeat. If the name of the person you are looking for comes after the names on the page, flip to the middle of the second half of the book and repeat until you find your person.

This algorithm is called a binary search because we are splitting the phone book in 2 (binary) each iteration.

Let's see how to apply it to an array. First we will look at the middle element. If the element we are looking for is less than the middle element, we know the element must be in the first half of the array. If the element we are looking for is greater than the middle element, we know the element must be in the second half of the array. (If the element we're looking for is the same as the middle element, then we're done). Then we take the half that the element must be in and repeat the process.

Write a `binarySearch` function that takes two parameters: a `needle` and a `haystack` and returns the index of element we are searching for. It is natural to use recursion for this type of algorithm.

#### Complexity Analysis

We'll have to do a little more work to analyze this function than we did for `linearSearch()`. In this case, let's think about how the number of steps increases as `n` (the number of elements in `haystack`) increases. For this algorithm, we're going to analyze the worst case complexity because it's a little complicated to reason about how you might get lucky and finish early because the middle item in the array is the one you are looking for. If we design our algorithm to "round down" when selecting the middle element (e.g take the 2nd element if we have 4 elements), then the worst case scenario is trying to find the last element in the array. Let's see how many steps it takes to find the last element for different sizes of `haystack`.

In this case, we consider a "step" to be the combined actions of splitting and checking the middle element. It's okay to consider multiple actions to be one step as long as they are always performed together. Considering these two actions as one step each would mean we end up with twice as many steps total (e.g. number of double-steps * 2), which gives us a constant of 2. Since we'll get rid of any constant multiples when we write the complexity in big O, it doesn't matter.

If `n` is 2, we will find the `needle` in 2 steps.

If `n` is 3, it will also take 2 steps (select the middle and split, then select the last element and finish).

If `n` is 4, 3 steps is the worst case scenario (select second element and split, select third element and split, select fourth element and finish).

To get an extra step, we had to go from 2 to 4. This could mean that we get another step every time we add 2 to `n` or it could mean we get an extra step every time we double `n`. Figure out which it is by working through `n = 5` through `n = 8`.

--

You should have discovered that we add another step each time `n` doubles. If `steps` is the number of steps, we can describe the relationship we have with `2^steps = n`. Stop and think about why this works and how it makes sense in the context of our problem. Use n=2, n=4, and n=8 and the steps that we solved for above.

If we know `n`, and we want to see how many steps we have, we can use a logarithm to rewrite `2^steps = n` as `log(n) = steps` (with a base 2 logarithm). Therefore, we can say that binary search has complexity `O(log(n))`.
