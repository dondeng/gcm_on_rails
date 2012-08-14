class CreateGcmNotificationDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :gcm_notification_devices do |t|
      t.string :registration_id, :size => 120, :null => false
      t.references :notification
      t.integer :response_code
      t.string  :response_error
      t.timestamps
    end

    add_index :gcm_notification_devices, :registration_id
    add_index :gcm_notification_devices, [:registration_id,:notification_id], :unique => true, :name => 'index_gcm_notification_devices_on_nid_and_rid'
    add_index :gcm_notification_devices, :notification_id
  end

  def self.down
    drop_table :gcm_notification_devices
  end
end