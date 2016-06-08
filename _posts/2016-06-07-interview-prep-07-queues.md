---
layout: post
title: Interview Prep 07 - Queues
permalink: guides/interview-prep-07
date: 2016-06-08
---


## {{ page.title }}

<hr class="left" />

A queue is a data structure similar to a stack. The only difference is that the first item into a queue is the first item out (as you would expect in a real-world line or queue at the grocery store). We call this type of data structure FIFO (first in first out).

Let's implement a queue. Like we did for stacks, we will create a `Queue` class with an instance variable array, `arr`. Like we did with stacks, you should not directly access `arr` in your solutions to the exercise -- only use the instance methods we will write for the `Queue` class.

### `Queue` Class

Create a file `src/queue.js` to store our queue class and other functions.

#### `constructor()`

Write a constructor for the `Queue` class. It needs to initialize an empty array in `this.arr`.

#### `push()`

To add something to the end of a `Queue`, we will perform an push operation operation, which will look exactly the same as `push()` for stacks.

Write an instance method, `push()` that takes one parameter, `newValue` and adds it to the end of `this.arr` using the built in `push()` function.

#### `shift()`

Write a `shift()` function that will remove the first item from the queue. You can use the built in array method, `shift()`. `shift()` does not take any parameters, but it does return the item from the array.

We call this function `shift()` because it removes the first item, then shifts the second item to the first item spot, the third item to the second item spot, etc.

#### `peek()`

Write a `peek()` function that will return the first item from the queue without removing it from the queue.

### Queue Problems

#### `levelOrder()`

Write an function `levelOrder()` that will perform a level-order traversal on a binary tree. (See the test code for the `TreeNode` specification). `levelOrder()` will take one parameter, `root` which is the root node of the tree it is to traverse. `levelOrder()` will print each node of the tree from top-to-bottom and left-to-right on each level of the tree. For example, if the trees look like this:

```
tree 1:

    1
   / \
  6   3
 / \   \
2   4   9
   /     \
  5       0

tree 2:

  9
   \
    10
     \
      18
     /  \
    11   28
     \
     13
```

The level-order traversal of tree 1 is: `1 6 3 2 4 9 5 0`, and the level-order traversal of tree 2 is: `9 10 18 11 28 13`.

It is natural to use a queue to perform breadth-first operations. One way to do a level-order traversal of a tree is like this:

- Add the root node to a queue
- While the queue is not empty:
    - Remove the first node from the queue, call it `node`
    - Visit `node` (in this case, print out it's data)
    - Add `node.left` to the queue if `node.left` exists
    - Add `node.right` to the queue if `node.left` exists

Try working through tree 1 above manually using this algorithm to convince yourself that it works.

#### `breadthFirstSearch()`

Write a function, `breadthFirstSearch()` that will use a queue to do a breadth-first search (BFS) of a tree. This function will take two parameters: the root node of the tree and `needle`, the element we are searching for.

The function should return the node that it has data equal to `needle`.

You can assume that the `needle` will always be in the tree.
