github:  ./script/github
worker:  ./script/worker
web:     rackup config.ru -p 9393 -E production -s thin
db:      couchdb -e tmp/couchdb.stderr -o tmp/couchdb.stdout
