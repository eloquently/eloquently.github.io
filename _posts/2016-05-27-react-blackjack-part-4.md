---
layout: post
title: React Blackjack Part 4
permalink: guides/react-blackjack-part-4
date: 2016-05-27
---

## {{ page.title }}

<hr class="left" />

In this final part of the React Blackjack guide, we will use several new React libraries to add additional functionality to our Blackjack game. Specifically, we are going to:

- Use Redux Saga to chain actions so that the dealer will draw cards one at a time with a slight delay between draws
- Use React Router to create a new page for settings
- Use Redux Redux form to create a settings form that allows the user to control how fast the dealer draws cards
- Use Redux Saga to persist and load users' win-loss records to a Rails 5 API

### Quick Configuration

Before we get started, let's change a configuration setting in `webpack.config.js`. We have been building complete source maps, which adds a decent amount of time to the build time. We can tell Webpack to make "cheaper" source maps that are much faster to build. Our build times will get noticeably slower as we add more dependencies to the project.

To change the type of source maps we build, change the `devtool` in `webpack.config.js` from `"source-map"` to `"cheap-module-eval-source-map"`. This will actually be the default type of source maps that Webpack uses in the near future. They are significantly faster to build without adding too much confusion while debugging.

<div class="fp">webpack.config.js</div>
```js
// ...

module.exports = {
    // ...
    devtool: "<mark>cheap-module-eval-</mark>source-map",
    // ...
};
```

### Chaining Actions with Redux Saga

In this section, we will use a package called Redux Saga to fire off actions in a sequence until a condition is met. This will allow the dealer to draw one card at a time and pause between each card drawn to add some suspense to our blackjack game.

Redux Sagas take advantage of ES6 generator functions, so it's worth reading up on those before continuing with the tutorial. Read more [here](https://davidwalsh.name/es6-generators). A deep understanding of generators will also require you to understand promises. [Here](https://davidwalsh.name/promises) is a good intro.

You can think of sagas as process that run in the background of your application watching for certain actions. We'll install Saga middleware that will watch the reducer for actions and iterate a saga generator each time an action is dispatched. It is important to note that the sagas will run after your reducer, so they will only see the application state after an action is performed.

Let's install the Redux Saga package:

```
npm install --save redux-saga@0.10.4
```

We're also going to need to install Babel Polyfill and Babel Stage 0 Preset in order to use promises and generators in our code.

```
npm install --save-dev babel-polyfill@6.9.0 babel-preset-stage-0@6.5.0
```

Let's also add the Stage 0 preset to `package.json`:

<div class="fp">package.json</div>
```js{7}
{
  // ...
  "babel": {
    "presets": [
      "es2015",
      "react"<mark>,</mark>
      "stage-0"
    ]
  }
}

```

Let's make a simple saga. We're going to make a new directory, `sagas/` to keep our code organized. Since we're using generators in this file, we need to import Babel Polyfill.

<div class="fp">app/sagas/index.js</div>
```js
import 'babel-polyfill';

export default function*() {
    let i = 0;
    while(true) {
        yield i;
        i++;
    }
}
```

This function will return a generator (note the `*` after `function`), which we can then iterate using `next()`. Each call to `next()` will return an object that looks like: `{ value: 1, done: false }`. We can write a test for this generator like this:

<div class="fp">test/sagas/index_spec.js</div>
```js
import { expect } from 'chai';
import watchActions from '../../app/sagas/index';

describe('sagas', () => {
    describe('watchActions()', () => {
        it('counts up', () => {
            const generator = watchActions();
            let i;
            i = generator.next().value;
            expect(i).to.eq(0);
            i = generator.next().value;
            expect(i).to.eq(1);
            i = generator.next().value;
            expect(i).to.eq(2);
        });
    });
});
```

This test should pass. Each time we call `next()` on the generator, it runs unitl it hits a `yield`. So if our generator looked like this:

<div class="fp">app/sagas/index.js</div>
```js
import 'babel-polyfill';

export default function*() {
    let i = 0;
    yield 'start';
    while(true) {
        yield i;
        i++;
        yield 'end loop';
    }
}
```

We'd have to change our test to look like this:

<div class="fp">test/sagas/index_spec.js</div>
```js{14-15}
// ...

describe('sagas', () => {
    describe('watchActions()', () => {
        it('counts up', () => {
            const generator = watchActions();
            let i;
            i = generator.next().value;
            expect(i).to.eq(<mark>'start'</mark>);
            i = generator.next().value;
            expect(i).to.eq(<mark>0</mark>);
            i = generator.next().value;
            expect(i).to.eq(<mark>'end loop'</mark>);
            i = generator.next().value;
            expect(i).to.eq(/* what goes here? */);
        });
    });
});
```

Instead of a generator function that simply counts up from 0, our "root" saga needs to emit `take` effects. `take` effects tell the saga middleware to watch for actions and execute a function (called a worker saga) after the reducer has changed the application state.

Redux Saga gives us two functions that make it very simple to create `take` effects. The functions are called `takeEvery()` and `takeLatest()`. The difference between the two is that `takeEvery()` will run the worker saga every time the action is dispatched, even if the process from the previous dispatch is still running. `takeLatest()` will not run a new worker saga if one is already running.

Since we want to deal cards to the dealer one at a time after the player chooses to stand, we will want to watch the `STAND` action. We only want to have one worker saga dealing cards to the dealer at a time, so we'll use `takeLatest()` (note: in this case it doesn't matter very much because it should be impossible to dispatch a second `STAND` before the first one ends). We will also write a placeholder worker saga.

Here's what `sagas/index.js` should look like:

<div class="fp">app/sagas/index.js</div>
```js
import 'babel-polyfill';
import { takeLatest } from 'redux-saga';

export function* onStand() {
    console.log("stand action");
}

export default function*() {
    yield takeLatest('STAND', onStand);
}
```

It is very easy to do unit testing on Sagas because they do not actually perform the effects they execute. Let's see what happens when we run the default generator in our tests now:

