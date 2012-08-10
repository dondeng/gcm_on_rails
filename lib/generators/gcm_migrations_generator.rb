require 'rails/generators/active_record'
# Generates the migrations necessary for Gcm on Rails.
# This should be run upon install and upgrade of the
# Gcm on Rails gem.
#
#   $ ruby script/generate gcm_migrations
class GcmMigrationsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  # Set the current directory as base for the inherited generators.
  def self.base_root
    File.dirname(__FILE__)
  end

  source_root File.expand_path('../templates/gcm_migrations', __FILE__)

  def create_migrations
    templates = {
      'create_gcm_notifications.rb' => 'db/migrate/create_gcm_notifications.rb',
      'create_gcm_notification_devices.rb' => 'db/migrate/create_gcm_notification_devices.rb'
    }

    templates.each_pair do |name, path|
      begin
        migration_template(name, path)
      rescue => err
        puts "WARNING: #{err.message}"
      end
    end
  end
end # GcmMigrationsGenerator