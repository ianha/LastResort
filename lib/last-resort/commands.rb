require 'launchy'

module LastResort
  class Commands
    def self.q_and_a project_name
      @last_resort_path = File.expand_path(File.dirname(File.realpath(__FILE__)) + '/../../')

      puts 'Last Resort is a Ruby gem for monitoring critical emails sent by automated services (monit, logging packages, external ping services, etc.) and calling your phone to tell you about it.'
      puts ''

      @no_heroku = !(ask_yes_no "Do you want it to be hosted on #{'Heroku'.magenta} (recommended)? [Y/n] ")
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
      Launchy.open("http://console.context.io") unless answer
      puts ''
      puts "Please find the ContextIO key and secret tokens, as well as the ContextIO Account ID of the email account you wish to monitor."
      @contextio_key = ask "#{'ContextIO'.yellow} Key: "
      @contextio_secret = ask "#{'ContextIO'.yellow} Secret: "
      @contextio_account = ask "#{'ContextIO'.yellow} Account: "
    end

    def self.create_project project_name
      @project_path = project_name.to_s

      create_project_folder
      copy_files
      copy_schedule_and_add_utc
      Dir.chdir("#{@project_path}")
      set_up_heroku unless @no_heroku
      `bundle install`
      set_up_git unless @no_heroku
      create_heroku_project unless @no_heroku
      create_env
      `git push heroku master` unless @no_heroku
      Dir.chdir("#{@last_resort_path}")
    end

    def self.create_project_folder
      puts "Creating project folder".green
      FileUtils.mkdir @project_path
    end

    def self.copy_files
      puts '* creating .gitignore'.green
      FileUtils.cp "#{@last_resort_path}/support/dot_gitignore", "#{@project_path}/.gitignore"

      puts '* creating config.ru'.green
      FileUtils.cp "#{@last_resort_path}/support/config.ru", "#{@project_path}"

      puts '* creating Gemfile'.green
      FileUtils.cp "#{@last_resort_path}/support/Gemfile", "#{@project_path}"
    end

    def self.copy_schedule_and_add_utc
      puts '* creating schedule.rb'.green
      schedule_file = File.open(@project_path + '/schedule.rb', 'w')
      schedule_file.puts File.open(@last_resort_path + '/support/schedule.rb').read % { :utc_offset => Time.now.utc_offset/60/60 }
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
      'git commit -m "init"'
    end

    def self.create_heroku_project
      puts 'Creating Heroku project'.green
      heroku_output = `heroku create --stack cedar`
      @host = heroku_output.match(/http(.*).com\//)[0]
    end

    def self.create_env
      env_file = File.open('.env', 'w')
      env_file.puts File.open(@last_resort_path + '/support/dot_env').read % {
        :host => (@no_heroku) ? '' : @host,
        :twilio_sid => @twillio_sid,
        :twilio_auth_token => @twillio_auth_token,
        :contextio_account => @contextio_account,
        :contextio_key => @contextio_key,
        :contextio_secret => @contextio_secret,
        :no_heroku => @no_heroku
      }
      puts 'Please remember to fill in the Host information in the .env file.'.yellow
    end
  end
end