<div class="fp">test/sagas/index_spec.js</div>
```js
import { expect } from 'chai';
import watchActions from '../../app/sagas/index';

describe('sagas', () => {
    describe('watchActions()', () => {
        it('??', () => {
            const generator = watchActions();
            console.log(generator.next());
        });
    });
});
```

In your test output, you should see that `generator.next()` looks like this:

```
{ value:
   { name: 'takeLatest(STAND, onStand)',
     next: [Function: next],
     throw: [Function] },
  done: false }
```

Thus, our unit test for this generator simply needs to ensure that it yields an object with a name property `takeLatest(STAND, onStand)`:

<div class="fp">test/sagas/index_spec.js</div>
```js
import { expect } from 'chai';
import watchActions from '../../app/sagas/index';

describe('sagas', () => {
    describe('watchActions()', () => {
        const generator = watchActions();
        const next = generator.next();

        it('yields takeLatest', () => {
            expect(next.value.name).to
                .eq('takeLatest(STAND, onStand)');
        });
    });
});
```

Sagas work as middleware, which means that they see every action that gets dispatched to the reducer. Let's hook up our sagas to the store:

<div class="fp">app/index.js</div>
```js{7,12,16,19-22}
import React from 'react';
import ReactDOM from 'react-dom';
import { AppContainer } from './components/app.js';
import { createStore<mark>, applyMiddleware,</mark>
         <mark>compose</mark> } from 'redux';
import { Provider } from 'react-redux';
import createSagaMiddleware from 'redux-saga';

import reducer from './reducer';
import { setupGame,
         setRecord } from '../app/action_creators';
import watchActions from './sagas/index';

require('./css/main.scss');

const sagaMiddleware = createSagaMiddleware();

let store = createStore(reducer, undefined, <mark>compose(</mark>
    applyMiddleware(sagaMiddleware),
    window.devToolsExtension ?
        window.devToolsExtension() : f => f
));

sagaMiddleware.run(watchActions);
// ...
```

Now in your browser, you should see "stand action" logged to the console by the worker saga each time you click the "stand" button!

Our goal is to deal cards one at a time to the dealer from the worker saga instead of dealing them all at once in the reducer. We'll need to change up the actions and reducer logic a little bit to achieve this.

First, we only want `STAND` to set `hasStood` to true and remove the dummy card from the dealer's hand. Second, we will create a new action `DEAL_TO_DEALER` that will add a single card to the dealer's hand in the same way that `DEAL_TO_PLAYER` adds a single card to the player's hand. Unlike `DEAL_TO_PLAYER`, `DEAL_TO_DEALER` doesn't need to worry about what happens if the score exceeds 21 (or 16) -- our saga will handle this logic and dispatch a `DETERMINE_WINNER` action, which we'll also have to create now.

Let's shift the tests around first. We will mostly be breaking up the `STAND` reducer rather than writing new logic, so we don't have to write much new code -- just rearrange.

First, let's write tests for the `DEAL_TO_DEALER` reducer. These tests will look similar to the `DEAL_TO_PLAYER` reducer tests:

<div class="fp">test/reducer_spec.js</div>
```js
import { expect } from 'chai';
import { Map, List, fromJS } from 'immutable';
import { setupGame, setRecord,
         dealToPlayer, stand<mark>,</mark>
         <mark>dealToDealer</mark> } from '../app/action_creators';
import { newDeck } from '../app/lib/cards';
import proxyquire from 'proxyquire';
import sinon from 'sinon';

import reducer from '../app/reducer';

describe('reducer', () => {
    // ...

    describe("DEAL_TO_PLAYER", () => {
        // ...
    });

    describe("DEAL_TO_DEALER", () => {
        const action = dealToDealer();

        const initialState = new Map({
            "dealerHand": new List(),
            "deck": newDeck()
        });

        const nextState = reducer(initialState, action);

        it('adds one card to dealer hand', () => {
            expect(nextState.get('dealerHand').size).to
                .eq(initialState.get('dealerHand').size + 1);
        });

        it('removes one card from deck', () => {
            expect(nextState.get('deck').size).to
                .eq(initialState.get('deck').size - 1);
        });
    });

    describe("STAND", () => {
        // ...
    });
});
```

We'll need to write an action creator for `DEAL_TO_DEALER`:

<div class="fp">app/action_creators.js</div>
```js
// ...

export function dealToDealer(seed=new Date().getTime()) {
    return { "type": "DEAL_TO_DEALER", seed };
}
```

We can also eliminate the entire "dealer drawing" `describe` block from the `STAND` test.

Next, we need to split up the `STAND` test so that the "determining winner" block is in a `DETERMINE_WINNER` test. We can also remove all the logic related to stubbing out the `score` function from the `STAND` test and put it in the `DETERMINE_WINNER` test.

This is what my tests for `STAND` and `DETERMINE_WINNER` look like after moving things around:

<div class="fp">test/reducer_spec.js</div>
```js
// ...

describe('reducer', () => {
    // ...

    describe("STAND", () => {
        const action = stand();

        const initialState = fromJS({
            "hasStood": false,
            dealerHand: [{ suit: 'S', rank: 'K' }, {}]
        });

        const nextState = reducer(initialState, action);

        it('sets hasStood to true', () => {
            expect(nextState.get('hasStood')).to.eq(true);
        });

        it('removes dummy card', () => {
            expect(nextState.get('dealerHand').size).to
                .eq(1);
        });
    });

    describe("DETERMINE_WINNER", () => {
        const action = determineWinner();
        const cardUtils = { };
        const stubbedReducer = proxyquire(
            '../app/reducer.js', {
                './lib/cards': cardUtils
            }
        ).default;

        const initialState = new Map({
            "hasStood": false,
            dealerHand: new List(),
            playerHand: new List(),
            winCount: 11,
            lossCount: 15
        });

        beforeEach( () => {
            cardUtils.score = sinon.stub();
            cardUtils.deal = sinon.stub();
            cardUtils.deal.returns([new List(), new List()]);
        });

        it('increments win count and sets playerWon if player wins', () => {
            cardUtils.score.onCall(0).returns(17); // dealer drawing check
            cardUtils.score.onCall(1).returns(20); // user score
            cardUtils.score.onCall(2).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(true);
        });

        it('increments win count and sets playerWon if dealer busts', () => {
            cardUtils.score.onCall(0).returns(17); // dealer drawing check
            cardUtils.score.onCall(1).returns(20); // user score
            cardUtils.score.onCall(2).returns(22); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(true);
        });

        it('increments loss count and sets playerWon if dealer wins', () => {
            cardUtils.score.onCall(0).returns(17); // dealer drawing check
            cardUtils.score.onCall(1).returns(16); // user score
            cardUtils.score.onCall(2).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount'));
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount') + 1);
            expect(nextState.get('playerWon')).to.eq(false);
        });

        it('does not change counts if tie', () => {
            cardUtils.score.onCall(0).returns(17); // dealer drawing check
            cardUtils.score.onCall(1).returns(17); // user score
            cardUtils.score.onCall(2).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount'));
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(undefined);
        });
    });
});
```


