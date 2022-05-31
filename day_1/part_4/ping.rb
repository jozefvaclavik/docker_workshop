require 'sinatra'
require 'redis'

class PingApp < Sinatra::Base
  configure do
    set :redis, redis = Redis.new(url: ENV["REDIS_URL"])
  end

  get '/' do
    "Pongs #{settings.redis.incr('count')}"
  end
end

PingApp.run!
