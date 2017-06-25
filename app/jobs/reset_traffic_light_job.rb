class ResetTrafficLightJob < ApplicationJob
  queue_as :default

  def perform(traffic_light)
    if traffic_light.present? 
      traffic_light.update(light_status: false)
    end
  end
end
