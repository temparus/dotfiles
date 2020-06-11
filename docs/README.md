# dotfiles

This is the collection of configuration files used on my machines. There are configuration files for the shell customizations, git, VPN and others.

## Serve the documentation

You can serve this documentation on your local machine with the following command using docker:

```shell
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```

The documentation can be accessed at http://localhost:8000

## Build the documentation

You can also build the static files for the documentation website using the following command with docker:

```shell
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material build
```

The generated files can be found in the directorz `${PWD}/site/`.
