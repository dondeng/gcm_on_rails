namespace :gcm do
  namespace :notifications do

    desc "Deliver unsent Gcm notifications of the specified type."
    task :deliver, [:type] => [:environment] do |t, args|
      if args.type.nil?
        Gcm::Notification.send_notifications
      else
        Gcm::Notification.send_notifications_by_type(args.type)
      end
    end

  end
end
