---
layout: post
title: React Blackjack Part 1
permalink: 'guides/react-blackjack-part-1'
---

## React Blackjack Part 1

<hr class="left" />

We're going to create a blackjack game using React.js and Redux. This time we'll be starting with a completely empty directory and setting up all the tools in the guide -- no boilerplate here!

What's the point of setting everything up from scratch? Because there are so many different options as far as which tools to use, when you start working on projects with other developers or building something off of code someone else wrote, you won't always be able to use a pre-made repository with all the tools you are used to.

You may have to learn a new toolset or figure out how to add the tools you prefer to the project. Going through the installation of these tools will help you understand how everything fits together and which packages are responsible for what. We don't install everything right away, but instead add dependencies to our project as they're needed.

It's also somewhat common to ask candidates what tools they use and to ask them to describe how various packages fit together to make sure the candidate really understands how a platform works.

Here's a preview of what we'll be building:

<p style="text-align: center">
    <img src="/img/react_blackjack/start_screen.png" alt="Start Screen" title="Start Screen">
</p>

Let's get started!

## Setting Up

To start, create a directory. I called mine `react_blackjack`.

Use `cd` to navigate to the directory

```
cd react_blackjack
```

We are going to use NPM for this project. [NPM](https://www.npmjs.com/) is a package manager for JavaScript packages.

To initialize a new project using NPM, we run the command `npm init`. This program will ask us a series of questions, and then create a `package.json` file based on our answers. You can use the default answers to the questions by pressing enter. If you don't like the default answer, feel free to type your own before pressing enter. Don't worry too much about the answers, you can always change them later in `package.json`.

You should now see a file called `package.json` in your `react_blackjack` directory. Among other things, this file will keep track of the packages our project depends on (similar to a `Gemfile` in Ruby) as well as provide basic information about our project, such as the name, description, and git repository.

### Setting up our Environment

#### Installing NPM and React

To install packages using NPM, we use commands that look like this:

```
npm install --save package_name
```

By default, this will look up a package named `package_name`, download `package_name` to the `node_modules` directory, and add the dependency and its version number to our `package.json` file.

We can specify in our `package.json` file that we only need a certain package (such as a testing library) in development environments by using `--save-dev` instead of `--save` when we install that package.

Let's see what happens when we install the `react` package. We will need React in both the development and production environment, so we use `--save`. If you omit the `--save` tag, the package will still be installed, but it won't be added to your `package.json` file. If you ever forget `--save`, go ahead and run the command again.

```
npm install --save react
```

This downloaded the React package (and the packages it depends on) into the `node_modules` directory and added the following lines to the `package.json` file. You don't need to type these, just verify that they are in `package.json`.

```js
"dependencies": {
    "react": "^15.0.2"
  }
```

If you moved your code to another directory or a completely different file and ran `npm install`, NPM would install all the dependencies in your `package.json` file (in our case, just `react`). The caret (`^`) before the version number tells NPM to install the latest version of `react` that is less than `16.0.0` and greater than `15.0.2` (the latest version when this guide was last updated).

We'll also need the ReactDOM package that allows React to render its components to the DOM.

<!-- [comment]: <> (Needs description of react-dom) -->

```
npm install --save react-dom
```

#### Webpack and Babel

We are going to use Webpack to compile all of our dependencies into a single `.js` file.

<!-- [comment]: <> (Needs more details about what webpack is) -->

Let's install Webpack. Webpack is only used to prepare our application for production, so we won't need it once we're actually in production. Let's install it as a development dependency:

```
npm install --save-dev webpack
```

To run Webpack, we need to find the binary created by NPM. On my system (a Cloud9 workspace), it is in the `node_modules/.bin/` directory. To run Webpack, we'll need to type `node_modules/.bin/webpack` in the terminal.

<p style="background-color:lightblue; margin-bottom: 16px; padding: 20px;">
Other tutorials and guides may install Webpack globally using the `-g` flag. This allows Webpack to be run by typing `webpack` rather than `node_modules/.bin/webpack` on the terminal. We prefer not to use global packages where possible to avoid dependency issues. We'll make a shortcut for running Webpack soon.
</p>

We also will need a package called Babel in order to use ES6 and React's JSX (more on that in a bit). Specifically, we want Webpack to run Babel for us on any JavaScript files Webpack tries to build. Babel will transform our ES6 code to a version of JavaScript supported by browsers.

The first step is to install the necessary Babel packages as development dependencies. The `babel-loader` package provides a "loader" that Webpack can use to run Babel. `babel-preset-es2015` and `babel-preset-react` will allow babel to interpret ES6 files and JSX respectively.

```
npm install --save-dev babel-core babel-loader babel-preset-es2015 babel-preset-react
```

Now let's create a config file to tell Webpack which files to read and write. Our config file will also tell Webpack to use Babel when it encounters files that end with `.js` or `.jsx`. The config file will be called `webpack.config.js` and it will be in the root directory of your project (the `react_blackjack/` in my setup).

When Webpack compiles the application, it will start with the file: `./app/index.js` (yet to be created). We specify this with `entry`. `entry` can also be an array of files, but at this point, we just need a single entry point.

It will only add files that `index.js` `require`s to the bundle. Each time it encounters a new file, it check its loaders to determine how to handle it. More specifically, it will match file names against the regular expression in each loader's `test` property. We want the Babel loader to run on files that end with `.js` or `.jsx`, so we use a regex that will match any file with those endings. (If you want to play around with regexs, I recommend [this site](http://regex101.com/).)

For the Babel loader, we specify that it should not be applied to `.js` files found in the `node_modules` directory and that it should use the `es2015` and `react` presets.

Later on, we'll add loaders for `scss` files, and you can also add loaders for images or many other file types.

Once it has processed all the files required by the `index.js`, it will decide where to output the bundle by looking at the `output` property. In this case, we tell it to put the bundle in `build/bundle.js`.

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
                test: /\.jsx?$/,
                loader: 'babel-loader?presets[]=es2015,presets[]=react',
                exclude: /node_modules/
            }
        ]
    },
};
```

We also need to tell Babel which presets to use while transforming our code in `package.json` so that we'll get the correct transformations when we run other scripts (such as tests). We do this in the `package.json` file:

<div class="fp">package.json</div>
```js
{
    //...
    "babel": {
        "presets": ["es2015", "react"]
    }
}
```

### A First Build

Let's do the first build of our application. We're going to need a few more directories and files.

First, let's make an HTML file that will serve our application. This file only needs two things: a `div` that will contain our React components, and a `<script>` tag that will add the `bundle.js` created by Webpack to the page.

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

Now, let's make a JavaScript file that inserts a component (which we'll create next) into the `<div>` component:

<div class="fp">app/index.js</div>
```jsx
import React from 'react';
import ReactDOM from 'react-dom';

