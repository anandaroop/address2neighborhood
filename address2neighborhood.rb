require "geocoder"
require "redis"
require "benchmark"
require "rgeo"
require "rgeo/geo_json"
require "byebug"
# byebug

NYC_BBOX = [[40.5, -74.3], [40.9, -73.7]]
NTA_NEIGHBORHOODS = RGeo::GeoJSON.decode(File.read("./NTA.geojson"))
FACTORY = NTA_NEIGHBORHOODS.first.geometry.factory

Geocoder.configure(
  lookup: :google,
  api_key: ENV['GEOCODER_API_KEY'],
  cache: Redis.new,
  cache_prefix: "a2n_"
)

# given a point, return the NYC neighborhood that contains it
def lookup_neighborhood(lat, lng)
  return unless lat.is_a?(Numeric) && lng.is_a?(Numeric)

  point = FACTORY.point(lng, lat)
  match = NTA_NEIGHBORHOODS.find{ |n| n.geometry.contains? point }
  return unless match

  match.properties
end

# given a querystring, return the geocoded results
def process(query)
  results = Geocoder.search(query, bounds: NYC_BBOX)
  if first_result = results&.first
    # formatted_address = first_result.formatted_address
    lat, lng = first_result.coordinates
    # neighborhood = first_result.data['address_components'].find{ |part| part['types'].include? "neighborhood"}['long_name']
    if nta_neighborhood = lookup_neighborhood(lat, lng)
      ntacode = nta_neighborhood['ntacode']
      ntaname = nta_neighborhood['ntaname']
      boroname = nta_neighborhood['boroname']
      formatted_neighborhood = [ntaname, boroname].join(", ")
    end
  end

  # puts [query, formatted_address, neighborhood, ntacode, formatted_neighborhood, lng, lat].inspect
  # puts [query, formatted_neighborhood].join("\t")
  puts "%60s\t%s" % [query, formatted_neighborhood]
end

# process a single query from command line arg OR multiple queries from standard input
if ARGV.length.zero?
  STDIN.each_with_index do |line, i|
    query = line.chomp
    process(query)

    if (i+1) % 5 == 0
      puts
    end
  end
else
  query = ARGV.join(" ")
  process(query)
end
