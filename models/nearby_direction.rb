# frozen_string_literal: true

class NearbyDirection
  attr_accessor :gillbus_trips, :city_from, :city_to

  def initialize(gillbus_trips: [], city_from:, city_to:)
    @gillbus_trips = gillbus_trips
    @city_from = city_from
    @city_to = city_to
  end

  def distance_to_start_city
    gillbus_trips.first&.distance_to_start
  end

  def distance_to_end_city
    gillbus_trips.first&.distance_to_end
  end

  def min_price
    gillbus_trips.map(&:total_cost).compact.min
  end

  def trips_count
    gillbus_trips.size
  end
end
