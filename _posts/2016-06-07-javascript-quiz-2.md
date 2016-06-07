---
layout: post
title: JavaScript Quiz 02
permalink: guides/js-quiz-02
date: 2016-06-08
---

## {{ page.title }}

<hr class="left" />

What do the following code blocks print?

#### 1)

```js
var foo = 42;
function setVar() {
    foo = 21;
}
setVar();
console.log(foo);
```

| a | b | c | d | e |
|---|---|---|---|---|
|`foo`|`42`|`21`|`undefined`|error|

#### 2)

```js
var foo = 42;
function setVar() {
    var foo = 21;
}
setVar();
console.log(foo);
```

| a | b | c | d | e |
|---|---|---|---|---|
|`foo`|`42`|`21`|`undefined`|error|

#### 3)

```js
var foo = 42;
function setVar() {
    var foo = 21;
    console.log(foo);
}
setVar();
```

| a | b | c | d | e |
|---|---|---|---|---|
|`foo`|`42`|`21`|`undefined`|error|

#### 4)

```js
var foo = 42;
function setVar() {
    console.log(foo);
    var foo = 21;
}
setVar();
```

| a | b | c | d | e |
|---|---|---|---|---|
|`foo`|`42`|`21`|`undefined`|error|

#### 5)

```js
foo = 42;
function setVar() {
    console.log(foo);
    var foo = 21;
}
setVar();
```

| a | b | c | d | e |
|---|---|---|---|---|
|`foo`|`42`|`21`|`undefined`|error|


#### 6)

```js
var arr = [1, 2, 3];
console.log(arr);
```

| a | b | c | d | e | f |
|---|---|---|---|---|---|
|`[1, 2, 3]`|`[1]`|`1`|`[1,2]`|`undefined`|error|

#### 7)

```js
var arr = [1, 2, 3];
arr.length = 1;
console.log(arr);
```

| a | b | c | d | e | f |
|---|---|---|---|---|---|
|`[1, 2, 3]`|`[1]`|`1`|`[1,2]`|`undefined`|error|

#### 8)

```js
var arr = [1, 2, 3];
arr.length = 1;
console.log(arr[1]);
```

| a | b | c | d | e | f |
|---|---|---|---|---|---|
|`[1, 2, 3]`|`[1]`|`1`|`[1,2]`|`undefined`|error|

#### 9)

**`console.log("" == false)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|


#### 10)

**`console.log("" == 0)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 11)

**`console.log(0 == "0")`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 12)

**`console.log("" == "0")`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 13)

**`console.log("" === false)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|


#### 14)

**`console.log("" === 0)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 15)

**`console.log(0 === "0")`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 16)

**`console.log("" === "0")`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 17)

**`console.log(10 == '+10')`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 18)

**`console.log(10 == '010')`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 19)

**`console.log(10 == +10)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 20)

**`console.log(10 == 010)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 21)

**`console.log(undefined == null)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 22)

**`console.log(undefined === null)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 23)

**`console.log(!!0)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 24)

**`console.log(!!false)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 25)

**`console.log(!!'')`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 26)

**`console.log(!!undefined)`**

| a | b | c | d |
|---|---|---|---|
|`true`|`false`|`undefined`|error|

#### 27)

```js
var options = ['test1', 'test2', 'test3'];
console.log(options[0]);
(options || []).forEach((el) => console.log(el));
```
| a | b | c | d |
|---|---|---|---|
|`test1\ntest2\ntest3`|`test1\ntest1\ntest2\ntest3`|`undefined`|error|

#### 28)

```js
var options = ['t1', 't2', 't3']
console.log(options[0])
(options || []).forEach((el) => console.log(el))
```
| a | b | c | d |
|---|---|---|---|
|`t1\nt2\nt3`|`t1\nt1\nt2\nt3`|`undefined`|error|

#### 29)

**Should you ever use `eval()`?**

| a | b |
|---|---|
|Yes|No|
