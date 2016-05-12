---
layout: post
title:  "Guard, LiveReload, and Cloud9"
date:   2016-05-05 17:38:02 -0700
permalink: "guides/livereload"
categories: guides
---

## LiveReload and Guard (on Cloud9)

<hr class="left" />

We will setup LiveReload and Guard to automatically refresh your browser whenever you make a change to a file. This saves you the hassle of clicking refresh or pressing F5 each time you want to see the effect of a change you made.

We set it up to use Guard.

Add the following gems to the `:development` group in your `Gemfile`:

```ruby
gem 'guard-livereload'
gem 'rack-livereload'
```

Run this in your bash console:

```bash
bundle install
guard init livereload
```

Add this to `config/environments/development.rb`:

```ruby
Rails.application.configure do
  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload, host: 'YOUR CLOUD9 URL HERE', port: 8081
  # ...
end
```

If you're not on Cloud9, omit the `host:` and `port:` parameters. If you are on Cloud9, enter the URL you view your application at (without the https:// part).

If you're on Cloud9, replace this line in your Guardfile:

```ruby
guard 'livereload' do
```

with this line:

```ruby
guard 'livereload', port: 8081 do
```

Now run `guard` in your bash terminal. You should see a line that says: `INFO - LiveReload is waiting for a browser to connect.`.

Now run your rails server. If you're on Cloud9 visit the page, but change `https` in the address bar to `http`.

If everything worked correctly, you should see `INFO - Browser connected.` in your guard console, and your page should refresh automatically when your files change!
