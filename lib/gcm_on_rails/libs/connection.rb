require 'net/https'
require 'uri'

module Gcm
  module Connection
    class << self
      def send_notification(noty, api_key)
        headers = {"Content-Type" => "application/x-www-form-urlencoded",
                   "charset" => "UTF-8",
                   "Authorization" => "key=#{api_key}"}

        message_data = noty.data.map{|k, v| "&data.#{k}=#{URI.escape(v)}"}.reduce{|k, v| k + v}
        data = "registration_id=#{noty.device.registration_id}&collapse_key=#{noty.collapse_key}#{message_data}"
        data = data + "&delay_while_idle" if noty.delay_while_idle

        url_string = configatron.gcm_on_rails.api_url
        url = URI.parse url_string
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        resp, dat = http.post(url.path, data, headers)

        return {:code => resp.code.to_i, :message => dat}
      end

      def open
        yield configatron.gcm_on_rails.api_key
      end
    end
  end
end