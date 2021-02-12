# frozen_string_literal: true

module NearbyTrips
  class FilterExistingCities
    def initialize(trips:)
      @trips = trips
    end

    def call
      trips_on_existing_cities
    end

    private

    attr_reader :trips

    def trips_on_existing_cities
      @trips_on_existing_cities ||= trips.filter { |trip| on_existing_city?(trip) }
    end

    def on_existing_city?(trip)
      existing_cities_gids.include?(trip.start_city_guid) && existing_cities_gids.include?(trip.end_city_guid)
    end

    def existing_cities_gids
      @existing_cities_gids ||= City.where(gid: cities_gids).pluck(:gid)
    end

    def cities_gids
      (start_cities_gids + end_cities_gids).uniq
    end

    def start_cities_gids
      trips.map(&:start_city_guid)
    end

    def end_cities_gids
      trips.map(&:end_city_guid)
    end
  end
end
