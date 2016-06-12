if RailsPushNotifications::GCMApp.table_exists? && !RailsPushNotifications::GCMApp.where(gcm_key: ENV['GOOGLE_AUTH_KEY']).exists?
  RailsPushNotifications::GCMApp.destroy_all
  RailsPushNotifications::GCMApp.create(gcm_key: ENV['GOOGLE_AUTH_KEY'])
end