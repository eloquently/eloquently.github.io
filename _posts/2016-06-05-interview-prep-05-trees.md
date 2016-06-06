---
layout: post
title: Interview Prep 05 - Trees
permalink: guides/interview-prep-05
date: 2016-06-05
---

## {{ page.title }}

<hr class="left">

We are going to look at another type of data structure: trees.

Trees are similar to linked lists in that they are a very simple data structure. The only difference between a tree and a linked list is that a node in a linked list points to a single next node, whereas a node in a tree can point to more than one node.

An everyday use of a tree data structure is the file system on your computer. A directory points to many sub-directories and files. The sub-directories can in turn point to other directories or more files. In the following exercises, we will be implementing and working with binary trees -- trees that can only have two children.

Like linked lists, it is natural to use recursion to perform common operations like traversal, search, insertion, and deletion on trees.

### Implementing `TreeNode`

Start implementing a tree by copying your implementation of a linked list node. The only thing that needs to change is that instead of a `next` instance variable, a tree node needs `left` and `right` instance variables.

At the end of your program, code up the following trees. You will use them to test your algorithms and we will base the examples off of them.

It's okay to code the trees like this:

```js
const smallTree_1 = new TreeNode(1);
const smallTree_2 = new TreeNode(2);
smallTree_1.left = smallTree_2;
```

Here are the trees:

```
small tree:
     1
    / \
   2   3

large tree:
     1
    / \
   6   3
  / \   \
 2   4   9
        / \
       5   0
```

### Traversals

Traversing a linked list is straightforward: start at the beginning of the list and visit each element in order. It is less obvious how to traverse a tree because there are two options for the "next" node. The three most common types of traversals are called "pre-order" "in-order" and "post-order".

Solve the following problems recursively! You can implement each of the traversals with about 5 lines of code!

#### Pre-order Traversal

In a pre-order traversal, the algorithm first traverses the left sub-tree, then visits the root, then traverses the right subtree.

Write an algorithm `preorder()` that does a pre-order traversal printing each node's data given one parameter: the root node of the tree (`root`).

For the small tree, your algorithm should print out `213` (separated by newlines).

For the large tree, your algorithm should print `26413590`.

If the parameter is ever `undefined` the function exit by returning `undefined`.

Run your traversals with lines like this at the end of your program:

```js
preorder(smallTree_1);
console.log('---');
preorder(largeTree_1);
```

You can run your program with:

```
npm run node src/trees.rb
```

#### In-order Traversal

In an in-order traversal, the algorithm first visits the root, then traverses the left sub-tree, then traverses the right subtree.

Write an algorithm `inorder()` that does an in-order traversal printing each node's data given one parameter: the root node of the tree (`root`).

For the small tree, your algorithm should print out `123` (separated by newlines).

For the large tree, your algorithm should print `16243950`.

#### Post-order Traversal

In a post-order traversal, the algorithm first traverses the left sub-tree, then traverses the right subtree, then visits the root.

Write an algorithm `postorder()` that does a post-order traversal printing each node's data given one parameter: the root node of the tree (`root`).

For the small tree, your algorithm should print out `231` (separated by newlines).

For the large tree, your algorithm should print `24650931`.

### Searching

Write a function, `basicSearch()`, that takes two parameters, `root` and `needle`, and returns the `TreeNode` object that contains `needle` as the data. It is common to store keys and values in tree nodes, and you might want to search a tree to find the value associated with a particular key. In this case, our `TreeNode`s only have a single data property, so we will just search for the actual node object.

Don't worry about writing an efficient algorithm -- just get one that passes the tests!

You may assume that `needle` will always be somewhere in the tree.

Once the tests pass, what is the time complexity of `basicSearch()`? Is this faster or slower than searching an unsorted array or linked list?

### Binary Search Trees

Binary Search Trees (BSTs) are a type of data structure that can be used to efficiently store and retrieve sorted data.

A BST is a binary tree with a special property: each node must be greater than any node in its left subtree, and each node must be less than any node in its right subtree.

Here are some examples of binary search trees:

```
BST 1:

    5
   / \
  3   8
 / \   \
1   4   10
       /  \
      9   15

BST 2:

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

Given a set of numbers, there can be many ways to arrange them in a BST. The shape of the tree depends on what order the elements were inserted in. Image what BST 2 would look like if 18 has been inserted first.

#### `searchBST()`

Write a function, `searchBST()`, that takes two parameters: the root node of a BST and a `needle` to search for. The function should return the node that has `needle` as its data.

You should write this recursively! This algorithm should be much more efficient than `basicSearch()`. In fact, it should have `O(log(n))` time complexity.

#### `insert()`

Write a function, `insert()`, that takes two parameters: the root of a BST (`root`) and a new value (a number, not a node) to be inserted in the tree (`newValue`). The function does not need to return anything. Make sure that the tree with the element inserted still has the property of a BST discussed above!

You can assume that the new element is unique (not already in the tree).

What is the time complexity of `insert()`?
