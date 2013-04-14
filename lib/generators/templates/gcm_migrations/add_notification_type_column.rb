class AddNotificationTypeColumn < ActiveRecord::Migration # :nodoc:
  def self.up
    add_column :gcm_notifications, :notification_type, :string
  end

  def self.down
    remove_column :gcm_notifications, :notification_type
  end
end
