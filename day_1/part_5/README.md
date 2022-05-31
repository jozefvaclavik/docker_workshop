# Part 5
Having your app talking to redis is really cool. Now you can persist your data between new versions of your app container.

But you may have also noticed that if we delete redis container, the whole data gets shredded with it. You saw how easy it was to delete the whole redis container.

> Note: You may either copy `Dockerfile` and `ping.rb` from `part_4` to `part_5`. We're not gonna modify them. You may as well use existing image build in `day_1:part_4`.

## Volumes
There are two ways how to link volumes to your container. Let's focus on the _simpler_ one. Let's link local folder to your redis container.

Refer to https://hub.docker.com/_/redis about configuration option. Database images usually include section about persisting its storage or at least where the data is located. In this case we need to pass few more details into docker run command. Especially we need to override entrypoint command so we can pass in additional attributes. Add to the end of a run command `redis-server --save 60 1 --loglevel warning`

You're gonna have to `docker stop redis` and `docker rm redis` to clean that up. After that add `--volume` flag to the command that links `./redis` folder to `/data`.

Lets create a `/tmp/redis` folder with a `mkdir -p /tmp/redis`

Run `docker run --detach --name redis --volume /tmp/redis:/data redis:latest redis-server --save 60 1 --loglevel warning`.

Any file written into `/data` in the container will be persisted outside of it. Once you wait a bit, youre gonna see `dump.rdb` in `/tmp/redis` folder.

Go ahead and exit the ping app. Then `docker stop redis` and `docker rm redis`. Once you run redis again `docker run --detach --name redis --volume /tmp/redis:/data redis:latest redis-server --save 60 1 --loglevel warning` and launch the app pod once again, you should see counters increasing from the last number.

---
Now you've learned how to link local folder to container. This feature comes especially handy once you wanna start developing in docker container. This way you link your local project folder and run commands in container while doing changes in your local editor.

Thats it for Part 5.

## Questions?
