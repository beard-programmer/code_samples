# frozen_string_literal: true

module NearbyTrips
  class SearchInGds
    def initialize(search_params:)
      @search_params = search_params
    end

    def call
      ordered_trips
    end

    private

    attr_reader :search_params
    # Rails < 6: https://stackoverflow.com/questions/15643172/make-delegated-methods-private
    # Rails = 6: https://github.com/rails/rails/pull/31944
    private *delegate(:service, :from_city, :to_city, :on_date, :passengers, to: :search_params)

    def ordered_trips
      trips.sort_by { |trip| [trip.distance_to_start.to_f, trip.distance_to_end.to_f] }
    end

    def trips
      @trips ||= gillbus_trips.to_a
    end

    def gillbus_trips
      gillbus
        .search_nearby_cities_trips(
          start_city_id: from_gid,
          end_city_id: to_gid,
          start_date_search: on_date,
          ticket_count: passengers,
        ).trips
    end

    def gillbus
      @gillbus ||= service.new_session(request_options: { timeout: Config['search_trips_timeout'] })
    end

    def from_gid
      from_city.gid
    end

    def to_gid
      to_city.gid
    end
  end
end
