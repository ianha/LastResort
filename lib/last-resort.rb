require "rubygems"
require "bundler/setup"
require "sinatra/base"

FILE_DIR = File.expand_path(File.dirname(__FILE__))

require 'last-resort/version'
require 'last-resort/config'
require 'last-resort/contextio'
require 'last-resort/scheduler'
require 'last-resort/twilio'
require 'last-resort/webhooks'
require 'last-resort/controller'

LastResort::Application.run! if $0 == __FILE__

# LastResort::WebHookCreator.create_hooks