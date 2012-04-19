require "rubygems"
require "bundler/setup"
require "sinatra"
require "awesome_print"

FILE_DIR = File.expand_path(File.dirname(__FILE__))
PROJECT_ROOT = File.expand_path("#{FILE_DIR}/..")

set :port, 80

$LOAD_PATH << FILE_DIR
Dir["#{FILE_DIR}/last-resort/*.rb"].each do |file_path|
  require file_path
end

get "/" do
  "Last Resort server running"
end

# LastResort::WebHookCreator.create_hooks