# General a docker container with Qt in it

# Images

Dockerfile contains a build of Qt, without QtWebengine, with openssl linked for runtime. This is not a development image. Use it to copy Qt into your own image.

# Build image

```
$ docker build .
```

# Pull image

```
$ docker pull lgrosz/qt5:5.15.0
```
