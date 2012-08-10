class Gcm::Notification < Gcm::Base
  self.table_name = "gcm_notifications"

  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper
  serialize :data

  attr_accessible :collapse_key, :data, :delay_while_idle, :time_to_live
  has_many :notification_devices, :class_name => 'Gcm::NotificationDevice', :dependent => :destroy


  validates :collapse_key, :presence => true,  :if => :time_to_live?
  validates :data, :presence => true

  def devices_ids
    notification_devices.collect { |notification_device| notification_device.registration_id }
  end

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
  def self.send_notifications(notifications = Gcm::Notification.includes(:notification_devices).where({:sent_at => nil}, :readonly => false))
    api_key, format = Gcm::Connection.open, configatron.gcm_on_rails.delivery_format
    logger.warn("notifications cannot be delivered when api key is not defined") and return if api_key.blank?
    logger.warn("notifications cannot be delivered when data format is neither json or plain_text") and return unless ["json","plain_text"].include?(format)
    return if notifications.blank?

    notifications.each do |notification|
      logger.warn("notification #{notification.id} cannot be delivered when no device was specified") and next if notification.notification_devices.blank?

      response = Gcm::Connection.send_notification(notification, api_key, format)

      if format == "json"
        update_notification_from_json_response(response,notification)
      else   #format is plain text
        update_notification_from_plain_text_response(response,notification)
      end
    end
  end

  private

  def self.update_notification_from_json_response(response,notification)
    Gcm::Notification.transaction do
      devices_results = JSON.parse response[:message]
      notification.sent_at = Time.now
      notification.save

      notification.notification_devices.each_index do |notification_index|
        notification_device = notification.notification_devices[notification_index]
        notification_device.response_code = response[:code]
        if response[:code] == 200
          notification_response = devices_results["results"][notification_index]
          if notification_response.has_key?("error")
            notification_device.response_error = notification_response["error"]
          else
            notification_device.response_error = nil
          end
        end
        notification_device.save
      end
    end
  end

  def self.update_notification_from_plain_text_response(response,notification)
    Gcm::Notification.transaction do
      notification.sent_at = Time.now
      notification.save

      notification.notification_devices.each_index do |notification_index|
        notification_device = notification.notification_devices[notification_index]
        response_code = response[notification_index][:code]
        device_result = response[notification_index][:message]
        notification_device.response_code = response_code
        if response_code == 200
          if device_result.start_with?("Error=")
            error_code = device_result.sub("Error=","")
            notification_device.response_error = error_code
          else
            notification_device.response_error = nil
          end
        end
        notification_device.save
      end
    end
  end

end