We'll need a `determineWinner()` action creator.

<div class="fp">app/action_creators.js</div>
```js
// ...

export function determineWinner() {
    return { "type": "DETERMINE_WINNER" };
}
```

We also no longer need the seed in the `STAND` action, because it's not doing anything random any more.

<div class="fp">app/action_creators.js</div>
```js
export function stand() {
    return { "type": "STAND" };
}
```

Now it's time for the reducer code. First, let's add the new actions to our root reducer. We can also remove `action.seed` from the call to the `STAND` reducer helper:

<div class="fp">app/reducer.js</div>
```js{12-16}
// ...

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
        case 'DEAL_TO_DEALER':
            return dealToDealer(currentState, action.seed);
        case 'DETERMINE_WINNER':
            return determineWinner(currentState);
    }
    return currentState;
}
```

Now time to implement our new actions. Let's start with `DEAL_TO_DEALER`:

<div class="fp">app/reducer.js</div>
```js
// ...

const dealToDealer = (currentState, seed) => {
    const [deck, newCard] = deal(
        currentState.get('deck'), 1, seed
    );

    const dealerHand = currentState
        .get('dealerHand').push(newCard.get(0));

    return currentState.merge(new Map({ deck, dealerHand }));
};

// ...
```

Next, let's split up `stand()` to create `determineWinner()`:

<div class="fp">app/reducer.js</div>
```js
// ...

const stand = (currentState, seed) => {
    let dealerHand = currentState.get('dealerHand');

    dealerHand = dealerHand.filter(
        (element) => element != new Map()
    );

    let newState = new Map({
        "hasStood": true,
        "dealerHand": dealerHand
    });

    return currentState.merge(newState);
};

const determineWinner = (currentState) => {
    const dealerHand = currentState.get('dealerHand');
    const playerHand = currentState.get('playerHand');
    let winCount = currentState.get('winCount');
    let lossCount = currentState.get('lossCount');

    const playerScore = score(playerHand);
    const dealerScore = score(dealerHand);
    let playerWon = undefined;

    if(playerScore > dealerScore || dealerScore > 21) {
        winCount += 1;
        playerWon = true;
    } else if(dealerScore > playerScore) {
        lossCount += 1;
        playerWon = false;
    }

    const gameOver = true;

    const newState = new Map({
        dealerHand, winCount, lossCount,
        gameOver, playerWon
    });

    return currentState.merge(newState);
};

// ...
```

Now all the tests except for the `DETERMINE_WINNER` tests should pass. Why are the `DETERMINE_WINNER` tests still failing?

Walk through them line by line to try to figure it out.

The answer has to do with the way we stubbed the `score` function.

When these tests were for `STAND` we called `score()` at least one time to check if the dealer needed to deal. Now that we've refactored the actions, we no longer make that extra call to `score()`. However, we set up our stubs as if the first call is still being made. To fix the tests, we need to remove the `onCall` from each stub (and remember to re-index the others!).

Here are the new `DETERMINE_WINNER` tests -- all of which should pass!

<div class="fp">test/reducer.js</div>
```js
// ...

describe('reducer', () => {
    // ...

    describe("DETERMINE_WINNER", () => {
        // ...

        it('increments win count and sets playerWon if player wins', () => {
            cardUtils.score.onCall(<mark>0</mark>).returns(20); // user score
            cardUtils.score.onCall(<mark>1</mark>).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(true);
        });

        it('increments win count and sets playerWon if dealer busts', () => {
            cardUtils.score.onCall(<mark>0</mark>).returns(20); // user score
            cardUtils.score.onCall(<mark>1</mark>).returns(22); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(true);
        });

        it('increments loss count and sets playerWon if dealer wins', () => {
            cardUtils.score.onCall(<mark>0</mark>).returns(16); // user score
            cardUtils.score.onCall(<mark>1</mark>).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount'));
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount') + 1);
            expect(nextState.get('playerWon')).to.eq(false);
        });

        it('does not change counts if tie', () => {
            cardUtils.score.onCall(<mark>0</mark>).returns(17); // user score
            cardUtils.score.onCall(<mark>1</mark>).returns(17); // dealer score

            const nextState = stubbedReducer(initialState, action);

            expect(nextState.get('winCount')).to.eq(initialState.get('winCount'));
            expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount'));
            expect(nextState.get('playerWon')).to.eq(undefined);
        });
    });
});
```

Now we can set up our worker saga (`*onStand()`) to dispatch these new actions. Our saga is going to need to get data from the application state to determine when to stop giving cards to the dealer. To do this, we will use a `select` effect which will grab data from the application state. To use `select`, we have to write a helper "selector" function that takes the state object as a parameter and returns the piece of state that we want to see.

Here is how we will use `select` effects and selectors to get data from state in our saga:

<div class="fp">app/sagas/index.js</div>
```js{3,4,6,9,10}
import 'babel-polyfill';
import { takeLatest } from 'redux-saga';
import { select } from 'redux-saga/effects';
import { score } from '../lib/cards';

const getDealerHand = (state) => state.get('dealerHand');

export function* onStand() {
    let dealerHand = yield select(getDealerHand);
    console.log(score(dealerHand));
}

// ...
```

If you refresh your application and hit "stand", you should see the score of the dealer's (one) card printed to the console.

