# frozen_string_literal: true

require 'test_helper'

module NearbyDirections
  class SearchInGdsTest < ActiveSupport::TestCase
    setup do
      create(:city_schyokino)
      @from = create(:city_tula)
      @to = create(:city_moscow)
      nearby_trip = load_dumped_object('nearby_shyokino_moscow_trip')
      @nearby_trips = [nearby_trip]

      NearbyTrips::SearchInGds.any_instance.stubs(:call).returns(@nearby_trips)
      NearbyTrips::FilterExistingCities.any_instance.stubs(:call).returns(@nearby_trips)

      @search_directions_process = NearbyDirections::SearchInGds.new(
        nearby_trips_search_params:
          'params dont matter as we use stubs',
      )
    end

    it 'returns nearby directions' do
      directions = @search_directions_process.call
      assert_equal 1, directions.size

      direction = directions.first

      assert_equal @nearby_trips, direction.gillbus_trips
      assert_equal @from, direction.city_from
      assert_equal @to, direction.city_to
    end
  end
end
