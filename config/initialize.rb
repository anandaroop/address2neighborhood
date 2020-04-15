NeighborhoodService.configure(
  geojson_path: "./NTA.geojson"
)

Geocoder.configure(
  lookup: :google,
  api_key: ENV['GEOCODER_API_KEY'],
  cache: Redis.new,
  cache_prefix: "a2n_"
)