To get the dealer to draw a new card, we are going to use the `put` effect, which enables a saga to dispatch actions to the reducer.

Since we always want the dealer to draw a new card to replace the dummy card, we can use `put` like this:

<div class="fp">app/sagas/index.js</div>
```js{5,12-14}
import 'babel-polyfill';
import { takeLatest } from 'redux-saga';
import { select<mark>, put</mark> } from 'redux-saga/effects';
import { score } from '../lib/cards';
import { dealToDealer } from '../action_creators';

const getDealerHand = (state) => state.get('dealerHand');

export function* onStand() {
    let dealerHand = yield select(getDealerHand);
    console.log(score(dealerHand));
    yield put(dealToDealer());
    dealerHand = yield select(getDealerHand);
    console.log(score(dealerHand));
}

export default function*() {
    yield takeLatest('STAND', onStand);
}
```

Now we should see the dealer's score before drawing a card and the dealer's score after drawing a card. The `DEAL_TO_DEALER` action will also show up in the Redux DevTools.

The last type of effect we need is the `call` effect, which allows a saga to run a function that returns a promise and stops the saga until the promise is resolved. Redux Saga provides us with a built-in `delay` function that returns a promise that isn't resolved for a fixed amount of time (passed as a parameter).

Here's what a saga with `call` and `delay()` looks like:

<div class="fp">app/sagas/index.js</div>
```js
import 'babel-polyfill';
import { takeLatest<mark>, delay</mark> } from 'redux-saga';
import { select, put<mark>, call</mark> } from 'redux-saga/effects';
import { score } from '../lib/cards';
import { dealToDealer } from '../action_creators';

const getDealerHand = (state) => state.get('dealerHand');

export function* onStand() {
    yield call(delay, 5000);
    console.log('Patience is a virtue');
}
```

Refresh your application and when you hit "stand", wait for 5 seconds and you should see a message in the console.

Now that we've seen commonly used saga effects, it's time to actually implement the saga.

Here is an outline of what we want the worker saga to do:

- Deal a card to the dealer
- Check the score of dealer.
    - If the score is >= 17, `put` a `DETERMINE_WINNER` action
    - If the score is < 17, `call` `delay(750)` and repeat

Let's write the saga first and then write the test. Writing tests for sagas can be tricky because you need to know exactly what the objects being yielded look like to write a test for them. After you have some practice writing the tests for sagas, TDD becomes more natural.

<div class="fp">app/sagas/index.js</div>
```js
import 'babel-polyfill';
import { takeLatest, delay } from 'redux-saga';
import { select, put, call } from 'redux-saga/effects';
import { score } from '../lib/cards';
import { dealToDealer, determineWinner } from '../action_creators';

const getDealerHand = (state) => state.get('dealerHand');

export function* onStand() {
    let dealerHand;
    while(true) {
        yield put(dealToDealer());
        dealerHand = yield select(getDealerHand);
        if(score(dealerHand) >= 17) {
            break;
        }
        else {
            yield call(delay, 750);
        }
    }
    yield put(determineWinner());
}

export default function*() {
    yield takeLatest('STAND', onStand);
}
```

Try it out in the browser! You'll see the dealer draw one card at a time. Experiment with different delay amounts -- the next feature we add will allow the user to choose how fast the dealer draws.

Let's look at how to test this saga. First, let's print each effect it yields so we can figure out how to write the test. We're going to use `proxyquire` to control the values we get from `score()`. Let's start with the situation where the dealer does not have to draw after replacing the dummy card:

<div class="fp">test/sagas/index_spec.js</div>
```js{3-4}
import { expect } from 'chai';
import watchActions from '../../app/sagas/index';
import proxyquire from 'proxyquire';
import sinon from 'sinon';

describe('sagas', () => {
    // ...

    describe('onStand()', () => {
        const cardUtils = {};
        const stubbedSagas = proxyquire(
            '../../app/sagas/index',
            { '../lib/cards' : cardUtils }
        );

        let generator;

        beforeEach( () => {
            cardUtils.score = sinon.stub();
            generator = stubbedSagas.onStand();
        });

        context('when dealer does not draw' , () => {
            it('??', () => {
                cardUtils.score.returns(21);
                let next;
                while(true) {
                    next = generator.next();
                    console.log(next);
                    if(next.done) break;
                }
            });
        });
    });
});
```

You should see the following output in the console when you run the test:

```
{ value:
   { '@@redux-saga/IO': true,
     PUT: { channel: null, action: [Object] } },
  done: false }
{ value:
   { '@@redux-saga/IO': true,
     SELECT: { selector: [Function: getDealerHand], args: [] } },
  done: false }
{ value:
   { '@@redux-saga/IO': true,
     PUT: { channel: null, action: [Object] } },
  done: false }
{ value: undefined, done: true }
```

First, the generator yields a `put` effect (to deal the dummy card). Next, the generator yields a `select` effect (to get the new dealerHand). Then, the generator yields another `put` effect (for `DETERMINE_WINNER`), and finally the generator yields an object with `done: true`.

We can write tests for the actual actions that are part of the `put` effects. Let's print out the actions by adding this line to the test after `console.log(next);`

```js
if(next.value.PUT) console.log(next.value.PUT.action);
```

Now the test output reads:

```
{ value:
   { '@@redux-saga/IO': true,
     PUT: { channel: null, action: [Object] } },
  done: false }
{ type: 'DEAL_TO_DEALER', seed: 1464382217894 }
{ value:
   { '@@redux-saga/IO': true,
     SELECT: { selector: [Function: getDealerHand], args: [] } },
  done: false }
{ value:
   { '@@redux-saga/IO': true,
     PUT: { channel: null, action: [Object] } },
  done: false }
{ type: 'DETERMINE_WINNER' }
{ value: undefined, done: true }
```

We can get they type of action dispatched or the name of the selector function with code like:

```js
generator.next().value.PUT.action.type
generator.next().value.SELECT.selector.name
```

Instead of typing that out a bunch of times, we'll add some helper methods to our test:

<div class="fp">test/sagas/index_spec.js</div>
```js
// ...

const actionType = (next) => {
    return next.value.PUT.action.type;
};

const selectorName = (next) => {
    return next.value.SELECT.selector.name;
};

describe('sagas', () => {

});
```

