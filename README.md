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

We were fed up with Jenkins and we couldn't wait for Travis Pro.  We're not
trying to compete with Travis, we believe it's an awesome service, run by
awesome people, and getting more awesome everyday. But we wanted something
quick and local, so we rolled our own. Also: hacking on a CI server is a lot of
fun!

## Requirements

* Ruby 1.9.3
* ZeroMQ
* CouchDB

## Installation

Install Ruby.
Install ZeroMQ.
Install CouchDB.

Install the ruby dependencies:

    gem install bundler
    bundle install

Put the configuration file in place and edit it if so desired

    cp config/mustacci.example.yml config/mustacci.yml

Start all the things:

    foreman start

Enter the URL of the listener as web service hook in Github.
For example: `http://mustacci.example.com/github`.

## Customizing

### The build process

You are responsible for keeping a script that does your build inside your
repository. You need to create an executable file called `.mustacci` in the
root of your repository. This file needs to do pretty much everything on its
own: install dependencies, create and migrate the database, etc.

If no `.mustacci` is found, it will try to run `rake`. No guarantees though.

### When builds fail or succeed

To customize what happens when a build fails or succeeds, edit `script/failed`
and `script/success`, respectively. Both files are given a filename as
argument. You can read that file for information about the commits done.

## Development installation OSX

Install ZeroMQ:

    brew install zmq

Then you can send a dummy post receive hook:

    curl -d "payload=`cat test/payload.json`" http://localhost:4567/github

Edit `test/payload.json` to try some different kinds of payloads.
