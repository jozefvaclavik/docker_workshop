# Part 7

Ok, lets take this one step further. We are gonna convert our project to development environment. We will drop the production flag, link our current folder and instead of launching webserver when container starts, we're gonna turn it into SSH-like environment.

> Note: Please copy `Dockerfile`, `docker-compose.yml` and `ping.rb` files from Part 6.

## Dockerfile

First step is to remove `COPY` line. Because we're not gonna copy anything anymore. Instead we will link the current folder. As the `ping.rb` file is not part of image, the `CMD` line does not make sense anymore. Lets change it to _something generic_ just for fun. We will override it in `docker-compose.yml` anyway. Oh, one more thing. By default workdir its filesystem root `/`, which is not that nice for app. Lets change also the workdir to `/root/app` instead.

```
FROM ruby:latest

RUN gem install sinatra puma redis
WORKDIR /root/app

CMD ["date"]
EXPOSE 4567/tcp
```

## Docker Compose
Next is to update our `docker-compose.yml`. We have to mount the volume and change command that gets executed. We will also remove `APP_ENV` environment variable.

Last thing to change is the command that gets executed when container starts. Previously we would launch the app, but now we just want container to hang around and wait until we _connect_ to it (aka executes `bash`). Theres a hack for it.

```yaml
version: "3.9"
services:
  redis:
    image: redis:latest
  ping:
    build:
      context: .
      dockerfile: Dockerfile
    command: /bin/sh -c "while sleep 1000; do :; done"
    depends_on:
      - redis
    ports:
      - 4567:4567
    environment:
      REDIS_URL: redis://redis:6379/0
    volumes:
      - .:/root/app
```

## Build and Up
Lets `docker compose build` and then `docker compose up`. You are gonna see only `part_7-redis-1` output as our `ping` service is just _hanging around_.

Next step is to connect to it. Use `docker container ls -a` to list your running containers. You will need its name to run `docker container exec -it part_7-ping-1 bash`.

Time to test if volume mounting is working as expected. Once you open interactive shell, you will find yourself in `/root/app` and if you do `ls`, you will see `Dockerfile  docker-compose.yml	ping.rb`.

Now on your host system, open the folder in any text editor and modify `ping.rb` file. Especially line 10 to `"Hello world #{settings.redis.incr('count')}x"`.

Once you save it, do `echo ping.rb` inside of a container.

Did it work? Yes? Happy days!

## Run webserver
While you are connected to your container, run `ruby ping.rb` to launch webserver manually.

Wait, it doesn't work. If you remember, we had that issue with puma listening only locally while running in `development` environment.

As you can now edit file outside of the container, go ahead and update `puma.rb`. Add above `set :redis, ...` line this line `set :bind, '0.0.0.0'`. This tells webserver to listen for traffic from all hosts.

Then run `ruby ping.rb` again. Does it work? If yea, you're gonna see `Hello world 1x`.

## Bonus content
Adding persistance to `redis` service is actually easier then it seems. Simply add `volumes` with appropriate mapping and overrice `command`. Here is updated redis service.

```yaml
services:
  redis:
    volumes:
      - /tmp/redis:/data
    command: redis-server --save 60 1 --loglevel warning
```

You're gonna have to tear `docker compose down` to clean up existing containers so docker can spinn up new `redis` service with persistence.

---
Now you've learned how to modify `docker-compose.yml` to create a local development environment. How to _hack_ your container to do nothing after starting while you _SSH_ into it to run _things_ manually how you would do on your local machine. And all that while editing source code in your favourite editor.

Thats it for Part 7.

## Questions?
