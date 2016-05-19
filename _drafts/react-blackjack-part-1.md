---
layout: post
title: React Blackjack Part 1
permalink: 'guides/react-blackjack-part-1'
---

## React Blackjack Part 1

<hr class="left" />

We're going to create a blackjack game using React.js and Redux.

## Setting Up

To start, create a directory. I called mine `react_blackjack`.

Use `cd` to navigate to the directory

```
cd react_blackjack
```

We are going to use NPM for this project. [NPM](https://www.npmjs.com/) is a package manager for JavaScript packages.

To initialize a new project using NPM, we run the command `npm init`. This program will ask us a series of questions, and then create a `package.json` file based on our answers. You can use the default answers to the questions by pressing enter. If you don't like the default answer, feel free to type your own before pressing enter.

You should now see a file called `package.json` in your `react_blackjack` directory. Among other things, this file will keep track of the packages our project depends on (similar to a `Gemfile` in Ruby) as well as provide basic information about our project, such as the name, description, and git repository.

### Setting up our Environment

#### Installing NPM and React

To install packages using NPM, we use commands that look like this:

```
npm install --save package_name
```

By default, this will look up a package named `package_name`, download `package_name` to the `node_modules` directory, and add the dependency and its version number to our `package.json` file.

We can specify in our `package.json` file that we only need a certain package (such as a testing library) in development environments by using `--save-dev` instead of `--save` when we install that package.

Let's see what happens when we install `react`. We will need the react library in both the development and production environment, so we use `--save`.

```
npm install --save react
```

This downloaded the `react` library (and the libraries it depends on) into the `node_modules` directory and added the following lines to the `package.json` file:

```js
"dependencies": {
    "react": "^15.0.2"
  }
```

If you were to move your code to another computer (or directory) and ran `npm install`, `npm` would install all the dependencies in your `package.json` file (in our case, just `react`). The caret (`^`) before the version number tells `npm` to install the latest version of `react` that is less than `16.0.0`.

We'll also need the React-DOM package that allows React to render to the DOM.

[comment]: <> (Needs description of react-dom)

```
npm install --save react-dom
```

#### Webpack and Babel

We are going to use Webpack to compile all of our dependencies into a single `.js` file.

[comment]: <> (Needs more details about what webpack is)

Let's install Webpack. Webpack is only used to prepare our application for production, so we won't need it once we're actually in production. Let's install it as a development dependency:

```
npm install --save-dev webpack
```

To run Webpack, we need to find the binary created by NPM. On my system (a Cloud9 workspace), it is in the `node_modules/.bin/` directory. To run Webpack, we'll need to type `node_modules/.bin/webpack` in the terminal.

<p style="background-color:lightblue; margin-bottom: 16px; padding: 20px;">
Other tutorials and guides may install Webpack globally using the `-g` flag. This allows Webpack to be run by typing `webpack` rather than `node_modules/.bin/webpack` on the terminal. We prefer not to use global packages where possible to avoid dependency issues. We'll make a shortcut for this soon.
</p>

We also will need Babel in order to use ES6. Specifically, we want Webpack to run Babel for us on any JavaScript files Webpack tries to build. Babel will transform our ES6 code to a version of JavaScript supported by browsers.

The first step is to install the necessary Babel packages as development dependencies. The `babel-loader` package provides a "loader" that Webpack can use to run Babel. `babel-preset-es2015` and `babel-preset-react` will allow babel to interpret ES6 files and

```
npm install --save-dev babel-core babel-loader babel-preset-es2015 babel-preset-react
```

Now let's create a config file to tell Webpack which files to read and write. Our config file will also tell `webpack` to use Babel when it encounters files that end with `.js` or `.jsx`.

<div class="fp">webpack.config.js</div>
```js
const path = require('path');

module.exports = {
    entry: "./app/index.js",
    output: {
        path: path.join(__dirname, 'build'),
        filename: "bundle.js"
    },
    module: {
        loaders: [
            {
                test: /.js?$/,
                loader: 'babel-loader',
                exclude: /node_modules/
            }
        ]
    },
};
```

We also need to tell `babel` which presets to use while transforming our code. We do this in the `package.json` file:

```js
// package.json
{
    //...
    "babel": {
        "presets": ["es2015", "react"]
    }
}
```

## A First Build

Let's do the first build of our application. We're going to need a few more directories and files.

First, let's make an HTML file that will serve our application:

```html
<!-- build/index.html -->

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>React Blackjack</title>
    </head>
    <body>
        <div id="app"></div>

        <script src="./bundle.js"></script>
    </body>
</html>
```

Now, let's make a JavaScript file that inserts our component into the document.

```jsx
// app/index.js

import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';

ReactDOM.render(
    <App />,
    document.getElementById('app')
);
```

Finally, we need the code for our component:

```jsx
// app/components/app.js

import React from 'react';

export default class App extends React.Component {
    render() {
        return (
            <h1>Hello, world!</h1>
        );
    }
};
```

Now if we run `node_modules/.bin/webpack`, we should see a `bundle.js` file created in the `build/` directory. If we view the `build/index.html` page in a browser, we should see "Hello, world!".

Instead of typing out `node_modules/.bin/webpack` each time we want to run the build process, we can create a script for npm to run in `package.json`. To do so, let's add the following to `package.json`:

```js
// package.json
{
    //...
    "scripts": {
        "webpack": "node_modules/.bin/webpack",
        "webpack:watch": "npm run webpack -- --watch"
    }
}
```

Now we can create `bundle.js` by running `npm run webpack` and if we ant `webpack` to update `bundle.js` each time we save a file, we can run `npm run webpack:watch`

## Talking Through the First Build

The `index.html` file is a pretty typical HTML file. It does not contain any `script` tags in the header, but it does have a `script` tag in the `body`. The `body` also has a single `div`. The `div` is empty to start with, but it is where `bundle.js` will load its components. The `bundle.js` script is the result of the `webpack` compilation of our programs and all of their dependencies. This means we don't need to include separate `script` tags for each of our dependencies (react, react-dom, etc.).

The `index.js` file finds the `div` with an `id` of `app` and renders `<App />` into in using the `ReactDOM.render` method. This is the first time we're seeing JSX in action. JSX is an extenion to JavaScript that allows us to use things that look like HTML or XML elements in code without turning them into strings or functions. Under the hood, there is a JSX preprocessor that converts tags like `<App />` into normal JavaScript functions that eventually return strings of HTML that get output into the browser.

The `app.js` file defines what JavaScript should render when we say `<App />`. We call this the App component. For now, our component is very simple -- it just renders a header, but components can get very complicated. Components can be composed of other components, and they can change their display based on the state of the application passed to the component as "props".

We could have included both the `app.js` file and the `index.js` file in a single file. However, it is generally good practice to keep your components in individual files to organize your code and emphasize that components are meant to be interchangeable and independent.

## Mapping out State

We will be using `redux` to manage our application's state. `redux` requires us to use a single variable to contain all state data. For this application, we'll be using a `Map` from the `Immutable.js` package. A `Map` is analgous to a `Hash` in Ruby or a JavaScript object except it is immutable. That means that every time you want to change a `Map` you will need to make a copy of it and change the copy while leaving the original `Map` alone.

<aside style="background-color:lightblue; margin-bottom: 16px;">It's perfectly fine to use a JavaScript object or any other data structure as a way to keep track of the application's state as long as you are careful not to mutate the state object. We eliminate this concern by using an immutable `Map`.</aside>

We want our state `Map` to keep track of the following variables:

- Player's win count
- Player's loss count
- Player's hand
- Dealer's hand
- Cards remaining in deck
- Current status of game (we'll use a boolean variable called hasStood -- if this is true, it is the dealer's turn to draw)

It can be useful to set up the state of the application so that you have some data to work with while you're working on the components. Let's do that now.

```jsx
// app/index.js
import React from 'react';
import ReactDOM from 'react-dom';
import { Map } from 'immutable'
import App from './components/app.js';



ReactDOM.render(
    <App />,
    document.getElementById('app')
);
```


## Setting Up the State


### Cards and deck

We need to write some helper functions to set up our state. To keep our code organized, let's do so in a new file in a new directory. Create a new folder inside `app/` called `lib/`. Inside `lib/` create a file called `cards.js`.

Let's create a `shuffle` method and a method that will create a new deck. I shamelessly stole the `shuffle` method from Stack Overflow [here](http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript). We'll also need a `newDeck` method that will add a new card to the deck for each rank and suit.

```js
// app/lib/cards.js

import { fromJS } from 'immutable';

export const shuffle = (array) => {
    let j, x, i;
    for (i = array.length; i; i -= 1) {
        j = Math.floor(Math.random() * i);
        x = array[i - 1];
        array[i - 1] = array[j];
        array[j] = x;
    }
};

export const newDeck = () => {
    const ranks = ['A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K'];
    const suits = ['S', 'C', 'H', 'D'];

    const deck = [];

    ranks.forEach( (r) => {
        suits.forEach( (s) => {
            deck.push({ "rank": r, "suit": s});
        });
    });

    shuffle(deck);

    return fromJS(deck);
};
```

In the new deck method, we refer to `deck` as a `const` because it is a constant reference to an array. This means that the array itself may change, but the pointer to the array that we are storing in `deck` is not allowed to change.

```js
const arr = [];
arr.push(1); // This is fine because it mutates an existing array
arr = [1, 2, 3]; // This will break because it replaces the existing array
```

Now we'll import the `newDeck` method into our `index.js` file, and create a new deck.

```js
// app/index.js

import { newDeck } from './lib/cards.js';

const deck = newDeck();
console.log(deck);
```

If you open the page in your browser and open the javascript console (`ctrl` + `shift` + `j` on Windows), you should see an array of Objects. You can click on them to ensure that they have a suit and rank.

We are currently storing `deck` in a mutable array. Let's install Immutable.js and store it in an immutable `List` instead.

```js
npm install --save immutable
```

Immutable.js provides us with a `fromJS` method that allows us to convert JavaScript objects and arrays into immutable `Map`s and `List`s. We can use that method now on our `deck`:

```js
// app/index.js

const deck = fromJS(newDeck());
console.log(deck);
```

Since we're dealing with Immutable.js objects rather than native JavaScript objects, it's hard to view them in the console. To fix that, I installed a [chrome extension](https://chrome.google.com/webstore/detail/immutablejs-object-format/hgldghadipiblonfkkicmgcbbijnpeog) that gives a custom formatter for Immutable.js objects. After you install it, you may need to close the developer tools console and refresh the page. You will also need to enable custom formatters in the developer tools options (access this by pressing `F1` after clicking on the developer tools console).

You should see a `List` containing `Map`s for each card.

## Player and Dealer Hands

The hands for the player and dealer will also be immutable `List`s. We are going to use the `takeLast` and `skipLast` methods from `List` to deal cards. We will also have to change `const deck` to `let deck` as the `deck` variable will be pointing to new immutable `List`s rather than pointing to a single array that mutates.


The code should look something like this:

```js
let deck = fromJS(newDeck());
console.log("start deck:");
console.log(deck);

let playerHand = deck.takeLast(2);
deck = deck.skipLast(2);
let dealerHand = deck.takeLast(2);
deck = deck.skipLast(2);

console.log("end deck:");
console.log(deck);
console.log("playerHand:");
console.log(playerHand);
console.log("dealerHand:");
console.log(dealerHand);
```

Now if you refresh the page and look at the console, you should see that the player and the dealer each have two cards and the deck starts with 52 cards and ends up with 48 cards.

Since we'll be dealing cards from the deck often, let's write a function that deals cards for us. It's annoying and dangerous to rely on printing out all of our results to the console. Let's setup our testing environment and write the tests for our `deal` function before we implement the method.

We're going to use `mocha` as our test framework and `chai` as our assertion library. Let's install those packages now:

```
npm install --save-dev mocha chai
```

To run the tests, we'll use the command

```
mocha --compilers js:babel-core/register --recursive
```

This tells `mocha` to use `babel` to transfrom our code from `ES6` and to search through our project recursively to find any tests to run.

We don't want to type this out each time we want to run our tests, so we can add this to our `webpack.config.js` file.

```js
// webpack.config.js

module.exports = {
    // ...,

    "scripts": {
        "test": "mocha --compilers js:babel-core/register --recursive"
    }
}
```

Now we can run our tests with:

```
npm run test
```

We also want to set up our tests to run each time we save a file (similar to using `guard` in Ruby). To do that, `mocha` provides us with a `--watch` option. Let's add another script to our `webpack` configuration:

```js
// webpack.config.js

module.exports = {
    // ...,

    "scripts": {
        // ...
        "test": "mocha --compilers js:babel-core/register --recursive",
        "test:watch": "npm run test --watch"
    }
}
```

To keep our test code DRY, we are going to want a test helper file that requires all the libraries we will need for testing. Create a folder for tests `test/` and create a `test_helper.js` file inside.

We are going to import `chai` and a library called `chai-immutable` that makes it easy for us to test Immutable.js objects. First, we'll get the package from npm:

```
npm install --save-dev chai-immutable
```

Now we'll add it to our `test_helper.js`:

```js
// test/test_helper.js

import chai from 'chai';
import chaiImmutable from 'chai-immutable';

chai.use(chaiImmutable);
```

To tell `mocha` to load this helper file, we'll add the `--require ./test/test_helper.js` option to our `test` script call in the webpack configuration:

```js
// webpack.config.js

module.exports = {
    // ...,

    "scripts": {
        // ...
        "test": "mocha --compilers js:babel-core/register --require ./test/test_helper.js --recursive",
        "test:watch": "npm run test --watch"
    }
}
```

Now let's write some tests for the `cards.js` file that we had previously been testing with `console.log`. We'll try to mirror our `app/` directory with our `test/` directory, so we'll put this test in `test/lib/cards_spec.js`.

```js
// test/lib/cards_spec.js
import { expect } from 'chai';
import { List } from 'immutable';

import { newDeck } from '../../app/lib/cards';

describe('cards.js', () => {
    describe('newDeck', () => {
        it('returns an immutable list', () => {
            expect(newDeck()).to.be.instanceOf(List);
        });
        it('has 52 elements', () => {
            expect(newDeck().size).to.eq(52);
        });
    });
});
```

This is how you write tests using `mocha` and `chai`. The code looks a lot like the Rails testing library `rspec`. First, we import the necessary modules from external libraries. For these tests, we need to import the `expect` function from `chai`. We also need to import the `List` object from Immutable.JS. Then we import the modules from our code we are testing. In this case, we import `newDeck` and `deal` from the `cards.js` file.

Then we set up a couple of `describe` blocks. These help us organize our tests, and each nested `describe` will show up indented one level in the tests. The first argument passed to `describe` is the name of the thing we are testing. Nothing magical happens with the name string, so feel free to type whatever you want. The second argument is a function that contains more `describe` blocks or tests.

Each `it` block corresponds to one test. Each test should check for one thing and should be mostly independent on other tests. Like the describe blocks, the `it` blocks take a string as the first argument. You should choose a string that reads like a grammatical sentence. The second argument to an `it` block is a function that contains the actual code for our test. This should also sound natural if you say it aloud.

You can read our tests like this:

- Look at `cards.js`.
    - Look at the `newDeck` function.
    - It returns an immutable list
        - Specifically, we expect the result of `newDeck()` to be an instance of `List`
    - It has 52 elements
        - Specifically, we expect the size of `newDeck()` to equal 52

If you save the file and run the tests, they should pass because we've already added the `newDeck` mehod to `cards.js`.

Before we write the `deal` method, we want to write some tests for it `deal` method:

```js
// test/lib/cards_spec.js

// ...

import { newDeck, deal } from '../../app/lib/cards';

// ...

describe('cards.js', () => {
   // ...
   describe('deal', () => {
        const deck = newDeck();
        const n = 5;
        const [new_deck, new_hand] = deal(deck, n);

        it('returns smaller deck', () => {
            expect(new_deck.size).to.eq(52 - n);
        });

        it('returns hand of n cards', () => {
            expect(new_hand.size).to.eq(n);
        });

        it('puts correct cards in hand', () => {
            for(let i = n-1; i >= 0; i--) {
                expect(new_hand.get(i)).to.eq(deck.get(51-(n-1)+i));
            }
        });
    });
});
```

One thing to note about these tests is that we only run the `newDeck` function once inside the `deal` `describe` block. This makes our code more DRY and prevents unnecessary runs of code. We can access variables and constants declared outside of an `it` block as long as they are declared inside the same `describe` as the `it`.

These tests won't run yet because we haven't written the `deal` method. Let's write it now:

```js
// app/lib/cards.js

// ...

// deal n cards from the end of List deck
export const deal = (deck, n) => {
    let dealt_cards = deck.takeLast(2);
    let newDeck = deck.skipLast(2);
    return [newDeck, dealt_cards];
};
```

Now try running the tests. One of them should pass, but there is a small error in the function. Try fixing it. You will know if you fixed it if all the tests pass.

We can now simplify `app/index.js`:

```jsx
// app/index.js

import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';

import { newDeck, deal } from './lib/cards.js';

let deck = fromJS(newDeck());
let playerHand, dealerHand;

[deck, playerHand] = deal(deck, 2);
[deck, dealerHand] = deal(deck, 2);

ReactDOM.render(
    <App />,
    document.getElementById('app')
);
```

The only parts of our application state that we still need to add are the win and loss counts and `hasStood`. Since these are primitive types (integers and booleans), we can just add them to the state `Map` when its created.

Let's now create our state `Map`:

```js
// app/index.js

// ...

import App from './components/app.js';
import { fromJS } from 'immutable';

import { newDeck, deal } from './lib/cards.js';

// ...

const state = fromJS({
    deck,
    playerHand,
    dealerHand,
    "winCount": 0,
    "lossCount": 0,
    hasStood: false
});

console.log(state);

// ...
```

Now when we build the bundle using `webpack` and refresh the browser page, we will see the state `Map` logged to the console.

The next step is to let our components know about `state`. We do this by passing `state` into our `<App />` component as a "prop". `<App />` looks like an HTML tag, and we can pass it variables the same way we give HTML tags properties:

```jsx
// app/index.js

// ...

ReactDOM.render(
    <App state={state} />,
    document.getElementById('app')
);
```

We use the curly braces around `{state}` to indicate to React that it should substitute a variable called `state` for `{state}`.

## A First Pass at Components

Now that we are passing our components some data, we can start thinking about what our components should look like.

### Component Design

One way to design a React front-end is to start with a basic sketch of the entire view, and try to break it down into components. This process can be more of an art than a science, and there is not always a correct way to do this. Generally if you see the same type of element repeated multiple times, that element should be a component.

For our application, we will have an `App` component that contains everything else. The `App` component will contain an `Info` component at the top that displays the player's record and buttons that allow the player to "hit" (draw another card) or "stand" (stop drawing cards). The `App` component will also contain two `Hand` components that show several `Card` components. One of these will represent the player's hand and the other will represent the dealer's hand.

### The `App` Component

The App component is very simple. It will just render the `Info` and `Hand` components as described above.

We're going to use the Enzyme testing utility to test our React components. Enzyme provides us with some helper functions that make rendering and manipulating React objects easier than trying to use the default tools provided by React.

First, let's install React's test utilities and Enzyme:

```
npm install --save-dev react-addons-test-utils enzyme chai-enzyme
```

Next, let's add Enzyme's `chai` assertions to our `test_helper.js`:

```js
// test/test_helper.js

import chai from 'chai';
import chaiImmutable from 'chai-immutable';
import chaiEnzyme from 'chai-enzyme';

chai.use(chaiImmutable);
chai.use(chaiEnzyme());
```

We can use Enzyme's `shallow` function to do a shallow render of our component. Shallow rendering will not render any child components. This allows us to keep our test one component at a time. If we are testing the `App` component, we want it to render an `Info` component. If something is wrong with the `Info` component, but it's still being rendered properly, the `App` component test should pass. Keeping our tests independent allows us to identify the source of a bug more quickly.

Shallow rendering can also boost performance as rendering all children and ancestor components can take a relatively long time in a big application.

The `shallow` function returns an object that has some other useful functions. In this test, we will use the `find` function to search for other elements inside the shallow rendering using CSS selectors (`element`, `#id`, `.class`).

Our first task for the `App` component is to make it render one `Info` component:

```jsx
import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import App from '../../app/components/app';

describe('<App />', () => {
    const rendered = shallow(<App />);

    it('renders <Info /> component', () => {
        expect(rendered.find('Info')).to.have.length(1);
    });
});
```

We did the `shallow` render outside of the `it` block because we will be using `rendered` for multiple tests.

To make the test pass, we need to add the `Info` component to the `render` function in our `App` component:

```jsx
// app/components/app.js

import React from 'react';
import Info from './info';

export default class App extends React.Component {
    render() {
        return (
            <div className="app">
                <h1>React Blackjack</h1>
                <Info />
            </div>
        );
    }
};
```

Note that we kept the `h1`. We had to wrap the entire thing in a `div` because a React component can only have one root HTML element. Without the `div`, we would have `h1` and `Info` on the same level, so we would have two root elements.

Another thing to note is that when we give an element a CSS class in `JSX`, we use `className=` rather than `class=` (the normal way to do it in HTML). This is because `JSX` is still JavaScript, and `class` is a reserved word in JavaScript used when declaring a new class.

We'll also need an `Info` component, so we have something to import and render from the `App` component:

```jsx
// app/components/info.js

import React from 'react';

export default class Info extends React.Component {
    render() {
        return (
            <p>This is the info component</p>
        );
    }
};
```

Now our test for the `App` component should pass.

Next, we want our `App` component to pass some state variables to the `Info` component as props. Specifically, the `Info` component is going to need to know `winCount`, `lossCount`, and `hasStood`. Our test for this looks like:

```jsx
// test/components/app_spec.js

// ...
import { fromJS } from 'immutable';

// ...

import { newDeck, deal } from '../../app/lib/cards.js';

let deck = newDeck();
let playerHand, dealerHand;

[deck, playerHand] = deal(deck, 2);
[deck, dealerHand] = deal(deck, 2);

const state = fromJS({
    deck,
    playerHand,
    dealerHand,
    "winCount": 0,
    "lossCount": 0,
    hasStood: false
});

describe('<App />', () => {
    const rendered = shallow(<App state={state} />);

    // ...

    it('passes props to <Info />', () => {
        expect(rendered.find('Info').first()).to.have.prop('winCount', state.get('winCount'));
        expect(rendered.find('Info').first()).to.have.prop('lossCount', state.get('lossCount'));
        expect(rendered.find('Info').first()).to.have.prop('hasStood', state.get('hasStood'));
    });
});
```

To write this test, we needed to create a state `Map`, just like we did in `index.js`. This is a bit repetitive, but it is okay for now. Once we start using Redux to handle state, we'll DRY this up.

We also want our `App` component to render two `Hand` components -- one for the player's hand and one for the dealer's hand. Let's make a test for this:

```jsx
// test/components/app_spec.js

// ...

describe('<App />', () => {

    // ...

    it('renders two <Hand /> component', () => {
        expect(rendered.find('Hand')).to.have.length(2);
    });
});
```

Let's make a dummy `Hand` component:

```jsx
// app/components/hand.js

import React from 'react';

export default class Hand extends React.Component {
    render() {
        return (
            <p>This is a hand component</p>
        );
    }
};
```

Now the test will pass if we render two `Hand`s in the `App` component:

```jsx
// app/components/app.js

import React from 'react';
import Info from './info';
import Hand from './hand';

export default class App extends React.Component {
    render() {
        console.log(this.props);
        return (
            <div className="app">
                <h1>React Blackjack</h1>
                <Info   winCount={this.props.state.get('winCount')}
                        lossCount={this.props.state.get('lossCount')}
                        hasStood={this.props.state.get('hasStood')} />

                <Hand />
                <Hand />
            </div>
        );
    }
};
```

We also want the `App` component to pass the cards for each `Hand` as a prop:

```jsx
// test/components/app_spec.js

// ...

describe('<App />', () => {

    // ...

    it('passes props to <Hand />s', () => {
        expect(rendered.find('Hand').first()).to.have.prop('cards', state.get("playerHand"));
        expect(rendered.find('Hand').last()).to.have.prop('cards', state.get("dealerHand"));
    });
});
```

Adding the appropriate props to the rendered `Hand` components inside `App` will pass the test:

```jsx
// app/components/app.js

// ...

export default class App extends React.Component {
    render() {
        return (
            <div className="app">

                // ...

                <strong>Player's hand:</strong>
                <Hand cards={this.props.state.get('playerHand')} />
                <strong>Dealer's hand:</strong>
                <Hand cards={this.props.state.get('dealerHand')} />
            </div>
        );
    }
};
```

Now our app component is doing everything it needs to do. Let's start working on the other components.

### The `Info` Component

As stated above, the info component is responsible for a couple things: displaying the win/loss record of the player and some buttons that allow the player to choose to "hit" or "stand".

Let's first write a test to check if the player's record is displayed correctly:

```jsx
// test/components/info_spec.js

import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import Info from '../../app/components/info';

describe('<Info />', () => {
    const rendered = shallow(<Info winCount={1} lossCount={2} hasStood={false} />);

    it('displays record', () => {
        expect(rendered).to.include.text("Wins: 1");
        expect(rendered).to.include.text("Losses: 2");
    });
});
```

To make the test pass, this is what our `Info` component should look like:

```jsx
// app/components/info.js

import React from 'react';

export default class Info extends React.Component {
    render() {
        return (
            <div id="info_bar">
                <span id="player_record">
                    Wins: {this.props.winCount} Losses: {this.props.lossCount}
                </span>
            </div>
        );
    }
};
```

Next, we want to display two buttons -- one with the text "Hit" and one with the text "Stand":

```jsx
// test/components/info_spec.js

// ...

describe('<Info />', () => {
    // ...

    it('shows hit and stand buttons', () => {
        const buttons = rendered.find('button');
        expect(buttons).to.have.length(2);
        expect(buttons.first()).to.have.text('Hit');
        expect(buttons.last()).to.have.text('Stand');
    });
});
```

Now, we'll add the buttons to our component:

```jsx
// app/components/info.js

// ...

export default class Info extends React.Component {
    render() {
        return (
            <div id="info_bar">
                // ...
                <span id="buttons">
                    <button>Hit</button>
                    <button>Stand</button>
                </span>
            </div>
        );
    }
};
```

We want one more behavior from the `Info` component. When `hasStood` is true, the hit and stand buttons should be disabled. Let's refactor our test to account for the two different possible contexts:

```jsx
// test/components/info_spec.js

//...

describe('<Info />', () => {
    describe('when hasStood is false', () => {
        const rendered = shallow(<Info winCount={1} lossCount={2} hasStood={false} />);

        it('displays record', () => {
            expect(rendered).to.include.text("Wins: 1");
            expect(rendered).to.include.text("Losses: 2");
        });

        const buttons = rendered.find('button');
        it('shows hit and stand buttons', () => {
            expect(buttons).to.have.length(2);
            expect(buttons.first()).to.have.text('Hit');
            expect(buttons.last()).to.have.text('Stand');
        });

        it('enables hit and stand buttons', () => {
            buttons.forEach((b) => {
                expect(b).to.not.have.attr('disabled');
            });
        });
    });

    describe('when hasStood is true', () => {
        const rendered = shallow(<Info winCount={1} lossCount={2} hasStood={true} />);

        it('disables hit and stand buttons', () => {
            const buttons = rendered.find('button');
            buttons.forEach((b) => {
                expect(b).to.have.attr('disabled');
            });
        });
    });

});
```

That's all we need for our `Info` component for now. We'll make the buttons actually do something after we set up the `Hand` component.

### The `Hand` and `Card` Components

The `Hand` component has a `List` of cards as a property and is responsible for displaying the cards in that list. We're going to create a Card component, so the first thing we want `Hand` to do is display the correct number of cards and give each one the correct props:

```jsx
// test/components/hand_spec.js

import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import Hand from '../../app/components/hand';

import { newDeck, deal } from '../../app/lib/cards.js';

let deck = newDeck();
let hand;

const n = 2;
[deck, hand] = deal(deck, n);

describe('<Hand />', () => {
    const rendered = shallow(<Hand cards={hand} />);

    it('renders correct number of cards', () => {
        expect(rendered.find('Card')).to.have.length(n);
    });

    it('gives each card the correct props', () => {
        hand.forEach((card, i) => {
            expect(cards.at(i)).to.have.prop('suit', card.get('suit'));
            expect(cards.at(i)).to.have.prop('rank', card.get('rank'));
        });
    });
});
```

Now let's make a dummy `Card` class:

```jsx
// app/components/card.js

import React from 'react';

export default class Card extends React.Component {
    render() {
        return (
            <div className="card">
                Card
            </div>
        );
    }
}
```

Then we'll render these cards from our `Hand` component.

```jsx
// app/components/hand.js

import React from 'react';
import Card from './card';

export default class Hand extends React.Component {
    render() {
        return (
            <div className="hand">
                {this.props.cards.map((card, i) =>
                    <Card suit={card.get('suit')}
                          rank={card.get('rank')}
                          key={i} />
                )}
            </div>
        );
    }
};
```

This render method is a little more complicated than our previous ones, so let's break it down. `this.props.cards` is a `List` object that contains a `Map` for each card. We want to render a `Card` element for each of those `Maps`. To do this, we invoke the `map()` method on `this.props.cards`. The `map()` method returns an array that is the result of applying the function passed to `map()` as a parameter. In this case, we get an array of `<Card>`s with a `card` prop that corresponds to the respective element in the original array.

We need to give each element a unique `key` attribute that React will use to distinguish the elements. In this case, we can just use the position of the element in the array (`i`), but in other cases the choice of `key` may be more complicated.

[comment]: <> (Above paragraphs could use some work)

Now it's time to flesh out our `Card` component. We want each `Card` to display its `suit` and `rank`. We also want the `Card`'s `div` element to have the card's suit as a class so that we can style the card appropriately. These tests are straightforward:

```jsx
// test/components/card_spec.js

import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';
import { fromJS } from 'immutable';

import Card from '../../app/components/card';

const suit = 'C';
const rank = 2;

describe('<Card />', () => {
    const rendered = shallow(<Card suit={suit} rank={rank}/>);

    it('shows suit and rank', () => {
        expect(rendered).to.include.text(suit);
        expect(rendered).to.include.text(rank);
    });

    it('adds a css class for the suit', () => {
        expect(rendered.find(`.card.${suit}`)).to.have.length(1);
    });
});
```

Now let's change our `Card` component so that the test will pass:

```jsx
// app/components/card.js

import React from 'react';

export default class Card extends React.Component {
    render() {
        return (
            <div className={`card ${this.props.suit}`}>
                <div className="top-rank">
                    {this.props.rank}
                </div>
                <div className="suit">
                    {this.props.suit}
                </div>
                <div className="bottom-rank">
                    {this.props.rank}
                </div>
            </div>
        );
    }
}
```

Our tests pass, but if we look at our application in the browser, it is not very user friendly. Let's use SASS to create some css to make our cards look more like cards.

### Setting up SASS and Hot Reload

#### SASS

First we need to configure `webpack` to compile our `.scss` files to `.sass`. Previously, we set up `babel` to transform our ES6 `.js` files. We are going to do something similar for our (not yet created) `.scss` files. First let's install `sass-loader` and `node-sass`:

```
npm install --save-dev style-loader css-loader sass-loader node-sass
```

We'll use `sass-loader` in our `webpack.config.js` file, but `node-sass` will actually do the compilation work.

Next, we need to put this loader into our configuration file:

```js
// webpack.config.js

// ...

module.exports = {
    // ...
    devtool: "source-map",
    "module": {
        "loaders": [
            {
                "test": /.js?$/,
                "loader": 'babel-loader',
                "exclude": /node_modules/
            },
            {
                "test": /\.scss$/,
                "loaders": ["style", "css?sourceMap", "sass?sourceMap"]
            }
        ]
    }
};
```

Now, `webpack` will build our `.scss` files. We've also turned on "source maps", which tell the inspect tool on our browsers which `.scss` file each style comes from. Source maps can slow down build times if you have a large application, but they make debugging much easier.

Now we can start making stylesheet files. We'll have a `main.scss` file that is only responsible for importing all of the other `.scss` files in our application.

```scss
/* app/css/main.scss */

@import 'components/all';
```

Next we'll make a directory called `components/` for our component styles inside our `css/` directory. It is a good practice to keep each component's stylesheet in its own file in order to make your components more modular. If we wanted to make another card game application, we could very easily re-use our card component by copying the `components/card.js` file and the `css/components/card.js` file to a new project.

The `components/` directory will have a file called `_all.scss` that imports each component. It's important to remember to add an import statement to this file each time you create a new `.scss` file.

The `_all.scss` file looks like this:

```scss
/* app/css/components/_all.scss */

@import 'card';
```

And now we can create a `card.scss` file:

```scss
/* app/css/components/card.scss */

.card {
    background-color: blanchedalmond;
    /* Yes -- blanchedalmond is a real color name */
}
```

Finally, we need to import our css file into `index.js` so that `webpack` can find it and include it in our bundle:

```js
// app/index.js

// ...

import { newDeck, deal } from './lib/cards.js';

require('./css/main.scss');

let deck = newDeck();
// ...
```

Now if you open `build/index.html` in the browser, you should see the a nice blanced almond color behind your cards! You may have to restart your `webpack:watch` process because we changed its configuration.

In Chrome, if you right click on a card and hit "inspect", you'll see the DOM tree appear. If you select one of the `<div class="hand">` lines, you should see a list of styles applied to the element. It will tell you that it's getting it's `blanchedalmond` `backround-color` from `card.scss`. This is the source map at work!

#### Hot Reloading/Hot Module Replacement

Another thing worth setting up at this point is "hot reloading". Hot reloading will automatically update the page we're working on in the browser without making us manually refresh. This speeds up the process of checking how changes we make in the code change what the browser renders.

Hot module replacement (HMR) is a is very useful form of hot reloading because, unlike refreshing, it keeps the state of the application intact. This means that if we are working on the message that our application displays when the user wins a game, we don't have to play an entire game of blackjack (and win) each time we make a change to the message. HMR will change the message without resetting the state of the game.

First, we need to get the react-hot-loader package:

```
npm install --save-dev react-hot-loader
```

Then, we need to make some changes to our `webpack.config.js` file:

```js
// webpack.config.js

var webpack = require('webpack');

const path = require('path');

module.exports = {
    "entry": [
        'webpack-dev-server/client?https://0.0.0.0:8080',
        'webpack/hot/only-dev-server',
        './app/index.js'
    ],
    "output": {
        "path": path.join(__dirname, 'build'),
        "filename": "bundle.js"
    },
    devtool: "source-map",
    "module": {
        "loaders": [
            {
                "test": /.js?$/,
                "loader": 'react-hot!babel-loader',
                "exclude": /node_modules/
            },
            {
                "test": /\.scss$/,
                "loaders": ["style", "css?sourceMap", "sass?sourceMap"]
            }
        ]
    },
    devServer: {
        contentBase: './build',
        hot: true
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin()
    ]
};
```

This configuration file works on a Cloud9 instance. If you are not on Cloud9, you may have to replace `'webpack-dev-server/client?https://0.0.0.0:8080'` with `'webpack-dev-server/client?http://localhost:8080'` on line 9.

To run our application, we will use `webpack-dev-server` instead of just opening `index.html` in the browser. To install `webpack-dev-server`:

```
npm install --save-dev webpack-dev-server
```

To run webpack-dev-server, you can type:

```
node_modules/.bin/webpack-dev-server --host $IP --port $PORT
```

If you are not on Cloud9, you don't need the `--host $IP --port $PORT` part.

To save ourselves some typing, let's add this to `package.json`. Remember to omit the `--host $IP --port $PORT` part if you are not on Cloud9.

```js
{
  // ...

  "scripts": {
    "webpack": "node_modules/.bin/webpack",
    "webpack:watch": "npm run webpack -- --watch",
    "test": "mocha --compilers js:babel-core/register --require ./test/test_helper.js --recursive",
    "test:watch": "npm run test -- --watch",
    "webpack-dev-server": "node_modules/.bin/webpack-dev-server --host 0.0.0.0 --port 8080"
  },

  // ...
}
```

Now run the following command in bash:

```
npm run webpack-dev-server
```

If you're on Cloud9, a link should appear to your application. If you're running this locally, you should be able to visit the page by navigating to `localhost:8080` in your browser.

Once you see the application, try changing the `background-color` in `app/css/components/card.scss` (I'd suggest a nice `rosybrown`). When you switch to the browser tab with the application, it should automatically change the background color without requiring you to hit refresh.

### Card Styles

We're not going to go into much depth with SASS. Feel free to use my stylesheet or tweak it however you want. Here's mine:

```scss
/* app/css/components/card.scss */

.card {
    display: inline-block;
    border: 1px solid black;
    height: 150px;
    width: 100px;
    margin: 10px;
    position: relative;
    background-color: ivory;

    .rank {
        padding: 5px;
        font-size: 20px;
    }

    .top-rank {
        @extend .rank;

        position: absolute;
        left: 0;
        top: 0;
    }

    .bottom-rank {
        @extend .rank;
        position: absolute;
        bottom: 0;
        right: 0;
    }

    .suit {
        display: none;
    }

    &.H, &.D {
        color: red;
        border-color: red;
    }

    &:after {
        position: absolute;
        top: 50%; left: 50%;
        transform: translate(-50%,-50%);
        font-size: 40px;
    }

    &.H:after {
        content: '\2665';
    }

    &.D:after {
        content: '\2666';
    }

    &.S:after {
        content: '\2660';
    }

    &.C:after {
        content: '\2663';
    }
}

```

Notice that as you change this file, your browser reloads the stylesheet without changing the cards. This is hot module replacement at work.

Let's also put a little bit of styling on the `Info` component. First, we need to change `components/_all.scss`:

```scss
/* app/css/components/_all.scss */

@import 'card';
@import 'info';
```

Then we can create an `info.scss` file and give it some styles. I'm just going to space things out a little bit.

```scss
/* app/css/components/info.scss */

#info {
    margin-bottom: 10px;

    span {
        margin: 10px;
    }
    button {
        margin: 0 5px;
    }
}
```

Now that our application is looking beautiful (well functional at least), we can move on to implementing some of the game logic.

## Setting up the Game

We haven't thought too much about what our application will need to do in order to play a game of blackjack.

One obvious way to make our game look more like blackjack is that the dealer's first card should be face down -- not face up.

There are a number of different ways to implement this feature. One would be to add a boolean `face_down` property to the `Card` objects we create at the very beginning of the program. This is a viable solution, but for this application, I think of `face_down` as more of display logic than an inherent property of a card.

Another solution is to modify our `Hand` component to just display the first card as face down. There are a few drawbacks here. Sometimes, the `Hand` will need to display the dealer's first card face up, such as when the player chooses "stand" and the dealer starts drawing. This means that our `Hand` component needs to know the `hasStood` state variable. `Hand` also needs to know whether it is the dealer's hand or the player's hand. It's typically a good strategy to limit the number of props being passed into a component. This approach makes our `Hand` component less modular -- it would be harder to use `Hand` in another card game.

Another drawback to both of these approaches is that we are deciding what the card will be before it is shown to the user. Displaying the card face down is just a cosmetic change -- the card's suit and rank are still in the application state. Since we are building a front-end application, the state tree is in the browser, and thus it is available to the user.

The way we will solve this is to set up our `Hand` components to take a dummy card that it will display as a face down card. The dummy card won't come from the deck and won't have a suit or rank. After the player stands, we'll deal an extra card to the dealer and remove the dummy card.

This logic suggests something else about our `deal` function: since the `Deck` object we're playing with is stored in state, the player can tell which card will be dealt next. This ruins the game. Let's fix this first.

### Refactoring the `deal` Function

Let's first add a test for our deal function. If we deal 1 card from the same deck 10 times, they shouldn't all be the same card. This new test will replace the `'puts correct cards in hand'` test.

```js
// test/lib/cards_spec.js

// ...

describe('cards.js', () => {

    // ...

    describe('deal', () => {

        // ...

        it('returns hand of n cards', () => {
            expect(new_hand.size).to.eq(n);
        });

        it('does not deal same card each time', () => {
            const cards = [];
            for(let i = 0; i < 10; i += 1) {
                cards.push(deal(deck, 1)[1].first());
            }
            const all_same = cards.reduce( (prev, curr) => prev && (cards[0] === curr), true );
            expect(all_same).to.eq(false);
        });
    });
});
```

Now we'll change the `deal` function:

```js
// app/lib/cards.js

import { fromJS, List } from 'immutable';

// ...

// deal n cards from random position in deck
export const deal = (deck, n) => {
    if(n == 1) {
        const r = Math.floor(Math.random() * deck.size);
        let dealtCards = new List([deck.get(r)]);
        let newDeck = deck.remove(r);
        return [newDeck, dealtCards]
    }

    let dealtCards = new List();
    let newDeck = deck;
    for(let i = 0; i < n; i += 1) {
        let [d, c] = deal(newDeck, 1);
        dealtCards = dealtCards.push(c.first());
        newDeck = d;
    }
    return [newDeck, dealtCards];
};
```

Your test should pass now. Since we are randomly choosing cards from the deck, there is a `1/(52^9)` chance that they will all be the same. This means that once out of every `2.8 * 10^15` times you run your test, it will fail. I think we can live with those odds!

### Dummy Cards

We are just going to use an empty `Map` object as a dummy card. This means that when we pass `Hand` a `cards` prop with one or more empty `Map`s it should render `Card` objects with a `faceDown=true` prop.

We'll also modify our other test to make sure that the non-dummy cards get `faceDown=false`:

```jsx
// test/components/hand_spec.js

// ...

describe('<Hand />', () => {
    describe('without dummy cards', () => {

        // ...

        it('gives each card the correct props', () => {
            hand.forEach((card, i) => {
                expect(cards.at(i)).to.have.prop('suit', card.get('suit'));
                expect(cards.at(i)).to.have.prop('rank', card.get('rank'));
                expect(cards.at(i)).to.have.prop('faceDown', false);
            });
        });
    });

    describe('with dummy cards', () => {
        const rendered = shallow(<Hand cards={hand.push(new Map())} />);
        const cards = rendered.find('Card');

        it('renders correct number of cards', () => {
            expect(cards).to.have.length(n+1);
        });

        it('gives dummy card faceDown=true', () => {
            expect(cards.last()).to.have.prop('faceDown', true);
        });
    });

});
```

Now let's make the tests pass:

```jsx
// app/components/hand.js

import React from 'react';
import Card from './card';

export default class Hand extends React.Component {
    render() {
        return (
            <div className="hand">
                {this.props.cards.map((card, i) =>
                    <Card suit={card.get('suit')}
                          rank={card.get('rank')}
                          faceDown={!(card.has('suit') && card.has('rank'))}
                          key={i} />
                )}
            </div>
        );
    }
};
```

We want our `Card` class to give face down cards a `face-down` class instead of their `suit` as a class so that we can apply the appropriate styling.

Let's write the test!

```jsx
// test/components/card_spec.js

// ...

describe('<Card />', () => {
    describe('non-dummy card', () => {
        const suit = 'C';
        const rank = 2;

        // ...
    });

    describe('non-dummy card', () => {
        const suit = undefined;
        const rank = undefined;
        const rendered = shallow(<Card suit={suit} rank={rank} faceDown={true} />);

        it('adds face-down class', () => {
            expect(rendered.find('.card.face-down')).to.have.length(1);
        });
    });

});
```

Now the code to make it pass:

```jsx
// app/components/card.js

// ...

export default class Card extends React.Component {
    render() {
        return (
            <div className={`card ${this.props.suit ? this.props.suit : 'face-down'}`}>
                // ...
            </div>
        );
    }
}
```

Now let's change the initial application state to give the dealer one dummy card and one real card.

```js
// app/index.js

// ...

import { fromJS, Map } from 'immutable';

// ...

[deck, dealerHand] = deal(deck, 1);

dealerHand = dealerHand.push(new Map());

// ...
```

And, finally, we'll add a style for `face-down` cards:

```scss
/* app/css/components/card.scss */

.card {
    /* ... */
    &.face-down {
        /* pattern from http://lea.verou.me/css3patterns/ */

        background-color:silver;
        background-image:
        radial-gradient(circle at 100% 150%, silver 24%, white 25%, white 28%, silver 29%, silver 36%, white 36%, white 40%, transparent 40%, transparent),
        radial-gradient(circle at 0    150%, silver 24%, white 25%, white 28%, silver 29%, silver 36%, white 36%, white 40%, transparent 40%, transparent),
        radial-gradient(circle at 50%  100%, white 10%, silver 11%, silver 23%, white 24%, white 30%, silver 31%, silver 43%, white 44%, white 50%, silver 51%, silver 63%, white 64%, white 71%, transparent 71%, transparent),
        radial-gradient(circle at 100% 50%, white 5%, silver 6%, silver 15%, white 16%, white 20%, silver 21%, silver 30%, white 31%, white 35%, silver 36%, silver 45%, white 46%, white 49%, transparent 50%, transparent),
        radial-gradient(circle at 0    50%, white 5%, silver 6%, silver 15%, white 16%, white 20%, silver 21%, silver 30%, white 31%, white 35%, silver 36%, silver 45%, white 46%, white 49%, transparent 50%, transparent);
        background-size:100px 50px;
    }
}
```

Now it looks like we're ready to play blackjack!

## Connecting Components

Before we make those "hit" and "stand" buttons do things, we need to set up our components to automatically update when the state changes.

Specifically, if we add a new card to the player's hand in the state `Map`, we want the `Hand` component to automatically update.

This is where our hard-work setting up an immutable state and pure components pays off. We can now easily use Redux to turn our components into "smart components".

Redux keeps track of the application's state with a `store`. We can modify the state through a "reducer" function. Redux requires us to use a single `store` and a single `reducer()`. `reducer()` must be a pure function -- that is, it must not mutate the current state but rather return a new one. Luckily for us, we are using an immutable `Map` to track state, so we don't have to worry about accidentally mutating state.

Let's install the necessary packages:

```
npm install --save redux react-redux
```

The first step is to create the `reducer` function. This function will take two arguments: the current state and the desired action. It will return the new state after performing the action.

### Simple Actions

The first action we want to build is the `SETUP_GAME` action. When the reducer receives a `SETUP_GAME`, it should set up the deck and hands for the player and dealer. Let's write a test for this:

```js
// test/reducer_spec.js

import { Map } from 'immutable';
import { expect } from 'chai';

import reducer from '../app/reducer';

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        const action = {
            type: 'SETUP_GAME'
        };
        describe("with empty initial state", () => {
            const initialState = undefined;
            const nextState = reducer(initialState, action);

            it('sets up deck', () => {
                expect(nextState.get('deck').size).to.eq(49);
            });

            it('sets up playerHand', () => {
                expect(nextState.get('playerHand').size).to.eq(2);
            });

            it('sets up dealerHand', () => {
                expect(nextState.get('dealerHand').size).to.eq(2);
                expect(nextState.get('dealerHand').last()).to.eq(new Map());
            });

            it('sets up hasStood', () => {
                expect(nextState.get('hasStood')).to.eq(false);
            })
        });
    });
});
```

To get these tests to pass, let's write our first version of the `reducer` function:

```js
// app/reducer.js

import { Map } from 'immutable';

const setupGame = (currentState) => {
    // coming soon
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame(currentState);
    }
    return currentState;
}
```

To keep our code organized, we will have `reducer()` call other functions that actually manage state. This keeps our code more modular.

To fill in `setupGame()`, we'll copy over the code from `index.js`:

```js
// app/reducer.js

const setupGame = () => {
    let deck = newDeck();
    let playerHand, dealerHand;

    [deck, playerHand] = deal(deck, 2);
    [deck, dealerHand] = deal(deck, 1);

    dealerHand = dealerHand.push(new Map());

    const newState = new Map({ deck, playerHand, dealerHand });

    return newState;
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame();
    }
    return currentState;
}
```

The tests should pass now. We also want to be able to send a `SETUP_GAME` action between each of the games in a session. This means that instead of replacing `currentState` with the result of `setupGame()`, we should merge it, so that other state variables like `winCount` won't be lost.

Let's write the test for this behavior:

```js
// test/reducer_spec.js

// ...

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        const action = {
            type: 'SETUP_GAME'
        };

        // ...

        describe("with existing initial state", () => {
            const initialState = new Map({'winCount': 10, 'lossCount': 7, 'deck': 'fake deck'});
            const nextState = reducer(initialState, action);

            it('adds new variables', () => {
                expect(Array.from(nextState.keys())).to.include('deck', 'playerHand', 'dealerHand', 'hasStood');
            });

            it('keeps old variables', () => {
                expect(nextState.get('winCount')).to.eq(10);
                expect(nextState.get('lossCount')).to.eq(7);
            });

            it('overwrites old variables', () => {
                expect(nextState.get('deck')).not.to.eq('fake deck');
            });
        });
    });
});
```

Now to make it pass, we just need to make a couple of small changes in `reducer.js`:

```js
// app/reducer.js

// ...

const setupGame = (currentState) => {

    // ...

    return currentState.merge(newState);
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame(currentState);
    }
    return currentState;
}
```

Now let's add a similar action: `SET_RECORD`. This action will set the player's win and loss records to `0`. First the test:

```js
// test/reducer_spec.js

// ...

describe('reducer', () => {
    describe("SETUP_GAME", () => {

        // ...

    });

    describe("SET_RECORD", () => {
        const action = {
            type: 'SET_RECORD',
            wins: 3,
            losses: 2
        };

        const initialState = new Map({'winCount': 10, 'lossCount': 7, 'deck': 'fake deck'});
        const nextState = reducer(initialState, action);

        it('sets winCount and lossCount', () => {
            expect(nextState.get('winCount')).to.eq(3);
            expect(nextState.get('lossCount')).to.eq(2);
        });

        it('keeps old variables', () => {
            expect(nextState.get('deck')).to.eq('fake deck');
        });
    });
});
```

Then the code:

```js
// app/reducer.js

// ...

const setRecord = (currentState, wins, losses) => {
    return currentState.merge(new Map({ "winCount": wins, "lossCount": losses }));
}

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame(currentState);
        case 'SET_RECORD':
            return setRecord(currentState, action.wins, action.losses);
    }
    return currentState;
}
```

### Action Creators

Instead of writing out actions as objects (e.g: `const action = { type: 'SET_RECORD', wins: 3, losses: 2 };`), we are going to write some helper functions that create the actions for us. This makes our code a little more DRY and organized.

These functions are very simple, so there is no need to write tests for them. They're also going to be short, so we can put them all in one file:

```js
// app/action_creators.js

export function setupGame() {
    return { "type": "SETUP_GAME" }
}

export function setRecord(wins, losses) {
    return {
        "type": "SET_RECORD",
        wins,
        losses
    };
}
```

Now in our `reducer()` tests, we can import and call these functions to create our actions:

```js
// test/reducer_spec.js

// ...
import { setupGame, setRecord } from '../app/action_creators';

import reducer from '../app/reducer';

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        const action = setupGame();

        // ...
    });

    describe("SET_RECORD", () => {
        const action = setRecord(3, 2);

        // ...
    });
});
```

If we dispatch `SETUP_GAME` and `SET_RECORD` with `0` wins and `0` losses, we get the initial values we want for all the state variables (`deck`, `playerHand`, `dealerHand`, `winCount`, `lossCount`, and `hasStood`). When our application starts, we will want to execute both of these actions.

Let's set up a Redux `store` and dispatch some actions to it to get our intiial state in `index.js`. First, we'll create the store and link it with our reducer function:

<div class="file-path">app/index.js</div>
```js
import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';
import {createStore} from 'redux';

import { reducer } from './reducer';

require('./css/main.scss');

let store = createStore(reducer);

// ...
```

<div class="file-path">app/index.js</div>
```js
// ...

import { reducer } from './reducer';
import { setupGame, setRecord } from '../app/action_creators';

require('./css/main.scss');

let store = createStore(reducer);

store.dispatch(setupGame());
store.dispatch(setRecord(0, 0));

// ...
```

Now we need to share the `store` with our React components. `react-redux` provides us with a component called `Provider` that takes care of that for us. We just need to wrap the `App` component with `Provider` and pass `Provider` our `store` as a prop. We'll also change the `state` prop from `App` to get the state from `store`.

<div class="file-path">app/index.js</div>
```jsx
import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';
import {createStore} from 'redux';
import { Provider } from 'react-redux';

import { reducer } from './reducer';
import { setupGame, setRecord } from '../app/action_creators';

require('./css/main.scss');

let store = createStore(reducer);

store.dispatch(setupGame());
store.dispatch(setRecord(0, 0));

ReactDOM.render(
    <Provider store={store}>
        <App />
    </Provider>,
    document.getElementById('app')
);
```

Now if we look at the application in the browser, it should look the same as before we replaced `state` with `store`. Congratulations! You just dispatched your first Redux actions!

### React and Redux DevTools

Let's take a quick break from writing code and check out the DevTools for React and Redux. This guide will talk about how to use the tools in Chrome. They are extremely useful for debugging and developing your application, so if you don't have Chrome, download it and go through this section!

#### React DevTools

You can install the React DevTools [here](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi?hl=en). After adding the extension and refreshing your browser (you may have to restart it), you will see a new tab on the Chrome Developer Tool panel (open with `ctrl+shift+j`).

If you switch to the React tab, you will see a DOM composed of the React components you wrote along with the props being passed to them. This is very useful if you want to see which props a component has.


#### Redux DevTools

While the React DevTools are very useful, they are also not that exciting. The Redux DevTools (install them [here](https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd?hl=en)), on the other hand are pretty cool. It keeps track of all actions dispatched by your application.

We do need to change one thing in our code to get the webtools to work. When we define `store`, we can tell it to use middleware. Middleware functions do things with actions after they are dispatched, but before they reach the reducer. It is easy to write your own middleware, but for now, we will just use a function provided by [someone else](https://github.com/zalmoxisus/redux-devtools-extension).

The Chrome extension attaches a middleware function to `window` called `devToolsExtension()`. We can pass this to `createStore` as the third parameter. The second parameter is for the initial state, but we don't need this so we'll just use `undefined`.

<div class="file-path">app/index.js</div>
```js
// ...

require('./css/main.scss');

let store = createStore(reducer, undefined, window.devToolsExtension ? window.devToolsExtension() : undefined);

// ...
```

Now refresh the page with our application and go to the Redux tab on the DevTool panel (if you don't see the Redux tab on your DevTool panel, restart your browser). If everything is working, you should see three events: `@@INIT`, `SETUP_GAME`, and `SET_RECORD`. These are the actions that our application has dispatched so far. Later, we will make the buttons on the application dispatch actions, and when you click on them, new actions will appear on this list in real-time.

Because reducers are pure functions operating on an immutable state, Redux allows for "time-travel". In practice, this means that it's very easy to go back in time in your application by "undoing" the last action(s). You can do this in the DevTools by simply clicking on the name of an action. If you click on the `SET_RECORD` action, we will be taken back in time to the state of the application before that action was performed.

You can even undo an action that was not the last one performed! Try undoing `SETUP_GAME` and see what happens to the state after `SET_RECORD`.

We can also use the DevTool to dispatch new actions. Click on the dispatcher button and type in:

```js
{
type: "SET_RECORD",
wins: 1,
losses: 0
}
```

When you hit dispatch, look at the new application state at the bottom of the action list. Our components don't update to reflect the new state because they are not yet linked up with the application state in `store`. Let's fix that!

### Mapping State to Props

Right now, our application passes the entire state tree down to the `App` component, which sends the state variables down to it's children components. This process is somewhat wasteful. The `App` component doesn't do anything with `winCount` or `hasStood` -- it just passes those variables straight to the `Info` component. The `App` component still needs to know the state variables `playerHand` and `dealerHand` because it has to pass these to the `Hand` components, but there is no reason for it to know `wincount`, `lossCount` or `hasStood`.

We could simply our components and make them more modular by having each component read from the state tree only the variables it needs. Redux allows us to do this easily with a function called `mapStateToProps`. `mapStateToProps` is going to take the entire state tree as a parameter, and return an object where the keys are names of props for the object.

#### Connecting `<Info>`

For the `Info` component, a `mapStateToProps` function might look something like this:

```js
function mapStateToProps(state) {
  return {
    winCount: state.get('winCount'),
    lossCount: state.get('lossCount'),
    hasStood: state.get('hasStood')
  };
}
```

The React-Redux package gives us a function called `connect` that takes a `mapStateToProps` function as an argument and returns another function that takes a React component as an argument and returns a "smart" component that will automatically update when state changes. A Redux convention is to refer to the "smart" version of a component as a container, so the "smart" version of the `Info` component is the `InfoContainer`. Let's add `mapStateToProps()` to our `info.js` file and create `InfoContainer`:

<div class="file-path">app/components/info.js</div>
```jsx
import React from 'react';
import { connect } from 'react-redux';

export class Info extends React.Component {
    // ...
};

function mapStateToProps(state) {
  return {
    winCount: state.get('winCount'),
    lossCount: state.get('lossCount'),
    hasStood: state.get('hasStood')
  };
}

export const InfoContainer = connect(mapStateToProps)(Info);
```

Since we've changed the export for `info.js`, we need to modify the imports for `info_spec.js`:

<div class="file-path">test/components/info_spec.js</div>
```js
import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import { Info } from '../../app/components/info';
```

Now, we should change our `App` component to render `<InfoContainer>` rather than `<Info>`. We also no longer need to pass any props because now `<InfoContainer>` is getting them straight from the `store`! Let's change our `App` component tests to reflect these changes we want to make:

```jsx
// test/components/app_spec.js

// ...

describe('<App />', () => {
    const rendered = shallow(<App state={state} />);

    it('renders one <InfoContainer /> component', () => {
        expect(rendered.find('Connect(Info)')).to.have.length(1);
    });

    // removed passes props to <Info /> test

    it('renders two <Hand /> components', () => {
        // ...
    });

    it('passes props to <Hand />s', () => {
        // ...
    });
});
```

Redux-React calls the connected components `<Connect(COMPONENT NAME)>`, so we need to check for that component in our shallow rendering rather than `<InfoContainer>`.

Now let's make the test pass by changing `<App>`'s `render` function:

<div class="file-path">app/components/app.js</div>
```jsx
// ...

export class App extends React.Component {
    render() {
        return (
            <div className="app">
                <h1>React Blackjack</h1>
                <InfoContainer />
                // ...
            </div>
        );
    }
};

```

Great! Now let's look at the application in the browser. Try dispatching some `SET_RECORD` actions from the Redux DevTools and watch your application instantaneously update!

#### Connecting `<App>`

Now that we have `<Info>` connected, let's write a `mapStateToProps` function for `<App>` and create the `AppContainer` class;

<div class="file-path">app/components/app.js</div>
```jsx
// ...
import { connect } from 'react-redux';

export class App extends React.Component {
    // ...
};

function mapStateToProps(state) {
  return {
    playerHand: state.get('playerHand'),
    dealerHand: state.get('dealerHand')
  };
}

export const AppContainer = connect(mapStateToProps)(App);
```

Instead of reading `playerHand` and `dealerHand` from the state `Map`, these are just passed directly as props, so we need to make a couple small changes to the `render` function:

<div class="file-path">app/components/app.js</div>
```jsx
// ...
export class App extends React.Component {
    render() {
        return (
            <div className="app">
                // ...
                <Hand cards={this.props.playerHand } />
                <strong>Dealer's hand:</strong>
                <Hand cards={this.props.dealerHand } />
            </div>
        );
    }
};
```

We also need to change our `app_spec.js` to pass these props individually to `<App>` rather than passing the entire state `Map`:

<div class="file-path">test/components/app_spec.js</div>
```
// ...

describe('<App />', () => {
    const rendered = shallow(<App playerHand={playerHand} dealerHand={dealerHand} />);

    // ...
});
```

The only thing left to do is to change the component that we're rendering in `index.js`:

<div class="file-path">app/index.js</div>
```
// ...

ReactDOM.render(
    <Provider store={store}>
        <AppContainer />
    </Provider>,
    document.getElementById('app')
);
```

Now we can run the application in the browser, and you should see the cards changing if you try dispatching `SETUP_GAME` actions!

### A Pure Deck

While dispatching and removing `SETUP_GAME` actions, you may have noticed that the application doesn't always behave as you would expect. For example, if you dispatch a second `SETUP_GAME` action, and then undo the first `SETUP_GAME`, the cards change! Because the second `SETUP_GAME` action is simply overwriting the state variables set by the first `SETUP_GAME` action, undoing the first `SETUP_GAME` shouldn't have any affect on the current application state.

Why does this happen? Because `newDeck()` and `deal()` are not pure functions. A pure function has two characteristics:

- A pure function always returns the same value when it's given the same parameters.
- A pure function does not have any side effects (e.g. mutating the parameters or other state variables).

#### Pure `deal()`

Our `deal()` is impure because it returns different results when we pass it the same `deck` and `n`. We actually did this on purpose so that users wouldn't be able to tell which card is coming next! Oops.

To fix this, we need to change the way we calculate random numbers. By default, `Math.random()` will calculate a random number using an arbitrary seed. We can fix this by using a random number generator that allows us to control the seed. Let's install such a generator from `npm`:

```
npm install --save seedrandom
```

To make `deal()` a pure function, we'll give it an extra parameter: the seed we want `seedrandom` to use. Let's write the tests that describe how `deal()` should behave when it takes a seed as a parameter:

```js
// test/lib/cards_spec.js

// ...

describe('cards.js', () => {

    // ...

    describe('deal', () => {

        // ...

        it('deals same card each time with same seed', () => {
            const cards = [];
            for(let i = 0; i < 10; i += 1) {
                cards.push(deal(deck, 1, 1)[1].first());
            }
            const all_same = cards.reduce( (prev, curr) => prev && (cards[0] === curr), true );
            expect(all_same).to.eq(true);
        });

        it('does not deal same card each time with different seeds', () => {
            const cards = [];
            for(let i = 0; i < 10; i += 1) {
                cards.push(deal(deck, 1, i)[1].first());
            }
            const all_same = cards.reduce( (prev, curr) => prev && (cards[0] === curr), true );
            expect(all_same).to.eq(false);
        });
    });
});
```

Now let's change the `deal` function to pass the test. We'll need to replace `Math.random()` with `seedrandom` and add the seed parameter to the recursive call:

<div class="file-path">app/lib/cards.js</div>
```js
import { fromJS, List } from 'immutable';
import seedrandom from 'seedrandom';

// ...

// deal n cards from arbitrary position in deck
export const deal = (deck, n, seed) => {
    if(n == 1) {
        const r = Math.floor(seedrandom(seed)() * deck.size);
        let dealtCards = new List([deck.get(r)]);
        let newDeck = deck.remove(r);
        return [newDeck, dealtCards]
    }

    let dealtCards = new List();
    let newDeck = deck;
    for(let i = 0; i < n; i += 1) {
        let [d, c] = deal(newDeck, 1, seed + i);
        dealtCards = dealtCards.push(c.first());
        newDeck = d;
    }
    return [newDeck, dealtCards];
};
```

Now we'll need to change the `SETUP_GAME` action to use this pure version of `deal()`. We'll add a seed to the action creator that is the current system time by default.

<div class="file-path">app/action_creators.js</div>
```js
export function setupGame(seed=new Date().getTime()) {
    return { "type": "SETUP_GAME", seed };
}

// ...
```

Finally, we need to change the `reducer` function to pass this seed along to `deal()`:

<div class="file-path">app/reducer.js</div>
```js
// ...

const setupGame = (currentState, seed) => {

    // ...

    [deck, playerHand] = deal(deck, 2, seed);
    [deck, dealerHand] = deal(deck, 1, seed + 1);

    // ...
};

// ...

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame(currentState, action.seed);
        // ...
    }
    return currentState;
}
```

#### Pure `newDeck()`

We need to make similar changes to the `newDeck` function -- specifically the `shuffle` helper function.

First, let's write the tests:
<div class="file-path">test/lib/cards_spec.js</div>
```js
// ...

describe('cards.js', () => {
    describe('newDeck', () => {

        // ...

        it('returns same deck with same seed', () => {
            expect(newDeck(1)).to.eq(newDeck(1));
        });

        it('returns different deck with different seeds', () => {
            expect(newDeck(1)).not.to.eq(newDeck(2));
        });
    });

    // ...

});
```

Now let's change `newDeck()` and `shuffle()`:

<div class="file-path">app/lib/cards.js</div>
```js
// ...

export const shuffle = (array, seed) => {
    // ...

    for (i = array.length; i; i -= 1) {
        j = Math.floor(seedrandom(seed + i)() * i);

        // ...
    }
};

export const newDeck = (seed) => {
    // ...

    shuffle(deck, seed);

    // ...
};

// ...
```

And finally, let's change `reducer()`:
<div class="file-path">app/reducer.js</div>
```js
// ...

const setupGame = (currentState, seed) => {
    let deck = newDeck(seed);

    // ...
};
```

Now if you add and delete `SETUP_GAME` events in the Redux DevTools, you shouldn't see the cards change when you undo an old `SETUP_GAME` and if you undo the most recent `SETUP_GAME`, you should see the cards that used to be there!

This is a small example of how things can go wrong with Redux if your `reducer` function isn't pure or if you accidentally mutate state. It also shows how easy it is to accidentally introduce an impure function.

### Mapping Dispatch to Props

Now we finally get to make those buttons do something when clicked. Let's work on "hit" first.

#### The "Hit" Button

The hit button needs to add a card to the player's hand. We want to dispatch a `DEAL_TO_PLAYER` action when the button is pressed. Let's first write the action creator for `DEAL_TO_PLAYER`:

<div class="file-path">app/action_creators.js</div>
```js
// ...

export function dealToPlayer(seed=new Date().getTime()) {
    return { "type": "DEAL_TO_PLAYER", seed };
}
```

When this action is dispatched, we should add a card to `playerHand`. Let's write the test:

<div class="file-path">test/reducer_spec.js</div>
```js
import { Map, List } from 'immutable';
import { expect } from 'chai';
import { setupGame, setRecord, dealToPlayer } from '../app/action_creators';
import { newDeck } from '../app/lib/cards.js';

import reducer from '../app/reducer';

describe('reducer', () => {
    // ...

    describe("DEAL_TO_PLAYER", () => {
        const action = dealToPlayer();
        const initialState = new Map({"playerHand": new List(), "deck": newDeck()});
        const nextState = reducer(initialState, action);

        it('adds one card to player hand', () => {
            expect(nextState.get('playerHand').size).to.eq(initialState.get('playerHand').size + 1);
        });

        it('removes one card from deck', () => {
            expect(nextState.get('deck').size).to.eq(initialState.get('deck').size - 1);
        });
    });
});
```

Now let's add the method to `reducer()`:

<div class="file-path">app/reducer.js</div>
```js

// ...

const dealToPlayer = (currentState, seed) => {
    const [deck, newCard] = deal(currentState.get('deck'), 1, seed);

    const playerHand = currentState.get('playerHand').push(newCard.get(0));

    return currentState.merge(new Map({ deck, playerHand }));
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        // ...

        case 'DEAL_TO_PLAYER':
            return dealToPlayer(currentState, action.seed);
    }
    return currentState;
}
```

Now try dispatching some `DEAL_TO_PLAYER` actions in the Redux DevTools. If everything seems to be working, it's time to set up the "hit" button to dispatch this action when it is clicked.

Redux-React provides us with a way to connect props and actions. We are first going to modify the `Info` component so that the "hit" button will run call some function when it is pressed. We will pass the function it should call into the component as a prop.

Let's first write the test. We are going to use a new testing utility called Sinon. Sinon allows us to "spy" on functions to see how many times they've been called and with what parameters. It has some other very useful features. [Here](http://jaketrent.com/post/sinon-spies-vs-stubs/) is a quick guide and [here](http://sinonjs.org/) is the full documentation with plenty of examples.

For this test, we'll use a Sinon spy as the prop we pass to `Info` that will eventually end up as the action on the "hit" button. We'll then simulate a click event and expect that the spy has been called once.

First, let's install Sinon:

```
npm install --save-dev sinon
```

Now let's write the test:

<div class="file-path">test/components/info_spec.js</div>
```jsx
// ...
import sinon from 'sinon';
import { shallow, simulate } from 'enzyme';

// ...

describe('<Info />', () => {
    describe('when hasStood is false', () => {
        const onClickHitSpy = sinon.spy();
        const rendered = shallow(<Info winCount={1}
                                       lossCount={2}
                                       hasStood={false}
                                       dealToPlayer={onClickHitSpy}
                                       />);

        // ...

        it('invokes prop function when Hit is clicked', () => {
            buttons.first().simulate('click');
            expect(onClickHitSpy.calledOnce).to.eq(true);
        });
    });

    // ...

});
```

To make our test pass, let's add this functionality to the `Info` component:

<div class="file-name">app/components/info.js</div>
```jsx
// ...

export class Info extends React.Component {
    render() {
        return (
            <div id="info">
                // ...
                <span id="buttons">
                    <button disabled={this.props.hasStood} onClick={this.props.onClickHit}>Hit</button>
                    // ...
                </span>
            </div>
        );
    }
};

// ...
```

Now, our pure `Info` component will call any function we pass to it as a prop. We want our connected `InfoContainer` to use the correct function as a prop.

We can do this with a `mapDispatchToProps` function that looks like `mapStateToProps()`:

<div class="file-path">app/components/info.js</div>
```js
// ...

function mapStateToProps(state) {
  // ...
}
const mapDispatchToProps = (dispatch) => {
  return {
    onClickHit: () => {
      dispatch(dealToPlayer())
    }
  }
}

export const InfoContainer = connect(mapStateToProps, mapDispatchToProps)(Info);
```

If you look at the application in the browser and click on "Hit", you should get another card!

#### The "Stand" Button

We're going to follow the same steps to add the functionality for the "Stand" button. At this point in the tutorial you should be able to do this yourself. Try to do it by following the steps listed above before checking your work with my solution below.

First, add a `STAND` action:

<div class="file-path">app/action_creators.js</div>
```js
// ...

export function stand() {
    return { "type": "STAND" };
}
```

We want the stand action to change the `hasStood` state variable to false. Here's what the `reducer()` test looks like:

<div class="file-path">test/reducer_spec.js</div>
```js
// ...

import { setupGame, setRecord, dealToPlayer, stand } from '../app/action_creators';

// ...

describe('reducer', () => {
    // ...

    describe("STAND", () => {
        const action = stand();
        const initialState = new Map({"hasStood": false});
        const nextState = reducer(initialState, action);

        it('sets hasStood to true', () => {
            expect(nextState.get('hasStood')).to.eq(true);
        });
    });
});
```

Now we add `STAND` to the `reducer` function:

<div class="file-path">app/reducer.js</div>
```js
// ...

const stand = (currentState) => {
    return currentState.merge(new Map({"hasStood": true}));
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SETUP_GAME':
            return setupGame(currentState, action.seed);
        case 'SET_RECORD':
            return setRecord(currentState, action.wins, action.losses);
        case 'DEAL_TO_PLAYER':
            return dealToPlayer(currentState, action.seed);
        case 'STAND':
            return stand(currentState);
    }
    return currentState;
}
```

Now we add the prop and map it to dispatch in the `Info` component. First the test:

<div class="file-path">test/components/info_spec.js</div>
```jsx

// ...

describe('<Info />', () => {
    describe('when hasStood is false', () => {
        const onClickHitSpy = sinon.spy();
        const onClickStandSpy = sinon.spy();
        const rendered = shallow(<Info winCount={1}
                                       lossCount={2}
                                       hasStood={false}
                                       onClickHit={onClickHitSpy}
                                       onClickStand={onClickStandSpy}
                                       />);
        // ...

        it('invokes prop function when Hit is clicked', () => {
            buttons.last().simulate('click');
            expect(onClickStandSpy.calledOnce).to.eq(true);
        });
    });

    // ...

});
```

Then the code:

// app/components/info.js
```jsx

// ...

import { dealToPlayer, stand } from '../action_creators';

export class Info extends React.Component {
    render() {
        return (
            <div id="info">
                // ...
                <span id="buttons">
                    <button disabled={this.props.hasStood}
                            onClick={this.props.onClickHit}>
                        Hit
                    </button>
                    <button disabled={this.props.hasStood}
                            onClick={this.props.onClickStand}>
                        Stand
                    </button>
                </span>
            </div>
        );
    }
};

const mapStateToProps = (state) => {
  // ...
}
const mapDispatchToProps = (dispatch) => {
    return {
        onClickHit: () => {
            dispatch(dealToPlayer());
        },
        onClickStand: () => {
            dispatch(stand());
        }
    };
};

export const InfoContainer = connect(mapStateToProps, mapDispatchToProps)(Info);
```

Now when you hit "Stand", the buttons will be disabled.
