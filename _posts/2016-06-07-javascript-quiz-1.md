---
layout: post
title: JavaScript Quiz 01
permalink: guides/js-quiz-01
---

## {{ page.title }}

<hr class="left">

What do the following lines print to the console?

**`console.log([1,2,3].toString())`**

a) `1, 2, 3`

b) `[1, 2, 3]`

c) `1 2 3`

d) `1\n2\n3`

e) `undefined`

f) error

**`console.log(true.toString())`**

a) `1`

b) `true`

c) `0`

d) `true.toString()`

e) `undefined`

f) error


**`console.log(2.toString())`**

a) `2`

b) `2.0`

c) `two`

d) `1.999999`

e) `undefined`

f) error


**`console.log(2..toString())`**

a) `2`

b) `2.0`

c) `two`

d) `1.999999`

e) `undefined`

f) error


---------------------------------------------------------------------

What do the following lines print after this code is run:

```js
var a = {
    name: "Eric", "phone": "555-555-5555",
    address: "2121 S Mill Ave"
}
```

**`console.log(a.name)`**

a) `name: "Eric"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `Eric`

d) `undefined`

e) error

**`console.log(a..name)`**

a) `name: "Eric"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `Eric`

d) `undefined`

e) error

**`console.log(a[name])`**

a) `name: "Eric"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `Eric`

d) `undefined`

e) error

**`console.log(a['name'])`**

a) `name: "Eric"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `Eric`

d) `undefined`

e) error

**`console.log(a.phone)`**

a) `phone: "555-555-5555"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `"555-555-5555"`

d) `undefined`

e) error

**`console.log(a['phone'])`**

a) `phone: "555-555-5555"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `"555-555-5555"`

d) `undefined`

e) error

**`console.log(a["phone"])`**

a) `phone: "555-555-5555"`

b) `{ name: "Eric", phone: "555-555-5555", address: "2121 S Mill Ave" }`

c) `"555-555-5555"`

d) `undefined`

e) error


---------------------------------------------------------------------

What do the following lines print after this code is run:

```js
var animal = { speak: function() { console.log(this.sound) } };

function Cow() { this.sound = 'moo'; }
function Duck() { this.sound = 'quack'; }
function Horse() { this.sound = 'neigh'; }
Cow.prototype = animal;
Duck.prototype = animal;
```

**`animal.speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error


**`Cow.speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error

**`c = new Cow(); c.speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error

**`new Duck().speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error

**`h = new Horse(); h.speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error

**`confused = new Cow(); confused.sound = 'neigh'; confused.speak()`**

a) `moo`

b) `quack`

c) `neigh`

d) `undefined`

f) nothing

e) error

**`console.log(c instanceof animal);`**

a) `true`

b) `false`

c) `undefined`

d) error

**`console.log(c instanceof Cow());`**

a) `true`

b) `false`

c) `undefined`

d) error

**`console.log(c instanceof Cow);`**

a) `true`

b) `false`

c) `undefined`

d) error

**`console.log(confused instanceof Cow);`**

a) `true`

b) `false`

c) `undefined`

d) error

**`for(var prop in c) { console.log(prop); }`**

a) `speak`

b) `sound`

c) `speak\nsound `

d) nothing

e) `undefined`

f) error

**`console.log(typeof c);`**

a) `number`

b) `boolean`

c) `function`

d) `undefined`

e) `object`

**`console.log(typeof Cow);`**

a) `number`

b) `boolean`

c) `function`

d) `undefined`

e) `object`

**`console.log(typeof Cow());`**

a) `number`

b) `boolean`

c) `function`

d) `undefined`

e) `object`

**`console.log(typeof new Cow());`**

a) `number`

b) `boolean`

c) `function`

d) `undefined`

e) `object`

**`console.log(typeof animal);`**

a) `number`

b) `boolean`

c) `function`

d) `undefined`

e) `object`


---------------------------------------------------------------------

What do the following code blocks print?

```js
function raiseSails() { console.log('sails raised'); }
raiseSails();
```

a) `sails raised\nsails raised`

b) `sails raised`

c) nothing

d) `undefined`

f) error

```js
raiseSails();
function raiseSails() { console.log('sails raised'); }
```

a) `sails raised\nsails raised`

b) `sails raised`

c) nothing

d) `undefined`

f) error

```js
var raiseSails = function() { console.log('sails raised'); };
raiseSails();
```

a) `sails raised\nsails raised`

b) `sails raised`

c) nothing

d) `undefined`

f) error

```js
raiseSails();
var raiseSails = function() { console.log('sails raised'); };
```

a) `sails raised\nsails raised`

b) `sails raised`

c) nothing

d) `undefined`

f) error
