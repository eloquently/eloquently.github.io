---
layout: post
title: "Classes, Strings, and Mutable State with ES6"
date: 2016-05-16
permalink: 'guides/es6-classes-strings-state'
---

## Classes, Strings, and Mutable State with ES6

<hr class="left" />

This is the second part of [this guide]{{ post_url('2016-05-15-es6-warmup ') }}. If you haven't done the previous guide, start there!

In this guide we will continue practing using the new ES6 syntax and we will work on some common interview questions dealing with strings.

This guide is also intended to get you to pay attention to how functions read and manipulate state. This will be an important topic when we start working with React and Redux.

You can clone this repository with this command:

```
git clone https://github.com/eloquently/es6-classes-strings.git
```

Then `cd` into the directory and run:

```
npm install
```

You should be all set. The `npm run test:watch` and `npm run webpack:watch` should run without any additional configuration.

### A `StringPlus` Class

We are going to build a wrapper of the `String` class with additional functionality. To define a class in ES6, we use the following syntax. Create a file called `string_plus.js` in the `src` directory and start writing the following code:

<div class="fp">src/string_plus.js</div>
```js
class StringPlus {

}
```

This creates an empty class called StringPlus. We can use it to create new objects by calling `new StringPlus()` in our code.

We'll want to access this class from other programs (such as our test), so we need to export the class:

<div class="fp">src/string_plus.js</div>
```js{1}
export class StringPlus {

}
```

Next we'll set up a constructor, but let's first write a test for it's behavior. We want the constructor to take a string as a parameter. `StringPlus` objects will have a property called `str` that stores a string. The constructor will save the parameter it is passed into `str`.

Objects of a class are just like any other JavaScript objects, so we can access its properties in the same way we access the properties of other objects. For example, if we have an instance of the `StringPlus` class called `sp`, we can access its `str` property with the command `sp.str`.

Our constructor test will test that we successfully save the parameter in the `str` property. We'll also write a test to show what happens when no parameter is given.

<div class="fp">test/string_plus_spec.js</div>
```js
import { expect } from 'chai';

import { StringPlus } from '../src/string_plus';

describe("StringPlus", () => {
    describe("constructor()", () => {
        it('sets str', () => {
            const sp = new StringPlus('parameter');
            expect(sp.str).to.eq('parameter');
        });

        it('works with no parameter', () => {
            const sp = new StringPlus();
            expect(sp.str).to.eq(undefined);
        });
    });
});
```

Now let's write the construtor method. In ES6, this is just a function inside the class called `constructor`:

<div class="fp">src/string_plus.js</div>
```js{2-4}
export class StringPlus {
    constructor(initialString) {
        this.str = initialString;
    }
}
```

The `this` object inside of the class is just the underlying JavaScript object.

### Replacing Characters

The first function we want to write will replace the character at a particular index with another character. This function, `replaceNthChar()`, will take two parameters: `n`, the position of the character in the string we want to replace (0 is the first character), and `newChar` the character we want to replace the n-th character with.

Here are some tests that show some examples of how to use this method:

<div class="fp">test/string_plus_spec.js</div>
```js
// ...

describe("StringPlus", () => {
    describe("constructor()", () => {
        // ...
    });

    describe("replaceNthChar()", () => {
        const sp = new StringPlus('test string');

        it('replaces n-th char', () => {
            sp.replaceNthChar(0, 'T');
            expect(sp.str).to.eq('Test string');
            sp.replaceNthChar(4, '!');
            expect(sp.str).to.eq('Test!string');
        });

        it('does not return anything', () => {
            expect(sp.replaceNthChar(0, 'A')).to.eq(undefined);
        });
    });
});
```

Let's describe an algorithm that solves this in English:

- Create a temporary string that will hold our answer (called `tempStr`)
- Start with the first character in `this.str` and perform the following actions:
    - If this character is not at the `n-th` position:
        - Add this character to `tempStr`
    - Otherwise
        - Add `newChar` to `tempStr`
    - Move to the next character; stop if there are no more characters
- Set `this.str` equal to `tempStr`.

This method is mutating the state of our object, so it shouldn't return any value.

Now let's write the method:

<div class="fp">src/string_plus.js</div>
```js
export class StringPlus {
    // ...

    replaceNthChar(n, newChar) {
        let tempStr = "";
        for(let i = 0; i < this.str.length; i++) {
            if(i != n) {
                tempStr = tempStr + this.str[i];
            } else {
                /* Fill in this line */
            }
        }
        this.str = tempStr;
    }
}
```

### Reversing Strings

The next function we want to write for our `StringPlus` class is `reverse`. This function will reverse all the characters in `str`. Here are some examples written as tests:

<div class="fp">test/string_plus_spec.js</div>
```js
// ...

describe("StringPlus", () => {
    // ...

    describe("reverse()", () => {
        it('reverses str', () => {
            const sp = new StringPlus('parameter');
            sp.reverse();
            expect(sp.str).to.eq('retemarap');
            sp.str = 'race car';
            sp.reverse();
            expect(sp.str).to.eq('rac ecar');
            sp.reverse();
            expect(sp.str).to.eq('race car');
        });

        it('does not return anything', () => {
            const sp = new StringPlus('parameter');
            expect(sp.reverse()).to.eq(undefined);
        });
    });
});
```

