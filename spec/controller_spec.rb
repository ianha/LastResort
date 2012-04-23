require 'spec_helper'

set :environment, :test

describe 'controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/twilio'
    last_response.should be_ok
    last_response.body.should == "Twilio callbacks up and running!"
  end
end