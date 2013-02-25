class CreateGcmDevicesNotifications < ActiveRecord::Migration # :nodoc:

  def self.up
    create_table :gcm_devices_notifications, :id => false do |t|
      t.integer :device_id, :null => false
      t.integer :notification_id, :null => false
    end

    add_index :gcm_devices_notifications, [:device_id, :notification_id], :unique => true
  end

  def self.down
    drop_table :gcm_devices_notifications
  end
end
