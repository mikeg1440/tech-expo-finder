require 'bundler'
require 'open-uri'
Bundler.require(:default, :developement)

require_relative '../lib/cli'
require_relative '../lib/event'
require_relative '../lib/scraper'
require_relative '../lib/location'
