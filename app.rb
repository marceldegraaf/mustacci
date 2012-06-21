$LOAD_PATH.unshift(File.expand_path('./lib', File.dirname(__FILE__)))

require 'rubygems'
require 'compass'
require 'sinatra'
require 'slim'
require 'mustacci/database'
require 'mustacci/build'
require 'mustacci/project'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

set :app_file,       __FILE__
set :root,           File.dirname(__FILE__)
set :views,          'views'
set :public_folder,  'public'

helpers do

  def time(time)
    time = Time.parse(time) unless time.is_a?(Time)
    time.strftime('%m/%d/%Y %H:%M:%S')
  end

  def database
    @database ||= Mustacci::Dabatase.new
  end

end

get '/' do
  @projects = Mustacci::Project.all
  slim :index
end

get '/projects/:id' do
  @project = Mustacci::Project.find(params[:id])
  slim :project
end

get '/projects/:project_id/builds/:id' do
  @project = Mustacci::Project.find(params[:project_id])
  @build = Mustacci::Build.find(params[:id])

  slim :build
end

get '/stylesheets/main.css' do
  sass :main, Compass.sass_engine_options
end
