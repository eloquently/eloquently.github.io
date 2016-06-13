---
layout: post
title: Interview Prep 10 - API Project
date: 2016-06-12
permalink: guides/interview-prep-10
---

## {{ page.title }}

<hr class="left" />

This guide is different from the other interview prep exercises. While the previous guides were intended to prepare you for data structure/algorithm questions that come up during an interview, this guide will prepare you for a common type of "homework" problem companies like to give candidates during the interview process.

Some companies will ask candidates to build a simple application before or after the first round if interviews. Typically, these projects are expected to take 4-6 hours, so while working on this guide, try not to spend too much more time than that.

This interview tactic is somewhat controversial because it requires a significant amount of the candidate's time. However, companies like to see how much a candidate knows and how well she or he can code, and one of the best ways to do that is to ask all the candidates to spend a few hours actually building a small project.

Here are some typical things that companies are looking for when they ask the candidate to do a homework assignment. These can vary widely in relative importance from company to company!

- Does the code submitted by the candidate actually run and meet the requirements?
- Was the candidate able to write the code in a reasonable time frame?
- How well organized is the code?
- Are there comments explaining how the code works?
- Are there any tests?
- Is the product well-designed? (Depending on the position/company, this can be very important or not important at all.)
- Are there any creative features in the finished product that add or improve functionality over the original specifications?

This guide will help you prepare for this part of the interview process while also giving you more practice with React and APIs!

### Requirements

For this project, you should build a simple front-end application that uses the Foursquare API, the OpenWeatherMap API, and the Google Maps API to build an app that has the following workflow:

