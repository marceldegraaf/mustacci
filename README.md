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
fun!

## Requirements

* Ruby 1.9.3
* ZeroMQ
* CouchDB

## Installation

1. Install Ruby.
2. Install ZeroMQ.
3. Install CouchDB.
4. Install Mustacci:

      gem install mustacci

5. Generate configuration

      mustacci install /path/to/your/mustacci/config

6. After configuring the generated files, seed the database

      bundle exec mustacci seed

6. Start Mustacci

      bundle exec mustacci start

## Configuration

The `mustacci install` command generated a configuration file.
Loot into that for

## The build process

You are responsible for keeping a script that does your build inside your
repository. You need to create an executable file called `.mustacci` in the
root of your repository. This file needs to do pretty much everything on its
own: install dependencies, create and migrate the database, etc.

If no `.mustacci` is found, it will try to run `rake`. No guarantees though.

## Development installation OSX

Installing ZeroMQ and CouchDB is easy:

    brew install zmq couchdb

Then you can send a dummy post receive hook:

    curl -d "payload=`cat test/payload.json`" http://localhost:8081/github

Edit `test/payload.json` to try some different kinds of payloads.