import App from './components/app.js';

ReactDOM.render(
    <App />,
    document.getElementById('app')
);
```

Finally, we need the code for our component:

<div class="fp">app/components/app.js</div>
```jsx
import React from 'react';

export default class App extends React.Component {
    render() {
        return (
            <h1>Hello, world!</h1>
        );
    }
};
```

Now if we run `node_modules/.bin/webpack`, we should see a `bundle.js` file created in the `build/` directory. If we view the `build/index.html` page in a browser, we should see a large "Hello, world!".

Instead of typing out `node_modules/.bin/webpack` each time we want to build the bundle, we can create a script for npm to run in `package.json`. To do so, let's add the following to `package.json`. Be sure to include it inside the `{}`s wrapping the document:

<div class="fp">package.json</div>
```js
{
    //...
    "scripts": {
        "webpack": "node_modules/.bin/webpack",
        "webpack:watch": "npm run webpack -- --watch"
    }
}
```

Now we can create `bundle.js` by running `npm run webpack` and if we want Webpack to update `bundle.js` each time we save a file, we can run `npm run webpack:watch`

#### Talking Through the First Build

The `index.html` file is a pretty typical HTML file. It does not contain any `script` tags in the header, but it does have a `script` tag in the `body`. The `body` also has a single `<div>`. The `div` is empty to start with, but it is where `bundle.js` will load its components. The `bundle.js` script is the result of the Webpack compilation of our programs and all of their dependencies. This means we don't need to include separate `script` tags for each of our dependencies (react, react-dom, etc.).

The `index.js` file finds the `div` with an `id` of `app` and renders `<App />` into in using the `ReactDOM.render` method. This is the first time we're seeing JSX in action. JSX is an extenion to JavaScript that allows us to use things that look like HTML or XML elements in code without turning them into strings or functions. Under the hood, there is a JSX preprocessor that converts tags like `<App />` into normal JavaScript functions that eventually return strings of HTML that get output into the browser. In our application, the Babel React preset is handling this conversion for us.

The `app.js` file defines what JavaScript should render when we say `<App />`. We call this the `App` component. For now, our component is very simple -- it just renders a header, but components can get very complicated. Components can be composed of other components, and they can change what they display based on the state of the application passed to the component as "props".

There is no hard rule that individual components must be kept in individual files (such as `app.js`). As long as `index.js` imports the correct modules, everything will work fine. However, it is a good practice to keep your components separate from each other to organize your code and emphasize that components are meant to be interchangeable and independent.

## `Map`ping out State

We will be using a package called Redux to manage our application's state. Redux requires us to use a single variable to contain all state data. For this application, we'll be using a `Map` from the `ImmutableJS` package. A `Map` is analgous to a `Hash` in Ruby or an object in JavaScript except it is immutable. That means that change made to a `Map` will actually be made to a copy of it, and the original `Map` will be left alone.

<p style="background-color:lightblue; margin-bottom: 20px; padding: 20px;">

It's perfectly fine to use a JavaScript object or any other data structure as a way to keep track of the application's state as long as you are careful not to mutate the state object. We eliminate this concern by using an immutable Map.

</p>

We want our state `Map` to keep track of the following variables:

- Player's win count
- Player's loss count
- Player's hand
- Dealer's hand
- Cards remaining in deck
- Current status of game -- we'll use a boolean variable called hasStood. If hasStood is true, then the player has chosen to stand and it is the dealer's turn to draw.

It can be useful to set up the state of the application so that you have some data to work with while you're working on the components. Let's do that now.

### Cards and deck

We need to write some helper functions to set up our state. To keep our code organized, let's do so in a new file in a new directory. Create a new folder inside `app/` called `lib/`. Inside `lib/` create a file called `cards.js`.

Let's create a `shuffle` method and a method that will create a new deck. I shamelessly stole the `shuffle` method from a Stack Overflow answer [here](http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript). We'll also need a `newDeck` method that will add a new card to the deck for each rank and suit.

Let's install ImmutableJS so that we can store the deck we create as an immutable `List` and the cards inside it as immutable `Map`s.

```js
npm install --save immutable
```

ImmutableJS provides us with a `fromJS` method that allows us to convert nested JavaScript objects and arrays into immutable `Map`s and `List`s. We'll use this method here:

<div class="fp">app/lib/cards.js</div>
```js
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

