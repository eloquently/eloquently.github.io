---
layout: post
title: React Blackjack Part 2
date: 2016-05-19
permalink: 'guides/react-blackjack-part-2'
---

## React Blackjack Part 2
<hr class="left" />

This is the second part of this guide. View the first part [here]({% post_url 2016-05-19-react-blackjack-part-1 %}).

### Setting up the Game

We haven't thought too much about what our application will need to do in order to play a game of blackjack.

One obvious way to make our game look more like blackjack is that one of the dealer's cards should be face down -- not face up.

There are a number of different ways to implement this feature. One would be to add a boolean `faceDown` property to the `card` objects we created earlier in this guide. This is a viable solution, but for this application, I think of `faceDown` as more of display logic than an inherent property of a card. If you make a new deck of cards would they all be face up or face down?

Another solution is to modify our `Hand` component to just display the first card as face down. There are a few drawbacks here. Sometimes, the `Hand` will need to display the dealer's first card face up, such as when the player chooses "stand" and the dealer starts drawing. This means that our `Hand` component needs to know the `hasStood` state variable. `Hand` also needs to know whether it is the dealer's hand or the player's hand. It's typically a good strategy to limit the number of props being passed into a component. This approach would make our `Hand` component less modular. That is, it would be harder to use the `Hand` component for in another card game with out making significant changes to it.

Another drawback to both of these approaches is that we are deciding what the card will be before it is shown to the user. Displaying the card face down is just a cosmetic change -- the card's suit and rank are still in the application state. Since we are building a front-end application, the state tree is in the browser, and thus it is available to the user.

The way we will solve this is to set up our `Hand` components to take a dummy card that it will display as a face down card. The dummy card won't come from the deck and won't have a suit or rank. After the player stands, we'll secretly deal an extra card to the dealer and remove the dummy card, so nothing will look strange to the user.

This logic suggests something else about our `deal` function: since the `Deck` object we're playing with is stored in state, the player can tell which card will be dealt next by looking at the end of the deck. This ruins the game. Let's fix this first.

### Refactoring the `deal` Function

Let's first add a test for our deal function. If we deal 1 card from the same deck 10 times, they shouldn't all be the same card. This new test will replace the `'puts correct cards in hand'` test.

<div class="fp">test/lib/cards_spec.js</div>
```js
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

<div class="fp">app/lib/cards.js</div>
```js
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

<div class="fp">test/components/hand_spec.js</div>
```jsx
// ...

describe('<Hand />', () => {
   describe('without dummy cards', () => {
       const rendered = shallow(<Hand cards={hand} />);
       const cards = rendered.find('Card');
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

<div class="fp">test/components/card_spec.js</div>
```jsx
// ...

