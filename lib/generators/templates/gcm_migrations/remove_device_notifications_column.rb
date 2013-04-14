class RemoveDeviceNotificationsColumn < ActiveRecord::Migration # :nodoc:
  def self.up
    remove_column :gcm_notifications, :device_id
  end

  def self.down
    add_column :gcm_notifications, :device_id, :null => false
  end
end
