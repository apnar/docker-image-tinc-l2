# tinc for Docker with bridge-utils

Dockerfile (c) 2015 Jens Erat, email@jenserat.de  
modified by Josh Lukens, jlukens@botch.com
Licensed under BSD license

> [tinc](http://www.tinc-vpn.org) is a Virtual Private Network (VPN) daemon that uses tunnelling and encryption to create a secure private network between hosts on the Internet.

This Dockerfile provides an image for running tinc 1.1 (pre release, as packaged by Debian).

## Usage

tinc requires access to `/dev/net/tun`. Allow the container access to the device and grant the `NET_ADMIN` capability:

    --device=/dev/net/tun --cap-add NET_ADMIN

A reasonable basic run command loading persisted configuration from `/srv/tinc` and creating the VPN on the host network would be

    docker run -d \
        --name tinc \
        --net=host \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --volume /srv/tinc:/etc/tinc \
        apnar/tinc-l2 

## Waiting for interface

In a number of confiurations you may want to add or change interfaces (with something like pipework or docker network) to the container prior to tinc actually starting.  You can do that by defining the enviroment variable WAIT_INT in your doccker command.   

    docker run -d \
        --name tinc \
        --net=host \
        --env WAIT_INT=eth2 \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --volume /srv/tinc:/etc/tinc \
        apnar/tinc-l2 

In the above example tinc won't start until the eth2 interface exists.  At which point you can do all your network shuffling via your tinc-up script.

## Sample tinc config

This container is designed to be used for layer 2 bridging so should be used only with tinc's "switch" mode.  A sample tinc.conf might look like:

    Name = segment1
    Mode = switch
    ConnectTo = segment2

With a tinc-up script like:

    #!/bin/sh
    ifconfig $INTERFACE 0.0.0.0
    brctl addif br0 $INTERFACE
    ifconfig $INTERFACE up

## Administration and Maintenance

To enter the container for various reasons, use `docker exec`, for example as `docker exec -ti [container-name] /bin/bash`.

## Image Updates

The image is linked to the official Debian images, and automatically rebuild whenever the base image is updated. [tinc is fetched from the Debian experimental repositories](https://packages.debian.org/experimental/tinc) (where tinc 1.1 pre release versions are available).
