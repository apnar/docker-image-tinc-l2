# tinc layer 2 for Docker

Dockerfile (c) 2015 Jens Erat, email@jenserat.de  
modified by Josh Lukens, jlukens@botch.com
Licensed under BSD license

> [tinc](http://www.tinc-vpn.org) is a Virtual Private Network (VPN) daemon that uses tunnelling and encryption to create a secure private network between hosts on the Internet.

This Dockerfile provides an image for running tinc 1.1 (pre release, as packaged by Debian).

## Usage

tinc requires access to `/dev/net/tun`. Allow the container access to the device and grant the `NET_ADMIN` capability:

    --device=/dev/net/tun --cap-add NET_ADMIN

This container assumes it has an eth0 interface inside it which it then converts to a bridge so it can attach tinc's tap interface to for layer 2 bridging.  This is most easily accomplished with the use of the macvlan driver.  So prior to launching the container you'd want to create the docker macvlan network with a command like:

    docker network create \
      -d macvlan --subnet=192.168.1.0/24 \
      --gateway=192.168.1.1 -o parent=eth0 macvlan

A reasonable basic run command loading persisted configuratino from `/srv/tinc` and creating the VPN on the host network would be

    docker run -d \
        --name tinc \
        --net=macvlan \
        --ip=192.168.1.10 \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --volume /srv/tinc:/etc/tinc \
        apnar/tinc-l2 

## Sample tinc config

This container is designed to be used for layer 2 bridging so should be used only with tinc's "switch" mode.  A sample tinc.conf might look like:

    Name = segment1
    Mode = switch
    ConnectTo = segment2

With a tinc-up script like:

    #!/bin/sh
    ifconfig $INTERFACE 0.0.0.0
    brctl addif tinc-bridge $INTERFACE
    ifconfig $INTERFACE up

## Administration and Maintenance

To enter the container for various reasons, use `docker exec`, for example as `docker exec -ti [container-name] /bin/bash`.

## Image Updates

The image is linked to the official Debian images, and automatically rebuild whenever the base image is updated. [tinc is fetched from the Debian experimental repositories](https://packages.debian.org/experimental/tinc) (where tinc 1.1 pre release versions are available).
