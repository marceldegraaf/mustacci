# Mustacci

Mustacci is a simple, biased continuous integration server for Rails applications.

Requirements:

* ruby 1.9.3-p194
* ZeroMQ

## Development installation OSX

Install ZeroMQ:

    brew install zmq

Install propers gems:

    bundle

To start the Github watcher:

    ./script/github

To start a worker:

    ./script/worker

Then you can send a dummy post receive hook:

    curl -d "payload=`cat test/payload.json`" http://localhost:4567/github
