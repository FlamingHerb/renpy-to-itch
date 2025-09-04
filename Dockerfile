FROM ubuntu:latest
ARG renpy_sdk_version=8.4.1
ARG android_sdk_version=11076708_latest
CMD ["/bin/bash"]

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y wget
RUN wget https://www.renpy.org/dl/${renpy_sdk_version}/renpy-${renpy_sdk_version}-sdk.tar.bz2
RUN apt-get install -y git-lfs
RUN apt-get install -y ffmpeg libsm6 libxext6
RUN apt-get install -y unzip
RUN apt-get install -y bzip2

# Install i386 packages separately to avoid dependency issues
# RUN dpkg --add-architecture i386 && apt-get update && \
# 	apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

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

# Common assumption is that we're already at the folder.

RUN wget http://update.renpy.org/${renpy_sdk_version}/renpy-${renpy_sdk_version}-web.zip 
RUN unzip renpy-${renpy_sdk_version}-web.zip 
RUN rm renpy-${renpy_sdk_version}-web.zip

RUN wget http://update.renpy.org/${renpy_sdk_version}/renpy-${renpy_sdk_version}-renios.zip
RUN unzip renpy-${renpy_sdk_version}-renios.zip 
RUN rm renpy-${renpy_sdk_version}-renios.zip

RUN wget http://update.renpy.org/${renpy_sdk_version}/renpy-${renpy_sdk_version}-rapt.zip
RUN unzip renpy-${renpy_sdk_version}-rapt.zip 
RUN rm renpy-${renpy_sdk_version}-rapt.zip

# NOTE: Work
# Downloading JDK
RUN apt-get install -y temurin-21-jdk

# Download and move Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${android_sdk_version}.zip
RUN unzip commandlinetools-linux-${android_sdk_version}.zip -d rapt/Sdk/
RUN mv rapt/Sdk/cmdline-tools rapt/Sdk/latest
RUN mkdir rapt/Sdk/cmdline-tools
RUN mv rapt/Sdk/latest rapt/Sdk/cmdline-tools/latest
RUN rm commandlinetools-linux-${android_sdk_version}.zip

# Download Packages
RUN wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
RUN unzip platform-tools-latest-linux.zip -d rapt/Sdk/
RUN rm platform-tools-latest-linux.zip

# Download platform
RUN chmod +x ./rapt/Sdk/cmdline-tools/latest/bin/sdkmanager
RUN ./rapt/Sdk/cmdline-tools/latest/bin/sdkmanager --sdk-root=/renpy-${renpy_sdk_version}-sdk/rapt/Sdk/
RUN ./rapt/Sdk/cmdline-tools/latest/bin/sdkmanager --update -y
RUN ./rapt/Sdk/cmdline-tools/latest/bin/sdkmanager --licenses -y
RUN ./rapt/Sdk/cmdline-tools/latest/bin/sdkmanager --install "platforms;android-35" -y