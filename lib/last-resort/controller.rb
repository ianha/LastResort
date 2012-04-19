exception_session = nil

################### Sinatra endpoints for Context-IO callbacks ######################

post '/matched_email' do
  return if LastResort::Scheduler.new.get_matching_schedule.nil?

  contact_names = LastResort::Scheduler.new.get_matching_schedule[:contacts]
  contacts = []
  contact_names.each do |name|
    contacts.push(LastResort::Contact.new(name.to_s, CONFIG.contacts[name][:phone]))
  end

  hookData = JSON.parse(request_body.read)
  exception_session = LastResort::ExceptionSession.new(contacts, hookData["message_data"]["subject"])
  exception_session.notify
end

#################    Sinatra endpoints for Twilio callbacks #########################

# This will probably be overwritten by configuration
#exception_session = LastResort::ExceptionSession.new([LastResort::Contact.new("Ian Ha", "+16478963060"), LastResort::Contact.new("Scott Hyndman", "+14167380604")])
exception_session = nil

get '/twilio' do
  "twilio callbacks up and running!"
end

# Test stub
get '/twilio/test' do
  exception_session.notify
end

post '/twilio/status_callback' do
  puts "status_callback with #{params.inspect}"
  exception_session.call_next
end

post '/twilio/call' do
  content_type 'text/xml'
  puts "call with #{params.inspect}"

  if params[:CallStatus] == 'no-answer'
    return Twilio::TwiML::Response.new { |r| r.Hangup }.text
  end

  response = Twilio::TwiML::Response.new do |r|
    r.Say "hello #{exception_session.callee_name}. The following error has occured: #{exception_session.description}", :voice => 'man'
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
    exception_session.end
    response = Twilio::TwiML::Response.new do |r|
    r.Say "Thank you for handling this exception. Goodbye.", :voice => 'man'
    r.Hangup
    end
    return response.text
  else # Hangup this call and go to the next person
    return Twilio::TwiML::Response.new {|r| r.Hangup}.text
  end
end