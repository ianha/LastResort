require 'rubygems'
require 'last-resort'
require 'rspec'
require 'rack'
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end