We're going to write a basic algorithm that solves this problem. Here's how it will work in English

- Create an empty string called `tempStr`
- Start at the end of `str`
- Repeat the following until reaching the beginning of `str`:
    - Add the last character of `str` to the end of `tempStr`
    - Move back one character in `str`

We can implement this in the code using a `for` loop. Try writing the method yourself before scrolling down to see our solution. **Note**: there are multiple ways to solve this problem -- this is just one. If your function looks different but passes the test, it's probably right!

<div class="fp">src/string_plus.js</div>
```js
export class StringPlus {
    // ...

    reverse() {
        /* Your code goes here */
    }
}
```

Here's our solution:

<div class="fp">src/string_plus.js</div>
```js
export class StringPlus {
    reverse() {
        let tempStr = "";
        for(let i = this.str.length - 1; i >= 0; i--) {
            tempStr = tempStr + this.str[i];
        }
        this.str = tempStr;
    }
}
```

ES6 includes a string interpolation feature. Instead of writing `tempStr = tempStr = this.str[i];`, we could write: ``tempStr = `${tempStr}${this.str[i]}`;``. Note that we are using backticks `` ` `` rather than quote marks. ``str = `var: ${var}`;`` is equivalent to `str = "var: #{var}"` in Ruby.

**Extra interview practice**: It's possible to write `reverse()` so that it doesn't need to use `temp_str`. Try refactoring your method in such a way now. Hint: you'll need the `replaceNthChar` function!

### Palindromes

A palindrome is a word that is spelled the same backwards and forwards. Let's write a method to determine if a string is a palindrome. Here are some test examples:

<div class="fp">test/string_plus_spec.js</div>
```js
// ...

describe("StringPlus", () => {
    // ...

    describe("isPalindrome()", () => {
        it('returns true for a palindrome', () => {
            const sp = new StringPlus('racecar');
            expect(sp.isPalindrome()).to.eq(true);
            sp.str = 'a';
            expect(sp.isPalindrome()).to.eq(true);
            sp.str = 'aa';
            expect(sp.isPalindrome()).to.eq(true);
            sp.str = 'aba';
            expect(sp.isPalindrome()).to.eq(true);
        });

        it('returns false if not a palindrome', () => {
            const sp = new StringPlus('race car');
            expect(sp.isPalindrome()).to.eq(false);
            sp.str = 'aA';
            expect(sp.isPalindrome()).to.eq(false);
            sp.str = 'ab';
            expect(sp.isPalindrome()).to.eq(false);
            sp.str = 'abb';
            expect(sp.isPalindrome()).to.eq(false);
        });
    });
});
```

This function is simply reading a property of the object, so it should not change state. Let's add a test for that:

<div class="fp">test/string_plus_spec.js</div>
```js
describe("StringPlus", () => {
    // ...

    describe("isPalindrome()", () => {
        it('returns true for a palindrome', () => {
            // ...
        });

        it('returns false if not a palindrome', () => {
            // ...
        });

        it('does not change state', () => {
            const sp = new StringPlus('racecar');
            sp.isPalindrome();
            expect(sp.str).to.eq('racecar');
            sp.str = 'race car';
            sp.isPalindrome();
            expect(sp.str).to.eq('racecar');
        });
    });
});
```

Now try to implement this method using the `reverse` function we wrote earlier. It will be a little trickier than it seems at first glance because `reverse()` changes the object's state. There are multiple ways to handle this.

<div class="fp">src/string_plus.js</div>
```js
export class StringPlus {
    // ...

    isPalindrome() {
        /* Your code here */
    }
}
```

Hint: What happens if you call reverse twice?

### Immutability and Pure Functions

Your `isPalindrome()` method is likely quite awkward. This could be avoided if `reverse()` did not mutate state and instead returned a new value. In fact, this is what the default `reverse` function in Javascript does. Instead of changing the value of the string, calling `reverse()` on a string just returns a new value and does not mutate the original string. If you want to save the value, you have to create a new variable.

```js
const a = "string";
a.reverse() // => "gnirts"
a // => "string"
const b = a.reverse()
b // => "gnirts"

// or
let c = "string";
c = c.reverse();
c // => "gnirts"
```

Note that in the `c` example, we defined `c` with `let` rather than `const`. It would not work with `const` because we are replacing the object `c` is pointing to with a new `object`.

In fact, in JavaScript, strings are "immutable". There is no way to change a string without making a copy of it -- all string functions will work like `reverse()`.

One more piece of terminology. We could write a `reverseString` function that looked like this:

```js
const reverseString = (str) => {
    let tempStr = "";
    for(let i = str.length - 1; i >= 0; i--) {
        tempStr = tempStr + str[i];
    }
    return tempStr;
}

console.log(reverseString('string')); // => 'gnirts'
```

We would call this function a "pure function". Pure functions meet two criteria:

1. Pure functions do not have any side effects. They do not mutate any variables that already exist.
2. A pure function always returns the same result when it is called with the sae parameter(s). The results do not depend on any part of the application state.