describe('<Card />', () => {
   describe('non-dummy card', () => {
       const suit = 'C';
       const rank = 2;

       // ...
   });

   describe('dummy card', () => {
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

<div class="fp">app/components/card.js</div>
```jsx
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

<div class="fp">app/index.js</div>
```js
// ...

import { fromJS, Map } from 'immutable';

// ...

[deck, dealerHand] = deal(deck, 1);

dealerHand = dealerHand.push(new Map());

// ...
```

And, finally, we'll add a style for `face-down` cards:

<div class="fp">app/css/components/card.scss</div>
```scss
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

### Connecting Components

Before we make those "hit" and "stand" buttons do things, we need to set up our components to update automatically when the state changes.

Specifically, if we add a new card to the player's hand in the state `Map`, we want the `Hand` component to be re-rendered.

This is where the hard work setting up an immutable state and pure components pays off. We can now easily use Redux to turn our components into "smart components".

Redux keeps track of the application's state with a `store`. We can modify the state through a "reducer" function. Redux requires us to use a single `store` and a single `reducer()`. `reducer()` must be a pure function -- that is, it must not mutate the current state but rather return a new one. Luckily for us, we are using an immutable `Map` to track state, so we don't have to worry about accidentally mutating state.

Let's install the necessary packages:

```
npm install --save redux react-redux
```

The first step is to create the `reducer` function. This function will take two arguments: the current state and the desired action. It will return the new state after performing the action.

#### Simple Actions

The first action we want to build is the `SETUP_GAME` action. When the reducer receives a `SETUP_GAME`, it should set up the deck and hands for the player and dealer. Let's write a test for this:

<div class="fp">test/reducer_spec.js</div>
```js
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

To get these tests to pass, let's write a first version of `reducer()`:

<div class="fp">app/reducer.js</div>
```js
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

Remember to restart your `npm run test:watch` process after creating new files.

To keep our code organized, we will have `reducer()` call other functions that actually do the work. This keeps our code more modular. Eventually if you have many different actions, you can break these functions out into different files to keep things even more organized and allow multiple people to work on different parts of your program at the same time.

To fill in `setupGame()`, we'll copy over the code from `index.js`:

<div class="fp">app/reducer.js</div>
```js{3}
import { Map } from 'immutable';

import { newDeck, deal } from './lib/cards.js';

const setupGame = () => {
   let deck = newDeck();
   let playerHand, dealerHand;

   [deck, playerHand] = deal(deck, 2);
   [deck, dealerHand] = deal(deck, 1);

   dealerHand = dealerHand.push(new Map());

   const hasStood = false;

   const newState = new Map({ deck, playerHand, dealerHand, hasStood });

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

<div class="fp">test/reducer_spec.js</div>
```js
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

<div class="fp">app/reducer.js</div>
```js{7}
// ...

const setupGame = (<mark>currentState</mark>) => {

   // ...

   return currentState.merge(newState);
};

export default function(currentState=new Map(), action) {
   switch(action.type) {
       case 'SETUP_GAME':
           return setupGame(<mark>currentState</mark>);
   }
   return currentState;
}
```

Now let's add a similar action: `SET_RECORD`. This action will set the player's win and loss records to whatever win and loss values are part of the action. First the test:

<div class="fp">test/reducer_spec.js</div>
```js
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

<div class="fp">app/reducer.js</div>
```js
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

<div class="fp">app/action_creators.js</div>
```js
export function setupGame() {
   return { "type": "SETUP_GAME" };
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

<div class="fp">test/reducer_spec.js</div>
```js{2,8,14}
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
```js{4,10}
import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';
import {createStore} from 'redux';

import reducer from './reducer';

require('./css/main.scss');

let store = createStore(reducer);

// ...
```

Next we'll import the action creators and dispatch the actions to set up the game.

<div class="file-path">app/index.js</div>
```js{3,9-10}
// ...
import reducer from './reducer';
import { setupGame, setRecord } from '../app/action_creators';

require('./css/main.scss');

let store = createStore(reducer);

store.dispatch(setupGame());
store.dispatch(setRecord(0, 0));

// ...
```

Now we need to share the `store` with our React components. React-Redux provides us with a component called `Provider` that takes care of that for us. We just need to wrap the `App` component with `Provider` and pass `Provider` our `store` as a prop. We'll also change the `state` prop passed to `<App />` to get the state from `store`.

<div class="file-path">app/index.js</div>
```jsx
import React from 'react';
import ReactDOM from 'react-dom';
import App from './components/app.js';
import {createStore} from 'redux';
import { Provider } from 'react-redux';

import reducer from './reducer';
import { setupGame, setRecord } from '../app/action_creators';

require('./css/main.scss');

let store = createStore(reducer);

store.dispatch(setupGame());
store.dispatch(setRecord(0, 0));

ReactDOM.render(
   <Provider store={store}>
       <App state={store.getState()} />
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
<div class="fp">...</div>
```js
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

We could simplify our components and make them more modular by having each component read from the state tree only the variables it needs. Redux allows us to do this easily with a function called `mapStateToProps`. `mapStateToProps` is going to take the entire state tree as a parameter, and return an object where the keys are names of props for the object.

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

The React-Redux package gives us a function called `connect` that takes a `mapStateToProps` function as an argument and returns another function that takes a React component as an argument and returns a "smart" component that will automatically update when state changes. A Redux convention is to refer to the "smart" version of a component as a container, so the "smart" version of the `Info` component is the `InfoContainer`. Let's add `mapStateToProps()` to our `info.js` file and create `InfoContainer`.

We are also going to remove `default` from `export dfault class Info`. When you import a `default` export, you use a command like `import Info from './info';`. If you remove `default` from your export, you now have a "named" export, and you need to import it using a command like `import { Info } from './info';`. I typically prefer not to use default exports if I export more than one thing from the same file, but this is a personal preference.

<div class="file-path">app/components/info.js</div>
```jsx
import React from 'react';
import { connect } from 'react-redux';

<mark>export class</mark> Info extends React.Component {
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

import <mark>{ Info }</mark> from '../../app/components/info';
```

Now, we should change our `App` component to render `<InfoContainer>` rather than `<Info>`. We also no longer need to pass any props because now `<InfoContainer>` is getting them straight from the `store`! Let's change our `App` component tests to reflect these changes we want to make:

<div class="fp">test/components/app_spec.js</div>
```jsx
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
import <mark>{ InfoContainer }</mark> from './info';
// ...

export default class App extends React.Component {
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

Now that we have `<Info>` connected, let's write a `mapStateToProps` function for `<App>` and create the `AppContainer` class. We're also going to remove the default export on the `App` class. This means we'll have to change the `app_spec.js` file to `import { App }` instead of `import App`.

<div class="file-path">app/components/app.js</div>
```jsx
// ...

import { connect } from 'react-redux';

<mark>export class</mark> App extends React.Component {
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
               <strong>Player hand:</strong>
               <Hand cards={this.props.playerHand } />
               <strong>Dealer hand:</strong>
               <Hand cards={this.props.dealerHand } />
           </div>
       );
   }
};
```

We also need to change our `app_spec.js` to pass these props individually to `<App>` rather than passing the entire state `Map`:

<div class="file-path">test/components/app_spec.js</div>
```jsx
// ...

describe('<App />', () => {
   const rendered = shallow(<App playerHand={playerHand} dealerHand={dealerHand} />);

   // ...
});
```

The only thing left to do is to change the component that we're rendering in `index.js`:

<div class="file-path">app/index.js</div>
```jsx
// ...
import <mark>{ AppContainer }</mark> from './components/app';
// ...

ReactDOM.render(
   <Provider store={store}>
       <App<mark>Container</mark> />
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

<div class="fp">test/lib/cards_spec.js</div>
```js
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
       let [d, c] = deal(newDeck, 1<mark>, seed + i</mark>);
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
};

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

Now if you add and delete `SETUP_GAME` events in the Redux DevTools, you shouldn't see the cards change when you undo an old `SETUP_GAME` action. If you undo the most recent `SETUP_GAME`, you should see the cards that used to be there!

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
                                      onClickHit={onClickHitSpy}
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
```js{2}
// ...
import { dealToPlayer } from '../../app/action_creators';

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
};
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

       it('invokes prop function when Stand is clicked', () => {
           buttons.last().simulate('click');
           expect(onClickStandSpy.calledOnce).to.eq(true);
       });
   });

   // ...

});
```

Then the code:

<div class="fp">app/components/info.js</div>
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

At this point, our application is functional. Try clicking the "Hit" and "Stand" buttons in the browser, and you should see the desired behavior. Try playing around with the Redux DevTools.

In the next section, we will finish up our app by adding logic to the reducers that prevents too many cards from being drawn, deals cards to the dealer after the player stands, and adds to the win and loss counts!
