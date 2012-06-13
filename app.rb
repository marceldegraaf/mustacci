require 'rubygems'
require 'compass'
require 'sinatra'
require 'slim'

set :app_file, __FILE__
set :root,    File.dirname(__FILE__)
set :views,   'views'
set :public,  'public'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end
