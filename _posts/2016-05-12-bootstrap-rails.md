---
layout: post
title:  "Bootstrap and Rails"
date:   2016-05-05 17:38:02 -0700
permalink: "guides/bootstrap_rails"
categories: guides
---

## Bootstrap and Rails

<hr class="left" />

Add this to your `Gemfile`:

<div class="file-path">Gemfile</div>
```ruby
gem 'bootstrap-sass'
```

Rename `app/assets/stylesheets/application.css` to `app/assets/stylesheets/application.scss`.

Remove these lines from the file:

<div class="file-path">app/assets/stylesheets/application.scss</div>
```
 *= require_tree .
 *= require_self
```

Now add these lines:

<div class="file-path">app/assets/stylesheets/application.scss</div>
```scss
@import "bootstrap-sprockets";
@import "bootstrap";
```

You should try to keep the styles for each view in a file named after that model or controller. For example, in our blog application, we will put all styles related to the post views in a file called `posts.scss`. We need to import this file into the `application.scss` file with a line like this:

<div class="file-path">app/assets/stylesheets/application.scss</div>
```scss
@import "posts";
```

To make elements like drop-down menus work, we'll also need to add bootstrap's JavaScript files. In `app/assets/javascripts/application.js`, add this line to the bottom:

<div class="file-path">app/assets/javascripts/application.js</div>
```js
//= require bootstrap-sprockets
```

Make sure that you are requiring `jquery` as well. You should also have this line in your `application.js`. If it's not there, add it above the `require bootstrap-sprockets` line.
