---
layout: post
title: Interview Prep 09 - Promises
permalink: guides/interview-prep-09
date: 2016-06-09
---

## {{ page.title }}

<hr class="left" />

In this guide, we will look at another relatively new construct in JavaScript called a Promise.

### Callbacks

A common pattern in JavasScript is the use of callback functions. Callback functions work like this:

```js
function fastFunction(cb) {
    cb();
}

fastFunction(() => console.log("I'm a hare"));
```

We have a function, `fastFunction()`, that will immediately call the parameter that is passed to it. We pass a function that logs a message to the console, and that function is executed immediately. When we run the program, the fast function runs right away, and we see `I'm a hare` logged to the console.

Callbacks are commonly used to run things after a long running process (such as an AJAX call). Authors of functions such as jQuery's `$.ajax()` use callbacks to give the user of the function a lot of flexibility -- they can specify anything as the callback function and `$.ajax()` will run whatever they function they provide after the query is complete. `$.ajax()` takes multiple callbacks that can be invoked in different cases. One might run when the request gets a success response, and another might run when the request gets an error response.

### Promises

JavaScript code can often get very messy if callbacks have callbacks that have callbacks which in turn have callbacks. One attempt to clean up this madness is with Promises.

Instead of invoking a callback, a function can return a Promise object. Promise objects have a method `then()`, which takes a function as a parameter. After the promise is resolved, the function attached to the promise by `then()` is executed. Here's what our `fastFunction` would look like using a promise instead of a callback:

```js
function fastFunction(cb) {
    return new Promise((resolve, reject) => {
        resolve();
    })
}

const fastPromise = fastFunction();
fastPromise.then(() => { console.log("I'm a hare") });
```

Our promise immediately calls the `resolve` function, which then immediately triggers the callback function attached by `then`.

`then()` returns a promise, so multiple `then()`s can be chained together:

```js
fastFunction()
    .then(() => { console.log("I'm a hare") })
    .then(() => { console.log("Not a hair"));
```

The `reject` function can be called when there is an error. `then()` attaches a function that is run when the promise is `resolved()`. `catch()` attaches a function that is run when the promise is rejected. Also, `resolve()` and `reject()` can pass data to their callback functions. For example:

```js
function fastFunction(cb) {
    return new Promise((resolve, reject) => {
        const random = Math.random();
        if(random < 0.3) {
            reject(random);
        } else {
            resolve(random);
        }
    });
}

fastFunction()
    .then((num) => { console.log(`today's your lucky day ${num}`) })
    .catch((num) => { console.log(`there was an error ${num}`)});
```

### Async Actions

Certain functions in JavaScript are asynchronous (async for short). This means that when you call them, they will work in the background, and allow the rest of your program to run. One of these functions is `setTimeout()`. `setTimeout` usually takes two parameters: a callback function and a number of milliseconds to wait before invoking the callback function.

Here's how you might use `setTimeout()`:

```js
function slowFunction(cb) {
    setTimeout(cb, 2000);
}

function fastFunction(cb) {
    cb();
}

fastFunction(() => console.log("I'm a hare"));
slowFunction(() => console.log("I'm a tortoise"));
```

If you want to run multiple lines of code after 2000 miliseconds, you would invoke `setTimeout()` like this:

```js
setTimeout(() => {
    console.log('finished sleeping!');
    console.log('where is everyone?');
}, 2000);
```

When we run the `fastFunction()`/`slowFunction()` code block above, we see the `I'm a hare` message, and then two seconds later, we see the `I'm a tortoise` message.

One feature of `setTimeout()` is that it is asynchronous. When `setTimeout(cb, 2000)` is invoked, the rest of your code will still run for two seconds before the tortoise prints his message. In this case, we would see the same thing if we swapped the order of `fastFunction()` and `slowFunction()`:

```js
slowFunction(() => console.log("I'm a tortoise"));
fastFunction(() => console.log("I'm a hare"));
```

The hare will still finish before the tortoise even though the tortoise started first!

Promises work nicely with async functions. For example:

```js
function slowFunction(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, 2000);
    });
}

function fastFunction(cb) {
    cb();
}

slowFunction()
    .then(() => console.log("I'm a tortoise"));
fastFunction(() => console.log("I'm a hare"));
```

Let's say our hare is getting tired of always beating the tortoise. He has decided to give the tortoise a head start by sleeping for somewhere between 1000 ms and 3000 ms (his alarm clock is unreliable).

```js
function slowFunction(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, 2000);
    });
}

function slowHare(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, Math.random()*2000 + 1000);
    });
}

console.log('start the race!');
slowFunction()
    .then(() => console.log("I'm a tortoise"));
slowHare()
    .then((num) => console.log("I'm a hare"));
```

Now the tortoise wins about half the time! If both functions are async, it doesn't matter if we call `slowFunction()` before or after `slowHare()`.

Since we don't know who will finish first, we have what is called a "race condition". If we wanted to do something with the result of `slowHare()` and the result of `slowFunction()`, we would have to wait for them to both finish before we continue with our program. It's easier to imagine such a scenario if the functions are retrieving something from a database rather than just waiting a few seconds and printing a message.

Let's say both our tortoise and hare are bringing us a number, and we want to calculate the sum of their two numbers:

```js
function slowFunction(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(
            () => resolve(Math.floor(Math.random() * 10)),
            2000
        );
    });
}
function slowHare(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(
            () => resolve(Math.floor(Math.random() * 10)),
            Math.random()*2000 + 1000
        );
    });
}

console.log('start the race!');
let tortoiseNum, hareNum, sum;
slowFunction()
    .then((num) => {
        console.log(`I'm a tortoise. My num is ${num}`);
        tortoiseNum = num;
    });
slowHare()
    .then((num) => {
        console.log(`I'm a hare. My num is ${num}`);
        hareNum = num;
        sum = hareNum + tortoiseNum;
        console.log(sum);
    });
```

This works when the hare loses the race, but will fail when the hare wins (because `tortoiseNum` is undefined until the tortoise finishes). These types of bugs can be very frustrating to hunt down because they can be hard to replicate if they only happen 5% of the time.

To handle race conditions, ES6 provides a function called `Promise.all()`.  `Promise.all()` returns a new Promise that is resolved when all of its "subpromises" are resolved. Here's how we would use it:

```js
function slowFunction(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(
            () => resolve(Math.floor(Math.random() * 10)),
            2000
        );
    });
}
function slowHare(cb) {
    return new Promise((resolve, reject) => {
        setTimeout(
            () => resolve(Math.floor(Math.random() * 10)),
            Math.random()*2000 + 1000
        );
    });
}

console.log('start the race!');
let tortoiseNum, hareNum, sum;
const tortoisePromise = slowFunction()
    .then((num) => {
        console.log(`I'm a tortoise. My num is ${num}`);
        tortoiseNum = num;
    });
const harePromise = slowHare()
    .then((num) => {
        console.log(`I'm a hare. My num is ${num}`);
        hareNum = num;
    });

Promise.all([tortoisePromise, harePromise]).then(() => {
    sum = hareNum + tortoiseNum;
    console.log(`Race over! Sum is ${sum}`);
});
```

If you only cared about the winner of the race, you could use `Promise.race()`, which will resolve as soon as the first of its subpromises resolves.
