namespace :gcm do
  namespace :notifications do

    desc "Deliver all unsent Gcm notifications."
    task :deliver, [:type] => [:environment] do |t, args|
      if args.type.nil?
        Gcm::Notification.send_notifications
      else
        Gcm::Notification.send_notifications_by_type(args.type)
      end
    end

  end
end
