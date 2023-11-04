# General

Qt docker conatiners

# Images

Dockerfile contains a build of Qt located at `C:\Qt`.

This image is built with

- Qt 5.15.0
- OpenSSL 1.1.1w, linked for runtime

This image does not include

- QtWebEngine

# Build image

```
$ docker build .
```

## Build Args

- `QT_CONFIGURE_EXTRA` can be set to add configuration options to Qt's `configure` command.

# Pre-built images

Pre-built images are uploaded to the `lgrosz` repository on Docker Hub.

| Name | Tag | `QT_CONFIGURE_EXTRA` |
| --- | --- | --- |
| qt5 | 5.15.0 | |
| qt5 | 5.15.0-static | `-static` |
