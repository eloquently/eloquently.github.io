---
layout: post
title: Interview Prep 01 - Counting and Primes
permalink: 'guides/interview-prep-01'
date: 2016-05-30
---

## {{ page.title }}

<hr class="left" />

This is the first part in Eloquently's Front End Developer Interview prep series.

You can get the files and tests for this exercise [here](https://github.com/eloquently/interview-prep-01).

These questions are meant to be solved in JavaScript, and the tests for them are written with Mocha/Chai.

There are tests for these exercises. Don't just randomly guess things to get the tests to pass -- you will not learn as much. Instead, pretend this is a real interview and after you come up with a solution, check your work (literally talk through it line by line). If you're not sure that your solution will work, don't just cross your fingers and run the tests. Take the time to think more and improve your answer -- as if it were a real interview.

Only after you are 100% sure that your solution is right, you can run the tests. We haven't set up a test watcher for this exercise: you'll have to type `npm test path/to/file_spec.js` each time. We've also put in a 20s delay at the beginning of the test suite to discourage you from running the tests too often.

Don't just search online for the solutions. In a real interview, that will not be an option. Instead ask for a hint -- that is acceptable in an interview as long as you've tried to solve the problem.

In the test files, the `describe` blocks have a `.skip` after them. This makes Mocha consider them pending, and they won't run. After you complete one test, remove the `.skip` from the next `describe` block to have Mocha run the next test.

One last thing: be sure to `export` your functions. For example, your `countWhile()` function declaration should look like:

```js
export const countWhile = () => {

}

// or...

export function countWhile() {

}
```

### Counting

#### `countWhile()`

Write a function that returns a string with the numbers 1-100 separated by newlines. The last character in the returned string should also be a new line. Your function should be called `countWhile()`. It does not need to take any parameters and should return a string. Use a `while` loop that looks like this: `while(i <= 100)`.

#### `countFor()`

Now write a function called `countFor()` that does the same thing but uses a `for` loop instead of a `while` loop.

#### `countOdds()`

Write a function, `countOdds()` that returns a string with the numbers 1-100, but with the odd numbers labeled. Specifically, your return string should look like this:

```
1 odd
2
3 odd
4
5 odd
.
.
.
```

Hint: Use the modulus operator `%` to determine if something is odd.

#### `fizzbuzz()`

Fizzbuzz is a classic interview question. Return the numbers 1-100 with a slight modification: replace any multiples of 3 with "fizz", replace any multiples of 5 with "buzz", and replace any number that is a multiple of both 3 and 5 with "fizzbuzz".

Here is some sample output:

```
1
2
fizz
4
buzz
.
.
.
14
fizzbuzz
16
.
.
.
```

### Prime

`n` is a prime number if it can only be divided by 1 and `n` to get an integer.

#### `isPrime()`

Create a new file `src/primes.js`, and write a function `isPrime()` that determines if the number passed to it as a parameter is prime. `isPrime()` should return true or false. Your solution should use some type of loop. Don't worry about making your algorithm efficient at this point -- it just needs to work.

When running your tests, note how long it takes to run the test for very large numbers (such as 2608038161). We'll try to make this algorithm more efficient in the next steps.

#### `isPrimeSteps()`

Copy your `isPrime()` function to a new function called `isPrimeSteps()`. Before your loop, create a variable that will track the number of times your program loops to calculate if the number is prime. `isPrimeSteps()` should return an array with two values: 1) a boolean for whether the parameter is prime or not and 2) the number of steps your algorithm went through to determine if the number is prime.

You may wish to skip the `isPrime` tests so you don't have to wait for the large number calculations.

#### `fasterPrime()`

Try to improve your `isPrimeSteps()` function so that it calculates whether a number is prime within the number of steps provided by the tests. Copy it into a new method called `fasterPrime()`. If you get stuck, try calculating whether a small number (like 9 or 11) is a prime by hand. Are there any steps that your algorithm currently performs that are unnecessary?

#### `firstPrimes()`

Write a function called `firstPrimes()` that will calculate the first `n` primes, where `n` is a number passed to the function as a parameter. Use the `fasterPrime()` function to determine if a number is a prime. Keep track of the total number of steps in the `fasterPrime()` method. `firstPrimes()` should return an array with two values: 1) an array containing the first `n` primes and 2) the total number of steps executed in all of the `fasterPrime()` calls.

#### Even Faster with Dynamic Programming

This gets a bit slow when we want to calculate something like the first 500,000 primes. We can use a technique called dynamic programming to speed it up. First, we'll need to write a new `fasterPrime()` function:

##### `evenFasterPrime()`

`evenFasterPrime()` is a version of `fasterPrime()` that takes an additional parameter: an array of all the primes up to the number we are checking (I call this `primesLessThanN`). Write an `evenFasterPrime()` function that uses this new parameter to  determine if a number is prime. The method should still calculate the number of steps, and return an array with two values: 1) a boolean that is true when the number is prime and 2) the number of steps the function performed.

##### `fasterFirstPrimes()`

Now we can write `fasterFristPrimes()`, which will calculate the first `n` primes much more efficiently. `fasterFirstPrimes()` will use `evenFasterPrime()`. Instead of requiring 1,132,749,812 steps to calculate the first 500,000 primes, we can do so with only 190,682,992 steps -- a 6x improvement! This takes the run time down from 14.7s to 2.3s in my Cloud9 environment.
