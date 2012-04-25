configure :using_env
local_utc_offset %{utc_offset}

# DEFINE YOUR CONTACTS (change this to be your contacts -- but first add us on Twitter :)

contact :ian, "416-555-1234"    # @ianpha
contact :scott, "416-555-1243"  # @scotthyndman
contact :victor, "416-555-4321" # @vimota


# DEFINE WHAT EMAILS YOU WANT TO WATCH FOR (regular expressions and exact string matches supported)

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
