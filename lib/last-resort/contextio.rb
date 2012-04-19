require 'oauth'
require 'json'
require 'net/http'

module ContextIO
  class Connection
    VERSION = "2.0"

    def initialize(key='', secret='', server='https://api.context.io')
      @consumer = OAuth::Consumer.new(key, secret, {:site => server, :sheme => :header})
      @token    = OAuth::AccessToken.new @consumer
    end

    def createWebhook(accountId, parameters)
      post accountId, 'webhooks', parameters
    end

    def listWebhooks(accountId)
      get accountId, 'webhooks'
    end

    def deleteWebhook(accountId, webhook_id)
      delete accountId, "webhooks/#{webhook_id}"
    end

    def deleteAllWebhooks(accountId)
      webhooks = listWebhooks(accountId)
      webhooks.each do |webhook|
        deleteWebhook accountId, webhook["webhook_id"]
      end
    end

    private

    def url(accountId, url, *args)
      if args.empty?
        "/#{VERSION}/accounts/#{accountId}/#{url}"
      else
        "/#{VERSION}/accounts/#{accountId}/#{url}?#{parametrize args}"
      end
    end

    def get(accountId, url, *args)
      response_body = @token.get(url(accountId, url, *args), "Accept" => "application/json").body
      JSON.parse(response_body)
    end

    def post(accountId, url, parameters)
      @token.post(url(accountId, url), parameters)
    end

    def delete(accountId, url, *args)
      @token.delete(url(accountId, url, *args))
    end

    def parametrize(options)
      URI.escape(
        options.collect do |k, v|
          v = v.to_i if k == :since
          v = v.join(',') if v.instance_of?(Array)
          k = k.to_s.gsub('_', '')
          "#{k}=#{v}"
        end.join('&'))
    end
  end
end
