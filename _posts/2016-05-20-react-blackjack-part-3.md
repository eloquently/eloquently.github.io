---
layout: post
title: React Blackjack Part 3
date: 2016-05-20
permalink: 'guides/react-blackjack-part-3'
---

## React Blackjack Part 3

<hr />

This is the third part of the guide. See the previous part [here]({% post_url 2016-05-19-react-blackjack-part-2 %}). At this point, our application has some basic functionality. We can deal cards to the player with by clicking "Deal" and disable the buttons by clicking "Stand", but it's still a stretch to call this a blackjack game.

Let's fix that.

### Winning and Losing

In our blackjack game, the player should not be allowed to take cards indefinitely. Instead, they should lose the game if they draw a card and their score is higher than 21 and win the game if their score is exactly 21.

How can we change our code to accommodate this rule? The `reducer` function is the natural place for logic like this, as it is responsible for determining the next state of the application given the current state and an action.

Before we change our reducer logic, let's first write a function that will take a `List` of cards and return their score as a blackjack hand.

We'll first need to write a test for this. We'll add this function to our `cards.js` file, so the test will be in `cards_spec.js`

<div class="fp">test/lib/cards_spec.js</div>
```js
import { expect } from 'chai';
import { List<mark>, fromJS</mark> } from 'immutable';

import { newDeck, deal<mark>, score</mark> } from '../../app/lib/cards';

describe('cards.js', () => {
    // ...

    describe('score()', () => {
        it('calculates correct score', () => {
            let hand = fromJS([{rank: 3}, {rank: 5}]);
            expect(score(hand)).to.eq(8);
            hand = fromJS([{rank: 2}, {rank: 9}]);
            expect(score(hand)).to.eq(11);
        });
    });
});
```

Let's write the code to make this pass. We are going to use the `reduce` function to caclulate the sum. In this case, `reduce()` will take two parameters: a function, which we'll describe in a second, and an initial value.

