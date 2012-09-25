class Gcm::Notification < Gcm::Base
  self.table_name = "gcm_notifications"

  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :data

  belongs_to :device, :class_name => 'Gcm::Device'
  validates_presence_of :collapse_key if :time_to_live?

  class << self
    # Opens a connection to the Google GCM server and attempts to batch deliver
    # an Array of notifications.
    #
    # This method expects an Array of Gcm::Notifications. If no parameter is passed
    # in then it will use the following:
    #   Gcm::Notification.all(:conditions => {:sent_at => nil})
    #
    # As each Gcm::Notification is sent the <tt>sent_at</tt> column will be timestamped,
    # so as to not be sent again.
    #
    # This can be run from the following Rake task:
    #   $ rake gcm:notifications:deliver
    def send_notifications(notifications = Gcm::Notification.all(:conditions => {:sent_at => nil}, :joins => :device, :readonly => false))

      if configatron.gcm_on_rails.delivery_format and configatron.gcm_on_rails.delivery_format == 'plain_text'
        format = "plain_text"
      else
        format = "json"
      end

      unless notifications.nil? || notifications.empty?
        api_key = Gcm::Connection.open
        if api_key
          notifications.each do |notification|
            response = Gcm::Connection.send_notification(notification, api_key, format)
            if response[:code] == 200
              if format == "json"
                error = ""
                puts "Response is #{:response.inspect}"
                message_data = JSON.parse response[:message]
                success = message_data['success']
                error = message_data['results'][0]['error']  if success == 0
              else   #format is plain text
                message_data = response[:message]
                error = response[:message].split('=')[1]
              end


              case error
                when "MissingRegistration"
                  ex = Gcm::Errors::MissingRegistration.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{notification.device.id}")
                  notification.device.destroy
                when "InvalidRegistration"
                  ex = Gcm::Errors::InvalidRegistration.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{notification.device.id}")
                  notification.device.destroy
                when "MismatchedSenderId"
                  ex = Gcm::Errors::MismatchSenderId.new(response[:message])
                  logger.warn(ex.message)
                when "NotRegistered"
                  ex = Gcm::Errors::NotRegistered.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{notification.device.id}")
                  notification.device.destroy
                when "MessageTooBig"
                  ex = Gcm::Errors::MessageTooBig.new(response[:message])
                  logger.warn(ex.message)
                else
                  notification.sent_at = Time.now
                  notification.save!
              end
            elsif response[:code] == 401
              raise Gcm::Errors::InvalidAuthToken.new(message_data)
            elsif response[:code] == 503
              raise Gcm::Errors::ServiceUnavailable.new(message_data)
            elsif response[:code] == 500
              raise Gcm::Errors::InternalServerError.new(message_data)
            end

          end
        end
      end
    end
  end
end