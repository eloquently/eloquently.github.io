---
layout: post
title: Interview Prep 03 - Linked Lists
date: 2016-06-01
permalink: 'guides/interview-prep-03'
---

## Interview Prep 03 - Linked Lists

Linked lists are a very simple type of data structure. A linked list is a series of "nodes" with two properties: the data they store and a reference to the next element in the list.

We are going to implement linked lists in JavaScript, write some functions that operate on them, and analyze the complexity of these functions.

### Building a Linked List

We are going to use ES6 class syntax to build a linked list.

First, create a file `linked_lists.js` in the `src` directory. Then, create and export a class called LinkedNode. Next, create a constructor for the class that takes two parameters: `data` and `nextNode`. The constructor will simply set the instance variables `data` and `nextNode` equal to the parameters passed to the constructor. In JavaScript, all parameters are technically optional. If they are not passed, then the value will be `undefined`. This means that we can create a `LinkedNode` without a `nextNode` simply by omitting the second parameter.

Copy your code into the JavaScript console in Chrome (don't include the `export` key word).

Try creating a new LinkedNode by typing this into the console:

```js
const n1 = new LinkedNode(1);
```

Now you can access `n1`'s instance variables with commands like `n1.data` and `n1.nextNode`.

Let's make another node with data `2` called `n2`.

Then we can link `n1` and `n2` with a command like: `n1.nextNode = n2`.

Now we have a linked list!


### `printList()`

Let's write a function that prints out the list. Write a function `printList()` that takes one parameter: the start of the list, and prints out every element in the list until it reaches `undefined`.

Note, it might be better to use named functions than anonymous functions here so that you can more easily override them in the chrome browser. If you do want to save an anonymous function in a variable, use `let` instead of `const`.

```js
// Good
function printList(start) { /* ... */ }

// Okay
let printList = (start) => { /* ... */ };

// Bad
const printList = (start) => { /* ... */ };
```

After you've finished `printList()`, try copying the function to the console, and running `printList(n1)`. If everything went right, you should see 1 and 2 printed out!

Notice that there is no way to tell if a node is actually the start node of a linked list. You could give any node to `printList()` and it will just print any nodes that come after it.

What is the time complexity of `printList()`?

_Vocabulary_: A "traversal" is when you go through each element in a data structure and perform some operation with it (such as printing). The time complexity of `printList()` is the same as complexity as any traversal of a linked list.

### `insert()`

Write a function `insert()` that takes three parameters: the starting node of the list (`start`), the position that the element should be inserted into (`pos`), and the data to be inserted (`data`).

The position can be any number greater than or equal to 0 and less than or equal to the length of the list.

After writing your function, try adding some lines of code to the end to test it out. Something like:

```js
let n1 = new LinkedNode("hello");
n1 = insert(n1, 1, "world");
n1 = insert(n1, 2, "!");

printList(n1);
```

Then run your program with:

```
npm run node src/linked_lists.js
```

You should see the message in your console. Also try inserting something to the beginning of the linked list -- remember that your `insert` function should return the new first element!

Do we need the `n1 =` parts in the lines above? What would happen if we removed them?

After playing around with it and testing everything manually, run the tests.

What is the complexity of your `insert` function? What would be the complexity of an `insertAtBeginning` algorithm that always adds a new node to the first element?

### `index()`

Write a function, `index()`, that takes two parameters, `start` and `pos`. `start` will be the first node in a linked list. `pos` will be an integer greater than or equal to zero and less than the length of the list. `index()` should return the data inside node #`pos`.

Calling `index(node0, 3)` is analogous to calling `arr[3]` on an array. Both will return the data at the fourth position in their respective data structures.

After writing the function, try out your index function in your program and run `npm run node`.

Once it looks like it's working correctly, run the tests! They should start running the tests for index automatically as soon as you create it.

### `remove()`

Write a function, `remove()`, that takes two parameters: `start` and `pos`. `start` is the first node in the linked list and `pos` is the element to be removed. The function should return the first element of the list with the element removed.

Again, play around with `remove()` in your program and then run the tests.

What is the time complexity of `remove()`? What if you are just removing the first element? What would be the time complexity of a remove operation on a node whose position in the list is already known (i.e. you don't have to traverse the list to find it)? How does this compare to the time complexity of removing an element from a JavaScript or Ruby array?
