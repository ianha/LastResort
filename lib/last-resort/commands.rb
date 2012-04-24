
module LastResort
  class Commands
    def self.q_and_a project_name
      @last_resort_path = File.expand_path(File.dirname(File.realpath(__FILE__)) + '/../../')
      @twillio_sid = ask "#{'Twillio'.red} SID: "
      @twillio_auth_token = ask "#{'Twillio'.red} Auth Token: "
      @contextio_account = ask "#{'ContextIO'.yellow} Account: "
      @contextio_key = ask "#{'ContextIO'.yellow} Key: "
      @contextio_secret = ask "#{'ContextIO'.yellow} Secret: "

      create_project project_name
    end

    def self.create_project project_name
      @project_path = project_name.to_s
      FileUtils.mkdir @project_path

      FileUtils.cp "#{@last_resort_path}/support/dot_gitignore", "#{@project_path}/.gitignore")
      FileUtils.cp @last_resort_path + '/support/config.ru'), (@project_path)
      FileUtils.cp @last_resort_path + '/support/Gemfile'), (@project_path)
      FileUtils.cp @last_resort_path + '/support/schedule.rb'), (@project_path)

      `cd #{project_name}`
      `gem install heroku`
      `heroku plugins:install git://github.com/ddollar/heroku-config.git`
      `heroku login`
      `bundle install`
      `git init`
      `git add .`
      'git commit -m "init"'
      `heroku create --stack cedar`
      `git push heroku master`


    end

    def create_env
      dot_env = File.open(@project_path + '/.env', 'w')
      dot_env.puts File.open(last_resort_path + '/support/dot_env').read % [@host, @twillio_sid, @twillio_auth_token, @contextio_account, @contextio_key, @contextio_secret]
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