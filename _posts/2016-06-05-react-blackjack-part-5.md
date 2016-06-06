---
layout: post
title: React Blackjack Part 5
date: 2016-06-05
permalink: guides/react-blackjack-part-5
---

## {{ page.title }}

<hr class="left">

In this final part of the React Blackjack guide, we will use an API to load and save the win/loss records of users.

The React application does not need to know anything about how the API is implemented. There are a number of different backend options that a React application could use. For this guide, we have put together a simple Rails 5 application. You can view the source code of the application [here](https://github.com/eloquently/react-blackjack-api).

### The API

The API is a Rails 5 application created with the "api only" option. We generated a scaffold for a User model with attributes for `win_count`, `loss_count` and a `token`. We want to be able to refer to users by their unique tokens, so we changed the routing configuration to use tokens rather than ids. We also set up the controller so that if an operation is attempted on a user with a token that is not found, we will create a new user rather than returning an error.

We also had to allow the API to accept requests from other domains. This is called Cross-Origin Resource Sharing (CORS). We used the [Rack-Cors gem](https://github.com/cyu/rack-cors) to set this up easily.

While following along with this part of the guide, you can clone the API application to your local environment and run the rails server in a separate terminal. To follow this approach, clone the repository:

```
git clone https://github.com/eloquently/react-blackjack-api
```

Then `cd` to the directory, install the bundle, create/migrate the database, and start the server with:

```
rails s -b $IP -p 8081
```

If you are not on Cloud9, you can omit the `-b $IP` part. Now your Rails application is running on port 8081. We can reference it from the React application at the URL: `localhost:8081`.

Alternatively, you can deploy the API to Heroku in two clicks using the "Deploy to Heroku" button on the [GitHub repository](https://github.com/eloquently/react-blackjack-api). Following this approach will mean you have to use a URL that looks like: `something.herokuapp.com` to access the API from your React application.

### Loading User Data

In order to keep track of users, we want to generate a unique token for each user. User tokens will be random strings of numbers and letters.

We want users to be able to resume where they left off by entering their token into the URL when they visit the page. For example, if a user's token is asdf1234, the user just needs to visit reactblackjackurl.com/?token=asdf1234 to load his or her progress. Users that plan to play a lot of blackjack can bookmark the unique URLs corresponding to their respective games.

Therefore, when the application loads, we need to check if the URL has a token. We are going to use a package called `query-string` to parse the URL. If the user does not have a token, we will want to generate one for the user. To do this, we will use a package called `randomstring`. Let's install both of those packages:

```
npm install --save query-string@4.2.0 randomstring@1.1.5
```

Let's import them in `index.js` and use them to generate a token for the user and store that token in the initial state we use to create the Redux store:

<div class="fp">app/index.js</div>
```js{3-4,8-10}
// ...

import queryString from 'query-string';
import randomstring from 'randomstring';

// ...

const userToken =
    queryString.parse(window.location.search).token ||
    randomstring.generate(12);

const initialState = {
    settings: new Map({speed: 750<mark>, userToken</mark>})
};
// ...
```

If you add `?token=123` to the end of the URL you use when working on your website, you should see a `userToken` key in the settings portion of the state tree in the Redux DevTools. Try loading the page without giving it a token and verify that `userToken` is set to a random string in the state tree.


#### `FETCH_RECORD`

We are going to create a new action that we will dispatch whenever we want to load the user's record from the server. We'll call this action `FETCH_RECORD`. First, let's add it to the action creators:

<div class="fp">app/action_creators.js</div>
```js
export function fetchRecord() {
    return { "type": "FETCH_RECORD" };
}
```

Instead of setting up a reducer to handle this action, we will have our sagas watch for it. For now we'll just log to the console and yield a `SET_RECORD` action to initialize the record at 0 wins and 0 losses.

<div class="fp">app/sagas/index.js</div>
```js{3-6,10}
// ...

export function* onFetchRecord() {
    console.log('fetching record');
    yield put(setRecord(0, 0));
}

export default function*() {
    yield [ takeLatest('STAND', onStand)<mark>,</mark>
            takeLatest('FETCH_RECORD', onFetchRecord)
    ];
}
```

Instead of dispatching `SET_RECORD` after setting up the store in `app/index.js`, we can now dispatch `FETCH_RECORD`:

<div class="fp">app/index.js</div>
```js
// ...

import reducer from './reducers/index';
import { setupGame,
         <mark>fetchRecord</mark> } from '../app/action_creators';

// ...

store.dispatch(<mark>fetchRecord()</mark>);
store.dispatch(setupGame());
// ...
```

If you refresh the page in the browser, you should see the "fetching record" message in the console and see that the user has 0 wins and 0 losses.

To set the record to whatever is in the database, we'll need to make an API call. To keep our code organized, we'll create an API lib file that will define the functions we need to interact with the API.

We're going to use a package called Isomorphic Fetch to handle the AJAX calls. "Fetch" is a built-in JavaScript function in modern browsers that provides a syntax similar to jQuery's `$.ajax(...)` for making asynchronous calls to external APIs. The Isomorphic Fetch package mimics the browser's `fetch()` so that `fetch()` calls can be made from JavaScript environments outside of the browser (like a NodeJS server or a Mocha test). Babel will also be able to transform the code in Isomorphic Fetch so that it is compatible with older browsers.

Let's install Isomorphic Fetch:

```
npm install --save isomorphic-fetch
```

We'll also use the built-in `url` package to create a URL for us given a host, port, and path.

<div class="fp">app/lib/api.js</div>
```js
import fetch from 'isomorphic-fetch';
import url from 'url';

function makeUrl(token) {
    const pathname = `users/${token}`;
    return url.format({
        hostname: "<mark>YOUR URL HERE</mark>",
        port: 8081,
        pathname
    });
}

export function fetchUser(token) {
    return fetch(makeUrl(token), {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    }).then(response => response.json());
}
```

Fetch returns a Promise (see previous guide). After the promise is resolved, we convert the response to a JSON object. Make sure to use the URL/port for the URL hostname. If you are running the Rails server from a Cloud9 instance (according to the instructions above), the hostname will be something like: `workspacename-c9username.c9users.io`.

We are almost ready to drop this function straight into the `onFetchRecord` saga. The only thing we need to add is a selector that will return the user's token given the application state.

Here's how to add the selector and modify the saga to make the API call:

<div class="fp">app/sagas/index.js</div>
```js{2,5-6,11-12}
// ...
import { fetchUser } from '../lib/api';

// ...
const getUserToken =
    (state) => state.settings.get('userToken');

//...

export function* onFetchRecord() {
    const userToken = yield select(getUserToken);
    const user = yield call(fetchUser, userToken);
    yield put(setRecord(<mark>user.win_count</mark>, <mark>user.loss_count</mark>));
}

// ...
```

Make sure your Rails server is running, and refresh the browser. In the JavaScript console, you should see that "Fetch complete" message and that the record is initialized to 0-0.

### Changing Components Based on API Call Status

If the user manages to play a game or two before the record finishes loading from the server, the win-loss record would be overwritten by the one from the server. It would be nice to hide the game from the player while the record is loading to prevent angry user complaints.

We can do this by dispatching additional actions from the `onFetchRecord` saga. Before we make the fetch call, we'll dispatch a `FETCHING_RECORD` action. After the fetch completes, we'll dispatch a `FETCHED_RECORD` action. These actions will toggle a state variable that the `App` component will use to decide if it should display the game or a loading message.

To keep our state tree organized, we'll create a new top level key in the state object and make a simple reducer to handle the `FETCHING_RECORD` and `FETCHED_RECORD` actions. This reducer will be pretty simple, so we are not going to write tests for it. If you want more practice writing tests, feel free to!

First, let's add the action creators for these two new actions:

<div class="fp">app/action_creators.js</div>
```js
// ...

export function fetchingRecord() {
    return { "type": "FETCHING_RECORD" };
}

export function fetchedRecord() {
    return { "type": "FETCHED_RECORD" };
}
```

Now let's import these actions and dispatch them from the saga:

<div class="fp">app/sagas/index.js</div>
```js{9,11}
// ...
import { dealToDealer, determineWinner,
         setRecord<mark>, fetchingRecord</mark>,
         <mark>fetchedRecord</mark> } from '../action_creators';
// ...

export function* onFetchRecord() {
    const userToken = yield select(getUserToken);
    yield put(fetchingRecord());
    const user = yield call(fetchUser, userToken);
    yield put(fetchedRecord());
    yield put(setRecord(user.win_count, user.loss_count));
}

// ...
```

Next, we'll create a reducer to handle these:

<div class="fp">app/reducers/api.js</div>
```js
import { Map } from 'immutable';

export default function(currentState = new Map(), action) {
    switch(action.type) {
        case 'FETCHING_RECORD':
            return currentState.set('fetchingRecord', true);
        case 'FETCHED_RECORD':
            return currentState.set('fetchingRecord', false);
    }

    return currentState;
}
```

We also need to add the new reducer to the root reducer:

<div class="fp">app/reducers/index.js</div>
```js
// ...
import api from './api';

export default combineReducers({
    game, settings<mark>, api</mark>, routing, form
});
```

Now let's change the `App` component to hide the components related to the game whenever the record is being fetched from the server:

<div class="fp">app/components/app.js</div>
```jsx{7-21,29,38}
// ...

export class App extends React.Component {
    render() {
        // ...

        let gameComponents;
        if(this.props.fetchingRecord) {
            gameComponents = <h1>Loading record...</h1>;
        } else {
            gameComponents = (
                <div class="game">
                    <InfoContainer />
                    { messageComponent }
                    <strong>Player hand:</strong>
                    <Hand cards={this.props.playerHand } />
                    <strong>Dealer hand:</strong>
                    <Hand cards={this.props.dealerHand } />
                </div>
            );
        }

        return (
            <div className="app">
                <div className="links">
                    <Link to="/settings">Settings</Link>
                </div>
                <h1>React Blackjack</h1>
                {gameComponents}
            </div>
        );
    }
}

function mapStateToProps(state) {
    return {
        // ...
        fetchingRecord: state.api.get('fetchingRecord')
    };
}

// ...
```

Now if you refresh the page in the browser, you should see the loading message until the `fetch` is complete!

### Updating the Record on the Server

The flow for saving the record between each game is very similar. In this case, we are going to watch the `SETUP_GAME` action and dispatch a similar set of actions. First, we'll write the action creators:

<div class="fp">app/action_creators.js</div>
```js
// ...

export function patchRecord() {
    return { "type": "PATCH_RECORD" };
}

export function patchingRecord() {
    return { "type": "PATCHING_RECORD" };
}

export function patchedRecord() {
    return { "type": "PATCHED_RECORD" };
}
```

Next, we'll write a function in our API utility file that sends a `PATCH` request to the Rails server. This request will be very similar to the `GET` request we send for fetching the record. The only difference here is that we need to send some data (the new win and loss counters) to the server, so we'll send a body with our request:

<div class="fp">app/lib/api.js</div>
```js
// ...

export function patchUser(token, body) {
    return fetch(makeUrl(token), {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json'
        },
        body
    }).then(response => response.json());
}
```

Now let's write the Saga:

<div class="fp">app/sagas/index.js</div>
```js{10-15,21}
// ...
import { dealToDealer, determineWinner,
         setRecord, fetchingRecord,
         fetchedRecord<mark>, patchingRecord</mark>,
         <mark>patchedRecord</mark> } from '../action_creators';
import { fetchUser<mark>, patchUser</mark> } from '../lib/api';

// ...

export function* onPatchRecord() {
    const userToken = yield select(getUserToken);
    yield put(patchingRecord());
    yield call(fetchUser, userToken);
    yield put(patchedRecord());
}

export default function*() {
    yield [
        takeLatest('STAND', onStand),
        takeLatest('FETCH_RECORD', onFetchRecord),
        takeLatest('SETUP_GAME', onPatchRecord)
    ];
}
```

Now refresh the page in your browser. Try loading the page with an easy to remember token (add `?token=hello` to the end of the URL you visit to see your application). Play a few games. Then close the page, and open it again with the same token. You should see that your record is the same as when you left!

The record is only saved when the `SETUP_GAME` action is fired. This means that it is possible that the sever may not remember the user's last game if the tab was closed before the `SETUP_GAME` action fired. While this is not ideal, it's okay for the purposes of this guide. It is a little bit trickier to patch the record immediately after the game ends because this application has multiple actions that can trigger the end of the game!

The final step is to add a message while the game is saving. We can do this by adding handling the `PATCHING_RECORD` and `PATCHED_RECORD` actions in the API reducer and modifying the `App` component.

First the reducer methods:

<div class="fp">app/reducers/api.js</div>
```js
// ...

export default function(currentState = new Map(), action) {
    switch(action.type) {
        // ...
        case 'PATCHING_RECORD':
            return currentState.set('patchingRecord', true);
        case 'PATCHED_RECORD':
            return currentState.set('patchingRecord', false);
    }

    return currentState;
}
```

Then the modifications to the `App` component:

<div class="fp">app/components/app.js</div>
```jsx
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
                {gameComponent}
                {this.props.patchingRecord ?
                    "Saving..."
                    : "" }
            </div>
        );
    }
}

function mapStateToProps(state) {
    return {
        // ...
        patchingRecord: state.api.get('patchingRecord')
    };
}

// ...
```

Notice that we did not set the initial value for `patchingRecord` in `index.js`. If `patchingRecord` is undefined, then the conditional in the `App` component will be false, and the `Saving...` message will not be rendered, which is exactly what we want. We technically did not need to set the initial value for `fetchingRecord` earlier, but we did so anyway to make the data flow more clear (and it can prevent other problems if a later feature cannot handle an undefined value).

Now, whenever a new game is set up

### End

This is the end of the guide. Feel free to continue practicing React and Redux and TDD by continuing to add features on top of what we built together!

This guide is still a huge work in progress. If you found any errors or have suggestions for better ways to do things, please contact us or put up an issue on our repository!

Thanks for following along!
