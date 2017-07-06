require "list_matcher"

module CompressorByRegex
  class Parser
    attr_reader :postal_codes

    def initialize(postal_codes)
      @postal_codes = postal_codes.dup
    end

    def parse
      wildcard_postalcodes = extract_wildcard_postalcodes
      wildcard_postalcodes_parsed = parse_wildcard_postalcodes(wildcard_postalcodes)

      postal_codes_ranges = group_by_ranges
      postal_codes_parsed = create_regex_based_on_ranges

      wildcard_postalcodes_parsed.any? ? postal_codes_parsed.concat(wildcard_postalcodes_parsed) : postal_codes_parsed
    end

    private
      def extract_wildcard_postalcodes
        @postal_codes = @postal_codes.partition {|postal_code| postal_code.include?("%")}
        wildcard_postalcodes = @postal_codes.first
        @postal_codes = @postal_codes.last
        wildcard_postalcodes
      end

      def parse_wildcard_postalcodes(wildcard_postalcodes)
        wildcard_postalcodes.map do |postal_code|
        result =
          if postal_code.start_with?("LIKE")
            postal_code.slice!("LIKE ")
            parse_positive_wildcard(postal_code)
          elsif postal_code.start_with?("NOT LIKE")
            postal_code.slice!("NOT LIKE ")
            parse_negative_wildcard(postal_code)
          elsif postal_code.include?("%")
            parse_positive_wildcard(postal_code)
          else
            nil
          end

          result
        end
      end

      def parse_positive_wildcard(postal_code)
        "/^#{postal_code.gsub("%", ".*")}$/"
      end

      def parse_negative_wildcard(postal_code)
        if postal_code.start_with? "%"
          postal_code.slice!("%")
          "/^.*(?<!#{postal_code})$/"
        elsif postal_code.end_with? "%"
          postal_code.slice!("%")
          "/^(?!#{postal_code}).*$/"
        end
      end

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