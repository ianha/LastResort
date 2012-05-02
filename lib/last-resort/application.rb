


require 'sinatra/base'

module LastResort
  class Application < Sinatra::Base

    def initialize
      super
    end

    # The exception session keeps state between twilio and context-io webhooks. Currently, the
    # system can only handle one call session at a time, although we plan to change that in future
    # versions.
    def self.exception_session
      @exception_session
    end

    def self.exception_session=(session)
      @exception_session = session
    end

    # ====== SERVER CHECK ROUTE

    get "/" do
      "Last Resort server running"
    end

    # ====== CONTEXT-IO TWILIO ENDPOINTS

    post '/matched_email' do
      scheduler = new_scheduler
      matching_schedule = scheduler.get_matching_schedule

      return if matching_schedule.nil?

      matched_email = JSON.parse(get_request_body)
      contacts = matching_schedule[:contacts].map { |name| LastResort::Contact.new(name.to_s, @config.contacts[name][:phone]) }

      Application.exception_session = new_exception_session(contacts, matched_email["message_data"]["subject"])
      Application.exception_session.notify
    end


    # ====== SINATRA TWILIO ENDPOINTS

    # Service check method
    get '/twilio' do
      "Twilio callbacks up and running!"
    end

    # Performs a test call based on the user's configuration
    get '/twilio/test' do
      Application.exception_session.notify
    end

    # Method invoked to determine how the machine should interact with the user.
    post '/twilio/call' do
      content_type 'text/xml'
      puts "call with #{params.inspect}"

      if params[:CallStatus] == 'no-answer'
        return Twilio::TwiML::Response.new { |r| r.Hangup }.text
      end

      response = Twilio::TwiML::Response.new do |r|
        r.Say "Hello #{Application.exception_session.callee_name}. The following error has occured: #{Application.exception_session.description}", :voice => 'man'
        r.Gather :numDigits => 1, :action => "http://#{HOST}/twilio/gather_digits" do |d|
          d.Say "Please enter 1 to handle this bug that you probably didn't even create or 0 or hangup to go back to spending quality time with your family."
        end
      end
      response.text
    end

    # Called when a user's call ends
    post '/twilio/status_callback' do
      puts "status_callback with #{params.inspect}"
      Application.exception_session.call_next
    end

    # Called to respond to user phone input
    post '/twilio/gather_digits' do
      puts "gather_digits with #{params.inspect}"

      content_type 'text/xml'
      digit = params[:Digits].to_i

      case digit
      when 1 # User handles call, so don't call anyone else
        Application.exception_session.end

        response = Twilio::TwiML::Response.new do |r|
          r.Say "Thank you for handling this exception. Goodbye.", :voice => 'man'
          r.Hangup
        end
        return response.text
      else # Hangup this call and go to the next person
        return Twilio::TwiML::Response.new {|r| r.Hangup}.text
      end
    end

    private

    def new_scheduler
      LastResort::Scheduler.new
    end

    def get_request_body
      request_body.read
    end

    def new_exception_session *args
      puts "original called"
      LastResort::ExceptionSession.new(*args)
    end
  end
end
