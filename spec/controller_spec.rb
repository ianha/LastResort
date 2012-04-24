require 'spec_helper'
require 'last-resort/twilio'


describe 'LastResort' do
  include Rack::Test::Methods

  def app
    LastResort::Application
  end

  it "should be up and running" do
    get '/twilio'
    last_response.should be_ok
    last_response.body.should == "Twilio callbacks up and running!"
  end

  describe "on initial phone call" do
    before(:each) do
      @exception_session = double("LastResort::ExceptionSession")
      @exception_session.stub("callee_name").and_return("Ian Ha")
      @exception_session.stub("description").and_return("+111")
      LastResort::Application.exception_session = @exception_session
    end

  	it "should hang up when the user does not answer the call" do
			post "/twilio/call", {:CallStatus => 'no-answer'}
  		last_response.body.should eq Twilio::TwiML::Response.new { |r| r.Hangup }.text
  	end

  	it "should gather a single digit response if the user picks up" do
  		post "/twilio/call", {:CallStatus => 'completed'}
  		doc = Nokogiri::XML(last_response.body)
  		doc.xpath('//Gather[@numDigits="1"]').size.should eq 1
  	end
  end
end