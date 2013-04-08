require 'sinatra/base'
require 'sinatra/reloader'
require 'better_errors'
require 'json'
require 'uri'
require 'open-uri'

class Flicks < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
      use BetterErrors::Middleware
      BetterErrors.application_root = File.expand_path("..", __FILE__)
  end

  configure do
    @app_name = "Flicks"
  end

  before do
    @app_name = "Flicks"
    @page_title = @app_name.dup
  end

  get '/' do
    @page_title += ": Home"

    erb :home
  end

  get '/search' do
    @query = params[:q]
    @button = params[:button]

    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"]

    erb :results
  end

  get '/movies' do
    @id = params[:id]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}")
    @result = JSON.load(file.read)
    @actors = @result["Actors"].split(", ")
    @directors = @result["Director"]

    erb :detail

  end

  run!
end