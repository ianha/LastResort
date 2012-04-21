module LastResort
  class Config

    CONFIG_PATH = "schedule.rb"

    attr_accessor :host, # The host provided to services for webhooks
                  :contacts, # A map of symbolized names to contact hashes
                  :matchers, # A list of objects describing emails that trigger alerts
                  :schedules, # A list of day and hour ranges and their associated contacts
                  :local_utc_offset_in_seconds, # The developer's local time offset, used server side to determine when to call
                  :twilio_sid, :twilio_auth_token, # Twilio creds
                  :contextio_account, :contextio_key, :contextio_secret # Context.io creds

    def initialize
      @contacts = {}
      @matchers = []
      @schedules = []
      run_config_in_context
    end

    protected

    def run_config_in_context
      source = open(CONFIG_PATH).read
      self.instance_eval source
    end

    def configure params
      @host = params[:host]
      @twilio_sid = params[:twilio_sid]
      @twilio_auth_token = params[:twilio_auth_token]
      @contextio_key = params[:contextio_key]
      @contextio_secret = params[:contextio_secret]
      @contextio_account = params[:contextio_account]
    end

    def local_utc_offset offset_in_hours
      @local_utc_offset_in_seconds = offset_in_hours * 60 * 60
    end

    def contact name, phone
      @contacts[name] = { :name => name, :phone => scrub_phone(phone) }
    end

    def match matcher
      @matchers << matcher
    end

    def between hours, options
      hours = hours.is_a?(Array) ? hours : [hours]

      days = options[:on] || :everyday
      days = days.is_a?(Array) ? days : [days]

      @current_schedule = {
        :hours => hours,
        :days => days
      }

      yield

      @schedules << @current_schedule
      @current_schedule = nil
    end

    def call contacts
      contacts = contacts.is_a?(Array) ? contacts : [contacts]
      @current_schedule[:contacts] = contacts
    end

    def scrub_phone phone
      phone.gsub!(/\D/, '')
      phone = "+1#{phone}" unless phone.start_with? "+1"
      phone
    end
  end
end

CONFIG = LastResort::Config.new