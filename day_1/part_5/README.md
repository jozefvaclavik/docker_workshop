# Part 5
Having your app talking to Redis is really cool. Now you can persist your counter between new versions of your app container.

Unfortunately you may have noticed that it is super easy to delete a container. The whole data gets shredded with it.

> Note: You may either copy `Dockerfile` and `ping.rb` from `part_4` to `part_5` (we are not gonna modify them); or you may as well use existing image build in `day_1:part_4`.

## Volumes
There are two ways how to link volumes to your container:
- you can create data container and map volumes from it to your container. Then even when you delete your container, data container keeps hanging around. Well, until you delete it _accidentally_.
- you can simply link host folders into your container.

Let's focus on the _simpler_ one. Let's link host folder to your `redis` container.

You're gonna have to `docker stop redis` and `docker container rm redis` to clean everything up.

Refer to https://hub.docker.com/_/redis about configuration option. Database images in docker hub usually include section about persisting its storage or at least where the data is located. In this case we need to pass few more details into docker container run command. Especially we need to override `ENTRYPOINT` command so we can pass in additional attributes. Add to the end of a run command `redis-server --save 60 1 --loglevel warning`

Lets create a `/tmp/redis` folder with a `mkdir -p /tmp/redis`. After that add `--volume` flag to the command that links `/tmp/redis` folder to `/data`.

Run `docker container run --detach --name redis --volume /tmp/redis:/data redis:latest redis-server --save 60 1 --loglevel warning`.

Any file written into `/data` in the container will be persisted outside of it. Once you wait a bit, you're gonna see `dump.rdb` in your `/tmp/redis` folder.

Go ahead and exit the ping app. Then `docker stop redis` and `docker container rm redis`. Once you run Redis again with `docker container run --detach --name redis --volume /tmp/redis:/data redis:latest redis-server --save 60 1 --loglevel warning` and launch the app pod once again, you should see counters increasing from the last number.

---
Now you've learned how to link local folder to container. This feature comes especially handy once you wanna start developing in docker container. This way you link your local project folder and run commands in container while doing changes in your local editor.

Thats it for Part 5.

## Questions?