Now we're ready for the actual tests!


<div class="fp">test/sagas/index_spec.js</div>
```js
// ...

describe('sagas', () => {
    // ...

    describe('onStand()', () => {
        // ...

        context('when dealer does not draw' , () => {
            it('yields correct effects', () => {
                cardUtils.score.returns(21);

                expect(actionType(generator.next())).to
                    .eq('DEAL_TO_DEALER');

                expect(selectorName(generator.next())).to
                    .eq('getDealerHand');

                expect(actionType(generator.next())).to
                    .eq('DETERMINE_WINNER');

                expect(generator.next().done).to
                    .eq(true);
            });
        });
    });
});
```

We should also test the case where the dealer has to draw (after replacing the dummy card) and we have to `call` `delay`. If we print out `generator.next()`, for the call action, we end up with an object like this:

```
{ '@@redux-saga/IO': true,
  CALL: { context: null, fn: [Function: delay], args: [ 750 ] } }
```

So we will add a helper function called `callFnName()` that will give us the name of the function the `call` effect yields.

Here is the helper method and the test:

<div class="fp">test/sagas/index_spec.js</div>
```js
// ...

const callFnName = (next) => {
    return next.value.CALL.fn.name;
};

describe('sagas', () => {
    // ...

    describe('onStand()', () => {
        // ...

        context('when dealer does not draw', () => {
            // ...
        });

        context('when dealer draws' , () => {
            it('yields correct effects', () => {
                cardUtils.score.onCall(0).returns(10);
                cardUtils.score.onCall(1).returns(21);

                expect(actionType(generator.next())).to
                    .eq('DEAL_TO_DEALER');

                expect(selectorName(generator.next())).to
                    .eq('getDealerHand');

                expect(callFnName(generator.next())).to
                    .eq('delay');

                expect(actionType(generator.next())).to
                    .eq('DEAL_TO_DEALER');

                expect(selectorName(generator.next())).to
                    .eq('getDealerHand');

                expect(actionType(generator.next())).to
                    .eq('DETERMINE_WINNER');

                expect(generator.next().done).to
                    .eq(true);
            });
        });
    });
});
```

At this point all the tests should pass, and we've successfully completed this feature!

One thing to note is that, by default, sagas run asynchronously. This means that while the saga is dispatching `DEAL_TO_DEALER` actions, the rest of the page will still function like normal and the reducer can receive other actions. We will see an example of this in the next section.

### Settings

As mentioned above, we want the user to be able to choose how fast the dealer draws cards (instead of the default value of 750). To do this, we will set up a new reducer for our settings state variables and re-structure the state tree to keep the game variables separate from the setting variables.

### combineReducers

As React applications go larger, it is common to split up reducer logic into multiple files and functions. It's also common to have different top level properties in the store. So far, we have kept all our reducer logic in `app/reducer.js`. This was okay because it all pertained to a single part of the application state: the game.

Our application store currently looks something like this (keys only):

```js
Map({
    winCount,
    lossCount,
    deck,
    playerHand,
    dealerHand,
    hasStood,
    gameOver
})
```

We'll eventually want to add some settings to the application state. It would be best to keep these separate from the game state. To do this, we can transform our store to look like this:

```js
{
    settings: Map({
        dealerDrawSpeed
    }),
    game: Map({
        winCount,
        lossCount,
        deck,
        playerHand,
        dealerHand,
        hasStood,
        gameOver
    })
}
```

Why are we using a plain JS object instead of an immutable map for the root of the store? Certain packages (such as React-Router-Redux), are not compatible with ImmutableJS stores. The main advantage to using ImmutableJS objects in the store is so that you don't accidentally mutate state in the reducers. However, after we have multiple reducers (which we later combine with `combineReducers`), the individual reducers won't see the full state tree -- only their respective parts of it. Since we will still be dealing with ImmutableJS objects in the state that our reducers use, we don't have to worry about accidentally mutating state. This mitigates the downside to keeping our store in a plain JS object.

We will just need to change a few things to refactor our current reducer to a "game reducer". After we refactor, we'll be able to add as many new reducers as we want very easily.

Let's start by moving the current reducer file from `app/reducer.js` to `app/reducers/game.js`.

Since we've changed the directory, we'll have to change the import path for cards.js:

<div class="fp">app/reducers/game.js</div>
```js
// ...
import { newDeck, deal, score } from '.<mark>.</mark>/lib/cards';
//...
```

We also need to move the test file and make a few changes to reflect the new paths. First, move `test/reducer.js` to `test/reducers/game_spec.js`. Then change the import paths:

<div class="fp">test/reducers/game_spec.js</div>
```js
import { expect } from 'chai';
import { Map, List, fromJS } from 'immutable';
import { setupGame, setRecord,
         dealToPlayer, stand,
         dealToDealer, determineWinner
       } from '../<mark>../</mark>app/action_creators';
import { newDeck } from '../<mark>../</mark>app/lib/cards';
import proxyquire from 'proxyquire';
import sinon from 'sinon';

import reducer from '../<mark>../</mark>app/reducers/game';

```

Because we're using proxyquire twice in this program here, we need to change the path to the reducer and the path to the `cards.js` file relative to the new reducer path. To make this easier in case of any future moves, let's store the paths in two constants at the beginning of test file:

<div class="fp">test/reducers/game_spec.js</div>
```js
// ...

const reducerPath = '../../app/reducers/game';
const cardsPath = '../lib/cards';

describe('reducer', () => {
    // ...
});
```

Our two `proxyquire` calls can now be replaced with this:

```js
const stubbedReducer = proxyquire(
    reducerPath,
    {[cardsPath]: cardUtils}
).default;
```

Now all your tests should be passing again.

To get the rest of the application to use our new reducer correctly, we need to create a file where we will combine all of our reducers into a single reducer. We'll do this in `app/reducers/index.js`. Right now we only have one reducer, so this is a little underwhelming.

<div class="fp">app/reducers/index.js</div>
```js
import { combineReducers } from 'redux';

import game from './game';

export default combineReducers({
    game
});
```

