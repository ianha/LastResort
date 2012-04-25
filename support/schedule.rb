# CONFIGURATION

# By default, configuration values are supplied by environment variables, or read out of the
# .env file in your project's directory. The .env is added to a .gitignore by default, because
# keys should not be committed to source control.
configure :using_env 

# You can optionally replace the line above with in-place configuration, but we don't recommend it,
# because keys have no place in source control.
# configure :host => "",
#           :twilio_sid => "",
#           :twilio_auth_token => "",
#           :contextio_account => "",
#           :contextio_key => "",
#           :contextio_secret => ""


# Sets your local timezone, because your server may run in a different timezone, and you don't want 
# to be called at the wrong times of day, do you?
local_utc_offset %{utc_offset}

# Define contacts. Names must be symbols
contact :ian, "416-555-1234"
contact :scott, "416-555-1243"
contact :victor, "416-555-4321"


# DEFINE WHAT EMAILS YOU WANT TO WATCH FOR (regular expressions and exact string matches supported)

match :subject => /server down/ # external server ping service
match :subject => /resource limit reached/ # monit


# DEFINE WHO TO CALL AND WHEN

between 19..22, :on => [:wednesday, :thursday] do
  call :victor
end

between :off_hours, :on => :weekdays do
  call :scott
end

between :all_hours, :on => :weekends do
  week = Time.now.week
  case week % 3
  when 0
    call :ian
  when 1
    call :scott
  when 2
    call :victor
  end
  
end
