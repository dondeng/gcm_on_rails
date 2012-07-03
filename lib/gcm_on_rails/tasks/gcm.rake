namespace :gcm do
  namespace :notifications do

    desc "Deliver all unsent Gcm notifications."
    task :deliver => [:environment] do
      Gcm::Notification.send_notifications
    end
  end
end
