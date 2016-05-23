---
layout: post
title: React Mini-Project 3 - Tic Tac Toe
permalink: guides/react-tic-tac-toe
date: 2016-05-22
---

## {{ page.title }}

<hr class="left" />

This application will allow users to play tic tac toe in the browser. Don't worry about the functionality for now. Just make it display a board that correctly reflects the current state.

### Application State

Here's an example of what the state `Map` might look like in the middle of the game.

```js
const initialState = fromJS({
    board: [ ['X', 'O', ''],
             ['X', '', 'O'],
             ['O', '', 'X'] ],
    gameOver: false,
    winner: undefined
});
```

Here's what the state might look like at the end of the game.

```js
const initialState = fromJS({
    board: [ ['X', 'O', ''],
             ['X', 'O', 'O'],
             ['X', '', 'X'] ],
    gameOver: true,
    winner: 'X'
});
```

You can add both `initialState`s to your `index.js` and comment one of them out to switch between the two.

### Components

Here is a suggested list of components for your Tic Tac Toe game:

- `<App />`: render all the other components
- `<Board />`: render the 3x3 board. Hint: use a `map()` inside of a `map()` to render all the components. `<Board />` will take one prop: the 2D array with the
- `<Cell />`: render one individual cell. `<Board />` will render 9 cells
- `<Message />`: render a message saying who won the game. Message only needs one prop: whether the winner was X or O. `<Message />` will also be responsible for displaying a button the user can press to restart the game.

Don't worry about making the buttons work or actually being able to place pieces by clicking. You can add this functionality after designing the components. For now, you can test out different scenarios in your browser by manipulating the state `Map` that is passed to `<App />`.

Your primary means of testing everything should be automated Chai tests!
