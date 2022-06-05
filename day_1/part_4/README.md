# Part 4

We've build a pretty sweet app. Unfortunately having counter only on a process level means we will lose it every time we refresh it. Let's add a database and store the counter there.

## Redis
If you think about it, redis is one of the few tools that you run and it just works. So lets do that.

Run `docker run --detach --name redis redis:latest`. We're gonna run community maintained redis image. You may have noticed this time we're naming the container `--name redis` and we're passing `--detach` flag. This will run the container on the background. You should see a long Container ID in output and you can check if everything is running with `docker ps -a`

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS         NAMES
40d4de928279   redis:latest      "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   6379/tcp      redis
```

This means that you have one redis container running with exposed port `6379`.

## Counter in redis
Time to set up some counters in redis. We're gonna modify few things in our `ping.rb` file.

First we need to require `redis` ruby gem in the script. Then in configuration we're gonna create an instance of connection to Redis. We want it to connect to ENV variable we can easily pass in. At last we need to increment a key in our route handler. Redis is so cool that when you call `incr`, it actually returns the current counter. Therefore we don't need to worry about getting value from redis. Here is updated `ping.rb` file.

```ruby
require 'sinatra/base'
require 'redis'

class PingApp < Sinatra::Base
  configure do
    set :redis, redis = Redis.new(url: ENV["REDIS_URL"])
  end

  get '/' do
    "Pong #{settings.redis.incr('count')}"
  end
end

PingApp.run!
```
As we now require new gem, we're gonna have to install it in our `Dockerfile`. Modify the line that installs gems and add there `redis`.

## Build & Run
Time to build current image with `docker build -t day_1:part_4 .`.

As mentioned above, we're gonna have to pass in ENV variable with `REDIS_URL` value. So lets modify our the run command to `docker run --rm --publish 4567:4567 --env APP_ENV=production --env REDIS_URL=redis://redis:6379/0 day_1:part_4`.

When you `open http://localhost:4567`, you're gonna get `Internal Server Error`. Ups. Did we mess up again?

Nah. You see, docker likes to be explicit. Exposing port allows other containers to talk to your container, but you still need to link these containers together so they can talk to each other. Add `--link redis` to your run command and watch the magic happen with `open https://localhost:4567`.

Now as we're still using `--rm` argument, once you exit the container it will delete it. Previously when you would run it again, counter would start from 0. Now as thats persisted in redis, counter will keep increasing.

If you wanna play with it bit more, go ahead and `docker stop redis` ([docs: "docker stop"](https://docs.docker.com/engine/reference/commandline/stop/), `docker rm redis` and then start it again with `docker run --detach --name redis redis:latest`. As you just re-created the redis instance, next time you run the app, counter will start from 0 again.

---
Now you've learned how to talk to Redis in Sinatra. How to launch redis container and how to link it to your apps container so they can talk to each other.

Thats it for Part 4.

## Questions?





