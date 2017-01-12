$: << __dir__ + "/lib"
require "pinterest"

client_id = "4878490596204882047"
client_secret = "aaa4922dadd0a08b0d767df5263e2e8987f88faa16c4079e17c10c0447c0fce0"
callback_url = "https://local.cowtech.it:3000"
access_token = "AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA"
client = Pinterest::Client.new(client_id: client_id, client_secret: client_secret)

# Authorization
puts client.authorization_url(callback_url)
#puts client.fetch_access_token("3baf2adea5c82d46")
client.access_token = access_token

# Verify authentication
p client.verify_access_token

# User
p client.me