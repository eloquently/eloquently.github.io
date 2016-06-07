---
layout: post
title: Interview Prep 06 - Stacks
permalink: guides/interview-prep-06
date: 2016-06-06
---

## {{ page.title }}

<hr class="left" />

In this guide we will look at a data structure called a stack. Stacks are analogous to a stack of papers sitting on a desk. You can only add papers to the top of the stack, and when you remove papers, you can only remove them from the top of the stack. This is called a LIFO data structure (last in first out).

Adding a variable to the top of a stack is called a `push`. Removing the top variable from the stack is called a `pop`. Looking at the top element without removing it is called a `peek`.

We are going to implement a stack in JavaScript by creating an object (`Stack`) with an array instance variable. We are going to add three instance methods to the `Stack` class: `push()`, `pop()`, and `peek()`.

### `Stack` Class

#### `constructor()`

We just need a very simple constructor for the `Stack` class. All it needs to do is set `this.arr` to an empty array.

#### `push()`

To add something to the stack, all we need to do is `push()` that element to `this.arr`. Write a function `push()` that takes one parameter, and pushes that parameter to `this.arr` using the built in `push()` function on JavaScript Arrays.

`push()` does not need to return anything.

#### `pop()`

To remove something from the stack, we can just remove the last element from `this.arr` and return it. JavaScript arrays also have a built in `pop()` function that you can use.

#### `peek()`

To peek at the element on the top of the stack, we need to return the last element from `this.arr`.

Now you have implemented a Stack! When you are using this Stack class below, you shouldn't reference `arr` directly. You should only use its `push()`, `pop()`, and `peek()` methods.

### Stack Problems

#### `reverseString()`

Write a function `reverseString()` that takes one parameter `str` and returns a string with the characters from `str` in reverse order.

Your method should use a stack to do the reversal. One approach is to push each character from `str` into a stack. Then create a blank sting and `pop()` the characters off the stack onto the end of the string until the stack is empty.

#### `minValueInStack()`

Write a function `minValueInStack()` that takes one parameter, `stack`, and returns the minimum value in the stack.

After the method is done, the original stack should be left unchanged.

### Stacks in Real Life

#### Call Stack

Stacks can be very useful data structures in real life. When you write a function that calls other functions (or itself recursively), your computer keeps track of all the functions it needs to execute in a stack called the "call stack".

For example, if you have functions that look like this:

```js
const a = () => {
    console.log('the end!');
}

const b = () => {
    console.log('before a');
    a();
    console.log('after a');
}

const c = () => {
    console.log('before b');
    b();
    console.log('after b');
}
```

When you call `c()`, the program will start by printing `before b`, then it will see that it needs to call `b()`. Before starting to execute `b()`, the program will add its current location inside `c()` to the call stack. Then it will start executing `b()`, and print `before a`. Once the program sees that it needs to call `a()`, it will add it's current location inside `b()` to the call stack.

Now the call stack has two elements, the position inside `c()` and the position inside `b()`. Since the position inside `b()` has been most recently added, it will be on the top.

Now the program can execute `a()` and print `the end!`. Now the program sees that `a()` is done executing, so it will `pop()` the top location off the call stack (`b()`) and resume the execution of that function by printing `after a`. Now that `b()` is done, it will pop the next item off the call stack (`c()`) and continue executing from that location by printing `after b`. Now that `c()` is done, and the call stack is empty, the program will terminate.

When your program crashes with an error, it is common to print out the "stack trace". This is just the contents call stack when the program died.

If you have recursion that goes too deep (or you have infinite recursion), your computer may not have enough memory to store the call stack. If this happens, you have an error called "stack overflow" -- which is where your favorite website gets its name!

#### Undo Stack

You can also implement an "undo" functionality using a stack. To do this, you would push the state of the application to a stack after each change is made.

Then when the user wishes to undo something, you simply pop the last state off of the stack and replace that. If they wish to undo multiple steps, you can continue popping off the stack.

You could also have a redo stack that you can push the current state to before undoing an action.

Let's see how that would work with a simple example.

We have put together a very basic word processor. It prompts the user for input and can do three things: 1) `add` the user's text to the end of the document, 2) `undo` the last addition to the document, and 3) `redo` any undone changes.

It is your job to implement the `undo` and `redo` functionality.

Here is an example of how it should work:

```
$ npm run node src/word_processor.js

welcome to the simple word processor
type add TEXT HERE to add text
type undo to undo the last command
type ctrl+c to exit
 > add It was the best of times, it was the worst of times,
your document:
It was the best of times, it was the worst of times,

 > add it was the age of wisdom, it was the age of typos,
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,

 > add it was the epoch of belief, it was the epoch of something
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,
it was the epoch of belief, it was the epoch of something

 > undo
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,

 > add it was the epoch of belief, it was the epoch of incredulity
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,
it was the epoch of belief, it was the epoch of incredulity

 > undo
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,

 > undo
your document:
It was the best of times, it was the worst of times,

 > undo
your document:

 > redo
your document:
It was the best of times, it was the worst of times,

 > redo
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of typos,

 > undo
your document:
It was the best of times, it was the worst of times,

 > add it was the age of wisdom, it was the age of foolishness,
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of foolishness,

 > redo
nothing to redo
your document:
It was the best of times, it was the worst of times,
it was the age of wisdom, it was the age of foolishness,

 > undo
your document:
It was the best of times, it was the worst of times,

 > undo
your document:

 > undo
nothing to undo
your document:
```

A few things to help out:

- Push to the history stack before changing the document.
- Push to the future stack before popping from the history stack when undoing.
- Don't forget to save `doc` to history before redoing
- You'll also need to delete anything from the future stack when new changes are added, or else redo will overwrite those changes.

You shouldn't need to write much code to get this to work! Likely less than 20 new lines will be enough.
