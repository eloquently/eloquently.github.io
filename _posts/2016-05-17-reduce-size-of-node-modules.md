---
layout: post
title: Reduce Size of node_modules
date: 2016-05-17
permalink: 'guides/reduce-size-node-modules'
---

## Reduce Size of `node_modules/`
<hr class="left" />

Version 2.x of NPM (the default that comes with a blank Cloud9 instance) creates huge `node_modules` directories. Luckily, it's easy to update NPM and reduce the size of the `node_modules` directory.

To check the size of your directories, `cd` to the directory your project is in, and run:

```
du -sh *
```

You should see a list that looks like this:

```
4.0K    README.md
1.5M    build
448M    node_modules
4.0K    package.json
32K     src
20K     test
4.0K    webpack.config.js
```

First, update NPM:

```
npm install -g npm@latest
```

Next, remove the `node_modules` directory of your project:

```
rm -rf node_modules
```

Then, rebuild `node_modules/`:

```
npm install
```

You should see that the directory is much smaller and that you have more available disk space!

After compmleting these steps, `du -sh *` gives me:

```
4.0K    README.md
1.5M    build
99M     node_modules
4.0K    package.json
32K     src
20K     test
4.0K    webpack.config.js
```

These steps saved me 300 MB! NPM 2 installs each package's dependencies separately, so if two packages depend on the same library, you end up with two copies of it. NPM 3 doesn't install redundant packages, which can result in big file space savings.
