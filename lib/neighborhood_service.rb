require "rgeo"
require "rgeo/geo_json"

class NeighborhoodService

  # enforce singleton access, but maybe let's not?
  private_class_method :new

  # geojson flavor of New York City Neighborhood Tabulation Areas (NTAs)
  @@geojson_path = "./NTA.geojsonz"

  # CLASS METHODS

  # allow configuration
  def self.configure(options)
    if options.key? :geojson_path
      @@geojson_path = options[:geojson_path]
    end
  end

  # main interface of this class
  def self.lookup(lat:, lng:)
    @@instance ||= self.send(:new, @@geojson_path)
    @@instance.lookup(lat: lat, lng: lng)
  end

  # INSTANCE METHODS

  # private constructor
  def initialize(path_to_geojson)
    @nta_neighborhoods = RGeo::GeoJSON.decode(File.read(path_to_geojson))
    @factory = @nta_neighborhoods.first.geometry.factory
  end

  # use RGeo to detect the neighborhood polygon containing the given lat/lng
  def lookup(lat:, lng:)
    raise "Numeric lat and lng required" unless lat.is_a?(Numeric) && lng.is_a?(Numeric)

    point = @factory.point(lng, lat)
    match = @nta_neighborhoods.find{ |n| n.geometry.contains? point }
    return unless match

    match.properties
  end
end
