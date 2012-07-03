class CreateGcmDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :gcm_devices do |t|
      t.string :registration_id, :size => 120, :null => false
      t.datetime :last_registered_at

      t.timestamps
    end

    add_index :gcm_devices, :registration_id, :unique => true
  end

  def self.down
    drop_table :gcm_devices
  end
end