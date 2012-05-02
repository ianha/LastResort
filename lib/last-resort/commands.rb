
module LastResort
  class Commands
    def self.q_and_a project_name
      @last_resort_path = File.expand_path(File.dirname(File.realpath(__FILE__)) + '/../../')

      # TODO preamble each with some info and a launchy launch if necessary
      @twillio_sid = ask "#{'Twillio'.red} SID: "
      @twillio_auth_token = ask "#{'Twillio'.red} Auth Token: "
      @contextio_key = ask "#{'ContextIO'.yellow} Key: "
      @contextio_secret = ask "#{'ContextIO'.yellow} Secret: "
      @contextio_account = ask "#{'ContextIO'.yellow} Account: "

      create_project project_name
    end

    def self.create_project project_name
      @project_path = project_name.to_s

      puts 'Creating project folder'.green
      FileUtils.mkdir @project_path

      puts '* creating .gitignore'.green
      FileUtils.cp "#{@last_resort_path}/support/dot_gitignore", "#{@project_path}/.gitignore"

      puts '* creating config.ru'.green
      FileUtils.cp "#{@last_resort_path}/support/config.ru", "#{@project_path}"

      puts '* creating Gemfile'.green
      FileUtils.cp "#{@last_resort_path}/support/Gemfile", "#{@project_path}"

      puts '* creating schedule.rb'.green
      FileUtils.cp "#{@last_resort_path}/support/schedule.rb", "#{@project_path}"

      # TODO this is wrong. should be Dir.pwd= call. I can explain why when we work tomorrow
      `cd #{project_name}`

      puts 'Installing heroku'.green
      `gem install heroku --no-rdoc --no-ri`
      `heroku plugins:install git://github.com/ddollar/heroku-config.git`

      puts 'Please login to Heroku'
      system 'heroku login'

      puts 'Running bundle install'.green
      `bundle install`

      puts 'Initiating git repo'.green
      `git init`
      `git add .`
      'git commit -m "Created basic Last Resort project structure"'

      puts 'Creating Heroku project'.green
      heroku_output = `heroku create --stack cedar`
      @host = heroku_output.match(/http(.*).com\//)[0]
      create_env

      `git push heroku master`
    end

    def self.create_env
      File.open(@project_path + '/.env', 'w') do |f|
        f.puts File.open(last_resort_path + '/support/dot_env').read % {
          "host" => @host,
          "twilio_sid" => @twillio_sid,
          "twillio_auth_token" => @twillio_auth_token,
          "contextio_account" => @contextio_account,
          "contextio_key" => @contextio_key,
          "contextio_secret" => @contextio_secret
        }
      end
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
  end
end