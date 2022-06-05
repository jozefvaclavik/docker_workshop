# Part 6
Dont know about you, but I would say things are getting bit out of hands here. Just check the length of these commands.

`docker run --detach --name redis --volume /tmp/redis:/data redis:latest redis-server --save 60 1 --loglevel warning`

`docker run --rm --publish 4567:4567 --env APP_ENV=production --env REDIS_URL=redis://redis:6379/0 --link redis day_1:part_6`

Don't know about you, but this feels bit too long to try to write this from your head.

> Note: Please copy `Dockerfile` and `ping.rb` from Part 3 or Part 4 or Part 5. We're not gonna modify them, but we will use them.

## Docker Compose
This is where `docker compose` command comes in handy. It's a command that allows you to specify all attributes you pass into your containers into YAML file and run that all at once.

Lets start with simple `docker-compose.yml` and for now we will ignore all redis persistance stuff. Just to keep things simple.

```yaml
version: "3.9"
services:
  redis:
    image: redis:latest
  ping:
    build:
      context: .
      dockerfile: Dockerfile
    depends_on:
      - redis
    ports:
      - 4567:4567
    environment:
      APP_ENV: production
      REDIS_URL: redis://redis:6379/0
```

You can see that we specify two services. First is `redis` that uses `redis:latest` image; another one is `ping` that contains `build` hash specifying dockerfile and context. It also depends on `redis` service; publishes port 4567 and sets two environment variables.

## Build
Lets try to build it with `docker compose build` [^1]. If all goes as expected, you should see similar output

```sh
[+] Building 2.3s (9/9) FINISHED
 => [internal] load build definition from Dockerfile                                                                          0.0s
 => => transferring dockerfile: 154B                                                                                          0.0s
 => [internal] load .dockerignore                                                                                             0.0s
 => => transferring context: 2B                                                                                               0.0s
 => [internal] load metadata for docker.io/library/ruby:latest                                                                2.2s
 => [auth] library/ruby:pull token for registry-1.docker.io                                                                   0.0s
 => [1/3] FROM docker.io/library/ruby:latest@sha256:af018e85cfae54a8d4c803640663e26232f49f31bfbe8b876e678e5365bc13ff          0.0s
 => [internal] load build context                                                                                             0.0s
 => => transferring context: 261B                                                                                             0.0s
 => CACHED [2/3] RUN gem install sinatra puma redis                                                                           0.0s
 => CACHED [3/3] COPY ./ping.rb ping.rb                                                                                       0.0s
 => exporting to image                                                                                                        0.0s
 => => exporting layers                                                                                                       0.0s
 => => writing image sha256:495d5fb0c318ffa3c3f848463905fd02cb7bb7d6cfc5944e3264a735d14ac1da                                  0.0s
 => => naming to docker.io/library/part_6_ping                                                                                0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
```

You can see the build was actually re-using already cached images. If you list `docker images`, you will see one new line

```sh
REPOSITORY            TAG                                  IMAGE ID       CREATED             SIZE
part_6_ping           latest                               495d5fb0c318   About an hour ago   851MB
```

This repository name `part_6_ping` is auto generated. I believe it consists of current folder name and service name.

## Run it
Now that we've build it, lets try to run it with `docker compose up` [^2]. This will create a new containers for each service and launch them.

```sh
[+] Running 3/3
 ⠿ Network part_6_default    Created                                                                                          0.0s
 ⠿ Container part_6-redis-1  Created                                                                                          0.0s
 ⠿ Container part_6-ping-1   Created                                                                                          0.0s
Attaching to part_6-ping-1, part_6-redis-1
part_6-redis-1  | 1:C 31 May 2022 11:54:50.403 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
part_6-redis-1  | 1:C 31 May 2022 11:54:50.403 # Redis version=7.0.0, bits=64, commit=00000000, modified=0, pid=1, just started
part_6-redis-1  | 1:C 31 May 2022 11:54:50.403 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
part_6-redis-1  | 1:M 31 May 2022 11:54:50.403 * monotonic clock: POSIX clock_gettime
part_6-redis-1  | 1:M 31 May 2022 11:54:50.404 * Running mode=standalone, port=6379.
part_6-redis-1  | 1:M 31 May 2022 11:54:50.404 # Server initialized
part_6-redis-1  | 1:M 31 May 2022 11:54:50.405 * The AOF directory appendonlydir doesn\'t exist
part_6-redis-1  | 1:M 31 May 2022 11:54:50.405 * Ready to accept connections
part_6-ping-1   | Puma starting in single mode...
part_6-ping-1   | * Puma version: 5.6.4 (ruby 3.1.2-p20) ("Birdie's Version")
part_6-ping-1   | *  Min threads: 0
part_6-ping-1   | *  Max threads: 5
part_6-ping-1   | *  Environment: production
part_6-ping-1   | *          PID: 1
part_6-ping-1   | == Sinatra (v2.2.0) has taken the stage on 4567 for production with backup from Puma
part_6-ping-1   | * Listening on http://0.0.0.0:4567
part_6-ping-1   | Use Ctrl-C to stop
```

Go ahead and `open http://localhost:4567` and watch the magic.

Stop with with `CTRL+d`.

```sh
^CGracefully stopping... (press Ctrl+C again to force)
[+] Running 2/2
 ⠿ Container part_6-ping-1   Stopped                                                                                        0.1s
 ⠿ Container part_6-redis-1  Stopped                                                                                        0.1s
canceled
```

Now go ahead and inspect containers with `docker ps -a`. You're gonna see two new containers. One for each service.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED              STATUS                      PORTS        NAMES
7833f337f26c   part_6_ping       "ruby ping.rb"           About a minute ago   Exited (1) 30 seconds ago                part_6-ping-1
ba072e1b8235   redis:latest      "docker-entrypoint.s…"   About a minute ago   Exited (0) 30 seconds ago                part_6-redis-1
```

Once you have a containers created, you can simply `docker compose start` [^3].

```sh
[+] Running 2/2
 ⠿ Container part_6-redis-1  Started                                                                                         0.2s
 ⠿ Container part_6-ping-1   Started                                                                                         0.2s
```

Give `docker ps -a` another look and you will see them up and running. Doing `docker compose stop` [^4] will stop them.

## Tear it down
Sometimes you wanna delete all the containers and start all over again from scratch. In that case do `docker compose down` [^5] and it will clean up everything for you.

```sh
[+] Running 3/2
 ⠿ Container part_6-ping-1   Removed                                                                                         0.1s
 ⠿ Container part_6-redis-1  Removed                                                                                         0.2s
 ⠿ Network part_6_default    Removed                                                                                         0.0s
```

 ---
 Now you've learned basic commands of `docker compose` command. You know how to write your own `docker-compose.yml` file, link multiple services, publish your ports and configure environment variables.

Thats it for Part 6.

## Questions?

[^1]: [docs: "docker compose build"](https://docs.docker.com/engine/reference/commandline/compose_build/)
[^2]: [docs: "docker compose up"](https://docs.docker.com/engine/reference/commandline/compose_up/)
[^3]: [docs: "docker compose start"](https://docs.docker.com/engine/reference/commandline/compose_start/)
[^4]: [docs: "docker compose stop"](https://docs.docker.com/engine/reference/commandline/compose_stop/)
[^5]: [docs: "docker compose down"](https://docs.docker.com/engine/reference/commandline/compose_down/)
