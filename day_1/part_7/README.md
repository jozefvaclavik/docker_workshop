# Part 7

Ok, lets take this one step further. Lets convert our project to development environment. We will drop the production flag, link our current folder and instead of launching webserver when container starts, we're gonna turn it into SSH-like environment.

> Note: Please copy `ping.rb` file from part_6. We're gonna modify the rest.

## Dockerfile

First is is to remove `COPY` line. Because we're not gonna copy anything anymore. Instead we will link the current folder. As the `ping.rb` file is not part of image, the `CMD` line does not make sense anymore. Lets change it to _something generic_ just for fun. We will override it in `docker-compose.yml` anyway. Oh, one more thing. By default workdir its filesystem root `/`, which is not that nice for app. Lets change also the workdir to `/root/app` instead.

```
FROM ruby:latest

RUN gem install sinatra puma redis
WORKDIR /root/app

CMD ["date"]
EXPOSE 4567/tcp
```

## Docker Compose
Next is to update our `docker-compose.yml`. We have to mount the volume and change command that gets executed. We will also remove APP_ENV environment variable.

Last thing to change is the command that gets executed when container starts. Previously we would launch webserver, but now we just want container to hang around and wait until we connect to it. Theres a hack for it.

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
Lets `docker compose up`, you don't really need to run `docker compose build` because it builds the images automatically. You're  gonna see only `part_7-redis-1` output as our `ping` service is just _hanging around_.

Next step is to connect to it. Use `docker ps -a` to list your running containers. You will need its name to run `docker exec -it part_7-ping-1 bash`

Time to test if volume mounting is working as expected. Once you open interactive shell, you will find yourself in `/root/app` and if you do `ls`, you will see `Dockerfile  docker-compose.yml	ping.rb`.

Now on your host system, open the folder in any text editor and modify `ping.rb` file. Especially line 10 to `"Hello world #{settings.redis.incr('count')}x"`.

Once you save it, do `echo ping.rb` on container.

Did it work? Yes? Happy days!

## Run webserver
While you are connected to your container, run `ruby ping.rb` to launch webserver manually.

Wait, it doesn't work. If you remember, we had that issue with puma listening only locally if its `development` environment.

As you can now edit file outside of the container, go ahead and update `puma.rb`. Add above `set :redis` this line `set :bind, '0.0.0.0'`.

Then run `ruby ping.rb` again. Does it work? If yea, you're gonna see `Hello world 1x`.

---
Now you've learned how to modify `docker-compose.yml` to create a local development environment. How to _hack_ your container to do nothing after starting while you _SSH_ into it to run _things_ manually how you would do on your local machine. And all that while editing source code in your favourite editor.

Thats it for Part 7.

## Questions?