- Users have two text fields to enter data into. One field is for a search query ("restaurant", "park', "taco") and the other field is for a location (85282, "Tempe, AZ").
- After hitting submit, a list of the top 5 possible locations will appear. The locations should be within 100,000km of the location they entered.
- The user selects one of the locations and the following happen:
    - The item in the list is highlighted (color and/or background-color change)
    - The current weather for the city where the place is located is displayed (from OpenWeatherMap)
    - A Google Map for the location is displayed

Your project will be evaluated on its functionality first and on its appearance second. It should look decent, but having a fully functional application with no bugs is more important.

You should fetch data from the APIs directly my making http requests against the API endpoints. Don't use NPM packages that do all the work for you :)

It should take you about 6-8 hours in total to finish this project. Do not spend more than 8 hours on this!

If you want to try to solve this problem on your own as practice for the interview, feel free to! Use any language/framework/tools you want. If you want some guidance, feel free to follow the guide below. The steps below are at a very high-level and the solution they describe is certainly not the only way to make an application like this.

### Getting Started With API Calls

One way to start these projects is to worry about setting up the API calls before even starting to think about the front-end.

You are going to build this application in React and Redux, so a good place to start is to clone the [react boilerplate repo](https://github.com/eloquently/react-boilerplate).

Since one of the goals of this project is to write well-organized code, you should start by creating a `util` directory to store the code responsible for making the API calls. In this directory, you can make a single `api.js` file that has functions to make all the necessary API calls.

#### First API Call

Your first goal is to make the Foursquare API call (find five possible matches given user's search). You should write a function, `listPlaces()` (or something else if you want!), that takes two string parameters (the data the user entered into the location field and the search query field) and will return an array with the names and necessary data for the top 5 matches.

You will need a Foursquare API key. Since this is a purely front-end project, you will have to expose your API keys to the client by including it in your JavaScript. It is still a good idea to omit it from your Git repository by placing it in a secrets.json file that gets ignored by version control. You should be able to talk about possible things that can go wrong if your API key is shared with users and what you can do to limit the downsides.

Use the `venues/search` end point on the Foursquare API with the `near` and `radius` arguments.

You can use the `isomorphic-fetch` library to make the API call inside this function (see [react blackjack part 5](/guides/react-blackjack-part-5) for an example).

For now, you can test your function by importing it and logging its results to the console inside `src/index.js` with some code like this:

```js
import { listPlaces } from './apis/foursquare.js';

console.log(listPlaces('Park', 85282));
```

Then if you run `webpack-dev-server` and open the page the browser, you should see the result of the API call on the page. If your code is working correctly, you should see data for 5 parks listed in an array.

#### Second API Call

Now you can write a function that takes the city and country output from the first API call (or the latitude and longitude) and makes the call against the OpenWeatherMap API. You'll need an API key from OpenWeatherMap. Continue testing these functions in `index.js`.

Note: OpenWeatherMap's API requires users to pay for https access. If you don't want to pay you can use the `http://...` address. Your browser will refuse to run the request if you visit your Cloud9 application using http, so make sure to change `https://___.c9users.io/` to `http://___.c9users.io/`.

#### Third API Call

Using the data from the first API call, we'll also need to get a Google Map to display on the page. There are a couple of ways to do this, but the easiest might be the [Static Map API](https://developers.google.com/maps/documentation/static-maps/intro).

If you use the Static Map API, you don't even need to make an API call -- you just form the URL with the parameters described in the documentation and use the URL as the `src` attribute on an `<img />` tag in your HTML. For now, you can write a function that takes data from the one element of the result of the first API call and returns the `src` for an `<img />` tag.

### Designing the Components

Now that you have set up all the API calls and seen what they data they return looks like, you can start thinking about how to layout the application that will display the data.

There are two things left to do. You need to code up the components for the application, and you need to connect them to the application state to make things happen when the user clicks on a component to make an API call.

In this guide, we'll set up all the components first and then make the application actually do things when buttons are pressed. However, developing the components as you develop the functionality is a perfectly valid approach too!

At this point, you should install Redux and set up the store in your `index.js` file. For now, you can set up the initial state to look like the user has already entered a query, hit submit, selected a location, and is now viewing the weather and the map for that location. Your state tree should look something like this:

<div class="fp">initial state</div>
```js
{
    query: 'park',
    places: [ ... ], // data from first API call
    selectedPlace: 2, // the park the user has clicked on
    weather: { ... }, // data from the third API call
}
```

Create the store using Redux, and pass it to a `Provider` component wrapping your `App` component. See [react blackjack part 2](/guides/react-blackjack-part-2) for more info.

Now you're ready to design the components! Since you have a Redux store, you can already create the container components with `connect()` and `mapStateToProps()`.

I'm not going to give you much guidance here, so it is up to you to figure out what components you need and how they should look on the page. Remember, you're under a fairly strict time limit, so don't spend a ton of time on the design!

You should be able to make a component that displays the Google map for the selected place if you are using the Static Map component with the data in your store. We'll look at how to make the other API calls in the next section.

### Functionality

Now it's time to add functionality to the application. Again, this could be done in any order. This guide will implement everything in the same order that a user visiting the page would perform different actions.

When writing reducer functions to handle these actions, make sure they are pure functions! That is, they should not mutate the state objects passed to them as parameters and they should always return the same result when given the same parameters.

#### `NEW_QUERY` and `FETCHED_PLACES`

The first action for you to implement, is when the user clicks the submit button. This should dispatch a `NEW_QUERY` action. Your reducer should change the query in the state tree to the value of the text field. For a good example of how to set this up, see [Dan Abramov's video](https://egghead.io/lessons/javascript-redux-react-todo-list-example-adding-a-todo). Watch the whole thing. The part where he gets the value from a text field into an action is a little bit past the 3 minute mark.

You can use Redux Saga to watch for `NEW_QUERY` actions and make the first API call when it sees one. The saga should dispatch a `FETCHED_PLACES` action with the data once the API call is complete.

#### `SELECT_PLACE` and `FETCHED_WEATHER`

The next action for you to implement is `SELECT_PLACE`. This action will be dispatched when the user clicks on one of the places on the screen.

You should have another saga watching for `SELECT_PLACE` actions. When one is observed, the saga should make the second call and dispatch a `FETCHED_WEATHER` action with the appropriate data when done.

If you set up your components correctly, this should be all you need to do! Clear out the initial state, and fix any bugs that you might encounter.

### Additional Features

If you still have time after your application is working, here are some additional ideas of features you can add:

An indication to the user that data is loading with some sort of graphic or text on the screen. We show how this is done in [react blackjack part 5](/guides/react-blackjack-part-5). It's not part of the original specification, but this is one of those extra features that shows some creativity and an understanding of important elements of front-end design.

Another feature would be input validation. If the user hits submit before typing anything into the input fields, it would be nice to show an error message rather than just running empty queries. You may wish to use redux-form for this functionality.
