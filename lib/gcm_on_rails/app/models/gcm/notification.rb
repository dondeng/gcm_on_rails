class Gcm::Notification < Gcm::Base
  self.table_name = "gcm_notifications"

  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :data

  belongs_to :device, :class_name => 'Gcm::Device'

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
      unless notifications.nil? || notifications.empty?
        Gcm::Connection.open do |api_key|
          notifications.each do |noty|
            puts "sending notification #{noty.id} to device #{noty.device.registration_id}"
            response = Gcm::Connection.send_notification(noty, api_key)
            puts "response: #{response[:code]}; #{response.inspect}"
            if response[:code] == 200
              case response[:message]
                when "Error=MissingRegistration"
                  ex = Gcm::Errors::MissingRegistration.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{noty.device.id}")
                  noty.device.destroy
                when "Error=InvalidRegistration"
                  ex = Gcm::Errors::InvalidRegistration.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{noty.device.id}")
                  noty.device.destroy
                when "Error=MismatchedSenderId"
                  ex = Gcm::Errors::MismatchSenderId.new(response[:message])
                  logger.warn(ex.message)
                when "Error=NotRegistered"
                  ex = Gcm::Errors::NotRegistered.new(response[:message])
                  logger.warn("#{ex.message}, destroying gcm_device with id #{noty.device.id}")
                  noty.device.destroy
                when "Error=MessageTooBig"
                  ex = Gcm::Errors::MessageTooBig.new(response[:message])
                  logger.warn(ex.message)
                else
                  noty.sent_at = Time.now
                  noty.save!
              end
            elsif response[:code] == 401
              raise Gcm::Errors::InvalidAuthToken.new(response[:message])
            elsif response[:code] == 503
              raise Gcm::Errors::ServiceUnavailable.new(response[:message])
            elsif response[:code] == 500
              raise Gcm::Errors::InternalServerError.new(response[:message])
            end
          end
        end
      end
    end
  end
end