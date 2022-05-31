require 'sinatra'

class PingApp < Sinatra::Base
  configure do
    set :count, 0
  end

  get '/' do
    settings.count += 1
    "Pong #{settings.count}"
  end
end

PingApp.run!
