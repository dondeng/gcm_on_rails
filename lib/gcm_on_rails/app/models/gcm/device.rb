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
class Gcm::Device < Gcm::Base
  self.table_name = "gcm_devices"

  attr_accessible :registration_id

  has_many :notifications, :class_name => 'Gcm::Notification', :dependent => :destroy
  validates_presence_of :registration_id
  validates_uniqueness_of :registration_id

  before_save :set_last_registered_at

  # The <tt>feedback_at</tt> accessor is set when the
  # device is marked as potentially disconnected from your
  # application by Google.
  attr_accessor :feedback_at

  private
  def set_last_registered_at
    self.last_registered_at = Time.now if self.last_registered_at.nil?
  end
end