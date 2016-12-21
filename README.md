# letsencrypt-heroku

[![Code Climate](https://codeclimate.com/github/substrakt/letsencrypt-heroku/badges/gpa.svg)](https://codeclimate.com/github/substrakt/letsencrypt-heroku)
[![Build Status](https://travis-ci.org/substrakt/letsencrypt-heroku.svg?branch=master)](https://travis-ci.org/substrakt/letsencrypt-heroku)

**This is the master branch. It contains all the latest changes and should not be used in production unless you know what you're doing.** While `master` is supposed to be in a usable state, it may (and probably will) contain breaking changes from the last release.

**Current stable release is [3.1.1](https://github.com/substrakt/letsencrypt-heroku/releases/tag/3.1.1)**

> Let's make *everything* secure.

With the advent of free SSL and Heroku finally offering free SSL endpoints, it's about time we made it ridiculously easy to get an SSL cert for any Heroku application and keep it up to date.

We wrote a blog post about it [here](https://substrakt.com/heroku-ssl-me-weve-come-a-long-way/)

[![Substrakt Logo](http://birmingham-made-me.org/wp-content/uploads/2014/03/substrakt-logo-300x55.png)](https://substrakt.com/)

Created by [Substrakt](https://substrakt.com).

## What it does
1. Provides an API to generate SSL certificates.
1. Generates SSL certificates using DNS records to validate ownership.

## Limitations
1. DNS must be managed by CloudFlare.

## Installation

You can install letsencrypt-heroku either directly on to Heroku, use Docker Compose or download the code and deploy it yourself anywhere you can run a Rack app.

First off, you'll need a Heroku auth token.

1. `heroku plugins:install heroku-cli-oauth`
1. `heroku authorizations:create -d "letsencrypt-heroku"`
1. Save the token from this. We'll use it later.

### Installation on Heroku

1. Deploy automatically to Heroku using this button: [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/substrakt/letsencrypt-heroku/tree/master)
1. Input all the required parameters as asked for by the Heroku setup wizard. This includes the heroku token from above.
1. This will set up the application and all dependencies automatically including a free instance of Heroku Redis. (Redis is used to process background jobs amongst other things.)
1. On the command line run `heroku config:get AUTH_TOKEN`. The response is the secret token. **Every request made to the API must have the query parameter `auth_token=TOKEN` added to it. You'll receive a 403 error if you forget to do this.**

### Run using Docker Compose

This application comes with a `docker-compose.yml` file. Assuming you have Docker installed, you can run `docker-compose up` and you'll be up and running immediately.

### Installation elsewhere
You can deploy this application anywhere you can run a Rack app. (Azure, Heroku, AWS, local, etc.)

1. Download the repo `git clone https://github.com/substrakt/letsencrypt-heroku.git`
1. Install Redis. (`brew install redis`)
1. Install foreman (`gem install foreman`)
1. Copy `.envsample` to `.env` using `cp .envsample .env`. The `.env` file is read when the application starts and should contain all of the required environment variables. One of these is the token generated earlier for Heroku. **DO NOT COMMIT THIS FILE TO SOURCE CONTROL**
1. Run the application locally using `foreman start`.
1. Deploy however you want to!

## Usage
1. Hit the following endpoint:

```
POST /certificate_request

{
	"auth_token": "CHOSEN AUTH TOKEN",
	"domains": ["www.substrakt.com", "substrakt.com"],
	"zone": "CLOUDFLARE DOMAIN ZONE",
	"heroku_app_name": "NAME OF HEROKU APP",
	"cloudflare_api_key": "API KEY OF CLOUDFLARE ACCOUNT",
	"cloudflare_email": "CLOUDFLARE EMAIL ADDRESS",
	"heroku_oauth_token": "HEROKU OAUTH TOKEN"
}
```


This will start the process in the background and output something like this:

```
{
  "status": "queued",
  "uuid": "a97fc5e2fce7bc60a96aa4c3e4907152",
  "url": "http://0.0.0.0/certificate_request/a97fc5e2fce7bc60a96aa4c3e4907152?auth_token=testtesttest"
}
```

That API URL will give you updates as to the certificate generation process. You should poll this to check how it's going. Redis is used as a store for status updates as well as the backend for Resque.

The output looks something like this:

```
{"status":"finished","message":"Generated certificate"}
```



**That's it.**

## Contributing
Pull requests and issues are very much welcome at this early stage.
