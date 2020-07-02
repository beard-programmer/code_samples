# frozen_string_literal: true

module NearbyDirections
  class SearchInGds
    def initialize(nearby_trips_search_params:)
      @nearby_trips_search_params = nearby_trips_search_params
    end

    def call
      NearbyDirections::DirectionsFromGdsTrips.new(
        gds_trips:
          NearbyTrips::FilterExistingCities.new(
            trips:
              NearbyTrips::SearchInGds.new(
                search_params:
                  nearby_trips_search_params,
              ).call,
          ).call,
      ).call
    end

    private

    attr_reader :nearby_trips_search_params
  end
end
