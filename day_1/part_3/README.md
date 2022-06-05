# Part 3

So now we know how to write `Dockerfile`. Cool. Lets write a `Dockerfile` for something _real_.

## Project
My background is Rails, but rails is bit too heavy for this purpose. So we're gonna go simpler way of Sinatra[^1]. I've never used it, but it _should_ be super simple.

To install Sinatra, simply do `gem install sinatra`. Oh wait, we don't really need this, right? Coz we are gonna run it in a docker!

Lets write a simple Sinatra app in `ping.rb` file.

```ruby
require 'sinatra/base'

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
```

The app is pretty advanced. Just look at it! Once you launch it, it sets counter to 0 and every time you reload the page, it increments it. Feels like 90s all over again. Noice!

If you have Sinatra running locally, you can actually try it. Run `ruby ping.rb` and then `open http://localhost:4567`. Reload the page couple times and watch the magic happen.

Alrite, back to business. Now that we have our app, lets write a `Dockerfile` for it.

```
FROM ruby:latest

RUN gem install sinatra puma
COPY ./ping.rb ping.rb

CMD ["ruby", "ping.rb"]
```

Instead of starting from `busybox:latest`, we're gonna start of latest ruby image (should be 3.1.2). Then we're gonna install `sinatra` (framework) and `puma` (webserver) gems and copy our `ping.rb` file. Our `CMD` is gonna be `ruby ping.rb`.

## Build
Run `docker build -t day_1:part_3 .` to build the image and tag it `day_1:part_3`.

There really isn't more to it.

## Run the app!
Run `docker container run --rm day_1:part_3` and `open http://localhost:4567`. What do you see?

Yup. Nothing. Nada. Time to go down the rabbit hole and try to figure out why.

If you run `docker container ls -a` you are gonna see your container running. As we didn't name it, it's gonna have a funky name.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED              STATUS                   PORTS         NAMES
91eabf92376a   day_1:part_3      "ruby ping.rb"           About a minute ago   Up About a minute                      romantic_wozniak
```

You can _connect_ to any running container and run commands on it. Kinda like SSH into a server. It's cool. Lets check it out.

Run `docker exec -it romantic_wozniak bash` [^2]. This executes interactively with TTY bash shell on your container. You could execute any command, but opening bash gives you SSH-like access. You should see your root shell in a container `root@91eabf92376a:/#`.

First lets see what is running on the container with `ps -aux`

```sh
root@91eabf92376a:/# ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.3 427780 26124 ?        Ssl  09:29   0:00 puma 5.6.4 (tcp://localhost:4567) [/]
root        12  0.0  0.0   5852  3532 pts/0    Ss   09:34   0:00 bash
root        28  0.0  0.0   8340  2908 pts/0    R+   09:36   0:00 ps -aux
```

This looks good. Our puma is running on `tcp://localhost:4567`.

Next step is to test it out locally. The `ruby` image comes with `curl` pre-installed. So you can test your app with `curl http://localhost:4567` and if you try this couple times, you should see `Pong 1`, then `Pong 2`, then `Pong 3` and so on.

Everything is running correctly on a container. Thats good. So why can't we access it?

## Networking
As I mentioned in Part 1, docker does lots of isolation while sharing existing resources. This also applies to process space and networking. Every docker container runs within its own private network. And these containers can't talk to each other, unless you explicitly expose a port. This can be done in `Dockerfile`.

Add `EXPOSE 4567/tcp` at the end of `Dockerfile` and build the image again. I'm not gonna tell you how. By now, you should know how. Am I right?

Then run it and check its status with `docker container ls -a`.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS         NAMES
e4aea41abe0b   day_1:part_3      "ruby ping.rb"           4 seconds ago   Up 3 seconds   4567/tcp      funny_ganguly
```

Awesome! Now you can se that we have exposed port 4567. On your local machine, `open http://localhost:4567`.

Wait, what? It still doesn't work? Now this is getting frustrating, right?

Exposing port from your container opens it up to other docker containers on the same network. This does not mean you can access it from your host. To do that, you need to publish port from this network to your host in your `docker container run` command. Lets try that with `docker container run --rm --publish 4567:4567 day_1:part_3`.

Unfortunately it still doesn't work. What is going on?

## Environments

We've actually hit a configuration issue in Sinatra. By default Sinatra runs in `development` mode which is available only on `localhost` (thats why running `curl` from within container worked). Containers are like it's own hosts, so it's natural that Sinatra doesn't listen to other host(s). We just need to tell Sinatra that we want it to run in `production` environment. This will allow access to its webserver from all hosts.

To do this, we need to pass in ENV variable `APP_ENV` with value `production`.

Do that with `docker container run --rm --publish:4567:4567 --env APP_ENV=production day_1:part_3` and you may notice that now puma starts with `Environment: production`. `open http://localhost:4567` and you will see `Pong 1` and on next refresh, its gonna be `Pong 2` and so on.

> Wanna hear a funny story? In 2012/2013 there was a somewhat spike in people scanning servers for opened MongoDB databases, downloading their data and deleting it on the node with asking for BTC in return. Basically ransomware. This was possible, coz MongoDB by default doesn't use any authentication. I was then running private app for couple hundred users. This was all hosted on bare servers, so everything was configured manually. I used `iptables` as a firewall. All super tight, but tbh I didn't had much experience with `iptables` and I asked more experienced person to set it up. Everything was running fine. Then we migrated to docker. Basically build production image on every deploy and run it. I was being smart-ass and decided to put all databases in docker as well. But here's the bummer. If you specify `--publish 4567:4567`, docker will work with `iptables` to _publish_ it everywhere. Yup. It will open this port to public. You need to explicitly specify `--publish 127.0.0.1:4567:4567` to explicitly make it available only for `localhost`, but not to the rest of the world. Sigh. Well. I had backups, so I gave middle finger to ransom guys and moved on. Obviously after learning it the hard way.

---
Now you've learned how to expose ports in a `Dockerfile`, publish them to your host and pass in ENV variables. And some Sinatra basics.

Thats it for Part 3.

## Questions?

#### Difference between `docker container run` and `docker exec`?
- `run` creates a new container from image and runs the command in it.
- `exec` executes the command in already running container.


[^1]: [sinatrarb.com](http://sinatrarb.com)
[^2]: [docs: "docker exec"](https://docs.docker.com/engine/reference/commandline/exec/)
