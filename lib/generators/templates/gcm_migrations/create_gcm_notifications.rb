class CreateGcmNotifications < ActiveRecord::Migration # :nodoc:

  def self.up

    create_table :gcm_notifications do |t|
      t.integer :device_id, :null => false
      t.string :collapse_key, :null => false
      t.text :data
      t.boolean :delay_while_idle
      t.datetime :sent_at
      t.timestamps
    end

    add_index :gcm_notifications, :device_id
  end

  def self.down
    drop_table :gcm_notifications
  end
end