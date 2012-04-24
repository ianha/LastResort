require "rubygems"
require "bundler/setup"
require "sinatra"

FILE_DIR = File.expand_path(File.dirname(__FILE__))

require 'last-resort/version'
require 'last-resort/config-lang'
require 'last-resort/contextio'
require 'last-resort/scheduler'
require 'last-resort/twilio'
require 'last-resort/webhooks'
require 'last-resort/controller'

# SINATRA BASICS

set :port, 80

get "/" do
  "Last Resort server running"
end

# LastResort::WebHookCreator.create_hooks