# renpy-to-itch

A Docker container for building Ren'Py games and publishing them to itch.io.

## Summary

This project provides a pre-built Docker image containing:
- **Ren'Py SDK** (configurable version, default 8.6.0)
- **Android SDK** for building Android APKs
- **butler** CLI for pushing builds to itch.io
- Required build tools (Java, Python, ffmpeg, etc.)

## Quick Start

### 1. Use the Pre-built Image

Pull the image from GitHub Container Registry:
```bash
docker pull ghcr.io/flamingherb/renpy-to-itch:latest
```

### 2. Configure Your GitHub Actions Workflow

Add this workflow to `.github/workflows/build.yml`:

```yaml
name: "Itch.io Export"

on:
  push:
    tags:
      - "v*"      
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/flamingherb/renpy-to-itch:latest
    steps:
        - name: Checkout
          uses: actions/checkout@v5
          with:
              lfs: true

        - name: Get latest tag pushed
          id: tag
          uses: 32teeth/action-github-tag@v1.0.7
          with:
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

        - name: Ren'Py PC Distributions
          run: |
            cd /renpy-*/
            ./renpy.sh launcher distribute ${{ github.event.repository.name }}/ --destination ~/builds
            ./renpy.sh launcher web_build ${{ github.event.repository.name }}/ --destination ~/builds/web

        - name: Ren'Py Mobile Distributions
          run: |
            cd /renpy-*/
            ./renpy.sh launcher android_build ${{ github.event.repository.name }}/ --destination ~/builds/android

        - name: Place API Key to butler_creds
          run: |
            mkdir -p ~/.config/itch/
            touch ~/.config/itch/butler_creds
            echo -n ${{ secrets.Itch_API_Key }} | cat > ~/.config/itch/butler_creds
        
        - name: Push All to Itch
          run: |
            butler push ~/builds/*-win.zip itch-user/your-game:windows-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/*-linux.tar.bz2 itch-user/your-game:linux-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/*-mac.zip itch-user/your-game:mac-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/web.zip itch-user/your-game:html-stable --userversion ${{steps.tag.outputs.tag}}
            butler push ~/builds/android/*.apk itch-user/your-game:android-stable --userversion ${{steps.tag.outputs.tag}}
```

## Configuration

### Required Secrets

Add these in your GitHub repository settings:
- `Itch_API_Key`: Your itch.io butler API key

### Customizing the Build

1. **Update game version**: Edit the `sed` command in the workflow to match your game's version format
2. **Update itch.io channel names**: Replace `itch-user/your-game:windows-stable` with your actual game/channel names
3. **Change Ren'Py version**: Build the image with `--build-arg renpy_sdk_version=8.6.0`

## Building the Container Locally

```bash
docker build -t renpy-to-itch .
```

## Building and Publishing the Container

This project includes a workflow (`.github/workflows/docker.yml`) that automatically builds and pushes the container to GHCR when you push a version tag.

To release a new version:
```bash
git tag v1.0.0
git push origin v1.0.0
```

The image will be available at:
- `ghcr.io/flamingherb/renpy-to-itch:v1.0.0`
- `ghcr.io/flamingherb/renpy-to-itch:latest`

## Files

| File | Description |
|------|-------------|
| `Dockerfile` | Container definition with Ren'Py SDK, Android SDK, and butler |
| `.github/workflows/docker.yml` | CI workflow to build and push the container |
| `README.md` | Original documentation with example workflow |