# Represents an Android phone.
# An Gcm::Device can have many Gcm::Notification.
#
# In order for the Gcm::Feedback system to work properly you *MUST*
# touch the <tt>last_registered_at</tt> column every time someone opens
# your application. If you do not, then it is possible, and probably likely,
# that their device will be removed and will no longer receive notifications.
#
# Example:
#   Device.create(:registration_id => 'FOOBAR')
class Gcm::NotificationDevice < Gcm::Base
  self.table_name = "gcm_notification_devices"

  attr_accessible :notification_id, :registration_id
  belongs_to :notification, :class_name => "Gcm::Notification"
  validates :registration_id, :presence => true, :uniqueness => { :scope => :notification_id }
  validates :notification_id, :presence => true



  # The <tt>feedback_at</tt> accessor is set when the
  # device is marked as potentially disconnected from your
  # application by Google.
  #attr_accessor :feedback_at
end