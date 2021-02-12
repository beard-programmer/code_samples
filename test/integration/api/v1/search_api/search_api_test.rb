# frozen_string_literal: true

require 'test_helper'

module V1
  class SearchAPITest < APITest
    def generate_rating(from:, to:, trip:, votes:)
      rating = TripRating.new(
        from: from,
        to: to,
        carrier_id: trip.carrier_id,
        carrier_name: trip.carrier_name,
        start_time: trip.start_time,
        technical_condition: 4.5,
        punctuality: 3.5,
        politeness: 2.5,
        cleanless: 1.5,
        avg_rating: (4.5 + 3.5 + 2.5 + 1.5) / 4,
        votes_count: votes,
      )
      rating.token =
        TripRating.make_token_for_trip(from_id: from.id, to_id: to.id, trip: trip)
      rating.save!
    end

    describe 'POST /search' do
      setup do
        @domain = create(:domain_ru, nearby_cities: true)
        @affiliate_key = create(:affiliate_key, domain: @domain, key: 'search-test')
        @kiev = create(:city_kiev)
        @warsaw = create(:city_warsaw)
        @bangkok = create(:city_bangkok)
        booking_config = ServiceConfig.first
        booking_config.cities << @kiev << @warsaw << @bangkok
      end


      it 'returns empty search on non existing direction' do
        @search = create(:search, domain: @domain, from: @kiev, to: @bangkok, trips: [])

        # stubs search
        BaseService.stubs(:booking)
        SearchTripsInGds.any_instance.stubs(:call).returns(@search)

        post '/v1/search', params: signed_params(
          access_key: @affiliate_key.key,
          from: @kiev.gid,
          to: @bangkok.gid,
          on: '2017-01-21',
          passengers: '1',
          locale: 'ru',
        )

        assert_response 201
        assert_equal false, json_body['search']['successful_searches_exist']
      end

      it 'returns empty search with nearby trips' do
        schyokino = create(:city_schyokino)
        moscow = create(:city_moscow)
        tula = create(:city_tula)
        @search = create(:search, domain: @domain, from: schyokino, to: moscow, trips: [], completed: true)
        nearby_trip = load_dumped_object('nearby_shyokino_moscow_trip')

        BaseService.stubs(:booking)
        SearchTripsInGds.any_instance.stubs(:call).returns(@search)
        NearbyTrips::SearchPolicy.any_instance.stubs(:search_allowed?).returns(true)
        NearbyTrips::SearchInGds.any_instance.stubs(:call).returns([nearby_trip])

        post '/v1/search', params: signed_params(
          access_key: @affiliate_key.key,
          from: schyokino.gid,
          to: moscow.gid,
          on: '2020-03-23',
          passengers: '1',
          locale: 'ru',
        )

        assert_response 201

        assert_equal 1, json_body['search']['nearby_directions'].size
        response_direction = json_body['search']['nearby_directions'].first

        assert_equal tula.id, response_direction['start_city_id']
        assert_equal nearby_trip.start_city_name, response_direction['start_city_name']

        assert_equal moscow.id, response_direction['end_city_id']
        assert_equal nearby_trip.end_city_name, response_direction['end_city_name']

        assert_equal nearby_trip.distance_to_start, response_direction['distance_to_start_city']
        assert_equal nearby_trip.distance_to_end, response_direction['distance_to_end_city']
        assert_equal nearby_trip.total_cost.to_s.to_f, response_direction['min_price']
        assert_equal 1, response_direction['count']
      end
    end
  end
end
