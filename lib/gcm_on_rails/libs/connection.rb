require 'net/https'
require 'uri'

module Gcm
  module Connection
    class << self
      def send_notification(notification, api_key, format)
        url_string = configatron.gcm_on_rails.api_url
        url = URI.parse url_string
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        if format == 'json'
          headers = {"Content-Type" => "application/json",
                     "Authorization" => "key=#{api_key}"}

          data = {:data => notification.data }
          data = data.merge({:collapse_key => notification.collapse_key}) unless notification.collapse_key.nil?
          data = data.merge({:delay_while_idle => notification.delay_while_idle}) unless notification.delay_while_idle.nil?
          data = data.merge({:time_to_live => notification.time_to_live}) unless notification.time_to_live.nil?
          data = data.merge({:registration_ids => notification.devices_ids})
          data = data.to_json
          resp = http.post(url.path, data, headers)
          return {:code => resp.code.to_i, :message => resp.body }

        else   #plain text format
          headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
                     "Authorization" => "key=#{api_key}"}

          post_data = notification.data.map{|k, v| "data.#{k}=#{URI.escape(v)}"}
          post_data << "collapse_key=#{notification.collapse_key}" unless notification.collapse_key.nil?
          post_data << "delay_while_idle=1" if notification.delay_while_idle
          post_data = post_data.join("&")


          return notification.devices_ids.collect do |device_id|
            device_id_data = "registration_id=#{device_id}"
            notification_device_post_data = "#{device_id_data}&#{post_data}"
            resp = http.post(url.path, notification_device_post_data, headers)
            {:code => resp.code.to_i, :message => resp.body }
          end

        end
      end

      def open
        configatron.gcm_on_rails.api_key
      end
    end
  end
end