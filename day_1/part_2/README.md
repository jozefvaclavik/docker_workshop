# Part 2

Now that we have docker running, we understand the concepts of images and containers its time to go step one forward.

Lets build our own docker image!

In your folder, create a `Dockerfile`

```
FROM busybox:latest
COPY ./script.sh script.sh
ENTRYPOINT ./script.sh
```

This `Dockerfile` is an image definition. You can use this definition to build docker image. Each line will build intermediate docker image that is used as a cache when building same or other images out of it.

You may remember I mentioned that every docker image needs to reference another docker image. This is what first line of `Dockerfile` is for. You specify out of what docker image you want yours to start. In our case its `FROM busybox:latest`
Second line copies our `script.sh` into the image.
Every docker image should have either `ENTRYPOINT` or `CMD` at the end. (Ehm, after almost 10 years working with docker, I still dont know the difference out of my head. There is, I swear. Just read the damn docs.) This gets executed when someone tries to run container from the image. In our case we're gonna execute the script we wrote.

Here is content of `script.sh`

```sh
date
```

Yup. That was it. Lets just print date. Don't forget to add executable flag to it. `chmod +x script.sh` otherwise docker will not be able to execute it.

## Build that image
Now its time to build that image. Run `docker build .` ([docs: "docker build"](https://docs.docker.com/engine/reference/commandline/build/)) and you should see something like

```sh
[+] Building 3.7s (8/8) FINISHED
 => [internal] load build definition from Dockerfile                                                                                         0.0s
 => => transferring dockerfile: 110B                                                                                                         0.0s
 => [internal] load .dockerignore                                                                                                            0.0s
 => => transferring context: 2B                                                                                                              0.0s
 => [internal] load metadata for docker.io/library/busybox:latest                                                                            3.2s
 => [auth] library/busybox:pull token for registry-1.docker.io                                                                               0.0s
 => [internal] load build context                                                                                                            0.0s
 => => transferring context: 41B                                                                                                             0.0s
 => [1/2] FROM docker.io/library/busybox:latest@sha256:ebadf81a7f2146e95f8c850ad7af8cf9755d31cdba380a8ffd5930fba5996095                      0.4s
 => => resolve docker.io/library/busybox:latest@sha256:ebadf81a7f2146e95f8c850ad7af8cf9755d31cdba380a8ffd5930fba5996095                      0.0s
 => => sha256:aadac55005f0a3cb3a66623bcaae762ce2664377569eecd0c321b7d6fa4f60e9 527B / 527B                                                   0.0s
 => => sha256:9f509842917afa47c9cdfa360d23641e013e8590ca4a476e434bbe9c4fda41be 1.47kB / 1.47kB                                               0.0s
 => => sha256:e9bbb3cc217f51be8fe02e09b3fff565a1b715808890428d5faa8eab084af5f5 828.41kB / 828.41kB                                           0.3s
 => => sha256:ebadf81a7f2146e95f8c850ad7af8cf9755d31cdba380a8ffd5930fba5996095 2.29kB / 2.29kB                                               0.0s
 => => extracting sha256:e9bbb3cc217f51be8fe02e09b3fff565a1b715808890428d5faa8eab084af5f5                                                    0.1s
 => [2/2] COPY ./script.sh script.sh                                                                                                         0.0s
 => exporting to image                                                                                                                       0.0s
 => => exporting layers                                                                                                                      0.0s
 => => writing image sha256:1ace621ca581d0c542ab39e470fd8562dd5eafd833a4e7379027d62b2205e7c6                                                 0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
```

That is lots of lines. There are just 2 important things that has happened.
1. As we deleted `busybox:latest` in previous part, docker now had to download it again. This happened in the part of `[1/2]`.
2. We copied our `script.sh` in `[2/2]`.

Thats it. Now if you list your `docker images` you're gonna see it.

```sh
REPOSITORY            TAG                                  IMAGE ID       CREATED         SIZE
<none>                <none>                               1ace621ca581   2 minutes ago   1.41MB
```

But this doesnt look right. There is no repository and no tag mentioned. Ugh. Did we just mess up?

This is similar behaviour like when creating containers. If you don't specify it during build, it will end up as untagged image. You can either tag it afterwards by referencing Image ID `docker tag 1ace621ca581 day_1:part_2`, or specify tag during `docker build -t day_1:part_2 .`. Do either one of that and next time you list your `docker images`, you will see

```sh
REPOSITORY            TAG                                  IMAGE ID       CREATED         SIZE
day_1                 part_2                               1ace621ca581   5 minutes ago   1.41MB
```

Now thats better.

## Run the container
Ok, so we've build our own docker image that will run script that prints current date. Lets try to run it `docker run day_1:part_2` and you should see output of current date and then it will exit.

Now its time to list containers and images and clean that up. As you didnt provide `--rm` into the above run command, one the container exits, it stays created.

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED              STATUS                          PORTS        NAMES
71684bb56359   day_1:part_2      "/bin/sh -c ./script…"   About a minute ago   Exited (0) About a minute ago                elated_albattani
```

You can delete this container by either its Container ID or by its Name. `docker rm 71684bb56359` or `docker rm elated_albattani`. [docs: "docker rm"](https://docs.docker.com/engine/reference/commandline/rm/)

Now check out your `docker images` and if you played around and tried to build the above image multiple times, you may noticed couple untagged images. You can't have multiple images with same tag. Last build always untags previous images if the tag was already used. So lets clean them up. For untagged ones, you gotta used Image ID, and for tagged one just used the repository:tag combination. `docker rmi day_1:part_2` and `docker rmi fc12c2dcf10a 1ace621ca581` or whatever untagged Image IDs you see there.

---
Now you've learned how to write your own `Dockerfile`, build and run it.

Thats it for Part 2.

## Questions?
