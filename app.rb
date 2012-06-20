require 'rubygems'
require 'compass'
require 'sinatra'
require 'slim'
require './lib/mustacci/models'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

set :app_file,       __FILE__
set :root,           File.dirname(__FILE__)
set :views,          'views'
set :public_folder,  'public'

helpers do

  def time(time)
    time.strftime('%m/%d/%Y %H:%M:%S')
  end

end

get '/' do
  @projects = Mustacci::Project.all
  slim :index
end

get '/projects/:owner/:name' do
  @project = Mustacci::Project.first(owner: params[:owner], name: params[:name])
  slim :project
end

get '/projects/:owner/:name/builds/:identifier' do
  @project = Mustacci::Project.first(owner: params[:owner], name: params[:name])
  @build = @project.builds.first(identifier: params[:identifier])

  slim :build
end

get '/stylesheets/main.css' do
  sass :main, Compass.sass_engine_options
end
