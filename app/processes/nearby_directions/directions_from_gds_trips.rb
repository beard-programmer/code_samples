# frozen_string_literal: true

module NearbyDirections
  class DirectionsFromGdsTrips
    def initialize(gds_trips:)
      @gds_trips = gds_trips
    end

    def call
      grouped_trips.map do |(start_city_guid, end_city_guid), gds_trips|
        NearbyDirection.new(
          gillbus_trips: gds_trips,
          city_from: cities_hash[start_city_guid],
          city_to: cities_hash[end_city_guid],
        )
      end
    end

    private

    attr_reader :gds_trips

    def grouped_trips
      @grouped_trips ||= gds_trips.group_by do |trip|
        [
          trip.start_city_guid,
          trip.end_city_guid,
        ]
      end
    end

    def cities_hash
      @cities_hash ||= cities.map { |city| [city.gid, city] }.to_h
    end

    def cities
      @cities ||= City.where(gid: cities_gids)
    end

    def cities_gids
      grouped_trips
        .keys
        .flatten
        .uniq
    end
  end
end
