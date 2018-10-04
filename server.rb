# server.rb

require_relative "cf"
require "logger"
require 'rubygems'
require 'sinatra'

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

get '/purge/:zone' do
  zone = params['zone']
  auth = CloudFlare.authenticated?(zone)
  if auth
    begin
      CloudFlare.purge_cache(zone)
    rescue RuntimeError => e
      logger.error("#{e}")
      status 500
      "Something went wrong: #{e}"
    end
    status 204
  else
    status 403
  end
end

get '/' do
  status 200
  "Johnathan.org"
end