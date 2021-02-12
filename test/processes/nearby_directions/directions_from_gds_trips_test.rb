# frozen_string_literal: true

require 'test_helper'

module NearbyDirections
  class DirectionsFromGdsTripsTest < ActiveSupport::TestCase
    setup do
      create(:city_schyokino)
      @from = create(:city_tula)
      @to = create(:city_moscow)
      nearby_trip = load_dumped_object('nearby_shyokino_moscow_trip')
      @nearby_trips = [nearby_trip]
      @directions_from_trips_process = NearbyDirections::DirectionsFromGdsTrips.new(gds_trips: @nearby_trips)
    end

    it 'builds nearby directions collection from gds nearby trips' do
      directions = @directions_from_trips_process.call

      assert_equal 1, directions.size

      expected_direction = NearbyDirection.new(gillbus_trips: @nearby_trips, city_from: @from, city_to: @to)
      response_direction = directions.first
      assert_equal expected_direction.city_from, response_direction.city_from
      assert_equal expected_direction.city_to, response_direction.city_to
      assert_equal expected_direction.gillbus_trips, response_direction.gillbus_trips
    end
  end
end
