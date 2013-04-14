require 'rails/generators/active_record'
# Generates the migrations necessary for upgrading Gcm on Rails.
#
#   $ ruby script/generate gcm_upgrade
class GcmUpgradeGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  # Set the current directory as base for the inherited generators.
  def self.base_root
    File.dirname(__FILE__)
  end

  source_root File.expand_path('../templates/gcm_migrations', __FILE__)

  def create_migrations
    templates = {
      'remove_device_notifications_column.rb' => 'db/migrate/remove_device_notifications_column.rb',
      'create_gcm_devices_notifications.rb' => 'db/migrate/create_gcm_devices_notifications.rb',
      'add_notification_type_column.rb' => 'db/migrate/add_notification_type_column.rb'
    }

    templates.each_pair do |name, path|
      begin
        migration_template(name, path)
      rescue => err
        puts "WARNING: #{err.message}"
      end
    end
  end
end # GcmUpgradeGenerator
