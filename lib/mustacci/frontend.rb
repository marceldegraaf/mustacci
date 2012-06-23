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

    def self.start
      set :mustacci, Mustacci.configuration
      set :port, Mustacci.configuration.frontend_port
      set :environment, :production
      enable :logging
      run!
    end

    Faye::WebSocket.load_adapter 'thin'
    use Faye::RackAdapter, mount: '/faye'

    set :root, File.expand_path('../../../frontend', __FILE__)

    configure do
      Compass.add_project_configuration(File.join(settings.root, 'compass.rb'))
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

      def faye_channel(channel_id)
        slim :_faye_channel, layout: false, locals: { channel_id: channel_id }
      end

    end

    error do
      <<-HTML
        <h1>HALP!</h1>
        <p>The shit hit the fan in such a way that I don't know what to do.</p>
        <p>The error message: #{request.env['sinatra.error'].message}</p>
      HTML
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
