# renpy-to-itch

## Setup

- Change secrets.
  - Like the `Itch_API_Key`.
- Change routing for builds.
- ???
- Profit.

## Example build

```
name: "Itch.io Export"

on:
  push:
    tags:
      - "v*"      
  workflow_dispatch:


jobs:
  build:
    runs-on: ubuntu-latest
    container: v4ccarria/renpy-to-itch:latest
    steps:
        - name: Checkout
          uses: actions/checkout@v4
          with:
              lfs: true

        - name: Get latest tag pushed
          id: tag
          uses: 32teeth/action-github-tag@v1.0.7
          with:
            # Return only the tag number (e.g., v1.0.0 -> 1.0.0)
            numbers_only: true

        - name: Change version according to specified version tag
          run: |
            sed -i 's/define config.version = "1.0"/define config.version = "${{steps.tag.outputs.tag}}"/' /__w/*/*/game/options.rpy

        - name: Copy Project Folder to Ren'Py
          run: |
            cp -R /__w/*/* /renpy-*/

        - name: Setup Builds Folder
          run: |
            mkdir -v -p ~/builds
            mkdir -v -p ~/builds/web

        - name: Debug (Checking with ls)
          run: |
            ls -l

        - name: Ren'Py PC Distributions
          id: renpy_dist_pc
          run: |
            cd /renpy-*/
            ./renpy.sh launcher distribute ${{ github.event.repository.name }}/ --destination ~/builds
            ./renpy.sh launcher web_build ${{ github.event.repository.name }}/ --destination ~/builds/web
        
        - name: Ren'Py Mobile Distributions
          id: renpy_dist_mobile
          run: |
            cd /renpy-*/
            ./renpy.sh launcher android_build ${{ github.event.repository.name }}/ --destination ~/builds/android

        # - name: Upload Artifact
        #   id: upload_artifact
        #   uses: actions/upload-artifact@v4
        #   with:
        #     path: ~/builds/
        
        - name: Obligatory LS
          run : ls ~/builds


        - name: Place API Key to butler_creds
          run: |
            mkdir -p ~/.config/itch/
            touch ~/.config/itch/butler_creds
            echo -n ${{ secrets.Itch_API_Key }} | cat > ~/.config/itch/butler_creds
        
        - name: Logging in to Itch
          run: |
            butler login

        - name: Push All to Itch
          run: |
            butler push ~/builds/*-win.zip vaccaria/test-project:windows-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/*-linux.tar.bz2 vaccaria/test-project:linux-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/*-mac.zip vaccaria/test-project:mac-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/web.zip vaccaria/test-project:html-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/android/*.apk vaccaria/test-project:android-stable --userversion ${{steps.tag.outputs.tag}}
```