configure :host => "",
          :twilio_sid => "",
          :twilio_auth_token => "",
          :contextio_account => "",
          :contextio_key => "",
          :contextio_secret => ""


# DEFINE YOUR CONTACTS

contact :ian, ""
contact :scott, ""
contact :victor, ""


# DEFINE WHAT EMAILS YOU WANT TO WATCH FOR

match :subject => /server down/ # rackspace ping
match :subject => /resource limit reached/ # monit


# DEFINE WHO TO CALL AND WHEN

between 19..22, :on => [:wednesday, :thursday] do
  call :victor
end

between :off_hours, :on => :weekdays do
  call :scott
end

between :all_hours, :on => :weekends do
  call [:ian, :scott, :victor]
end
