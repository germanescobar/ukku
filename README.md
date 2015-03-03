# Ukku

A command line application that allows you to easily deploy web applications à la Heroku (i.e. using `git push`) **to your own servers**.

**Notes:** 

1. `ukku` is designed to deploy only one application per server.
2. Multi-host deployments are **not** supported.
3. You can deploy an application in multiple servers independently (e.g. for production, staging, etc.).

## Status

Development. **Not suitable for real deployments. Use at your own risk**.

## Installation

The recommended way of installing `ukku` is through Rubygems:

```
$ gem install ukku
```

You need to have CMake and `pkg-config` installed on your system to be able to run the previous command. On OS X, after installing Homebrew, you can get CMake with:

```
$ brew install cmake
```

## Requirements

Launch a server **with Ubuntu** using your favorite provider (AWS, Digital Ocean, Linode, etc.). **Your server must be accessible through a public IP**.

## Usage

1\. `cd` into your application folder and run:

```
$ ukku configure -u <user> <your_server_ip>
```

This command will:

* Configure your server so that it can receive the git push. It will also install a PostgreSQL database.
* Add a remote named "production" to your local git repository (it will initialize the repository if it doesn't exists yet)
* Create a file `.ukku.yml`, and ignore it in `.gitignore`.

2\. Push the repository

```
$ git push production master
```

Your application is now deployed!
