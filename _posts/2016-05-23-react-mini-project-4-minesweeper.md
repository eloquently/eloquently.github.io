---
layout: post
title: React Mini-Project 4 - Minesweeper
permalink: guides/react-minesweeper
date: 2016-05-23
---

## {{ page.title }}

<hr class="left" />

This application will allow users to play minesweeper in the browser.

Minesweeper is a game that looks like this:

![minesweeper](/img/guides/minesweeper.png)

At the beginning of the game all the tiles are hidden. Some of the tiles contain mines. If you click on one of those tiles, you immediately lose the game. If you click on a tile that does not have a mine, it tells you how many of the adjacent cells (including diagonal cells) contain mines. The number can range from 0-8.

The user can choose to flag a tile where he/she believes there will be a mine in order to remember not to click that tile in the future.

### Application State

For the first crack at this application, the state tree will contain a 10x10 grid of cells. Each cell is an object with three properties: whether the cell is `revealed`, whether the cell contains a `mine`, and whether the cell has been `flagged`. Here is a state tree that you can use for testing your application.

To make it easier to generate different state's to test, I've written a helper function for you that you can use like this:

```js
board = `
xf*..*...*
*xx....*..
.x*.....*.
......*...
..........
....*..*..
.*......*.
.....x*..x
.*..*x.*xx
........xx
`

initialState = strToMinesweeperBoard(board);
```

Here's the function:

```js
const strToMinesweeperBoard = (board) => {
    board = board.trim();
    board_arr = [];
    board.split("\n").forEach((row, i) => {
        board_arr[i] = [];
        row.split('').forEach((cell, j) => {
            board_arr[i][j] = {
                revealed: cell == 'x',
                flagged: cell == 'f',
                mine: cell == 'f' || cell == '*'
            }
        });
    });
    return { board: board_arr };
};
```

Note, this helper function assumes that all flagged cells have mines in them. This won't always be the case. The user might flag a cell that does not contain a mine by accident!

You can change the board string however you want to try out different state configurations.

### Components

Since your state does not contain information for each cell about how many neighboring cells contain mines, you will have to do it in your components. When you render each `<Cell />` from a `Board` component, you will have to pass it a prop that says how many neighbors contain mines. This computation is not trivial, so spend some time thinking about how to do it and write out test cases for different scenarios (literally corner cases).

Other than that additional computation, the general component structure will be similar to the tic tac toe application -- just with 100 cells instead of 9!

With some good styling and a well-written algorithm for detecting neighboring mines, this is could be a portfolio worthy project after adding Redux to handle clicks!
