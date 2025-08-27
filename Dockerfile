FROM ubuntu:latest
ARG renpy_sdk_version=8.4.2
CMD ["/bin/bash"]

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y wget
RUN wget https://www.renpy.org/dl/${renpy_sdk_version}/renpy-${renpy_sdk_version}-sdk.tar.bz2
RUN apt-get install -y git-lfs
RUN apt-get install -y ffmpeg libsm6 libxext6
RUN apt-get install -y unzip
RUN apt-get install -y bzip2
RUN tar -xvjf renpy-${renpy_sdk_version}-sdk.tar.bz2
RUN rm renpy-${renpy_sdk_version}-sdk.tar.bz2

WORKDIR /renpy-${renpy_sdk_version}-sdk

RUN wget https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
RUN mv default butler.zip
RUN unzip butler.zip
RUN rm butler.zip
RUN chmod +x butler

ENV PATH=/renpy-${renpy_sdk_version}-sdk:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get install -y git
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-venv

RUN wget http://update.renpy.org/${renpy_sdk_version}/renpy-${renpy_sdk_version}-web.zip 
RUN unzip renpy-${renpy_sdk_version}-web.zip 
RUN rm renpy-${renpy_sdk_version}-web.zip