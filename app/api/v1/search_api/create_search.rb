# frozen_string_literal: true

module V1
  module SearchAPI
    class CreateSearch < Grape::API
      desc 'Create search'
      params do
        requires :access_key, type: String, desc: 'Access key'
        optional :ref, type: String, desc: 'Search ref'
        requires :from, type: String, desc: 'From (GID)'
        requires :to, type: String, desc: 'To (GID)'
        requires :on, type: String, desc: 'Date'
        requires :passengers, type: Integer, desc: 'Number of passengers'
        optional :details, type: Array, desc: 'Passengers details' do
          requires :age, type: Integer, desc: 'Kid age'
          requires :seats, type: Integer, desc: 'Seats count'
        end
        requires :locale, type: String, desc: 'Locale'
        requires :signature, type: String
      end

      helpers V1::SearchAPI::Helpers
      helpers do
        def check_passengers_details!
          return if params[:details].blank?

          validator = SearchParamsValidator.new(params.slice(:passengers, :details))
          return if validator.call

          error!({ error: 'Invalid parameters [passengers, details]', details: validator.errors }, 400)
        end

        def search_params
          search_params = (params[:ref].present? && { search_ref: params[:ref] }) || search_params_without_ref
          search_params.merge(service: service, affiliate_key: current_user)
        end

        def nearby_trips_search_params
          NearbyTrips::SearchParams.new(
            search_params_without_ref
              .merge(service: service)
              .except(:domain, :details),
          )
        end

        def search_params_without_ref
          {
            domain: direction.domain,
            from_city: from,
            to_city: to,
            on_date: parsed_date,
            passengers: params[:passengers],
            details: params[:details],
          }
        end

        def parsed_date
          @parsed_date ||= parse_date(params[:on])
        end

        def direction
          @direction ||= domain.directions.find_or_create_by!(from: from, to: to)
        end
      end

      post '/' do
        authenticate!
        verify_signature
        check_suspended_search!

        I18n.with_locale(params[:locale] || current_user.locale) do
          domain.as_current do
            check_passengers_details!

            search = SearchTripsInGds.new(search_params).call
            postprocess = SearchTripsPostprocess.new(search: search)
            search = postprocess.call
            policy = NearbyTrips::SearchPolicy.new(domain, search)

            if policy.search_allowed?
              search.nearby_directions =
                NearbyDirectionDecorator.decorate_collection(
                  NearbyDirections::SearchInGds.new(
                    nearby_trips_search_params:
                      nearby_trips_search_params,
                  ).call,
                )
            end

            present search,
              with: V1::Entities::Search,
              details_changed: search.details_changed?,
              locale: I18n.locale,
              search_ref: search.ref,
              variant: domain.variant,
              domain: domain,
              successful_searches_exist: postprocess.successful_searches_exist
          end
        end
      end
    end
  end
end
