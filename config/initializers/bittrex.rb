# fix bittrex lib
require "addressable/uri"

Bittrex.config do |c|
  c.key = At::Settings.bittrex.key
  c.secret = At::Settings.bittrex.secret
end
