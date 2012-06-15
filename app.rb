require 'rubygems'
require 'compass'
require 'sinatra'
require 'slim'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

set :app_file,       __FILE__
set :root,           File.dirname(__FILE__)
set :views,          'views'
set :public_folder,  'public'

get '/' do
  slim :index
end

get '/projects/:name' do
  slim :project
end

get '/stylesheets/main.css' do
  sass :main, Compass.sass_engine_options
end
