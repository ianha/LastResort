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

  describe "on a phone call" do
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

    it "should call the next person when a call ends" do
      @exception_session.should_receive("call_next")
      post '/twilio/status_callback', {}
    end

    context "when receiving user input" do

      it "should hangup if selected digit is not 1" do
        post '/twilio/gather_digits', {:Digits => "0"}
        last_response.body.should eq Twilio::TwiML::Response.new { |r| r.Hangup }.text
      end

      it "should end the call queue when receiving a digit of 1" do
        @exception_session.should_receive("end")
        post '/twilio/gather_digits', {:Digits => "1"}
      end

      it "should say a final message and hangup when receiving a digit of 1" do
        @exception_session.should_receive("end")
        post '/twilio/gather_digits', {:Digits => "1"}
        doc = Nokogiri::XML(last_response.body)
        doc.xpath('//Hangup').size.should eq 1
        doc.xpath('//Say').size.should eq 1
      end

    end
  end

  describe "on receiving a matched email" do
    before (:each) do
      $exception_session = @exception_session = double("LastResort::ExceptionSession")
      @exception_session.stub("callee_name").and_return("Ian Ha")
      @exception_session.stub("description").and_return("+111")
      $scheduler = @scheduler = double("LastResort::Scheduler")
      @scheduler.should_receive(:get_matching_schedule).with(any_args()).and_return({:contacts => []})
      @exception_session.should_receive(:notify)
      JSON.should_receive(:parse).with(any_args()).and_return({"message_data" => {"subject" => 'foo'}})

      class LastResort::Application
        def new_scheduler
          $scheduler
        end

        def new_exception_session(*args)
          $exception_session
        end

        def get_request_body(*args)
          ""
        end
      end

      # puts LastResort::ExceptionSession.methods.sort
      # LastResort::ExceptionSession.should_receive(:new).with(any_args()).and_return(@exception_session)
      # LastResort::ExceptionSession.should_receive("exception_session").and_return(@exception_session)
    end

    it "should begin call sequence" do
      post '/matched_email', {}
    end
  end


end