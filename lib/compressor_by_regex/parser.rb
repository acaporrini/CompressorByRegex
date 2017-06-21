require "list_matcher"

module CompressorByRegex
  class Parser
    attr_reader :postal_codes

    def initialize(postal_codes)
      @postal_codes = postal_codes
    end

    def parse
      postal_codes_ranges = group_by_ranges
      create_regex_based_on_ranges
    end

    private
      def group_by_ranges
        _postal_codes = @postal_codes.sort
        actual = _postal_codes.first

        _postal_codes.slice_before do |e|
          expected, actual = actual.next, e
          expected != actual
        end.to_a
      end

      def create_regex_based_on_ranges
        postal_codes_ranges = group_by_ranges

        regexps = []
        list_matcher = List::Matcher.new

        postal_codes_ranges.each do |range|
          regexps << list_matcher.pattern(range, :atomic => false)
        end

        regexps.map do |regex|
          "/^#{regex}$/"
        end
      end
  end
end