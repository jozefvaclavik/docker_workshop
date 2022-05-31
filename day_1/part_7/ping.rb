require 'sinatra/base'
require 'redis'

class PingApp < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    set :redis, redis = Redis.new(url: ENV["REDIS_URL"])
  end

  get '/' do
    "Hello world #{settings.redis.incr('count')}x"
  end
end

PingApp.run!
