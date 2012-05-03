require 'launchy'
require 'config'

module LastResort
  class Commands
    def self.q_and_a project_name
      @last_resort_path = File.expand_path(File.dirname(File.realpath(__FILE__)) + '/../../')

      puts "#{"Last Resort".green} is a Ruby gem for monitoring critical emails sent by automated services (monit, logging packages, external \nping services, etc.) and calling your phone to tell you about it.\n\n"

      get_twillio_info
      get_contextio_info

      create_project project_name
    end

    def self.ask_yes_no message
      begin
        answer = ask message
      end while !(answer.casecmp('y') == 0 or answer.casecmp('n') == 0)
      answer.casecmp('y') == 0
    end

    def self.ask message
      begin
        print message
        response = $stdin.gets.strip
        if response.empty?
          puts "Sorry you must enter something."
        end
      end while response.empty?

      response
    end

    def self.get_twillio_info
      answer = ask_yes_no "Do you already have a #{'Twillio'.red} account? [Y/n]"
      Launchy.open("http://www.twilio.com/try-twilio") unless answer
      @twillio_sid = ask "#{'Twillio'.red} SID: "
      @twillio_auth_token = ask "#{'Twillio'.red} Auth Token: "
      puts ''
    end

    def self.get_contextio_info
      answer = ask_yes_no "Do you already have a #{'ContextIO'.yellow} account? [Y/n]"
      Launchy.open("http://www.context.io") unless answer
      puts ''
      puts "Please find the ContextIO key and secret tokens, as well as the ContextIO Account ID of the email account you wish to monitor."
      @contextio_key = ask "#{'ContextIO'.yellow} Key: "
      @contextio_secret = ask "#{'ContextIO'.yellow} Secret: "
      @contextio_account = ask "#{'ContextIO'.yellow} Email Account ID: "
    end

    def self.create_project project_name
      @project_path = project_name.to_s

      create_project_folder
      copy_files
      copy_schedule_and_add_utc

      old_dir = Dir.pwd
      Dir.chdir("#{@project_path}")

      `bundle install`

      use_heroku = use_heroku?
      if use_heroku
        set_up_heroku
        set_up_git
        create_heroku_project
      end

      create_env

      `git push heroku master` if use_heroku

      puts "\nNext steps:".yellow
      puts "1) cd #{project_name}"
      puts "2) last-resort run"

      Dir.chdir("#{old_dir}")
    end

    def self.create_project_folder
      puts "\nCreating project folder"
      FileUtils.mkdir @project_path
    end

    def self.copy_files
      puts '  creating .gitignore'
      FileUtils.cp "#{@last_resort_path}/support/dot_gitignore", "#{@project_path}/.gitignore"

      puts '  creating config.ru'
      FileUtils.cp "#{@last_resort_path}/support/config.ru", "#{@project_path}"

      puts '  creating Gemfile'
      FileUtils.cp "#{@last_resort_path}/support/Gemfile", "#{@project_path}"
    end

    def self.copy_schedule_and_add_utc
      puts '* creating schedule.rb'.green
      schedule_file = open(@project_path + '/schedule.rb', 'w') do |f|
        f.puts open(@last_resort_path + '/support/schedule.rb').read % {
          :utc_offset => Time.now.utc_offset/60/60
        }
      end
    end

    def self.use_heroku?
      puts ''
      @no_heroku = !(ask_yes_no "Do you want it to be hosted on #{'Heroku'.magenta} (recommended)? [Y/n] ")
      not @no_heroku
    end

    def self.set_up_heroku
      puts 'Installing heroku'.green
      `gem install heroku --no-rdoc --no-ri`
      `heroku plugins:install git://github.com/ddollar/heroku-config.git`

      answer = ask "Do you already have a #{'Heroku'.magenta} account? [Y/n]"
      Launchy.open("http://heroku.com") if answer.casecmp('n') == 0
      puts 'Please login to Heroku'
      system 'heroku login'
    end

    def self.set_up_git
      puts 'Initiating git repo'.green
      `git init`
      `git add .`
      `git commit -m "Initializing git"`
    end

    def self.create_heroku_project
      puts 'Creating Heroku project'.green
      heroku_output = `heroku create --stack cedar`
      @host = heroku_output.match(/http(.*).com\//)[0]
    end

    def self.create_env
      open('.env', 'w') do |f|
        f.puts open(@last_resort_path + '/support/dot_env').read % {
          :host => (@no_heroku) ? '' : @host,
          :twilio_sid => @twillio_sid,
          :twilio_auth_token => @twillio_auth_token,
          :contextio_account => @contextio_account,
          :contextio_key => @contextio_key,
          :contextio_secret => @contextio_secret,
          :no_heroku => @no_heroku
        }
      end

      if @no_heroku
        puts 'Settings for Last Resort are stored in a .env file that can be found in the project directory.'.yellow
        puts 'In order to run your project, you must modify the .env to include the domain name of your server.'.yellow
      end
    end

    # ====== RUN

    def self.run_heroku_or_rackup
      begin
        LastResort::Config::populate_env_if_required
      rescue
        puts 'Make sure to run "last-resort run" from a last-resort project'.yellow
        return
      end

      @no_heroku = ENV['NO_HEROKU'].chomp == 'true'
      if @no_heroku
        `rackup`
      else
        `git push heroku master`
      end
    end
  end
end