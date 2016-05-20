---
layout: post
title: React Blackjack Part 3
permalink: 'guides/react-blackjack-part-3'
---

## React Blackjack Part 3

<hr />

This is the third part of the guide. See the previous part [here]({% post_url 2016-05-19-react-blackjack-part-2 %}). At this point, our application has some basic functionality. We can deal cards to the player with by clicking "Deal" and disable the buttons by clicking "Stand", but it's still a stretch to call this a blackjack game.

Let's fix that.

### Blackjack Logic

In our blackjack game, the player should not be allowed to take cards indefinitely. Instead, they should lose the game if they draw a card and their score is higher than 21.

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

<div class="fp">app/lib/cards_spec.js</div>
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
        describe('with numberic ranks', () => {
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

<div class="fp">app/lib/cards_spec.js</div>
```js
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
                hand = hand.push({rank: 'A'});
                expect(score(hand)).to.eq(2);
                hand = hand.push({rank: 'A'});
                expect(score(hand)).to.eq(3);
                hand = hand.push({rank: 'A'});
                expect(score(hand)).to.eq(4);
            })
        });
    });
});
```

Modifying the `score` function to pass these tests is a great way to practice for interview questions. Try to pass the tests yourself before looking at our solution below.

If you're getting stuck, here is an English description of how to solve the problem:

- Remove all the aces from the hand