We'll have to change the location we import the reducer in `app/index.js`:

<div class="fp">app/index.js</div>
```js
// ...
import reducer from './reducer<mark>s/index</mark>';
// ...
```

Next, we need to change the `mapStateToProps` functions to read the game state variables from the `game` key in the store.

Let's start with `<App />`:

<div class="fp">app/components/app.js</div>
```js
// ...

function mapStateToProps(state) {
    return {
        playerHand: state.<mark>game.</mark>get('playerHand'),
        dealerHand: state.<mark>game.</mark>get('dealerHand'),
        gameOver: state.<mark>game.</mark>get('gameOver'),
        playerWon: state.<mark>game.</mark>get('playerWon')
    };
}

// ...
```

Similarly for `<Info />`:

<div class="fp">app/components/info.js</div>
```js
// ...

const mapStateToProps = (state) => {
    return {
        winCount: state.<mark>game.</mark>get('winCount'),
        lossCount: state.<mark>game.</mark>get('lossCount'),
        hasStood: state.<mark>game.</mark>get('hasStood'),
        gameOver: state.<mark>game.</mark>get('gameOver')
    };
};

// ...
```

The last thing left to do is to change the selector used to get the dealer hand from state in the sagas.

<div class="fp">app/sagas/index.js</div>
```js
// ...

const getDealerHand = (state) => state.<mark>game.</mark>get('dealerHand');

// ...
```

Now if you view the page in the browser, everything will be normal.

#### Settings Reducer

With our new reducer setup, it will be very simple to create a new reducer for settings. Let's do that now:

<div class="fp">app/reducers/settings.js</div>
```js
import { Map } from 'immutable';

export default function(currentState=new Map(), action) {
    return currentState;
}
```

We want a `SET_SPEED` action that will change the speed at which the dealer draws cards. Let's first write the test for the reducer:

<div class="fp">test/reducers/settings_spec.js</div>
```js
import { expect } from 'chai';
import { Map } from 'immutable';

import reducer from '../../app/reducers/settings';
import { setSpeed } from '../../app/action_creators';

describe('settings reducer', () => {
    describe('SET_SPEED', () => {
        const action = setSpeed(100);

        context('with undefined initial state', () => {
            const initialState = undefined;
            it('sets speed', () => {
                const nextState = reducer(initialState, action);
                expect(nextState.get('speed')).to.eq(100);
            });
        });

        context('with existing initial state', () => {
            const initialState = new Map({speed: 750});
            it('sets speed', () => {
                const nextState = reducer(initialState, action);
                expect(nextState.get('speed')).to.eq(100);
            });
        });
    });
});
```

We'll also need an action creator:

<div class="fp">app/action_creators.js</div>
```js
// ...

export function setSpeed(speed) {
    return { "type": "SET_SPEED", speed };
}
```

And finally the code to pass the test:

<div class="fp">app/reducers/settings.js</div>
```js
// ...

const setSpeed = (currentState, newSpeed) => {
    return currentState.set('speed', newSpeed);
};

export default function(currentState=new Map(), action) {
    switch(action.type) {
        case 'SET_SPEED':
            return setSpeed(currentState, action.speed);
    }
    return currentState;
}
```

The last thing to do is combine our settings reducer with the game reducer. We'll do this in `app/reducers/index.js`:

<div class="fp">app/reducers/index.js</div>
```js{4}
import { combineReducers } from 'redux';

import game from './game';
import settings from './settings';

export default combineReducers({
    game<mark>, settings</mark>
});
```

Now that our reducer is hooked up, try dispatching SET_SPEED actions in the browser. You should see a new "settings" key added to the root state object, and your SET_SPEED actions should change the speed within the settings `Map`.

To make our speed setting actually do something, we'll need to change the saga that deals cards to the dealer. At the beginning of the `onStand` saga, we will `select` the speed from the state.

We need to change the tests for this saga to account for this extra step. Simply add this expect statement to each of the saga tests we wrote previously:

```js
expect(selectorName(generator.next())).to
    .eq('getSpeed');
```

Now we can make these tests pass and have the saga `delay()` the correct amount between each card by making the following changes to the saga:

<div class="fp">app/sagas/index.js</div>
```js{4,7}
// ...

const getDealerHand = (state) => state.game.get('dealerHand');
const getSpeed = (state) => state.settings.get('speed');

export function* onStand() {
    const dealSpeed = yield select(getSpeed);
    let dealerHand;
    while(true) {
        yield put(dealToDealer());
        dealerHand = yield select(getDealerHand);
        if(score(dealerHand) >= 17) {
            break;
        }
        else {
            yield call(delay, <mark>dealSpeed</mark>);
        }
    }
    yield put(determineWinner());
}

export default function*() {
    yield takeLatest('STAND', onStand);
}
```

The tests should pass and if you change the speed with SET_SPEED actions in the Redux DevTools, you can make the cards appear faster or slower.

Right now the speed state variable is initially undefined. Let's fix that by adding an initial state to our store:

<div class="fp">app/index.js</div>
```js{2,6}
// ...
import { Map } from 'immutable';

// ...

const initialState = { settings: new Map({speed: 750}) };

// ...

const store = createStore(reducer, <mark>initialState</mark>, compose(
    applyMiddleware(sagaMiddleware),
    window.devToolsExtension ?
        window.devToolsExtension() : f => f
));

// ...
```

In the next step, we'll create a settings page on the application that will allow the user to choose the speed using radio buttons.

### Settings Page

If we were to create a new page in a Rails application, we would have to set up a new route, a new controller method, and a new view file. When the user clicks on the link to the settings page, the browser would have to reload the entire page and all of the front-end application state would be lost in the browser.

There is a React library called React Router that offers us the same functionality as a new route/controller/view in Rails. React Router works by deciding which components to render based on the URL typed into the browser window. When the user clicks on a link to a new route, React router just swaps which components are being displayed and the user only has to wait for the new components to render (a trivial amount of time for small applications) rather than sending a request to a server and having the browser process the response from scratch. Another advantage is that the application is not lost when the page changes. This means that if the user decides to visit the settings page in the middle of a blackjack game, the game will still be in the same state after they change the settings and return to the game page.

