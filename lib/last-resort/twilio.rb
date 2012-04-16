require 'twilio-ruby'

# Sandbox code
ACCOUNT_SID = ""
AUTH_TOKEN = ""
FROM_NUMBER = ""
HOST = ""

module LastResort

	class Contact
		attr_accessor :name, :number

		def initialize (name = "", number = "")
			@name = name
			@number = number
		end
	end

	class ExceptionSession

		# Array of strings representing numbers
		attr_accessor :contacts, :client, :call, :index, :description, :handled

		def initialize(contacts = [], description = "a general exception has occurred")
			@contacts = contacts
			@description = description
			@client = Twilio::REST::Client.new ACCOUNT_SID, AUTH_TOKEN
			@index = -1
			@handled = false
		end	

	    # Return false if call was not made
		def call_next
			@index += 1
			return false if @contacts.empty? || @index >= @contacts.size ||	@handled

			# @call.hangup if @call # hangup a previous call
			
			# Make the call
			@call = @client.account.calls.create(
			  :from => FROM_NUMBER,
			  :to => @contacts[@index].number,
			  :url => "http://#{HOST}/twilio/call",
			  :status_callback => "http://#{HOST}/twilio/status_callback"
			)		

			return true				
		end	

		# Called when someone in the queue has handled this
		def end
			@handled = true			
		end	

		# Begin the notification cycle
		def notify
			self.call_next
		end	

		# Name of the latest callee (latest call)
		def callee_name
			@contacts[@index].name
		end	

		# Number of latest callee (latest call)
		def callee_number
			@contacts[@index].number
		end		
	end
end

#################    Sinatra endpoints for Twilio callbacks #########################

# This will probably be overwritten by configuration
#exception_session = LastResort::ExceptionSession.new([LastResort::Contact.new("Ian Ha", "+16478963060"), LastResort::Contact.new("Scott Hyndman", "+14167380604")])
$exception_session = nil

get '/twilio' do
	"twilio callbacks up and running!"
end

# Test stub
get '/twilio/test' do
	$exception_session.notify	
end

post '/twilio/status_callback' do
	puts "status_callback with #{params.inspect}"
	$exception_session.call_next
end

post '/twilio/call' do
  content_type 'text/xml'
  puts "call with #{params.inspect}"

  if params[:CallStatus] == 'no-answer'  	
  	return Twilio::TwiML::Response.new { |r| r.Hangup }.text	
  end	

  response = Twilio::TwiML::Response.new do |r|
	  r.Say "hello #{$exception_session.callee_name}. The following error has occured: #{$exception_session.description}", :voice => 'man'
	  r.Gather :numDigits => 1, :action => "http://#{HOST}/twilio/gather_digits" do |d|
	  	d.Say "Please enter 1 to handle this bug that you probably didn't even create or 0 or hangup to go back to spending quality time with your family."
	  end
  end
  response.text
end

post '/twilio/gather_digits' do
  puts "gather_digits with #{params.inspect}"

  content_type 'text/xml'
  digit = params[:Digits].to_i

  case digit
  when 1 # User handles call, so don't call anyone else
  	puts "User entered 1"
  	$exception_session.end  	
  	response = Twilio::TwiML::Response.new do |r|
	  r.Say "Thank you for handling this exception. Goodbye.", :voice => 'man'
	  r.Hangup
  	end
  	return response.text
  else # Hangup this call and go to the next person
  	return Twilio::TwiML::Response.new {|r| r.Hangup}.text	 
  end	  
  
end
