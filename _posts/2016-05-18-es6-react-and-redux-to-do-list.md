---
layout: post
title: ES6, React, and Redux - To Do List
date: 2016-05-17
permalink: 'guides/es6-react-redux'
---

## React and Redux

This guide adds Redux to a simple React to-do list application that has already been built. The starting point for this code is the `basic_components` branch of [this repository](https://github.com/eloquently/redux-todo-guide). This guide will walk through applying Redux to that to-do list application.

To get started, clone the repository, checkout the `basic_components` branch, and install the dependencies.

```
git clone https://github.com/eloquently/redux-todo-guide.git
cd redux-todo-guide
git checkout basic_components
npm install
```

You can run the server for the application by running `npm run webpack-dev-server` in the terminal. Run the tests by running `npm run test:watch` in the terminal.

### Immutable State

The first requirement of Redux is that the all the state be stored in a single, immutable data structure. For this project, we are going to use data structures provided by a package called ImmutableJS. ImmutableJS provides us with immutable versions of objects and arrays called Maps and Lists. The interface to access them is slightly different, but they have much of the same functionality. The big difference is that if you try to change an immutable Map or List, you will end up with a copy of the object and the original object will remain unchanged. Here is a brief example:

```js
/* Normal JS Array */
const a = [1, 2, 3];
const b = a.pop();
console.log(a); // => [1, 2]
console.log(b); // => 3

/* Immutable List */
const x = List([1, 2, 3]);
const y = x.last();
const z = List.pop();
console.log(x); // => List([1, 2, 3])
console.log(y); // => 3
console.log(z); // => List([1, 2])
```

It takes us an extra step to "pop" the immutable `x`, but the benefits of having immutable data structures is that it's very easy to keep track of them. Using immutable data structures with Redux allows us to do useful things such as "undo" events that happened many steps ago.

Let's set up the initial state of our application so that it uses immutable Maps and Lists rather than objects and arrays. First we'll need to install ImmutableJS:

```
npm install --save immutable@^3.8
```

Immutable JS comes with a function called `fromJS()`, which takes a nested group of objects and arrays and returns an immutable set of nested Lists and Maps. We'll import it and use it on `state`:

<div class="fp">src/index.js</div>
```js{2,6,24}
// ...
import { fromJS } from 'immutable';

// ...

const state = fromJS({
    items: [
        {
            id: 1,
            content: "Go to the store",
            complete: true
        },
        {
            id: 2,
            content: "Buy an apple",
            complete: false
        },
        {
            id: 3,
            content: "Buy a pear",
            complete: false
        }
    ]
});

// ...
```

We're also defining an initial state in our test for the `App` component, so let's change that one to an immutable object as well:

<div class="fp">test/components/app_spec.js</div>
```js{2,6,24}
// ...
import { fromJS } from 'immutable';

// ...

const state = fromJS({
    items: [
        {
            id: 1,
            content: "Go to the store",
            complete: true
        },
        {
            id: 2,
            content: "Buy an apple",
            complete: false
        },
        {
            id: 3,
            content: "Buy a pear",
            complete: false
        }
    ]
});

// ...
```

##### Debugging

If we save the files and look at the browser, we will notice that nothing renders and we have an error: "Cannot read property 'map' of undefined" coming from line 9 of `item_list.js`. This is the line where we call `this.props.items.map` in the `ItemList` component, so the error is teling us that `this.props.items` is undefined.

Let's look at where we render `ItemList` and see what components we pass to it. Inside the `App` component, we call: `<ItemList items={ this.props.state.items } />`. This is where the error is: we end up passing `undefined` to `<ItemList>` because `.items` is not how we get something out of the state Map.

Now that we've identified this bug, let's add a test for the `App` component that checks if it is passing something to `<ItemList />`:

<div class="fp">test/components/app_spec.js</div>
```js
// ...

describe('<App />', () => {
    describe('render()', () => {
        // ...

        it('renders ItemList with items prop', () => {
            expect(wrapper.find('ItemList')).to.have.length(1);
            expect(wrapper.find('ItemList').props()).to.include.key('items');
            expect(wrapper.find('ItemList').props().items).not.to.be.an('undefined');
        });
    });
});
```

To fix the error and make the test pass, we need to change the `App` component so that it correctly extracts the value from the state `Map`. To get a value out of a `Map`, we will use the `get()` function:

<div class="fp">src/components/app.js</div>
```js
// ...

export class App extends React.Component {
    render() {
        return (
            <div className="app">
                <h1>{ this.props.name }</h1>
                <ItemList items={ this.props.state.get('items') } />
            </div>
        );
    }
}
```

We will need to make a similar change to the `ItemList` component. In this component we are trying to set the props of the items with statements like `i.id`. Since `i` is no longer an object, this doesn't work. In this case, though there is no error, but the `<Item />`'s receive `undefined` for their props, and so nothing is rendered on the screen. This is why testing is important! It would be easy to fail to notice that our program was not working correctly here since it doesn't give an error message or break the program in any way.

Let's write a test to ensure that the `<Item />`'s get the right props:

<div class="fp">test/components/item_list_spec.js</div>
```js
import React from 'react';
import { expect } from 'chai';
import { shallow } from 'enzyme';
import { fromJS } from 'immutable';

import { ItemList } from '../../src/components/item_list';

const items = fromJS([
    { id: 1, content: "test item 1", complete: true },
    { id: 2, content: "test item 2", complete: false }
]);

describe('<ItemList />', () => {
    const wrapper = shallow(<ItemList items={items} />);
    it('renders Items with correct props', () => {
        expect(wrapper.find('Item')).to.have.length(2);
        const firstItemProps = wrapper.find('Item').first().props();
        expect(firstItemProps).to.include.keys('content', 'complete');
        expect(firstItemProps.content).to.eq('test item 1');
        expect(firstItemProps.complete).to.eq(true);
        const secondItemProps = wrapper.find('Item').last().props();
        /* WRITE A TEST HERE TO CHECK secondItemProps.content */
        /* WRITE A TEST HERE TO CHECK secondItemProps.complete */
    });
});
```

After creating a new `spec` file, you will have to restart your `npm run test:watch` process. To exit it, click on the terminal it is running in and press `ctrl+c`. To start it again, press the up arrow on your keyboard and hit enter.

Then fix the component so that the tests pass and everything looks okay in the browser:

<div class="fp">item_list.js</div>
```js
// ...

export class ItemList extends React.Component {
    render() {
        return (
            <div className="item-list">
                { this.props.items.map( (i) =>
                    <Item key={i.get('id')}
                          id={/* WHAT GOES HERE */}
                          content={/* WHAT GOES HERE */}
                          complete={/* WHAT GOES HERE */} />
                )}
            </div>
        );
    }
}

```

Now that our state is immutable, we are ready to set up the `reducer` function.

### Reducer and Actions

In Redux, we write a single "reducer" function. The reducer function will take two parameters: the `currentState` and an `action`. It should return the `nextState` that the application should have after applying `action`. In the case of our simple to-do app, an action we might want to perform is `TOGGLE_ITEM`. When the reducer receives this action, it will find the item we want to toggle in `currentState`, and return a `nextState` which is exactly the same as `currentState`, except we will change `complete` to `false` if it's currently `true` or change `complete` to `true` if it's currently `false`.

`reducer()` should be a pure function, which means two things:

- It should always return the same thing when it is called with the same parameters.
- It should not have any side effects -- specifically we don't want to mutate the `currentState` parameter.

We are modeling our state with an immutable `Map`, so we don't have to worry very much about that second condition. The first condition means that `reducer()` should only look at the `currentState` parameter to decide how to calculate `nextState`.

For most actions, you won't need to go out of your way to meet these conditions, but it's important to keep them in the back of your mind.

Let's write `reducer()`!

<div class="fp">src/reducer.js</div>
```js
export function reducer(currentState, action) {

}
```

We don't need to import or extend anything -- `reducer()` is just a regular function.

Now let's start filling in the `reducer()`. The first thing we want it to do is return an empty `Map` if no `currentState` is given. Let's write a test for this:

<div class="fp">test/reducer_spec.js</div>
```js
import { expect } from 'chai';
import { Map } from 'immutable';

import { reducer } from '../src/reducer.js';

describe("reducer()", () => {
    it('returns empty Map if currentState is undefined', () => {
        expect(reducer(undefined, undefined)).to.eq(Map());
    });
});
```

To make this method pass, we will set a default parameter for `currentState` and just return `currentState` inside the function:

<div class="fp">src/reducer.js</div>
```js
import { Map } from 'immutable';

export function reducer(currentState = new Map(), action) {
    return currentState;
}
```

Now we are ready to write our `TOGGLE_ITEM` action. Actions are simply objects that have a `type` key and any other keys they need (not all actions need additional data). In order to toggle an item, we will also need to know which item to toggle, so we will have to include the item id in the action. Therefore, a `TOGGLE_ITEM` action will look something like this:

```js
{
    "type": "TOGGLE_ITEM",
    "id": 3
}
```
If the reducer receives this function, it should switch the `complete` value for the item with `id` 3.

Let's write a test for this. We'll also write a test to ensure that the `complete` value of another item in the list isn't changed.

<div class="fp">test/reducer_spec.js</div>
```js{2}
import { expect } from 'chai';
import { Map, fromJS } from 'immutable';

// ...

describe("reducer()", () => {
    // ...

    describe('TOGGLE_ITEM', () => {
        const currentState = fromJS({
            items: [
                { id: 3, complete: false },
                { id: 2, complete: true }
            ]
        });
        const action = { type: "TOGGLE_ITEM", id: 3 };

        const nextState = reducer(currentState, action);

        it('changes complete for correct item', () => {
            expect(nextState.get('items').get(0).get('complete')).to.eq(true);
        });

        it('does not change complete for other items', () => {
            expect(nextState.get('items').get(1).get('complete')).to.eq(true);
        });

    });
});
```

The second test will pass right away because right now `reducer()` just returns the currentState without changing anything. It's just there to make sure we don't make a mistake when we change `reducer()`.

One quick note: ImmutableJS provides us with a function called `getIn()` that makes it easier to write a statement that has several chained `get()`'s. We could rewrite our tests so that they look like this instead:

```
expect(nextState.getIn(['items', 0, 'complete'])).to.eq(true);
```

After rewriting your tests to use `getIn()`, it's time to make these tests pass by adding to our `reducer()`:

<div class="fp">src/reducer.js</div>
```js
// ...
export function reducer(currentState = new Map(), action) {
    if(action !== undefined) {
        switch(action.type) {
            case 'TOGGLE_ITEM':
                return toggleItem(currentState, action.id);
        }
    }
    return currentState;
}
```

We're not done yet, but let's briefly talk about what we've added. We write a `switch` statement on `action.type`. `switch` is just a condensed way to writing a sequence of `if`/`else if`s. If `TOGGLE_ITEM` is the action type, then we are going to call a function called `toggleItem`, and give it the currentState and the `id` from the action. Next we'll write the `toggleItem()` function. Putting the actual work of the `reducer` function into helper files keeps your code organized. You could create separate files for different type of actions to keep your code modular and make it easier for multiple people to work on the program at the same time.

Now time for the `toggleItem()` function. This function is going to find the position in the `items` array of the `item` with the `id` we want to toggle. Then it's going to create a new `item` with `complete` toggled. Then it will create a new list of items that contains the toggled item instead of the untoggled one. Finally it will merge this new items list into `currentState` so that the rest of `currentState` will be left intact, and the old items list will be overwritten.

This is what that looks like in JavaScript:

<div class="fp">src/reducer.js</div>
```js
// ...

const toggleItem = (currentState, id) => {
    const items = currentState.get('items');
    const itemIndex = items.findIndex( (el) => el.get('id') == id);

    const oldItem = items.get(itemIndex);
    const newItem = oldItem.set('complete', !oldItem.get('complete'));
    const newItems = items.set(itemIndex, newItem);

    return currentState.merge({items: newItems});
};

export function reducer(currentState = new Map(), action) {
    // ...
}
```

The last thing to do for actions is to write a function that will return an action object. This is considered optional but is almost always a good idea. Instead of writing out `{ type: 'TOGGLE_ITEM', id: 3}` each time we want to use a TOGGLE_ITEM action, we can just write a function that will return the action object for any given `id` parameter.

We'll put all these "action creators" in a file called `action_creators.js`:

<div class="fp">src/action_creators.js</div>
```js
export function toggleItem(id) {
    return {
        type: 'TOGGLE_ITEM',
        id
    };
}
```

Note that we are using ES6 short-hand for object declaration. When setting a key equal to a variable that has the same name as a key, ES6 permits you to just write the name of the variable/key instead of `key: variable`. We could have written the object `toggleItem()` as:

```
{
    type: 'TOGGLE_ITEM',
    id: id
}
```

Now in our `reducer_spec.js`, we can use this action creator instead of writing out the action:

<div class="fp">test/reducer_spec.js</div>
```js
import { expect } from 'chai';
import { Map, fromJS } from 'immutable';

import { reducer } from '../src/reducer.js';
import { toggleItem } from '../src/action_creators';

describe("reducer()", () => {
    it('returns empty Map if currentState is undefined', () => {
        expect(reducer(undefined, undefined)).to.eq(Map());
    });

    describe('TOGGLE_ITEM', () => {
        // ...
        const action = toggleItem(3);

        // ...
    });
});
```

### Stores

Now that we have a `reducer()`, it's time to set up a Redux `store`. A `store` is where Redux keeps track of the application state. Redux applications have a single store that will hold a single state object that should never mutate -- only be replaced by new objects by `reducer()`. A `store` is linked to a `reducer()` when the `store` is created.

Let's install Redux and React-Redux.

```bash
npm install --save redux react-redux
```

Now we need to make some changes to `index.js`. First, we need to create a `store` object. We will do this with the `createStore` function provided by `redux`. `createStore()` takes three parameters: the `reducer` function, the initial state, and any "middleware functions".

Middleware functions do things with actions after they are dispatched, but before they reach the reducer. It is easy to write your own middleware, but we don't need to do that now. We are going to use middleware to let Redux in our application share data with the [Redux DevTools in the brower](https://github.com/zalmoxisus/redux-devtools-extension).

The other big change we'll make to `index.js` is wrapping the `App` component with a `Provider` component when we render the `App` component to the DOM. `Provider` is a top-level component given to us by the React-Redux package. Simply put, it is how we share the `store` with the components in the application. Since we're going to get `store` from `Provider`, we can remove the state prop that we pass to `<App />`.

To learn more about how Redux works (including specifics on `Provider` and the link between `reducer()` and `store`), I recommend watching Dan Abramov's (the creator of Redux) [video series on Redux](https://egghead.io/series/getting-started-with-redux) after finishing this guide.

Here is what `index.js` should look like:

<div class="fp">src/index.js</div>
```js{4,5,8,33,37-39}
import React from 'react';
import ReactDOM from 'react-dom';
import { fromJS } from 'immutable';
import {createStore} from 'redux';
import { Provider } from 'react-redux';

import { App } from './components/app';
import { reducer } from './reducer';

// Add CSS files to bundle
require('../src/css/application.scss');

const initialState = fromJS({
    items: [
        {
            id: 1,
            content: "Go to the store",
            complete: true
        },
        {
            id: 2,
            content: "Buy an apple",
            complete: false
        },
        {
            id: 3,
            content: "Buy a pear",
            complete: false
        }
    ]
});

const store = createStore(reducer, initialState, window.devToolsExtension ? window.devToolsExtension() : undefined);

// Render application to DOM
ReactDOM.render(
    <Provider store={store}>
        <App name="React To-Do" />
    </Provider>,
    document.getElementById('app')
);
```

### Connecting Components to Store

To connect a component with the state being tracked by the Redux `store`, we will write a function called `mapStateToProps`. This function will take a single parameter: the state object, and return a mapping of the names of this component's props to variables in state.

Let's do this now for the `ItemList` component. `<ItemList />` only needs one prop: a `List` of items. This corresponds to the `items` key/value pair in our state object. Therefore `mapStateToProps()` for this component looks like:

```js
const mapStateToProps = (state) => {
    return {
        items: state.get('items')
    };
};
```
Then, we are going to use this function to create a "smart" version of the `ItemList` component. This "smart" component will be like the "dumb" version we currently have, but it will automatically update when the state changes due to action being dispatched through the reducer. To create the smart component, we will use a function called `connect()` provided by React-Redux. By convention, we name the connected/"smart" component by adding "Container" to the end of the name of its "dumb" counterpart. In this case, our connected component will be called `ItemListContainer`.

 This is what the component should look like with the call to `connect()` and the `mapStateToProps` function we wrote above:

<div class="fp">src/components/item_list.js</div>
```js{2}
import React from 'react';
import { connect } from 'react-redux';

import { Item } from './item';

export class ItemList extends React.Component {
    // ... (none of this changes)
}

const mapStateToProps = (state) => {
    return {
        items: state.get('items')
    };
};

export const ItemListContainer = connect(mapStateToProps)(ItemList);
```

Now instead of rendering `<ItemList />` in `<App />`, we want to render `<ItemListContainer />` without giving it any props. Let's first change our tests for the `App` component.

Let's change the last test in `app_spec.js`, and delete the test for `ItemList`'s props (the second the last test).

<div class="fp">test/components/app_spec.js</div>
```js
// ...

describe('<App />', () => {
    describe('render()', () => {
        // ...

        it('renders ItemListContainer', () => {
            expect(wrapper.find('Connect(ItemList)')).to.have.length(1);
        });
    });
});
```

Note that instead of using the name we gave `ItemListContainer`, Enzyme will render this component as `Connect(ItemList)`.

Now this test should fail, so let's make it pass by changing `app.js`:

<div class="fp">src/components/app.js</div>
```js{3,10}
// ...

import { ItemListContainer } from './item_list';

export class App extends React.Component {
    render() {
        return (
            <div className="app">
                <h1>{ this.props.name }</h1>
                <ItemListContainer />
            </div>
        );
    }
}
```

Now we have a fully connected component being rendered. If you view the page in the browser, nothing will look any different. However, try dispatching a `TOGGLE_ITEM` action from the Redux DevTools -- remember to give the action an `id`. Dispatching the action should result in the item you toggled swapping colors!

### Connecting Components to Actions

The final step here is to set up a click handler on the `Item` component so that a `TOGGLE_ITEM` action will trigger when the user clicks on an `Item`.

We do this by setting the `onClick` prop of the `div` tag inside the `Item` component. We will set it to a function that gets passed to the component as a prop.

<div class="fp">app/components/item.js</div>
```js{8}
import React from 'react';

export class Item extends React.Component {
    render() {
        return (
            <div className={ this.props.complete ? 'item complete' : 'item incomplete' }
                 onClick={ this.props.toggleItem }>
                { this.props.content }
            </div>
        );
    }
}
```

`this.props.toggleItem` will be a function, so we are just telling the component to call that function when the `<div>` is clicked.

In the same way that we mapped state to props earlier, we are going to map actions to props. This time the function will be called `mapDispatchToProps()`.

This is how we will define the function and create the connected `Item`:

<div class="fp">app/components/item.js</div>
```js{2,4}
import React from 'react';
import { connect } from 'react-redux';

import { toggleItem } from '../action_creators.js';

export class Item extends React.Component {
    // ... (doesn't change)
}

const mapDispatchToProps = (dispatch, ownProps) => {
    return {
        toggleItem: () => dispatch(toggleItem(ownProps.id))
    };
};
export const ItemContainer = connect(undefined, mapDispatchToProps)(Item);
```

`connect()`'s first parameter here is undefined becasue we do not need to `mapStateToProps` for this function -- all of the props are provided by the parent `<ItemList />`.

The final step is to render the connected `<ItemContainer />`s rather than `<Item />`s in the `<ItemList />` component. First, let's change the test. In this case, we are still passing the same props, we just want to change the name of the component we are rendering from `Item` to `Connect(Item)`:

```js{6,7,9}
// ...

describe('<ItemList />', () => {
    const wrapper = shallow(<ItemList items={items} />);
    it('renders Items with correct props', () => {
        expect(wrapper.find('Connect(Item)')).to.have.length(2);
        const firstItemProps = wrapper.find('Connect(Item)').first().props();
        // ...
        const secondItemProps = wrapper.find('Connect(Item)').last().props();
        // ...
    });
});
```

Now we can make the change the actual component to get the tests to pass:

<div class="fp">src/components/item_list.js</div>
```js{4,11}
import React from 'react';
import { connect } from 'react-redux';

import { ItemContainer } from './item';

export class ItemList extends React.Component {
    render() {
        return (
            <div className="item-list">
                { this.props.items.map( (i) =>
                    <ItemContainer key={i.get('id')}
                          id={i.get('id')}
                          content={i.get('content')}
                          complete={i.get('complete')} />
                )}
            </div>
        );
    }
}

// ...
```

And we're done! If you click on the items in your browser, you should see them toggle between green and red!

### Further exercises

1. Add a delete button that removes the item from the list
2. Add a "create new item" form that allows the user to add a new item to the list

Now that you have an understanding of why Redux is useful and how to use it in basic settings, watch Dan Abramov's (the creator of Redux) [video series on Redux](https://egghead.io/series/getting-started-with-redux).
