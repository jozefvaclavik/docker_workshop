# Part 3

So now we know how to write `Dockerfile`. Cool. Lets write a `Dockerfile` for something _real_.

## Project
My background is Rails, but rails is bit too heavy for this purpose. So we're gonna go simpler way of Sinatra. I've never used it, but it _should_ be super simple.

Run `gem install sinatra` to install it. Oh wait, we dont really need this, right? Coz we're gonna run it in docker.

Lets create a simple Sinatra app in `ping.rb` file.

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

The app is super advanced. Once you launch it, it sets counter to 0 and every time you reload the page, it increments it. Feels like 90s all over again. Noice!

If you have sinatra running locally, you can try it. Run `ruby ping.rb` and then `open http://localhost:4567`. Reload the page couple times and watch the magic happen.

Now back to the business. Now that we have our app, lets write a `Dockerfile` for it.

```
FROM ruby:latest

RUN gem install sinatra puma
COPY ./ping.rb ping.rb

CMD ["ruby", "ping.rb"]
```

Now instead of starting from busybox:latest, we're gonna start of latest ruby image (should be 3.1.2). Then we're gonna install `sinatra` (framework) and `puma` (webserver) gems and copy our `ping.rb` file. Our CMD is gonna be `ruby ping.rb`.

## Build
Run `docker build -t day_1:part_3 .` to build the image and tag it `ping_app:latest`.

There really isnt more to it.

## Run the app!
Run `docker run --rm day_1:part_3` and `open http://localhost:4567`. What do you see?

Yup. Nothing. Nada. Lets try to figure out why.

If you run `docker ps -a` youre gonna see your container running. As we didn't name it, it's gonna have funky name.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED              STATUS                   PORTS         NAMES
91eabf92376a   day_1:part_3      "ruby ping.rb"           About a minute ago   Up About a minute                      romantic_wozniak
```

You can _connect_ to any running container and run commands on it. Kinda like SSH into a server. It's cool. Lets check it out.

Run `docker exec -it romantic_wozniak bash` ([docs: "docker exec"](https://docs.docker.com/engine/reference/commandline/exec/). This executes interactively with TTY bash shell on your container. You could execute any command, but opening bash gives you SSH-like access. You should see your root shell in a container `root@91eabf92376a:/#`.

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

## Ports
Docker doesnt automatically expose ports to your host. We're gonna have to tell `Dockerfile` to explicitly expose our `4567` port.

Add `EXPOSE 4567/tcp` at the end of `Dockerfile` and build the image again. I'm not gonna tell you how. By now, you should know how. Am I right?

Then run it and check its status with `docker ps -a`.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS         NAMES
e4aea41abe0b   day_1:part_3      "ruby ping.rb"           4 seconds ago   Up 3 seconds   4567/tcp      funny_ganguly
```

Awesome! Now you can se that we have exposed port 4567. On your local machine, `open http://localhost:4567`.

Wait, what? It still doesn't work? Now this is getting frustrating, right?

Exposing port from your container opens it up to other docker containers. This doesnt mean you can access it from your host. To do that, you need to specify port-mapping in your `docker run` command. Lets try that with `docker run --rm --publish 4567:4567 day_1:part_3`

Unfortunately it still doesnt work. Now its bit of configuration issue. Sinatra by default runs in development mode which is available only on `localhost`. Docker by default uses `0.0.0.0` and we need to tell sinatra we want it to run in `production` environment. This mean we need to pass in ENV variable `APP_ENV` with value `production`.

Do that with `docker run --rm --publish:4567:4567 --env APP_ENV=production day_1:part_3` and you may notice that now puma starts with `Environment: production`. `open http://localhost:4567` and you will see `Pong 1` and on next refresh, its gonna be `Pong 2` and so on.

> Wanna hear a funny story? In 2012/2013 there was a somewhat spike in people scanning servers for opened mongodb databases, downloading their data and deleting it on the node with asking for BTC in return. Basically ransomware. This was possible, coz monbodb by default doesnt use any authentication. I was then running private app for couple hundred users. This was all hosted on bare servers, so everything was configured manually. I used iptables as a firewall. All super tight, but tbh I didn't had much experience with iptables and I asked more experienced person to set it up. Everything was running fine. Then we migrated to docker. Basically build production image, all databases in docker as well with their volumes being persisted (about that in next parts). But here's the bummer. If you specify `--publish 4567:4567`, docker will work with iptables to _publish_ it. Yup. It will open this port to public. You need to explicitely specify `--publish 127.0.0.1:4567:4567` to explicitely make it available only for localhost, but not to the rest of the world. Sigh. Well. I had backups, so I gave middle finger to ransome guys and moved on. Obviously after learning it the hard way.

---
Now you've learned how to expose ports in a Dockerfile, publish them to your host and pass in ENV variables. And some Sinatra basics.

Thats it for Part 3.

## Questions?
