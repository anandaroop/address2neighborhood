require "geocoder"
require "redis"
require_relative "lib/neighborhood_service"
require_relative "lib/address"
require_relative "config/initialize"

def process(query)
  address = Address.new(query)
  puts "%60s\t%s" % [query, address.neighborhood_and_borough]
end

def process_command_line
  query = ARGV.join(" ")
  process(query)
end

def process_standard_input
  STDIN.each_with_index do |line, i|
    query = line.chomp
    process(query)

    if (i+1) % 5 == 0
      puts
    end
  end
end

def command_line_arg?
  ARGV.length > 0
end

# process a single query from command line arg OR multiple queries from standard input
if command_line_arg?
  process_command_line
else
  process_standard_input
end
