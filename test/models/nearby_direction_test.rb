require 'test_helper'

class NearbyDirectionTest < ActiveSupport::TestCase
  setup do
    @city_tula = create(:city_tula)
    @city_moscow = create(:city_moscow)
  end

  describe 'nearby direction with nearby trips' do
    let(:city_from) { @city_tula }
    let(:city_to) { @city_moscow }

    let(:nearby_trip) { load_dumped_object('nearby_shyokino_moscow_trip') }
    let(:nearby_trip_doubled_cost) do
      load_dumped_object('nearby_shyokino_moscow_trip').tap do |nearby_trip|
        nearby_trip.total_cost += nearby_trip.total_cost
      end
    end
    let(:nearby_trips) { [nearby_trip, nearby_trip_doubled_cost] }
    let(:nearby_direction) { NearbyDirection.new(city_from: city_from, city_to: city_to, gillbus_trips: nearby_trips) }

    it 'returns distance to start city' do
      assert_equal nearby_trip.distance_to_start, nearby_direction.distance_to_start_city
    end
    it 'returns distance to end city' do
      assert_equal nearby_trip.distance_to_end, nearby_direction.distance_to_end_city
    end
    it 'returns min price' do
      assert_equal nearby_trips.map(&:total_cost).min, nearby_direction.min_price
    end
    it 'returns trips number' do
      assert_equal nearby_trips.size, nearby_direction.trips_count
    end
  end

  describe 'nearby direction without nearby trips' do
    let(:city_from) { @city_tula }
    let(:city_to) { @city_moscow }

    let(:nearby_direction) { NearbyDirection.new(city_from: city_from, city_to: city_to) }

    it 'returns distance to start city' do
      assert_nil nearby_direction.distance_to_start_city
    end
    it 'returns distance to end city' do
      assert_nil nearby_direction.distance_to_end_city
    end
    it 'returns min price' do
      assert_nil nearby_direction.min_price
    end
    it 'returns trips number' do
      assert_equal 0, nearby_direction.trips_count
    end
  end
end
