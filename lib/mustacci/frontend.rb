require 'compass'
require 'sinatra'
require 'slim'
require 'mustacci/database'
require 'mustacci/build'
require 'mustacci/project'
require 'sinatra/base'
require 'faye'

module Mustacci
  class Frontend < Sinatra::Base

    def self.start(configuration)
      set :mustacci, configuration
      set :port, configuration.frontend_port
      enable :logging
      run!
    end

    Faye::WebSocket.load_adapter 'thin'
    use Faye::RackAdapter, mount: '/faye'

    set :root,           File.expand_path('../../../', __FILE__)
    set :views,          'views'
    set :public_folder,  'public'

    configure do
      Compass.add_project_configuration(File.join(settings.root, 'config', 'compass.rb'))
    end

    helpers do

      def time(time)
        time = Time.parse(time) unless time.is_a?(Time)
        time.strftime('%d/%m/%Y %H:%M:%S')
      end

      def database
        @database ||= Mustacci::Dabatase.new
      end

      def build_status(build)
        slim :_build_status, layout: false, locals: { build: build }
      end

      def faye_url
        "http://#{settings.mustacci.hostname}:#{settings.mustacci.websocket_port}/faye"
      end

    end

    error do
      "<p>HALP! The shit hit the fan in such a way that I don't know what to do. The error message:<br><br>" + request.env['sinatra.error'].message + "</p>"
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

  end
end
