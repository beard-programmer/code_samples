# frozen_string_literal: true

module NearbyTrips
  class SearchPolicy
    def initialize(domain, search)
      @domain = domain
      @search = search
    end

    def search_allowed?
      nearby_cities_option? && nothing_found?
    end

    private

    attr_reader :domain, :search

    def nearby_cities_option?
      domain.nearby_cities
    end

    def nothing_found?
      search.completed && search.trips.empty?
    end
  end
end
