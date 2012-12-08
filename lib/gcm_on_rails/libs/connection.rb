require 'net/https'
require 'uri'

module Gcm
  module Connection
    class << self
      def send_notification(notification, api_key, format)
        if format == 'json'
          headers = {"Content-Type" => "application/json",
                     "Authorization" => "key=#{api_key}"}

          data = notification.data.merge({:collapse_key => notification.collapse_key}) unless notification.collapse_key.nil?
          data = data.merge({:delay_while_idle => notification.delay_while_idle}) unless notification.delay_while_idle.nil?
          data = data.merge({:time_to_live => notification.time_to_live}) unless notification.time_to_live.nil?
          data = data.merge({:registration_ids => notification.devices.map{ |d| d.registration_id } })
          data = data.to_json
        else   #plain text format
          headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
                     "Authorization" => "key=#{api_key}"}

          post_data = notification.data[:data].map{|k, v| "&data.#{k}=#{URI.escape(v)}".reduce{|k, v| k + v}}[0]
          extra_data = "registration_ids=#{notification.devices.map{ |d| d.registration_id }}"
          extra_data = "#{extra_data}&collapse_key=#{notification.collapse_key}" unless notification.collapse_key.nil?
          extra_data = "#{extra_data}&delay_while_idle=1" if notification.delay_while_idle
          data = "#{extra_data}#{post_data}"
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
