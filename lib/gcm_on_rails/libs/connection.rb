require 'net/https'
require 'uri'

module Gcm
  module Connection
    class << self
      def send_notification(notification, api_key, format)

        if format == 'json'
          headers = {"Content-Type" => "application/json",
                     "Authorization" => "key=#{api_key}"}

          data = notification.data.merge({"collapse_key" => notification.collapse_key}) unless notification.collapse_key.nil?
          data = data.merge({"delay_while_idle" => notification.delay_while_idle}) unless notification.delay_while_idle.nil?
          data = data.to_json
        else   #plain text format
        end

        url_string = configatron.gcm_on_rails.api_url
        url = URI.parse url_string
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        resp, dat = http.post(url.path, data, headers)

        return {:code => resp.code.to_i, :message => dat }
      end

      def open
        configatron.gcm_on_rails.api_key
      end
    end
  end
end