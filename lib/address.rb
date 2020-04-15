require "geocoder"

class Address
  attr_reader :query, :result, :nta

  NYC_BOUNDING_BOX = [[40.5, -74.3], [40.9, -73.7]]

  # CLASS METHODS

  def self.to_neighborhood_tabulation_area(address_text)
    new(address_text).nta
  end

  # INSTANCE METHODS

  def initialize(address_text)
    @query = address_text
    geocode!
    lookup_neighborhood!
  end

  def geocode!
    @result = Geocoder.search(@query, bounds: NYC_BOUNDING_BOX)&.first
  end

  def geocoded?
    !!@result&.coordinates
  end

  def lookup_neighborhood!
    return unless geocoded?
    lat, lng = @result.coordinates
    @nta = NeighborhoodService.lookup(lat: lat, lng: lng)
  end

  def neighborhood_found?
    !!@nta
  end

  def neighborhood_and_borough
    return unless neighborhood_found?
    @nta.values_at('ntaname', 'boroname').join(", ")
  end

  def to_s
    if geocoded?
      "#<Address \"#{query}\" @ #{result&.coordinates} in #{neighborhood_and_borough}>"
    else
      "#<Address \"#{query}\" not located>"
    end
  end
end
