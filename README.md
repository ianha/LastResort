Last Resort is a Ruby gem for monitoring email sent by automated services (monit, logging packages,
external ping services, etc.) and calling your phone to tell you about the important ones. Using free and trial tiers
available from [context.io](http://context.io), [twilio](http://twilio.com) and [heroku](http://heroku.com),
Last Resort can be deployed in a reliable environment and perform up to 1500 emergency calls **for free**.

### Requirements
* Ruby 1.9.x
* Accounts with [context.io](http://context.io), [twilio](http://twilio.com) and optionally [heroku](http://heroku.com),
  but don't worry -- our commandline utility will help you through the process.
* git (if you're deploying to Heroku)

### Installation
```sh
$ gem install last-resort
```

### Getting started
```sh
$ last-resort new my-awesome-project
```
This will create a new monitoring project with a sample `my-awesome-project/schedule.rb` file, and all that's
needed to get up and running on a Rack server (or Heroku) quickly.

### Example schedule.rb file

```ruby
configure :from_env

# DEFINE YOUR CONTACTS

contact :ian, "416-123-1234"
contact :scott, "416-321-4321"
contact :victor, "416-123-4321"

# DEFINE WHAT EMAILS YOU WANT TO WATCH FOR

match :subject => /Server down/ # external ping service
match :subject => /Resource limit matched/ # monit

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
```

### Roadmap
If there is sufficient demand, we plan on adding more complicated schedules.

### Credit
Victor Mota ([@vimota](http://www.twitter.com/vimota))
Scott Hyndman ([@scotthyndman](http://www.twitter.com/scotthyndman))
Ian Ha ([@ianpha](http://www.twitter.com/ianpha))