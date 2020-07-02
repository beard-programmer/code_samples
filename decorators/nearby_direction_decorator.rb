# frozen_string_literal: true

class NearbyDirectionDecorator < Draper::Decorator
  delegate :distance_to_start_city, :distance_to_end_city, :min_price, :trips_count
  delegate :localized_slug, to: :start_city, prefix: true
  delegate :localized_slug, to: :end_city, prefix: true

  def start_city_id
    start_city&.id
  end

  def start_city_name
    start_city&.name
  end

  def end_city_id
    end_city&.id
  end

  def end_city_name
    end_city&.name
  end

  private

  def start_city
    object.city_from
  end

  def end_city
    object.city_to
  end
end
