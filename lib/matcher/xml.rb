require 'matcher/nokogiri_extensions'
require 'ostruct'

module Matcher

  class MatchError < StandardError
  end

  class Xml

    NOT_FOUND = "[Not found]"
    EXISTENCE = "[Existence]"
    UNMATCHED = "[Unmatched]"

    attr_reader :lhs, :rhs, :custom_matchers, :results

    def initialize(lhs, custom_matchers = {})
      @lhs = parse(lhs)
      @custom_matchers = custom_matchers
      @results = {}
    end

    def match_on(path, options = {}, &blk)
      raise ArgumentError.new("Using block AND options is not supported for custom matching") if blk && !options.empty?
      excluding = options[:excluding]
      raise ArgumentError.new "'excluding' option must be a regular expression" if excluding && !excluding.kind_of?(Regexp)
      @custom_matchers[path] = blk || options
    end

    alias_method :on, :match_on

    def match(actual)
      @results.clear
      @rhs = parse(actual)
      compare(@lhs, @rhs)
    end

    def record(path, result, expected, actual)
      # support 0 as true (for regex matches)
      r = (!result || result.nil?) ? false : true
      was_custom_matched = @custom_matchers[path] ? true : false
      @results[path] = OpenStruct.new(:result => r, :expected => expected, :actual => actual, :was_custom_matched => was_custom_matched)
    end

    def result_for(path)
      return "matched" if matches[path]
      return "mismatched" if mismatches[path]
      "unmatched"
    end

    def matches
      results_that_are(true)
    end

    def mismatches
      results_that_are(false)
    end

    def evaluate(path, expected, actual)
      custom_matcher = custom_matchers[path]
      match = custom_matcher ? evaluate_custom_matcher(custom_matcher, expected, actual) : expected == actual
      record(path, match, expected, actual)
      match
    end

    private

      def evaluate_custom_matcher(custom_matcher, expected, actual)
        custom_matcher.kind_of?(Hash) ? evaluate_as_regex(custom_matcher, expected, actual) : custom_matcher.call(actual)
      end

      def evaluate_as_regex(custom_matcher, expected, actual)
        exclude_pattern = custom_matcher[:excluding]
        match_data = expected.match(exclude_pattern)
        return false unless match_data
        
        if match_data.captures.empty?
          lhs = expected.sub(exclude_pattern, "")
          rhs = actual.sub(exclude_pattern, "")
        else
          lhs_exclude = expected.match(exclude_pattern).captures.first
          rhs_exclude = actual.match(exclude_pattern).captures.first
          lhs = expected.sub(/#{lhs_exclude}/, "")
          rhs = actual.sub(/#{rhs_exclude}/, "")
        end

        raise Matcher::MatchError.new("excluding option resulted in comparing empty values") if lhs.empty?
        lhs == rhs
      end

      def results_that_are(value)
        match_info = {}
        @results.each { |path, info| match_info[path] = info if info.result == value}
        match_info
      end

      def parse(xml)
        xml_as_string = xml.instance_of?(Nokogiri::XML::Document) ? xml.to_xml : xml
        Nokogiri::XML(xml_as_string) { |config| config.noblanks }
      end

      def compare(lhs, rhs)
        return false unless lhs && rhs
        match = true
        lhs.traverse { |node| match &= node.match?(rhs, self) }
        match
      end

  end

end
