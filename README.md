# pinterest-ruby

[![Gem Version](https://badge.fury.io/rb/pinterest-ruby.png)](http://badge.fury.io/rb/pinterest-ruby)
[![Dependency Status](https://gemnasium.com/ShogunPanda/pinterest-ruby.png?travis)](https://gemnasium.com/ShogunPanda/pinterest-ruby)
[![Build Status](https://secure.travis-ci.org/ShogunPanda/pinterest-ruby.png?branch=master)](http://travis-ci.org/ShogunPanda/pinterest-ruby)
[![Coverage Status](https://coveralls.io/repos/github/ShogunPanda/pinterest-ruby/badge.svg?branch=master)](https://coveralls.io/github/ShogunPanda/pinterest-ruby?branch=master)

A tiny JSON API framework for Ruby on Rails.

https://sw.cowtech.it/pinterest-ruby

# Introduction

Pinterest API wrapper.

## Usage

### Basic authorization flow

```ruby
require "pinterest"

# Create the client
client = Pinterest::Client.new(client_id: "ID", client_secret: "SECRET")

# Authorization
url = "https://localhost:3000" # The URL MUST be HTTPS and configured on Pinterest Apps console.

puts client.authorization_url(url) # Send the user to this URL.

# ...

# Start a webserver that will listen on the url above, it will get called with a authorization code in the query string.
query = request.params[:code]

token = client.fetch_access_token(query) # This token can be saved for later use (see below).
client.access_token = token

# Play with the API!
p client.me
```

### Authenticated flow

```ruby
require "pinterest"

# Fetch the token saved above
token = "TOKEN"

# Create the client
client = Pinterest::Client.new(access_token: token)

# Play with the API!
p client.me
```

## API Documentation

The API documentation can be found [here](https://sw.cowtech.it/pinterest-ruby/docs).

## Contributing to pinterest-ruby
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.

Licensed under the MIT license, which can be found at http://opensource.org/licenses/MIT.
