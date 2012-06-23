# Mustacci

Mustacci is a simple, biased continuous integration server.

## How does it work?

Mustacci has many small parts. Here is the general gist of it:

1. The listener is a small Sinatra app that receives push notification from Github.
2. The listener sends the payload via ZeroMQ to the worker.
3. The worker stores the payload and starts the runner.
4. The runner runs your tests.
5. Meanwhile, all output is streamed to your browser.
6. You get to write a script that will notify you in the way you see fit.

It's not finished yet. Feel free to help us out, by contacting us.

## Why Mustacci?

We were fed up with Jenkins and we couldn't wait for Travis Pro. We're not
trying to compete with Travis, we believe it's an awesome service, run by
awesome people, and getting more awesome everyday. But we wanted something
quick and local, so we rolled our own. Also: hacking on a CI server is a lot of
fun! It turned out it wasn't as simple as we thought, but definitely fun.

## Requirements

* Ruby 1.9.3
* ZeroMQ
* CouchDB

## Installation

Install the gem:

``` shell
gem install mustacci
```

And run the installer to generate the configuration files. You'll have to give
it a directory where to put the configuration files, e.g.:

``` shell
mustacci install ~/Mustacci
```

You'll get these files:

* `mustacci.rb`, where you do all of your configurations.
* `Gemfile`, where you can add dependencies via [Bundler](http://gembundler.com/)
* `Procfile`, where you can specify the processes to run, using [Foreman](http://ddollar.github.com/foreman/)

Have a look through those file and configure as needed/wanted.

When you've configured it to your liking, setup the database:

``` shell
mustacci setup
```

Then you can start Mustacci:

``` shell
foreman start
```


## The build process

You are responsible for keeping a script that does your build inside your
repository. You need to create an executable file called `.mustacci` in the
root of your repository. This file needs to do pretty much everything on its
own: install dependencies, create and migrate the database, etc.

The `.mustacci` file must be executable and don't forget the hashbang at the top.

For example:

``` shell
#!/usr/bin/env bash
set -e
export RAILS_ENV=test
gem install bundler
bundle install
rake db:create
rake db:migrate
rspec -fp
```

If no `.mustacci` is found, it will try to run `rake`. No guarantees though.

## Development

After cloning, run `bundle install`, then install the application:

``` shell
bundle exec mustacci install dev
```

Then edit the `Gemfile` and let the mustacci gem point to your local setup:

``` ruby
gem 'mustacci', :path => '../mustacci'
```

There is a dummy github payload you can use to test the github listener:

``` shell
curl -d "payload=`cat test/payload.json`" http://localhost:8081/github
```
