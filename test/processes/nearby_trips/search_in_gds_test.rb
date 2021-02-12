# frozen_string_literal: true

require 'test_helper'

module NearbyTrips
  class SearchInGdsTest < ActiveSupport::TestCase
    setup do
      @from = create(:city_schyokino)
      @to = create(:city_moscow)
      @search_date = Date.current
      @search_passengers = 1
    end

    def search_trips(**params)
      default_params = {
        from_city: @from,
        to_city: @to,
        on_date: @search_date,
        passengers: @search_passengers,
      }
      NearbyTrips::SearchInGds.new(
        search_params:
          NearbyTrips::SearchParams.new(
            default_params.merge(params),
          ),
      ).call
    end

    describe 'connect to gds and load results' do
      def stub_gillbus_search_nearby_trips
        service = mock
        gillbus = mock
        response = load_dumped_object('nearby_trips/search_response_shyokino_moscow')

        service.expects(:new_session)
          .with(
            request_options: {
              timeout: Config['search_trips_timeout'],
            },
          )
          .returns(gillbus)

        gillbus.expects(:search_nearby_cities_trips)
          .with(
            start_city_id: @from.gid,
            end_city_id: @to.gid,
            start_date_search: @search_date,
            ticket_count: @search_passengers,
          )
          .returns(response)

        service
      end

      it 'successfully connects to gds and loads nearby trips results' do
        gillbus_service = stub_gillbus_search_nearby_trips
        search_trips(service: gillbus_service)
      end
    end

    describe 'connect to gds and zero results' do
      def stub_gillbus_search_nearby_trips
        service = mock
        gillbus = mock
        response = load_dumped_object('nearby_trips/search_response_empty')

        service.expects(:new_session)
          .with(
            request_options: {
              timeout: Config['search_trips_timeout'],
            },
          )
          .returns(gillbus)

        gillbus.expects(:search_nearby_cities_trips)
          .with(
            start_city_id: @from.gid,
            end_city_id: @to.gid,
            start_date_search: @search_date,
            ticket_count: @search_passengers,
          )
          .returns(response)

        service
      end

      it 'successfully connects to gds and loads zero trips results' do
        gillbus_service = stub_gillbus_search_nearby_trips
        search_trips(service: gillbus_service)
      end
    end
  end
end
