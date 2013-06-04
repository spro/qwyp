#!/bin/sh

coffee -c client.coffee
browserify client.js > static/client.js
rm client.js
