---
layout: post
title: React Mini-Project 1 - Shopping List
permalink: 'guides/react-shopping-list'
date: 2016-05-22
---

## {{ page.title }}

<hr class="left" />

The goal for these mini projects is to get you used to writing tests and designing components in React. I suggest that you go through it once implementing and testing all the components before worrying about managing the state with Redux. After completing a few of these mini-procjects, pick one of them and work on adding Redux stores and reducers to it.

One goal for these exercises is to make you more comfortable writing React tests and code. That means that we are not going to give you the program piece by piece (as we did in the [blackjack guides]({% post_url 2016-05-19-react-blackjack-part-1 %}). Instead, we'll give you very general pieces of the code, and you will have to figure out where to go.

Don't worry if you get stuck or don't know where to start -- that's very normal. Before trying to find a tutorial, spend some time thinking about what you are trying to build, and what the next steps are.

This series of guides will hold your hand less and less as you go through them. For example, in this first guide we will tell you all the components you need and what each component should be responsible for. By the end, we'll give you just a description of the finished product and you will be responsible for figuring out how to set up all the components!

Let's get started.

### Shopping List State

This is what one state for the Shopping List Application will look like:

```js
const initialState = fromJS({
    name: 'Groceries',
    items: [
        {
            name: 'Carrots',
            quantity: 2
            purchased: true
        },
        {
            name: 'Broccoli',
            quantity: 1,
            purchased: true
        },
        {
            name: 'Milk',
            quantity: '1 gallon',
            purchased: false
        },
        {
            name: 'Eggs',
            quantity: '2 dozen',
            purchased: false
        }
    ]
});
```

We will use ImmutableJS's immutable `Map`s and `List`s to store the application state. In the above code-block, we use the `fromJS` function provided by ImmutableJS to convert the objects and arrays into `Map`s and `List`s.

### Shopping List Components

This shopping list application will have the following components:

- `<App />`: the `App` component will be the top level component that is responsible for rendering all the other components. There is nothing special about this name -- you could call it something else if you wanted. `<App />` will take the entire application state `Map` as a prop.
- `<ShoppingList />`: The `ShoppingList` component will be responsible for displaying the name of the list and rendering `Item` components for each item in the list. `<ShoppingList />` will take two props: `name` for the name of the list and `items`, which will be an immutable `List`.
- `<Item />`: the `Item` component will be responsible for rendering the name of the item, the quantity to purchase, and it should be styled differently based on whether the item has been purchased already or not.

Here's an example of what the final HTML for the "Carrots" item in the application state above will look like:

```html
<div class="item purchased">
    <span class="quantity">2</span>
    <span class="name">Carrots</span>
</div>
```

Here's what the HTML for the "Eggs" item might look like:

```html
<div class="item">
    <span class="quantity">2 Dozen</span>
    <span class="name">Eggs</span>
</div>
```

When you're done [here's a link to the next one]({% post_url 2016-05-22-react-mini-project-2-list-of-shopping-lists %}).
