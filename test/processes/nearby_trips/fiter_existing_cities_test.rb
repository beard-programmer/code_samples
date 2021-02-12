# frozen_string_literal: true

require 'test_helper'

module NearbyTrips
  class FilterExistingCitiesTest < ActiveSupport::TestCase
    setup do
      create(:city_schyokino)
      create(:city_moscow)
      create(:city_tula)
      @nearby_trip = load_dumped_object('nearby_shyokino_moscow_trip')
      nt_without_start_city = load_dumped_object('nearby_shyokino_moscow_trip').tap do |nearby_trip|
        nearby_trip.start_city_guid = 'not_existing_city_guid'
      end
      nt_without_end_city = load_dumped_object('nearby_shyokino_moscow_trip').tap do |nearby_trip|
        nearby_trip.end_city_guid = 'not_existing_city_guid'
      end
      @nearby_trips = [@nearby_trip, nt_without_start_city, nt_without_end_city]
      @filter_trips_process = NearbyTrips::FilterExistingCities.new(trips: @nearby_trips)
    end

    it 'filters trips on non existing cities' do
      trips = @filter_trips_process.call
      assert_equal 1, trips.size
      assert_equal @nearby_trip, trips.first
    end
  end
end
