module LastResort
  def self.handleTwilioCallback request_body
    return if LastResort::Scheduler.new.get_matching_schedule.nil?

    contact_names = LastResort::Scheduler.new.get_matching_schedule[:contacts]
    contacts = []
    contact_names.each do |name|
      contacts.push(LastResort::Contact.new(name.to_s, CONFIG.contacts[name][:phone]))
    end

    hookData = JSON.parse(request_body.read)
    ap hookData
    ap contacts
    $exception_session = LastResort::ExceptionSession.new(contacts, hookData["message_data"]["subject"])
    $exception_session.notify
  end
end

post '/matched_email' do
  LastResort::handleTwilioCallback request.body
end