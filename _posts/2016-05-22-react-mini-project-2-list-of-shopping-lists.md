---
layout: post
title: React Mini-Project 2 - List of Shopping Lists
permalink: 'guides/react-list-of-shopping-lists'
date: 2016-05-22
---

## {{ page.title }}

<hr class="left" />

One of the goals when designing and implementing components in React is that they should be modular. This means that they should be able to re-use them in multiple projects. For this mini-project, we will re-use some of the components from the [shopping list mini-project](react-shopping-list).

To build a modular component, it is important to make each component as indepedent of the overall application is possible. For the most part, this means that the component shouldn't be receiving any props that it doesn't need, and the component only depends on its props to decide how it should render. It shouldn't make any assumptions about what its parent component or any other component in the application looks like.

It's worth refactoring your components from the shopping list mini project to make the more modular if any improvements come to mind.

In this project, you'll be building an application that displays multiple shopping lists at the same time. This means that you can reuse the `<List />` component and the `<Item />` component that you used in the application that displays a single shopping list.

Note: start this project in a new directory. Pretend like its a completely new project, even though your code will look pretty similar to the last part. This will give you more practice writing the code and hopefully it will be easier the second time around. Keep writing tests for everything! The more practice the better.

### Application state

Use the application state from the shopping list project to make a `List` of several shopping lists. We might want this application to keep track of the office supplies and electronics we need to buy. Make a couple more shopping lists for these categories (or whatever else you might want!). You can keep using the `fromJS` function -- you'll just change it's parameter from a single list object to an array of lists.

### Application components

This application will use the same components as the single shopping list. You just need to figure out how to make it display more than 1!

One other feature you should add: Each list should tell you how many items have not been purchased yet. You can put it next to the name (such as "Groceries - 3 items remaining") or somewhere else inside the `ShoppingList` component.