There is a library called React-Router-Redux that makes React Router send its events to the Redux store so they will show up in the DevTools and make debugging easier.

Let's install the package first:

```
npm install --save react-router-redux@4.0.4
```

Next, we need to add the routing reducer to our combined reducer:

<div class="fp">app/reducers/index.js</div>
```js{2,3}
// ...
import { routerReducer as routing }
    from 'react-router-redux';

// ...

export default combineReducers({
    game, settings<mark>, routing</mark>
});
```

Then we'll need to import the router, connect the router history object with our application store, and wrap our components in router components. We'll do this all in `index.js`:

<div class="fp">app/index.js</div>
```jsx{2,3,9,15-18}
// ...
import { Router, Route, hashHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';

// ...

sagaMiddleware.run(watchActions);

const history = syncHistoryWithStore(hashHistory, store);

// ...

ReactDOM.render(
    <Provider store={store}>
        <Router history={history}>
            <Route path="/" component={AppContainer} />
        </Router>
    </Provider>,
    document.getElementById('app')
);
```

Now we're ready to make a settings page. We need a top-level component for this page, so let's call it `<Settings />`.

<div class="fp">app/components/settings.js</div>
```jsx
import React from 'react';

export class Settings extends React.Component {
    render() {
        return (
            <div id="settings">
                <h1>Settings</h1>
            </div>
        );
    }
}
```

To access this page, we need to add a route to it in `index.js`:

<div class="fp">app/index.js</div>
```jsx{7}
// ...

ReactDOM.render(
    <Provider store={store}>
        <Router history={history}>
            <Route path="/" component={AppContainer} />
            <Route path="/settings" component={Settings} />
        </Router>
    </Provider>,
    document.getElementById('app')
);
```

Now if you type '#/settings' at the end of the URL you use to see your application, you'll see the settings page! Note: you could choose to use `browserHistory` rather than `hashHistory` so that you would visit '/settings' rather than '#/settings' like a normal web application. This requires additional server configuration that we are not going to deal with right now.

React Router gives us a `<Link>` component that will generate an `<a>` tag that will send the user to the correct page when clicked (automatically adjusting for if you are using `hashHistory` or `browserHistory`). Let's add this component to create links between the `App` component and the `Settings` component.

First `<App />`:

<div class="fp">app/components/app.js</div>
```jsx{2,14-16}
// ...
import { Link } from 'react-router';

// ...

export class App extends React.Component {
    render() {
        // ...

        return (
            <div className="app">
                <div className="links">
                    <Link to="/settings">Settings</Link>
                </div>
                <h1>React Blackjack</h1>
                // ...
            </div>
        );
    }
}

// ...
```

And then `<Settings />`:

<div class="fp">app/components/settings.js</div>
```jsx{2,9-11}
import React from 'react';
import { Link } from 'react-router';

export class Settings extends React.Component {
    render() {
        return (
            <div id="settings">
                <div class="links">
                    <Link to="/">Back to game</Link>
                </div>
                <h1>Settings</h1>
            </div>
        );
    }
}
```

Now you can use the links to navigate between your game and your settings page. You can also load the settings page directly by entering the URL from that page in the browser just like a normal application.

### Dealer Speed Form

Now that we have a settings page, we can put a form on it that allows the user to choose how fast the dealer should deal.

We are going to use a package called Redux Form that will take care a lot of the form logic for us. Specifically, Redux Form will dispatch actions to our reducer for various form events

Let's install Redux Form:

```
npm install --save redux-form@5.2.5
```

The first step is to add a form reducer in the same way we added the routing reducer:

<div class="fp">app/reducers/index.js</div>
```js{4}
import { combineReducers } from 'redux';
import { routerReducer as routing }
    from 'react-router-redux';
import { reducer as form } from 'redux-form';

import game from './game';
import settings from './settings';

export default combineReducers({
    game, settings, routing<mark>, form</mark>
});
```

Next, we'll create a form component in plain HTML, then we will use Redux Form to create a connected version of the form that will dispatch actions to the form router.

This is what the pure `<DealerSpeedForm />` will look like:

<div class="fp">app/components/dealer_speed_form.js</div>
```jsx
import React from 'react';

export class DealerSpeedForm extends React.Component {
    render() {
        return (
            <div class="dealer-speed-form">
                <form>
                    <label>
                        Fast
                        <input type="radio" name="speed"
                               value={250} />
                    </label>
                    <label>
                        Normal
                        <input type="radio" name="speed"
                               value={750} />
                    </label>
                    <label>
                        Slow
                        <input type="radio" name="speed"
                               value={1500} />
                    </label>
                    <input type="submit" />
                </form>
            </div>
        );
    }
}
```

We'll have to make some changes to the radio buttons, so it would be nice to DRY this code up a little bit. Before we refactor it, let's write a couple of tests to make sure nothing breaks as we change the code:

<div class="fp">test/components/dealer_speed_form_spec.js</div>
```jsx
import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import { DealerSpeedForm }
    from '../../app/components/dealer_speed_form';

describe('<DealerSpeedForm />', () => {
    const rendered = shallow(<DealerSpeedForm />);

    it('renders three radio buttons', () => {
        expect(rendered).to.have.exactly(3)
            .descendants('input[type="radio"]');
    });

    it('gives correct speeds to radio buttons', () => {
        const radios = rendered.find('input[type="radio"]');
        expect(radios.map((el) => el.prop('value'))).to
            .eql([250, 750, 1500]);
    });
});
```

Now let's put the possible speeds and labels into an array and loop through it to create the `<label>`s and `<input>`s:

<div class="fp">test/components/dealer_speed_form_spec.js</div>
```jsx
// ...
export class DealerSpeedForm extends React.Component {
    render() {
        return (
            <div class="dealer-speed-form">
                <form>
                    {[
                        ["Fast", 250],
                        ["Normal", 750],
                        ["Slow", 1500]
                     ].map((el) => (
                        <label key={el[1]}>
                            {el[0]}
                            <input type="radio"
                                   name="speed"
                                   value={el[1]} />
                        </label>
                      ))
                    }
                    <input type="submit" />
                </form>
            </div>
        );
    }
}
```

