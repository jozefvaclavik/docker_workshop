# Part 1

Back in 2009-2012 was a period when it was easier to run development environment on virtual machine then on a MacOS. There was no Homebrew, no ruby-buils, easiest way to install/run postgres/mysql was through LAMP type of packaged apps. Any upgrade of MacOS between major versions would mean that things were broken for 1-2 months.

Virtual machines had one issue. You couldnt easily move them around or rebuild them if you needed. You could take dumps/snapshots, but to be fair, this was time CPUs in MBP has 2 cores and 200GB drives were kinda default so having 20GB snapshot laying around wasn't really reasonable.

This was when docker came in and I started experimenting with it. Docker is not a full virtualization. That means it's not as reasource heavy as VM. It relies on images build based on Dockerfile and creates running containers from them. Containers are persistent only while they are created, once you delete a container, its data is gone. This is one important difference between running VMs and containers.

That was enough history, lets get started. Hope by now you have docker installed locally, so lets create some containers in practice.

## Welcome to Busybox
Buxybox is the smallest and simplest linux image available (1-5MB). Lets run that and see what happens.

Run `docker run -it --rm busybox`

Then you should see something like this:

```sh
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
e9bbb3cc217f: Pull complete
Digest: sha256:ebadf81a7f2146e95f8c850ad7af8cf9755d31cdba380a8ffd5930fba5996095
Status: Downloaded newer image for busybox:latest
/ #
```

Lets go line by line to see what happened. The command we just ran said: "Hey docker, run interactively busybox image and delete it once I'm done with it."

The first line of output said that docker could not find busybox:latest locally. Second line said that docker is pulling it from library/busybox and after that there are some details about ID of image it downloaded, it status and some digest/sha verification. At the end you get some final status message and you are welcomed with a prompt. This prompt is inside of the busybox container.

You can test that by calling

```sh
/ # uname -a
Linux 85a6c3b1bc4a 5.10.104-linuxkit #1 SMP PREEMPT Thu Mar 17 17:05:54 UTC 2022 aarch64 GNU/Linux
```

You can run some other linux commands and have some fun with it.

## Containers
Now open another terminal tab and run `docker ps -a`. You should see something like

```sh
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS      NAMES
85a6c3b1bc4a   busybox           "sh"                     5 minutes ago   Up 5 minutes              vibrant_maxwell
```

This lists all containers on your machine (by default it prints only running containers, `-a` prints containers in any state). You can see that there is one container from image `busybox` and running command `sh`. It was created while ago and has a funky name. If you don't name your container when creating it, docker will assign it random two-word name.

Now lets exit the shell youre running in the container by typing `exit` or `CTRL+d`. And go ahead and print all containers again. Did you notice any difference? Thats the `-rm` flag passed into `exec` command. It specified that once we're done running it, we wanna delete the container.

## Images
Now that you know how to list your containers, lets also have a look how to list your images that you have stored locally.

Type `docker images` and you will see similar list of all local images.

```sh
REPOSITORY            TAG                                  IMAGE ID       CREATED        SIZE
busybox               latest                               9f509842917a   5 days ago     1.41MB
```

You can see that we have a `busybox` image with latest tag and some other details. It really is just 1.41MB.

If you wanna remove existing image (loacly), you can delete it  with `docker rmi busybox:latest` or by passing its image ID `docker rmi 9f509842917a`

```sh
Untagged: busybox:latest
Untagged: busybox@sha256:ebadf81a7f2146e95f8c850ad7af8cf9755d31cdba380a8ffd5930fba5996095
Deleted: sha256:9f509842917afa47c9cdfa360d23641e013e8590ca4a476e434bbe9c4fda41be
Deleted: sha256:954b5f64facaacc791fd27fc3115af390bd5c5c105e5dfe0702805d95a126e5d
```

You may wonder where did this `busybox` image magically  appeared. Docker maintains a registry of docker images. Some of these are community maintained/official images, others are public or private images. In this case `busybox` is a community maintained docker image that comes from https://hub.docker.com/_/busybox

---
Now you've learned the difference between VM and Docker, something about containers and something about images.

Thats it for Part 1.

## Questions?