The first parameter function (let's call it `f`) itself takes two parameters. `reduce()` works by, for each element of the array, passing the result of the last `f` call (or the initial value for the first one) to `f` along with the current element. Then it evaluates `f` for those parameters, and passes the result `f` along with the next element.

In this case, we want to add each card's rank, and we'll keep track of the result in a variable called `sum`:

<div class="fp">app/lib/cards.js</div>
```js
// ...

export const score = (cards) => {
    return cards.reduce( (sum, card) => {
        return sum + card.get('rank');
    }, 0);
};
```

Now the tests should pass, but our function will only work in a very limited case: when the ranks are numbers.

Let's write the tests for when the ranks are face cards:

<div class="fp">test/lib/cards_spec.js</div>
```js{7,14,15-22}
// test/lib/cards_spec.js

describe('cards.js', () => {
    // ...

    describe('score()', () => {
        describe('with numeric ranks', () => {
            it('calculates correct score', () => {
                let hand = fromJS([{rank: 3}, {rank: 5}]);
                expect(score(hand)).to.eq(8);
                hand = fromJS([{rank: 2}, {rank: 9}]);
                expect(score(hand)).to.eq(11);
            });
        });
        describe('with face cards', () => {
            it('calculates correct score', () => {
                let hand = fromJS([{rank: 3}, {rank: 'K'}]);
                expect(score(hand)).to.eq(13);
                hand = fromJS([{rank: 'Q'}, {rank: 'J'}]);
                expect(score(hand)).to.eq(20);
            });
        });
    });
});
```

To pass the test, we will have to convert kings to 12, queens to 11, and jacks to 10. We'll write a helper method called `rankAsNum` to do that for us.

<div class="fp">app/lib/cards.js</div>
```js
// ...

import { <mark>Map, </mark>List, fromJS } from 'immutable';

// ...

export const rankAsNum = (rank) => {
    if(rank == 'K' || rank == 'Q' || rank == 'J') {
        return 10;
    } else {
        return rank;
    }
};

export const score = (cards) => {
    return cards.reduce( (sum, card) => {
        return sum + <mark>/* What goes here? */</mark>;
    }, 0);
};
```

Once you get the test to pass, the next step is to consider is what happens with aces. In blackjack, the ace can be worth either 1 point or 11 points. For this application, we want the ace to count as 11 unless total of the hand is greater than 21.

Let's clarify what we want with some test cases:

<div class="fp">test/lib/cards_spec.js</div>
```js
describe('cards.js', () => {
    // ...

    describe('score()', () => {
        // ...

        describe('with aces', () => {
            it('counts aces as 11 for hands less than 21', () => {
                const hand = fromJS([{rank: 3}, {rank: 'A'}]);
                expect(score(hand)).to.eq(14);
            });

            it('counts aces as 11 for hands equal to 21', () => {
                let hand = fromJS([{rank: 10}, {rank: 'A'}]);
                expect(score(hand)).to.eq(21);
                hand = fromJS([{rank: 'A'}, {rank: 'K'}]);
                expect(score(hand)).to.eq(21);
            });

            it('counts aces as 1 for hands greater than 21', () => {
                let hand = fromJS([{rank: 3}, {rank: 'A'}, {rank: 9}]);
                expect(score(hand)).to.eq(13);
                hand = fromJS([{rank: 'K'}, {rank: 'K'}, {rank: 'A'}]);
                expect(score(hand)).to.eq(21);
            });

            it('works with multiple aces', () => {
                let hand = fromJS([{rank: 'A'}]);
                expect(score(hand)).to.eq(11);
                hand = hand.push(new Map({rank: 'A'}));
                expect(score(hand)).to.eq(12);
                hand = hand.push(new Map({rank: 'A'}));
                expect(score(hand)).to.eq(13);
                hand = hand.push(new Map({rank: 'A'}));
                expect(score(hand)).to.eq(14);
                hand = fromJS([{rank: 'A'}, {rank: 'K'}, {rank: 'A'}]);
                expect(score(hand)).to.eq(12);
            })
        });
    });
});
```

Modifying the `score` function to pass these tests is a great way to practice for interview questions. Try to pass the tests yourself before looking at our solution below.

If you're getting stuck, here is an English description of how to solve the problem:

- Count how many aces there are in the hand (`acesCount`)
- Calculate the score of the rest of the hand and add 1 for each ace that was removed. Store this in a variable called `score`.
- Add 10 if `score` is less than or equal to 11

Before moving on to the code, think about this and write out by hand a few examples of how this algorithm would be applied (maybe one per each of the four test cases above). Why does this work? Why do we only have to add ten once at the end? Does that part still work if there are multiple aces?

Once you feel like you've figured out how this algorithm works, try to code it yourself before looking at our code.

<div class="fp">app/lib/cards.js</div>
```js
// ...

export const score = (cards) => {
    const aces = cards.filter((card) => card.get('rank') == 'A');
    const nonAces = cards.filter((card) => card.get('rank') != 'A');

    if(nonAces.size == 0 && aces.size == 0) {
        return 0;
    } else if(aces.size == 0) {
        return cards.reduce( (sum, card) => {
            return sum + rankAsNum(card.get('rank'));
        }, 0);
    } else {
        let acesAllOneScore = score(nonAces) + aces.size;
        if(acesAllOneScore <= 11) {
            acesAllOneScore += 10;
        }
        return acesAllOneScore;
    }
};
```

Now that we can calculate a score, we can check the player's score after they have received a card. If their score is higher than 21, we should increase the loss count. If the score is exactly 21, we should increase the win count. We will do this in the `reducer` helper function `dealToPlayer()`. Let's write the test first:

<div class="fp">test/reducer_spec.js</div>
```js{10-12,24-35}
// ...
import { Map, List<mark>, fromJS</mark> } from 'immutable';

// ...

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


        describe("when player gets more than 21 points", () => {
            const initialState = fromJS({
                "playerHand": [{rank: 'K'}, {rank: 'Q'}],
                "deck": fromJS([{rank: 'J'}]),
                "lossCount": 0
            });
            const nextState = reducer(initialState, action);

            it('increases loss count by 1', () => {
                expect(nextState.get('lossCount')).to.eq(initialState.get('lossCount') + 1);
            });
        });

        describe("when player gets exactly 21 points", () => {
            const initialState = fromJS({
                "playerHand": [{rank: 'K'}, {rank: 2}],
                "deck": fromJS([{rank: 9}]),
                "winCount": 0
            });
            const nextState = reducer(initialState, action);

            it('increases win count by 1', () => {
                expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            });
        });

    // ...
});
```

In these tests, we cheat a little bit to make the player draw the right card for the scenario we want to test by only putting one card in the deck. Our tests here are not exactly "unit" tests because they have a lot of dependencies on other parts of the program. Specifically, if something goes wrong with the `score` function (or the `draw` function), this test won't work any more. This is not ideal, and we could use stubs from Sinon to make our tests more independent. We will see how this works in a little bit.

And then add some logic to the reducer:

<div class="fp">app/reducer.js</div>
```js{12-22}
// ...

import { newDeck, deal<mark>, score</mark> } from './lib/cards.js';

// ...

const dealToPlayer = (currentState, seed) => {
    const [deck, newCard] = deal(currentState.get('deck'), 1, seed);

    const playerHand = currentState.get('playerHand').push(newCard.get(0));

    let newState = new Map({ deck, playerHand });

    const newScore = score(playerHand);

    if(newScore > 21) {
        const lossCount = currentState.get('lossCount') + 1;
        newState = newState.set('lossCount', lossCount);
    } else if(newScore == 21) {
        const winCount = currentState.get('winCount') + 1;
        newState = newState.set('winCount', winCount);
    }

    return currentState.merge(newState);
};

// ...
```

Now try playing a game in your browser. Keep clicking "hit" until your score is above 21. You should see your loss count increase (unless you were lucky enough to hit 21 exactly). Note that if you continue to click "hit", you continue drawing cards and your loss count continues to rise.

Let's think about what should happen after each game ends. It would be nice to show a message to the player saying whether the game ended with a win or a loss. It would also be nice to show the cards at the end of the game before immediately resetting the game (otherwise the player would never know the last card drawn) and displaying a button the player can click when ready to start the next game.

We'll need a new component for the game over message that will contain a string like "You win!" and a "New Game" button. This component is going to take two props. One will determine whether it should show a win message or a loss message, the other will contain the callback function for when the user hits the "New Game" button.

Let's write some tests for the component. First we want to give the component a different message depending on the value of the `win` prop.

<div class="fp">test/components/game_over_message_spec.js</div>
```js
import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';

import { GameOverMessage } from '../../app/components/game_over_message';

describe('<GameOverMessage />' , () => {
    describe('for win', () => {
        const rendered = shallow(<GameOverMessage win={true} />);

        it('displays message', () => {
            expect(rendered).to.include.text('You win!');
        });
    });

    describe('for loss', () => {
        const rendered = shallow(<GameOverMessage /* What goes here */ />);

        it('displays message', () => {
            expect(rendered).to.include.text('You lose :(');
        });
    });
});
```

Next, we'll write the tests for the button. We'll use a sinon spy again to make sure that the callback prop is executed when the "Next Game" button is clicked.

<div class="fp">test/components/game_over_message_spec.js</div>
```js{3,10-18}
// ...
import { shallow<mark>, simulate</mark> } from 'enzyme';
import sinon from 'sinon';

// ...

describe('<GameOverMessage />' , () => {
    // ...

    describe('next game button', () => {
        it('triggers callback when button is pressed', () => {
            const nextGameSpy = sinon.spy();
            const rendered = shallow(<GameOverMessage nextGame={nextGameSpy} />);

            rendered.find('button').simulate('click');
            expect(nextGameSpy.calledOnce).to.eq(true);
        });
    });
});
```

First we'll get the message tests to pass:

<div class="fp">app/components/game_over_message.js</div>
```js
import React from 'react';

export class GameOverMessage extends React.Component {
    render() {
        return (
            <div id="game_over_message">
                { this.props.win ? 'You win!' : 'You lose :(' }
            </div>
        );
    }
}
```

Next, we need to add a button, and give the button an `onClick` prop:

<div class="fp">app/components/game_over_message.js</div>
```jsx{8}
import React from 'react';

export default class GameOverMessage extends React.Component {
    render() {
        return (
            <div id="game_over_message">
                { this.props.win ? 'You win!' : 'You lose :(' }
                <button onClick={this.props.nextGame}>Next Game</button>
            </div>
        );
    }
}
```

Now all three tests should pass. Next, we need to have the `App` comopnent render the message when the game is over. To determine if the game is over, we will need another state variable: `gameOver`. Since we also will need to know if the player won or lost in order to display the correct message, we will need another state variable: `playerWon`. Both of these variables will be booleans.

At the start of the game and each time the game is reset, we'll want `gameOver` to be `false`. The best way to initialize this variable is to do so in the `SETUP_GAME` action that is called at the start of the application and each time the game needs to be reset. We'll also want to initialize `playerWon` to `undefined` when we `SETUP_GAME`. `playerWon` only needs a value if `gameOver` is `true`.

Let's add a test for this in the `SETUP_GAME` action's reducer test:

<div class="fp">test/reducer_spec.js</div>
```js{10-16}
// ...

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        const action = setupGame();

        describe("with empty initial state", () => {
            // ...

            it('sets up gameOver', () => {
                expect(nextState.get('gameOver')).to.eq(false);
            });

            it('sets up playerWon', () => {
                expect(nextState.get('playerWon')).to.eq(undefined);
            });
        });

        describe("with existing initial state", () => {
            // ...

            it('adds new variables', () => {
                expect(Array.from(nextState.keys())).to.include(
                    'deck', 'playerHand', 'dealerHand',
                    'hasStood'<mark>, 'gameOver', 'playerWon'</mark>
                );
            });

            // ...
        });
    });

    // ...
});
```

We'll need to add a few lines to the `reducer.js` file to initialize these variables:

<div class="fp"></div>
```js{12,13}
const setupGame = (currentState, seed) => {
    let deck = newDeck(seed);
    let playerHand, dealerHand;

    [deck, playerHand] = deal(deck, 2, seed);
    [deck, dealerHand] = deal(deck, 1, seed + 1);

    dealerHand = dealerHand.push(new Map());

    const hasStood = false;

    const gameOver = false;
    const playerWon = undefined;

    const newState = new Map({
        deck, playerHand,
        dealerHand, hasStood,
        <mark>gameOver, playerWon</mark>
    });

    return currentState.merge(newState);
};
```

The tests should now pass. Now, we change our App component to render the message when appropriate. First the tests:

<div class="fp">test/components/app_spec.js</div>
```jsx
// test/components/app_spec.js

// ...

describe('<App />', () => {
    // ...

    describe('when gameOver', () => {
        const rendered = shallow(<App gameOver={true} />);

        it('renders <GameOverMessage />', () => {
            expect(rendered.find('GameOverMessage')).to.have.length(1);
        });

        describe('player won', () => {
            const rendered = shallow(<App gameOver={true} playerWon={true} />);
            it('gives <GameOverMessage /> correct prop', () => {
                expect(rendered.find('GameOverMessage')).to.have.prop('win', true);
            });
        });

        describe('player lost', () => {
            const rendered = shallow(<App gameOver={true} playerWon={false} />);
            it('gives <GameOverMessage /> correct prop', () => {
                expect(rendered.find('GameOverMessage')).to.have.prop('win', false);
            });
        });
    });
});
```

Now let's add the message to our App component. One of the limitations of JSX is that you cannot put multi-line JavaScript expresssions (like an `if`-`else`) in the JSX (see [this page](https://facebook.github.io/react/tips/if-else-in-JSX.html) for an explanation). So far, we have been getting around this limitation by using ternary statements. In this case though, let's use an `if` statement to keep our render function cleaner and show how it can be done.

<div class="fp">app/components/app.js</div>
```jsx{2,6-9,15}
// ...
import { GameOverMessage } from './game_over_message';

export class App extends React.Component {
    render() {
        let messageComponent;
        if(this.props.gameOver) {
            messageComponent = <GameOverMessage win={this.props.playerWon} />;
        }

        return (
            <div className="app">
                <h1>React Blackjack</h1>
                <InfoContainer />
                { messageComponent }
                <strong>Player hand:</strong>
                <Hand cards={this.props.playerHand } />
                <strong>Dealer hand:</strong>
                <Hand cards={this.props.dealerHand } />
            </div>
        );
    }
}

// ...
```


If `gameOver` is false, the `messageComponent` will be undefined. When we try to render `undefined`, React will just output nothing, which is what we want in this case.

Let's also change the `mapStateToProps` function so that the connected `App` will update when the reducer changes `gameOver` and `playerWon`.

<div class="fp">app/components/app.js</div>
```js
// ...
function mapStateToProps(state) {
    return {
        playerHand: state.get('playerHand'),
        dealerHand: state.get('dealerHand'),
        gameOver: state.get('gameOver'),
        playerWon: state.get('playerWon')
    };
}
```

Now, we need to make the reducer for `DEAL_TO_PLAYER` use the `gameOver` and `playerWon` variables to tell the `App` component to show the message. Let's add these requirements to the tests:

<div class="fp">test/reducer_spec.js</div>
```js
// ...

describe('reducer', () => {
    // ...

    describe("DEAL_TO_PLAYER", () => {
        // ...

        describe("when player gets more than 21 points", () => {
            // ...

            it('toggles gameOver and sets playerWon', () => {
                expect(nextState.get('gameOver')).to.eq(true);
                expect(nextState.get('playerWon')).to.eq(false);
            });
        });

        describe("when player gets exactly 21 points", () => {
            // ...

            it('toggles gameOver and sets playerWon', () => {
                expect(nextState.get('gameOver')).to.eq(true);
                expect(nextState.get('playerWon')).to.eq(true);
            });
        });
    });

    // ...
});
```

Now let's change the reducer function so that these tests pass:

<div class="fp">app/reducer.js</div>
```js{7-10,12}
// ...

const dealToPlayer = (currentState, seed) => {
    // ...

    if(newScore > 21) {
        const lossCount = currentState.get('lossCount') + 1;
        const gameOver = true;
        const playerWon = false;
        newState = newState.merge({lossCount, gameOver, playerWon});
    } else if(newScore == 21) {
        /* Your code here */
    }

    return currentState.merge(newState);
};

// ...
```

Now try playing a game in the browser. The correct message should be shown if you go over 21 or get 21 exactly. The message is a little hard to see, so we should clean it up with some CSS:

Create a `game_over_message.scss` file in your `app/css/components`, and then import in `components/_all.scss`:

<div class="fp">app/css/components/_all.scss</div>
```scss
@import 'card';
@import 'info';
@import 'game_over_message';
```

Then you can add my style for `#game_over_message` or modify it to look nicer.

<div class="fp">app/css/components/game_over_message.scss</div>
```scss
#game_over_message {
    border: 1px solid #999;
    width: 300px;
    padding: 20px;
    margin-bottom: 10px;

    button {
        float: right;
    }
}
```

For extra practice with React components, try to give `<GameOverMessage />` a different CSS class so the message can look different depending on whether the player won or lost.

Now that everything is looking nice, let's make that "Next Game" button do something when clicked. To do this, we'll create a `mapDispatchToProps` function on the `GameOverMessage` component and create a connected version of the component:

<div class="fp">app/components/game_over_message.js</div>
```js{2-3,9-15}
import React from 'react';
import { connect } from 'react-redux';
import { setupGame } from '../action_creators';

export class GameOverMessage extends React.Component {
    // ...
}

function mapDispatchToProps(dispatch) {
    return {
        nextGame: () => dispatch(setupGame())
    };
}

export const GameOverMessageContainer = connect(undefined, mapDispatchToProps)(GameOverMessage);
```

Now we want `App` to render the connected `GameOverMessageContainer` component rather than the "dumb" `GameOverMessage` component. Let's change the tests first.

<div class="fp">test/components/app_spec.js</div>
```jsx
// ...

describe('<App />', () => {
    // ...

    describe('when gameOver', () => {
        const rendered = shallow(<App gameOver={true} />);

        it('renders <GameOverMessage<mark>Container</mark> />', () => {
            expect(rendered.find('<mark>Connect(GameOverMessage)</mark>')).to.have.length(1);
        });

        describe('player won', () => {
            const rendered = shallow(<App gameOver={true} playerWon={true} />);
            it('gives <GameOverMessage<mark>Container</mark> /> correct prop', () => {
                expect(rendered.find('<mark>Connect(GameOverMessage)</mark>')).to.have.prop('win', true);
            });
        });

        describe('player lost', () => {
            const rendered = shallow(<App gameOver={true} playerWon={false} />);
            it('gives <GameOverMessage<mark>Container</mark> /> correct prop', () => {
                expect(rendered.find('<mark>Connect(GameOverMessage)</mark>')).to.have.prop('win', false);
            });
        });
    });
});
```

To finish up, we just need to change the component that is rendered in our `App` component:

<div class="fp">app/components/app.js</div>
```jsx
// ...

export class App extends React.Component {
    render() {
        let messageComponent;
        if(this.props.gameOver) {
            messageComponent = <GameOverMessage<mark>Container</mark> win={this.props.playerWon} />;
        }
        // ...
    }
}
// ..
```

One problem that still needs to be fixed: the player can draw cards even if the game is over. Let's prevent this by disabling the "Hit" and "Stand" buttons.

Before we figure out how to implement this behavior, let's write a test for it.

We already disable the buttons when `hasStood` is true, and now we want to do the same thing when `gameOver` is true. We already have a test for `hasStood`, and this test will look very similar. Try writing the test yourself before looking at our code below.

Your test should fail and give you output that looks like:

```
AssertionError: expected the node in <Info /> to have a 'disabled' attribute

HTML:

<button>Hit</button>
```

Here is our test:

<div class="fp">test/components/info_spec.js</div>
```jsx
// ...

describe('<Info />', () => {
    // ...

    describe('when gameOver is true', () => {
        const rendered = shallow(<Info gameOver={true} />);

        it('disables hit and stand buttons', () => {
            const buttons = rendered.find('button');
            buttons.forEach((b) => {
                expect(b).to.have.attr('disabled');
            });
        });
    });
});
```

To make our `Info` component code more DRY and the render function less complicated, let's calculate whether the buttons should be disabled before the return statement:

<div class="fp">app/components/info.jsx</div>
```jsx{5-8}
// ...

export class Info extends React.Component {
    render() {
        let disableButtons = false;
        if(this.props.hasStood || this.props.gameOver) {
            disableButtons = true;
        }
        return (
            <div id="info">
                <span id="player_record">
                    Wins: {this.props.winCount} Losses: {this.props.lossCount}
                </span>
                <span id="buttons">
                    <button disabled={<mark>disableButtons</mark>}
                            onClick={this.props.onClickHit}>
                        Hit
                    </button>
                    <button disabled={<mark>disableButtons</mark>}
                            onClick={this.props.onClickStand}>
                        Stand
                    </button>
                </span>
            </div>
        );
    }
}
```

Now we need to add `gameOver` to `mapDispatchToProps()` so that we get `gameOver` from the store:

<div class="fp">app/components/info.js</div>
```js{8}
// ...

const mapStateToProps = (state) => {
    return {
        winCount: state.get('winCount'),
        lossCount: state.get('lossCount'),
        hasStood: state.get('hasStood')<mark>,</mark>
        gameOver: state.get('gameOver')
    };
};

// ...
```

### Blackjack!

It's also possible for the user to get 21 on their initial deal by getting an ace and a card worth 10 points.

We should account for this possibility in the `SETUP_GAME` action's reducer function.

We won't be able to use on the trick of stacking the deck to control which cards are dealt for these tests because `SETUP_GAME` creates a whole new deck. This means that we will have to overwrite ("stub") the deal method.

To do this, we are going to use a new package called Proxyquire. Let's first install Proxyquire:

```
npm install --save-dev proxyquire
```

Proxyquire allows us to require another file and replace the things that that file requires with stubs (or anything we want). In this case, we are going to require a special reducer that uses a stubbed `deal` function -- one that only deals aces and jacks. The reducer gets its `deal` function from `./lib/cards.js`, so we want to use Proxyquire to replace to `deal` function in that file with our special function.

Proxyquire provides us with a function, `proxyquire()`, that takes two arguments: the file that we are importing from and an object with keys that tell it which modules we want to replace (these should line up with the `from "..."` lines in the file we're requiring). The values of the object in the second parameter are more objects that have keys that are the names of the functions (or classes or anything else that is exported) that we want to replace and the values are their replacements. If something that we import isn't overridden, it will just use the original "thing" (function, class, etc.). Here's an example to make it more concrete:

```js
const action = setupGame();
const initialState = undefined;

const cardUtils = { }; // we'll put the overrides in here

/* require reducer.js but override the functions
   imported from './lib/cards.js' with the functions
   in cardUtils (if there are any).
   we have the .default at the end because the reducer
   function is the default export from the reducer.js
   file */
const stubbedReducer = proxyquire(
    '../app/reducer.js',
    {'./lib/cards.js': cardUtils}
).default;

/* this is the function we want to replace deal with
   proxyquire will tell the reducer to use this function
   instead of the usual deal function because we put it
   in cardUtils. We'll just return an empty List for the
   deck and an ace and a jack for the cards dealt */
cardUtils.deal = () => {
    return [
        new List(),
        fromJS([
            {suit: 'S', rank: 'A'},
            {suit: 'S', rank: 'J'}
        ])
    ];
}


const nextState = stubbedReducer(initialState, action);

/* now every time we try to deal in the reducer
   we will end up dealing out an ace and jack */
```

In this case, we just wrote our own override function for `deal()` but we also could have used a Sinon stub if we wanted something more flexible.

Let's add this to our reducer test:

<div class="fp">test/reducer_spec.js</div>
```js{2}
// ...
import proxyquire from 'proxyquire';

import reducer from '../app/reducer';

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        const action = setupGame();

        // ...

        describe("when dealt winning hand", () => {
            const cardUtils = { };
            const stubbedReducer = proxyquire('../app/reducer.js', {'./lib/cards.js': cardUtils}).default;
            cardUtils.deal = () => [new List(), fromJS([{suit: 'S', rank: 'A'}, {suit: 'S', rank: 'J'}])];

            const initialState = undefined;
            const nextState = stubbedReducer(initialState, action);

            it('sets gameOver and playerWon', () => {
                expect(nextState.get('gameOver')).to.eq(true);
                expect(nextState.get('playerWon')).to.eq(true);
            });
        });
    });

    // ...
});
```

Now the code for reducer to make this test pass:

<div class="fp">app/reducer.js</div>
```js{7-10}
const setupGame = (currentState, seed) => {
    // ...

    <mark>let</mark> gameOver = false;
    <mark>let</mark> playerWon = undefined;

    if(score(playerHand) == 21) {
        gameOver = true;
        playerWon = true;
    }

    const newState = new Map({
        deck, playerHand,
        dealerHand, hasStood,
        gameOver, playerWon
    });

    return currentState.merge(newState);
};
```

We'll also want to increase the winCount. Here's the test:

<div class="fp">test/reducer_spec.js</div>
```js
// ...

describe('reducer', () => {
    describe("SETUP_GAME", () => {
        // ...

        describe("when dealt winning hand", () => {
            // ...

            it('increments winCount', () => {
                expect(nextState.get('winCount')).to.eq(initialState.get('winCount') + 1);
            });
        });
    });
});
```

In this case, the reducer code is a little trickier. It's possible to call SETUP_GAME before winCount has been set. Therefore we need to initialize `winCount` to 0 before incrementing it. We can use an `||` operator as a shortcut. We will use a line that looks like this:

```js
let winCount = currentState.get('winCount') || 0;
```

This is saying set `winCount` equal to `currentState.get('winCount')` unless `currentState.get('winCount')` is `undefined` (or `false`). If it's `undefined`, set it to 0.

Here is the code for the reducer:

<div class="fp">app/reducer.js</div>
```js{7,12}
// ...
const setupGame = (currentState, seed) => {
    // ...

    let gameOver = false;
    let playerWon = undefined;
    let winCount = currentState.get('winCount') || 0;

    if(score(playerHand) == 21) {
        gameOver = true;
        playerWon = true;
        winCount += 1;
    }

    const newState = new Map({
        deck, playerHand,
        dealerHand, hasStood,
        gameOver, playerWon<mark>,</mark>
        <mark>winCountwin</mark>
    });

    return currentState.merge(newState);
};
// ...
```

If you want to test it in the browser, keep playing games until you're dealt blackjack. You can also dispatch a `SETUP_GAME` event with the seed `1463783318510` in the Redux DevTools (don't ask me how long it took to get that!).

#### Debugging

Imagine you just deployed this code to production and you go home for the day. At 3AM, you get a call from your boss saying "I keep getting user error reports! Fix the problem!!" You log into the support email system and see hundreds of people with claims like this:

```
I loaded your page and I got an ace and king.

The page said I won, but my win count didn't go up!!!!

Fix this or I'll sue you!
```

What went wrong?


-- Incomplete -- Work in progress.
