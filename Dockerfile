FROM registry.hub.docker.com/library/ubuntu:latest
ARG renpy_sdk_version=8.5.2
ARG android_sdk_version=11076708_latest
CMD ["/bin/bash"]

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y wget
RUN wget https://www.renpy.org/dl/${renpy_sdk_version}/renpy-${renpy_sdk_version}-sdk.tar.bz2
RUN apt-get install -y git-lfs
RUN apt-get install -y ffmpeg libsm6 libxext6
RUN apt-get install -y unzip
RUN apt-get install -y bzip2
RUN apt-get install -y default-jre

# Install i386 packages separately to avoid dependency issues
# RUN dpkg --add-architecture i386 && apt-get update && \
# 	apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

RUN tar -xvjf renpy-${renpy_sdk_version}-sdk.tar.bz2
RUN rm renpy-${renpy_sdk_version}-sdk.tar.bz2

WORKDIR /renpy-${renpy_sdk_version}-sdk

RUN wget https://broth.itch.zone/butler/linux-amd64/LATEST/archive/default
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
# RUN apt-get install -y temurin-21-jdk

# Install OpenJDK 8 (Ren'Py Android builds work best with JDK 8)
RUN apt-get install -y openjdk-21-jdk-headless

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Download and set up Android SDK for Ren'Py
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${android_sdk_version}.zip
RUN unzip commandlinetools-linux-${android_sdk_version}.zip -d rapt/Sdk/
RUN mv -v -T rapt/Sdk/cmdline-tools rapt/Sdk/latest 
RUN mkdir -p rapt/Sdk/cmdline-tools
RUN mv -v -t rapt/Sdk/cmdline-tools rapt/Sdk/latest
RUN chmod +x rapt/Sdk/cmdline-tools/latest/bin/sdkmanager
RUN rm commandlinetools-linux-${android_sdk_version}.zip

# Install platform-tools
RUN wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
RUN unzip platform-tools-latest-linux.zip -d rapt/Sdk/
RUN rm platform-tools-latest-linux.zip

# Set ANDROID_HOME for Ren'Py
ENV ANDROID_HOME=/renpy-${renpy_sdk_version}-sdk/rapt/Sdk
ENV PATH=$PATH:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin

# Accept licenses and install required Android SDK packages for Ren'Py
RUN yes | sdkmanager --licenses
RUN sdkmanager --update
RUN sdkmanager --install \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;30.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*