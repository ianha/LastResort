module LastResort
  class WebHookCreator
    def self.create_hooks
      config = Config.new
      contextio = ContextIO::Connection.new(config.contextio_key, config.contextio_secret)

      # Delete everything...
      contextio.deleteAllWebhooks config.contextio_account

      # ...then recreate based on the configuration
      config.matchers.each do |matcher|
        contextio.createWebhook CONFIG.contextio_account,
          :callback_url => "http://#{CONFIG.host}/matched_email",
          :failure_notif_url => "http://google.ca",
          :filter_subject => matcher[:subject].source,
          :sync_period => "immediate"
      end
    end
  end
end