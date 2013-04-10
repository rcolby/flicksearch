require 'sinatra'
require 'sinatra/reloader'
require 'better_errors'
require 'json'
require 'uri'
require 'open-uri'


configure :development do
  register Sinatra::Reloader
    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path("..", __FILE__)
end

configure do
  @app_name = "Flicksearch"
end

before do
  @app_name = "Flicksearch"
  @page_title = @app_name.dup
end

get '/' do
  @page_title += ": Home"
  erb :home_page
end

get '/search' do
  @query = params[:q]
  @page_title += "Search Results for #{@query}"
  @button = params[:button]
  if @button == "lucky"
    file = open("http://www.omdbapi.com/?t=#{URI.escape(@query)}")
    @result = JSON.load(file.read)
    @actors = @result["Actors"].split(", ")
    @directors = @result["Director"]
    erb :detail
  else
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"] || []
  end
  if @results.size == 1
    redirect "/movies?id=#{@results.first["imdbID"]}"
  else
    erb :results
  end
end

get '/movies' do
  @id = params[:id]
  file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}")
  @result = JSON.load(file.read)
  @page_title += ": #{@result["Title"]}"
  @actors = @result["Actors"].split(", ")
  @directors = @result["Director"].split(", ")
  erb :detail

end

