---
layout: post
title: Interview Prep 08 - Generators
permalink: guides/interview-prep-08
date: 2016-06-08
---

## {{ page.title }}

<hr class="left" />

This guide will talk about two relatively new JavaScript patterns called generators and promises. Some libraries (such as Redux Saga) use both of them together, but they are very different tools and completely independent of each other.

These are relatively new features in JavaScript, and you can probably get away without knowing them (for both interviews and most projects). However, if something goes wrong in a package you are using, debugging can be much easier if you understand these new language features. It will also impress someone interviewing you if you do know what they are!

### Generators

Generators functions are functions that can pause in the middle of their execution. This can be useful in many cases. Let's start with a not-so-useful example of a generator:

```js
function* count() {
    console.log('before yielding 1');
    yield 1;
    console.log('before yielding 2');
    yield 2;
    console.log('before yielding 3');
    yield 3;
    console.log('before finishing');
}
```

Let's say we run the following code:

```js
const counter = count();
const counter2 = count();
const counter3 = counter;
```

The generator function `count()` returns a reference to a generator object. In this case, `counter` and `counter2` will be referencing two completely independent generator objects, whereas `counter` and `counter3` will reference the same generator object.

Generators have a method called `next()` that will run the function until it reaches a `yield`.

Now if we run,

```js
let a = counter.next();
console.log(a);
```

We will see the following in the console:

```
before yielding 1
{ value: 1, done: false }
```

When we called `counter.next()` the `count` function started running. It executed it's first line (logging `before yielding 1` to the console) then it reached a `yield` line and stopped. When it stopped, it emitted an object with two keys. The object's `value` key has a value of `1` because that's what was yielded. It also has a `done` key with the value `false`. This indicates that the instance of the generator stored in `counter`  is still running. If we run count again:

```js
a = counter.next();
console.log(a);
```

The `count` function will start running on the line: `console.log('before yielding 2');` and continue until it hits the next yield statement. Thus we get the following on the console:

```
before yielding 2
{ value: 2, done: false }
```

What will happen if we run this code? Try guessing what will happen, then run the code in a Chrome console (or using `npm run node file.js` if you put it in a file).

```js
let b = counter2.next();
console.log(b);
```

What happens when we reach the end of a generator? Run each of the following lines one at a time to make sure you understand what is being printed.

```js
b = counter2.next();
console.log(b);
b = counter2.next();
console.log(b);
b = counter2.next();
console.log(b);
```

The fourth time we iterate (call `next()` on) `counter2`, we reach the end of the program. After there are no more statements to yield, the iterator will return an object with an `undefined` `value` and `done` equal to true.

What happens if you keep iterating a generator that's already done?

```js
b = counter2.next();
console.log(b);
```

#### `completeGenerator()`

Create a file called `src/generators.js`. Write a function `completeGenerator()` that takes a single parameter: `generator`, a generator object (not the generator function), and runs the generator to completion.

For example, someone might you use your function like this:

```js
counter = count();
completeGenerator(counter);
```

In this case, your function should run all the way through the generator. It doesn't need to print or return anything -- just iterate until it's done.

#### `seededRNG()`

When would we use generators in practice? They can be useful when you have a stateful-service that you will want to access in many different places and at many different times in your application. Redux-Saga is one example of this. Another more simple example would be a random number generator (RNG) that has a fixed seed.

We could build a seeded RNG inside a generator function and then pass around a reference to a single generator object (let's call it `rng`) created by the generator function. This would allow multiple parts of our code to use the same RNG without having to worry about managing the seed. Whenever you need a new random number, you can just iterate `rng` to get it.

Write a generator function, `seededRNG()`, that takes one parameter: `seed`, a 4 digit number.

We are going to use a very simple algorithm to generate random numbers. This algorithm was invented by John Von Neumann (the same guy that invented merge sort and made many other science, math, and computer science contributions). It's also a good way to practice numeric, string, and type operations in JavaScript.

- Square `seed` (4-digits)
    - If you get a number with less than 8 digits, add 0s to the start of `seed` until you get 8 digits (e.g. if you square seed and get 1234567, you need to change it to 01234567).
    - Your random number is the middle four digits (01234567 -> 2345). Remember to convert them back to an integer if they are a string!

This isn't a great random number generator, but if it was good enough for John Von Neumann, it's good enough for us!

Your generator object should be able to continue returning random numbers indefinitely. Each time it generates one, it should increment the seed, so that the next one will be different.

Here's how someone should be able to use your `seededRNG` generator function:

```js
const rng = seededRNG(1111);
const random1 = rng1.next().value;
const random2 = rng1.next().value;
```

Each time `seededRNG()` is given the same seed value, it should produce the same output on its first iteration, second iteration, etc.

### Asynchronicity and Concurrence with Generators

These exercises are intentionally brief so that you will have time to read another great guide on ES6 generators. The guide is written by Kyle Simpson, and the first part is [here](https://davidwalsh.name/es6-generators). It starts off with the basics in part 1 and 2, then goes over advanced usage of generators in parts 3 and 4. If you want to fully understand how Redux Saga uses generators, read part 3 of that guide! Part 4 is also very useful and the whole guide is very well written and easy to understand.
