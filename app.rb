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

helpers do

  def time(time)
    time.strftime('%m/%d/%Y %H:%M:%S')
  end

end

get '/' do
  slim :index
end

get '/projects/:user/:project' do
  @user, @project = params[:user], params[:project]
  slim :project
end

get '/projects/:user/:project/builds/:hash' do
  @hash = params[:hash]
  @file = File.open("tmp/output/#{@hash}.html")
  @time = @file.mtime
  @output = @file.read
  slim :build
end

get '/stylesheets/main.css' do
  sass :main, Compass.sass_engine_options
end