In the newDeck method, we refer to `deck` as a `const` because it is a constant reference to an array. This means that the array itself may change, but the reference to the array that we are storing in `deck` is not allowed to change. We could describe `deck` as a constant reference to a mutable array. Here's a quick example of what's okay and what's not okay:

```js
const arr = [];
arr.push(1); // This is fine because it mutates an existing array
arr = [1, 2, 3]; // This will break because it replaces the array with a new reference
```

Now we'll import the `newDeck` method into our `index.js` file, and create a new deck.

<div class="fp">app/index.js</div>
```js
import React from 'react';
import ReactDOM from 'react-dom';

import App from './components/app.js';

import { newDeck } from './lib/cards.js';

const deck = newDeck();
console.log(deck);

ReactDOM.render(
    <App />,
    document.getElementById('app')
);
```

Try opening the `index.html` page in your browser. In Cloud9, you can do this by right clicking the `index.html` file and selecting preview. In the new window that pops up, click the button next to the settings button in the top right. If you're not on Cloud9, you can just choose "Open File" from the menu in your browser and find `index.html`.

Once you have the page open, open the Console tab in the developer tools (`ctrl` + `shift` + `j` on Windows), you should see a `List`. Since we're dealing with ImmutableJS objects rather than native JavaScript objects and arrays, it's hard to view them in the console. To fix that, I installed a [chrome extension](https://chrome.google.com/webstore/detail/immutablejs-object-format/hgldghadipiblonfkkicmgcbbijnpeog) that gives a custom formatter for ImmutableJS objects. After you install it, you may need to close the developer tools console and refresh the page (or close the tab and open a new one). You will also need to enable custom formatters in the developer tools options (access this by pressing `F1` after clicking somewhere in the developer tools console).

You should see a `List` containing `Map`s for each card.

### Player and Dealer Hands

The hands for the player and dealer will also be immutable `List`s. We are going to use the `takeLast` and `skipLast` methods from `List` to deal cards. We will also have to change `const deck` to `let deck` as the `deck` variable will be pointing to new immutable `List`s rather than pointing to a single array that mutates.

Your code should look something like this:

<div class="fp">app/index.js</div>
```js
// ...

let deck = newDeck();
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

// ...
```

Now if you refresh the page and look at the console, you should see that the player and the dealer each have two cards and the deck starts with 52 cards and ends up with 48 cards.

Since we'll be dealing cards from the deck often, let's write a function that deals cards for us. It's annoying and dangerous to make sure our code works by printing out all of our results to the console. Let's set up our testing environment and write the tests for our `deal` function before we implement the method.

We're going to use Mocha as our test framework and Chai as our assertion library. Let's install those packages now:

```
npm install --save-dev mocha chai
```

To run the tests, we'll use the command

```
mocha --compilers js:babel-core/register --recursive
```

This tells Mocha to use Babel to transfrom our code correctly and to search through our project recursively to find any tests to run. If you try running it now, it won't find any tests and might show you an error message.

We don't want to type this out each time we want to run our tests, so we can add this to our `package.json`.

<div class="fp">package.json</div>
```js
{
    // ...
    "scripts": {
        "webpack": "node_modules/.bin/webpack",
        "webpack:watch": "npm run webpack -- --watch",
        "test": "mocha --compilers js:babel-core/register --recursive"
    }
    // ...
}
```

Now we can run our tests with:

```
npm run test
```

We also want to set up our tests to run each time we save a file (similar to using Guard in Ruby). To do that, Mocha provides us with a `--watch` option. Let's add another script to `package.json`:

<div class="fp">package.json</div>
```js
{
    // ...
    "scripts": {
        "webpack": "node_modules/.bin/webpack",
        "webpack:watch": "npm run webpack -- --watch",
        "test": "mocha --compilers js:babel-core/register --recursive",
        "test:watch": "npm run test -- --watch"
    }
    // ...
}
```

To keep our test code DRY, we are going to want a test helper file that requires all the libraries we will need for testing. Create a folder for tests `test/` and create a `test_helper.js` file inside.

We are going to import `chai` and a library called `chai-immutable` that makes it easy for us to test ImmutableJS objects by providing us with some new assertions. First, we'll get the package from NPM:

```
npm install --save-dev chai-immutable
```

Now we'll add it to our `test_helper.js`:

<div class="fp">test/test_helper.js</div>
```js
import chai from 'chai';
import chaiImmutable from 'chai-immutable';

chai.use(chaiImmutable);
```

To tell `mocha` to load this helper file, we'll add the `--require ./test/test_helper.js` option to our `test` script in `package.json`:

<div class="fp">package.json</div>
```js
{
    // ...
    "scripts": {
        "webpack": "node_modules/.bin/webpack",
        "webpack:watch": "npm run webpack -- --watch",
        "test": "mocha --compilers js:babel-core/register --recursive --require ./test/test_helper.js",
        "test:watch": "npm run test -- --watch"
    }
    // ...
}
```

Now let's write some tests for the `cards.js` file that we had previously been testing with `console.log`. We'll try to mirror our `app/` directory with our `test/` directory, so we'll put this test in `test/lib/cards_spec.js`.

<div class="fp">test/lib/cards_spec.js</div>
```js
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

This is how you write tests using Mocha and Chai. The code looks a lot like the Rails testing library `rspec`. First, we import the necessary modules from external libraries. For these tests, we need to import the `expect` function from Chai. We also need to import the `List` object from ImmutableJS. Then we import the modules from our code we are testing. In this case, we import `newDeck` and `deal` from the `cards.js` file.

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

Before we write the `deal` method, we want to write some tests for the `deal` method:

<div class="fp">test/lib/cards_spec.js</div>
```js
// ...

import { newDeck<mark>, deal</mark> } from '../../app/lib/cards';

// ...

describe('cards.js', () => {
   // ...
   describe('deal()', () => {
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

One thing to note about these tests is that we only run the `newDeck` function once inside the `deal()` `describe` block. This makes our code more DRY and prevents unnecessary runs of code. We can access variables and constants declared outside of an `it` block as long as they are declared inside the same `describe` as the `it`.

These tests won't pass yet because we haven't written the `deal` method. Let's write it now:

<div class="fp">app/lib/cards.js</div>
```js
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

<div class="fp">app/index.js</div>
```jsx{7-11}
import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';

import { newDeck, deal } from './lib/cards.js';

let deck = newDeck();
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

<div class="fp">app/index.js</div>
```js{4,14-22}
// ...

import App from './components/app.js';
import { fromJS } from 'immutable';

import { newDeck, deal } from './lib/cards.js';

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

console.log(state);

// ...
```

Now when we build the bundle with `npm run webpack` and refresh the browser page, we will see the state `Map` logged to the console.

The next step is to let our components know about `state`. We do this by passing `state` into our `<App />` component as a "prop". `<App />` looks like an HTML tag, and we can pass it props the same way we give HTML tags attributes:

<div class="fp">app/index.js</div>
```jsx
// ...

ReactDOM.render(
    <App <mark>state={state}</mark> />,
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

The App component is very simple. It is only responsible for rendering the `Info` and `Hand` components as described above.

We're going to use the Enzyme testing utility to test our React components. Enzyme provides us with some helper functions that make rendering and manipulating React objects easier than trying to use the default tools provided by React.

First, let's install React's test utilities and Enzyme:

```
npm install --save-dev react-addons-test-utils enzyme chai-enzyme
```

Next, let's add Enzyme's Chai assertions to our `test_helper.js`:

<div class="fp">test/test_helper.js</div>
```js
import chai from 'chai';
import chaiImmutable from 'chai-immutable';
import chaiEnzyme from 'chai-enzyme';

chai.use(chaiImmutable);
chai.use(chaiEnzyme());
```

We can use Enzyme's `shallow` function to do a shallow render of our component. Shallow rendering will not render any child components. This allows us to keep our test one component at a time. If we are testing the `App` component, we want it to render an `Info` component. If something is wrong with the `Info` component, but it's still being rendered properly, the `App` component test should pass. Keeping our tests independent allows us to identify the source of a bug more quickly.

Shallow rendering can also boost performance as rendering all children and ancestor components can take a relatively long time in a big application.

The `shallow` function returns a "wrapper" object that has some useful functions. In this test, we will use the `find` function to search for other elements inside the shallow wrapper using CSS selectors (`element`, `#id`, `.class`).

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

<div class="fp">app/components/app.js</div>
```jsx{7,9,10}
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

Note that we also kept the `h1`. We had to wrap the entire thing in a `div` because a React component can only have one root HTML element. Without the `div`, we would have `h1` and `Info` on the same level, so we would have two root elements.

Another thing to note is that when we give an element a CSS class in `JSX`, we use `className=` rather than `class=` (the normal way to do it in HTML). This is because `JSX` is still JavaScript, and `class` is a reserved word in JavaScript used when declaring a new class.

We'll also need an `Info` component, so we have something to import and render from the `App` component. Make a new file and slap this inside for now:

<div class="fp">app/components/info.js</div>
```jsx
import React from 'react';

export default class Info extends React.Component {
    render() {
        return (
            <p>This is the info component</p>
        );
    }
};
```

Now our test for the `App` component should pass. You should also be able to see the dummy `Info` component in the browser.

Next, we want our `App` component to pass some state variables to the `Info` component as props. Specifically, the `Info` component is going to need to know `winCount`, `lossCount`, and `hasStood`. Our test for this looks like:

<div class="fp">test/components/app_spec.js</div>
```jsx{2,6,8-21,28-36}
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
    const rendered = shallow(<App <mark>state={state}</mark> />);

    // ...

    it('passes props to <Info />', () => {
        const info = rendered.find('Info').first();
        expect(info).to.have.prop('winCount',
            state.get('winCount'));
        expect(info).to.have.prop('lossCount',
            state.get('lossCount'));
        expect(info).to.have.prop('hasStood',
            state.get('hasStood'));
    });
});
```

To write this test, we needed to create a state `Map`, just like we did in `index.js`. This is a bit repetitive, but it is okay for now. Once we start using Redux to handle state, we'll DRY this up.

We also want our `App` component to render two `Hand` components -- one for the player's hand and one for the dealer's hand. Let's make a test for this:

<div class="fp">test/components/app_spec.js</div>
```jsx
// ...

describe('<App />', () => {

    // ...

    it('renders two <Hand /> component', () => {
        expect(rendered.find('Hand')).to.have.length(2);
    });
});
```

Let's make a dummy `Hand` component:

<div class="fp">app/components/hand.js</div>
```jsx
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

<div class="fp">app/components/app.js</div>
```jsx
import React from 'react';
import Info from './info';
import Hand from './hand';

export default class App extends React.Component {
    render() {
        console.log(this.props);
        return (
            <div className="app">
                <h1>React Blackjack</h1>
                <Info winCount={this.props.state.get('winCount')}
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

<div class="fp">test/components/app_spec.js</div>
```jsx
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

<div class="fp">app/components/app.js</div>
```jsx
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

As stated above, the `Info` component is responsible for a couple things: displaying the win/loss record of the player and some buttons that allow the player to choose to "hit" or "stand".

Let's first write a test to check if the player's record is displayed correctly:

<div class="fp">test/components/info_spec.js</div>
```jsx
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

<div class="fp">app/components/info.js</div>
```jsx{7-9}
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

<div class="fp">test/components/info_spec.js</div>
```js
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

<div class="fp">app/components/info.js</div>
```jsx{8-11}
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

<div class="fp">test/components/info_spec.js</div>
```jsx
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

<div class="fp">test/components/hand_spec.js</div>
```jsx
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
    const cards = rendered.find('Card');

    it('renders correct number of cards', () => {
        expect(cards).to.have.length(n);
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

<div class="fp">app/components/card.js</div>
```jsx
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

<div class="fp">app/components/hand.js</div>
```jsx
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

This render method is a little more complicated than our previous ones, so let's break it down. `this.props.cards` is a `List` object that contains a `Map` for each card. We want to render a `Card` element for each of those `Maps`. To do this, we invoke the `map()` method on `this.props.cards`. The `map()` method returns an `List` that is the result of applying the function passed to `map()` to each element in the `List`. In this case, we get a `List` of `<Card>`s with a `card` prop that corresponds to the respective element in the original array.

We need to give each element a unique `key` attribute that React will use to track the elements in case some are added or removed at some point in the future. For now, we can just use the position of the element in the `List` (`i`).

<!-- [comment]: <> (Above paragraphs could use some work) -->

Now it's time to flesh out our `Card` component. We want each `Card` to display its `suit` and `rank`. We also want the `Card`'s `div` element to have the card's suit as a class so that we can style the card appropriately. These tests are straightforward:

<div class="fp">test/components/card_spec.js</div>
```jsx
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

<div class="fp">app/components/card.js</div>
```jsx
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

First we need to configure Webpack to compile our `.scss` files to `.sass`. Previously, we set up `babel` to transform our ES6 `.js` files. We are going to do something similar for our (not yet created) `.scss` files. First let's install `sass-loader` and `node-sass`:

```
npm install --save-dev style-loader css-loader sass-loader node-sass
```

We'll use `sass-loader` in our `webpack.config.js` file, but `node-sass` will actually do the compilation work.

Next, we need to put this loader into our configuration file:

<div class="fp">webpack.config.js</div>
```js{5,13-16}
// ...

module.exports = {
    // ...
    "devtool": "source-map",
    "module": {
        "loaders": [
            {
                "test": /\.jsx?$/,
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

Now, Webpack will build our `.scss` files. We've also turned on "source maps", which tell the inspect tool on our browsers which `.scss` file each style comes from. Source maps can slow down build times if you have a large application, but they make debugging much easier.

Now we can start making stylesheet files. We'll have a `main.scss` file that is only responsible for importing all of the other `.scss` files in our application.

<div class="fp">app/css/main.scss</div>
```scss
@import 'components/all';
```

Next we'll make a directory called `components/` for our component styles inside our `css/` directory. It is a good practice to keep each component's stylesheet in its own file in order to make your components more modular. If we wanted to make another card game application, we could very easily re-use our card component by copying the `components/card.js` file and the `css/components/card.js` file to a new project.

The `components/` directory will have a file called `_all.scss` that imports each component. It's important to remember to add an import statement to this file each time you create a new `.scss` file.

The `_all.scss` file looks like this:

<div class="fp">app/css/components/_all.scss</div>
```scss
@import 'card';
```

And now we can create a `card.scss` file:

<div class="fp">app/css/components/card.scss</div>
```scss
.card {
    background-color: blanchedalmond;
    /* Yes -- blanchedalmond is a real color name */
}
```

Finally, we need to import our css file into `index.js` so that Webpack can find it and include it in our bundle:

<div class="fp">app/index.js</div>
```js{5}
// ...

import { newDeck, deal } from './lib/cards.js';

require('./css/main.scss');

let deck = newDeck();
// ...
```

Now if you open `build/index.html` in the browser, you should see the a nice blanched almond color behind your cards! You may have to restart your `webpack:watch` process because we changed its configuration.

In Chrome, if you right click on a card and hit "inspect", you'll see the DOM tree appear. If you select one of the `<div class="hand">` lines, you should see a list of styles applied to the element. It will tell you that it's getting it's `blanchedalmond` `backround-color` from `card.scss`. This is the source map at work!

#### Hot Reloading/Hot Module Replacement

Another thing worth setting up at this point is "hot reloading". Hot reloading will automatically update the page we're working on in the browser without making us manually refresh. This speeds up the process of checking how changes we make in the code change what the browser renders.

Hot module replacement (HMR) is a is very useful form of hot reloading because, unlike refreshing, it keeps the state of the application intact. This means that if we are working on the message that our application displays when the user wins a game, we don't have to play an entire game of blackjack (and win) each time we make a change to the message. HMR will change the message without resetting the state of the game.

First, we need to get the react-hot-loader package:

```
npm install --save-dev react-hot-loader
```

Then, we need to make some changes to our `webpack.config.js` file:

<div class="fp">webpack.config.js</div>
```js{7,8,29-35}
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
    "devtool": "source-map",
    "module": {
        "loaders": [
            {
                "test": /\.jsx?$/,
                "loader": '<mark>react-hot!</mark>babel-loader',
                "exclude": /node_modules/
            },
            {
                "test": /\.scss$/,
                "loaders": ["style", "css?sourceMap", "sass?sourceMap"]
            }
        ]
    },
    "devServer": {
        contentBase: './build',
        hot: true
    },
    "plugins": [
        new webpack.HotModuleReplacementPlugin()
    ]
};
```

This configuration file works on a Cloud9 instance. If you are not on Cloud9, you may have to replace `'webpack-dev-server/client?https://0.0.0.0:8080'` with `'webpack-dev-server/client?http://localhost:8080'` on line 9.

To run our application, we will use `webpack-dev-server` instead of just opening `index.html` in the browser. To install `webpack-dev-server`:

```
npm install --save-dev webpack-dev-server
```

To run `webpack-dev-server`, you can type:

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

<div class="fp">app/css/components/card.scss</div>
```scss
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

<div class="fp">app/css/components/_all.scss</div>
```scss
@import 'card';
@import 'info';
```

Then we can create an `info.scss` file and give it some styles. I'm just going to space things out a little bit.

<div class="fp">app/css/components/info.scss</div>
```scss
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

Now that our application is looking beautiful (well that might be a stretch unless you did some custom styling), we can move on to implementing some of the game logic.

This is the end of Part 1 of this guide. In the [next part]({% post_url 2016-05-19-react-blackjack-part-2 %}), we will start thinking about the logic for the game and work on connecting our components to the application state!
