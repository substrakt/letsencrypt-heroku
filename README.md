# letsencrypt-heroku

> Let's make *everything* secure.

With the advent of free SSL and Heroku finally offering free SSL endpoints, it's about time we made it ridiculously easy to get an SSL cert for any Heroku application and keep it up to date.

**This is alpha software. It may work, or it may not. We use it in production at [Substrakt](https://substrakt.com) but your milage may vary until 1.0.**

## What it does
1. Generates a private key.
1. Validates domain ownership using DNS verification for a set of domains including the root. **(Only works with CloudFlare currently!)**
1. Generates a CSR.
1. Generates a LetsEncrypt certificate.
1. Enables the http-sni feature on a specified Heroku application.
1. Adds or updates the certificate with the newly generated one.

## How it works
1. User or robot makes an API request to this application.
1. Magic happens.
1. Site is secure.

## Limitations
As we're currently in alpha, there are some severe limitations.

1. Heroku apps must be in the common runtime. `http-sni` is not supported in private spaces, yet. This shouldn't be a problem for 99% of applications.
1. DNS must be managed by CloudFlare.
1. Renewals do not happen automatically. (Not sure if this is in the scope of this application or whether or not the application itself should handle renewals?)
1. We're using an unreleased Heroku API endpoint and `http-sni` is beta. If it changes or is removed, this application will simply cease to work.
1. It doesn't currently add the CNAME records to CloudFlare once the SSL certificate has been generated. (Possibly out of scope?)

## Usage
1. Run the application.
1. Hit the following endpoint:

```
GET domains/{domain_name}?subdomains={subdomains}&debug={0/1}&app_name={heroku_app_name}
```

Parameters:

`domain_name` is the domain name without subdomains. (e.g. `google.com` == Good. `www.google.com` == Bad.)
`subdomains` is a comma delimited list of subdomains to cover. Usually this is just `www`, but could also be anything else such as `www,dishwasher,git,purple`.
`debug` is `1` or `0` depending if this is a test or not. When debug is on, non-valid certificates are generated.
`heroku_app_name` is the name of the application on Heroku.

**That's it.**

## Contributing
Pull requests and issues are very much welcome at this early stage.
