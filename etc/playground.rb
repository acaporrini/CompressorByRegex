require_relative "../lib/compressor_by_regex"
require "json"
require "benchmark"
require "to_regexp"
require "list_matcher"

postal_codes = JSON.parse(File.read("postalcodes.json"))
regular_expressions = []
time =
  Benchmark.realtime do
    parser = CompressorByRegex::Parser.new(postal_codes)
    regular_expressions = parser.parse
  end


puts "Postal Codes parsed: #{postal_codes.size}"
puts "Regex generated: #{regular_expressions.size}"
puts "Time taken: #{time} sec"


list_matcher = List::Matcher.new
regular_expressions_2 = list_matcher.pattern(postal_codes, :atomic => false)

puts regular_expressions.size
puts regular_expressions_2.size

# This checks that all the original postalcodes are matching at least one of the generated regex, however the 40k postal codes example takes a lot of time to run

# it_works =
#   postal_codes.none? do |postal_code|
#     not_found = regular_expressions.none? {|regex| (regex.to_regexp =~ postal_code).nil? }
#     puts "#{Time.now} -- PostalCode #{postal_code} not matched: #{not_found}"

#     not_found
#   end

# puts "All postalcodes matched" if it_works

