require 'rubygems'
require 'bundler'

# Bring in the dependencies
Bundler.require

# Create context-io webhooks (destroyed and recreated on every application run)
LastResort::WebHookCreator.create_hooks

# Run!
run LastResort::Application