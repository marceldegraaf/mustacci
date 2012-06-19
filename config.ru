require 'sinatra'
require 'faye'
require './app'

Faye::WebSocket.load_adapter 'thin'
use Faye::RackAdapter, mount: '/faye'

run Sinatra::Application