If everything went right, the tests we wrote should still pass.

With the code structured this way, we will have a much easier time if we need to change the radio buttons (such as adding new props or CSS classes to them) or add/remove new speed options.

Now let's write the code to create the connected version of the component:

<div class="fp">test/components/dealer_speed_form_spec.js</div>
```jsx{2}
import React from 'react';
import { reduxForm } from 'redux-form';

export class DealerSpeedForm extends React.Component {
    // ...
}

export const DealerSpeedFormContainer = reduxForm({
    form: 'dealerSpeed',
    fields: ['speed']
})(DealerSpeedForm);
```

We need to give `reduxForm()` a name for the form. This can be anything as long as it's unique (among other things, Redux Form will use this name as the key for the form's data in the store). We also need to give it an array of fields in the form. In this case, we just have a `speed` field. Redux Form will create props for each field.

Now we can render the form in the `Settings` component:

<div class="fp">app/components/settings.js</div>
```jsx{3-4}
import React from 'react';
import { Link } from 'react-router';
import { DealerSpeedFormContainer }
    from './dealer_speed_form';

export class Settings extends React.Component {
    render() {
        return (
            <div id="settings">
                <div class="links">
                    <Link to="/">Back to game</Link>
                </div>
                <h1>Settings</h1>
                <DealerSpeedFormContainer />
            </div>
        );
    }
}
```

If you visit the settings page in your browser, you should see the new radio buttons (don't worry -- they don't do anything yet).

To make our form actually do something, we need to use some of the props provided to us by Redux Form. First, we'll use the field props to dispatch actions on various form events. Let's get the field props for the "speed" field and pass them to the input component.

We're also going to write an `onSubmit` function that we'll give to the `handleSubmit()` prop provided by Redux Form. `handleSubmit()` will call our custom `onSubmit` function with two parameters: the values of the form inputs and the dispatch function for the store (similar to a `mapDispatchToProps()`). In this case, we just want to dispatch a `SET_SPEED` action with the value of the speed field. `handleSubmit()` will prevent the default submit action for us, so all we need to worry about is dispatching actions with the values from the form.

<div class="fp">app/components/dealer_speed_form.js</div>
```jsx{3,5-7,11,23}
import React from 'react';
import { reduxForm } from 'redux-form';
import { setSpeed } from '../action_creators';

const onSubmit = (values, dispatch) => {
    dispatch(setSpeed(parseInt(values.speed)));
};

export class DealerSpeedForm extends React.Component {
    render() {
        const speed = this.props.fields.speed;
        const handleSubmit = this.props.handleSubmit;
        return (
            <div class="dealer-speed-form">
                <form <mark>onSubmit={handleSubmit(onSubmit)}</mark>>
                    {[
                        // ...
                     ].map((el) => (
                        <label key={el[1]}>
                            {el[0]}
                            <input type="radio"
                                   name="speed"
                                   {...speed}
                                   value={el[1]} />
                        </label>
                      ))
                    }
                    <input type="submit" />
                </form>
            </div>
        );
    }
}

// ...
```

Our test will fail because it doesn't see a `fields` prop or a `handleSubmit` prop. Let's get our test to pass by providing it with these props.

<div class="fp">test/components/dealer_speed_form_spec.js</div>
```jsx
// ...

describe('<DealerSpeedForm />', () => {
    const props = {
        fields: { speed: { } },
        handleSubmit: () => { }
    };
    const rendered = shallow(<DealerSpeedForm <mark>{...props}</mark> />);

    // ...
});
```

The tests should pass again. In the browser, you should see events fired when you click on the radio buttons and when you submit the form, the speed at which the dealer draws cards should change!

We would also like to have the form show the current value of the dealer draw speed when it is rendered. Unfortunately, this version of Redux Form doesn't handle initial values for radio buttons very well, so we will have to write a couple lines of code to get it to work.

First we will need to get the initial speed from the settings in the state. We will do this with a `mapStateToProps` function.

Then we will decide which value should be checked. If `speed.value` is undefined, the radio button with the value equal to the speed in the settings should be checked. Once the user selects a radio button, `speed.value` will be set to the value of the radio button selected by the user, so the radio button with a value equal to `speed.value` should be checked.

Before we write the code in the component, we should write a test for this behavior:

<div class="fp">test/components/dealer_speed_form_spec.js</div>
```jsx{7,11-14}
// ...

describe('<DealerSpeedForm />', () => {
    const props = {
        fields: { speed: { } },
        handleSubmit: () => { }<mark>,</mark>
        initialSpeed: 750
    };
    // ...

    it('checks button with initial value', () => {
        const initial = rendered.find('input[value=750]');
        expect(initial.prop('checked')).to.eq(true);
    });
});
```

Now for the code in the component:

<div class="fp">app/components/dealer_speed_form.js</div>
```jsx{6,20,32-34}
// ...

export class DealerSpeedForm extends React.Component {
    render() {
        // ...
        const val = speed.value || this.props.initialSpeed;
        return (
            <div class="dealer-speed-form">
                <form onSubmit={handleSubmit(onSubmit)}>
                    {[
                        ["Fast", 250],
                        ["Normal", 750],
                        ["Slow", 1500]
                     ].map((el) => (
                        <label key={el[1]}>
                            {el[0]}
                            <input type="radio"
                                   name="speed"
                                   {...speed}
                                   checked={val == el[1]}
                                   value={el[1]} />
                        </label>
                      ))
                    }
                    <input type="submit" />
                </form>
            </div>
        );
    }
}

const mapStateToProps = (state) => {
    return { initialSpeed: state.settings.get('speed') };
};

export const DealerSpeedFormContainer = reduxForm({
    form: 'dealerSpeed',
    fields: ['speed']
}<mark>, mapStateToProps</mark>)(DealerSpeedForm);
```

Now when you load the page, the "normal" radio button should be checked. If you choose a different speed option, switch to the game page, and switch back to the setting page, the option you selected should be checked when the form is re-rendered!

We now have a fully functional settings form that allows the user to choose how fast the dealer will receive cards.
